--Лабораторная выполняется в СУБД  Oracle. 
--Cкопируйте файл  edu8.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. 
--Запустите скрипт edu8.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа 3, курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных 
--Вами операторов после пунктов 1- 9.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt 
--и сохраняется в каталог.

--1.	Создайте таблицу emp_tel, с полями empno, phone_num. Первое из них - поле идентичное полю empno 
--таблицы emp и служит внешним ключом для связывания таблиц emp и emp_tel. 
--Второе поле – массив переменной длины с максимальным числом элементов равным пяти. 
--Поле может содержать телефоны сотрудника (домашний, рабочий, МТС, Велком, Лайф). 

CREATE OR REPLACE TYPE phone_num_ty AS VARRAY(4) OF VARCHAR2(30);
/
CREATE TABLE emp_tel (
  empno INTEGER NOT NULL REFERENCES emp(empno),
  phone_num phone_num_ty
);

--2.	Вставьте записи в таблицу  emp_tel со следующими данными:
--505, 2390122, 2203415, 80297121314, 80296662332, Null
--303, 2390222, 2240070, 80297744543, 80296667766, 80443345543
--503, 2391234, 2233014, Null, 80296171717, 80443161612
--104, 2390012, 22333015, 80297654321, Null, 90443939398

INSERT INTO  emp_tel VALUES(505, phone_num_ty('2203415', '80297121314', '80296662332', NULL));
INSERT INTO  emp_tel VALUES(303, phone_num_ty('2240070', '80297744543', '80296667766', '80443345543'));
INSERT INTO  emp_tel VALUES(503, phone_num_ty('2233014', NULL, '80296171717', '80443161612'));
INSERT INTO  emp_tel VALUES(104, phone_num_ty('22333015', '80297654321', NULL, '90443939398'));

--3.	Создайте запросы:
--a)	 для сотрудников с номерами 505, 503 указать имя, фамилию и номера телефонов;

SELECT emp.empname, emp_tel.phone_num FROM emp_tel
JOIN emp ON emp.empno = emp_tel.empno
WHERE emp.empno IN (505, 303);

--b)	для сотрудника с номером 303, используя функцию Table, укажите его номер и телефоны.

select empno, LISTAGG(column_value, ', ') WITHIN GROUP(order by column_value) phones 
from emp_tel, table(emp_tel.phone_num)
where empno = 303
group by empno;

--4.	Создайте таблицу children с полями empno, child. 
--Первое из них - поле идентичное полю empno таблицы emp и служит внешним ключом для связывания 
--таблиц emp и children. Второе является вложенной таблицей и содержит данные об имени (name) 
--и дате рождения ребёнка (birthdate) сотрудника.

CREATE OR REPLACE TYPE clildren_record_ty AS OBJECT 
(name VARCHAR(50),  birthdate DATE);
/
CREATE TYPE clildren_table_ty IS TABLE OF clildren_record_ty;
/

CREATE TABLE children (
  empno NUMBER NOT NULL REFERENCES emp(empno),
  child clildren_table_ty
) NESTED TABLE child STORE AS child_table;

--5.	Вставьте в таблицу children записи:
--для сотрудника с номером 102 двое детей: Pavel, 02.02.2011
--				               Nina, 10.11.2015;


INSERT INTO children VALUES(
  102,
  clildren_table_ty(
    clildren_record_ty('Pavel', TO_DATE('02-02-2011','dd-mm-yyyy')),
    clildren_record_ty('Nina', TO_DATE('10-11-2015','dd-mm-yyyy'))
  )
);
--для сотрудника с номером 327 двое детей: Alex, 22.09.2015
--						Anna, 04.10.2018.

INSERT INTO children VALUES(
  327,
  clildren_table_ty(
    clildren_record_ty('Alex', TO_DATE('22-09-2015','dd-mm-yyyy')),
    clildren_record_ty('Anna',TO_DATE('04-10-2018','dd-mm-yyyy'))
  )
);

--6.	Создайте запросы:
--a)	укажите все сведения из таблицы children;

SELECT * FROM children temp, TABLE(temp.child) tchild;

--b)	укажите имя и фамилию сотрудника, имеющего ребёнка с именем Pavel, имя ребёнка и дату рождения ребёнка.

SELECT e.empname, tchild.* FROM children temp, TABLE(temp.child) tchild 
JOIN emp e ON e.empno = empno
WHERE name = 'Pavel' and e.empno = temp.empno;

--7.	Измените дату рождения ребёнка с именем Alex на 10.10.2016.

UPDATE TABLE (
  SELECT child FROM children, TABLE(child) tchild
  WHERE tchild.name = 'Alex'
)
SET birthdate = TO_DATE('10-10-2016', 'dd-mm-yyyy') WHERE name = 'Alex';
SELECT temp.empno, tchild.* FROM children temp, TABLE(temp.child) tchild;

--8.	Добавьте для сотрудника с номером 102 ребёнка с именем Trevor и датой рождения 10.12.2019.
INSERT INTO TABLE (
  SELECT child FROM children
  WHERE empno = 102
) VALUES (clildren_record_ty('Trevor', TO_DATE('10.12.2019','dd.mm.yyyy')));
SELECT temp.empno, tchild.* FROM children temp, TABLE(temp.child) tchild;

--9.	Удалите сведения о ребёнке с именем Nina для сотрудника с номером 102.	
	
DELETE FROM TABLE (
  SELECT child FROM children WHERE empno = 102
) temp where temp.name = 'Nina';
SELECT temp.empno, tchild.* FROM children temp, TABLE(temp.child) tchild;

