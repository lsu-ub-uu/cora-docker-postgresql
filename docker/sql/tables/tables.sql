CREATE TABLE record (
	type character varying(255),
	id character varying(255),
	datadivider character varying(255) NOT NULL,
	data jsonb NOT NULL,
	PRIMARY KEY (type, id)
);

create table link (
	fromtype character varying(255),
	fromid character varying(255),
	totype character varying(255),
	toid character varying(255),
	PRIMARY KEY (fromtype, fromid, totype, toid),
	CONSTRAINT fk_torecord FOREIGN KEY(totype, toid) REFERENCES record(type, id) 
	CONSTRAINT fk_fromrecord FOREIGN KEY(fromtype, fromid) REFERENCES record(type, id) 
);

--Kontroller att id stämmer (id är id:et för record). Type saknas i javaklassen storageTerm, men behövs i db tabellen för att mappa med FK.
create table storageterm (
	id SERIAL,
	recordtype character varying(255),
	recordid character varying(255),
	storagetermid character varying(255),
	value character varying(255),
	storagekey character varying(255),
	PRIMARY KEY (id),
	CONSTRAINT fk_record FOREIGN KEY(recordtype, recordid) REFERENCES record(type, id) 
);

--ALTER TABLE record OWNER TO systemone;