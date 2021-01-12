--Лабораторная выполняется в СУБД  Oracle. 
--Cкопируйте файл  EDU4.sql  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. 
--Таблица Emp имеет дополнительные столбцы mstat (семейное положение), Nchild (количество несовершеннолетних детей).  
--Произведите запуск SQLPlus, PLSQLDeveloper или другой системы работы с Oracle и соеденитесь с БД.  Запустите скрипты EDU4.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа 3, курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1, 2.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталог.

--1. Создайте пакет, включающий в свой состав процедуру ChildBonus и функцию EmpChildBonus. 
--Процедура ChildBonus должна вычислять ежегодную добавку к 
--зарплате сотрудников на детей за 2019 год и заносить её в виде дополнительной премии в первом месяце (январе) следующего 2020
--календарного года в поле Bonvalue таблицы Bonus. 
--В качестве параметров процедуре передаются проценты в зависимости от количества детей (см. правило начисления добавки).
--Функция EmpChildBonus должна вычислять ежегодную добавку за 2019 год на детей к  зарплате конкретного сотрудника 
--(номер сотрудника - параметр передаваемый функции) без занесения в таблицу.

--ПРАВИЛО ВЫЧИСЛЕНИЯ ДОБАВКИ

--Добавка к заработной плате на детей  вычисляется только для работавших полностью все последние  три месяца (октябрь, ноябрь и декабрь) 2019 году сотрудников по следующему правилу: 
--добавка равна X% от суммы должностного месячного оклада (поле minsalary таблицы job) по занимаемой в декабре 2019 года должности и всех начисленных 
--за 2019 год премий (поле bonvalue таблицы bonus), где:
--X% равны X1% , если сотрудник имеет одного ребёнка;
--X% равны X2% , если сотрудник имеет двух детей;
--X% равны X3% , если сотрудник имеет трёх и более детей.
--X1%<X2%<X3%  являются передаваемыми процедуре и функции параметрами. Кроме этого, функции в качестве параметра передаётся номер сотрудника (empno). 

CREATE OR REPLACE PACKAGE bonuses AS
    PROCEDURE ChildBonus(X1 IN REAL, X2 IN REAL, X3 IN REAL);
    FUNCTION EmpChildBonus(emps IN INTEGER, X1 IN REAL, X2 IN REAL, X3 IN REAL) RETURN REAL;
END bonuses;
/
CREATE OR REPLACE PACKAGE BODY bonuses AS
    PROCEDURE ChildBonus(X1 IN REAL, X2 IN REAL, X3 IN REAL) IS
        CURSOR ChildBonusCursor IS
            SELECT empnos, nvl(salary, 0) + nvl(bonusearnings, 0)
            FROM (SELECT career.empno                   AS empnos,
                         nvl(sum(nvl(minsalary, 0)), 0) AS salary
                  FROM career
                           JOIN job ON job.jobno = career.jobno
                  WHERE 
                      ((extract(YEAR FROM career.startdate) < 2019) OR
                      ((extract(YEAR FROM career.startdate) = 2019) AND
                      (extract(MONTH FROM career.startdate) >= 10)))
                        AND 
                        
                      ((career.enddate IS NULL) OR 
                      ((extract(YEAR FROM career.enddate) = 2019) AND 
                      (extract(MONTH FROM career.enddate) = 12)) OR
                      (extract(YEAR FROM career.enddate) >= 2020))
                  GROUP BY career.empno)
                     LEFT JOIN
                 (SELECT empno                         AS bonusempno,
                         nvl(sum(nvl(bonvalue, 0)), 0) AS bonusearnings
                  FROM bonus
                  WHERE bonus.year = 2019
                  GROUP BY empno) ON empnos = bonusempno;
        empl       INTEGER := 0;
        childs     INTEGER := 0;
        income     REAL    := 0;
        childbonus REAL    := 0;

    BEGIN
        OPEN ChildBonusCursor;
        LOOP
            FETCH ChildBonusCursor INTO empl, income;
            EXIT WHEN ChildBonusCursor % NOTFOUND;

            SELECT nchild
            INTO childs
            FROM emp
            WHERE empno = empl;

            IF (childs > 0) THEN
                IF childs = 1 THEN
                    childbonus := income * X1 / 100;
                ELSIF childs = 2 THEN
                    childbonus := income * X2 / 100;
                ELSIF childs > 2 THEN
                    childbonus := income * X3 / 100;
                END IF;
                
                INSERT INTO bonus
                VALUES (empl, 11, 2020, childbonus, NULL);
                commit;

            END IF;
        END LOOP;
        CLOSE ChildBonusCursor;
    END ChildBonus;

    FUNCTION EmpChildBonus(emps IN INTEGER, X1 IN REAL, X2 IN REAL, X3 IN REAL) RETURN REAL IS
        bonusincome REAL    := 0;
        salary      REAL    := 0;
        total       REAL    := 0;
        childs      INTEGER := 0;
        childbonus  REAL    := 0;

    BEGIN
        BEGIN
            SELECT nvl(sum(nvl(bonvalue, 0)), 0)
            INTO bonusincome
            FROM bonus
            WHERE empno = emps
              AND bonus.year = 2019
            GROUP BY empno;
        EXCEPTION
            WHEN no_data_found THEN bonusincome := 0;
        END;

        BEGIN
            SELECT nvl(sum(nvl(minsalary, 0)), 0)
            INTO salary
            FROM career
                     JOIN job ON job.jobno = career.jobno
            WHERE (career.empno = emps) AND
                  ((extract(YEAR FROM career.startdate) < 2019) OR
                  ((extract(YEAR FROM career.startdate) = 2019) AND
                  (extract(MONTH FROM career.startdate) >= 10)))
                    AND 
                    
                  ((career.enddate IS NULL) OR 
                  ((extract(YEAR FROM career.enddate) = 2019) AND 
                  (extract(MONTH FROM career.enddate) = 12)) OR
                  (extract(YEAR FROM career.enddate) >= 2020))
            GROUP BY career.empno;
        EXCEPTION
            WHEN no_data_found THEN salary := 0;
        END;

        BEGIN
            SELECT nchild
            INTO childs
            FROM emp
            WHERE empno = emps;
        EXCEPTION
            WHEN no_data_found THEN childs := 0;
        END;

        total := bonusincome + salary;

        IF childbonus = 1 THEN
            childbonus := total * X1 / 100;
        ELSIF childs = 2 THEN
            childbonus := total * X2 / 100;
        ELSIF childs > 2 THEN
            childbonus := total * X3 / 100;
        END IF;

        RETURN childbonus;
    END EmpChildBonus;
END bonuses;
/
SELECT * FROM bonus
WHERE year >= 2020 and month >= 11;
BEGIN
    bonuses.ChildBonus(5, 9, 13);
END;
/
SELECT * FROM bonus
WHERE year >= 2020 and month >= 11;

/
DECLARE
v REAL;
BEGIN
  v := bonuses.EmpChildBonus(102, 11, 21, 31);
  DBMS_OUTPUT.PUT_LINE(v);
END;

--2. Создайте триггер, который при добавлении или обновлении записи в таблице EMP 
-- должен отменять действие и сообщать об ошибке:
--a) если для сотрудника с семейным положением холост (s)  в столбце Nchild указывается не нулевое количество детей или NULL:;
--b) если для любого сотрудника указывается отрицательное количество детей или или большее пяти.
/
CREATE OR REPLACE TRIGGER trigger1
    BEFORE INSERT OR UPDATE
    ON emp
    FOR EACH ROW
BEGIN

    IF (:new.nchild IS NULL)
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'number of childs should be not null');
    END IF;
    IF (:new.nchild < 0 OR :new.nchild > 5)
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'number of childs should be nonnegative');
    END IF;
    IF (:new.mstat = 's' AND :new.nchild != 0)
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'number of childs for single should be zero');
    END IF;
end;
/

insert into emp values (123, 'A B', to_date('12.10.1979','dd-mm-yyyy'),'s',1);
