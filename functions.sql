CREATE OR REPLACE FUNCTION random_string(length integer) returns text as
$$
DECLARE
  chars text[] := '{а,б,в,г,д,е,ё,ж,з,и,й,к,л,м,н,о,п,р,с,т,у,ф,х,ц,ч,ш,щ,ъ,ы,ь,э,ю,я}';
  result text := '';
  i integer := 0;
BEGIN
  if length < 1 THEN
    raise exception 'Given length cannot be less than 1';
  END if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION random_date() returns timestamp as
$$
declare 
        result timestamp;
BEGIN
        result = timestamp '1950-01-10 20:00:00' +
        random() * (now() - '1950-01-10 20:00:00');      
        return result;
end;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION сгенерировать_сети(count int)
RETURNS VOID AS $$
DECLARE
	startId int = 0;
	currId int;
BEGIN
	    SELECT MAX(ид) + 1 INTO startId FROM Сети;
	    IF startId IS NULL THEN
	    	RAISE NOTICE 'null';
	    	startId = 0;
	    ELSE 
	    	startId = startId + 1;
	    	RAISE NOTICE 'value %', startId;
	    END IF;
		
        WHILE currId <> startId + count LOOP
        	RAISE NOTICE 'hey';
        	INSERT INTO Сети(ид, название, сайт) VALUES (currId, 'Сеть ' || currId, 'мираж.ру');
        	currId = currId + 1;
        END LOOP;
END; 
$$ 
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_кинотеатры(число_на_сеть int)
RETURNS VOID AS $$
BEGIN
        FOR i IN 1 .. SELECT * FROM "Сети" LOOP
                FOR j IN 1 .. column_count LOOP
                        INSERT INTO Места(ид_зала, ряд, место, стоимость)
                         values(room_id, i, j, base_prise);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_tickets_for_session(session_id int)
RETURNS VOID AS $$
DECLARE
        room_id int;
        place_id record;
BEGIN
        room_id = (SELECT ид_фильма FROM Сеансы where Сеансы.ид = session_id);
        FOR place_id IN (SELECT ид from Места where ид_зала=room_id)
        LOOP
                INSERT INTO Билеты(ид_места, ид_сеанса, стоимость, статус) 
        values(place_id.ид, session_id, random()::int, 0);
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_cinema_circuit(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Сети(название) values(random_string(10));
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_cinemas(count int)
RETURNS VOID AS $$
DECLARE
        circuit record;
BEGIN
        FOR circuit IN (SELECT ид, название from Сети)
        LOOP
                FOR i in 1 .. count LOOP
                insert into Кинотеатры(ид_сети, название, город, адрес) 
                        values(circuit.ид,circuit.название, 'Санкт-Петербург', random_string(8));
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_rooms(count int)
RETURNS VOID AS $$
DECLARE
        cinema record;
BEGIN
        FOR cinema IN (SELECT ид from Кинотеатры)
        LOOP
                FOR i in 1 .. count LOOP
                insert into Залы(ид_кинотеатра, номер_зала) 
                        values(cinema.ид,i);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_places()
RETURNS VOID AS $$
DECLARE
        cinema_room record;
BEGIN
        FOR cinema_room IN (SELECT ид from Залы)
        LOOP
                PERFORM insert_places_for_cinema_room
                (cinema_room.ид,(random()*10+ 1)::int,(random()*20)::int+ 1,(random()*500)::int + 1);
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_users(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Пользователи(логин, пароль, фио, дата_регистрации)
                 values (random_string(10), random_string(10),random_string(20),random_date());
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_people(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Люди(фио)
                 values (random_string(20));
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_genres(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Жанры(название)
                 values (random_string(20));
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_films(count int)
RETURNS VOID AS $$
DECLARE
        film_date timestamp;
BEGIN
        film_date = random_date();
        FOR i in 1 .. count LOOP
                insert into Фильмы(название, дата_начала_съемок, дата_конца_съемок,дата_премьеры,продолжительность,бюджет,возрастной_рейтинг) 
        values(random_string(20),film_date,(film_date + ('12 months')::interval)::timestamp,
                (film_date + ('13 months')::interval)::timestamp,'121','11000','G');
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_sessions()
RETURNS VOID AS $$
DECLARE
        film record;
        room record;
        film_time timestamp;
BEGIN
        FOR room IN (SELECT ид from Залы)
        LOOP
                FOR film IN (SELECT * from Фильмы)
                LOOP
                        film_time = (film.дата_премьеры + ('1 months')::interval)::timestamp;
                        insert into Сеансы(ид_фильма, ид_зала, дата_начала, дата_конца) 
                                values(film.ид, room.ид, 
                                        film_time, (film_time + ('1 hour')::interval)::timestamp);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_responses()
RETURNS VOID AS $$
DECLARE
        film record;
        users record;
BEGIN
        FOR users IN (SELECT ид from Пользователи)
        LOOP
                FOR film IN (SELECT ид from Фильмы)
                LOOP
                        insert into Оценки(ид_фильма,ид_пользователя, значение, комментарий) 
        values(film.ид,users.ид, 5, random_string(5));
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_genres_to_films()
RETURNS VOID AS $$
DECLARE
        film record;
        genres record;
BEGIN
        FOR genres IN (SELECT ид from Жанры)
        LOOP
                FOR film IN (SELECT ид from Фильмы)
                LOOP
                        insert into Фильмы_Жанры 
                                values(film.ид, genres.ид);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_groups(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Группы(название) values(random_string(10));
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_groups_to_films()
RETURNS VOID AS $$
DECLARE
        film record;
        groups record;
BEGIN
        FOR groups IN (SELECT ид from Группы)
        LOOP
                FOR film IN (SELECT ид from Фильмы)
                LOOP
                        insert into Фильмы_Группы 
                                values(film.ид,groups.ид);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_media()
RETURNS VOID AS $$
DECLARE
        film record;
BEGIN
        FOR film IN (SELECT ид from Фильмы)
        LOOP
                insert into Медиа(название, ид_фильма, тип, url) 
                        values(random_string(20),
                         film.ид, random_string(5), random_string(30));
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_roles()
RETURNS VOID AS $$
DECLARE
        people record;
        groupr record;
BEGIN
        FOR people IN (SELECT ид from Люди)
        LOOP
                FOR groupr IN (SELECT ид from Группы)
                LOOP
                        insert into Роли(название,ид_человека,ид_группы) 
                                values(random_string(10),people.ид, groupr.ид);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_peoples_to_groups()
RETURNS VOID AS $$
DECLARE
        people record;
        groups record;
BEGIN
        FOR groups IN (SELECT ид from Группы)
        LOOP
                FOR people IN (SELECT ид from Люди)
                LOOP
                        insert into Люди_Группы 
                                values(people.ид,groups.ид);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_random_database(count int)
RETURNS VOID AS $$
BEGIN
        PERFORM insert_cinema_circuit(count / 100);
        PERFORM insert_cinemas(count / 50);
        PERFORM insert_rooms(count / 100);
        PERFORM insert_places();
        PERFORM insert_users(count*2);
        PERFORM insert_people(count);
        PERFORM insert_genres(count);
        PERFORM insert_films(count/4);
        PERFORM insert_sessions();
        PERFORM insert_responses();
        PERFORM insert_genres_to_films();
        PERFORM insert_groups_to_films();
        PERFORM insert_media();
        PERFORM insert_roles();
        PERFORM insert_people_to_groups();
END;
$$ LANGUAGE plpgsql;


