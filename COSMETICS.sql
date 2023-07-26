------------------------CREATING TABLE FOR IMPORT------------------------------------------
create table chemicals_in_cosmetics
(Index bigint, Cdphid bigint, ProductName varchar(500), CSFId bigint, CSF varchar(500), CompanyId bigint,
 CompanyName varchar(200), BrandName varchar(200), PrimaryCategoryId bigint,
 PrimaryCategory varchar(200), SubCategoryId bigint, SubCategory varchar(200), CasId bigint,
 CasNumber VARCHAR(200), ChemicalId bigint, ChemicalName varchar(200),
 InitialDateReported date, MostRecentDateReported date, DiscontinuedDate date, ChemicalCreatedAt date,
 ChemicalUpdatedAt date, ChemicalDateRemoved date, ChemicalCount bigint)

select * from chemicals_in_cosmetics
select productname from chemicals_in_cosmetics
where productname like '%?%'

--update chemicals_in_cosmetics
--set productnameupdated= replace(productname, '?', '') 


select index, cdphid, chemicalname, productname, companyid, brandname,companyname, csfid, csf, casid, casnumber,
primarycategory, chemicalid, subcategory, subcategoryid, primarycategoryid, chemicalcreatedat, 
chemicalcount, chemicalname, initialdatereported, mostrecentdatereported, discontinueddate,
chemicalupdatedat, chemicaldateremoved, count(*)
from chemicals_in_cosmetics
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
having count(*) > 1

--------------------------------------renaming column
alter table chemicals_in_cosmetics
rename column chemicalcreatedat to chemicalcreated from chemicals_in_cosmetics

------------remove unwanted character and add new column--------------
select replace(productname, '?','') as productnamefixed-------USING REPLACE to remove unwanted character
from chemicals_in_cosmetics

alter table chemicals_in_cosmetics----------ADDING NEW FIXED COLUMN TO TABLE
add productnamefixed varchar (500)

update chemicals_in_cosmetics-------------UPDATING CHANGES MADE TO EXISTING COLUMN INTO NEW COLUMN
set productnamefixed= replace (productname, '?', '')

--------------------------------------------CORRECTING DATE
update chemicals_in_cosmetics
set chemicaldateremoved= '2013-12-05'
where chemicaldateremoved = '2103-12-05'

-------------CHECKING FOR DUPLICATES ACROSS ROWS--------------
select index, cdphid, chemicalname, productname, companyid, brandname,companyname, csfid, csf, casid, casnumber,
primarycategory, chemicalid, subcategory, subcategoryid, primarycategoryid, chemicalcreatedat, 
chemicalcount, chemicalname, initialdatereported, mostrecentdatereported, discontinueddate,
chemicalupdatedat, chemicaldateremoved, count(*)
from chemicals_in_cosmetics
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
having count(*) > 1
 
--------------using cte to check for duplicates 
 with row_numCTE AS
(SELECT *, 
	ROW_NUMBER() OVER (
	partition by index, cdphid, chemicalname, productname, companyid, brandname,companyname, csfid, csf, casid, casnumber,
primarycategory, chemicalid, subcategory, subcategoryid, primarycategoryid, chemicalcreatedat, 
chemicalcount, chemicalname, initialdatereported, mostrecentdatereported, discontinueddate,
chemicalupdatedat, chemicaldateremoved) row_num 
from chemicals_in_cosmetics)
select * from row_numCTE
WHERE row_num > 1

---select DISTINCT(chemicalname)-------------chemicals in personal care products 
----from chemicals_in_cosmetics 
-----where primarycategory= 'Personal Care Products'

----select DISTINCT(chemicalname)-------------chemicals in all products 
---from chemicals_in_cosmetics 



----------------------------------------CHEMICALS USED THE MOST. Q1
select distinct(chemicalname), sum(chemicalcount)
from chemicals_in_cosmetics
group by 1
order by 2 desc

--------------------------------------COMPANIES THAT USED THE MOST REPORTED CHEMICALS. 

select distinct(chemicalname), count(reportedyear)-----------MOST REPORTED CHEMICALS
from chemicals_in_cosmetics
group by 1
order by 2 desc

select distinct(companyname), count(chemicalname)------. Q2
from chemicals_in_cosmetics
where chemicalname= 'Titanium dioxide'
group by 1
order by 2 desc

		
-----------------------BRANDS HAVING CHEMICALS REMOVED & DISCONTINUED. Q3
SELECT DISTINCT (brandname), chemicalname
from chemicals_in_cosmetics
where chemicalcount=0
group by 1,2

--------------EXTRACT YEAR FROM EXISTING COLUMN AND ADD NEW COLUMN--------
select extract(year from mostrecentdatereported) as reportedyear
from chemicals_in_cosmetics

alter table chemicals_in_cosmetics
add reportedyear int
update chemicals_in_cosmetics
set reportedyear= extract(year from mostrecentdatereported)


-----------------BRANDS WHICH HAD CHEMICALS MOSTLY REPORTED IN 2018.
select extract(year from chemicalcreatedat) as creation_year
from chemicals_in_cosmetics

alter table chemicals_in_cosmetics
add creation_year int
update chemicals_in_cosmetics
set creation_year=extract(year from chemicalcreatedat)

SELECT distinct(chemicalname), count(creation_year)----CHEMICALS MOSTLY REPORTED IN 2018 IN DESC ORDER 
from chemicals_in_cosmetics
where creation_year= 2018 
group by 1
order by 2 desc
LIMIT 5


SELECT distinct(brandname), chemicalname --------------BRANDS WITH CHEMICALS MOSTLY REPORTED IN 2018 . Q4
from chemicals_in_cosmetics
where creation_year =2018
group by 1,2
HAVING chemicalname IN ('Titanium dioxide','Talc', 'Mica', 'Silica crystalline', 'Cosmetic talc')


-------------------------brands that had chemicals discontinued and removed. Q5
select distinct(brandname)
from chemicals_in_cosmetics
where chemicalcount= 0

---------------------------PERIOD BETWEEN CHEMICAL CREATION AND REMOVAL. Q6
SELECT chemicalcreatedat, chemicaldateremoved, (chemicaldateremoved-chemicalcreatedat) as time_difference
from chemicals_in_cosmetics
WHERE chemicalcount=0

---------------------------TELLING IF DISCONTINUED CHEMICALS IN BATH PRODS WERE REMOVED. Q7
select chemicaldateremoved, chemicalcount
from chemicals_in_cosmetics
where primarycategory= 'Bath Products' and chemicaldateremoved is not null
order by 2 desc


------------------------------------HOW LONG CHEMICALS IN BABY PRODUCTS WERE USED. Q8
-------------DIFFERENCE IN DAYS ONLY-----------------
SELECT chemicalcreatedat, chemicaldateremoved, (chemicaldateremoved-chemicalcreatedat) as time_difference
from chemicals_in_cosmetics
where primarycategory= 'Baby Products' and chemicaldateremoved is not null
order by 3 desc
--------DIFFERENCE IN Y,M,D---------------------
SELECT AGE(chemicaldateremoved, chemicalcreatedat) as time_difference
from chemicals_in_cosmetics
where primarycategory= 'Baby Products' AND chemicaldateremoved is not null
order by time_difference desc
-------------------------------OR---------------------------------------
SELECT chemicalcreatedat, chemicaldateremoved, (chemicaldateremoved-chemicalcreatedat) as duration
from chemicals_in_cosmetics
where primarycategory= 'Baby Products' and chemicalcount=0
order by 3 desc

-------------------------RELATIONSHIP BTWN CHEMICALS MOST RECENTLY REPORTED AND DISCONTINUED
select extract(year from discontinueddate) as stop_year----------creating year column for discontinueddate
from chemicals_in_cosmetics

alter table chemicals_in_cosmetics
add stop_year int

update chemicals_in_cosmetics
set stop_year= extract(year from discontinueddate)

SELECT distinct(chemicalname),reportedyear, stop_year, chemicalcount --------. Q9
from chemicals_in_cosmetics
where stop_year is not null
order by reportedyear, stop_year

-----------------------------------RELATIONSHIP BTWN CSF, CHEMICALS & SUBCATEGORIES. Q10
SELECT DISTINCT(subcategory), count(subcategory), chemicalname, csf
from chemicals_in_cosmetics
where csf is not null
group by 1,3,4
order by 2 desc





------------------------------DATA EXPLORATION--------------------------
with cte_1 as----------- HIGHEST COUNT OF DISTINCT CHEMICAL USED BY A COMPANY
(select companyname, chemicalname, sum(chemicalcount) as sum_count
 from chemicals_in_cosmetics
group by 1,2
order by 3 desc)
select distinct(chemicalname), max(sum_count) from cte_1
group by 1
order by 2 desc

select primarycategory, count(distinct(chemicalname)) --------unique number of chemicals USED by category
from chemicals_in_cosmetics 
GROUP BY primarycategory
order by 2 desc

select distinct(companyname), count(distinct(chemicalname)) --------unique number of chemicals by companyname
from chemicals_in_cosmetics
group by 1
order by 2 desc

SELECT count(distinct(companyname)) from chemicals_in_cosmetics-----------total number of companies

SELECT max(chemicalcount) FROM chemicals_in_cosmetics-----------------highest chemical count in one product


