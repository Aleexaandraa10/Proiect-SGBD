-- Ex 12

-- Avand in vedere importanta fiecarui tabel din baza de date a unui cinematograf,  
-- se solicita inregistrarea detaliata a tuturor operatiunilor de creare, modificare  
-- sau stergere a acestora, pentru a asigura integritatea datelor.  


CREATE OR REPLACE TRIGGER trigger_ex12 
  AFTER CREATE OR DROP OR ALTER ON SCHEMA
DECLARE 
BEGIN 
    pachet_ex10.inserare_date_trigger(SYSEVENT, DICTIONARY_OBJ_NAME);
    if SYSEVENT = 'ALTER' then
        dbms_output.put_line('Tabela '||DICTIONARY_OBJ_NAME||' a fost modificata.');
        
    elsif SYSEVENT = 'DROP' then
        dbms_output.put_line('Tabela '||DICTIONARY_OBJ_NAME||' a fost stearsa din baza de 
            date');
    elsif SYSEVENT = 'CREATE' then
        dbms_output.put_line('Tabela '||DICTIONARY_OBJ_NAME||' a fost creata.');
    end if;
END; 
/


select * from trigger_history_angajati;


-- ALTER PE FILM
ALTER TABLE film add coloana_trigger varchar2(30);
desc film;
ALTER TABLE film drop column coloana_trigger ;
INSERT INTO film VALUES('F26', 'Test', 18, 1995, 'Dragoste', 'Nume regizor', 'SUA', 'coloana_trigger');
select * from film;
delete from film where cod_film = 'F26';



-- CREATE, ALTER, DROP PE O TABELA CREATA CA TEST
CREATE TABLE test_trigger(
    coloana1 varchar2(30),
    coloana2 varchar2(30),
    numar number);
ALTER TABLE test_trigger add coloana4 varchar2(30);
desc test_trigger;
INSERT INTO test_trigger VALUES('Test', 'trigger_ex12', 12, 'ultima_coloana');
select * from test_trigger;
DROP TABLE test_trigger;


drop trigger trigger_ex12;
