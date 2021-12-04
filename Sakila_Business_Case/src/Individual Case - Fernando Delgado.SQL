/* Fernando Delgado */

/********************************/
/*******FINANCIAL ANALYSIS******/
/******************************/


/* MONTHLY SALES AND REVENUE BY STORE */


SELECT 
strftime('%m', p.payment_date) as Month, 
strftime('%Y', p.payment_date)as Year,
sum(CASE WHEN store_id = 1 THEN 1 ELSE 0 END) AS Rentals_Store1,
round(sum(CASE WHEN store_id = 1 THEN p.amount ELSE 0 END),1) AS Revenue_Store1,
sum(CASE WHEN store_id = 2 THEN 1 ELSE 0 END) AS Rentals_Store2,
round(sum(CASE WHEN store_id = 2 THEN p.amount ELSE 0 END),1) AS Revenue_Store2,
count(*) AS Total_Rentals,
round(sum(p.amount),1) AS Total_Revenue
FROM payment AS p 
INNER JOIN rental AS r USING (rental_id)
INNER JOIN staff AS s USING(staff_id)
INNER JOIN store AS st USING (store_id)
GROUP BY Month
ORDER BY Year;


/* YEARLY SALES AND REVENUE BY STORE */


SELECT strftime('%Y', p.payment_date) AS Year, 
sum(CASE WHEN store_id = 1 THEN 1 ELSE 0 END) AS Rentals_Store1,
round(sum(CASE WHEN store_id = 1 THEN p.amount ELSE 0 END),1) AS Revenue_Store1,
sum(CASE WHEN store_id = 2 THEN 1 ELSE 0 END) AS Rentals_Store2,
round(sum(CASE WHEN store_id = 2 THEN p.amount ELSE 0 END),1) AS Revenue_Store2,
count(*) AS Total_Rentals,
round(sum(p.amount),1) AS Total_Revenue
FROM payment AS p 
INNER JOIN rental AS r USING (rental_id)
INNER JOIN staff AS s USING(staff_id)
INNER JOIN store AS st USING (store_id)
GROUP BY year;



/* MONTHLY AVERAGE PRICE PER RENTAL BY STORE */

SELECT 
strftime('%m', p.payment_date) as Month, 
strftime('%Y', p.payment_date) as Year,
round(avg(CASE WHEN store_id = 1 THEN p.amount END),1) AS Store_1,
round(avg(CASE WHEN store_id = 2 THEN p.amount END),1) AS Store_2,
round(avg(p.amount),1) AS Total_AvgPricePerRental
FROM payment AS p 
INNER JOIN rental AS r USING (rental_id)
INNER JOIN staff AS s USING(staff_id)
INNER JOIN store AS st USING (store_id)
GROUP BY Month
ORDER BY Year;


/* YEARLY AVERAGE PRICE PER RENTAL BY STORE */


SELECT 
strftime('%Y', p.payment_date) as Year,
avg(CASE WHEN store_id = 1 THEN p.amount END) AS Store_1,
avg(CASE WHEN store_id = 2 THEN p.amount END) AS Store_2,
avg(p.amount) AS Total_AvgPricePerRental
FROM payment AS p 
INNER JOIN rental AS r USING (rental_id)
INNER JOIN staff AS s USING(staff_id)
INNER JOIN store AS st USING (store_id)
GROUP BY Year;


/********************************/
/*******CUSTOMER ANALYSIS******/
/******************************/


/* ACTIVE AND INACTIVE CUSTOMERS */


SELECT 
sum(CASE WHEN active = 1 THEN 1 ELSE 0 END) AS Active_Customers,
sum(CASE WHEN active = 0 THEN 1 ELSE 0 END) AS Inactive_Customers,
count(*) AS Total_Customers
FROM customer;


/* FREQUENCY RECENCY AND MONETARY VALUE ON AVERAGE CUSTOMER */


SELECT round(avg(NbrofRentals),1) as Frequency, round(avg(YearsSinceLastPurchase),1) AS Recency, round(avg(avgmoney),1) AS Monetary_Value
FROM 
    (SELECT count(*) AS NbrofRentals, date('now') - max(payment_date) AS YearsSinceLastPurchase, avg(amount) AS avgmoney
    FROM payment
    GROUP BY customer_id);


/* CUSTOMER TENURE */


SELECT avg(YearsSinceRegistration) AS Tenure
FROM 
    (SELECT date('now') - create_date AS YearsSinceRegistration
    FROM customer
    WHERE active = 1
    GROUP BY customer_id);
    

/* CUSTOMER LOCATION AND MARKET SHARE */

SELECT
CASE WHEN country IN ('Austria', 'Belarus', 'Bulgaria', 'Czech Republic', 'Estonia', 'Faroe Islands', 'Finland', 'France', 'Germany', 'Greece', 'Holy See (Vatican City State)',
'Hungary', 'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 'Moldova', 'Netherlands', 'Poland', 'Romania', 'Russian Federation', 'Slovakia', 'Spain', 'Sweden', 'Switzerland', 'Turkey', 
'Ukraine', 'United Kingdom', 'Yugoslavia') THEN 'Europe'

WHEN country IN ('Argentina', 'Bolivia', 'Brazil',  'Chile', 'Colombia', 'Dominican Republic', 'Ecuador', 'French Guiana', 'Paraguay', 'Peru', 'Puerto Rico',
'Saint Vincent and the Grenadines', 'Venezuela') THEN 'South America'

WHEN country IN ('Anguilla', 'Canada', 'Greenland', 'Mexico', 'United States', 'Virgin Islands, U.S.')THEN 'North America'

WHEN country IN ('Algeria', 'Angola', 'Cameroon', 'Chad','Congo, The Democratic Republic of the', 'Egypt', 'Ethiopia', 'Gambia', 'Kenya', 'Kuwait', 'Madagascar', 'Malawi', 'Morocco', 'Mozambique', 
'Nigeria', 'Runion', 'Senegal', 'South Africa', 'Sudan', 'Tanzania', 'Tunisia', 'Zambia') THEN 'Africa'

WHEN country IN ('Afghanistan', 'Armenia', 'Azerbaijan', 'Bahrain', 'Bangladesh', 'Brunei', 'Cambodia', 'China', 'Hong Kong', 'India', 'Indonesia', 'Iran', 'Iraq', 'Israel', 'Japan', 'Kazakstan',  
'Malaysia', 'Myanmar', 'Nepal', 'North Korea', 'Oman', 'Pakistan', 'Philippines', 'Saudi Arabia', 'South Korea', 'Sri Lanka', 'Taiwan', 'Thailand', 'Turkmenistan', 'United Arab Emirates', 
'Vietnam', 'Yemen') THEN 'Asia'

WHEN country IN ('American Samoa', 'Australia', 'French Polynesia', 'Nauru', 'New Zealand', 'Tonga', 'Tuvalu') THEN 'Oceania'
ELSE 'Other' END AS Region,
count(distinct(cu.customer_id)) AS Number_of_Customers,
round((cast (count(distinct(cu.customer_id))as REAL) / cast((select count(*) FROM customer) as REAL) * 100),1) AS 'Customer_%',
round(sum(p.amount),1) AS Sales_By_Region,
round(sum(p.amount) / (SELECT sum(amount) FROM payment) * 100 ,1) AS 'Market_Share_%'
FROM customer AS cu
INNER JOIN address AS a USING(address_id)
INNER JOIN city AS ci USING(city_id)
INNER JOIN country AS c USING(country_id)
INNER JOIN payment AS p USING(customer_id)
GROUP BY Region
ORDER BY 4 DESC;

/********************************/
/**INTERNAL BUSINESS PROCESSES**/
/******************************/


/* TOP 10 DVDs BY RENTALS */


SELECT film_id, count(r.rental_id) AS Nbr_Of_Rentals, c.name AS category
FROM film 
INNER JOIN inventory AS i USING(film_id)
INNER JOIN rental AS r USING(inventory_id)
INNER JOIN film_category as fc USING (film_id)
INNER JOIN category AS c USING (category_id)
GROUP BY title
ORDER BY Nbr_Of_Rentals DESC
LIMIT 10;


/* CATEGORIES RANK BY RENTAL RATE */ 


SELECT c.name AS Category, round(AvgRentalRate,1) AS Avgerage_Rental_Rate,
CASE WHEN AvgRentalRate > 3.1 THEN 'Good'
WHEN AvgRentalRate > 2.8 THEN 'Average'
ELSE 'Bad'
END AS Rank

FROM(SELECT c.name, avg(rental_rate) AS AvgRentalRate
FROM category AS c
INNER JOIN film_category as fc USING (category_id)
INNER JOIN film AS f USING (film_id)
GROUP BY c.name
ORDER BY 2 DESC);


/*  ACTORS RANK BY RENTAL RATE  */


SELECT a.first_name, a.Last_Name, round(AvgRentalRate,1) AS AvgRentalRate,
CASE WHEN AvgRentalRate > 3.1 THEN 'Good'
WHEN AvgRentalRate > 2.8 THEN 'Average'
ELSE 'Bad'
END AS Rank
FROM 
        (SELECT a.first_name, a.Last_Name, avg(rental_rate) AS AvgRentalRate
        FROM actor AS a
        INNER JOIN film_actor as fa USING (actor_id)
        INNER JOIN film AS f USING (film_id)
        GROUP BY 1
        ORDER BY 3 DESC);


/*  NUMBER OF ACTORS BY RANK  */


SELECT 
CASE WHEN AvgRentalRate > 3.1 THEN 'Good'
WHEN AvgRentalRate > 2.8 THEN 'Average'
ELSE 'Bad'
END AS Rank,
count(*) AS Nbr_of_Actors
FROM 
        (SELECT a.first_name, a.Last_Name, avg(rental_rate) AS AvgRentalRate
        FROM actor AS a
        INNER JOIN film_actor as fa USING (actor_id)
        INNER JOIN film AS f USING (film_id)
        GROUP BY 1
        ORDER BY 3 DESC)
    GROUP BY RANK;


/* MOVIES NOT IN INVENTORY AND COST OF RE-STOCK */


SELECT count(*) AS Missing_Movies, sum(stock) AS Total_Inventory, round(avg(replacement_cost),1) AS Avg_Replacement_Cost, round((sum(replacement_cost) *4),1)AS Restock_Cost
FROM (
SELECT film_id, c.name, count(i.inventory_id) AS stock, count(r.rental_id) AS Nbr_Of_Rentals, replacement_cost
FROM film 
LEFT JOIN inventory AS i USING(film_id)
LEFT JOIN rental AS r USING(inventory_id)
LEFT JOIN payment AS p USING(rental_id)
LEFT JOIN film_category AS fc USING (film_id)
LEFT JOIN category AS c USING (category_id)
GROUP BY film_id
HAVING Nbr_Of_Rentals = 0)
;

/* MOVIES WORTH REPLACING DUE TO CATEGORY */

SELECT c.name AS category, count(*) AS Missing_Movies, sum(stock) AS Total_Inventory, round(avg(replacement_cost),1) AS Avg_Replacement_Cost, round((sum(replacement_cost) *4),1) AS Restock_Cost
FROM (
SELECT film_id, c.name, count(i.inventory_id) AS stock, count(r.rental_id) AS Nbr_Of_Rentals, replacement_cost
FROM film 
LEFT JOIN inventory AS i USING(film_id)
LEFT JOIN rental AS r USING(inventory_id)
LEFT JOIN payment AS p USING(rental_id)
LEFT JOIN film_category AS fc USING (film_id)
LEFT JOIN category AS c USING (category_id)
GROUP BY film_id
HAVING Nbr_Of_Rentals = 0)
GROUP BY 1
HAVING category = 'New' OR category = 'Games' OR category = 'Travel' OR category = 'Sci-Fi' OR category = 'Comedy' OR category = 'Sports';

/* TOTAL INVESTMENT OF MOVIES WORTH REPLACING DUE TO CATEGORY */

SELECT count(*) AS Missing_Movies, sum(stock) AS Total_Inventory, round(avg(replacement_cost),1) AS Avg_Replacement_Cost, round((sum(replacement_cost) *4),1) AS Restock_Cost
FROM (
SELECT film_id, c.name AS category, count(i.inventory_id) AS stock, count(r.rental_id) AS Nbr_Of_Rentals, replacement_cost
FROM film 
LEFT JOIN inventory AS i USING(film_id)
LEFT JOIN rental AS r USING(inventory_id)
LEFT JOIN payment AS p USING(rental_id)
LEFT JOIN film_category AS fc USING (film_id)
LEFT JOIN category AS c USING (category_id)
GROUP BY film_id
HAVING Nbr_Of_Rentals = 0)
WHERE category = 'New' OR category = 'Games' OR category = 'Travel' OR category = 'Sci-Fi' OR category = 'Comedy' OR category = 'Sports';


/* Employees that are Customers */


SELECT *
FROM customer
WHERE address_id IN 
    (SELECT address_id 
    FROM staff)

