# SQL_public_portfolio

- SQL olist data base from [kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## <p align = "center">:pushpin: [Exercise #1](https://github.com/AndreRosaLopes/SQL_public_portfolio/blob/main/Creating%20the%20data%20base%20olist.pgsql): setting a postgreSQL data base </p>

This is how the Entity Relationship Diagram looks like:
![ERD_olist](https://github.com/AndreRosaLopes/AndreRosaLopes/assets/135834696/cb9a1338-c348-4728-af01-2e45b25742b8)


## <p align = "center">:pushpin: [Exercise #2](https://github.com/AndreRosaLopes/SQL_public_portfolio/blob/main/olist_CTE%20practice%20calculate%20the%20statisct%20distribution%20of%20monthly%20revenue.pgsql): CTE practice </p>
The leadership team at Olist wants to understand the distribution of monthly revenue throughout 2018 from the top 10 best-selling product category.

Calculate descriptve statistics for monthly revenue by product category in 2017
|   | Product_Category         | Minimum  | Average            | Maximum  | Standard_Deviation  |
|-------|---------------------------|----------|--------------------|----------|----------------------|
| ...     | ...             | ...  | ...           | ... | ...      |

### :pencil2:<i> Answer</i>:

What we have to do?

First, we need to sum the (price * quantity) by product category and by month. So, we need to join information from tables:
* orders: order_purchase_timestamp
* itens: price
* products: product_category_name
* Do we have information about quantity??? Where is it? (we have to check some hypothesis)
Then, calculate the asked statistics by month and by seller

10 rows returned

|       | Product_Category         | Minimum  | Average            | Maximum  | Standard_Deviation  |
|-------|---------------------------|----------|--------------------|----------|----------------------|
| 1     | cama_mesa_banho           | 3960.16  | 41536.7025         | 89412.54 | 23274.84602066      |
| 2     | relogios_presentes        | 8086.52  | 41066.208333333336 | 97724.57 | 26047.28077707      |
| 3     | beleza_saude              | 12561.32 | 40146.309166666664 | 79120.4  | 18797.84442421      |
| ...     | ...             | ...  | ...           | ... | ...      |

## <p align = "center">:pushpin: [Exercise #3](https://github.com/AndreRosaLopes/SQL_public_portfolio/blob/main/olist_performance_of_top_5_sellers.pgsql): WINDOWS function practice </p>

Analyse how the top 5 seller of 2017 are performance along the year 2018:
For each month, show:
 * amount revenue by currently MONTH
 * the running total of year
 * compare the currently revenue with 12 monthy ago

### :pencil2:<i> Answer</i>:
Let's use windows function

What we need?
- price from table itens
- seller_id from table itens (unhappyly we don't have the seller name, I guess it because this is a confidential information)

<b>Please be aware that for some months sellers have not been able to earn their revenue.
In that case the **LAG function** will not bring the correct value!! </b>
I used self-join in that case...

![image](https://github.com/AndreRosaLopes/SQL_public_portfolio/assets/135834696/41028e6e-7ec1-41d2-8ce9-6aa5ef3ea605)

37 rows returned

| seller_id                         | date                  | currently_monthly_revenue | running_total | compare_monthly_revenue |
|-----------------------------------|-----------------------|---------------------------|---------------|-------------------------|
| 46dc3b2cc0980fb8ec44634e21d2718e | 2018-01-01 00:00:00   | 3819.83                   | 3819.83       | 3029.87                 |
| 46dc3b2cc0980fb8ec44634e21d2718e | 2018-02-01 00:00:00   | 1389.94                   | 5209.77       | 3339.93                 |
| 46dc3b2cc0980fb8ec44634e21d2718e | 2018-03-01 00:00:00   | 3119.94                   | 8329.71       | 2719.88                 |
| 46dc3b2cc0980fb8ec44634e21d2718e | 2018-04-01 00:00:00   | 929.95                    | 9259.66       | 1698.85                 |
| 46dc3b2cc0980fb8ec44634e21d2718e | 2018-05-01 00:00:00   | 2049.90                   | 11309.56      | 5509.70                 |
| 46dc3b2cc0980fb8ec44634e21d2718e | 2018-06-01 00:00:00   | 2599.87                   | 13909.43      | 9009.60                 |
| ... | ...   | ...                   | ...      | ...                |
