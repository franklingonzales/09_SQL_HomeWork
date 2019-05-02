-- Franklin's homework --
use sakila;
-- 1a. Display the first and last names of all actors from the table actor. --
select first_name, last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. --
select concat(first_name,', ',last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, --
-- "Joe." What is one query would you use to obtain this information? --
select actor_id, first_name, last_name from actor where first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters GEN: --
select first_name, last_name from actor  where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order: --
select last_name, first_name from actor  where last_name like '%LI%' order by last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China: --
select country_id, country from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, -- 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, --
-- as the difference between it and VARCHAR are significant). --
alter table actor add description BLOB;
select * from actor;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column. --
alter table actor drop description;
select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name. --
select distinct(last_name), count(last_name) as number_of_actors from actor group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names --
-- that are shared by at least two actors --
select last_name, first_name, count(last_name) as number_of_actors 
from actor 
group by last_name, first_name
having count(first_name)>=2;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record. --
update actor 
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! --
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. --
update actor 
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? --
show create table address;
/* 
+---------+-------------------------------------------------------------------------------------------------------------+
| Table   | Create Table                                                        										|
+---------+-------------------------------------------------------------------------------------------------------------+
| address | CREATE TABLE `address` (                                            										|
|         | `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT, 													|
|         |	`address` varchar(50) NOT NULL,																				|
|         |	  `address2` varchar(50) DEFAULT NULL,																		|
|         |	  `district` varchar(20) NOT NULL,																			|
|         |	  `city_id` smallint(5) unsigned NOT NULL,																	|
|         |	  `postal_code` varchar(10) DEFAULT NULL,																	|
|         |	  `phone` varchar(20) NOT NULL,																				|
|         |   `location` geometry NOT NULL,																				|
|         |	  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,					|
|         |	  PRIMARY KEY (`address_id`),																				|
|         |	  KEY `idx_fk_city_id` (`city_id`),																			|
|         |	  SPATIAL KEY `idx_location` (`location`),																	|
|         |	  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE		|
|         | ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8 													|
+---------+-------------------------------------------------------------------------------------------------------------+
*/


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address: --
select t1.first_name, t1.last_name, t2.address 
from staff t1
inner join address t2
where t1.address_id = t2.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. --
select t1.first_name, t1.last_name, sum(t2.amount) as total_amount from staff t1
inner join payment t2
where t1.staff_id = t2.staff_id and 
date(payment_date) between '2005-08-01' and '2005-08-30'
group by t1.first_name, t1.last_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join. --
select t1.title, count(t2.actor_id) as number_of_actors from film t1
inner join film_actor t2
where t1.film_id = t2.film_id
group by t1.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system? --
-- First, we look movie's id_film. --
select film_id, title from film
where title = 'Hunchback Impossible';
-- Second, id_film = 439, so now we execute INNER JOIN statement 
select t1.title, count(t2.film_id) as number_of_copies from film t1
inner join inventory t2
where t1.film_id=439 and t1.film_id = t2.film_id
group by t2.film_id;
/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/
select t1.first_name, t1.last_name, sum(t2.amount) as 'Total Amount Paid' 
from customer t1
inner join payment t2
where t1.customer_id = t2.customer_id
group by t1.first_name, t1.last_name
order by t1.last_name asc;

/*
7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
of movies starting with the letters K and Q whose language is English.
*/

select title from film where language_id = (select language_id from language where name = "English") and
      (title like "K%" or title like "Q%");

/* 
7b. Use subqueries to display all actors who appear in the film Alone Trip.
 */
select first_name, last_name from actor where actor_id in (select actor_id from film_actor where film_id = 17); 

/*
7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.
*/

/* version JOIN */
select customer.first_name, customer.last_name, customer.email from customer 
JOIN address ON (customer.address_id = address.address_id)
JOIN city ON (city.city_id = address.city_id)
JOIN country ON (country.country_id = city.country_id)
where country.country = "Canada";

/* Subqueries version */
select concat(first_name, ", ", last_name) as 'Full Name', email 
from customer
where address_id in (
						select address_id 
                        from address 
                        where city_id in (
										select city_id 
                                        from city 
                                        where country_id = (select country_id from country where country = "Canada")
                                        )
					);
                    
/* 
7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.
*/

select film.title as Movie_title, category.name as Category
from film
JOIN film_category ON (film.film_id = film_category.film_id)
JOIN category ON (category.category_id = film_category.category_id)
where category.name = "Family";

/*
7e. Display the most frequently rented movies in descending order.
*/
select film.title, count(rental.inventory_id) as number_of_rents
from rental 
join inventory on (inventory.inventory_id = rental.inventory_id)
join film on (film.film_id = inventory.film_id)
group by film.title
order by number_of_rents desc;

/*
7f. Write a query to display how much business, in dollars, each store brought in.
*/
select store.store_id, sum(amount) as 'Contributions p/store in $'
from payment
join staff on (staff.staff_id = payment.staff_id)
join store on (store.manager_staff_id = staff.staff_id)
group by store.store_id;

/*
	7g. Write a query to display for each store its store ID, city, and country.
*/
select store.store_id, city.city, country.country
from store
join address on (address.address_id = store.address_id)
join city on (city.city_id = address.city_id)
join country on (country.country_id = city.country_id);

/*
7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*/
select category.name as "Genre's name", sum(payment.amount) as Contribution
from category
join film_category on (film_category.category_id = category.category_id)
join inventory on (inventory.film_id = film_category.film_id)
join rental on (rental.inventory_id = inventory.inventory_id)
join payment on (payment.rental_id = rental.rental_id)
group by category.name
order by Contribution desc LIMIT 5;

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute 
another query to create a view.
*/
CREATE VIEW vw_Top_five_genres_by_gross_revenue as
select category.name as "Genre's name", sum(payment.amount) as Contribution
from category
join film_category on (film_category.category_id = category.category_id)
join inventory on (inventory.film_id = film_category.film_id)
join rental on (rental.inventory_id = inventory.inventory_id)
join payment on (payment.rental_id = rental.rental_id)
group by category.name
order by Contribution desc LIMIT 5;

/* 
  8b. How would you display the view that you created in 8a?
 */
select * from  vw_Top_five_genres_by_gross_revenue;
 /*
  8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
 */
 DROP VIEW IF EXISTS vw_Top_five_genres_by_gross_revenue;