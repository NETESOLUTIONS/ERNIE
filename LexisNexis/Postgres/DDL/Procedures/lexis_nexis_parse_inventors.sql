/*
  Author: VJ Davey
  This script is part of a set that defines several procedures for XMLTABLE based parsing of LexisNexis XML patent files.
  This section covers inventor data.
*/

\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


-- Inventors parsing
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_inventors(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_inventors(country_code,doc_number,kind_code,inventor_sequence,
                                language,name,address_1,address_2,address_3,address_4,address_5,
                                mailcode,pobox,room,address_floor,building,street,city,county,
                                postcode,country)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.inventor_sequence,
          xmltable.language,
          xmltable.name,
          xmltable.address_1,
          xmltable.address_2,
          xmltable.address_3,
          xmltable.address_4,
          xmltable.address_5,
          xmltable.mailcode,
          xmltable.pobox,
          xmltable.room,
          xmltable.address_floor,
          xmltable.building,
          xmltable.street,
          xmltable.city,
          xmltable.county,
          xmltable.postcode,
          xmltable.country
     FROM
     XMLTABLE('//bibliographic-data/parties/inventors/inventor[not(@data-format)]' PASSING input_xml
              COLUMNS
                --below come from higher level nodes
                country_code TEXT PATH '//bibliographic-data/publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '//bibliographic-data/publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '//bibliographic-data/publication-reference/document-id/kind' NOT NULL,

                --below are attributes
                inventor_sequence INT PATH '@sequence' NOT NULL,
                language TEXT PATH 'addressbook[1]/@lang',
                --Below are sub elements
                name TEXT PATH 'addressbook[1]/name',
                address_1 TEXT PATH 'addressbook[1]/address/address-1',
                address_2 TEXT PATH 'addressbook[1]/address/address-2',
                address_3 TEXT PATH 'addressbook[1]/address/address-3',
                address_4 TEXT PATH 'addressbook[1]/address/address-4',
                address_5 TEXT PATH 'addressbook[1]/address/address-5',
                mailcode TEXT PATH 'addressbook[1]/address/mailcode',
                pobox TEXT PATH 'addressbook[1]/address/pobox',
                room TEXT PATH 'addressbook[1]/address/room',
                address_floor TEXT PATH 'addressbook[1]/address/address-floor',
                building TEXT PATH 'addressbook[1]/address/building',
                street TEXT PATH 'addressbook[1]/address/street',
                city TEXT PATH 'addressbook[1]/address/city',
                county TEXT PATH 'addressbook[1]/address/county',
                state TEXT PATH 'addressbook[1]/address/state',
                postcode TEXT PATH 'addressbook[1]/address/postcode',
                country TEXT PATH 'addressbook[1]/address/country'
              )
    ON CONFLICT (country_code,doc_number,kind_code,inventor_sequence)
    DO UPDATE SET language=excluded.language,name=excluded.name,address_1=excluded.address_1,address_2=excluded.address_2,address_3=excluded.address_3,
    address_4=excluded.address_4,address_5=excluded.address_5,mailcode=excluded.mailcode,pobox=excluded.pobox,room=excluded.room,
    address_floor=excluded.address_floor,building=excluded.building,street=excluded.street,city=excluded.city,county=excluded.county,
    postcode=excluded.postcode,country=excluded.country,last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;
