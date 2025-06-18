with vendidos_2011 as (
	select * 
		from (select sod.ProductID
				, count(*) as cantidad
				, row_number() over (order by count(*) desc) as ranking
				from Sales.SalesOrderHeader soh
				left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
				where year(OrderDate) = 2011
				group by sod.ProductID) v2011
		WHERE  v2011.ranking <= 100
	) ,
vendidos_2012 as (
select * from (select sod.ProductID, count(*) as cantidad, row_number() over (order by count(*) desc) as ranking
from Sales.SalesOrderHeader soh
left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = 2012
group by sod.ProductID) v2012
WHERE  v2012.ranking <= 100
)
,
vendidos_2013 as (
select * from (select sod.ProductID, count(*) as cantidad, row_number() over (order by count(*) desc) as ranking
from Sales.SalesOrderHeader soh
left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = 2013
group by sod.ProductID) v2013
WHERE  v2013.ranking <= 100
)
,
vendidos_2014 as (
select * from (select sod.ProductID, count(*) as cantidad, row_number() over (order by count(*) desc) as ranking
from Sales.SalesOrderHeader soh
left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = 2014
group by sod.ProductID) v2014
WHERE  v2014.ranking <= 100
)
,
conjunto as (
select 
	v2011.ProductID as producto2011
	, CASE WHEN v2012.ProductID IS NULL THEN 0 ELSE 1 END as c_2012
	, CASE WHEN v2013.ProductID IS NULL THEN 0 ELSE 1 END as c_2013
	, CASE WHEN v2014.ProductID IS NULL THEN 0 ELSE 1 END as c_2014
		from vendidos_2011 v2011
		left join vendidos_2012 v2012 on v2011.ProductID = v2012.ProductID
		left join vendidos_2013 v2013 on v2011.ProductID = v2013.ProductID
		left join vendidos_2014 v2014 on v2011.ProductID = v2014.ProductID)
select count(distinct c.producto2011) as top_producto_2011 , sum (c.c_2012) as productos_retenidos_2012, sum (c.c_2013) as productos_retenidos_2013, sum(c.c_2014) as productos_retenidos_2014
from conjunto c






----------------

with vendidos_2011 as (
	select * 
		from (select soh.CustomerID
				, sum(TotalDue) as cantidad
				, row_number() over (order by sum(TotalDue) desc) as ranking
				from Sales.SalesOrderHeader soh
				left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
				where year(OrderDate) = 2011
				group by soh.CustomerID) v2011
		WHERE  v2011.ranking <= 1400
	) ,
vendidos_2012 as (
	select * 
		from (select soh.CustomerID
				, sum(TotalDue) as cantidad
				, row_number() over (order by sum(TotalDue) desc) as ranking
				from Sales.SalesOrderHeader soh
				left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
				where year(OrderDate) = 2012
				group by soh.CustomerID) v2012
		WHERE  v2012.ranking <= 1400
	)
,
vendidos_2013 as (
	select * 
		from (select soh.CustomerID
				, sum(TotalDue) as cantidad
				, row_number() over (order by sum(TotalDue) desc) as ranking
				from Sales.SalesOrderHeader soh
				left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
				where year(OrderDate) = 2013
				group by soh.CustomerID) v2013
		WHERE  v2013.ranking <= 1400
	)
,
vendidos_2014 as (
	select * 
		from (select soh.CustomerID
				, sum(TotalDue) as cantidad
				, row_number() over (order by sum(TotalDue) desc) as ranking
				from Sales.SalesOrderHeader soh
				left join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
				where year(OrderDate) = 2014
				group by soh.CustomerID) v2014
		WHERE  v2014.ranking <= 1400
	),
conjunto as (
select 
	v2011.CustomerID as producto2011
	, CASE WHEN v2012.CustomerID IS NULL THEN 0 ELSE 1 END as c_2012
	, CASE WHEN v2013.CustomerID IS NULL THEN 0 ELSE 1 END as c_2013
	, CASE WHEN v2014.CustomerID IS NULL THEN 0 ELSE 1 END as c_2014
		from vendidos_2011 v2011
		left join vendidos_2012 v2012 on v2011.CustomerID = v2012.CustomerID
		left join vendidos_2013 v2013 on v2011.CustomerID = v2013.CustomerID
		left join vendidos_2014 v2014 on v2011.CustomerID = v2014.CustomerID)
select count(distinct c.producto2011) as top_producto_2011 , sum (c.c_2012) as productos_retenidos_2012, sum (c.c_2013) as productos_retenidos_2013, sum(c.c_2014) as productos_retenidos_2014
from conjunto c



select year(OrderDate), count(distinct(soh.CustomerID)) from sales.SalesOrderHeader soh 
group by year(OrderDate)
order by year(OrderDate)


SELECT
    c.CustomerID,
    YEAR(soh.OrderDate) AS Anio,
    COUNT(soh.SalesOrderID) AS Compras
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY c.CustomerID, YEAR(soh.OrderDate)