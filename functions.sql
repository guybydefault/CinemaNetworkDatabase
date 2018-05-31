Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{а,б,в,г,д,е,ё,ж,з,и,й,к,л,м,н,о,п,р,с,т,у,ф,х,ц,ч,ш,щ,ъ,ы,ь,э,ю,я}';
  result text := '';
  i integer := 0;
begin
  if length < 1 then
    raise exception 'Given length cannot be less than 1';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION create_places_for_cinema_room(room_id int, rows_count int, column_count int, base_prise int)
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

CREATE OR REPLACE FUNCTION create_tickets_for_session(session_id int)
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

CREATE OR REPLACE FUNCTION create_cinema_circuit(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Сети(название) values(random_string(10));
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_cinemas(count int)
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


CREATE OR REPLACE FUNCTION create_rooms(count int)
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

CREATE OR REPLACE FUNCTION create_places()
RETURNS VOID AS $$
DECLARE
        cinema_room record;
BEGIN
        FOR cinema_room IN (SELECT ид from Залы)
        LOOP
                PERFORM create_places_for_cinema_room
                (cinema_room.ид,(random()*10+ 1)::int,(random()*20)::int+ 1,(random()*500)::int + 1);
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_random_database(count int)
RETURNS VOID AS $$
BEGIN
        PERFORM create_cinema_circuit(count / 100);
        PERFORM create_cinemas(count / 50);
        PERFORM create_rooms(count / 100);
        PERFORM create_places();
END;
$$ LANGUAGE plpgsql;
