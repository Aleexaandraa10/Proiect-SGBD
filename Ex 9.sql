-- Sa se determine urmatoarele informatii pentru filmele specificate de utilizatori, 
-- care sunt difuzate intr-o singura zi in cinematograful indicat:
-- 1. Numarul de rezervari facute pentru film.
-- 2. Venitul total generat de rezervarile pentru film.
-- 3. Pentru clientii care au realizat rezervari:
--      a. Sa se calculeze pretul rezervarii, tinandu-se cont de punctele bonus acumulate.
-- 4. Sa se clasifice acesti clienti in functie de punctele bonus dupa cum urmeaza:
--      a. Client ocazional: intre 100 si 150 puncte bonus.
--      b. Client activ: intre 150 si 190 puncte bonus.
--      c. Client loial: peste 190 puncte bonus.

-- Tabele utilizate: cinematograf, difuzeaza, film, rezervare, clienti

create or replace procedure
    ex9(id_film in film.cod_film%type,
        id_cinema in cinematograf.cod_cinematograf%type,
        nr_rezervari out number, --determinarea punctului 1 din cerinta
        categorie out varchar2) -- determinarea punctului 4 din cerinta
is
    venit_total number; --variabila pentru determinarea punctului 2 din cerinta
    mesaj istoric_erori.mesaj_eroare%type;
    exista_film film.nume_film%type; 
    exista_cinema number;
    exista_rezervari number;
    exista_o_zi date;
    eroare_client varchar2(40);
    
    
    --cursor pentru a determina orele la care se difuzeaza filmul avand codul id_film
    cursor c_ore is
        select t.ora_inceput inceput, t.ora_final final
        from difuzeaza d, table(d.perioade_difuzare) t
        where d.cod_film = id_film;
    
    --cursor pentru a putea afisa detalii despre rezervarile clientilor (punctul 3 din cerinta)
    cursor c_rezervari is
        select
           cl.nume_client as nume,
           cl.prenume_client as prenume,
           cl.puncte_bonus as puncte,
           r.pret_bilet*r.numar_persoane as pret_initial,
           r.pret_bilet*r.numar_persoane - cl.puncte_bonus/10 as pret_final
        from cinematograf c
            join difuzeaza d on c.cod_cinematograf = d.cod_cinematograf
            join film f on d.cod_film = f.cod_film
            join rezervare r on f.cod_film = r.cod_film
            join clienti cl on r.cod_client = cl.cod_client
        where f.cod_film = id_film and c.cod_cinematograf = id_cinema;
    
    
    -- Declarare exceptii proprii
    NU_EXISTA_CINEMA EXCEPTION;
    NU_EXISTA_REZERVARI EXCEPTION;
    FARA_CATEGORIE EXCEPTION;

begin
    -- tratarea erorii ca nu exista film cu acel cod --> NO_DATA_FOUND
    select nume_film into exista_film
    from film
    where cod_film = id_film
        and rownum = 1;

    -- tratarea erorii ca nu exista cinematograf cu acel cod
    select count(*) into exista_cinema
    from cinematograf
    where cod_cinematograf = id_cinema;

    if exista_cinema = 0 then
        RAISE NU_EXISTA_CINEMA;
    end if;


    -- tratarea erorii ca filmul avand codul id_film nu se difuzeaza intr-o singura zi --> TOO_MANY_ROWS
    select distinct t.data_difuzare into exista_o_zi
    from difuzeaza d, table(d.perioade_difuzare) t
    where d.cod_film = id_film
      and d.cod_cinematograf = id_cinema;


     --tratarea erorii ca filmul se difuzeaza intr-o singura zi, dar nu are rezervari atribuite
    select count(*) into nr_rezervari
        from difuzeaza d
            join film f on d.cod_film = f.cod_film
            join rezervare r on f.cod_film = r.cod_film
        where d.cod_film = id_film and d.cod_cinematograf = id_cinema;
        
        if nr_rezervari = 0 then
            RAISE NU_EXISTA_REZERVARI;
        end if;
    
    dbms_output.put_line('');
    dbms_output.put_line('               - DETALII DESPRE FILM -              ');
    dbms_output.put_line('');
    dbms_output.put_line('Filmul '||exista_film||' se difuzeaza in ziua '||exista_o_zi||' si in intervalul orar: ');
    for i in c_ore loop
        dbms_output.put_line('  - '||to_char(i.inceput, 'HH24:MI')||' - '||to_char(i.FINAL, 'HH24:MI'));
    end loop;
    dbms_output.new_line;
    
    dbms_output.put_line('');
    dbms_output.put_line('              - DETALII REZERVARI -                ');
    dbms_output.put_line('');
    dbms_output.put_line('Pentru acest film s-au facut '||nr_rezervari||' rezervari.');
    
    dbms_output.put_line('  In functie de punctele bonus acumulate, clientii au obtinut urmatoarele reduceri: ');
    dbms_output.new_line;
    for i in c_rezervari loop
        dbms_output.put_line('Numele clientului: '||i.nume||' '||i.prenume);
        dbms_output.put_line('Puncte bonus: '||i.puncte);
        dbms_output.put_line('Reducere: '||i.puncte/10||' lei');
         dbms_output.put_line('Pretul initial al rezervarii: '||i.pret_initial||' lei');
        dbms_output.put_line('Pretul final al rezervarii: '||i.pret_final||' lei');
        
        if
            i.puncte >= 100 and i.puncte < 150 then
                categorie := 'Ocazional'; 
        elsif
            i.puncte >=150 and i.puncte < 190 then
                categorie := 'Activ'; 
        elsif
            i.puncte >= 190 then
                categorie := 'Loial'; 
        else 
            eroare_client := i.nume||' '||i.prenume;
            RAISE FARA_CATEGORIE;
        end if;
        dbms_output.put_line('Categoria clientului: '||categorie);
        dbms_output.put_line('---------------------------------------------');
        dbms_output.new_line;
    end loop;
    
    -- determinarea venitului total atribuit filmului avand codul id_film
    -- UTILIZARE A 5 TABELE INTR-O SINGURA COMANDA SQL
    select
          trunc(sum(r.pret_bilet*r.numar_persoane - cl.puncte_bonus/10)) into venit_total
    from cinematograf c
            join difuzeaza d on c.cod_cinematograf = d.cod_cinematograf
            join film f on d.cod_film = f.cod_film
            join rezervare r on f.cod_film = r.cod_film
            join clienti cl on r.cod_client = cl.cod_client
    where f.cod_film = id_film and c.cod_cinematograf = id_cinema;
    dbms_output.put_line('Filmul '||exista_film||' a adus incasari in valoare de '||venit_total||' lei.');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        mesaj := 'Nu s-a gasit in baza de date un film avand codul ' || id_film;
        inserare_date_tabel('ex9', mesaj);
    WHEN TOO_MANY_ROWS THEN
        mesaj := 'Filmul care are codul ' || id_film || ' se difuzeaza in mai multe zile';
        inserare_date_tabel('ex9', mesaj);
    WHEN NU_EXISTA_CINEMA THEN
        mesaj := 'In baza de date nu exista un cinematograf care sa aiba codul: ' || id_cinema;
        inserare_date_tabel('ex9', mesaj);
    WHEN NU_EXISTA_REZERVARI THEN
        mesaj := 'In baza de date nu exista rezervari care sa includa filmul avand codul: ' || id_film
                 ||' cu toate ca se difuzeaza intr-o singura zi.';
        inserare_date_tabel('ex9', mesaj);
    WHEN FARA_CATEGORIE THEN
        mesaj := 'Clientul '||eroare_client||' nu apartine niciunei categorii.';
        inserare_date_tabel('ex9', mesaj);
    WHEN OTHERS THEN 
            mesaj := 'A aparut alta eroare: ' || SQLERRM;
            inserare_date_tabel('ex9', mesaj);
end ex9;
/


-- FUNCTIONEAZA FARA EXCEPTII
-- varianta 1
declare 
    nr_rezervari number;
    categorie varchar2(20);
begin
    ex9('F9', 'C7', nr_rezervari, categorie);
end;
/

-- varianta 2
variable nr_rezervari number
variable categorie varchar2
execute ex9('F15', 'C3', :nr_rezervari, :categorie)


-- NO_DATA_FOUND
declare 
    nr_rezervari number;
    categorie varchar2(20);
begin
    ex9('F26', 'C7', nr_rezervari, categorie);
end;
/

-- TOO_MANY_ROWS
declare 
    nr_rezervari number;
    categorie varchar2(20);
begin
    ex9('F3', 'C2', nr_rezervari, categorie);
end;
/

-- VALUE_ERROR
begin
    declare 
        nr_rezervari number := ' ';
        categorie varchar2(20);
    begin
        ex9('F3', 'C2', nr_rezervari, categorie);
    end;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            inserare_date_tabel('ex9', 'Al treilea argument al procedurii trebuie sa fie de tip numeric.');
end;
/


-- NU_EXISTA_CINEMA
variable nr_rezervari number
variable categorie varchar2
execute ex9('F6', 'C11', :nr_rezervari, :categorie)


-- NU_EXISTA_REZERVARI
variable nr_rezervari number
variable categorie varchar2
execute ex9('F25', 'C3', :nr_rezervari, :categorie)

-- FARA_CATEGORIE
variable nr_rezervari number
variable categorie varchar2
execute ex9('F23', 'C1', :nr_rezervari, :categorie)


select * from istoric_erori;


