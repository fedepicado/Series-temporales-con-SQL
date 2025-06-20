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




----------
-- analisis de cohortes productos
-- No solo quiero ver como se van perdiendo los productos del a�o 2011 sino tambien como se van perdiendo los productos del a�o 2012 y 2013

WITH productos_por_año AS (
    SELECT 
        YEAR(soh.OrderDate) AS año,
        sod.ProductID,
        COUNT(*) AS cantidad_vendida
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
    GROUP BY YEAR(soh.OrderDate), sod.ProductID
),
top1000_por_año AS (
    SELECT 
        año,
        ProductID
    FROM (
        SELECT 
            año,
            ProductID,
            ROW_NUMBER() OVER (PARTITION BY año ORDER BY cantidad_vendida DESC) AS ranking
        FROM productos_por_año
    ) ranked
    WHERE ranking <= 1000
),
combinaciones AS (
    -- Generamos pares (cohorte, a�o_observado)
    SELECT 
        c1.año AS cohorte,
        c2.año AS año_observado,
        c1.ProductID
    FROM top1000_por_año c1
    JOIN top1000_por_año c2 
        ON c1.ProductID = c2.ProductID
        AND c2.año >= c1.año  -- solo observaciones posteriores o del mismo a�o
),
productos_finales as (
SELECT 
    cohorte,
    año_observado - cohorte AS año_desde_cohorte,
    COUNT(DISTINCT ProductID) AS productos_retenidos
FROM combinaciones
GROUP BY cohorte, año_observado - cohorte
)
SELECT 
    pf.cohorte,
    pf.año_desde_cohorte,
    round((CAST(pf.productos_retenidos AS FLOAT) /
     CAST(FIRST_VALUE(pf.productos_retenidos) OVER (PARTITION BY pf.cohorte ORDER BY pf.año_desde_cohorte) AS FLOAT)),2) * 100 
     AS porcentaje 
FROM productos_finales pf
order by pf.cohorte, pf.año_desde_cohorte asc

-- porcentaje para que luego cuando sea lineplot sea más facil visualizar la caida sino las cantidades no iban a hacer tan visible se lo quiero agregar a los otros



SELECT 
    pf.cohorte,
    pf.año_desde_cohorte,
    pf.productos_retenidos,
    CASE 
        WHEN pf.año_desde_cohorte != 0 THEN 
            CAST(
                pf.productos_retenidos / (
                    SELECT FIRST_VALUE(cp2.productos_retenidos) 
                    OVER (PARTITION BY pf2.cohorte ORDER BY pf2.año_desde_cohorte)
                    FROM productos_finales pf2 
                    WHERE pf.cohorte = pf2.cohorte
                ) 
            AS FLOAT) * 100 
        ELSE 100 
    END AS porcentaje
FROM productos_finales pf
ORDER BY pf.cohorte ASC, pf.año_desde_cohorte;


----------- con pivot para ver mejor

WITH productos_por_año AS (
    SELECT 
        YEAR(soh.OrderDate) AS año,
        sod.ProductID,
        COUNT(*) AS cantidad_vendida
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
    GROUP BY YEAR(soh.OrderDate), sod.ProductID
),
top100_por_año AS (
    SELECT 
        año,
        ProductID
    FROM (
        SELECT 
            año,
            ProductID,
            ROW_NUMBER() OVER (PARTITION BY año ORDER BY cantidad_vendida DESC) AS ranking
        FROM productos_por_año
    ) ranked
    WHERE ranking <= 100
),
combinaciones AS (
    SELECT 
        c1.año AS cohorte,
        c2.año AS año_observado,
        c1.ProductID
    FROM top100_por_año c1
    JOIN top100_por_año c2 
        ON c1.ProductID = c2.ProductID
        AND c2.año >= c1.año
),
cohorte_retención AS (
    SELECT 
        cohorte,
        año_observado - cohorte AS año_desde_cohorte,
        COUNT(DISTINCT ProductID) AS productos_retenidos
    FROM combinaciones
    GROUP BY cohorte, año_observado - cohorte
)
-- PIVOT: filas = cohorte, columnas = a�o_desde_cohorte
SELECT 
    cohorte,
    ISNULL([0], 0) AS año0,
    ISNULL([1], 0) AS año1,
    ISNULL([2], 0) AS año2,
    ISNULL([3], 0) AS año3
FROM cohorte_retención
PIVOT (
    SUM(productos_retenidos)
    FOR año_desde_cohorte IN ([0], [1], [2], [3])
) AS pvt
ORDER BY cohorte;

--- Quiero aplicar la misma logica pero para clientes. ACA todos los clientes

WITH primera_compra AS (
    SELECT 
        CustomerID,
        MIN(YEAR(OrderDate)) AS año_primera_compra
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
    GROUP BY CustomerID
),
compras_por_cliente AS (
    SELECT 
        soh.CustomerID,
        pc.año_primera_compra AS cohorte,
        YEAR(soh.OrderDate) AS año_observado
    FROM Sales.SalesOrderHeader soh
    JOIN primera_compra pc ON soh.CustomerID = pc.CustomerID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
        AND pc.año_primera_compra BETWEEN 2011 AND 2014
        AND YEAR(soh.OrderDate) >= pc.año_primera_compra
),
clientes_cohorte_retencion AS (
    SELECT 
        cohorte,
        año_observado - cohorte AS año_desde_cohorte,
        COUNT(DISTINCT CustomerID) AS clientes_retenidos
    FROM compras_por_cliente
    GROUP BY cohorte, año_observado - cohorte
)
-- Tabla pivotada
select * from clientes_cohorte_retencion ccr ORDER BY ccr.cohorte ASC


SELECT 
    cohorte,
    ISNULL([0], 0) AS año0,
    ISNULL([1], 0) AS año1,
    ISNULL([2], 0) AS año2,
    ISNULL([3], 0) AS año3
FROM clientes_cohorte_retencion
PIVOT (
    SUM(clientes_retenidos)
    FOR año_desde_cohorte IN ([0], [1], [2], [3])
) AS pvt
ORDER BY cohorte


-- Si quiero los 100 clientes que mas�plata dejaron?

--1 Calcular la ganancia total por cliente (por todas sus compras).

--2 Ordenar y seleccionar el top 100 clientes m�s rentables.

--3 Hacer el mismo an�lisis de cohortes pero limitado a ese subconjunto.

-- 1. Calcular clientes m�s rentables
WITH clientes_rentables AS (
    SELECT 
        soh.CustomerID,
        SUM(sod.UnitPrice * sod.OrderQty) AS ingresos -- o ganancia si ten�s costos
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
    GROUP BY soh.CustomerID
),
top100_clientes AS (
    SELECT CustomerID
    FROM (
        SELECT 
            CustomerID,
            ROW_NUMBER() OVER (ORDER BY ingresos DESC) AS ranking
        FROM clientes_rentables
    ) r
    WHERE ranking <= 100
),
-- 2. Identificar la primera compra de esos clientes
primera_compra AS (
    SELECT 
        soh.CustomerID,
        MIN(YEAR(soh.OrderDate)) AS año_primera_compra
    FROM Sales.SalesOrderHeader soh
    JOIN top100_clientes tc ON soh.CustomerID = tc.CustomerID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
    GROUP BY soh.CustomerID
),
-- 3. Traer todas las compras de esos clientes en esos a�os
compras_por_cliente AS (
    SELECT 
        soh.CustomerID,
        pc.año_primera_compra AS cohorte,
        YEAR(soh.OrderDate) AS año_observado
    FROM Sales.SalesOrderHeader soh
    JOIN primera_compra pc ON soh.CustomerID = pc.CustomerID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
        AND YEAR(soh.OrderDate) >= pc.año_primera_compra
),
-- 4. Calcular retenci�n
clientes_cohorte_retencion AS (
    SELECT 
        cohorte,
        año_observado - cohorte AS año_desde_cohorte,
        COUNT(DISTINCT CustomerID) AS clientes_retenidos
    FROM compras_por_cliente
    GROUP BY cohorte, año_observado - cohorte
)
-- 5. PIVOT final
SELECT 
    cohorte,
    ISNULL([0], 0) AS año0,
    ISNULL([1], 0) AS año1,
    ISNULL([2], 0) AS año2,
    ISNULL([3], 0) AS año3
FROM clientes_cohorte_retencion
PIVOT (
    SUM(clientes_retenidos)
    FOR año_desde_cohorte IN ([0], [1], [2], [3])
) AS pvt
ORDER BY cohorte;

-- Esta bien esto? Oseaaaa los que mas plata gastaron se mantienen en su mayoria? 

