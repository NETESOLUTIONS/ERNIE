-- Next sequence value
SELECT nextval(:'seq');

-- Last sequence value in the current session
SELECT currval(:'seq');

-- Set the counter (as if the last) value
SELECT setval(:'seq', :counter_value);

-- Get name of the sequence that a serial or identity column uses
SELECT pg_get_serial_sequence(:'table', :'column');