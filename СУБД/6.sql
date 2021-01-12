--Лабораторная выполняется в СУБД  Oracle. 
--Cкопируйте файл  EDU6.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. 
--База данных имеет дополнительную таблицу t_error.  
--Произведите запуск Oracle.  Запустите скрипты EDU6.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО Гулин Кирилл Иванович, группа 3, курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1a, 1b.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталоu.

--1a. Имеются PL_SQL-блоки, содержащий следующие операторы:
/*declare
     empnum integer; 
     begin
      insert into bonus values (505,15, 2018, 500, null);
end;*/

/*declare
     empnum integer; 
     begin
      insert into job values (1010, 'Accountant xxxxxxxxxx',5500);
end;*/

/*declare
     empnum integer; 
     begin
      select empno into empnum from emp where empno=505 or empno=403;
end;*/
--Оператор исполняемого раздела в каждом из блоков вызывает предопределённое исключение со своими предопределёнными
--кодом и сообщением. 
--Дополните блоки разделами обработки исключительных ситуаций. 
--Обработка каждой ситуации состоит в занесении в таблицу t_error предопределённых кода ошибки, 
--сообщения об ошибке и текущих даты и времени, когда ошибка произошла.

declare
    empnum INTEGER;
    err_num INTEGER;
    err_msg VARCHAR(100);
begin
    insert into bonus values (505, 15, 2018, 500, null);
EXCEPTION
    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        INSERT INTO t_error VALUES (err_num, err_msg, SYSDATE);
end;
/

declare
    empnum integer;
    err_num INTEGER;
    err_msg VARCHAR(100);
begin
    insert into job values (1010, 'Accountant xxxxxxxxxx', 5500);
    EXCEPTION
    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        INSERT INTO t_error VALUES (err_num, err_msg, SYSDATE);
end;
/

declare
    empnum integer;
    err_num INTEGER;
    err_msg VARCHAR(100);
begin
    select empno into empnum from emp where empno = 505 or empno = 403;
    EXCEPTION
    WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        INSERT INTO t_error VALUES (err_num, err_msg, SYSDATE);
end;
/

--1b. Создайте собственную исключительную ситуацию ex_one с кодом -16000 и сообщением 
--'premium more than possible by m for n months', где m - превышение премиального фонда при введении очередной записи
--в таблицу bonus для месяца n.
--Исключительная ситуация ex_one наступает при нарушении бизнес-правила: "Сумма всех премий (премии в столбце bonvalue), начисленных с начала 2020 года
--за n месяцев, не может быть больше 1000*n" 1<= n<=12. То есть, если премиальный фонд в 1000 денежных единиц полностью не
--израсходован в текущем месяце, то его остаток может быть израсходован в последующие месяцы, но без нарушения суммарного
--премиального фонда за каждые n месяцев. 
--Создайте собственную исключительную ситуацию ex_two с кодом -16001 и сообщением "the amount of bonuses in the n-th month is less than in the previous month",
--где n+1 номер месяца в первой записи вводимой в таблицу bonus для (n+1)-го месяца(как признак завершения записей для n-го месяца).
--Исключительная ситуация ex_two наступает, при нарушении бизнес-правила: "Сумма всех премий за n-ый месяц не может быть меньше, чем
--сумма всех премий за предыдущий месяц. Как уже указано выше, признак окончания начислений за n-ый месяц - появление первой записи с новым значением 
--номера месяца n+1 (доначисление премий за предыдущие месяцы не допускается). Для января исключительная ситуация не рассматривается.
--Рассматривается только 2020 года.
--Создайте блок с операторами, вызывающими нарушение бизнес-правил и обработку соответсвующих ситуаций.
--При наступлении пользовательской исключительной ситуации ex_two обработка состоит в занесении данных о ней 
--(аналогично разделу 1a) в таблицу t_error и отмене фиксации записи в таблице bonus (оператор rollback).    

declare
    err_num INTEGER;
    err_msg VARCHAR(100);
    sum_bon_value REAL := 0;
    diff REAL := 0;
    ex_one EXCEPTION;
    PRAGMA EXCEPTION_INIT ( ex_one, -20000);

begin
    INSERT INTO bonus values (205, 9, 2020, 12000, null);
    FOR i IN (SELECT MONTH, SUM(bonvalue) AS bonvalue
        FROM bonus
        WHERE YEAR = 2020
        GROUP BY MONTH
        ORDER BY MONTH)
        LOOP
            sum_bon_value := sum_bon_value + i.bonvalue;
            IF sum_bon_value > i.month * 1000 THEN
                diff := sum_bon_value - i.month * 1000;
                err_msg := 'premium more than possible by ' || diff || ' for ' || i.month || ' months ';
                RAISE_APPLICATION_ERROR(-20000, err_msg);
            end if;
        end loop;
    EXCEPTION WHEN ex_one THEN
        err_num := -16000;
        err_msg := SUBSTR(SQLERRM, 1, 100);
        INSERT INTO t_error VALUES (err_num, err_msg, SYSDATE);
end;
/

DECLARE
    last_month     INTEGER := -1;
    err_num        INTEGER;
    err_msg        VARCHAR(100);
    our_value      REAL    := 0;
    previous_value REAL    := 0;
    for_printing INTEGER := 0;
    ex_two EXCEPTION;
    PRAGMA EXCEPTION_INIT ( ex_two, -20001);
BEGIN
    INSERT INTO bonus values (205, 11, 2020, 14000, null);
    FOR i IN (SELECT MONTH, SUM(bonvalue) AS bonvalue
        FROM bonus
        WHERE YEAR = 2020
        GROUP BY MONTH
        ORDER BY MONTH)
        LOOP
                last_month := i.month;
        END LOOP;
    IF last_month >= 3 THEN
        FOR i IN (SELECT MONTH, SUM(bonvalue) AS bonvalue
        FROM bonus
        WHERE YEAR = 2020
        GROUP BY MONTH
        ORDER BY MONTH)
            LOOP
                IF i.month = last_month - 1 THEN
                    our_value := i.bonvalue;
                end if;
                IF i.month = last_month - 2 THEN
                    previous_value := i.bonvalue;
                end if;
            END LOOP;

        IF previous_value > our_value THEN
            for_printing := last_month - 1;
            RAISE_APPLICATION_ERROR(-20001, 'the amount of bonuses in the ' || for_printing ||
                                            '-th month is less than in the previous month');
        end if;
    end if;


EXCEPTION
    WHEN ex_two THEN err_num := -16001;
    err_msg := SUBSTR(SQLERRM, 1, 100);
    ROLLBACK;
    INSERT INTO t_error VALUES (err_num, err_msg, SYSDATE);
END ;

