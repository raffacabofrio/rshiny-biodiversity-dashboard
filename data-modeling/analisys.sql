select count(*) from countries
-- 224 ok

select count(*) from species
-- 56k - may cause problens. :/

-- TOP 3 COUNTRIES
-- 48 - "The Netherlands" >> 95k
-- 50 - "France" .........>> 1.2k
-- 24 - "Spain" ..........>> 0.7k
select country_id, count(*) as total from ocurrences_100k
group by country_id
order by total desc

-- TOP 3 SPECIES
-- 511  - "Brimstone" ..............>> 1.9k
-- 3425 - "Common Buzzard" .........>> 1.5k
-- 171  - "Black-tailed Godwit" ....>> 1.4k
select specie_id, count(*) as total from ocurrences_100k
group by specie_id
order by total desc

select * from countries where id = 16  order by country

select * from ocurrences where country_id = 16 -- brazil



select count(*) from species where id in (511, 3425, 171)

select 
	*, 
	scientificname || 
	CASE 
		WHEN vernacularname is not null THEN ' ( ' || vernacularname || ' ) ' 
		ELSE ''
	END as name  
from species 
-- where 
	-- vernacularname like '%ssdsd''sdas%' OR
	-- scientificname like '%savana%'
	-- id = 3116
-- order by vernacularname
limit 100

select * from species limit 10

-- LOCALITY
-- BRAZIL: estado
-- ESPANHA: cidade

select count(*) from ocurrences_100k where stateprovince is null
-- countryCode is null ..>> 0
-- locality is null .....>> 0 (mais confiável)
-- stateprovince is null >> 5k

select distinct "individualCount" from ocurrences_100k


select "longitudeDecimal", latitudedecimal, count from ocurrences_by_locality
where country_id = 48 and specie_id = 511
order by count desc
-- 36k 
-- 522 apenas 1 espécie (suave)


select "eventDate", "count" from ocurrences_by_date
where country_id = 48
order by "eventDate"
-- antes  >> 20k - agrupado por AAA-MM-DD
-- depois >> 11k - agrupado por AAA-MM

select min("eventDate"), max("eventDate") from ocurrences_by_date

