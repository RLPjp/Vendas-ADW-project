   
-- QUERY 1: VISÃO GERAL DO NEGÓCIO



SELECT 
    COUNT(DISTINCT order_id) as total_pedidos,
    COUNT(DISTINCT customer_id) as total_clientes,
    ROUND(SUM(payment_value), 2) as faturamento_total,
    ROUND(AVG(payment_value), 2) as ticket_medio,
    ROUND(MIN(payment_value), 2) as menor_compra,
    ROUND(MAX(payment_value), 2) as maior_compra
FROM vendas;



-- QUERY 2: TOP 10 CATEGORIAS MAIS LUCRATIVAS
 


SELECT 
    product_category_name as categoria,
    COUNT(DISTINCT order_id) as quantidade_pedidos,
    ROUND(SUM(payment_value), 2) as faturamento_total,
    ROUND(AVG(payment_value), 2) as ticket_medio,
    ROUND(SUM(payment_value) * 100.0 / (SELECT SUM(payment_value) FROM vendas), 2) as percentual_faturamento
FROM vendas
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY faturamento_total DESC
LIMIT 10;


 
-- QUERY 3: ANÁLISE GEOGRÁFICA - DESEMPENHO POR ESTADO



SELECT 
    customer_state as estado,
    COUNT(DISTINCT order_id) as total_pedidos,
    COUNT(DISTINCT customer_id) as total_clientes,
    ROUND(SUM(payment_value), 2) as faturamento,
    ROUND(AVG(payment_value), 2) as ticket_medio,
    ROUND(COUNT(DISTINCT order_id) * 1.0 / COUNT(DISTINCT customer_id), 2) as pedidos_por_cliente,
    ROUND(SUM(payment_value) * 100.0 / (SELECT SUM(payment_value) FROM vendas), 2) as percentual_faturamento
FROM vendas
WHERE customer_state IS NOT NULL
GROUP BY customer_state
ORDER BY faturamento DESC;


 
-- QUERY 4: TOP 20 CIDADES COM MAIOR FATURAMENTO



SELECT 
    customer_city as cidade,
    customer_state as estado,
    COUNT(DISTINCT order_id) as total_pedidos,
    COUNT(DISTINCT customer_id) as total_clientes,
    ROUND(SUM(payment_value), 2) as faturamento_total,
    ROUND(AVG(payment_value), 2) as ticket_medio
FROM vendas
WHERE customer_city IS NOT NULL
GROUP BY customer_city, customer_state
HAVING COUNT(DISTINCT order_id) > 5
ORDER BY faturamento_total DESC
LIMIT 20;



-- QUERY 5: EVOLUÇÃO MENSAL DO FATURAMENTO
 


SELECT 
    year_month as mes,
    COUNT(DISTINCT order_id) as pedidos,
    COUNT(DISTINCT customer_id) as clientes,
    ROUND(SUM(payment_value), 2) as faturamento,
    ROUND(AVG(payment_value), 2) as ticket_medio
FROM vendas
WHERE year_month IS NOT NULL
GROUP BY year_month
ORDER BY year_month;


 
-- QUERY 6: SEGMENTAÇÃO DE CLIENTES POR VALOR DE COMPRA



SELECT 
    CASE 
        WHEN payment_value < 50 THEN '1. Baixo (< R$ 50)'
        WHEN payment_value > 50 AND payment_value < 200 THEN '2. Médio (R$ 50-200)'
        WHEN payment_value > 200 AND payment_value < 500 THEN '3. Alto (R$ 200-500)'
        ELSE '4. Premium (> R$ 500)'
    END as faixa_valor,
    COUNT(DISTINCT order_id) as quantidade_pedidos,
    ROUND(SUM(payment_value), 2) as faturamento_total,
    ROUND(AVG(payment_value), 2) as ticket_medio,
    ROUND(COUNT(DISTINCT order_id) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM vendas), 2) as percentual_pedidos,
    ROUND(SUM(payment_value) * 100.0 / (SELECT SUM(payment_value) FROM vendas), 2) as percentual_faturamento
FROM vendas
GROUP BY faixa_valor
ORDER BY faixa_valor;



-- QUERY 7: TOP 20 CLIENTES QUE MAIS COMPRARAM



SELECT 
    customer_id,
    customer_city as cidade,
    customer_state as estado,
    COUNT(DISTINCT order_id) as total_pedidos,
    ROUND(SUM(payment_value), 2) as valor_total_gasto,
    ROUND(AVG(payment_value), 2) as ticket_medio,
    ROUND(MAX(payment_value), 2) as maior_compra,
    ROUND(MIN(payment_value), 2) as menor_compra
FROM vendas
GROUP BY customer_id, customer_city, customer_state
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY valor_total_gasto DESC
LIMIT 20;


 
-- QUERY 8: CATEGORIAS COM MAIOR TICKET MÉDIO



SELECT 
    product_category_name as categoria,
    COUNT(*) as quantidade_vendida,
    ROUND(AVG(payment_value), 2) as ticket_medio,
    ROUND(MIN(payment_value), 2) as preco_minimo,
    ROUND(MAX(payment_value), 2) as preco_maximo,
    ROUND(MAX(payment_value) - MIN(payment_value), 2) as amplitude_preco,
    ROUND(SUM(payment_value), 2) as faturamento_total
FROM vendas
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
HAVING COUNT(*) > 10
ORDER BY ticket_medio DESC
LIMIT 15;


 
-- QUERY 9: ANÁLISE DE CONCENTRAÇÃO - REGRA 80/20
 

WITH customer_revenue AS (
    SELECT 
        customer_id,
        ROUND(SUM(payment_value), 2) as total_gasto,
        COUNT(DISTINCT order_id) as total_pedidos
    FROM vendas
    GROUP BY customer_id
    ORDER BY total_gasto DESC
),
top_20_percent AS (
    SELECT 
        customer_id,
        total_gasto,
        total_pedidos
    FROM customer_revenue
    LIMIT (SELECT COUNT(*) * 0.2 FROM customer_revenue)
)
SELECT 
    COUNT(*) as quantidade_clientes_top20,
    ROUND(SUM(total_gasto), 2) as faturamento_top20,
    ROUND(AVG(total_gasto), 2) as gasto_medio_top20,
    ROUND(SUM(total_pedidos), 0) as total_pedidos_top20,
    ROUND(SUM(total_gasto) * 100.0 / (SELECT SUM(payment_value) FROM vendas), 2) as percentual_faturamento_top20,
    (SELECT COUNT(DISTINCT customer_id) FROM vendas) as total_clientes_base
FROM top_20_percent;



-- QUERY 10: CATEGORIA MAIS VENDIDA POR ESTADO


SELECT 
    customer_state as estado,
    product_category_name as categoria_mais_vendida,
    COUNT(*) as quantidade_vendida,
    ROUND(SUM(payment_value), 2) as faturamento,
    ROUND(AVG(payment_value), 2) as ticket_medio
FROM vendas v1
WHERE customer_state IS NOT NULL 
  AND product_category_name IS NOT NULL
GROUP BY customer_state, product_category_name
HAVING COUNT(*) > 3
  AND COUNT(*)  (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) as cnt
        FROM vendas v2
        WHERE v2.customer_state  v1.customer_state
          AND v2.product_category_name IS NOT NULL
        GROUP BY v2.product_category_name
    )
)
ORDER BY customer_state, quantidade_vendida DESC;


