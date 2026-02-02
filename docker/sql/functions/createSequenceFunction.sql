CREATE OR REPLACE FUNCTION cora_create_sequence(
seq_name text,
min_value bigint,
start_with bigint
)
RETURNS void AS $$
BEGIN
	
IF seq_name !~ '^[a-zA-Z0-9_\-]*$' THEN
RAISE EXCEPTION 'Invalid sequence name: %', seq_name;
END IF;

IF start_with < min_value THEN
RAISE EXCEPTION 'START WITH (%) must be >= MINVALUE (%)',
start_with, min_value;
END IF;

seq_name := lower(seq_name);

EXECUTE format(
'CREATE SEQUENCE %I MINVALUE %s START WITH %s',
seq_name,
min_value,
start_with
);
END;
$$ LANGUAGE plpgsql;