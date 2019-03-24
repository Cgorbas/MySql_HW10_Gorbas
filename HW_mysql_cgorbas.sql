use sakila;

-- 1a. Display the first and last names of all actors from actor table 
Select first_name, last_name
from actor
order by last_name
;

-- 1b Display the first and last name of each actor in a single 
--  column in upper case letters. Name the column Actor Name.
Select Upper(concat_ws(' ',first_name, last_name)) as 'Actor Name'
from actor
order by last_name
;

-- 2a. find the ID number, first name, last name of actor,  first name, "Joe." 
Select actor_id, first_name, last_name
from actor
where first_name = "Joe"
order by last_name
;

-- 2b. Find all actors whose last name contain the letters GEN:
Select concat_ws(' ',first_name, last_name) as 'Actor Name'
from actor
where last_name like "%gen%"
order by last_name
;

-- 2c. Find actors last names contain the letters LI. order by last name, first name, in that order:
Select concat_ws(' ',first_name, last_name) as 'Actor Name'
from actor
where last_name like "%li%"
order by last_name, first_name
;

-- 2d. Using IN, display the country_id and country columns of the 
-- following countries: Afghanistan, Bangladesh, and China
Select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China')
order by country
;

-- 3a. create a column in the table actor named description and use the data type BLOB
ALTER TABLE country ADD description blob 
;

-- 3b. Very quickly you realize that entering descriptions for each actor is 
-- too much effort. Delete the description column.
ALTER TABLE country
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select distinct last_name, count(last_name) as ln_count
from actor
group by last_name
;
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select distinct last_name, count(last_name) as ln_count
from actor
group by last_name
having count(last_name) > 1
;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as 
-- GROUCHO WILLIAMS. Write a query to fix the record.
Update actor 
set first_name ="Harpo" 
where first_name = "Groucho" and last_name = "Williams"
;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that 
-- GROUCHO was the correct name after all! In a single query, if the first name of the 
-- actor is currently HARPO, change it to GROUCHO.
Update actor 
set first_name ="Groucho" 
where first_name = "Harpo" and last_name = "Williams"
;

-- 5a. re-create address schema?
describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
describe address;

Select staff.first_name, staff.last_name, staff.address_id, address.address, address.address2
from staff, address
join staff as s on address.address_id = s.address_id
 ;
 
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff (staff_id, last_name, first_name and payment (amount, payment_date, staff id)
describe payment;

Select distinct(payment.staff_id), sum(payment.amount), payment.payment_date, staff.first_name, staff.last_name
from staff, payment
join staff as s on payment.staff_id = s.staff_id
where payment.payment_date BETWEEN '2005-08-01' AND '2005-08-31' 
group by payment.staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables 
--  film_actor (count actor_id on film_id) and film (title, film_id). Use inner join.

describe film_actor;

SELECT film.title, count(actor_id) as 'number of actors'
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
group by film.title
;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
describe inventory;

SELECT film.title, count(inventory_id) as 'in inventory'
FROM film
JOIN inventory
ON film.film_id = inventory.film_id
where film.title like "hunch%"
;

-- 6e. Using the tables payment(amount, customer_id) and customer (customer_id, first_name, last_name) and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
describe payment;

SELECT customer.first_name, customer.last_name, sum(amount) as 'customer total'
FROM customer
JOIN payment
ON customer.customer_id = payment.customer_id
group by customer.last_name
order by customer.last_name 
;

-- 7a. films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- film(title, language_id, where titles like "k%" or "q%") language(language_id, name where name="english")
select title 
from film
where title like("k%") or ("q") and language_id IN
(
Select language_id
from language
where name="English"
-- where city in('Qalyub', 'Qinhuangdao', 'Qomsheh', 'Quilmes')
)
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- actor(actor_id, first_name, last_name) film_actor(actor_id, film_id) film (film_id, title)
select first_name, last_name 
from actor
where  actor_id IN
  (
  select actor_id 
  from film_actor
  where film_id IN
    (
    Select film_id
    from film
    where title="Alone Trip"
-- where city in('Qalyub', 'Qinhuangdao', 'Qomsheh', 'Quilmes')
))
order by last_name
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- country(country_id,country = "canada") city (city_id,country_id) address(address_id, city_id)
-- customer(email, address_id) join country id     address and city id

select email 
from customer
join address
on customer.address_id = address.address_id
where  address.city_id IN
  (
  select city_id 
  from city
  join country
  on city.country_id=country.country_id
  where country.country = "Canada"
    )
;

-- 7e. Display the most frequently rented movies in descending order.
-- rental(inventory_id as film id, rental_id), inventory(inventory_id, film_id), film(film_id,title)
-- select inventory_id, rental_id from rental order by inventory_id;
      
SELECT film.title, count(rental.rental_id) as "Number of Times Rented"
FROM rental
    INNER JOIN inventory
        ON inventory.inventory_id = rental.inventory_id
    INNER JOIN film
        ON film.film_id = inventory.film_id
group by title
order by count(rental.rental_id) desc
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- payment(staff_id, amount), staff(staff_id, store_id)
 Select sum(payment.amount), staff.store_id
	from payment
	join staff
	on payment.staff_id=staff.staff_id
    group by staff.staff_id
    ;
     
-- 7g. Write a query to display for each store its store ID, city, and country. 
--      address(address_id, city_id) , store(store_id,address_id), city(city_id, city, country_id),country(country_id,country)
select * from address;
SELECT store.store_id, address.address, city.city, country.country
FROM store
    INNER JOIN address
        ON address.address_id = store.address_id
    INNER JOIN city
        ON city.city_id = address.city_id
    INNER JOIN country
        ON country.country_id = city.country_id
group by store.store_id
;
 
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category (category_id, name), 
-- film_category (category_id, film_id), inventory(rental_id, film_id), payment(rental_id, amount), 
-- and rental.)
Select category.name, sum(payment.amount) as "Total Earned"
FROM category
    INNER JOIN film_category
        ON film_category.category_id = category.category_id
    INNER JOIN film
        ON film.film_id = film_category.film_id
    INNER JOIN inventory
        ON inventory.film_id = film.film_id
    INNER JOIN rental
        ON rental.inventory_id = inventory.inventory_id
	INNER JOIN payment
        ON payment.rental_id = rental.rental_id
	group by category.name
    order by sum(payment.amount) desc limit 5
    ;

-- 8a. viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view Top_5
as
	Select category.name, sum(payment.amount) as "Total Earned"
	FROM category
		INNER JOIN film_category
			ON film_category.category_id = category.category_id
		INNER JOIN film
			ON film.film_id = film_category.film_id
		INNER JOIN inventory
			ON inventory.film_id = film.film_id
		INNER JOIN rental
			ON rental.inventory_id = inventory.inventory_id
		INNER JOIN payment
			ON payment.rental_id = rental.rental_id
		group by category.name
		order by sum(payment.amount) desc limit 5
    ;
-- 8b. How would you display the view that you created in 8a?
Select * from top_5;

-- Show create view top_5;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop view top_5;