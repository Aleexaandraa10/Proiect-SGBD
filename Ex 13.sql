-- Ex 13

-- CERINTA: 
-- Cu prilejul Zilei Nationale a Romaniei, cinematografele din intreaga tara au organizat o serie 
-- de evenimente speciale pentru a celebra aceasta zi. Evenimentele includ:

-- 1. Tarife unice pentru bilete, indiferent de categoria de varsta:
--    - Film 2D: 10 lei
--    - Film 3D: 15 lei
--    - Film IMAX: 20 lei

-- 2. Surprize cinematografice speciale:
--    a. Clasament pe baza recenziilor: S-a realizat un clasament general al filmelor, indiferent de compania
-- de cinematografe. Filmul cel mai apreciat a fost adaugat in programul zilei de 1 decembrie 2024.
--    b. Filme speciale:
--      - Lansare in avanpremiera: Red One (aventura de Craciun).
--      - BeetleJuice (film clasic de Halloween) ramane in program inclusiv pe 1 decembrie.
--      - Anul Nou care n-a fost (regizat de Bogdan Muresanu) pentru celebrarea Zilei Nationale.

-- 3. Surprize pentru clienti:
-- La finalul fiecarei zile, clientul cu cele mai multe puncte bonus va primi un bilet gratuit 
-- pentru  un film la alegere. Notificarea va fi trimisa clientului la ora 22:00.


-- Fiecare client care a facut rezervare a fost notificat sa acorde o recenzie pentru filmul vizionat.
-- S-a realizat un clasament al filmelor, care include:
--    - Numarul de rezervari atribuite fiecarui film.
--    - Recenziile lasate de clienti.
-- Clasamentul astfel realizat va fi folosit pentru a tine cont de preferintele clientilor 
-- in planificarea ofertelor pentru anul urmator.

----------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- secventa necesara in momentul adaugarii recenziilor noi in baza de date
CREATE SEQUENCE recenzii_seq
START WITH 32
INCREMENT BY 1;



-- In momentul in care un client face o rezervare, acest trigger actualizeaza tabela
-- CLIENTI cu punctele bonus obtinute.
-- Se va afisa de asemenea un mesaj de atentionare legat de restrictia de varsta a filmului.
CREATE OR REPLACE TRIGGER actualizare_puncte_bonus 
    FOR INSERT ON rezervare
    COMPOUND TRIGGER
        puncte_1_decembrie number := 0;
        data_1_decembrie date := TO_DATE('01-12-2024', 'DD-MM-YYYY');
        data_gasita boolean := false;
        type vector is varray(10) of date;
        date_difuzare vector := vector();
        varsta film.varsta_recomandata%type;
        
        cursor c_date is
            select t.data_difuzare 
            from difuzeaza d, table(d.perioade_difuzare) t
                where d.cod_film = :NEW.cod_film;
    BEFORE EACH ROW IS
        BEGIN
            open c_date;
            fetch c_date bulk collect into date_difuzare;
            close c_date;
            
            for i in date_difuzare.first..date_difuzare.last loop
                if date_difuzare(i) = data_1_decembrie then
                    data_gasita := true;
                    exit;
                end if;
            end loop;
            
            if data_gasita = true then
                if :NEW.format_proiectie = '2D' then
                    puncte_1_decembrie := 10;
                elsif :NEW.format_proiectie = '3D' then
                    puncte_1_decembrie := 15;
                elsif :NEW.format_proiectie = 'IMAX' then
                    puncte_1_decembrie := 20;
                end if;
            else
                dbms_output.put_line('Rezervarea nu este facuta pentru un film din date de 1 decembrie, punctele bonus vor fi adaugate fara adaosul special');
            end if;
    END BEFORE EACH ROW;
    
    AFTER EACH ROW IS
    BEGIN
        update clienti 
        set puncte_bonus = puncte_bonus+ puncte_1_decembrie+:NEW.pret_bilet*:NEW.numar_persoane
        where cod_client = :NEW.cod_client;
        
        select varsta_recomandata into varsta
        from film
        where cod_film = :NEW.cod_film;
        
        dbms_output.put_line('Rezervarea a fost facuta cu succes!');
        dbms_output.put_line('Aveti in vedere ca varsta minima la acest film este: '||varsta||' ani.');
    END AFTER EACH ROW;
END actualizare_puncte_bonus;
/


CREATE OR REPLACE PACKAGE pachet_ex13 AS
    type record_top is record(
    cod film.cod_film%type,
    nume film.nume_film%type,
    regizor film.nume_regizor%type,
    numar_rez number,
    nota_medie number
    );
    type tablou_imbricat is table of record_top;
    type vector_clienti is varray(20) of clienti.cod_client%type;
    type vector_cod_filme is varray(20) of film.cod_film%type;
    type vector_nume_filme is table of film.nume_film%type index by pls_integer;
    
    function client_cu_max_puncte_bonus return number;
    function clienti_care_dau_recenzii return vector_clienti;
    function topul_filmelor_coduri return tablou_imbricat;
    
    procedure adauga_film_rezervare;
    procedure notif_max_pct_bonus;
    procedure submit_notif_max_pct_bonus_job;
    procedure notif_recenzii;
    procedure submit_notif_recenzii;
    procedure adauga_recenzii(v_clienti in vector_clienti);
    procedure afisare_top_filme(v_recorduri in tablou_imbricat);
END pachet_ex13;
/

-- drop package pachet_ex13;


CREATE OR REPLACE PACKAGE BODY pachet_ex13 AS
    
    -------------------------------------  TOPUL FILMELOR - functie ---------------------------------------------
    function topul_filmelor_coduri return tablou_imbricat
    is
        v_recorduri tablou_imbricat := tablou_imbricat();
        cursor c_top_filme is
            select f.cod_film, f.nume_film, f.nume_regizor,
                  nvl(count(rez.cod_film), 0) nr_rezervari,
                  nvl(round(avg(rec.scor),2), 0) nota_medie
            from film f
                join rezervare rez on f.cod_film = rez.cod_film
                join clienti c on rez.cod_client = c.cod_client
                join recenzie rec on c.cod_client = rec.cod_client
            group by f.cod_film, f.nume_film, f.nume_regizor
            order by nr_rezervari desc, nota_medie desc;
    begin
        open c_top_filme;
        fetch c_top_filme bulk collect into v_recorduri;
        close c_top_filme;
        
        return v_recorduri;
    end topul_filmelor_coduri;

     ----------------------------- ADAUGA FILME, REZERVARI, DIFUZARI- procedura ---------------------------
    procedure adauga_film_rezervare
    is
        v_top tablou_imbricat := topul_filmelor_coduri;
        primul_din_top record_top := v_top(v_top.first);
        id_cinema varchar2(3);
        durata varchar2(3);
    begin
        select cod_cinematograf, durata_film
        into id_cinema, durata
        from difuzeaza
        where cod_film = primul_din_top.cod;
        
        INSERT INTO TABLE (
        select d.perioade_difuzare
        from difuzeaza d
        where d.cod_cinematograf = id_cinema
                and  d.cod_film = primul_din_top.cod)      
        select per_dif(
            TO_DATE('01-12-2024', 'DD-MM-YYYY'),
            TO_DATE('18:00', 'HH24:MI'),
            TO_DATE('18:00', 'HH24:MI') + durata / 1440)
        FROM dual;
        INSERT INTO rezervare VALUES (primul_din_top.cod, 8, 10, 3, '2D', 4, 'Card');
        
        
        INSERT INTO film VALUES('F26', 'Red one', 8, 2024, 'Actiune', 'Jake Kasdan', 'SUA');
        INSERT INTO difuzeaza VALUES (
            'C4', 'F26', 
        lista_perioade(
            per_dif(TO_DATE('01-12-2024', 'DD-MM-YYYY'), TO_DATE('16:30', 'HH24:MI'), TO_DATE('19:00', 'HH24:MI'))),
        'Engleza', 120);
        INSERT INTO rezervare VALUES ('F26', 10, 10, 2, '2D', 1, 'Card');
        INSERT INTO rezervare VALUES ('F26', 11, 10, 4, '2D', 1, 'Cash');
        INSERT INTO rezervare VALUES ('F26', 12, 10, 3, '2D', 1, 'Cash');
        
        
        INSERT INTO film VALUES('F27', 'BeetleJuice', 12, 2024, 'Comedie', 'Tim Burton', 'SUA');
        INSERT INTO difuzeaza VALUES (
            'C4', 'F27', 
        lista_perioade(
            per_dif(TO_DATE('01-12-2024', 'DD-MM-YYYY'), TO_DATE('14:30', 'HH24:MI'), TO_DATE('16:00', 'HH24:MI'))),
        'Romana', 90);
        INSERT INTO rezervare VALUES ('F27', 22, 20, 2, 'IMAX', 2, 'Card');
        INSERT INTO rezervare VALUES ('F27', 7, 20, 2, 'IMAX', 2, 'Cash');
    
        
        INSERT INTO film VALUES('F28', 'Anul Nou Care N-a Fost', 15, 2024, 'Drama', 'Bogdan Muresanu', 'Romania');
        INSERT INTO difuzeaza VALUES (
            'C4', 'F28', 
        lista_perioade(
            per_dif(TO_DATE('01-12-2024', 'DD-MM-YYYY'), TO_DATE('20:00', 'HH24:MI'), TO_DATE('22:00', 'HH24:MI'))),
        'Romana', 120);
        INSERT INTO rezervare VALUES ('F28', 21, 15, 1, '3D', 3, 'Card');
        INSERT INTO rezervare VALUES ('F28', 4, 15, 4, '3D', 3, 'Cash');
        INSERT INTO rezervare VALUES ('F28', 5, 15, 3, '3D', 3, 'Card');
        INSERT INTO rezervare VALUES ('F28', 17, 15, 3, '3D', 3, 'Cash');
    end adauga_film_rezervare;
    
     --------------------------------------  CLIENT MAX PCT BONUS - functie ---------------------------------------
    function client_cu_max_puncte_bonus return number 
    is
        cod_client_cu_max_pct number;
        max_puncte number := 0;
        max_rezervari number := 0;
        nr_rezervari_client number;
    begin
        for i in (select puncte_bonus, cod_client
                  from clienti ) loop
            if i.puncte_bonus > max_puncte then
                cod_client_cu_max_pct := i.cod_client;
                max_puncte := i.puncte_bonus;
            
                select count(*) into max_rezervari
                from rezervare
                where cod_client = i.cod_client;
            
            -- daca exista mai multi clienti cu acelasi nr de puncte bonus se va determina clientul
            -- care a facut mai multe rezervari
            elsif i.puncte_bonus = max_puncte then
                select count(*) into nr_rezervari_client
                from rezervare
                where cod_client = i.cod_client;
            
                if nr_rezervari_client > max_rezervari then
                    max_rezervari := nr_rezervari_client;
                    cod_client_cu_max_pct := i.cod_client;
                end if;
            end if;
        end loop;
        return cod_client_cu_max_pct;
    end client_cu_max_puncte_bonus;
    
    ---------------------------------------- NOTIF PCT BONUS-procedura  -------------------------------------------
    procedure notif_max_pct_bonus is
        nume varchar2(30);
        prenume varchar2(30);
    begin
        select nume_client, prenume_client 
        into nume, prenume
        from clienti
        where cod_client = client_cu_max_puncte_bonus;
    
        dbms_output.put_line('Notificare trimisa catre: '||nume||' '||prenume);
        dbms_output.put_line('Felicitari, ai castigat o vizionare gratuita din cabina de proiectie a oricarui film ales de tine!');
        dbms_output.put_line('Oferta este valabila pe perioada a doua saptamani incepand cu data la care ai primit mesajul.');
    end notif_max_pct_bonus;
    
    ---------------------------------- DBMS_JOB PENTRU PCT BONUS - procedura ----------------------------
    procedure submit_notif_max_pct_bonus_job is
        nr_job_id number;
    begin
        DBMS_JOB.SUBMIT(
            JOB        => nr_job_id,
            WHAT       => 'pachet_ex13.notif_max_pct_bonus;',
            NEXT_DATE  => TRUNC(SYSDATE) + 22/24, 
            INTERVAL   => 'TRUNC(SYSDATE + 1) + 22/24' );
        dbms_output.put_line('Job-ul cu ID-ul '||nr_job_id||' a fost inregistrat cu succes.');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20050,'Eroare la înregistrarea job-ului: ' || SQLERRM);
    end submit_notif_max_pct_bonus_job;
    
    
    ---------------------- DETERMINARE CLIENTI CARE TREBUIE SA DEA RECENZII - functie ---------------
    function clienti_care_dau_recenzii return vector_clienti
    is
        v_clienti vector_clienti := vector_clienti();
        cursor c_clienti is
            select c.cod_client
            from clienti c
                join rezervare r on c.cod_client = r.cod_client
                join film f on r.cod_film = f.cod_film
                join difuzeaza d on f.cod_film = d.cod_film, table(d.perioade_difuzare) t
            where t.data_difuzare = TO_DATE('01-12-2024', 'DD-MM-YYYY')
            group by c.cod_client
            order by c.cod_client;
    begin
        open c_clienti;
        fetch c_clienti bulk collect into v_clienti;
        close c_clienti;
        
        return v_clienti;
    end clienti_care_dau_recenzii;
    
    ----------------------------------------- NOTIFICARE RECENZII - procedura -------------------------------------
    procedure notif_recenzii
    is
        v_clienti vector_clienti := clienti_care_dau_recenzii;
        v_nume_filme vector_nume_filme;
        nume clienti.nume_client%type;
        prenume clienti.prenume_client%type;
        
        -- se selecteaza cele 4 filme care s-au difuzat pe 1 decembrie
        cursor c_nume_filme(cod clienti.cod_client%type) is
            select f.nume_film nume
            from rezervare r 
                join film f on r.cod_film = f.cod_film
                join difuzeaza d on f.cod_film = d.cod_film, table(d.perioade_difuzare) t
            where t.data_difuzare = TO_DATE('01-12-2024', 'DD-MM-YYYY') 
                 and r.cod_client = cod;
            
    begin
        for i in v_clienti.first..v_clienti.last loop
            v_nume_filme := vector_nume_filme();
            
            for j in c_nume_filme(v_clienti(i)) loop
                v_nume_filme(v_nume_filme.count + 1) := j.nume;
            end loop;
            
            select nume_client, prenume_client
            into nume, prenume
            from clienti 
            where cod_client = v_clienti(i);
            
            dbms_output.put_line('Notificare trimisa catre '||nume||' '||prenume||' pentru urmatoarele filme vizionate: ');
            for k in v_nume_filme.first..v_nume_filme.last loop
                dbms_output.put_line('  '||v_nume_filme(k));
            end loop;
            dbms_output.put_line('Ne bucuram ca ati ales sa va petreceti ziua de 1 decembrie la cinematograf!');
            dbms_output.put_line('Va rugam lasati o recenzie filmelor pe care ati ales sa le vizionati.');
            dbms_output.new_line;
        end loop;
    end notif_recenzii;
    
    -------------------------------------- DBMS_JOB PENTRU RECENZII - procedura ------------------------------
    procedure submit_notif_recenzii is
        v_job_id number;
    begin
        DBMS_JOB.SUBMIT(
        JOB => v_job_id,
        WHAT => 'pachet_ex13.notif_recenzii;',
        NEXT_DATE => SYSDATE+3/86400,
        INTERVAL  => 'SYSDATE+1'
        );

        dbms_output.put_line('Job-ul cu ID-ul '||v_job_id||' a fost inregistrat cu succes.');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20051,'Eroare la înregistrarea job-ului: ' || SQLERRM);
    end submit_notif_recenzii;
    

     -------------------------------------- INSERARE RECENZII - procedura ------------------------------------------
    procedure adauga_recenzii(v_clienti in vector_clienti)
    is
        v_cod_filme vector_cod_filme;
        v_nota number;
        v_id_recenzie varchar2(3);
         
        cursor c_cod_filme(cod clienti.cod_client%type) is
            select f.cod_film cod
            from rezervare r 
                join film f on r.cod_film = f.cod_film
                join difuzeaza d on f.cod_film = d.cod_film, table(d.perioade_difuzare) t
            where t.data_difuzare = TO_DATE('01-12-2024', 'DD-MM-YYYY') 
                and r.cod_client = cod;       
    begin
        for i in v_clienti.first..v_clienti.last loop
            v_cod_filme := vector_cod_filme();
            
            for j in c_cod_filme(v_clienti(i)) loop
                v_cod_filme.extend;
                v_cod_filme(v_cod_filme.count) := j.cod;
            end loop;
            
            -- recenziile vor avea o nota random
            -- codul recenziei se construieste utilizand recenzii_seq definita anterior
            for k in v_cod_filme.first..v_cod_filme.last loop
                v_nota := ROUND(DBMS_RANDOM.VALUE(1,10));
                v_id_recenzie := 'R' || TO_CHAR(recenzii_seq.NEXTVAL);
                INSERT INTO recenzie VALUES (v_id_recenzie, v_cod_filme(k), v_clienti(i), v_nota, TO_DATE('2024-12-02', 'YYYY-MM-DD'));
            end loop;
        end loop;
        dbms_output.put_line('Recenziile au fost adaugate cu succes');
    end adauga_recenzii;
    
    --------------------------------------------  TOPUL FILMELOR - procedura ---------------------------------------
    procedure afisare_top_filme(v_recorduri in tablou_imbricat) is 
    -- in v_recorduri se retineau informatiile filmelor ordonate descrescator dupa popularitate
    begin
        dbms_output.put_line('Topul filmelor din anul 2024 difuzate in cinematografe: ');
        for i in v_recorduri.first..v_recorduri.last loop
            dbms_output.put_line('Cod: '||v_recorduri(i).cod);
            dbms_output.put_line('Nume film: '||v_recorduri(i).nume);
            dbms_output.put_line('Regizor: '||v_recorduri(i).regizor);
            dbms_output.put_line('Acest film a avut '||v_recorduri(i).numar_rez||' de rezervari');
            dbms_output.put_line('Scorul mediu in urma recenziilor a fost '||v_recorduri(i).nota_medie);
            dbms_output.new_line;
        end loop;
        
    end afisare_top_filme;
    
END pachet_ex13;    
/

--drop package pachet_job;


declare
    cod_client_max_pct_bonus number;
    v_clienti pachet_ex13.vector_clienti;
    v_coduri_filme pachet_ex13.tablou_imbricat;
begin
    -- PASUL 1: se adauga date in tabelele FILM, DIFUZEAZA, REZERVARI 
    -- + se activeaza triggerul pt rezervari (se modif implicit si pct bonus din tabela CLIENTI)
    --pachet_ex13.adauga_film_rezervare; 
    
    --PASUL 2: determinarea clientului cu max pct bonus
    --cod_client_max_pct_bonus := pachet_ex13.client_cu_max_puncte_bonus;
    --dbms_output.put_line('Clientul avand codul '||cod_client_max_pct_bonus||
        --' a obtinut numar maxim de puncte.');
        
    --PASUL 3: notificarea pentru clientul cu max pct bonus
    --pachet_ex13.submit_notif_max_pct_bonus_job;
    
    -- PASUL 4: notificare pentru acordarea de recenzii
    --pachet_ex13.submit_notif_recenzii;
    
    -- PASUL 5: adaugarea recenziilor
    --v_clienti := pachet_ex13.clienti_care_dau_recenzii;
    --pachet_ex13.adauga_recenzii(v_clienti);
    
    -- PASUL 6: afisarea clasamentului final al filmelor
    v_coduri_filme := pachet_ex13.topul_filmelor_coduri;
    pachet_ex13.afisare_top_filme(v_coduri_filme);
end;
/

SELECT * FROM USER_SYS_PRIVS;
GRANT CREATE JOB TO SYSTEM;
GRANT EXECUTE ON DBMS_JOB TO SYSTEM;


-- verificare PASUL 1
select * from film;
select * from rezervare;
select * from clienti; -- pentru verificarea triggerului
SELECT d.cod_cinematograf, 
       d.cod_film, 
       TO_CHAR(p.data_difuzare, 'DD-MM-YYYY') AS data_difuzare,
       TO_CHAR(p.ora_inceput, 'HH24:MI') AS ora_inceput,
       TO_CHAR(p.ora_final, 'HH24:MI') AS ora_final
FROM difuzeaza d,
     TABLE(d.perioade_difuzare) p;



-- verificare PASUL 3
select job, next_date, what
from user_jobs;


begin
    dbms_job.run(job => 21);
end;
/


SELECT JOB, WHAT
FROM USER_JOBS
WHERE WHAT = 'notif_max_pct_bonus;';


-- verificare PASUL 4
select job, next_date, what
from user_jobs;


begin
    dbms_job.run(job => 22);
end;
/


-- verificare PASUL 5
select * from recenzie;


---------------------------------   RESETEAZA VALORILE PT TESTAREA PACHETULUI ----------------------
drop sequence recenzii_seq;
drop trigger actualizare_puncte_bonus;
drop package pachet_ex13;

drop table recenzie;
CREATE TABLE recenzie(
cod_recenzie varchar(3) constraint pk_recenzie primary key,
cod_film varchar2(3),
cod_client number(2),
scor number(2),
data_recenzie date,
constraint fk_film_recenzie foreign key(cod_film) references FILM(cod_film),
constraint fk_client foreign key(cod_client) references CLIENTI(cod_client));


drop table difuzeaza;
CREATE TABLE difuzeaza(
cod_cinematograf varchar2(3) references CINEMATOGRAF(cod_cinematograf),
cod_film varchar2(3) references FILM(cod_film),
perioade_difuzare lista_perioade,
subtitrari varchar2(30),
durata_film number(3),
constraint pk_difuzare primary key (cod_cinematograf, cod_film)
) NESTED TABLE perioade_difuzare STORE AS perioade_difuzare_tab;


drop table rezervare;
CREATE TABLE rezervare(
cod_film varchar2(3) references FILM(cod_film),
cod_client number(2) references CLIENTI(cod_client),
pret_bilet number(3) not null,
numar_persoane number(2),
format_proiectie varchar2(5),
numar_sala number(3),
metoda_plata varchar2(30),
constraint pk_rezervare primary key (cod_film, cod_client));

drop table clienti;
CREATE TABLE clienti(
cod_client number(2) constraint pk_client primary key,
nume_client varchar2(30),
prenume_client varchar2(30),
puncte_bonus number(5));


delete from film
where cod_film= 'F26';

delete from film
where cod_film= 'F27';

delete from film
where cod_film= 'F28';



BEGIN
    DBMS_JOB.BROKEN(job => 25, broken => TRUE, next_date => NULL);
END;
/

BEGIN
    DBMS_JOB.BROKEN(job => 25, broken => FALSE, next_date => SYSDATE);
    COMMIT;
END;
/

-- privilegii pt a putea folosi dbms_job
GRANT CREATE JOB TO SYSTEM;
GRANT EXECUTE ON DBMS_JOB TO SYSTEM;
