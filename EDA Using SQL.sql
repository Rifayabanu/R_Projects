select * from project2.raw_sales_data;

-- Finding duplicate entries
select Customer_Name,Order_Date, count(*) as duplicate_count
from project2.raw_sales_data
group by Customer_Name, Order_Date
having count(*) > 1; 

-- Create new table without duplicates
create table project2.clean_sales_datea_1 as
select min(Order_ID) as Order_Id, Customer_Name,Email,Phone,Product_Category,Order_Date,Revenue,`Discount (%)`
from project2.raw_sales_data 
group by Customer_Name,Email,Phone,Product_Category,Order_Date,Revenue,`Discount (%)`;

select * from project2.clean_sales_datea_1;
SET SQL_SAFE_UPDATES = 0;

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe mode

-- Update email to 'not_provided@email.com' when the cell is empty
update project2.clean_sales_datea_1 set Email='not_provided@email.com' where Email='';



-- update phone number to '0000000000' when the cell is empty
update project2.clean_sales_datea_1 set Phone='0000000000' where Phone='';

-- update discount to 0 when the cell is empty
update project2.clean_sales_datea_1 set `Discount (%)`= 0.0 where `Discount (%)`='';

-- Update date format to YYYY-MM-DD
UPDATE project2.clean_sales_datea_1
SET Order_Date = 
    CASE 
        -- MM/DD/YYYY format (e.g., 12/31/2023)
        WHEN Order_Date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' 
        THEN STR_TO_DATE(Order_Date, '%m/%d/%Y')  

        -- YYYY/MM/DD format (e.g., 2024/01/12)
        WHEN Order_Date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' 
        THEN STR_TO_DATE(Order_Date, '%Y/%m/%d')  

        -- YYYY-MM-DD format (e.g., 2024-03-08)
        WHEN Order_Date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
        THEN STR_TO_DATE(Order_Date, '%Y-%m-%d')  

        -- MM-DD-YYYY format (e.g., 02-15-2024)
        WHEN Order_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' 
        THEN STR_TO_DATE(Order_Date, '%m-%d-%Y')  

        -- DD-MM-YYYY format (e.g., 01-05-2024, European format)
        WHEN Order_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' 
        THEN STR_TO_DATE(Order_Date, '%d-%m-%Y')  

        ELSE NULL  -- If the format is unrecognized, set it to NULL (or handle differently)
    END;

ALTER TABLE project2.clean_sales_data  
MODIFY COLUMN Order_Date DATE;

 
--  Identifying Sales Trendz
-- 1. Revenue by each category
select Product_Category, sum(Revenue) from project2.clean_sales_datea_1 group by Product_Category;

-- 2. Revenue by Month
select monthname(Order_Date) as MONTH, sum(Revenue) as Revenue from project2.clean_sales_datea_1 group by monthname(Order_Date);

-- 3. Average discount by product category
select Product_Category, round(avg(`Discount (%)`)) as Average_Discount from project2.clean_sales_datea_1 group by Product_Category;

-- 4. Number of sales per month
select monthname(Order_Date) as Month, count(Order_Date) as Num_of_Sales from project2.clean_sales_datea_1 group by monthname(Order_Date);

-- 5. Revenue per month for each category
select monthname(Order_Date) as Month, Product_Category, sum(Revenue) as Revenue 
from project2.clean_sales_datea_1 
group by monthname(Order_Date), Product_Category;
