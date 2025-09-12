-- Active: 1737261979509@@127.0.0.1@5432@Ola


-----------------------------OLA DATA ANALYTICS-----------------------------

-- Cearting Database--
create database ola;
Drop table if exists  bookings;
CREATE TABLE bookings (
    Date DATE,
    Time TIME,
    Booking_ID VARCHAR(50) PRIMARY KEY,
    Booking_Status VARCHAR(50),
    Customer_ID VARCHAR(50),
    Vehicle_Type VARCHAR(30),
    Pickup_Location VARCHAR(100),
    Drop_Location VARCHAR(100),
    V_TAT VARCHAR(10),
    C_TAT VARCHAR(10),
	Canceled_Rides_by_Customer VARCHAR(65),
    Canceled_Rides_by_Driver VARCHAR(65),
    Incomplete_Rides VARCHAR(30),
    Incomplete_Rides_Reason TEXT,
    Booking_Value NUMERIC(10,2),
    Payment_Method VARCHAR(30),
    Ride_Distance NUMERIC(6,2),
    Driver_Ratings VARCHAR(10),
    Customer_Rating VARCHAR(10)
);

Select count(booking_id) from bookings


-- 1. Retrieve all successful bookings:
select * from bookings
where booking_status = 'success'

-- 2. Find the average ride distance for each vehicle type
select vehicle_type, avg(ride_distance) as Average_Distance from  bookings
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Get the total number of cancelled rides by customers:
select count(Booking_ID) as Total_Number_of_canceled_rides from bookings
where Booking_status = 'Canceled by Customer';

--4. List the top 5 customers who booked the highest number of rides:

SELECT Customer_ID, COUNT(Booking_ID) as total_rides FROM bookings GROUP BY
Customer_ID ORDER BY total_rides DESC LIMIT 5;

-- 5. Get the number of rides cancelled by drivers due to personal and car-related issues:
Select count(Booking_ID) as Total_number_of_rides_cancelled_by_Driver from Bookings
where Booking_status = 'Canceled by Driver' and Canceled_Rides_by_Driver =  'Personal & Car related issue'


-- 6. Find the maximum and minimum driver ratings for Prime Sedan bookings:
SELECT MAX(Driver_Ratings) as max_rating, MIN(Driver_Ratings) as min_rating FROM
bookings WHERE Vehicle_Type = 'Prime Sedan';

-- 7 Retrieve all rides where payment was made using UPI:
SELECT * FROM Bookings WHERE Payment_Method = 'UPI';

-- 8 Find the average customer rating per vehicle type:
Select Vehicle_Type,Avg(Customer_rating) as Average_rating_by_customer from Bookings
GROUP BY 1
ORDER BY 2 DESC;

-- 9. Calculate the total booking value of rides completed successfully:
SELECT SUM(Booking_Value) as total_successful_value FROM bookings WHERE
Booking_Status = 'Success';

-- 10. List all incomplete rides along with the reason:
SELECT Booking_ID, Incomplete_Rides_Reason FROM bookings WHERE Incomplete_Rides =
'Yes';

-----------------------------Advanced Operational & Behavioral Queries-----------------------------

--11 Identify peak booking hours per vehicle type:
SELECT Vehicle_Type, EXTRACT(HOUR FROM Time) AS Booking_Hour, COUNT(Booking_ID) AS Total_Bookings
FROM bookings
GROUP BY Vehicle_Type, Booking_Hour
ORDER BY Vehicle_Type, Total_Bookings DESC;

--12 Detect customers with frequent cancellations (>3 times):
Select customer_id, count(Booking_id) as Cancelled_count from bookings
where booking_status  in('Canceled by Customer' , 'Canceled by Driver')
GROUP BY 1
having count(*) > 3;



-- 13 Find average booking value per payment method:
select payment_method, avg(booking_value) from bookings
GROUP BY 1
ORDER BY 2 DESC;

-- 14 Compare average ride distance between successful and incomplete rides:
SELECT Booking_Status, AVG(Ride_Distance) AS Average_Ride_Distance
FROM bookings
WHERE Booking_Status IN ('Success', 'Canceled by Customer', 'Canceled by Driver')
GROUP BY Booking_Status;

-- 15 Calculate ride completion rate per vehicle type?
Select Vehicle_type,count(case when booking_status = 'Success' then 1 END) as Success_ride_count, 
count(case when booking_status = 'Success' then 1 END) * 100.0/count(booking_id) as completion_rate from Bookings
GROUP BY 1;

-- 16 Find top 5 pickup-drop pairs with longest average ride distance:

SELECT Pickup_Location, Drop_Location, AVG(Ride_Distance) AS Avg_Distance
FROM bookings
GROUP BY Pickup_Location, Drop_Location
ORDER BY Avg_Distance DESC
LIMIT 5;

-- 17 Identify customers with highest average booking value:
select customer_id, avg(booking_value) as Average_Booking_Value from bookings
GROUP BY 1
ORDER BY 2 DESC

-- 18 Find vehicle types with highest cancellation rate:
select Vehicle_Type, 
count(case when booking_status in('Canceled by Customer', 'Canceled by Driver') then 1 END) as Cancelled_count,
count(case when booking_status in('Canceled by Customer', 'Canceled by Driver') then 1 END)* 100.0/count(booking_id) as Cancellation_rate
from Bookings
GROUP BY 1
ORDER BY 3 DESC;


-------------------------Trend & Time Series Analysis-----------------------------
-- 19 Monthly booking trend by vehicle type:

select TO_CHAR(date, 'YYYY-MM') as Year_Month, vehicle_type,Count(*) from bookings
GROUP BY 1,2
ORDER BY  1;

--20 Average ride distance trend over time:
SELECT TO_CHAR(Date, 'yyyy-MM') AS Month, AVG(Ride_Distance) AS Avg_Distance
FROM bookings
GROUP BY 1

-- 21 Booking value trend for UPI payments:
Select TO_CHAR(DATE,'YYYY-MM') as Year_Month, 
SUM(Booking_Value) as Total_UPI_Value from bookings
where Payment_Method = 'UPI'
GROUP BY 1;

-- 22 Ratio of successful to cancelled bookings per customer:
SELECT 
    Customer_ID,
    COUNT(CASE WHEN Booking_Status = 'Success' THEN 1 END) AS Successful,
    COUNT(CASE WHEN Booking_Status IN ('Canceled by Driver', 'Canceled by Customer') THEN 1 END) AS Cancelled,
    ROUND(
        COUNT(CASE WHEN Booking_Status = 'Success' THEN 1 END)::NUMERIC /
        NULLIF(COUNT(CASE WHEN Booking_Status IN ('Canceled by Driver', 'Canceled by Customer') THEN 1 END)::NUMERIC, 0),
        2
    ) AS Success_Cancel_Ratio
FROM 
    bookings
GROUP BY 
    Customer_ID;


-- 23 Average booking value per km per vehicle type:
SELECT Vehicle_Type, AVG(Booking_Value/ NULLIF(Ride_Distance, 0)) AS Avg_Value_per_KM
FROM bookings
GROUP BY Vehicle_Type

-- 19 Analyze correlation between driver ratings and booking value:

----------Location Based Insights-----------------------------

-- 24 Top 5 pickup locations with most cancellations:

SELECT Pickup_Location, COUNT(*) AS Cancelled_Count
FROM bookings
WHERE Booking_Status in ('Canceled by Customer', 'Canceled by Driver')
GROUP BY Pickup_Location
ORDER BY Cancelled_Count DESC
LIMIT 5;

--25 Drop locations with lowest average customer rating:
SELECT 
    ROUND(
        AVG(
            NULLIF(
                regexp_replace(customer_rating, '[^0-9.]', '', 'g'),
                ''
            )::NUMERIC
        ),
        2
    ) AS avg_rating
FROM 
    bookings;


-- 26 Pickup-drop pairs with highest average booking value:
SELECT Pickup_Location, Drop_Location, AVG(Booking_Value) AS Avg_Value
FROM bookings
GROUP BY Pickup_Location, Drop_Location
ORDER BY Avg_Value DESC
LIMIT 5;

-- 27 Vehicle type usage per pickup location:
SELECT Pickup_Location, Vehicle_Type, COUNT(*) AS Usage_Count
FROM bookings
GROUP BY Pickup_Location, Vehicle_Type
ORDER BY Pickup_Location, Usage_Count DESC;

-- 28 Identify locations with high incomplete ride frequency:
SELECT Pickup_Location, COUNT(*) AS Incomplete_Count
FROM bookings
WHERE Incomplete_Rides = 'null'
GROUP BY Pickup_Location
ORDER BY Incomplete_Count DESC;

-- 29 Average ride distance from top 5 pickup locations:
SELECT Pickup_Location, AVG(Ride_Distance) AS Avg_Distance
FROM bookings
WHERE Pickup_Location IN (
    SELECT Pickup_Location
    FROM bookings
    GROUP BY Pickup_Location
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
GROUP BY Pickup_Location;

-- 30 Cancellation reasons analysis by location:
SELECT Pickup_Location, Canceled_Rides_by_Customer, COUNT(*) AS Cancelled_Count
FROM bookings
WHERE Booking_Status = 'Canceled by Customer'
GROUP BY Pickup_Location, Canceled_Rides_by_Customer
ORDER BY Pickup_Location, Cancelled_Count DESC;







