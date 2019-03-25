use sakila;

## Instructions

-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT 
    first_name, last_name
FROM
    actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 
    first_name, last_name, UPPER(CONCAT(first_name, ' ', last_name)) AS Actor_Name
FROM
    actor;


-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';


-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name like '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;


-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');


-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE actor ADD COLUMN description BLOB;

SELECT 
    *
FROM
    actor;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

alter table actor drop description;

SELECT 
    *
FROM
    actor;
-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(last_name)
FROM
    actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(last_name) AS Last_Name_Count
FROM
    actor
GROUP BY last_name
HAVING Last_Name_Count > 1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SET FOREIGN_KEY_CHECKS = 0; 
TRUNCATE table actor; 
SET FOREIGN_KEY_CHECKS = 1;

SELECT 
    first_name,
    last_name,
    UPPER(CONCAT(first_name, ' ', last_name)) AS Actor_Name
FROM
    actor;
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    1 = 1 AND first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';






-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    1 = 1 AND first_name = 'HARPO';

SELECT 
    *
FROM
    actor;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;


 --  * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT 
    *
FROM
    staff s
        INNER JOIN
    address a ON s.address_id = a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    SUM(p.amount) AS total_amount
FROM
    staff s
        INNER JOIN
    payment p ON s.staff_id = p.staff_id
GROUP BY staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT 
    f.title, COUNT(fa.actor_id) AS totalactors
FROM
    film_actor fa
        INNER JOIN
    film f ON f.film_id = fa.film_id
GROUP BY f.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 
    f.title, COUNT(i.film_id) AS copies
FROM
    film f
        INNER JOIN
    inventory i ON i.film_id = f.film_id
WHERE
    f.title = 'Hunchback Impossible';

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    c.customer_id, first_name, last_name, SUM(p.amount) as total_paid
FROM
    payment p
        INNER JOIN
    customer c ON c.customer_id = p.customer_id
GROUP BY c.customer_id;




 --  ![Total amount paid](Images/total_payment.png)

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT 
    *
FROM
    film
WHERE 1=1
    and title in (SELECT 
            language_id
        FROM
            language
        WHERE
            name = 'English')
	or title like "K%"
    or title like "Q%";


-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT 
    a.actor_id, a.first_name, a.last_name
FROM
    actor a
WHERE
    a.actor_id IN (SELECT 
            fa.actor_id
        FROM
            film_actor fa
        WHERE
            fa.film_id = (SELECT 
                    f.film_id
                FROM
                    film f
                WHERE
                    f.title = 'Alone Trip'));




-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email
from customer c
inner join address a on a.address_id = c.address_id
inner join city ci on ci.city_id = a.city_id
inner join country co on co.country_id = ci.country_id
where co.country = 'Canada';


-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT 
    f.title, c.name
FROM
    film f
        INNER JOIN
    film_category fc ON fc.film_id = f.film_id
        INNER JOIN
    category c ON c.category_id = fc.category_id
WHERE
    c.name = 'Family';

-- * 7e. Display the most frequently rented movies in descending order.
SELECT 
    f.title, COUNT(r.rental_id)
FROM
    film f
        INNER JOIN
    inventory i ON i.film_id = f.film_id
        INNER JOIN
    rental r ON r.inventory_id = i.inventory_id
GROUP BY f.title;


-- * 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT 
    st.store_id, SUM(p.amount) AS store_total
FROM
    store st
        INNER JOIN
    staff s ON s.store_id = st.store_id
        INNER JOIN
    payment p ON p.staff_id = s.staff_id
GROUP BY st.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.

SELECT 
    st.store_id, c.city, co.country
FROM
    store st
        INNER JOIN
    address a ON a.address_id = st.address_id
        INNER JOIN
    city c ON c.city_id = a.city_id
        INNER JOIN
    country co ON co.country_id = c.country_id;



-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    c.name, SUM(p.amount) as total_revenue
FROM
    category c
        INNER JOIN
    film_category fc ON fc.category_id = c.category_id
        INNER JOIN
    film f ON f.film_id = fc.film_id
        INNER JOIN
    inventory i ON i.film_id = f.film_id
        INNER JOIN
    rental r ON r.inventory_id = i.inventory_id
        INNER JOIN
    payment p ON p.rental_id = r.rental_id
GROUP BY c.name
Order by total_revenue desc
limit 5;


-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres as (SELECT 
    c.name, SUM(p.amount) as total_revenue
FROM
    category c
        INNER JOIN
    film_category fc ON fc.category_id = c.category_id
        INNER JOIN
    film f ON f.film_id = fc.film_id
        INNER JOIN
    inventory i ON i.film_id = f.film_id
        INNER JOIN
    rental r ON r.inventory_id = i.inventory_id
        INNER JOIN
    payment p ON p.rental_id = r.rental_id
GROUP BY c.name
Order by total_revenue desc
limit 5)



-- * 8b. How would you display the view that you created in 8a?
Select * from top_five_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS v;