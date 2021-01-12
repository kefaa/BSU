--Выберите СУБД Oracle для выполнения лабораторной. 
--Cкопируйте файл EDU1.sql в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
-- Произведите запуск SQLPlus. или PLSQLDeveloper. или другого инструментария Oracle и соеденитесь с БД.  Запустите скрипт EDU.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа        3    , курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки соответсвующего select-предложения после строки с текстом задания. 
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и отправте в систему edufpmi как ответ к заданию или сохраните в файл.                        .
--Тексты заданий:
--1.	Выдать информацию об минимальном окладе (minsalary) продовца (salesman).
SELECT minsalary FROM job
WHERE jobname = 'Salesman';
	
--2.	Выдать информацию обо всех работниках, родившихся в промежуток: 1 января 1985 года, 31 декабря 2000 года.

SELECT * FROM emp
WHERE to_date('01-01-1985','dd-mm-yyyy') <= birthdate AND birthdate <= to_date('31-12-2000','dd-mm-yyyy');

--3.	Найти дату первого принятия на работу сотрудника Don Burleson.

SELECT MIN(startdate) FROM emp
JOIN career c on emp.empno = c.empno
WHERE empname = 'Don Burleson';

--4.	Подсчитать число работников, не работавших в компании в период с 31 мая 2017 года по 31 декабря 2018 года хотя бы один день.
SELECT count(*) as ans FROM emp
WHERE 
(SELECT count(*) FROM career c WHERE c.empno = emp.empno and 
(c.startdate <= to_date('31-12-2018','dd-mm-yyyy') and (c.enddate is null or to_date('31-05-2017','dd-mm-yyyy') <= c.enddate))) = 0;

--5.	Найти минимальные, максимальные и средние премии начисленные в 2016, 2017, 2018, 2019 годах (указать год и размеры премий в хронологическом порядке). 	

SELECT year, MIN(bonvalue), MAX(bonvalue), AVG(bonvalue) FROM bonus
WHERE 2016 <= year and year <= 2019
GROUP BY year
ORDER BY year;

--6.	Выдать информацию о названии всех должностей,  на которых работала сотрудник Nina Tihanovich. Если Nina Tihanovich работает в настоящее время - должность также включается в искомый список.

SELECT DISTINCT(jobname) FROM (job
JOIN career c on c.jobno = job.jobno) 
JOIN emp e on e.empno = c.empno
WHERE e.empname = 'Nina Tihanovich';

--7.	Выдать информацию о названиях должностей, на которых в настоящее время работают Richard Martin и Jon Martin. Должность выдаётся вместе с ФИО (empname) работника.

SELECT e.empname, jobname FROM (job
JOIN career c on c.jobno = job.jobno) 
JOIN emp e on e.empno = c.empno
WHERE e.empname in ('Richard Martin', 'Jon Martin') and c.enddate is null;

-- 8.	Найти фамилии, коды должностей, названия отделов и периоды работы (даты приема и даты увольнения) для всех инженеров (Engineer) и программистов (Programmer), работавших или работающих в компании. Для работающих дата увольнения для периода неопределена и при выводе либо отсутсвует, либо определяется как Null.

SELECT e.empname, j.jobno, career.startdate, career.enddate FROM career
JOIN emp e ON e.empno = career.empno
JOIN job j ON j.jobno = career.jobno
JOIN dept d ON d.deptid = career.deptid
WHERE j.jobname in ('Engineer', 'Programmer');
       
-- 9.	Найти фамилии, коды должностей, названия должностей и периоды работы (даты приема и даты увольнения) для бухгалтеров (Accountant) и исполнительных директоров (Executive Director),  работавших или работающих в компании. Для работающих дата увольнения для периода неопределена и при выводе либо отсутсвует, либо определяется как Null.

SELECT e.empname, j.jobno, j.jobname, career.startdate, career.enddate FROM career
JOIN emp e ON e.empno = career.empno
JOIN job j ON j.jobno = career.jobno
WHERE j.jobname in ('Accountant', 'Executive Director');

-- 10.	Найти фамилии различных работников, работавших в отделе B02 в период с 01.01.2014 по 31.12.2017 хотя бы один день. 

SELECT DISTINCT(emp.empname) FROM emp
JOIN career c ON emp.empno = c.empno
WHERE c.deptid = 'B02' AND c.startdate <= to_date('31-12-2017','dd-mm-yyyy') AND (c.enddate IS NULL OR to_date('01-01-2014','dd-mm-yyyy') <= c.enddate);

-- 11.	Найти количество этих работников.

SELECT count(DISTINCT(emp.empname)) FROM emp
JOIN career c ON emp.empno = c.empno
WHERE c.deptid = 'B02' AND c.startdate <= to_date('31-12-2017','dd-mm-yyyy') AND (c.enddate IS NULL OR to_date('01-01-2014','dd-mm-yyyy') <= c.enddate);

--12.	Найти номера и названия отделов, в которых в период с 01.01.2015 по 31.12.2015 работало не более 7 сотрудников.

SELECT DISTINCT dept.deptid, dept.deptname FROM dept
JOIN career c ON c.deptid = dept.deptid
WHERE (SELECT count(*) FROM career
    WHERE (career.deptid = dept.deptid 
        AND career.startdate <= to_date('31.12.2015','dd-mm-yyyy') AND to_date('01.01.2015','dd-mm-yyyy') <= career.enddate)) <= 7;
        
--13.	Найти информацию о работниках (номер, фамилия), для которых начислялись премии в период с 01.01. 2016 по  31.12.2017.

SELECT DISTINCT emp.empno, emp.empname FROM emp
JOIN bonus b ON b.empno = emp.empno
WHERE (SELECT count(*) FROM bonus
    WHERE bonus.empno = emp.empno AND 2016 <= bonus.year AND bonus.year <= 2017) > 0;
    
--14.	Найти фамилии работников, никогда не работавших  ни в исследовательском  (Research) отделе, ни в отделе поддержки (Support). 

SELECT DISTINCT(emp.empname) FROM emp
JOIN career c ON c.empno = emp.empno
JOIN dept d ON d.deptid = c.deptid
WHERE (SELECT count(*) FROM career
    WHERE c.empno = emp.empno AND d.deptname IN ('Research', 'Support')) = 0;
    
-- 15.	Найти количество сотрудников, работавших в двух и более отделах. Если сотрудник работает в настоящее время, то отдел также учитывается.

SELECT count(DISTINCT(emp.empno)) FROM emp
JOIN career c ON c.empno = emp.empno
WHERE (SELECT count(DISTINCT deptid) FROM career
    WHERE career.empno = emp.empno) >= 2;

-- 16.	Найти коды и фамилии сотрудников, работавших только н одной должности. Если сотрудник работает в настоящее время, то должность также учитывается.

SELECT DISTINCT emp.empno, emp.empname FROM emp
JOIN career c ON c.empno = emp.empno
WHERE (SELECT count(DISTINCT jobno) FROM career
    WHERE career.empno = emp.empno) >= 2;
    
-- 17.	Найти коды  и фамилии сотрудников, суммарный стаж работы которых в компании не менее 4 лет.

SELECT emp.empno, emp.empname FROM emp
JOIN career c ON emp.empno = c.empno
GROUP BY emp.empno, emp.empname
HAVING sum(MONTHS_BETWEEN(NVL(c.enddate, current_date), c.startdate)) >= 48;

-- 18.	Найти всех сотрудников (коды и фамилии), ни разу не увольнявшихся из компании.

SELECT DISTINCT emp.empno, emp.empname FROM emp
JOIN career c ON c.empno = emp.empno
WHERE (SELECT count(*) FROM career
    WHERE c.empno = emp.empno AND enddate IS NOT NULL) = 0;

--19.	Найти среднии премии, начисленные за период в два 2016, 2017 года, и за период в два 2017, 2018 года, в разрезе работников (т.е. для работников, имевших начисления хотя бы в одном месяце двугодичного периода). Вывести id, имя и фимилию работника, период, среднюю премию.

SELECT AVG(bonvalue), '2016, 2017', emp.empname, emp.empno FROM bonus
JOIN emp ON bonus.empno = emp.empno
WHERE year IN (2016, 2017)
GROUP BY emp.empname, emp.empno 
UNION (SELECT AVG(bonvalue), '2017, 2018', emp.empname, emp.empno FROM bonus
    JOIN emp ON bonus.empno = emp.empno
    WHERE year IN (2017, 2018)
    GROUP BY emp.empname, emp.empno);
    
--20.	Найти должности (id, название), для которых есть начисления премий в феврале 2017 года.
SELECT job.jobno, job.jobname FROM job
JOIN career c
JOIN bonus b ON c.empno = b.empno ON job.jobno = c.jobno
WHERE b.month = 2 AND b.year = 2017
