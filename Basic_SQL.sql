-- Please add the proper SQL query to follow the instructions below  

-- 1) Select ecommerce as your default database 
use ecommerce;

-- 2) Show the PK, name, and quantity per unit from all products
SELECT ProductID, ProductName, QuantityPerUnit FROM products;


-- 3) Show the number of products ever on sale in our stores
SELECT COUNT(ProductID) from order_details;
SELECT DISTINCT (ProductID) from order_details;

-- 2155 is number of total products sold. 77 is the number of distinct products sold.

-- 4) Show the number of products in stock (available right now) in our store
SELECT COUNT(UnitsinStock) from products;
-- 77

--  5) Show the number of products with more orders than stock
Select count(ProductID) from products where UnitsOnOrder > UnitsInStock;


-- 6) List all products available in the store and order them alphabetically from a to z 
-- Show just the first ten products 
Select ProductName from products order by ProductName ASC LIMIT 10;
-- 'Alice Mutton', 'Aniseed Syrup' 'Boston Crab Meat''C?te de Blaye''Camembert Pierrot''Carnarvon Tigers''Chai''Chang''Chartreuse verte''Chef Anton\'s Cajun Seasoning'


--  7) Create a new table called scustomers with all the customers from a country that starts with the letter S
CREATE TABLE scustomers AS (SELECT * FROM customers WHERE Country LIKE 'S%');

--  8) Delete the previously created table
DROP TABLE scustomers;


--  9) Show how many customer the store has from Mexico
select count(Country) from customers where Country like 'Mexico';
-- 5

-- 10) Show how many different countries our customers come from
select distinct count(country) from customers;
-- 90

--  11) Show how many customers are from Mexico, Argentina, or Brazil 
--  whose contact title is  Sales Representative or a Sales Manager
select count(country), count(ContactTitle) from customers 
WHERE (country="Mexico" OR country="Argentina" OR country="Brazil")
AND (ContactTitle="Sales Representative" OR ContactTitle="Sales Manager");
-- 4

--  12) Show the number of employees that were 50 years old or more 
--  as at 2014-10-06 (you will probably need to use the DATE_FORMAT function) 

SELECT count(Birthdate)
FROM employees
where YEAR('2014-10-06') - YEAR(Birthdate) >= 50;

-- 7 

--  13) Show the age of the oldest employee of the company
--  (hint: use the YEAR and DATE_FORMAT functions)
SELECT min(Birthdate)
FROM employees;

SELECT TIMESTAMPDIFF(YEAR, (select min(Birthdate) from employees), '2014-10-06');

-- 62

--  14) Show the number of products whose quantity per unit is measured in bottles
select distinct count(QuantityPerUnit) from products where QuantityPerUnit like "%bottles%";

-- 11

-- 15) Show the number of customers with a Spanish or British common surname
--  (a surname that ends with -on or -ez)
select count(ContactName) from customers where ContactName like "%on" or ContactName like "%ez";

-- 11


--  16) Show how many distinct countries our 
--  customers with a Spanish or British common surname come from
--  (a surname that ends with -on or -ez)
select distinct Country from customers where (ContactName like "%on" or ContactName like "%ez");
 -- 7
 

--  17) Show the number of products whose names do not contain the letter 'a'
--  (Note: patterns are not case sensitive)
select ProductName from products where not ProductName like '%a%';
select distinct count(ProductName) from products where not ProductName like '%a%';

-- 19

--  18) Get the total number of items sold ever.
select sum(quantity) from order_details;

-- 51317

--  19) Get the id of all products sold at least one time
SELECT distinct ProductID from order_details where Quantity>0 ORDER BY ProductID ASC;

-- Technically no products were ever sold if the unit price of all of the products is zero, however that answer 
-- does not seem right

--  20) Is there any product that was never sold? Which ones?

SELECT ProductId FROM products
WHERE ProductID NOT IN 
(SELECT DISTINCT ProductID FROM order_details);
-- There are no product IDs not in order_details. None of them were ever 'sold' per se, if the price was 0 for all of them. 

