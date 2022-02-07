-- --------------------------------------------------------------
-- OCURRENCES ( raw data )

CREATE TABLE public.ocurrences
(
    id character varying(128) PRIMARY KEY,
    "occurrenceID" character varying(128),
	catalogNumber character varying(128),
	basisOfRecord character varying(128),
	collectionCode character varying(128),
	scientificName character varying(128),
	taxonRank character varying(128),
	kingdom character varying(128),
	family character varying(128),
	higherClassification character varying(128),
	vernacularName character varying(128),
	previousIdentifications character varying(128),
    "individualCount" integer,
	lifeStage character varying(128),
	sex character varying(128),
    "longitudeDecimal" double precision,
	latitudeDecimal double precision,
	geodeticDatum character varying(128),
	dataGeneralizations character varying(128),
	coordinateUncertaintyInMeters integer,
	continent character varying(128),
	country character varying(128),
	countryCode character varying(128),
	stateProvince character varying(128),
	locality character varying(128),
	habitat character varying(128),
	recordedBy character varying(128),
	eventID character varying(128),
    "eventDate" date,
    "eventTime" time without time zone,
	samplingProtocol character varying(128),
	behavior character varying(128),
	associatedTaxa character varying(128),
	"references" character varying(128),
	rightsHolder character varying(128),
	license character varying(128),
    modified date
);

-- --------------------------------------------------------------
-- COUNTRIES

CREATE TABLE public.countries
(
    id serial primary key,
    continent character varying(128),
	country character varying(128),
	countryCode character varying(128)

);

insert into countries (continent, country, countryCode)
select distinct continent, country, countryCode from ocurrences_100k


-- --------------------------------------------------------------
-- SPECIES

CREATE TABLE public.species
(
    id serial primary key,
	scientificName character varying(128),
	taxonRank character varying(128),
	kingdom character varying(128),
	family character varying(128),
	higherClassification character varying(128),
	vernacularName character varying(128)
);

insert into species (scientificName, taxonRank, kingdom, family, higherClassification, vernacularName)
select distinct scientificName, taxonRank, kingdom, family, higherClassification, vernacularName from ocurrences_100k

-- --------------------------------------------------------------
-- NORMALIZING DATA

ALTER TABLE IF EXISTS public.ocurrences_100k
    ADD COLUMN country_id integer;

ALTER TABLE IF EXISTS public.ocurrences_100k
    ADD COLUMN specie_id integer;

UPDATE ocurrences_100k o
	SET country_id = c.id
FROM countries c
where o.countryCode = c.countryCode

UPDATE ocurrences_100k o
	SET specie_id = s.id
FROM species s
where o.scientificname = s.scientificname


-- --------------------------------------------------------------
-- OCURRENCES BY LOCALITY

drop table ocurrences_by_locality

CREATE TABLE public.ocurrences_by_locality
(
    id serial primary key,
	country_id INTEGER,
	specie_id INTEGER,
	"longitudeDecimal" double precision,
	latitudeDecimal double precision,
	count INTEGER
);



insert into ocurrences_by_locality(country_id, specie_id, "longitudeDecimal", latitudeDecimal, count)
select 
	country_id, specie_id,
	ROUND(ROUND("longitudeDecimal"::numeric * 2, 1) /2, 2) as "longitudeDecimal2",
	ROUND(latitudeDecimal::numeric, 1) as latitudeDecimal2,
	SUM("individualCount") as "individualCount"
from ocurrences_100k
group by country_id, specie_id, "longitudeDecimal2", latitudeDecimal2

CREATE INDEX "country_specie_localitie_IDX"
    ON public.ocurrences_by_locality USING btree
    (country_id ASC NULLS LAST, specie_id ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX "country_specie_localitie_IDX2"
    ON public.ocurrences_by_locality USING btree
    (country_id ASC NULLS LAST)
    TABLESPACE pg_default;


-- --------------------------------------------------------------
-- OCURRENCES BY DATE

drop table ocurrences_by_date

CREATE TABLE public.ocurrences_by_date
(
    id serial primary key,
	country_id INTEGER,
	specie_id INTEGER,
	"eventDate" date,
	count INTEGER
);

insert into ocurrences_by_date(country_id, specie_id, "eventDate", count)
select 
	country_id, 
	specie_id,
	TO_CHAR("eventDate", 'yyyy-mm-01')::date as "eventDate2",
	SUM("individualCount") 
from ocurrences_100k 
group by country_id, specie_id, "eventDate2"

CREATE INDEX "country_specie_IDX"
    ON public.ocurrences_by_date USING btree
    (country_id ASC NULLS LAST, specie_id ASC NULLS LAST)
    TABLESPACE pg_default;