
    // 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса
    SELECT COUNT(s.seat_no), s.fare_conditions, a.model
    FROM seats AS s
    JOIN aircrafts_data AS a ON s.aircraft_code = a.aircraft_code
    GROUP BY a.model, s.fare_conditions
    ORDER BY a.model;

    //2. Найти 3 самых вместительных самолета (модель + кол-во мест)
    SELECT COUNT(s.seat_no), a.model
    FROM seats AS s
    JOIN aircrafts_data AS a ON s.aircraft_code = a.aircraft_code
    GROUP BY a.model
    ORDER BY COUNT(s.seat_no)
    DESC LIMIT 3;

    //3. Найти все рейсы, которые задерживались более 2 часов
    SELECT flight_no, scheduled_departure, actual_departure
    FROM flights
    WHERE actual_departure - scheduled_departure > INTERVAL '2 hour';

    //4.Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
    SELECT t.contact_data, t.passenger_name, b.book_date, ft.fare_conditions FROM tickets AS t
    JOIN bookings AS b ON t.book_ref = b.book_ref
    JOIN ticket_flights AS ft ON t.ticket_no = ft.ticket_no
    WHERE fare_conditions = 'Business'
    ORDER BY b.book_date DESC LIMIT 10;

    //5.Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
    SELECT DISTINCT f.flight_no
    FROM flights f
    WHERE NOT EXISTS
    (SELECT * FROM seats s
    WHERE s.aircraft_code = f.aircraft_code
    AND s.fare_conditions = 'Business');

    //6.Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой
    SELECT a.airport_name, a.city, f.actual_departure, f.scheduled_departure
    FROM flights AS f JOIN airports AS a ON f.departure_airport = a.airport_code
    WHERE f.actual_departure > f.scheduled_departure;

    //7.Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
    SELECT DISTINCT airport_name ->> 'en' AS airport_name, count(departure_airport) AS count
    FROM airports_data
    INNER JOIN flights f on airports_data.airport_code = f.departure_airport
    group by airport_name
    ORDER BY count DESC;

    //8.Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival)
    // было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
    SELECT *
    FROM flights f
    WHERE (f.scheduled_arrival != f.actual_arrival);

    //9.Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
    SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions
    FROM seats AS s
    JOIN aircrafts AS a ON s.aircraft_code = a.aircraft_code
    WHERE a.model LIKE 'Аэробус A321-200'
    AND s.fare_conditions NOT LIKE 'Econom'
    ORDER BY s.seat_no;

    //10.Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
    SELECT aa.city, aa.airport_code, aa.airport_name
    FROM (SELECT city, count( * )
    FROM airports
    GROUP BY city
    HAVING count( * ) > 1) AS a
    JOIN airports AS aa ON a.city = aa.city
    ORDER BY aa.city, aa.airport_name;

    //11.Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
    SELECT t.passenger_id, t.passenger_name, SUM(b.total_amount) AS total_booking_amount
    FROM tickets t
    JOIN bookings b ON t.book_ref = b.book_ref
    GROUP BY t.passenger_id, t.passenger_name
    HAVING SUM(b.total_amount) > (SELECT AVG(total_amount)
    FROM bookings);

    //12.Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
    SELECT f.*
    FROM flights_v f
    WHERE f.departure_city = 'Екатеринбург'
    AND f.arrival_city = 'Москва'
    AND status LIKE 'On Time'
    ORDER BY f.scheduled_departure
    LIMIT 1;

    //13.Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
    SELECT f.flight_no, tf.amount
    FROM  flights_v f
    JOIN ticket_flights tf ON f.flight_id = tf.flight_id
    WHERE amount IN (( SELECT max( amount ) FROM ticket_flights ),
    ( SELECT min( amount ) FROM ticket_flights ))
    GROUP BY 1, 2
    ORDER BY amount;

    //Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
    CREATE TABLE  Customers (
    id BIGSERIAL PRIMARY KEY,
    firstName VARCHAR (120) NOT NULL,
    lastName VARCHAR (120) NOT NULL,
    email VARCHAR (160) NOT NULL,
    phone VARCHAR (120) NOT NULL);

    //Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
    CREATE TABLE  Orders (
    id BIGSERIAL PRIMARY KEY,
    quantity int NOT NULL;
    customerId int FOREIGN KEY REFERENCES Customers(customerId));


    //Написать 5 insert в эти таблицы
    INSERT INTO Customers
    (id, firstName, LastName, email, phone)
    VALUES
    (1, 'Harry', 'Potter', 'Potter@gmail.com', '375333122601'),
    (2, 'Ron', 'Wiesley', 'Wiesley@gmail.com', '375293100601'),
    (3, 'Joe', 'Mitchel', 'Mitchel@gmail.com', '375333124601'),
    (4, 'John', 'Dolby', 'Dolby@gmail.com', '375442322601'),
    (5, 'Vik', 'MikkiY', 'MikkiY@gmail.com', '375333122579');

    INSERT INTO Orders
    (id, quantity, customerId)
    VALUES
    (1, 2, 1),
    (2, 3, 1),
    (3, 4, 2),
    (4, 3, 5),
    (5, 1, 3);

    //Удалить таблицы
    DROP TABLE  IF EXISTS Customers,Orders;