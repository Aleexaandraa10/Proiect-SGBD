CREATE TABLE oras(
cod_oras number(3) constraint pk_oras primary key,
prefix_judet varchar2(3) not null,
nume_oras varchar2(30)   not null);


CREATE TABLE adresa (
cod_adresa number(3) constraint pk_adresa primary key,
cod_oras number(3),
nume_strada varchar2(30) not null,
constraint fk_oras foreign key(cod_oras) references ORAS(cod_oras));



CREATE TABLE cinematograf(
cod_cinematograf varchar2(3) constraint pk_cinema primary key,
cod_adresa number(3),
nume_cinema varchar2(30) not null,
nume_companie varchar2(30) not null,
numar_sali number(3) not null,
constraint fk_adresa foreign key(cod_adresa) references ADRESA(cod_adresa));


CREATE TABLE departamente(
cod_departament varchar2(3) constraint pk_dep primary key,
nume_departament varchar2(30) not null);


CREATE TABLE joburi(
cod_job  varchar2(3) constraint pk_job primary key,
nume_job varchar2(30) not null,
salariu_minim number(6) not null,
salariu_maxim number(6) not null,
nivel_exp_necesar varchar2(30));



CREATE TABLE angajati(
cod_angajat varchar2(3) constraint pk_angajat primary key,
cod_job varchar2(3),
cod_departament varchar2(3),
cod_cinematograf varchar2(3),
nume_angajat varchar2(30) not null,
prenume_angajat varchar2(30) not null,
salariu_angajat number(6) not null,
data_angajare date,
status_angajat varchar2(30),
constraint fk_job foreign key(cod_job) references JOBURI(cod_job),
constraint fk_dep foreign key(cod_departament) references DEPARTAMENTE(cod_departament),
constraint fk_cinema foreign key (cod_cinematograf) references CINEMATOGRAF(cod_cinematograf)
);


CREATE TABLE film(
cod_film varchar2(3) constraint pk_film primary key,
nume_film varchar2(30) not null,
varsta_recomandata number(2) not null,
an_aparitie number(4),
gen_film varchar2(30) not null,
nume_regizor varchar2(30),
tara_productie varchar2(30));



CREATE TYPE per_dif AS OBJECT (
    data_difuzare date,
    ora_inceput date, 
    ora_final date
);
/

CREATE TYPE lista_perioade AS TABLE OF per_dif;
/

select t.data_difuzare, to_char(t.ora_inceput, 'hh24:mi'), to_char(t.ora_final, 'hh24:mi')
--select t.*
from difuzeaza d, table(d.perioade_difuzare) t;

CREATE TABLE difuzeaza(
cod_cinematograf varchar2(3) references CINEMATOGRAF(cod_cinematograf),
cod_film varchar2(3) references FILM(cod_film),
perioade_difuzare lista_perioade,
subtitrari varchar2(30),
durata_film number(3),
constraint pk_difuzare primary key (cod_cinematograf, cod_film)
) NESTED TABLE perioade_difuzare STORE AS perioade_difuzare_tab;

-- da eroare pt ca este un tabel de stocare intern si nu poate fi interogat direct
-- acest tabel este gestionat automat de oracle si nu este destinat accesului direct de catre utilizatori
SELECT * 
FROM perioade_difuzare_tab;


CREATE TABLE clienti(
cod_client number(2) constraint pk_client primary key,
nume_client varchar2(30) not null,
prenume_client varchar2(30) not null,
puncte_bonus number(5) );


CREATE TABLE recenzie(
cod_recenzie varchar(3) constraint pk_recenzie primary key,
cod_film varchar2(3),
cod_client number(2),
scor number(2),
data_recenzie date,
constraint fk_film_recenzie foreign key(cod_film) references FILM(cod_film),
constraint fk_client foreign key(cod_client) references CLIENTI(cod_client));


CREATE TABLE rezervare(
cod_film varchar2(3) references FILM(cod_film),
cod_client number(2) references CLIENTI(cod_client),
pret_bilet number(3) not null,
numar_persoane number(2) not null,
format_proiectie varchar2(5) not null,
numar_sala number(3) not null,
metoda_plata varchar2(30) not null,
constraint pk_rezervare primary key (cod_film, cod_client));



-------------------------------------------------------------


INSERT INTO oras VALUES (50, 'BV', 'Predeal');
INSERT INTO oras VALUES (51, 'CJ', 'Cluj-Napoca');
INSERT INTO oras VALUES (52, 'GJ', 'Targu Jiu');
INSERT INTO oras VALUES (53, 'IS', 'Pascani');
INSERT INTO oras VALUES (54, 'IS', 'Targu Frumos');
INSERT INTO oras VALUES (55, 'IF', 'Buftea');
INSERT INTO oras VALUES (56, 'IF', 'Chitila');
INSERT INTO oras VALUES (57, 'MS', 'Sighisoara');
INSERT INTO oras VALUES (58, 'TM', 'Timisoara');
INSERT INTO oras VALUES (59, 'VS', 'Vaslui');

select * from oras;


INSERT INTO adresa VALUES (10, 50, 'Strada Predeal');
INSERT INTO adresa VALUES (11, 51, 'Strada Unirii');
INSERT INTO adresa VALUES (12, 52, 'Strada Victoriei');
INSERT INTO adresa VALUES (13, 53, 'Strada Garii');
INSERT INTO adresa VALUES (14, 54, 'Strada Horea');
INSERT INTO adresa VALUES (15, 55, 'Strada 1 Decembrie');
INSERT INTO adresa VALUES (16, 56, 'Strada Principala');
INSERT INTO adresa VALUES (17, 57, 'Strada Cetatii');
INSERT INTO adresa VALUES (18, 58, 'Strada Banatului');
INSERT INTO adresa VALUES (19, 59, 'Strada Marasesti');

select * from adresa;


INSERT INTO cinematograf VALUES ('C1', 10, 'Cinema Park', 'BV Cinemas', 6);
INSERT INTO cinematograf VALUES ('C2', 11, 'Cinema Cotroceni', 'CJ Cinemas', 5);
INSERT INTO cinematograf VALUES ('C3', 12, 'Cinema Victoriei', 'GJ Cinemas', 8);
INSERT INTO cinematograf VALUES ('C4', 13, 'Cinema Garii', 'IS Cinemas', 4);
INSERT INTO cinematograf VALUES ('C5', 14, 'Cinema Luceafarul', 'IS Cinemas', 7);
INSERT INTO cinematograf VALUES ('C6', 15, 'Cinema Grand', 'IF Cinemas', 5);
INSERT INTO cinematograf VALUES ('C7', 16, 'Cinema Aurora', 'IF Cinemas', 6);
INSERT INTO cinematograf VALUES ('C8', 17, 'Cinema Gloria', 'MS Cinemas', 5);
INSERT INTO cinematograf VALUES ('C9', 18, 'Cinema Star', 'TM Cinemas', 5);
INSERT INTO cinematograf VALUES ('C10', 19, 'Cinema Tomis', 'VS Cinemas', 6);

select * from cinematograf;

INSERT INTO departamente VALUES ('D1', 'IT Support');
INSERT INTO departamente VALUES ('D2', 'Marketing');
INSERT INTO departamente VALUES ('D3', 'Resurse Umane');
INSERT INTO departamente VALUES ('D4', 'Logistica');
INSERT INTO departamente VALUES ('D5', 'Supraveghere');
INSERT INTO departamente VALUES ('D6', 'Tehnic');
INSERT INTO departamente VALUES ('D7', 'Vanzari');
INSERT INTO departamente VALUES ('D8', 'Curatenie');
INSERT INTO departamente VALUES ('D9', 'Siguranta si Protectie');

select * from departamente;


INSERT INTO joburi VALUES ('J1', 'Administrator IT', 4000, 7000, 'Mediu');
INSERT INTO joburi VALUES ('J2', 'Specialist Marketing', 3500, 6000, 'Mediu');
INSERT INTO joburi VALUES ('J3', 'Manager Resurse Umane', 5000, 9000, 'Avansat');
INSERT INTO joburi VALUES ('J4', 'Coordonator Logistica', 4000, 7500, 'Mediu');
INSERT INTO joburi VALUES ('J5', 'Supraveghetor Sali', 2500, 4000, 'Incepator');
INSERT INTO joburi VALUES ('J6', 'Tehnician Echipamente', 3000, 5500, 'Avansat');
INSERT INTO joburi VALUES ('J7', 'Casier', 2000, 3500, 'Incepator');
INSERT INTO joburi VALUES ('J8', 'Personal Curatenie', 1800, 3000, 'Incepator');
INSERT INTO joburi VALUES ('J9', 'Agent de Securitate', 2500, 4500, 'Mediu');
INSERT INTO joburi VALUES ('J10', 'Proiectionist', 3000, 5000, 'Mediu');
INSERT INTO joburi VALUES ('J11', 'Coordonator Evenimente', 4000, 6500, 'Mediu');
INSERT INTO joburi VALUES ('J12', 'Consultant Vanzari', 2200, 4000, 'Incepator');
-- J10 --> D6
-- J11 --> D3
-- J12 --> D7
select *
from joburi;

update angajati
set salariu_angajat = 4050
where cod_angajat = 'A4';


INSERT INTO angajati VALUES ('A1', 'J1', 'D1', 'C1','Alexandrescu', 'Andra', 4500, TO_DATE('16-JAN-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A2', 'J2', 'D2', 'C1','Roman', 'Cristina', 4500, TO_DATE('20-FEB-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A3', 'J3', 'D3', 'C3','Pop', 'Ioana', 5500, TO_DATE('25-MAR-23', 'DD-MON-YY'),'In concediu');
INSERT INTO angajati VALUES ('A4', 'J4', 'D4', 'C4','Georgiu', 'Ana', 4050, TO_DATE('30-APR-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A5', 'J5', 'D5', 'C1','Moldovan', 'Roxana', 3200, TO_DATE('02-MAY-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A6', 'J6', 'D6', 'C6','David', 'Andreea', 3150, TO_DATE('03-JUN-23', 'DD-MON-YY'),'Suspendat');
INSERT INTO angajati VALUES ('A7', 'J7', 'D7', 'C7','Iacob', 'Andrei', 2300, TO_DATE('18-JUL-19', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A8', 'J1', 'D1', 'C9','Vlonga', 'Stefan', 6000, TO_DATE('20-AUG-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A9', 'J2', 'D2', 'C10','Durlesteanu', 'Victor', 4000, TO_DATE('25-SEP-23', 'DD-MON-YY'),'In concediu');
INSERT INTO angajati VALUES ('A10', 'J3', 'D3', 'C1','Bechea', 'Flavia', 5000, TO_DATE('24-OCT-19', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A11', 'J4', 'D4', 'C2','Racovita', 'Cristina', 6100, TO_DATE('05-NOV-21', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A12', 'J5', 'D5', 'C3','Igescu', 'Rares', 3200, TO_DATE('13-DEC-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A13', 'J6', 'D6', 'C4','Chirila', 'Bianca', 3300, TO_DATE('15-JAN-18', 'DD-MON-YY'),'Suspendat');
INSERT INTO angajati VALUES ('A14', 'J7', 'D7', 'C5','Blaj', 'Deea', 2400, TO_DATE('20-FEB-24', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A15', 'J8', 'D8', 'C6','Buimac', 'Delia', 2800, TO_DATE('25-MAR-20', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A16', 'J9', 'D9', 'C7','Mihalache', 'Diana', 4100, TO_DATE('30-APR-24', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A17', 'J10', 'D6', 'C8','Nechita', 'Teodora', 3600, TO_DATE('05-MAY-24', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A18', 'J4', 'D4', 'C2','Popica', 'Tudor', 4050, TO_DATE('19-JUN-23', 'DD-MON-YY'),'In concediu');
INSERT INTO angajati VALUES ('A19', 'J5', 'D5', 'C10','Florea', 'Bianca', 3300, TO_DATE('15-JUL-20', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A20', 'J11', 'D3', 'C1','Munteanu', 'Andrada', 6400, TO_DATE('27-AUG-22', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A21', 'J8', 'D8', 'C2','Salcianu', 'Stefan', 2700, TO_DATE('10-SEP-23', 'DD-MON-YY'),'In concediu');
INSERT INTO angajati VALUES ('A22', 'J12', 'D7', 'C3','Monceanu', 'Valentina', 2600, TO_DATE('15-AUG-22', 'DD-MON-YY'),'Suspendat');
INSERT INTO angajati VALUES ('A23', 'J8', 'D8', 'C4','Andruta', 'Andra', 2900, TO_DATE('27-JUL-20', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A24', 'J9', 'D9', 'C9','Tanislav', 'Alexia', 2650, TO_DATE('08-JUN-21', 'DD-MON-YY'),'In concediu');
INSERT INTO angajati VALUES ('A25', 'J10', 'D6', 'C6','Velcea', 'Mihnea', 3400, TO_DATE('01-SEP-23', 'DD-MON-YY'),'Activ');
INSERT INTO angajati VALUES ('A26', 'J10', 'D6', 'C10','Lupu', 'Andrei', 5000, TO_DATE('12-OCT-23', 'DD-MON-YY'),'Suspendat');
INSERT INTO angajati VALUES ('A27', 'J11', 'D3', 'C8','Ciorita', 'Alexandra', 6500, TO_DATE('19-SEP-24', 'DD-MON-YY'),'In concediu');

select * from angajati;



INSERT INTO film VALUES('F1', 'Titanic', 18, 1995, 'Dragoste', 'James Cameron', 'SUA');
INSERT INTO film VALUES('F2', 'Inception', 12, 2010, 'Science Fiction', 'Christopher Nolan', 'SUA');
INSERT INTO film VALUES('F3', 'Parasite', 16, 2019, 'Thriller', 'Bong Joon-ho', 'Coreea de Sud');
INSERT INTO film VALUES('F4', 'The Godfather', 18, 1972, 'Drama', 'Francis Ford Coppola', 'SUA');
INSERT INTO film VALUES('F5', 'Interstellar', 12, 2014, 'Science Fiction', 'Christopher Nolan', 'SUA');
INSERT INTO film VALUES('F6', 'The Shawshank Redemption', 15, 1994, 'Drama', 'Frank Darabont', 'SUA');
INSERT INTO film VALUES('F7', 'Pulp Fiction', 18, 1994, 'Crima', 'Quentin Tarantino', 'SUA');
INSERT INTO film VALUES('F8', 'La La Land', 12, 2016, 'Musical', 'Damien Chazelle', 'SUA');
INSERT INTO film VALUES('F9', 'Avengers: Endgame', 13, 2019, 'Actiune', 'Anthony Russo', 'SUA');
INSERT INTO film VALUES('F10', 'Joker', 15, 2019, 'Drama', 'Todd Phillips', 'SUA');
INSERT INTO film VALUES('F11', 'The Dark Knight', 13, 2008, 'Supereroi', 'Christopher Nolan', 'SUA');
INSERT INTO film VALUES('F12', 'Spirited Away', 10, 2001, 'Animatie', 'Hayao Miyazaki', 'Japonia');
INSERT INTO film VALUES('F13', 'The Matrix', 16, 1999, 'Science Fiction', 'Lana Wachowski', 'SUA');
INSERT INTO film VALUES('F14', 'Schindler s List', 15, 1993, 'Istoric', 'Steven Spielberg', 'SUA');
INSERT INTO film VALUES('F15', 'Forrest Gump', 12, 1994, 'Drama', 'Robert Zemeckis', 'SUA');
INSERT INTO film VALUES('F16', 'Gladiator', 15, 2000, 'Istoric', 'Ridley Scott', 'SUA');
INSERT INTO film VALUES('F17', 'The Lion King', 6, 1994, 'Animatie', 'Rob Minkoff', 'SUA');
INSERT INTO film VALUES('F18', 'Crouching Tiger, Hidden Dragon', 12, 2000, 'Actiune', 'Ang Lee', 'China');
INSERT INTO film VALUES('F19', 'The Grand Budapest Hotel', 12, 2014, 'Comedie', 'Wes Anderson', 'SUA');
INSERT INTO film VALUES('F20', 'Black Panther', 13, 2018, 'Supereroi', 'Ryan Coogler', 'SUA');
INSERT INTO film VALUES('F21', 'A Separation', 12, 2011, 'Drama', 'Asghar Farhadi', 'Iran');
INSERT INTO film VALUES('F22', 'Life is Beautiful', 10, 1997, 'Drama', 'Roberto Benigni', 'Italia');
INSERT INTO film VALUES('F23', 'Pan s Labyrinth', 15, 2006, 'Fantezie', 'Guillermo del Toro', 'Spania');
INSERT INTO film VALUES('F24', 'The Revenant', 16, 2015, 'Aventura', 'Alejandro González Iñárritu', 'SUA');
INSERT INTO film VALUES('F25', 'Amélie', 12, 2001, 'Comedie Romantica', 'Jean-Pierre Jeunet', 'Franta');

select *
from film;

INSERT INTO clienti VALUES(1, 'Popescu', 'Ion', 125);
INSERT INTO clienti VALUES(2, 'Ioanitoaiei', 'Maria', 145);
INSERT INTO clienti VALUES(3, 'Georgian', 'Andrei', 190);
INSERT INTO clienti VALUES(4, 'Marin', 'Ana', 110);
INSERT INTO clienti VALUES(5, 'Dumitru', 'Mihai', 175);
INSERT INTO clienti VALUES(6, 'Jalba', 'Elena', 102);
INSERT INTO clienti VALUES(7, 'Popa', 'Florin', 215);
INSERT INTO clienti VALUES(8, 'Stan', 'Ioana', 185);
INSERT INTO clienti VALUES(9, 'Diaconu', 'Cristian', 198);
INSERT INTO clienti VALUES(10, 'Radu', 'Vasile', 135);
INSERT INTO clienti VALUES(11, 'Tudor', 'Monica', 230);
INSERT INTO clienti VALUES(12, 'Dobre', 'Adrian', 140);
INSERT INTO clienti VALUES(13, 'Luca', 'Simona', 155);
INSERT INTO clienti VALUES(14, 'Gheorghe', 'Roxana', 205);
INSERT INTO clienti VALUES(15, 'Nistor', 'Daniel', 180);
INSERT INTO clienti VALUES(16, 'Anghel', 'Alexandra', 145);
INSERT INTO clienti VALUES(17, 'Voicu', 'Alin', 125);
INSERT INTO clienti VALUES(18, 'Petrescu', 'Marian', 192);
INSERT INTO clienti VALUES(19, 'Ciobanu', 'Bianca', 137);
INSERT INTO clienti VALUES(20, 'Gavrila', 'Robert', 210);
INSERT INTO clienti VALUES(21, 'Racovita', 'Mihaela', 10);
INSERT INTO clienti VALUES(22, 'Popescu', 'Radu', 230);

update clienti
set puncte_bonus = 10
where cod_client = 21;

select *
from clienti;



INSERT INTO recenzie VALUES ('R1', 'F1', 1, 8, TO_DATE('2024-01-15', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R2', 'F2', 2, 9, TO_DATE('2024-06-20', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R3', 'F3', 3, 7, TO_DATE('2024-01-22', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R4', 'F5', 5, 8, TO_DATE('2024-01-28', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R5', 'F8', 2, 7, TO_DATE('2024-10-05', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R6', 'F9', 6, 8, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R7', 'F10', 7, 9, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R8', 'F11', 8, 10, TO_DATE('2024-12-12', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R9', 'F12', 9, 8, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R10', 'F13', 6, 7, TO_DATE('2024-04-18', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R11', 'F15', 9, 9, TO_DATE('2024-12-22', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R12', 'F15', 1, 9, TO_DATE('2024-01-25', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R13', 'F15', 20, 4, TO_DATE('2024-06-28', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R14', 'F16', 11, 3, TO_DATE('2024-09-01', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R15', 'F17', 12, 10, TO_DATE('2024-02-03', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R16', 'F18', 13, 4, TO_DATE('2024-03-05', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R17', 'F19', 14, 7, TO_DATE('2024-08-07', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R18', 'F20', 15, 5, TO_DATE('2024-03-10', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R19', 'F20', 15, 7, TO_DATE('2024-08-12', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R20', 'F16', 16, 8, TO_DATE('2024-09-15', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R21', 'F8', 17, 1, TO_DATE('2024-03-18', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R22', 'F10', 18, 1, TO_DATE('2024-12-20', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R23', 'F20', 19, 6, TO_DATE('2024-05-22', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R24', 'F4', 4, 9, TO_DATE('2024-10-15', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R25', 'F15', 15, 2, TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R26', 'F11', 2, 9, TO_DATE('2024-03-02', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R27', 'F15', 5, 7, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R28', 'F17', 5, 8, TO_DATE('2024-01-04', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R29', 'F17', 10, 10, TO_DATE('2024-11-13', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R30', 'F19', 10, 6, TO_DATE('2024-12-16', 'YYYY-MM-DD'));
INSERT INTO recenzie VALUES ('R31', 'F23', 1, 7, TO_DATE('2024-12-05', 'YYYY-MM-DD'));

select *
from recenzie;



INSERT INTO rezervare VALUES ('F1', 1, 25, 1, '2D', 1, 'Card');
INSERT INTO rezervare VALUES ('F2', 2, 35, 2, '3D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F3', 3, 50, 1, 'IMAX', 1, 'Card');
INSERT INTO rezervare VALUES ('F4', 4, 25, 2, '2D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F5', 5, 35, 1, '3D', 3, 'Card');
INSERT INTO rezervare VALUES ('F6', 6, 25, 1, '2D', 1, 'Cash');
INSERT INTO rezervare VALUES ('F7', 7, 50, 2, 'IMAX', 1, 'Card');
INSERT INTO rezervare VALUES ('F8', 8, 25, 1, '2D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F9', 9, 35, 2, '3D', 1, 'Card');
INSERT INTO rezervare VALUES ('F10', 10, 25, 1, '2D', 1, 'Cash');
INSERT INTO rezervare VALUES ('F11', 11, 50, 2, 'IMAX', 3, 'Card');
INSERT INTO rezervare VALUES ('F12', 12, 35, 1, '3D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F13', 13, 25, 1, '2D', 1, 'Card');
INSERT INTO rezervare VALUES ('F14', 14, 35, 1, '3D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F15', 15, 50, 2, 'IMAX', 1, 'Card');
INSERT INTO rezervare VALUES ('F16', 16, 25, 1, '2D', 1, 'Cash');
INSERT INTO rezervare VALUES ('F17', 17, 35, 1, '3D', 2, 'Card');
INSERT INTO rezervare VALUES ('F18', 18, 50, 2, 'IMAX', 1, 'Cash');
INSERT INTO rezervare VALUES ('F19', 19, 25, 1, '2D', 2, 'Card');
INSERT INTO rezervare VALUES ('F20', 20, 35, 1, '3D', 3, 'Cash');
INSERT INTO rezervare VALUES ('F20', 1, 25, 1, '2D', 2, 'Card');
INSERT INTO rezervare VALUES ('F21', 1, 35, 1, '3D', 3, 'Cash');
INSERT INTO rezervare VALUES ('F23', 1, 50, 1, 'IMAX', 2, 'Card');
INSERT INTO rezervare VALUES ('F23', 21, 35, 3, '3D', 4, 'Card');
INSERT INTO rezervare VALUES ('F10', 2, 25, 1, '2D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F11', 2, 50, 1, 'IMAX', 2, 'Card');
INSERT INTO rezervare VALUES ('F15', 5, 35, 1, '3D', 3, 'Card');
INSERT INTO rezervare VALUES ('F17', 5, 50, 2, 'IMAX', 3, 'Cash');
INSERT INTO rezervare VALUES ('F17', 10, 25, 2, '2D', 2, 'Card');
INSERT INTO rezervare VALUES ('F18', 10, 35, 2, '3D', 3, 'Cash');
INSERT INTO rezervare VALUES ('F19', 10, 50, 1, 'IMAX', 1, 'Card');
INSERT INTO rezervare VALUES ('F15', 22, 25, 4, '2D', 2, 'Cash');
INSERT INTO rezervare VALUES ('F20', 22, 25, 4, '2D', 2, 'Card');

select * from rezervare;

INSERT INTO difuzeaza VALUES (
    'C1', 'F1', 
    lista_perioade(
        per_dif(TO_DATE('17-06-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI')),
        per_dif(TO_DATE('17-06-2024', 'DD-MM-YYYY'), TO_DATE('15:00', 'HH24:MI'), TO_DATE('17:30', 'HH24:MI')),
        per_dif(TO_DATE('18-06-2024', 'DD-MM-YYYY'), TO_DATE('20:00', 'HH24:MI'), TO_DATE('22:30', 'HH24:MI'))),
    'Romana',150);

INSERT INTO difuzeaza VALUES (
    'C1', 'F2', 
    lista_perioade(
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:30', 'HH24:MI')),
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('21:00', 'HH24:MI'), TO_DATE('23:30', 'HH24:MI'))),
    'Romana', 180);

INSERT INTO difuzeaza VALUES (
    'C1', 'F2', 
    lista_perioade(
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:30', 'HH24:MI')),
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('21:00', 'HH24:MI'), TO_DATE('23:00', 'HH24:MI'))),
    'Romana', 150);

INSERT INTO difuzeaza VALUES (
    'C2', 'F3', 
    lista_perioade(
        per_dif(TO_DATE('10-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI')),
        per_dif(TO_DATE('12-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('18:30', 'HH24:MI')),
        per_dif(TO_DATE('15-12-2024', 'DD-MM-YYYY'), TO_DATE('20:00', 'HH24:MI'), TO_DATE('22:30', 'HH24:MI'))),
    'Engleza', 150);

INSERT INTO difuzeaza VALUES (
    'C2', 'F4', 
    lista_perioade(
        per_dif(TO_DATE('15-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI')),
        per_dif(TO_DATE('16-12-2024', 'DD-MM-YYYY'), TO_DATE('14:00', 'HH24:MI'), TO_DATE('16:00', 'HH24:MI'))),
    'Romana', 120);

INSERT INTO difuzeaza VALUES (
    'C3', 'F5', 
    lista_perioade(
        per_dif(TO_DATE('10-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:30', 'HH24:MI')),
        per_dif(TO_DATE('03-12-2024', 'DD-MM-YYYY'), TO_DATE('17:00', 'HH24:MI'), TO_DATE('19:00', 'HH24:MI'))),
    'Romana', 150);

INSERT INTO difuzeaza VALUES (
    'C4', 'F6', 
    lista_perioade(
        per_dif(TO_DATE('20-12-2024', 'DD-MM-YYYY'), TO_DATE('17:00', 'HH24:MI'), TO_DATE('19:00', 'HH24:MI')),
        per_dif(TO_DATE('21-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI'))),
    'Engleza', 120);
    
INSERT INTO difuzeaza VALUES (
    'C5', 'F7', 
    lista_perioade(
        per_dif(TO_DATE('09-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('18:00', 'HH24:MI')),
        per_dif(TO_DATE('02-12-2024', 'DD-MM-YYYY'), TO_DATE('19:00', 'HH24:MI'), TO_DATE('21:00', 'HH24:MI'))),
    'Romana', 120);

INSERT INTO difuzeaza VALUES (
    'C6', 'F8', 
    lista_perioade(
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('21:00', 'HH24:MI')),
        per_dif(TO_DATE('06-12-2024', 'DD-MM-YYYY'), TO_DATE('17:30', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI'))),
    'Romana', 150);

INSERT INTO difuzeaza VALUES (
    'C7', 'F9', 
    lista_perioade(
        per_dif(TO_DATE('04-12-2024', 'DD-MM-YYYY'), TO_DATE('15:00', 'HH24:MI'), TO_DATE('17:30', 'HH24:MI')),
        per_dif(TO_DATE('04-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:30', 'HH24:MI'))),
    'Romana', 150);

INSERT INTO difuzeaza VALUES (
    'C8', 'F10', 
    lista_perioade(
        per_dif(TO_DATE('15-12-2024', 'DD-MM-YYYY'), TO_DATE('14:00', 'HH24:MI'), TO_DATE('15:30', 'HH24:MI')),
        per_dif(TO_DATE('16-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('17:30', 'HH24:MI'))),
    'Engleza', 90);

INSERT INTO difuzeaza VALUES (
    'C10', 'F12', 
    lista_perioade(
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('19:30', 'HH24:MI')),
        per_dif(TO_DATE('02-12-2024', 'DD-MM-YYYY'), TO_DATE('20:00', 'HH24:MI'), TO_DATE('22:00', 'HH24:MI'))),
    'Japoneza', 90);

INSERT INTO difuzeaza VALUES (
    'C1','F13', 
    lista_perioade(
        per_dif(TO_DATE('10-12-2024', 'DD-MM-YYYY'), TO_DATE('17:30', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI')),
        per_dif(TO_DATE('11-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('18:30', 'HH24:MI'))),
    'Romana', 150);
    
INSERT INTO difuzeaza VALUES (
    'C2', 'F14', 
    lista_perioade(
        per_dif(TO_DATE('15-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('18:00', 'HH24:MI'))),
    'Romana', 120);

INSERT INTO difuzeaza VALUES (
    'C3', 'F15', 
    lista_perioade(
        per_dif(TO_DATE('12-12-2024', 'DD-MM-YYYY'), TO_DATE('19:00', 'HH24:MI'), TO_DATE('21:00', 'HH24:MI'))),
    'Romana', 120);

INSERT INTO difuzeaza VALUES (
    'C4', 'F16', 
    lista_perioade(
        per_dif(TO_DATE('20-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('18:30', 'HH24:MI')),
        per_dif(TO_DATE('21-12-2024', 'DD-MM-YYYY'), TO_DATE('15:00', 'HH24:MI'), TO_DATE('17:30', 'HH24:MI')),
        per_dif(TO_DATE('22-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:30', 'HH24:MI'))),
    'Engleza', 150);

INSERT INTO difuzeaza VALUES (
    'C5', 'F17', 
    lista_perioade(
        per_dif(TO_DATE('18-12-2024', 'DD-MM-YYYY'), TO_DATE('15:00', 'HH24:MI'), TO_DATE('16:20', 'HH24:MI')),
        per_dif(TO_DATE('02-12-2024', 'DD-MM-YYYY'), TO_DATE('14:30', 'HH24:MI'), TO_DATE('15:50', 'HH24:MI'))),
    'Romana', 80);

INSERT INTO difuzeaza VALUES (
    'C6', 'F18', 
    lista_perioade(
        per_dif(TO_DATE('10-12-2024', 'DD-MM-YYYY'), TO_DATE('17:00', 'HH24:MI'), TO_DATE('18:30', 'HH24:MI')),
        per_dif(TO_DATE('12-12-2024', 'DD-MM-YYYY'), TO_DATE('19:00', 'HH24:MI'), TO_DATE('20:30', 'HH24:MI'))),
    'Chineza', 90);

INSERT INTO difuzeaza VALUES (
    'C7', 'F19', 
    lista_perioade(
        per_dif(TO_DATE('05-12-2024', 'DD-MM-YYYY'), TO_DATE('15:00', 'HH24:MI'), TO_DATE('17:10', 'HH24:MI')),
        per_dif(TO_DATE('06-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:10', 'HH24:MI')),
        per_dif(TO_DATE('07-12-2024', 'DD-MM-YYYY'), TO_DATE('17:30', 'HH24:MI'), TO_DATE('19:40', 'HH24:MI'))),
    'Romana', 130);

INSERT INTO difuzeaza VALUES (
    'C8', 'F20', 
    lista_perioade(
        per_dif(TO_DATE('19-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('18:20', 'HH24:MI')),
        per_dif(TO_DATE('02-12-2024', 'DD-MM-YYYY'), TO_DATE('18:30', 'HH24:MI'), TO_DATE('20:50', 'HH24:MI'))),
    'Engleza', 140);

INSERT INTO difuzeaza VALUES (
    'C9', 'F21', 
    lista_perioade(
        per_dif(TO_DATE('10-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('20:00', 'HH24:MI'))),
    'Romana', 120);

INSERT INTO difuzeaza VALUES (
    'C10', 'F22', 
    lista_perioade(
        per_dif(TO_DATE('23-12-2024', 'DD-MM-YYYY'), TO_DATE('17:00', 'HH24:MI'), TO_DATE('18:10', 'HH24:MI'))),
    'Italiana', 70);

INSERT INTO difuzeaza VALUES (
    'C1', 'F23', 
    lista_perioade(
        per_dif(TO_DATE('15-12-2024', 'DD-MM-YYYY'), TO_DATE('19:00', 'HH24:MI'), TO_DATE('20:50', 'HH24:MI'))),
    'Spaniola', 110);

INSERT INTO difuzeaza VALUES (
    'C2', 'F24', 
    lista_perioade(
        per_dif(TO_DATE('27-12-2024', 'DD-MM-YYYY'), TO_DATE('16:00', 'HH24:MI'), TO_DATE('17:30', 'HH24:MI')),
        per_dif(TO_DATE('02-12-2024', 'DD-MM-YYYY'), TO_DATE('18:00', 'HH24:MI'), TO_DATE('19:30', 'HH24:MI'))),
    'Romana', 90);


INSERT INTO difuzeaza VALUES (
    'C3', 'F25', 
    lista_perioade(
        per_dif(TO_DATE('10-12-2024', 'DD-MM-YYYY'), TO_DATE('15:30', 'HH24:MI'), TO_DATE('17:10', 'HH24:MI'))),
    'Franceza', 100);

select *
from difuzeaza;

SELECT d.cod_cinematograf, 
       d.cod_film, 
       TO_CHAR(p.data_difuzare, 'DD-MM-YYYY') AS data_difuzare,
       TO_CHAR(p.ora_inceput, 'HH24:MI') AS ora_inceput,
       TO_CHAR(p.ora_final, 'HH24:MI') AS ora_final
FROM difuzeaza d,
     TABLE(d.perioade_difuzare) p;



commit;