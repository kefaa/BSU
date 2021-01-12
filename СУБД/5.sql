--Лабораторная выполняется в СУБД  Oracle. 
--Cкопируйте файл  EDU5.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. 
--Произведите запуск Oracle.  Запустите скрипты EDU5.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа 3, курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1-6.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталог.                  .

--1. Создайте триггер, который при обновлении записи в таблице EMP 
-- должен отменять действие и сообщать об ошибке
-- a) если семейное положение сотрудника разведен/разведена (d) или женат/замужем (m) изменяется на семейное положение холост/одинокая (s); 
/
CREATE OR REPLACE TRIGGER trigger1
    BEFORE INSERT OR UPDATE
    ON emp
    FOR EACH ROW
BEGIN

    IF ((:old.mstat = 'd' AND :new.mstat = 's') OR (:old.mstat = 'm' and :new.mstat = 's'))
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'd->s or m->s is forbidden!');
    END IF;
end;

--2. Создайте триггер, который при добавлении или обновлении записи в таблице EMP должен:
-- a) осуществлять вставку данного равного 0,
-- если для сотрудника с семейным положением холост/одинокая (s)  в столбце Nchild указывается данное, отличное от 0 
-- или если для любого сотрудника указывается отрицательное количество детей.
/
CREATE OR REPLACE TRIGGER trigger2
    BEFORE INSERT OR UPDATE
    ON emp
    FOR EACH ROW
BEGIN
    IF (:new.nchild < 0)
    THEN :new.nchild := 0;
    END IF;

    IF (:new.mstat = 's' AND :new.nchild != 0)
    THEN
        :new.nchild := 0;
    END IF;
end;

--3. Создайте триггер, который при обновлении записи в таблице EMP 
-- должен отменять действие и сообщать об ошибке, если для сотрудников, находящихся в браке (m) в столбце Nchild 
-- новое значение увеличивается (рождение ребёнка) или уменьшается (достижение ребёнком совершеннолетия) более чем на 1.
/
CREATE OR REPLACE TRIGGER trigger3
BEFORE UPDATE ON emp FOR EACH ROW
BEGIN
  IF (:new.mstat = 'm' AND ((:new.nchild > :old.nchild + 1) OR (:old.nchild > :new.nchild + 1)))
  THEN RAISE_APPLICATION_ERROR(-20001, 'number of changes of childs should be <= 1');
  END IF;
END;


--4. Создать триггер, который отменяет любые действия (начисление, изменение, удаление) с премиями (таблица bonus) 
-- неработающих в настоящий момент в организации сотрудников и сообщает об ошибке.
/
CREATE OR REPLACE TRIGGER trigger4
    BEFORE INSERT OR UPDATE OR DELETE
    ON bonus
    FOR EACH ROW
DECLARE
    cnt INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO cnt
    FROM career
    WHERE empno = :new.empno
      and enddate IS NULL;
    IF cnt = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'this empl doesnt work now');
    END IF;
END;

--5. Создайте триггер, который после выполнения действия (вставка, обновление, удаление) с таблицей job
-- создаёт запись в таблице temp_table, с указанием названия действия (delete, update, insert) активизирующего триггер.
/
CREATE OR REPLACE TRIGGER trigger5
    BEFORE INSERT OR UPDATE OR DELETE
    ON job
    FOR EACH ROW
BEGIN
    IF UPDATING
    THEN
        INSERT INTO temp_table VALUES ('update');
    END IF;

    IF INSERTING
    THEN
        INSERT INTO temp_table VALUES ('insert');
    END IF;

    IF DELETING
    THEN
        INSERT INTO temp_table VALUES ('delete');
    END IF;
END;


--6. Создайте триггер, который до выполнения обновления в таблице job столбца minsalary отменяет действие, сообщает об ошибке
-- и создаёт запись в таблице temp_table c указанием "более 10%",
-- если должностной оклад изменяется более чем 10% (увеличивается или уменьшается). 
/
CREATE OR REPLACE
    PROCEDURE log_error_p
    AS
         PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
         INSERT INTO temp_table VALUES ('Более 10%');
         COMMIT;
    END;
/
CREATE OR REPLACE TRIGGER trigger6
    BEFORE UPDATE
    ON job
    FOR EACH ROW
BEGIN
    IF ((:new.minsalary < 0.9 * :old.minsalary) OR (:old.minsalary < 0.9 * :new.minsalary))
    THEN
        log_error_p();
        RAISE_APPLICATION_ERROR(-20001, 'Change of minsalary is greater 10%');
    END IF;
END;


