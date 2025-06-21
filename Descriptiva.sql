-- Analisis descriptivo

--1) top productos mas consumidos 

SELECT Top 10
    p.Name AS ProductName,
    SUM(sod.OrderQty) AS TotalUnitsSold
FROM
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY
    p.Name
ORDER BY
    TotalUnitsSold DESC;

--2) Que territorio es el mas rentable

SELECT
    st.Name AS TerritoryName,
    SUM(soh.TotalDue) AS TotalSales
FROM
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY
    st.Name
ORDER BY
    TotalSales DESC;

--3) top 5´productos mas vendidos por territorio (cantidad)

WITH productos_mas_vendidos as (
    SELECT
        st.Name AS TerritoryName,
        p.Name AS ProductName,
        SUM(sod.OrderQty) AS TotalUnitsSold,
        ROW_NUMBER() OVER (PARTITION BY st.Name ORDER BY SUM(sod.OrderQty) DESC) AS rn
    FROM
        Sales.SalesOrderDetail sod
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
        JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
        JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY
        st.Name,
        p.Name
)
SELECT
    TerritoryName,
    ProductName,
    TotalUnitsSold
FROM productos_mas_vendidos
WHERE rn <= 5
ORDER BY
    TerritoryName,
    TotalUnitsSold DESC;


-- Top 5 Productos mas rentables por territorio

WITH productos_mas_rentables AS (
    SELECT
        st.Name AS TerritoryName,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY st.Name ORDER BY SUM(sod.LineTotal) DESC) AS rn
    FROM
        Sales.SalesOrderDetail sod
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
        JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
        JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY
        st.Name,
        p.Name
)
SELECT
    TerritoryName,
    ProductName,
    TotalSales
FROM productos_mas_rentables
WHERE rn <= 5
ORDER BY
    TerritoryName,
    TotalSales DESC;

-- Por año y por territorio

WITH productos_mas_vendidos AS (
    SELECT
        st.Name AS TerritoryName,
        YEAR(soh.OrderDate) AS Year,
        p.Name AS ProductName,
        SUM(sod.OrderQty) AS TotalUnitsSold,
        ROW_NUMBER() OVER (
            PARTITION BY st.Name, YEAR(soh.OrderDate)
            ORDER BY SUM(sod.OrderQty) DESC
        ) AS rn
    FROM
        Sales.SalesOrderDetail sod
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
        JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
        JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY
        st.Name,
        YEAR(soh.OrderDate),
        p.Name
)
SELECT
    TerritoryName,
    Year,
    ProductName,
    TotalUnitsSold
FROM productos_mas_vendidos
WHERE rn <= 5
ORDER BY
    TerritoryName,
    Year,
    TotalUnitsSold DESC;

-- 

SELECT
    st.Name AS TerritoryName,
    YEAR(soh.OrderDate) AS Year,
    p.Name AS ProductName,
    SUM(sod.OrderQty) AS TotalUnitsSold
FROM
    Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY
    ROLLUP(st.Name, YEAR(soh.OrderDate), p.Name)
ORDER BY
    TerritoryName,
    Year,
    ProductName;