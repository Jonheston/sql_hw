use sakila;

#1a. Display the first and last names of all actors from the table actor.
select * from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ', last_name) as "Actor Name" from actor; 

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = "Joe"; 

#2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like "%GEN%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like "%LI%" order by last_name, first_name;


#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ("Afghanistan", "Bangladesh", "China")

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
add column description blob

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description;

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as `Actor Count`
from actor
group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as `actor_count`
from actor
group by last_name
having actor_count >1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name = "Harpo" where first_name = "Groucho";

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = "Groucho" where first_name = "Harpo";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table sakila.address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address
FROM staff 
LEFT JOIN address ON staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Total'
FROM staff LEFT JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.first_name, staff.last_name;


select * from inventory;
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.title, COUNT(film_actor.actor_id) AS 'total'
FROM film  LEFT JOIN film_actor  ON film.film_id = film_actor.film_id
GROUP BY film.title;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(inventory_id)
from inventory
where film_id in (SELECT film_id from film where title='HUNCHBACK IMPOSSIBLE')

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'TOTAL'
FROM customer LEFT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY customer.last_name

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
FROM film
WHERE (title LIKE 'Q%' OR title LIKE 'K%') 

#7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN (SELECT actor_id FROM film_actor WHERE film_id 
		IN (SELECT film_id from film where title='ALONE TRIP'))
	

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email
from customer
where address_id
	IN (select address_id from address where city_id
		IN (select city_id from city where country_id
			IN (select country_id from country where country = 'canada')))
    
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title
from film
where film_id
	in (select film_id from film_category where category_id
		in (select category_id from category where name = 'family'))

select * from category;

#7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(film.film_id) AS 'rental_count'
FROM  film
LEFT JOIN inventory ON (film.film_id= inventory.film_id)
LEFT JOIN rental ON (inventory.inventory_id=rental.inventory_id)
GROUP BY title ORDER BY rental_count DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff.store_id, SUM(payment.amount) as "total_business"
FROM payment 
LEFT JOIN staff  ON (payment.staff_id=staff.staff_id)
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select store_id, city.city, country.country
from store
LEFT JOIN address on (address.address_id = store.address_id)
LEFT JOIN city on (address.city_id = city.city_id)
LEFT JOIN country on (country.country_id = city.country_id)

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) as "gross_revenue"
FROM payment 
LEFT JOIN rental  ON (payment.rental_id=rental.rental_id)
LEFT JOIN inventory ON (rental.inventory_id = inventory.inventory_id)
LEFT JOIN film_category on (inventory.film_id = film_category.film_id)
LEFT JOIN category ON (film_category.category_id = category.category_id)
GROUP BY category.name
ORDER BY gross_revenue desc
LIMIT 5;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT category.name, SUM(payment.amount) as "gross_revenue"
FROM payment 
LEFT JOIN rental  ON (payment.rental_id=rental.rental_id)
LEFT JOIN inventory ON (rental.inventory_id = inventory.inventory_id)
LEFT JOIN film_category on (inventory.film_id = film_category.film_id)
LEFT JOIN category ON (film_category.category_id = category.category_id)
GROUP BY category.name
ORDER BY gross_revenue desc
LIMIT 5;


#8b. How would you display the view that you created in 8a?
select * from top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;