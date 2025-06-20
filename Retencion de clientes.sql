SELECT 
    CustomerID,
    MIN(OrderDate) AS minimo,
	MAX(OrderDate) AS maximo
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY maximo DESC

WITH primera_compra AS (
    SELECT 
        CustomerID,
        MIN(DATEPART(YEAR, OrderDate) * 4 + DATEPART(QUARTER, OrderDate) - 1) AS trimestre_primera_compra,
        MIN(OrderDate) AS fecha_primera_compra
    FROM Sales.SalesOrderHeader
    WHERE OrderDate >= '2011-05-31' AND OrderDate < '2014-06-30'  -- Agregar filtro aquí también
    GROUP BY CustomerID
),
compras_por_cliente AS (
    SELECT 
        soh.CustomerID,
        pc.trimestre_primera_compra AS cohorte,
        DATEPART(YEAR, soh.OrderDate) * 4 + DATEPART(QUARTER, soh.OrderDate) - 1 AS trimestre_observado,
        pc.fecha_primera_compra
    FROM Sales.SalesOrderHeader soh
    JOIN primera_compra pc ON soh.CustomerID = pc.CustomerID
    WHERE soh.OrderDate >= '2011-05-31' AND soh.OrderDate < '2014-06-30'  -- Filtro también aquí
),
clientes_cohorte_retencion AS (
    SELECT 
        cohorte,
        trimestre_observado - cohorte AS trimestres_desde_cohorte,
        COUNT(DISTINCT CustomerID) AS clientes_retenidos
    FROM compras_por_cliente
    GROUP BY cohorte, trimestre_observado - cohorte
),
tabla_pivot AS (
    SELECT 
        cohorte,
        ISNULL([0], 0) AS trimestre0,
        ISNULL([1], 0) AS trimestre1,
        ISNULL([2], 0) AS trimestre2,
        ISNULL([3], 0) AS trimestre3,
        ISNULL([4], 0) AS trimestre4,
        ISNULL([5], 0) AS trimestre5,
        ISNULL([6], 0) AS trimestre6,
        ISNULL([7], 0) AS trimestre7,
        ISNULL([8], 0) AS trimestre8,
        ISNULL([9], 0) AS trimestre9,
        ISNULL([10], 0) AS trimestre10,
        ISNULL([11], 0) AS trimestre11,
        ISNULL([12], 0) AS trimestre12
    FROM clientes_cohorte_retencion
    PIVOT (
        SUM(clientes_retenidos)
        FOR trimestres_desde_cohorte IN (
            [0], [1], [2], [3], [4], [5], [6], [7],
            [8], [9], [10], [11], [12]
        )
    ) AS pvt
)
SELECT 
    cohorte,
    -- CORRECCIÓN: Convertir de vuelta usando la lógica inversa correcta
    CAST(((cohorte + 1) / 4) AS VARCHAR) + 'Q' + CAST(((cohorte + 1) % 4) + 1 AS VARCHAR) AS periodo_cohorte_corregido,
    
    trimestre0,
    trimestre1,
    trimestre2,
    trimestre3,
    trimestre4,
    trimestre5,
    trimestre6,
    trimestre7,
    trimestre8,
    trimestre9,
    trimestre10,
    trimestre11,
    trimestre12,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre0 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t0_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre1 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t1_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre2 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t2_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre3 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t3_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre4 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t4_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre5 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t5_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre6 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t6_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre7 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t7_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre8 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t8_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre9 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t9_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre10 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t10_pct,
    CASE WHEN trimestre0 > 0 THEN ROUND((trimestre11 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t11_pct,
	CASE WHEN trimestre0 > 0 THEN ROUND((trimestre12 * 100.0 / trimestre0), 2) ELSE 0 END AS ret_t12_pct
FROM tabla_pivot
ORDER BY cohorte;

-- Consulta adicional para métricas de resumen
-- Uncomment para ejecutar por separado:
/*
WITH cohort_summary AS (
    SELECT 
        AVG(CASE WHEN trimestre0 > 0 THEN (trimestre1 * 100.0 / trimestre0) END) AS avg_retention_t1,
        AVG(CASE WHEN trimestre0 > 0 THEN (trimestre3 * 100.0 / trimestre0) END) AS avg_retention_t3,
        AVG(CASE WHEN trimestre0 > 0 THEN (trimestre6 * 100.0 / trimestre0) END) AS avg_retention_t6,
        AVG(CASE WHEN trimestre0 > 0 THEN (trimestre12 * 100.0 / trimestre0) END) AS avg_retention_t12
    FROM tabla_pivot
)
SELECT 
    'Retención promedio T1: ' + CAST(ROUND(avg_retention_t1, 2) AS VARCHAR) + '%' AS metric_t1,
    'Retención promedio T3: ' + CAST(ROUND(avg_retention_t3, 2) AS VARCHAR) + '%' AS metric_t3,
    'Retención promedio T6: ' + CAST(ROUND(avg_retention_t6, 2) AS VARCHAR) + '%' AS metric_t6,
    'Retención promedio T12: ' + CAST(ROUND(avg_retention_t12, 2) AS VARCHAR) + '%' AS metric_t12
FROM cohort_summary;
*/

----
