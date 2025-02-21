-- Ex 7
---------------------------------------------------------------------------------------------------------

-- CERINTA:
-- In baza de date a unui cinematograf, pentru fiecare film este cunoscut genul acestuia 
-- (de exemplu, Science Fiction, Drama, Dragoste etc.). Cerinta presupune sa se primeasca un gen 
-- de film specific, iar pentru toate filmele care apartin acestui gen sa se afiseze urmatoarele informatii:
--  1. Perioada de difuzare a fiecarui film.
--  2. Recenziile asociate fiecarui film, constand in data recenziei si scorul acesteia.
-- Daca un film nu are nicio recenzie, trebuie gestionat explicit acest caz, 
-- iar mesajul corespunzator sa fie afisat, indicand lipsa recenziilor pentru acel film.

-----------------------------------------------------------------------------------------------

-- Tabele utilizate: difuzeaza, film, recenzie


create or replace procedure ex7(gen in film.gen_film%type)
is
    verificare film.cod_film%type; -- variabila pentru a testa existenta genului
    ct_recenzii number; -- variabila pentru a verifica exista recenziilor unui film
    
    -- cursor pentru filme
    cursor c_film is
        select cod_film, nume_film
        from film
        where gen_film = gen;
    
    -- cursor parametrizat, dependent de cursorul c_film
    cursor c_recenzie(cod film.cod_film%type) is
        select  scor, data_recenzie
        from recenzie
        where cod_film = cod 
        order by data_recenzie desc ;
        
    -- cursor dinamic pentru perioadele de difuzare
    type difuzare_tip is ref cursor;
    c_difuzare difuzare_tip;

    interogare_sql varchar2(1000);
    v_data_difuzare date;
    v_ora_inceput date;
    v_ora_final date;

begin
    -- tratarea erorii ca nu exista genul introdus de utilizator
    select cod_film into verificare
    from film
    where gen_film = gen
        and rownum = 1; -- se limiteaza rezultatul cautarii a.i sa returneze doar primul rand, daca exista, care 
                        -- indeplineste conditia gen_film = gen
       
    for i in c_film loop
        ct_recenzii := 0;
        dbms_output.put_line('Numele filmului: ' || i.nume_film || ', iar codul: ' || i.cod_film);
        dbms_output.put_line('  Perioada de difuzare a acestui film este: ');

        interogare_sql := 'select data_difuzare, ora_inceput, ora_final ' ||
                          'from table (select perioade_difuzare ' ||
                                      'from difuzeaza ' ||
                                      'where cod_film = :cod_film_param)';

        -- se deschide cursorul dinamic 
        open c_difuzare for interogare_sql using i.cod_film;
        loop
            fetch c_difuzare into v_data_difuzare, v_ora_inceput, v_ora_final;
            exit when c_difuzare%notfound;

            dbms_output.put_line('      Data: ' || v_data_difuzare || ', intre orele: ' ||
                                 to_char(v_ora_inceput, 'hh24:mi') || '-' || to_char(v_ora_final, 'hh24:mi'));
        end loop;
        close c_difuzare;
        
        for j in c_recenzie(i.cod_film) loop
            dbms_output.put_line('  Recenzia filmului a fost postata la data: '||j.data_recenzie||', iar nota acordata este: '||j.scor);
            ct_recenzii := ct_recenzii + 1;
        end loop;
        
        if ct_recenzii = 0 then
            dbms_output.put_line('  Acest film nu are recenzii.');
        end if;
        
        dbms_output.new_line;
    end loop;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, 'Nu exista filme cu genul specificat in baza de date.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20012,'A aparut o eroare: ' || sqlerrm);
end ex7;
/




begin 
     ex7('Drama');
end;
/

execute ex7('Horror');
execute ex7('Dragoste');
