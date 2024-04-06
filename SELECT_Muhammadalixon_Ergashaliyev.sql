-- Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?
WITH staff_revenue AS (
    SELECT s.store_id, s2.staff_id, s2.first_name || ' ' || s2.last_name AS full_name, SUM(p.amount) AS total_revenue
    FROM store s
    JOIN staff s2 ON s2.store_id = s.store_id
    JOIN payment p ON p.staff_id = s2.staff_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY s.store_id, s2.staff_id
)
SELECT sr.store_id, sr.full_name
FROM staff_revenue sr
JOIN (
    SELECT store_id, MAX(total_revenue) AS max_revenue
    FROM staff_revenue
    GROUP BY store_id
) max_revenues ON sr.store_id = max_revenues.store_id AND sr.total_revenue = max_revenues.max_revenue;

-- Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

SELECT
  f.title,
  count(r.rental_id) AS rental_count,
  f.rating 
FROM
  film f 
JOIN
  inventory i 
    ON i.film_id = f.film_id 
JOIN rental r
    ON r.inventory_id = i.inventory_id 
GROUP BY
  f.film_id 
ORDER BY
  rental_count DESC
LIMIT 5

-- Which actors/actresses didn't act for a longer period of time than the others?

WITH ActorFilmYears AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        f.release_year,
        ROW_NUMBER() OVER (PARTITION BY a.actor_id ORDER BY f.release_year DESC) AS rn
    FROM
        actor a
    JOIN
        film_actor fa ON fa.actor_id = a.actor_id
    JOIN
        film f ON f.film_id = fa.film_id
)
SELECT
    first_name,
    last_name,
    last_casting_year
FROM
    (SELECT
        actor_id,
        first_name,
        last_name,
        release_year AS last_casting_year,
        ROW_NUMBER() OVER (PARTITION BY actor_id ORDER BY release_year DESC) AS rn
    FROM
        ActorFilmYears) AS sub
WHERE
    rn = 1
ORDER BY
    last_casting_year ASC;