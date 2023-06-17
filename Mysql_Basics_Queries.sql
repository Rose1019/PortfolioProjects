/* SQL BASICS - CODEBASICS

1> Data Retreival - MULTIPLE TABLES 
   Inner Joins,Left Join,Right Joins,Full Joins,Cross Joins,Analytics on Tables

2> Using MySQL
3> To import .sql file to mysql
	Server-> Data import -> Import from disk -> Import from Self-Contained file -> 
    Browse once we click on '...' -> Select the sql file -> Open -> Import again
    Refresh icon , the data is imported.
*/

/***********************************************************************************************************************************/

/***************** SQL JOINS ****************/

select *
from movies;

select *
from financial;

/* Print all movies along with their title, budget, revenue, currency and unit.*/
/* No NULL values */

select title,budget,revenue,currency,unit
from movies
join financial
using(movies_id);

/* Perform LEFT JOIN on above discussed scenario*/
/* The movies_id = 114,406,412 are not present in Movies table but present in Finanacial table
/* CONCEPT : Left join will return all the records from left table , even if there are no matches in Right table
/* Therefore, the result set contains NULL values for the rows having NO MATCH on the right table. */

select m.movies_id,title,budget,revenue,currency,unit
from movies m
left join financial f
using(movies_id);

/* Perform RIGHT JOIN on above discussed scenario*/
/* The movies_id = 106,112,141 are not present in Financial table but present in Movies table
/* CONCEPT : Right join will return all the records from Right table , even if there are no matches in Left table
/* Therefore, the result set contains NULL values for the rows having NO MATCH on the left table. */

select m.movies_id,title,budget,revenue,currency,unit
from movies m
right join financial f
using(movies_id);


/* Perform FULL JOIN using 'Union' on above two tables*/

select m.movies_id,title,budget,revenue,currency,unit
from movies m
left join financial f
using(movies_id)
UNION
select m.movies_id,title,budget,revenue,currency,unit
from movies m
right join financial f
using(movies_id);

 
/* Print a list of final menu items along with their price for a restaurant.*/
/* CROSS JOIN : used when we dont have any common columns between 2 tables */

select *, concat(name,' ',variant_name) as Item_name, (price+variant_price) as Total_Price
from items
cross join variants;


/************* Analytics on Tables ***********/
/* Find profit for all movies*/
select *
from movies;

select * 
from financials;

select *,(revenue-budget) as Profit
from movies
join financials
using(movie_id);

/* Find profit for all movies in bollywood*/
select *,(revenue-budget) as Profit
from movies
join financials
using(movie_id)
where industry="Bollywood";

/* Find profit of all bollywood movies and sort them by profit amount 
   (Make sure the profit be in millions for better comparisons)*/
   
select distinct (unit)
from financials;

select m.movie_id,title,revenue,budget,unit,
CASE 
 when unit="Thousands" Then round((revenue-budget)/1000,2)
 when unit="Billions" Then round((revenue-budget)*1000,2)
 ELSE (revenue-budget)
END Profit_Millions
from movies m
join financials f
using(movie_id)
where m.industry="Bollywood"
order by Profit_Millions desc;

/************* Join More Than Two Tables *******/
/* Show comma separated actor names for each movie
   JOIN 3 tables : movies,movie_actor,actors*/

select m.movie_id,m.title,group_concat(a.name separator " , ") as actors
from movies m
join movie_actor ma using(movie_id)
join actors a using(actor_id)
group by m.movie_id;


/* Print actor name and all the movies they are part of */

select a.actor_id,name as Actor_Name,group_concat(m.title separator " , ") as Movie_Names
from actors a
join movie_actor ma using(actor_id)
join movies m using(movie_id)
group by a.actor_id;

/* Print actor name and how many movies they acted in*/

select name,
group_concat(m.title separator " | ") as Movie_Names,
count(m.title) as Number_of_movies_acted
from actors a
join movie_actor ma using(actor_id)
join movies m using(movie_id)
group by a.actor_id
order by Number_of_movies_acted desc;

/******************* EXERCISE *************************
/*  Show all the movies with their language names */

select m.title,l.name as Language_Name
from movies m
join languages l using(language_id);

/* Show all Telugu movie names (assuming you don't know the language (id for Telugu)*/

select m.title,m.language_id,l.name as Language_Name
from movies m
join languages l using(language_id)
where l.name ="Telugu";

/* Show the language and number of movies released in that language*/

select l.name as Language_Name,language_id,count(m.movie_id) as Number_of_Movies_released
from movies m
join languages l using(language_id)
group by l.name
order by Number_of_Movies_released desc;


/* Generate a report of all Hindi movies sorted by their revenue amount in millions.Print movie name, revenue, currency, and unit*/

select m.title as Movie_Name,f.revenue as Revenue,f.currency as Currency,f.unit as Unit,l.name as Langauge_Name,
CASE
  When f.unit = "Billions" Then (f.revenue)*1000
  When f.unit = "Thousands" Then (f.revenue)/1000
  ELSE f.revenue
END as Revenue_Millions
from movies m
join languages l using(language_id)
join financials f using(movie_id)
where l.name="Hindi"; 
