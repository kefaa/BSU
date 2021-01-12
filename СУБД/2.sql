--Выбирите СУБД (DB2, Oracle) для выполнения лабораторной. 
--В зависимости от выбора скопируйте файлы  FPMI\SERV314\SUBFACULTY\каф ИСУ\Исаченко\Лабораторные\EDU.txt , ............\EDU1.txt  (для DB2) или ......\EDU.sql, .....\EDU1.sql (для Oracle) в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--В случае выбора DB2, произведите запуск IBM DB2 и соеденитесь с БД EDU. Запустите скриптs EDU.txt, EDU1.txt на выполнение.
--В случае выбора Oracle, произведите запуск SQLPlus или PLSQLDeveloper и соеденитесь с БД под логином Scott и паролем Tiger.  Запустите скрипты EDU.sql и EDU1.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа 3, курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки соответсвующегоselect-предложения после строки с текстом задания. 
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталог  fpmi-serev604\common_stud\Исаченко\Группа3                   .
--Тексты заданий:
--1.Увеличте нижнюю границу минимальной заработной платы в таблице JOB на 50 единиц.

UPDATE job
SET minsalary = minsalary + 50;
rollback;

--2. Увеличте минимальную зарплату в таблице JOB на 10%  для всех должностей, минимальная зарплата для которых меньше 2000 единиц.	

UPDATE job
SET minsalary = minsalary * 1.10
WHERE minsalary <= 2000;
rollback;

--3. Увеличте минимальную зарплату в таблице JOB на 10% для продовца  (Salesman) и уменьшите минимальную зарплату для инженера (Engineer) на 10%  (одним оператором).
UPDATE job
SET minsalary = CASE
    WHEN jobname = 'Salesman' THEN minsalary * 1.1
    WHEN jobname = 'Engineer' THEN minsalary * 0.9
    ELSE minsalary
END;
rollback;

--4. Установите минимальную зарплату менеджера ( Manager) равной половине зарплаты  программиста (Programmer).

UPDATE job
SET minsalary =
(SELECT minsalary FROM job WHERE jobname = 'Programmer') * 0.5
WHERE jobname = 'Manager';
rollback;

--5. Приведите в таблице EMP имена служащих, которые начинаются на буквы 'D', ‘N’ и ‘O’, полностью к нижнему регистру, оставив формат фамилий прежним.

UPDATE emp
SET empname = LOWER(regexp_substr(empname, '^\w* ')) || regexp_substr(empname, '\w*$')
WHERE regexp_like(empname, '^[DNO]');
rollback;

--6. Приведите в таблице EMP фамилии служащих, имена которых начинаются на буквы 'A', ‘D’ и ‘O’, полностью к верхнему регистру, оставив формат имён прежним.

UPDATE emp
SET empname = regexp_substr(empname, '^\w* ') || upper(regexp_substr(empname, '\w*$'))
WHERE regexp_like(empname, '^[ADO]');

--7. Приведите в таблице EMP имена и фамилии служащих, с именами Stephen,  Piter и Alex, полностью к верхнему регистру.

UPDATE emp
SET empname = upper(empname)
WHERE substr(empname, 1, 7) = 'Stephen' OR substr(empname, 1, 5) = 'Piter' OR substr(empname, 1, 4) = 'Alex';

rollback;
--8. Оставте в таблице EMP только фамилии сотрудников (имена удалите).

UPDATE emp
SET empname = substr(empname, instr(empname, ' ') + 1);

rollback;
--9. Перенесите отдел с кодом U03 по адресу отдела управления персоналом (Personnel management), а тот, в сою очередь, по адресу отдела с кодом U02. 
UPDATE dept
SET deptaddress = (SELECT deptaddress FROM dept WHERE deptname = 'Personnel management')
WHERE deptid = 'U03';

UPDATE dept
SET deptaddress = (SELECT deptaddress FROM dept WHERE deptid = 'U02')
WHERE deptname = 'Personnel management';
rollback;

--10. Добавьте нового сотрудника в таблицу EMP. Его номер равен  900, имя и фамилия ‘Frank Hayes’, дата рождения ‘12-09-1978’.	

INSERT INTO emp
VALUES (900, 'Frank Hayes', to_date('12-09-1978', 'dd-mm-yyyy'));

--11. Определите нового сотрудника (см. предыдущее задание) на работу в административный отдел (Administration) с адресом 'Belarus, Minsk', начиная с текущей даты в должности менеджера (Manager).
INSERT INTO career
VALUES(
(SELECT jobno FROM job WHERE jobname = 'Manager'), 900, 
(SELECT deptid FROM dept WHERE deptname = 'Administration' AND deptaddress = 'Belarus, Minsk'), CURRENT_DATE, NULL);

rollback;
--12. Удалите все записи из таблицы TMP_EMP. Добавьте в нее информацию о сотрудниках, которые работают в отделе развития (Development) или продаж (Sales) в настоящий момент.

DELETE FROM tmp_emp;
INSERT INTO tmp_emp
  SELECT e.empno, e.empname, e.birthdate FROM emp e
   JOIN career c on c.empno = e.empno
   JOIN dept d on c.deptid = d.deptid
   WHERE c.enddate IS NULL AND d.deptname in ('Development', 'Sales');

rollback;

--13. Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые ни разу не увольнялись и работают на предприятии в настоящий момент.

INSERT INTO tmp_emp (empno, empname, birthdate)
  (SELECT * FROM emp WHERE empno not in
  (SELECT empno FROM career WHERE enddate IS NOT NULL));
rollback;

--14. Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые хотя бы раз увольнялись и работают на предприятии в настоящий момент.

INSERT INTO TMP_EMP (empno, empname, birthdate)
  (SELECT empno, empname, birthdate FROM emp
   WHERE empno NOT IN ((SELECT empno FROM CAREER WHERE CAREER.enddate IS NULL)) AND 
         empno IN((SELECT empno FROM TMP_EMP)));

rollback;
--15. Удалите все записи из таблицы TMP_JOB и добавьте в нее информацию по тем должностям, на которых в  настоящий момент работаеют сотрудники.
DELETE FROM tmp_emp;
INSERT INTO TMP_JOB (jobno, jobname, minsalary)
  (SELECT JOB.jobno, jobname, minsalary FROM JOB
   JOIN CAREER C2 on JOB.jobno = C2.jobno
   WHERE C2.enddate IS NULL
   GROUP BY job.jobno, jobname, minsalary);

rollback;
--16. Удалите всю информацию о начислениях премий сотрудникам, которые в настоящий момент уже не работают на предприятии.

DELETE FROM bonus
WHERE empno NOT IN
(SELECT empno FROM career WHERE enddate IS NULL);

rollback;
--17. Начислите премию в размере 20% минимального должностного оклада всем сотрудникам, работающим на предприятии. 
--Зарплату начислять по должности, занимаемой сотрудником в настоящий момент и отнести ее на текущий месяц.

INSERT INTO bonus
(SELECT career.empno, 
extract(MONTH FROM CURRENT_DATE), 
2018 /* ограничение на год в скрипте*/, j.minsalary * 0.2 FROM career
   JOIN job j ON career.jobno = j.jobno
   WHERE enddate IS NULL );
   

--18. Удалите данные о премиях  за 2017 и 2019 годы для сотрудников, неработающих в настоящий момент.	

DELETE FROM bonus 
WHERE empno NOT IN
(SELECT empno FROM career WHERE enddate IS NULL) AND year in (2017, 2019);

rollback;
--19. Удалите информацию о прошлой карьере тех сотрудников, которые в настоящий момент  работают на предприятии.
DELETE FROM career
WHERE enddate IS NOT NULL AND empno IN
(SELECT empno FROM career WHERE enddate IS NULL);

rollback;

--20. Удалите записи из таблицы EMP для тех сотрудников, которые не работают на предприятии в настоящий момент.
DELETE FROM career
WHERE empno NOT IN
(SELECT DISTINCT empno FROM career WHERE enddate IS NULL);

DELETE FROM bonus
WHERE empno NOT IN
(SELECT DISTINCT empno FROM career WHERE enddate IS NULL);

DELETE FROM emp
WHERE empno NOT IN
(SELECT DISTINCT empno FROM career WHERE enddate IS NULL);

rollback;

