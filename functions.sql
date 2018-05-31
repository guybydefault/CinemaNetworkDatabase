CREATE OR REPLACE FUNCTION random_string(length integer) returns text as
$$
declare
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

CREATE OR REPLACE FUNCTION insert_places_for_cinema_room(room_id int, rows_count int, column_count int, base_prise int)
RETURNS VOID AS $$
BEGIN
        FOR i IN 1 .. rows_count LOOP
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
                insert into Люди(фио)
                 values (random_string(20));
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
END;
$$ LANGUAGE plpgsql;


