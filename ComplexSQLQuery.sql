
-- Problem set week 3 number 2.

-- Please load music-store database
use musicstore;

-- Please add the proper SQL query to follow the instructions below


------------------------------------------------
use musicstore;
------------------------------------------------

-- 1.Show the Number of tracks whose composer is F. Baltes
-- (Note: there can be more than one composers for each track)
select Composer from Track where Composer regexp('Baltes');

-- 2 tracks featuring Baltes

-- 2.Show the Number of invoices, and the number of invoices with a total amount =0 in the same query
-- (Hint: you can use CASE WHEN)


-- 3.Show the album title and artist name of the first five albums sorted alphabetically
ALTER Table Artist RENAME COLUMN Name TO ArtistName;
ALTER Table Track RENAME COLUMN Name TO TrackName;
ALTER Table Album RENAME COLUMN Title to AlbumTitle;
ALTER Table Genre RENAME COLUMN Name to GenreName;
ALTER Table MediaType RENAME COLUMN Name to MediaName;

select AlbumTitle, ArtistName from Album
Join Artist on Artist.ArtistId = Album.ArtistId 
ORDER BY AlbumTitle ASC 
Limit 5;


-- 4.Show the Id, first name, and last name of the 10 first customers 
-- alphabetically ordered. Include the id, first name and last name 
-- of their support representative (employee)
 select CustomerId, FirstName, LastName from Customer 
 Order BY LastName ASC 
 Limit 10;
 
-- 5.Show the Track name, duration, album title, artist name,
--  media name, and genre name for the five longest tracks

select TrackName, Milliseconds, AlbumTitle, ArtistName, GenreName, MediaName From Track 
Join Album on Album.AlbumId = Track.AlbumId
Join Artist on Artist.ArtistId = Album.ArtistId
Join Genre on Genre.GenreId = Track.GenreId
Join MediaType on MediaType.MediaTypeId = Track.MediaTypeId
Order BY Milliseconds DESC
Limit 5;

-- 6.Show Employees' first name and last name
-- together with their supervisor's first name and last name
-- Sort the result by employee last name
SELECT 
	Employee_Table.FirstName as Employee_First_Name, 
	Employee_Table.LastName as Employee_Last_Name, 
	Manager_Table.FirstName as Manager_First_Name, 
	Manager_Table.LastName as Manager_Last_Name
FROM 
	(SELECT FirstName, LastName, ReportsTo FROM Employee) AS Employee_Table

LEFT JOIN Employee as Manager_Table on Employee_Table.ReportsTo = Manager_Table.EmployeeId
ORDER BY Employee_Table.LastName;

-- 7.Show the Five most expensive albums
--  (Those with the highest cumulated unit price)
--  together with the average price per track

SELECT AlbumTitle, sum(UnitPrice) as Album_Price from Album
Left Join Track on Album.AlbumId = Track.AlbumId
Group by AlbumTitle
Order By Album_price desc
Limit 5;

-- 8. Show the Five most expensive albums
--  (Those with the highest cumulated unit price)
-- but only if the average price per track is above 1
SELECT AlbumTitle, avg(UnitPrice) as Average_Price, sum(UnitPrice) as Album_Price FROM Album
Join Track on Album.AlbumId = Track.AlbumId
Where UnitPrice > 1
Group by AlbumTitle
Order By Album_price desc
Limit 5;

-- In the above I realize that I'm just using UnitPrice because I looked through the data and saw only .99 and 1.99. 
-- However, inserting Average_Price results in an error, as does avg(UnitPrice). Therefore, not sure how I would do it 
-- if the prices were not binary

-- 9.Show the album Id and number of different genres
-- for those albums with more than one genre
-- (tracks contained in an album must be from at least two different genres)
-- Show the result sorted by the number of different genres from the most to the least eclectic 

Select 
	a.AlbumID, 
    Count(Distinct g.GenreId) as Number_of_Genres
FROM Album a
    Left Join Track t on t.AlbumId = a.AlbumId
	Right Join Genre g on g.GenreId = t.GenreId 
Group BY a.AlbumID
HAVING Number_of_Genres <> 1
Order By Number_of_Genres DESC;
 

-- 10.Show the total number of albums that you get from the previous result (hint: use a nested query)
Select count(Number_of_Genres) as Albums_with_Multiple_Genres
FROM 
	(SELECT 
		a.AlbumID, 
		Count(Distinct g.GenreId) as Number_of_Genres
	FROM Album a
		Left Join Track t on t.AlbumId = a.AlbumId
		Right Join Genre g on g.GenreId = t.GenreId 
	Group BY a.AlbumID
	HAVING Number_of_Genres <> 1
	Order By Number_of_Genres DESC) as Genre_Counter;


-- 11.Show the	number of tracks that were ever in some invoice
Select distinct (TrackId) from InvoiceLine
Where Quantity > 0;
-- 2240 (double checked to make sure there were no quantities above 1, got same result)
Select distinct count(TrackId) from InvoiceLine;
Select * from InvoiceLine;


-- 12.Show the Customer id and total amount of money billed to the five best customers 
-- (Those with the highest cumulated billed imports)
Select Total, CustomerId
FROM Invoice i
Order By Total Desc
Limit 5;

-- 13.Add the customer's first name and last name to the previous result
-- (hint:use a nested query)

Select i.Total, c.CustomerId, c.FirstName, c.LastName
FROM Invoice i
Join Customer c on c.CustomerId = i.CustomerId
Order By Total Desc
Limit 5;

-- 14.Check that the total amount of money in each invoice
-- is equal to the sum of unit price x quantity
-- of its invoice lines.

Select i.Total, sum((l.unitprice)*(l.quantity))
From Invoice i
Join InvoiceLine l on l.InvoiceId = i.InvoiceId
Group By l.InvoiceId
Order by i.Total Desc;



-- 15.We are interested in those employees whose customers have generated 
-- the highest amount of invoices 
-- Show first_name, last_name, and total amount generated 

Select e.FirstName, e.LastName, count(distinct i.invoiceid) as Invoices_Generated, sum(i.total) as Revenue_Generated
From Invoice i
Left Join Customer c on i.CustomerId = c.CustomerId
Left Join Employee e on c.SupportRepId = e.EmployeeId
Group By c.SupportRepId;

-- 16.Show the following values: Average expense per customer, average expense per invoice, 
-- and average invoices per customer.
-- Consider just active customers (customers that generated at least one invoice)
SELECT 
    (SELECT AVG(APC) from (
    SELECT Sum(Total)/Count(Distinct CustomerId) as APC
    from Invoice
    Group by CustomerId)
    as A),
    
    (SELECT AVG(EPI) from (
    SELECT sum(total)/Count(InvoiceId) as EPI
    from Invoice
    Group By InvoiceID)
    as B),
    
    (SELECT AVG(IPC) from (
    SELECT count(customerID) as IPC
    from Invoice
    Group BY CustomerId)
    as C);

-- 17.We want to know the number of customers that are above the average expense level per customer. (how many?)

Select count(CustomerId)
	From (
    SELECT CustomerId, Sum(Total) from Invoice
	GROUP BY CustomerId
	Having Sum(Total) > 
     (SELECT AVG(APC) from (
    SELECT Sum(Total)/Count(Distinct CustomerId) as APC
    from Invoice
    Group by CustomerId)
    as A)) AS K;
    
-- 18.We want to know who is the most purchased artist (considering the number of purchased tracks), 
-- who is the most profitable artist (considering the total amount of money generated).
-- and who is the most listened to artist (considering purchased song minutes).
-- Show the results in 3 rows in the following format: 
-- ArtistName, Concept('Total Qubnvczx. antity','Total Amount','Total Time (in seconds)'), Value
-- (hint:use the UNION statement)

SELECT
	count(i.trackid) as Number_of_Tracks, a.ArtistName
    FROM InvoiceLine i
    JOIN Track t ON t.trackid = i.trackid
    JOIN Album b on b.albumid = t.albumid
    JOIN Artist a on a.artistid = b.artistid
    GROUP BY a.ArtistName
    Order BY Number_of_Tracks DESC;
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));


SELECT
	*
	FROM InvoiceLine i
    LEFT JOIN Track t ON t.trackid = i.trackid
    JOIN Album b on b.albumid = t.albumid
    JOIN Artist a on a.artistid = b.artistid
    Group By b.albumid;





