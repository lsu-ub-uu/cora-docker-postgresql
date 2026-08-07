DROP MATERIALIZED VIEW IF EXISTS urnnbn_recent_records;

CREATE MATERIALIZED VIEW urnnbn_recent_records as
	SELECT
		record_id->>'value' AS id,
		record_urnnbn->>'value' AS urnnbn,
		record_visibility->>'value' AS visibility, -- Maybe we do not need this line, we do not need the information.
		(record_tsCreated->>'value')::timestamp AS ts_created
	FROM
		record,
		LATERAL jsonb_array_elements(data->'children') AS record_recordInfo,
		LATERAL jsonb_array_elements(record_recordInfo->'children') AS record_id,
		LATERAL jsonb_array_elements(record_recordInfo->'children') AS record_urnnbn,
		LATERAL jsonb_array_elements(record_recordInfo->'children') AS record_visibility,
		LATERAL jsonb_array_elements(record_recordInfo->'children') AS record_tsCreated
	WHERE
		type = 'diva-output'
		AND record_recordInfo->>'name' = 'recordInfo'
		AND record_id->>'name' = 'id'
		AND record_urnnbn->>'name' = 'urn'
		AND record_visibility->>'name' = 'visibility' -- Maybe we do not need this line
		AND record_visibility->>'value' = 'published'
		AND record_tsCreated->>'name' = 'tsCreated'
	ORDER BY ts_created DESC
	LIMIT 10000;

--Need it in order to use concurrently while refreshing the view
CREATE UNIQUE INDEX idx_urnnbn_recent_records_id ON urnnbn_recent_records (id);