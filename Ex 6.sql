-- Ex 6 

----------------------------------------------------------------------------------------------------
-- CERINTA:
-- Se doreste realizarea unei analize pentru a identifica, in fiecare cinematograf, 
-- filmele care sunt difuzate in prezent si clientii care au rezervari active pentru aceste filme. 
-- De asemenea, se vor extrage recenziile acordate de clienti pentru filmele respective, 
-- dar doar daca rezervarile lor sunt active. Este important de mentionat ca recenziile oferite 
-- de clienti pentru vizionari anterioare nu sunt relevante in aceasta cerinta, care se concentreaza 
-- exclusiv pe situatia rezervarilor active.

------------------------------------------------------------------------------------------------------

-- Se folosesc tablouri indexate pentru a stoca informatii despre cinematografe si filme.
-- Se folosesc tablouri imbricate pentru a stoca informatiile despre rezervarile si clienti.
-- Se folosesc vectori pentru a gestiona recenziile acordate clientilor.

-- Tabele utilizate: cinematograf, film, clienti, rezervare, difuzeaza, recenzii
-----------------------------------------------------------------------------------------------------


create or replace procedure ex6 
is 
    -- Definire tipuri de date pentru afisarea informatiilor despre filme
    type tablou_indexat_nume is table of film.nume_film%type index by pls_integer;
    type tablou_indexat_cod is table of film.cod_film%type index by pls_integer;
    t_indexat_filme_nume tablou_indexat_nume;
    t_indexat_filme_cod tablou_indexat_cod;
    
    cursor c_cinematograf is
        select cod_cinematograf as cod, nume_cinema as nume
        from cinematograf;
        
    cursor c_film(cod cinematograf.cod_cinematograf%type) is
        select f.nume_film as nume, f.cod_film as cod
        from difuzeaza d
            join film f on d.cod_film = f.cod_film
        where d.cod_cinematograf = cod;
        
    -- Definire tipuri de date pentru afisarea clientilor
    type tablou_imbricat1 is table of clienti.nume_client%type;
    type tablou_imbricat2 is table of clienti.cod_client%type;
    

    cursor c_client(cod film.cod_film%type) is
        select distinct c.nume_client, c.cod_client
        from clienti c
            join rezervare r on c.cod_client = r.cod_client
        where r.cod_film = cod;
    
    -- Definire vector pentru afisarea recenziilor
    type vector is varray(20) of recenzie.scor%type;
    
    cursor c_recenzie(cod film.cod_film%type) is
        select rec.scor, rec.cod_client
        from recenzie rec
            join clienti c on rec.cod_client = c.cod_client
            join film f on rec.cod_film = f.cod_film
        where f.cod_film = cod
            -- blocul EXISTS este folosit pentru a valida ca recenzia selectata apartine unui 
            -- client care a facut o rezervare pentru filmul respectiv
            and exists (
                        select 1
                        from rezervare rez
                        where rez.cod_film = f.cod_film
                                and rez.cod_client = rec.cod_client
                        );
            -- fara existenta blocului EXITS s-ar returna toate recenziile inregistrate vreodata
            -- pentru filmul respectiv
    
begin
    -- Se parcurge fiecare cinematograf
    for i in c_cinematograf loop
        dbms_output.put_line('----------------------------------------------');
        dbms_output.put_line('Cinematograf: ' || i.nume);
        dbms_output.put_line('----------------------------------------------');
    
       open c_film(i.cod);
       fetch c_film bulk collect into t_indexat_filme_nume, t_indexat_filme_cod;
       
        -- Se afiseaza filmele care corespund cinematografului curent
        if t_indexat_filme_nume.count = 0 then
            dbms_output.put_line('Nu exista filme difuzate în acest cinematograf.');
        else
            for j in t_indexat_filme_nume.first..t_indexat_filme_nume.last loop
                dbms_output.put_line('  Film: ' || t_indexat_filme_nume(j));
                
                -- Se afiseaza clientii care au rezervari pentru filmul curent
                open c_client(t_indexat_filme_cod(j));
                declare
                    -- Se va initializa pentru fiecare film un vector cu recenziile lasate de clienti
                    v_recenzii vector := vector(); 
                    t_imbricat1_clienti tablou_imbricat1 := tablou_imbricat1(); -- se retin numele clientilor
                    t_imbricat2_clienti tablou_imbricat2 := tablou_imbricat2(); -- codurile clientilor care au facut rezervari
                    t_imbricat3_clienti tablou_imbricat2 := tablou_imbricat2(); -- codurile clientilor care au lasat recenzie
                begin
                    fetch c_client bulk collect into t_imbricat1_clienti, t_imbricat2_clienti;
                    if t_imbricat1_clienti.count = 0 then
                        dbms_output.put_line('    Nu exista clienti cu rezervari pentru acest film.');
                    else
                        dbms_output.put('    Clienti cu rezervari: ');
                        for k in t_imbricat1_clienti.first..t_imbricat1_clienti.last loop
                            dbms_output.put(t_imbricat1_clienti(k));
                            if k < t_imbricat1_clienti.last then
                                dbms_output.put(', ');
                            end if;
                        end loop;
                        dbms_output.new_line;
                        
                        -- Se afiseaza recenziile pentru filmul curent
                        open c_recenzie(t_indexat_filme_cod(j));
                        fetch c_recenzie bulk collect into v_recenzii, t_imbricat3_clienti;

                        if v_recenzii.count = 0 then
                            dbms_output.put_line('    Nu exista recenzii pentru acest film.');
                        else
                            for k in t_imbricat1_clienti.first..t_imbricat1_clienti.last loop
                                -- bloc necesar pentru a determina daca clientul curent a acordat sau nu recenzie filmului curent
                                declare
                                    -- cu aceasta variabila se verifica existenta unei recenzii date de clientul curent
                                    nota_existenta boolean := false;
                                begin
                                    for idx in 1..v_recenzii.count loop
                                        -- daca clientul care a facut o rezervare la filmul curent
                                        -- a acordat si o recenzie, atunci se va afisa nota lui
                                        if t_imbricat2_clienti(k) = t_imbricat3_clienti(idx) then
                                            dbms_output.put_line('      ' || t_imbricat1_clienti(k) || ' a acordat nota: ' || v_recenzii(idx));
                                            nota_existenta := true;
                                            exit; 
                                        end if;
                                    end loop;
                                    if not nota_existenta then
                                        dbms_output.put_line('      ' || t_imbricat1_clienti(k) || ' nu a acordat nicio nota.');
                                    end if;
                                end;
                            end loop;
                        end if;
                        close c_recenzie;
                    end if;
                end;
                close c_client;
            end loop;
        end if;
        dbms_output.new_line;
        close c_film;
    end loop;
end ex6;
/

EXECUTE EX6;


