/* SQL BASICS - CODEBASICS

1> COMPLEX QUERIES
	Subquery,ANY/SOME,ALL,Co-related subquery,CTE(Common Table Expression)
    
2> Using MySQL
3> To import .sql file to mysql
	Server-> Data import -> Import from disk -> Import from Self-Contained file -> 
    Browse once we click on '...' -> Select the sql file -> Open -> Import again
    Refresh icon , the data is imported.
*/

/***********************************************************************************************************************************/

/***************** SUBQUERIES ****************/

/*Select a movie with highest imdb_rating WITHOUT SUBQUERY*/

Select MAX(imdb_rating)
from movies;

select *
from movies
order by imdb_rating desc;

/*Select a movie with highest imdb_rating WITH SUBQUERY*/

Select *
from movies
where imdb_rating = ( Select MAX(imdb_rating)
					  from movies
					);

/*Select a movie with highest and lowest imdb_rating*/

Select title,imdb_rating
from movies
where imdb_rating IN (
					( Select MAX(imdb_rating) as Highest_Rating
					  from movies
					) ,
                    ( Select Min(imdb_rating) as Lowest_Rating
					  from movies
					)  
                    );

/*Select all the actors whose age is greater than 70 and less than 85*/

select name as Actor_Name,Actors_Age
from    (
		   select name as Actor_Name,
           (year(curdate()) - birth_year) as Actors_Age
		   from actors
         ) as   Age_Table
where Actors_Age between 70 AND 85;

/* To get the current year */
select year(curdate());

/***************** ANY/SOME,ALL operators ****************/

/*select actors who acted in any of these movies (101,110, 121)*/

/*WITHOUT ANY OPERATOR */
select m.movie_id as Movie_ID,m.title as Movie_Name,
group_concat(a.name separator ' , ') as Actors_Name
from movies m
join movie_actor ma using(movie_id)
join actors a using(actor_id)
where m.movie_id in (101,110,121)
group by m.movie_id;

/*TO AVOID JOINS WE CAN USE ANY OPERATOR*/
select actor_id as Actor_ID,name as Actor_Name
from actors
where actor_id=ANY(select actor_id
				   from movie_actor
				   where movie_id in(101,110,121)
                   group by actor_id
                   );
                   
                   
/*select all movies whose rating is greater than *any* of the marvel movies rating*/
/*WITHOUT ANY OPERATOR - SUBQUERY ,MIN()*/
select title,studio,imdb_rating 
from movies
where imdb_rating > (select min(imdb_rating)
					 from movies
                     where studio="Marvel Studios"
                     );
/*WITH ANY OPERATOR*/
select title,studio,imdb_rating 
from movies
where imdb_rating > ANY(select imdb_rating
					 from movies
                     where studio="Marvel Studios"
                     );


/*select all movies whose rating is greater than *all* of the marvel movies rating*/
/*WITHOUT ALL OPERATOR - SUBQUERY ,MAX()*/
select title,studio,imdb_rating
from movies
where imdb_rating > (Select max(imdb_rating)
					 from movies
                     where studio = "Marvel Studios"
                     );

/*WITH ALL OPERATOR*/					
select title,studio,imdb_rating
from movies
where imdb_rating >ALL (Select imdb_rating
					 from movies
                     where studio = "Marvel Studios"
                     );                     


/***************** Co-Related Subquery ****************/

/*Get the actor id, actor name and the total number of movies they acted in.*/

select actor_id,name,
	   ( select count(*) 
		  from movie_actor ma
          where actors.actor_id=ma.actor_id
         ) as Total_Number_of_Movies_Acted
from actors
order by Total_Number_of_Movies_Acted desc;

/*Above, can be achieved by using Joins too!*/

select actor_id,name as Actor_Name,count(*) as Total_Number_of_Movies_Acted
from movie_actor ma
join actors a
using(actor_id)
group by actor_id
order by Total_Number_of_Movies_Acted;

/******************* EXERCISE *************************/

/* Select all the movies with minimum and maximum release_year. Note that there
can be more than one movie in min and a max year hence output rows can be more than 2*/

select *
from movies
where release_year IN (
						(select min(release_year) from movies), 
						(select max(release_year) from movies)
					  );

/*Select all the rows from the movies table whose imdb_rating is higher than the average rating*/

select avg(imdb_rating)
from movies;

select *
from movies
where imdb_rating > ( select avg(imdb_rating)
					  from movies
                     ); 

/***************** CTE ****************/
/*Select all the actors whose age is greater than 70 and less than 85 
[Previously, we have used sub-queries to solve this. Now we use CTE's]*/
 
 /* SUBQUERY */
 select Actor_Name,Actors_Age
 from ( select name as Actor_Name,(year(curdate())-birth_year) as Actors_Age
		from actors
	   ) as Age_Table
 where Actors_Age between 70 and 85;
 
 select name,(year(curdate())-birth_year) as age
 from actors;
 
 /* CTE */
 with cte_age as( 
					select name as Actors_Name,(year(curdate())-birth_year) as Actors_Age
					from actors
				)
select * 
from cte_age
where Actors_Age between 70 and 85
order by Actors_Age desc;
					
 
/* Movies that produced 500% profit and their rating was less than average rating for all movies */

with 
A_Profit as
(					 select movie_id,revenue,budget,(revenue-budget) as Profit,
                     ((revenue-budget)/budget)*100 as Profit_Pct
                     from financials
                     order by Profit_Pct desc
),					

B_Average as 
(					select movie_id,title,imdb_rating
					from  movies
					where imdb_rating < ( select avg(imdb_rating)
										  from movies
										)
					order by imdb_rating desc 
)	

select 	AP.movie_id,AP.revenue,AP.budget,AP.Profit,AP.Profit_Pct,
		BA.title,BA.imdb_rating
from A_Profit AP
join B_Average BA using(movie_id)
where AP.Profit_Pct >500;
                   
/*Above, can be achieved using sub-query too (But, code readability is less here compared to CTE's)*/

select 	AP.movie_id,AP.revenue,AP.budget,AP.Profit,AP.Profit_Pct,
		BA.title,BA.imdb_rating
from (select movie_id,revenue,budget,(revenue-budget) as Profit,
                     ((revenue-budget)/budget)*100 as Profit_Pct
                     from financials
                     order by Profit_Pct desc) as AP
join 
	(select movie_id,title,imdb_rating
					from  movies
					where imdb_rating < ( select avg(imdb_rating)
										  from movies
										)
					order by imdb_rating desc ) as BA 
using(movie_id)
where AP.Profit_Pct >500;


/******************* EXERCISE *************************/
/*Select all Hollywood movies released after the year 2000 that made more than 500 million $ profit or more profit. 
Note that all Hollywood movies have millions as a unit hence you don't need to do the unit conversion. 
Also, you can write this query without CTE as well but you should try to write this using CTE only*/

with
A as
( 			select	movie_id,title,release_year,industry,
					budget,revenue,(revenue-budget) as Profit
			from movies
            join financials
            using(movie_id)
)
select A.movie_id,A.title,A.release_year,A.industry,A.budget,A.revenue,A.Profit
from A 
where A.industry = "Hollywood" AND A.Profit>=500 AND A.release_year>2000;





