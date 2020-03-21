\set ON_ERROR_STOP on
-- \set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


CALL cc2.theta_omega_calculations(:cited_1::bigint, :cited_2::bigint, :first_year::smallint);
-- DO
-- $blocks$
--
--     BEGIN
--         IF :first_year::smallint < 1998 THEN
--             CALL cc2.theta_omega_calculations(:cited_1::bigint, :cited_2::bigint, :first_year::smallint);
--         ELSE
--             RAISE NOTICE 'First cited year greater than 1997 running query on public.scopus_reference table';
--             CALL cc2.theta_omega_calculations_main_table(:cited_1::bigint, :cited_2::bigint, :first_year::smallint);
--         END IF;
--
--
--     END
-- $blocks$;