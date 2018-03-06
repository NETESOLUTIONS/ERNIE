DROP TABLE IF EXISTS msids;
CREATE TABLE msids AS
SELECT source_id FROM wos_references
WHERE source_id NOT IN (SELECT SOURCE_ID FROM wos_publications);
