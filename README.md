# SQL_public_portfolio

- SQL olist data base from [kaggle](https://www.kaggle.com/code/sepidehsoleimanian/olist-project).

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

10 rows returned

|       | Product_Category         | Minimum  | Average            | Maximum  | Standard_Deviation  |
|-------|---------------------------|----------|--------------------|----------|----------------------|
| 1     | cama_mesa_banho           | 3960.16  | 41536.7025         | 89412.54 | 23274.84602066      |
| 2     | relogios_presentes        | 8086.52  | 41066.208333333336 | 97724.57 | 26047.28077707      |
| 3     | beleza_saude              | 12561.32 | 40146.309166666664 | 79120.4  | 18797.84442421      |
| ...     | ...             | ...  | ...           | ... | ...      |


