
------- !!!!!!!!!!!!!!!! CRAPA PUNCTE BONUS --------------------------------

create or replace package buguri
is
    nr_job number;
    function obtine_job return number;
end;
/

drop package buguri;

create or replace package body buguri is
    function obtine_job return number is
    begin
        return nr_job;
    end;
end;
/

create or replace procedure notif_max_pct_bonus is
        cod number(2);
        nume varchar2(30);
        prenume varchar2(30);
        job_id number;
    begin
        cod := pachet_ex13.client_cu_max_puncte_bonus;
        select nume_client, prenume_client 
        into nume, prenume
        from clienti
        where cod_client = cod;
    
        select JOB into job_id
        from USER_JOBS
        where WHAT = 'notif_max_pct_bonus;';
    
        INSERT INTO job_log (job_id, mesaj)
            VALUES (job_id, 'Notificare pentru clientul cu puncte maxime');
    
        dbms_output.put_line('Notificare trimisa catre: '||nume||' '||prenume);
        dbms_output.put_line('Felicitari, ai castigat o vizionare gratuita din cabina de proiectie a oricarui film ales de tine!');
        dbms_output.put_line('Oferta este valabila pe perioada a doua saptamani incepand cu data la care ai primit mesajul.');
end notif_max_pct_bonus;

begin
    dbms_job.submit(
        job => buguri.nr_job,
        WHAT => 'notif_max_pct_bonus;',
        NEXT_DATE => SYSDATE + 3/86400,
        INTERVAL => 'SYSDATE + 3/86400' );
end;

SELECT JOB, NEXT_DATE, WHAT 
FROM   USER_JOBS 
WHERE  JOB = buguri.obtine_job; 


BEGIN 
   DBMS_JOB.RUN(JOB => buguri.obtine_job); 
END; 
/ 







CREATE OR REPLACE PACKAGE pachet_job 
IS 
nr_job NUMBER; 
FUNCTION obtine_job RETURN NUMBER; 
END; 
/ 

CREATE OR REPLACE PACKAGE body pachet_job 
IS 
FUNCTION obtine_job RETURN NUMBER IS 
BEGIN 
RETURN nr_job; 
END; 
END; 
/ 

BEGIN 
DBMS_JOB.SUBMIT( -- întoarce num?rul jobului,  -- printr-o variabil?  
JOB =>  pachet_job.nr_job,    -- codul PL/SQL care trebuie executat  
WHAT => 'notif_max_pct_bonus;',  -- data de start a execu?iei (dupa 3 secunde) 
NEXT_DATE => SYSDATE+3/86400,   -- intervalul de timp la care se repet?  -- execu?ia = 3secunde 
INTERVAL => 'SYSDATE+3/86400');  
END; 
/ -- informatii despre joburi 
SELECT JOB, NEXT_DATE, WHAT 
FROM   USER_JOBS 
WHERE  JOB = pachet_job.obtine_job; 

SELECT JOB, BROKEN
FROM USER_JOBS
WHERE JOB = pachet_job.obtine_job;

GRANT CREATE JOB TO SYSTEM;
GRANT EXECUTE ON DBMS_JOB TO SYSTEM;
-- lansarea jobului la momentul dorit 
BEGIN 
   DBMS_JOB.RUN(JOB => pachet_job.obtine_job); 
END; 

BEGIN
    DBMS_JOB.BROKEN(pachet_job.obtine_job, FALSE);
END;

/ -- stergerea unui job 
BEGIN 
   DBMS_JOB.REMOVE(JOB=>pachet_job.obtine_job); 
END; 
/ 
SELECT JOB, NEXT_DATE, WHAT 
FROM   USER_JOBS 
WHERE  JOB = pachet_job.obtine_job; 
















create or replace procedure submit_notif_max_pct_bonus_job is
        v_job_id number; 
    begin
        DBMS_JOB.SUBMIT(
            JOB        => v_job_id,
            WHAT       => 'begin notif_max_pct_bonus; end;',
            NEXT_DATE  => TRUNC(SYSDATE) + 22/24, 
            INTERVAL   => 'TRUNC(SYSDATE + 1) + 22/24' );

        dbms_output.put_line('Job-ul a fost inregistrat cu succes. ID-ul job-ului: ' || v_job_id);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20050,'Eroare la înregistrarea job-ului: ' || SQLERRM);
end submit_notif_max_pct_bonus_job;

SELECT * FROM USER_JOBS WHERE JOB = 48;

GRANT CREATE JOB TO SYSTEM;
GRANT EXECUTE ON DBMS_JOB TO SYSTEM;

BEGIN
    submit_notif_max_pct_bonus_job;
END;
/

begin
    dbms_job.run(job => 48);
end;


select job, what
from user_jobs;

------------------------------------------------------------------------------------------------------------
create or replace procedure notif_recenzii
    is
        v_clienti pachet_ex13.vector_clienti := pachet_ex13.clienti_care_dau_recenzii;
        v_nume_filme pachet_ex13.vector_nume_filme;
        nume clienti.nume_client%type;
        prenume clienti.prenume_client%type;
        job_id number;
        
        cursor c_nume_filme(cod clienti.cod_client%type) is
            select f.nume_film nume
            from rezervare r 
                join film f on r.cod_film = f.cod_film
                join difuzeaza d on f.cod_film = d.cod_film, table(d.perioade_difuzare) t
            where t.data_difuzare = TO_DATE('01-12-2024', 'DD-MM-YYYY') 
                 and r.cod_client = cod;
            
    begin
        select JOB into job_id
        from USER_JOBS
        where WHAT = 'notif_recenzii;';
        
        INSERT INTO job_log (job_id, mesaj)
        VALUES (job_id, 'Notificare pentru clienti ca sa acorde recenzii');
        
        for i in v_clienti.first..v_clienti.last loop
            v_nume_filme := pachet_ex13.vector_nume_filme();
            
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
    

create or replace procedure submit_notif_recenzii is
        v_job_id number; 
    begin
        DBMS_JOB.SUBMIT(
        JOB        => :v_job_id,
        WHAT       => 'BEGIN notif_recenzii; END;',
        NEXT_DATE  => SYSDATE + 1/24,
        INTERVAL   => 'SYSDATE + 1'
    );

        dbms_output.put_line('Job-ul a fost inregistrat cu succes. ID-ul job-ului: ' || v_job_id);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20051,'Eroare la înregistrarea job-ului: ' || SQLERRM);
end submit_notif_recenzii;



SELECT * FROM USER_JOBS WHERE JOB = 49 AND BROKEN = 'N';

begin
    submit_notif_recenzii;
end;

begin
    dbms_job.run(49);
end;
