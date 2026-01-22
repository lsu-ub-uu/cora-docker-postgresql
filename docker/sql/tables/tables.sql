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
	CONSTRAINT fk_fromrecord FOREIGN KEY(fromtype, fromid) REFERENCES record(type, id) 
);

create table storageterm (
	id SERIAL,
	recordtype character varying(255),
	recordid character varying(255),
	storagetermid character varying(255),
	value character varying(5000),
	storagekey character varying(255),
	PRIMARY KEY (id),
	CONSTRAINT fk_record FOREIGN KEY(recordtype, recordid) REFERENCES record(type, id) 
);

create view recordstorageterm as select r.*, s.storagetermid, s.storagekey, s.value  
from record r left join storageterm s on r."type" =s.recordtype and r.id =s.recordid ;
