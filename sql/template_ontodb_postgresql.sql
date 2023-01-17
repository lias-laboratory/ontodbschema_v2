DROP TABLE IF EXISTS mm_datatype CASCADE;
DROP TABLE IF EXISTS mm_entity CASCADE;
DROP TABLE IF EXISTS mm_attribute CASCADE;
DROP TABLE IF EXISTS m_datatype CASCADE;
DROP TABLE IF EXISTS m_class CASCADE;
DROP TABLE IF EXISTS m_property CASCADE;
DROP TABLE IF EXISTS languages CASCADE;
DROP TABLE IF EXISTS metadata CASCADE;

DROP SEQUENCE IF EXISTS mm_rid_seq CASCADE;
DROP SEQUENCE IF EXISTS m_rid_seq CASCADE;
DROP SEQUENCE IF EXISTS i_rid_seq CASCADE;
DROP SEQUENCE IF EXISTS l_rid_seq CASCADE;
DROP SEQUENCE IF EXISTS a_rid_seq CASCADE;

CREATE SEQUENCE m_rid_seq
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    START 100
    CACHE 1;

CREATE SEQUENCE mm_rid_seq
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    START 100
    CACHE 1;

CREATE SEQUENCE i_rid_seq
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    START 1
    CACHE 1;
  
CREATE SEQUENCE l_rid_seq
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    START 1
    CACHE 1;
  
CREATE SEQUENCE a_rid_seq
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    START 1
    CACHE 1;

-- Metameta model

CREATE TABLE mm_entity (
    rid bigint NOT NULL DEFAULT nextval('mm_rid_seq'),
    name character varying(255) NOT NULL,
    package character varying(255),
    mappedtablename character varying(255) NOT NULL,
    ismetametamodel boolean DEFAULT false,
    iscore boolean DEFAULT false,
    attributes bigint[],
    superentity bigint,  
CONSTRAINT constraint_mm_entity_superentity FOREIGN KEY (superentity) REFERENCES mm_entity (rid) MATCH SIMPLE,
CONSTRAINT constraint_mm_entity_name UNIQUE (name),
CONSTRAINT constraint_mm_entity_pk PRIMARY KEY (rid)
);

CREATE TABLE mm_datatype (
    rid bigint NOT NULL DEFAULT nextval('mm_rid_seq'),
    dtype character varying(40) NOT NULL,
    onclass bigint,
    collectiontype bigint,
    ismanytomany boolean,
    reverseattribute bigint,
    issimpletype boolean DEFAULT false,
    CONSTRAINT constraint_mm_datatype_onclass FOREIGN KEY (onclass) REFERENCES mm_entity (rid) MATCH SIMPLE,
    CONSTRAINT constraint_mm_datatype_collectiontype FOREIGN KEY (collectiontype) REFERENCES mm_datatype (rid) MATCH SIMPLE,
    CONSTRAINT constraint_mm_datatype_pk PRIMARY KEY (rid)
);

CREATE TABLE mm_attribute (
    rid bigint NOT NULL DEFAULT nextval('mm_rid_seq'),
    name character varying(255),
    scope bigint NOT NULL,
    range bigint NOT NULL,
    isoptional boolean DEFAULT true,
    iscore boolean DEFAULT false,
    CONSTRAINT constraint_mm_attribute_scope FOREIGN KEY (scope) REFERENCES mm_entity (rid) MATCH SIMPLE,
    CONSTRAINT constraint_mm_attribute_range FOREIGN KEY (range) REFERENCES mm_datatype (rid) MATCH SIMPLE,
    CONSTRAINT constraint_mm_attribute_pk PRIMARY KEY (rid)
);
ALTER TABLE mm_datatype ADD CONSTRAINT constraint_mm_datatype_reverseattribute FOREIGN KEY (reverseattribute) REFERENCES mm_attribute (rid) MATCH SIMPLE;


insert into mm_entity (rid, name, mappedtablename, iscore) values (28, 'boolean', 'm_datatype', true); 
insert into mm_entity (rid, name, mappedtablename, iscore) values (29, 'int', 'm_datatype', true);
insert into mm_entity (rid, name, mappedtablename, iscore) values (30, 'real', 'm_datatype', true);
insert into mm_entity (rid, name, mappedtablename, iscore) values (31, 'string', 'm_datatype', true);
insert into mm_entity (rid, name, mappedtablename, iscore) values (32, 'multistring', 'm_datatype', true);
insert into mm_entity (rid, name, mappedtablename, iscore, superentity) values (33, 'uritype', 'm_datatype', true, 31);
insert into mm_entity (rid, name, mappedtablename, iscore, superentity) values (63, 'enum', 'm_datatype', true, 31);  
insert into mm_entity (rid, name, mappedtablename, iscore, superentity) values (64, 'counttype', 'm_datatype', true, 29);
insert into mm_entity (rid, name, mappedtablename, iscore) values (65, 'array', 'm_datatype', true);  
insert into mm_entity (rid, name, mappedtablename, iscore) values (66, 'ref', 'm_datatype', true);  

insert into mm_datatype (rid, dtype, isSimpleType) values (1, 'boolean', true);
insert into mm_datatype (rid, dtype, isSimpleType) values (2, 'int', true);
insert into mm_datatype (rid, dtype, isSimpleType) values (3, 'real', true);
insert into mm_datatype (rid, dtype, isSimpleType) values (4, 'string', true);
insert into mm_datatype (rid, dtype, isSimpleType) values (5, 'multistring', true);

insert into mm_entity (rid, name, mappedtablename, ismetametamodel) values (6, 'mmentity', 'mm_entity', true);  
insert into mm_entity (rid, name, mappedtablename, ismetametamodel) values (7, 'mmattribute', 'mm_attribute', true);
insert into mm_entity (rid, name, mappedtablename, ismetametamodel) values (8, 'mmdatatype', 'mm_datatype', true);  


-- Meta model

create table m_class (
    rid bigint NOT NULL DEFAULT nextval('m_rid_seq'),
    dtype character varying(40) NOT NULL,
    code character varying(255) NOT NULL,
    name_fr character varying(255),
    name_en character varying(255),
    definition_fr character varying(255),
    definition_en character varying(255),
    isextension boolean DEFAULT false,
    directproperties bigint[],
    usedproperties bigint[],
    superclass bigint,
    package character varying(255),
    CONSTRAINT constraint_m_class_superclass FOREIGN KEY (superclass) REFERENCES m_class (rid) MATCH SIMPLE,
    CONSTRAINT constraint_m_class_pk PRIMARY KEY (rid)
);

CREATE TABLE m_datatype (
    rid bigint NOT NULL DEFAULT nextval('m_rid_seq'),
    dtype character varying(40) NOT NULL,
    onclass bigint, -- reference of class
    collectiontype bigint, -- type of collection
    issimpletype boolean,
    enumvalues character varying(255)[],
    CONSTRAINT constraint_m_datatype_onclass FOREIGN KEY (onclass) REFERENCES m_class (rid) MATCH SIMPLE,
    CONSTRAINT constraint_m_datatype_collectiontype FOREIGN KEY (collectiontype) REFERENCES m_datatype (rid) MATCH SIMPLE,
    CONSTRAINT constraint_m_datatype_pk PRIMARY KEY (rid)
);

create table m_property (
    rid bigint NOT NULL DEFAULT nextval('m_rid_seq'),
    dtype character varying(40) NOT NULL,
    code character varying(255) NOT NULL,
    name_fr character varying(255),
    name_en character varying(255),
    definition_fr character varying(255),
    definition_en character varying(255),
    scope bigint,
    range bigint,
    ismandatory boolean,
    isvisible boolean,
    CONSTRAINT constraint_m_property_scope FOREIGN KEY (scope) REFERENCES m_class (rid) MATCH SIMPLE,
    CONSTRAINT constraint_m_property_range FOREIGN KEY (range) REFERENCES m_datatype (rid) MATCH SIMPLE,
    CONSTRAINT constraint_m_property_pk PRIMARY KEY (rid)
);


insert into m_datatype (rid, dtype, isSimpleType) values (1, 'boolean', true);
insert into m_datatype (rid, dtype, isSimpleType) values (2, 'int', true);
insert into m_datatype (rid, dtype, isSimpleType) values (3, 'real', true);
insert into m_datatype (rid, dtype, isSimpleType) values (4, 'string', true);
insert into m_datatype (rid, dtype, isSimpleType) values (5, 'multistring', true);
insert into m_datatype (rid, dtype, isSimpleType) values (6, 'uritype', true);

insert into mm_entity (rid, name, mappedtablename, iscore) values (9, 'class', 'm_class', true);
insert into mm_attribute (rid, name, scope, range, iscore) values (30, 'rid', 9, 2, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (10, 'code', 9, 4, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (24, 'dtype', 9, 4, true);  
insert into mm_attribute (rid, name, scope, range, iscore) values (38, 'package', 9, 4, true);    
insert into mm_attribute (rid, name, scope, range, iscore) values (40, 'name', 9, 5, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (52, 'definition', 9, 5, true);
insert into mm_datatype (rid, dtype, onclass) values (34, 'ref', 9); 
insert into mm_attribute (rid, name, scope, range, iscore) values (35, 'superclass', 9, 34, true);  

insert into mm_entity (rid, name, mappedtablename, iscore) values (11, 'property', 'm_property', true);
insert into mm_attribute (rid, name, scope, range, iscore) values (31, 'rid', 11, 2, true);  
insert into mm_attribute (rid, name, scope, range, iscore) values (16, 'code', 11, 4, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (25, 'dtype', 11, 4, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (50, 'name', 11, 5, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (51, 'definition', 11, 5, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (53, 'ismandatory', 11, 1, true);
insert into mm_datatype (rid, dtype, onclass) values (18, 'ref', 9); 
insert into mm_attribute (rid, name, scope, range, isoptional, iscore) values (17, 'scope', 11, 18, false, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (67, 'isvisible', 11, 1, true);

insert into mm_entity (rid, name, mappedtablename, iscore) values (15, 'datatype', 'm_datatype', true);
insert into mm_attribute (rid, name, scope, range, iscore) values (32, 'rid', 15, 2, true);
insert into mm_datatype (rid, dtype, collectiontype, ismanytomany) values (55, 'array', 4, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (56, 'enumvalues', 15, 55, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (57, 'dtype', 15, 4, true);
insert into mm_datatype (rid, dtype, onclass) values (58, 'ref', 9);
insert into mm_attribute (rid, name, scope, range, iscore) values (59, 'onclass', 15, 58, true); 
insert into mm_datatype (rid, dtype, onclass) values (60, 'ref', 15);
insert into mm_datatype (rid, dtype, collectiontype, ismanytomany) values (61, 'array', 60, true);  
insert into mm_attribute (rid, name, scope, range, iscore) values (62, 'collectiontype', 15, 61, true);

insert into mm_datatype (rid, dtype, onclass) values (20, 'ref', 15); 
insert into mm_attribute (rid, name, scope, range, isoptional, iscore) values (19, 'range', 11, 20, false, true);
insert into mm_datatype (rid, dtype, onclass) values (14, 'ref', 11);   
insert into mm_datatype (rid, dtype, collectiontype, ismanytomany, reverseattribute) values (13, 'array', 14, false, 17);
insert into mm_attribute (rid, name, scope, range, iscore) values (12, 'directproperties', 9, 13, true);
insert into mm_datatype (rid, dtype, onclass) values (23, 'ref', 11); 
insert into mm_datatype (rid, dtype, collectiontype, ismanytomany) values (22, 'array', 23, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (21, 'usedproperties', 9, 22, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (26, 'isextension', 9, 1, true);  

insert into mm_entity (rid, name, mappedtablename, iscore) values (27, 'staticclass', 'm_class', true);
insert into mm_attribute (rid, name, scope, range, iscore) values (33, 'rid', 27, 2, true);  
insert into mm_attribute (rid, name, scope, range, iscore) values (28, 'code', 27, 4, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (29, 'dtype', 27, 4, true);
insert into mm_datatype (rid, dtype, onclass) values (36, 'ref', 27); 
insert into mm_attribute (rid, name, scope, range, iscore) values (37, 'superclass', 27, 36, true);  
insert into mm_attribute (rid, name, scope, range, iscore) values (39, 'package', 27, 4, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (49, 'name', 27, 5, true);
insert into mm_attribute (rid, name, scope, range, iscore) values (54, 'definition', 27, 5, true);

insert into mm_attribute (rid, name, scope, range, iscore) values (41, 'rid', 6, 4, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (42, 'name', 6, 2, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (43, 'package', 6, 4, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (44, 'mappedtablename', 6, 4, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (45, 'ismetametamodel', 6, 1, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (46, 'iscore', 6, 1, true); 
insert into mm_datatype (rid, dtype, onclass) values (37, 'ref', 7); 
insert into mm_datatype (rid, dtype, collectiontype, ismanytomany) values (38, 'array', 37, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (47, 'attributes', 6, 4, true); 
insert into mm_attribute (rid, name, scope, range, iscore) values (48, 'superentity', 6, 4, true); 


-- Languages
create table languages (
    rid bigint NOT NULL DEFAULT nextval('l_rid_seq'),
    name character varying(40) NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255),
    CONSTRAINT constraint_languages_pk PRIMARY KEY (rid)
);
insert into languages (name, code) values ('Français', 'fr');
insert into languages (name, code) values ('English', 'en');


-- Metadata MariusQL
create table metadata (
    rid bigint NOT NULL DEFAULT nextval('a_rid_seq'),
    metaname character varying(40) NOT NULL,
    metavalue character varying(255),
    CONSTRAINT constraint_about_pk PRIMARY KEY (rid)
);
insert into metadata (metaname, metavalue) values ('version', '0.5');

update mm_entity set attributes = '{10,12,21,24,26,30,35,38,40,52}' where  rid = 9;
update mm_entity set attributes = '{16,17,19,25,31,50,51,53,67}' where rid = 11;
update mm_entity set attributes = '{33,28,29,36,37,39,49,54}' where rid = 27;
update mm_entity set attributes = '{41,42,43,44,45,46,47,48}' where rid = 6;
update mm_entity set attributes = '{32,56,57,59,62}' where rid = 15;
