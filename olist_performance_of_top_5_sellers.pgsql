-- Analyse how the top 5 seller of 2017 are performance along the year 2018:
-- For each month, show:
-- * amount revenue by currently MONTH
-- * the running total of year
-- * compare the currently revenue with 12 monthy ago

-- Let's use windows function
-- What we need?
-- price from table itens
-- seller_id from table itens (unhappyly we don't have the seller name, I guess it because this is a confidential information)

-- Please be aware that for some months sellers have not been able to earn their revenue.
-- In that case the LAG function will not bring the correct value!!

WITH top_5_montlhy as(
    WITH top_sellers as (
        SELECT
            seller_id AS seller,
            SUM(price)
        FROM itens
        WHERE EXTRACT(YEAR FROM shipping_limit_date) = 2017
        GROUP BY seller_id
        ORDER BY SUM(price) DESC
        LIMIT 5
    )
    SELECT
        date_trunc('month', shipping_limit_date) AS date,
        i.seller_id,
        sum(price) AS revenue
    FROM itens AS i
    INNER JOIN top_sellers AS t
        ON i.seller_id = t.seller
    GROUP BY date_trunc('month', shipping_limit_date), seller_id
)
SELECT
    t1.seller_id,
    t1.date,
    t1.revenue AS currently_monthly_revenue,
    SUM(t1.revenue) OVER(
        PARTITION BY t1.seller_id
        ORDER BY t1.date
        ) AS running_total,
    CASE 
        WHEN t2.revenue IS NULL 
        THEN 0 
        ELSE t2.revenue 
        END AS compare_monthly_revenue
FROM top_5_montlhy t1
LEFT JOIN top_5_montlhy t2
    ON t1.seller_id = t2.seller_id AND t1.date = (t2.date + INTERVAL '12 MONTH')
WHERE EXTRACT(YEAR FROM t1.date) = 2018
ORDER BY t1.seller_id, t1.date
