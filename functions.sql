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

CREATE OR REPLACE FUNCTION random_film_date()
RETURNS TIMESTAMP AS $$
DECLARE
        result timestamp;
BEGIN
        result = timestamp '1950-01-10 20:00:00' + random() * interval '68 years';
        return result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_film_interval()
RETURNS INTERVAL AS $$
BEGIN
        return random() * interval '2 months';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION сгенерировать_сети(count integer)
RETURNS VOID AS $$
DECLARE
        startId integer = 0;
        currId int;
BEGIN
            SELECT MAX(ид) + 1 INTO startId FROM Сети;
            IF startId IS NULL THEN
                startId = 0;
            END IF;
                currId = startId;
        WHILE currId <> startId + count LOOP
                INSERT INTO Сети(ид, название, сайт) VALUES (currId, 'Сеть ' || currId, 'мираж' || currId || '.ру');
                currId = currId + 1;
        END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_кинотеатры(число_на_сеть integer)
RETURNS VOID AS $$
DECLARE
        currId integer = 0;
        row RECORD;
BEGIN
            SELECT MAX(ид) + 1 INTO currId FROM Кинотеатры;
            IF currId IS NULL THEN
                currId = 0;
            END IF;

        FOR row IN SELECT * FROM Сети LOOP
                FOR j IN 1 .. число_на_сеть LOOP
                        INSERT INTO Кинотеатры(ид, ид_сети, название, город, адрес)
                         VALUES (currId, row.ид, 'Кинотеатр ' || currId, 'СПб', 'Чкаловская д. ' || currId);
                        currId = currId + 1;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_залы(число_на_кинотеатр integer)
RETURNS VOID AS $$
DECLARE
        currId integer = 0;
        row RECORD;
BEGIN
            SELECT MAX(ид) + 1 INTO currId FROM Залы;
            IF currId IS NULL THEN
                currId = 0;
            END IF;

        FOR row IN SELECT * FROM Кинотеатры LOOP
                FOR j IN 1 .. число_на_кинотеатр LOOP
                        INSERT INTO Залы(ид, ид_кинотеатра, номер_зала) VALUES (currId, row.ид, currId + 1);
                        currId = currId + 1;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_фильмы(число integer)
RETURNS VOID AS $$
DECLARE
        currId integer = 0;
        row RECORD;
        start_scene timestamp;
        end_scene timestamp;
        release timestamp;
BEGIN
            SELECT MAX(ид) + 1 INTO currId FROM Фильмы;
            IF currId IS NULL THEN
                currId = 0;
            ELSE
                currId = currId + 1;
            END IF;

        FOR j IN 1 .. число LOOP
                        start_scene = random_film_date();
                        end_scene = start_scene + random_film_interval();
                                release = end_scene + random_film_interval();
                INSERT INTO Фильмы(ид, название, начало_съемок, конец_съемок, премьера,
                 продолжительность, бюджет, возрастной_рейтинг, кассовые_сборы)
                VALUES (currId, 'Звездные войны ' || currId, start_scene, end_scene, release,
                 (120 + 10 * random()), (200 + 100 * random()), 'NC-17', (50 + 120 * random()));
                currId = currId + 1;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_пользователей(число_пользователей integer)
RETURNS VOID AS $$
BEGIN
        FOR i IN 1 .. число_пользователей LOOP
                INSERT INTO Пользователи(логин, пароль, фио)
                 VALUES (random_string(10), random_string(10),random_string(20));
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_сеансы(число_сеансов_фильма integer)
RETURNS VOID AS $$
DECLARE
        film RECORD;
        room RECORD;
        film_time TIMESTAMP;
BEGIN
        FOR room IN (SELECT ид FROM Залы)
        LOOP
                FOR film IN (SELECT * FROM Фильмы)
                LOOP
                    FOR i IN 1 .. число_сеансов_фильма LOOP
                        film_time = (film.премьера + random_film_interval())::TIMESTAMP;
                        INSERT INTO Сеансы(ид_фильма, ид_зала, начало, конец)
                                VALUES(film.ид, room.ид,
                                        film_time, (film_time + ('2 hours')::INTERVAL)::TIMESTAMP);
                    END LOOP;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_оценки()
RETURNS VOID AS $$
DECLARE
        film RECORD;
        users RECORD;
BEGIN
        FOR users IN (SELECT ид FROM Пользователи)
        LOOP
                FOR film IN (SELECT ид, премьера FROM Фильмы)
                LOOP
                        INSERT INTO Оценки(ид_фильма,ид_пользователя, значение, комментарий, дата_время)
        VALUES(film.ид, users.ид, random()*9 + 1, random_string(5), (film.премьера + random_film_interval()));
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_места(число_мест integer)
RETURNS VOID AS $$
DECLARE
        cinema_room RECORD;
        row_c integer;
BEGIN
        FOR cinema_room IN (SELECT ид FROM Залы)
        LOOP
                row_c = 1;
            FOR i IN 1..число_мест LOOP
                INSERT INTO Места (ид_зала, ряд, место, стоимость)
                VALUES (cinema_room.ид, row_c, i % 10 + 1, random() * 100 + 100);
                IF i % 10 = 0 THEN
                        row_c = row_c + 1;
                END IF;
            END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_билеты()
RETURNS VOID AS $$
DECLARE
        sess RECORD;
        seat RECORD;
BEGIN
        FOR sess IN (SELECT ид, ид_зала FROM Сеансы) LOOP
                FOR seat IN (SELECT ид FROM Места WHERE Места.ид_зала = sess.ид_зала) LOOP
                        if (random() > 0.8) THEN
                        INSERT INTO Билеты (ид_сеанса, ид_места, стоимость, статус)
                        VALUES (sess.ид, seat.ид, random() * 500 + 100, random() * 2);
                                END IF;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_жанры()
RETURNS VOID AS $$
BEGIN
        insert into Жанры(название) values('Космическая опера');
        insert into Жанры(название) values('Комедия');
        insert into Жанры(название) values('Боевик');
        insert into Жанры(название) values('Триллер');
        insert into Жанры(название) values('Трагедия');
        insert into Жанры(название) values('Научная фантастика');
        insert into Жанры(название) values('Ужасы');
        insert into Жанры(название) values('Мелодрама');
        insert into Жанры(название) values('Приключения');
        insert into Жанры(название) values('Фэнтези');
        insert into Жанры(название) values('Документальное кино');
        insert into Жанры(название) values('Биография');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_жанры_к_фильмам()
RETURNS VOID AS $$
DECLARE
        film record;
        genres record;
BEGIN
        FOR genres IN (SELECT ид from Жанры)
        LOOP
                FOR film IN (SELECT ид from Фильмы)
                LOOP
                    if (random() > 0.8) THEN
                        insert into Фильмы_Жанры 
                                values(film.ид, genres.ид);
                    end if;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_медиа(COUNT integer)
RETURNS VOID AS $$
DECLARE
        film record;
BEGIN
        FOR film IN (SELECT ид from Фильмы)
        LOOP
            FOR i IN 1..COUNT LOOP
                insert into Медиа(название, ид_фильма, тип, url) 
                        values(random_string(20),
                         film.ид, random_string(5), random_string(30));
            END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_группы(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Группы(название) values(random_string(10));
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_группы_к_фильмам()
RETURNS VOID AS $$
DECLARE
        film record;
        groups record;
BEGIN
        FOR groups IN (SELECT ид from Группы)
        LOOP
                FOR film IN (SELECT ид from Фильмы)
                LOOP
                    if (random() > 0.8) THEN
                        insert into Фильмы_Группы 
                                values(film.ид, groups.ид);
                    end if;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_людей(count int)
RETURNS VOID AS $$
BEGIN
        FOR i in 1 .. count LOOP
                insert into Люди(фио)
                 values (random_string(20));
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_роли()
RETURNS VOID AS $$
DECLARE
        people record;
        groupp record;
BEGIN
        FOR people IN (SELECT ид from Люди)
        LOOP
                FOR groupp IN (SELECT ид from Группы)
                LOOP
                        If (random() > 0.9) THEN
                        insert into Роли(название, ид_человека, ид_группы) 
                                values(random_string(10) , people.ид , groupp.ид);
                        END If;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_награды()
RETURNS VOID AS $$
DECLARE
        film record;
        people record;
BEGIN
        FOR film IN (SELECT ид,премьера from Фильмы) LOOP
            FOR people IN (SELECT ид from Люди) LOOP
                if ((random() > 0.8) AND Exists(SELECT 1 from Фильмы 
                    Join Фильмы_Группы 
                    On Фильмы.ид=Фильмы_Группы.ид_фильма 
                    Join Роли 
                    On Фильмы_Группы.ид_группы=Роли.ид_группы
                    WHERE Роли.ид_человека=people.ид AND Фильмы.ид=film.ид
                    ) 
                ) THEN
                    insert into Награды(ид_фильма,ид_человека,название,тип,дата)
                        values(film.ид,people.ид,random_string(10),
                            random_string(5),film.премьера + random_film_interval());
                END IF;
            END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_базу(COUNT integer) -- count - это коэффициент масштабирования ( по умолчанию будем запускать с count = 1)
RETURNS VOID AS $$
BEGIN
        PERFORM сгенерировать_сети(5 * COUNT);
        PERFORM сгенерировать_кинотеатры(20 * COUNT);
        PERFORM сгенерировать_залы(8 * COUNT);
        PERFORM сгенерировать_фильмы(200 * COUNT);
        PERFORM сгенерировать_пользователей(100 * COUNT);
        PERFORM сгенерировать_оценки(); -- по ~2000 оценок на фильм - рандомно раскидать по разным пользователям
        PERFORM сгенерировать_сеансы(3 * COUNT); -- по 15 сеансов фильмов на зал
        PERFORM сгенерировать_места(40 * COUNT); -- по 40 мест на каждый зал
        PERFORM сгенерировать_билеты(); -- абсолютно рандомно сгенерить билеты по 15 на сеанс
        PERFORM сгенерировать_жанры();
        PERFORM сгенерировать_жанры_к_фильмам();
        PERFORM сгенерировать_медиа(10*COUNT);
        PERFORM сгенерировать_группы(500*COUNT);
        PERFORM сгенерировать_людей(1000*COUNT);
        PERFORM сгенерировать_группы_к_фильмам();
        PERFORM сгенировать_роли();
        PERFORM сгенерировать_награды();
END;
$$ LANGUAGE plpgsql;
