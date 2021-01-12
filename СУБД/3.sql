--лабораторная выполняется в СУБД  Oracle. 
--Скопируйте файлы EDU3.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. Таблица Bonus имеет дополнительный столбец tax (налог) со значениями null.  
--Произведите запуск SQLPlus, PLSQLDeveloper или другого инструментария Oracle и соеденитесь с БД.  Запустите скрипты EDU3.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа 3, курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1a), 1b), 1c), 2), 3).
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в cbcntvt edufpmi.bsu.by      .                   .
--Вам необходимо создать ананимные блоки (программы) для начисления налога на прибыль и занесения его в соответсвующую запись таблицы Bonus.
--Налог вычисляется по следующему правилу: 
--налог равен 9% от начисленной  в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца не превышает 600;
--налог равен 11% от начисленной  в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца больше 600, но не превышает 900;
--налог равен 13% от начисленной  в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца больше 900, но не превышает 900больше 1200;
--налог равен 15% от начисленной  в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца  больше 1200;.

--1.	Составьте программу вычисления налога и вставки его в таблицу Bonus:
--a) с помощью простого цикла (loop) с курсором, оператора if или опретора case;

DECLARE CURSOR cursor IS
SELECT psum_bonus.empno, psum_bonus.month, psum_bonus.year, sum(b.bonvalue) AS sum FROM bonus psum_bonus
JOIN bonus b ON (b.empno = psum_bonus.empno AND b.year = psum_bonus.year AND b.month <= psum_bonus.month)
GROUP BY psum_bonus.empno, psum_bonus.month, psum_bonus.year;

x cursor % ROWTYPE;
p REAL := 0;
BEGIN OPEN cursor;
  LOOP FETCH cursor INTO x;
    EXIT WHEN cursor % NOTFOUND;

    IF x.sum <= 600 
    THEN p := 0.09;
    ELSIF x.sum <= 900
    THEN p := 0.11;
    ELSIF x.sum <= 1200
    THEN p := 0.13;
    ELSE p := 0.15;
    END IF;

    UPDATE bonus
    SET tax = p * bonvalue
    WHERE empno = x.empno AND YEAR = x.year AND MONTH = x.month;
  END LOOP;
CLOSE cursor;
END;
/
SELECT * FROM bonus;


-- b)   с помощью курсорного цикла FOR;

DECLARE CURSOR cursor IS
SELECT psum_bonus.empno, psum_bonus.month, psum_bonus.year, sum(b.bonvalue) AS sum FROM bonus psum_bonus
JOIN bonus b ON (b.empno = psum_bonus.empno AND b.year = psum_bonus.year AND b.month <= psum_bonus.month)
GROUP BY psum_bonus.empno, psum_bonus.month, psum_bonus.year;

p REAL := 0;

BEGIN
  FOR x IN cursor LOOP
  
    IF x.sum <= 600 
    THEN p := 0.09;
    ELSIF x.sum <= 900
    THEN p := 0.11;
    ELSIF x.sum <= 1200
    THEN p := 0.13;
    ELSE p := 0.15;
    END IF;

    UPDATE bonus
    SET tax = p * bonvalue
    WHERE empno = x.empno AND YEAR = x.year AND MONTH = x.month;
  END LOOP;
END;
/
SELECT * FROM bonus;

-- c) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать налог. 

CREATE OR REPLACE PROCEDURE run(emp IN INTEGER) IS
    CURSOR cursor (emp INTEGER) IS
      
    SELECT psum_bonus.empno, psum_bonus.month, psum_bonus.year, sum(b.bonvalue) AS sum FROM bonus psum_bonus
    JOIN bonus b ON (b.empno = psum_bonus.empno AND b.year = psum_bonus.year AND b.month <= psum_bonus.month)
    GROUP BY psum_bonus.empno, psum_bonus.month, psum_bonus.year;
    
    x cursor % ROWTYPE;
    p REAL := 0;
    BEGIN OPEN cursor(emp);
    LOOP FETCH cursor INTO x;
      EXIT WHEN cursor % NOTFOUND;
        
        IF x.sum <= 600 
        THEN p := 0.09;
        ELSIF x.sum <= 900
        THEN p := 0.11;
        ELSIF x.sum <= 1200
        THEN p := 0.13;
        ELSE p := 0.15;
        END IF;
    
        UPDATE bonus
        SET tax = p * bonvalue
        WHERE empno = x.empno AND YEAR = x.year AND MONTH = x.month;
        
    END LOOP;
    CLOSE cursor;
END run;
/
CALL run(505);
SELECT * FROM bonus WHERE empno = 505;

--2.   Создайте процедуру, вычисления налога и вставки его в таблицу Bonus за всё время начислений для конкретного сотрудника. В качестве параметров передать проценты налога (до 600, от 601 до 900, от 901 до 1200, выше 1200) и номер сотрудника.
CREATE OR REPLACE PROCEDURE run(p1 IN REAL, p2 IN REAL, p3 IN REAL, p4 IN REAL, emp IN INTEGER) IS
    CURSOR cursor (emp INTEGER) IS
      
    SELECT psum_bonus.empno, psum_bonus.month, psum_bonus.year, sum(b.bonvalue) AS sum FROM bonus psum_bonus
    JOIN bonus b ON (b.empno = psum_bonus.empno AND b.year = psum_bonus.year AND b.month <= psum_bonus.month)
    GROUP BY psum_bonus.empno, psum_bonus.month, psum_bonus.year;
    
  x cursor % ROWTYPE;
  p REAL := 0;

  BEGIN OPEN cursor(emp);
    LOOP FETCH cursor INTO x;
      EXIT WHEN cursor % NOTFOUND;
      
        IF x.sum <= 600 
        THEN p := p1;
        ELSIF x.sum <= 900
        THEN p := p2;
        ELSIF x.sum <= 1200
        THEN p := p3;
        ELSE p := p4;
        END IF;
        
        UPDATE bonus
        SET tax = p * bonvalue
        WHERE empno = x.empno AND YEAR = x.year AND MONTH = x.month;
    END LOOP;
  CLOSE cursor;
END run;

/ 
CALL run(0.09, 0.11, 0.13, 0.15, 505);
SELECT * FROM bonus WHERE empno = 505;

--3.   Создайте функцию, вычисляющую суммарный налог на премию сотрудника за всё время начислений. В качестве параметров передать процент налога (до 600, от 601 до 900, от 901 до 1200, выше 1200) и номер сотрудника.
-- Возвращаемое значение – суммарный налог.

CREATE OR REPLACE FUNCTION calc(p1 IN REAL, p2 IN REAL, p3 IN REAL, p4 IN REAL, emp IN INTEGER) RETURN REAL IS
    CURSOR cursor (emp INTEGER) IS
      
    SELECT psum_bonus.empno, psum_bonus.month, psum_bonus.year, sum(b.bonvalue) AS sum FROM bonus psum_bonus
    JOIN bonus b ON (b.empno = psum_bonus.empno AND b.year = psum_bonus.year AND b.month <= psum_bonus.month)
    WHERE b.empno = emp
    GROUP BY psum_bonus.empno, psum_bonus.month, psum_bonus.year;
    
  x cursor % ROWTYPE;
  p REAL := 0;
  t REAL := 0;

  BEGIN OPEN cursor(emp);
    LOOP FETCH cursor INTO x;
      EXIT WHEN cursor % NOTFOUND;
      
        IF x.sum <= 600 
        THEN p := p1;
        ELSIF x.sum <= 900
        THEN p := p2;
        ELSIF x.sum <= 1200
        THEN p := p3;
        ELSE p := p4;
        END IF;
        
        t := t + p * x.sum;
        
    END LOOP;
  CLOSE cursor;
  RETURN t;
END calc;

/ 
SELECT calc(0.09, 0.11, 0.13, 0.15, 505) FROM dual;


  
    

