CREATE TABLE record (
	type character varying(255),
	id character varying(255),
	datadivider character varying(255) NOT NULL,
	record jsonb NOT NULL,
	PRIMARY KEY (type, id)
);

create table link (
	type character varying(255),
	id character varying(255),
	PRIMARY KEY (type, id),
	CONSTRAINT fk_torecord FOREIGN KEY(type, id) REFERENCES record(type, id) 
);

create table storageterm (
	type character varying(255),
	id character varying(255),
	value character varying(255),
	storagekey character varying(255),
	PRIMARY KEY (type, id, storagekey),
	CONSTRAINT fk_torecord FOREIGN KEY(type, id) REFERENCES record(type, id) 
);

--ALTER TABLE record OWNER TO systemone;