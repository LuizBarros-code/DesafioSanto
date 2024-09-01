#Quais são os 10 produtos mais vendidos (em quantidade) na categoria "Bicicletas", considerando apenas vendas feitas nos últimos dois anos?

SELECT 
    p.ProductName, 
    SUM(v.OrderQuantity) AS total_vendido
FROM (
    -- Subquery que une os dados de vendas de 2016 e 2017
    SELECT ProductKey , OrderQuantity FROM sales_2016
    UNION ALL
    SELECT ProductKey , OrderQuantity FROM sales_2017
) v   -- 'v' é o alias dado ao resultado da união das duas tabelas de vendas
JOIN 
    products p ON v.ProductKey = p.ProductKey  -- Junta com a tabela de produtos para obter o nome do produto
JOIN 
    product_subcategories s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey  -- Junta com subcategorias para obter a subcategoria do produto
JOIN 
    product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey   -- Junta com categorias para obter a categoria do produto
WHERE 
    c.CategoryName = 'Bikes'   -- Filtra para considerar apenas produtos da categoria "Bikes"
GROUP BY 
    p.ProductName   -- Agrupa os resultados por nome de produto para calcular a soma das vendas
ORDER BY 
    total_vendido DESC -- Ordena os resultados em ordem decrescente com base no total vendido
LIMIT 10;  -- Limita o resultado aos 10 produtos mais vendidos




#Qual é o cliente que tem o maior número de pedidos realizados, considerando apenas clientes que fizeram pelo menos um pedido em cada trimestre do último ano fiscal?
 -- calcula o número de pedidos por cliente e por trimestre
WITH Pedidostrimestrais AS (
    SELECT 
        s.CustomerKey,  -- Identificador do cliente
        QUARTER(s.OrderDate) AS Quarter,  -- Calcula o trimestre em que o pedido foi feito
        COUNT(s.OrderNumber) AS OrderCount  -- Conta o número de pedidos no trimestre
    FROM Sales_2017 s
    WHERE YEAR(s.OrderDate) = 2017
    GROUP BY s.CustomerKey, QUARTER(s.OrderDate)  -- Agrupa os resultados por cliente e trimestre
),
EligibleCustomers AS ( -- seleciona os clientes que fizeram pedidos em exatamente dois trimestres diferentes
    SELECT 
        qo.CustomerKey
    FROM Pedidostrimestrais qo
    GROUP BY qo.CustomerKey
    HAVING COUNT(DISTINCT qo.Quarter) = 2   -- Filtra para clientes que fizeram pedidos em exatamente 2 trimestres, no csv 2017 só tem ate o mês 06
)
SELECT   -- Consulta principal que encontra o cliente com o maior número de pedidos entre os elegíveis
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

WITH Mesmaisvendas AS ( -- calcula as vendas totais, o número de vendas e o valor médio de vendas por mês e ano
    SELECT 
        YEAR(s.OrderDate) AS year,
        MONTH(s.OrderDate) AS month,
        SUM(p.ProductPrice) AS total_sales,
        COUNT(s.OrderNumber) AS num_sales,
        AVG(p.ProductPrice) AS avg_sales_value
    FROM ( -- Subquery que une os dados de vendas dos anos 2015, 2016 e 2017
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
FilteredMonths AS ( -- filtra apenas os meses onde o valor médio de vendas foi superior a 500
    SELECT 
        year,
        month,
        total_sales
    FROM 
        Mesmaisvendas
    WHERE 
        avg_sales_value > 500
)
SELECT  -- Consulta principal que soma o total de vendas para cada mês filtrado
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

 -- calcula o total de vendas por território e ano
WITH VendedoresVendas AS (
    SELECT 
        s.TerritoryKey,
        YEAR(s.OrderDate) AS year,
        SUM(p.ProductPrice) AS total_sales
    FROM ( -- Subquery que une os dados de vendas de 2016 e 2017
        SELECT OrderNumber, ProductKey, OrderDate, TerritoryKey FROM sales_2016
        UNION ALL
        SELECT OrderNumber, ProductKey, OrderDate, TerritoryKey FROM sales_2017
    ) s
    JOIN products p ON s.ProductKey = p.ProductKey
    GROUP BY s.TerritoryKey, YEAR(s.OrderDate)
), -- calcula a média de vendas por território ao longo dos anos
AverageSales AS (
    SELECT
        TerritoryKey,
        AVG(total_sales) AS avg_sales
    FROM VendedoresVendas
    GROUP BY TerritoryKey
), --  calcula as vendas totais por território para 2016 e 2017 separadamente
YearlySales AS (
    SELECT
        TerritoryKey,
        SUM(CASE WHEN year = 2017 THEN total_sales ELSE 0 END) AS sales_2017,
        SUM(CASE WHEN year = 2016 THEN total_sales ELSE 0 END) AS sales_2016
    FROM VendedoresVendas
    GROUP BY TerritoryKey -- Agrupa por território para calcular as vendas por ano
) 
-- Consulta principal que filtra e retorna os territórios com vendas em 2017 acima da média , e com crescimento superior a 10% em comparação a 2016
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
   
SELECT  -- Seleciona o ano e a média dos preços dos produtos vendidos nesse ano
    YEAR(OrderDate) AS year,
    AVG(p.ProductPrice) AS avg_sales_year
FROM ( -- Subquery que une os dados de vendas de 2015, 2016 e 2017
    SELECT OrderDate, ProductKey FROM sales_2015
    UNION ALL
    SELECT OrderDate, ProductKey FROM sales_2016
    UNION ALL
    SELECT OrderDate, ProductKey FROM sales_2017
) s  -- 's' é o alias dado ao conjunto de dados unificado das três tabelas de vendas
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY YEAR(OrderDate)
ORDER BY year; -- Ordena os resultados por ano em ordem crescente
