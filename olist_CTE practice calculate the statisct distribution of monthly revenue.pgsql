-- CTE practice:
-- The leadership team at Olist wants to understand the distribution of monthly 
-- revenue throughout 2018 from the top 10 best-selling product category.

-- Calculate descriptve statistics for monthly revenue by product category in 2017
-- -> | Product_Category | Minimum | Avarage | Maximum | Standard_Deviation

-- What we have to do?
-- First, we need to sum the (price * quantity) by product category and by month
-- So, we need to join information from tables:
    -- * orders: order_purchase_timestamp
    -- * itens: price
    -- * products: product_category_name
    -- * Do we have information about quantity??? Where is it? *
-- Then, calculate the asked statistics by month and by seller

-- But we don't have the direct information of quantity.
    -- So, let suppose that each order calls as many itens that are
    -- ordered. Ex.: If a custumer order 3 balls, the order will have 3 itens.
    -- let's check this hypothesis:

SELECT
    order_id,
    product_id,
    price,
    count(item_id) AS quantity
FROM itens
GROUP BY
    order_id,
    product_id,
    price
HAVING
    count(item_id) > 1
LIMIT 30;

-- YES! In the same order we could have more than one item for the same product (and same price).

WITH finally AS (
    WITH subresult as (
        WITH first_join as (
            SELECT
                itens.order_id,
                itens.price,
                -- itens.product_id,
                -- products.product_id,
                products.product_category_name
            FROM
                itens
            LEFT JOIN products
                ON     itens.product_id = products.product_id
        )
        SELECT
            product_category_name,
            price,
            date_trunc('month', order_purchase_timestamp) AS order_month
        FROM
            first_join
        LEFT JOIN orders
            ON     first_join.order_id = orders.order_id
        WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2017
    )
    SELECT
        order_month,
        product_category_name,
        SUM(price) AS revenue
    FROM subresult
    GROUP BY
        order_month,
        product_category_name
)
SELECT
    product_category_name AS Product_Category,    
    min(revenue) as Minimum,
    avg(revenue) as Avarage,
    max(revenue) as Maximum,
    stddev(revenue) Standard_Deviation
FROM finally
GROUP BY product_category_name
ORDER BY sum(revenue) DESC
LIMIT 10;
