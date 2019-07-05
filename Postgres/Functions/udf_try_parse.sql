/*
Title: User Defined Function , procedural
Author: Djamil Lakhdar-Hamina
Date: 06/05/2019

This is a user-defined function which replicates MySqls try_parse function.
It essentially combines three elements into a date-format YYYY-MM-DD. However,
unlike the make_date, when year = 0000 or month=00 or day=00 the function
makes the whole format equal NULL on the first, makes month=01
on the second, and makes day=01 on the last condition.

*/


DROP FUNCTION IF EXISTS try_parse() ;
CREATE OR REPLACE FUNCTION try_parse(year_arg int, month_arg int, day_arg int)
RETURNS date AS $$
DECLARE date_result date default null;
BEGIN
    BEGIN
    date_result := make_date(year_arg,coalesce(nullif(month_arg, 0), 1), coalesce(nullif(day_arg, 0), 1));
    EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
    END;
RETURN date_result;
END;
$$ LANGUAGE plpgsql;
