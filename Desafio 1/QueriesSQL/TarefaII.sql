#Quais são os 10 produtos mais vendidos (em quantidade) na categoria "Bicicletas", considerando apenas vendas feitas nos últimos dois anos?

SELECT 
    p.ProductName, 
    SUM(v.OrderQuantity) AS total_vendido
FROM (
    SELECT ProductKey , OrderQuantity FROM sales_2016
    UNION ALL
    SELECT ProductKey , OrderQuantity FROM sales_2017
) v
JOIN 
    products p ON v.ProductKey = p.ProductKey 
JOIN 
    product_subcategories s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey 
JOIN 
    product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey 
WHERE 
    c.CategoryName = 'Bikes'
GROUP BY 
    p.ProductName 
ORDER BY 
    total_vendido DESC
LIMIT 10;




#Qual é o cliente que tem o maior número de pedidos realizados, considerando apenas clientes que fizeram pelo menos um pedido em cada trimestre do último ano fiscal?

WITH Pedidostrimestrais AS (
    SELECT 
        s.CustomerKey,
        QUARTER(s.OrderDate) AS Quarter,
        COUNT(s.OrderNumber) AS OrderCount
    FROM Sales_2017 s
    WHERE YEAR(s.OrderDate) = 2017
    GROUP BY s.CustomerKey, QUARTER(s.OrderDate)
),
EligibleCustomers AS (
    SELECT 
        qo.CustomerKey
    FROM Pedidostrimestrais qo
    GROUP BY qo.CustomerKey
    HAVING COUNT(DISTINCT qo.Quarter) = 2  
)
SELECT 
    c.CustomerKey,
    c.FirstName,
    c.LastName,
    COUNT(s.OrderNumber) AS TotalOrders
FROM Sales_2017 s
JOIN EligibleCustomers ec ON s.CustomerKey = ec.CustomerKey
JOIN Customers c ON s.CustomerKey = c.CustomerKey
WHERE YEAR(s.OrderDate) = 2017
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY TotalOrders DESC
LIMIT 1;





#Em qual mês do ano ocorrem mais vendas (em valor total), considerando apenas os meses em que a receita média por venda foi superior a 500 unidades monetárias?

WITH Mesmaisvendas AS (
    SELECT 
        YEAR(s.OrderDate) AS year,
        MONTH(s.OrderDate) AS month,
        SUM(p.ProductPrice) AS total_sales,
        COUNT(s.OrderNumber) AS num_sales,
        AVG(p.ProductPrice) AS avg_sales_value
    FROM (
        SELECT OrderNumber, ProductKey, OrderDate FROM sales_2015
        UNION ALL
        SELECT OrderNumber, ProductKey, OrderDate FROM sales_2016
        UNION ALL
        SELECT OrderNumber, ProductKey, OrderDate FROM sales_2017
    ) AS s
    JOIN products p ON s.ProductKey = p.ProductKey
    GROUP BY 
        YEAR(s.OrderDate), MONTH(s.OrderDate)
),
FilteredMonths AS (
    SELECT 
        year,
        month,
        total_sales
    FROM 
        Mesmaisvendas
    WHERE 
        avg_sales_value > 500
)
SELECT 
    month,
    SUM(total_sales) AS total_sales_for_month
FROM 
    FilteredMonths
GROUP BY 
    month
ORDER BY 
    total_sales_for_month DESC
LIMIT 1;



#Quais vendedores tiveram vendas com valor acima da média no último ano fiscal e também tiveram um crescimento de vendas superior a 10% em relação ao ano anterior?


WITH VendedoresVendas AS (
    SELECT 
        s.TerritoryKey,
        YEAR(s.OrderDate) AS year,
        SUM(p.ProductPrice) AS total_sales
    FROM (
        SELECT OrderNumber, ProductKey, OrderDate, TerritoryKey FROM sales_2016
        UNION ALL
        SELECT OrderNumber, ProductKey, OrderDate, TerritoryKey FROM sales_2017
    ) s
    JOIN products p ON s.ProductKey = p.ProductKey
    GROUP BY s.TerritoryKey, YEAR(s.OrderDate)
),
AverageSales AS (
    SELECT
        TerritoryKey,
        AVG(total_sales) AS avg_sales
    FROM VendedoresVendas
    GROUP BY TerritoryKey
),
YearlySales AS (
    SELECT
        TerritoryKey,
        SUM(CASE WHEN year = 2017 THEN total_sales ELSE 0 END) AS sales_2017,
        SUM(CASE WHEN year = 2016 THEN total_sales ELSE 0 END) AS sales_2016
    FROM VendedoresVendas
    GROUP BY TerritoryKey
)
SELECT
    t.Region,
    y.sales_2017,
    y.sales_2016
FROM
    AverageSales a
JOIN
    YearlySales y ON a.TerritoryKey = y.TerritoryKey
JOIN
    territories t ON y.TerritoryKey = t.SalesTerritoryKey
WHERE
    y.sales_2017 > a.avg_sales
    AND (y.sales_2017 - y.sales_2016) / y.sales_2016 > 0.10 
ORDER BY
    y.sales_2017 DESC;
   
   
 #Media de vendas a cada ano 2015,2016 e 2017
   
SELECT 
    YEAR(OrderDate) AS year,
    AVG(p.ProductPrice) AS avg_sales_year
FROM (
    SELECT OrderDate, ProductKey FROM sales_2015
    UNION ALL
    SELECT OrderDate, ProductKey FROM sales_2016
    UNION ALL
    SELECT OrderDate, ProductKey FROM sales_2017
) s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY YEAR(OrderDate)
ORDER BY year;