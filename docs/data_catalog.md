# **Data dictionary for The Gold Layer**

## overview
The gold layer represents the highest level of data refinement in a modern data architecture, typically following the bronze (raw) and silver (cleaned) layers in a medallion architecture pattern. 
It is business level data structure to support data analytics and reporting.
It consists of dimensional tables in our case 'gold.dim_customers' and 'gold.dim_products' and fact tables like 'gold.fact_sales'.

## 1. gold.dim_customers

 - **Purpose:** stores customers data including demographic and geographic data.
 - **Columns:**
   
| Column name | Data type | Description |
|--|--|--|
| customer_key | bigint | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id | int | Unique numerical identifier assigned to each customer.  |
| customer_number | nvarchar(50) | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| first_name | nvarchar(50) | The customer's first name, as recorded in the system (e.g.,'Louis'). |
| last_name | nvarchar(50) | The customer's last name or family name, as recorded in the system (e.g.,'Tang'). |
| country | nvarchar(50) | The country of residence for the customer (e.g., 'Australia'). |
| gender | nvarchar(50) | The gender of the customer (e.g.,'Male','Female' or 'n/a'). |
| marital_status | nvarchar(50) | The marital status of the customer (e.g., 'Married','Single'). |
| birth_date | date | The date of birth of the customer, formatted as YYY-MMM-DD (e.g., 1971-10-06). |
| create_date | date | The date when the customer record was created in the system. |

## 2. gold.dim_products

- **Purpose:** stores Product data including Product type and date.
 - **Columns:**
 
| Column name | Data type | Description |
|--|--|--|
| product_key | bigint | Surrogate key uniquely identifying each product record in the product dimension table. |
| product_id | int | A unique identifier assigned to the prodcut of internal tracking and referencing. |
| product_number | nvarchar(50) | A structured alphanumeric code representing the product often used for categorization or inventory. |
| product_name | nvarchar(50) | Descriptive name of the product including key details such as type, color and size. |
| product_cost | int | The cost or base price of the product, measured in monetary units. |
| product_line | nvarchar(50) | The specific product line or series to which the product belongs (e.g., 'Road', 'Mountain') |
| category_id | nvarchar(50) | A unique identifier for the product's category linking to its high-level classification. |
| category | nvarchar(50) | The broader classification of the product (e.g., Bikes, Components) to group related items. |
| subcategory | nvarchar(50) | A more detailed classification of the product withing the category, such as product type. |
| maintenance | nvarchar(50) | indicates whether the product requires maintenance (e.g., 'Yes','No').|
| starting_date | date | The date when the product became available for sale or use, stored in. |

## 3. gold.fact_sales

- **Purpose:** stores transactional sales data for analytical purposes.
 - **Columns:**
 
| Column name | Data type | Description |
|--|--|--|
| order_number | NVARCHAR(50)| A unique alphanumeric identifier for each sales order (e.g., 'SO54496'). |
| product_key | int | Surrogated key linking the order to the product dimension table. |
| customer_key | int | Surrogated key linking the order to the customer dimension table. |
| order_date | date | The date when the order was placed. |
| shipping_date | date | The date when the order was shipped to the customer. |
| due_date | date | The date when the order payment was due. |
| sales_amout | int | The total monetary value of the sale for the line item, in whole currency units (e.g., 25). |
| quantity | int | The number of units of the product ordered for the line item (e.g., 1). |
| price | int | The price per unit of the product for the line item, in whole currency units (e.g., 25). |
