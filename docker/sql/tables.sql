CREATE TABLE record_post (
	type character varying(255) NOT NULL PRIMARY KEY,
	id character varying(255) NOT NULL PRIMARY KEY,
	datadivider character varying(255) NOT NULL,
	record jsonb NOT NULL
);

CREATE TABLE storage_term (
	recordtype character varying(255) NOT NULL PRIMARY KEY,
	recordid character varying(255) NOT NULL PRIMARY KEY, 
	storagekey character varying(255) NOT NULL,
	collectermid character varying(255) NOT NULL,
	collectermvalue character varying(255) NOT NULL
);

CREATE TABLE linklist (
	recordtype character varying(255) NOT NULL PRIMARY KEY,
	recordid character varying(255) NOT NULL PRIMARY KEY, 
	linktotype character varying(255) NOT NULL PRIMARY KEY,
	linkyoid character varying(255) NOT NULL PRIMARY KEY 
);


--ALTER TABLE record OWNER TO cora;
