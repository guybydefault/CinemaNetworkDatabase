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


CREATE OR REPLACE FUNCTION сгенерировать_сети(count int)
RETURNS VOID AS $$
DECLARE
	startId int = 0;
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

CREATE OR REPLACE FUNCTION сгенерировать_кинотеатры(число_на_сеть int)
RETURNS VOID AS $$
DECLARE
	currId int = 0;
	row Сети%ROWTYPE;
BEGIN
	    SELECT MAX(ид) + 1 INTO currId FROM Кинотеатры;
	    IF currId IS NULL THEN
	    	currId = 0;
	    END IF;
		
        FOR row IN SELECT * FROM Сети LOOP
                FOR j IN 1 .. число_на_сеть LOOP
                        INSERT INTO Кинотеатры(ид, ид_сети, название, город, адрес) VALUES (currId, row.ид, 'Кинотеатр ' || currId, 'СПб', 'Чкаловская д. ' || currId);
                        currId = currId + 1;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_залы(число_на_кинотеатр int)
RETURNS VOID AS $$
DECLARE
	currId int = 0;
	row Кинотеатры%ROWTYPE;
BEGIN
	    SELECT MAX(ид) + 1 INTO currId FROM Залы;
	    IF currId IS NULL THEN
	    	currId = 0;
	    END IF;
		
        FOR row IN SELECT * FROM Кинотеатры LOOP
                FOR j IN 1 .. число_на_кинотеатр LOOP
                        INSERT INTO Залы(ид, ид_кинотеатра, номер_зала) VALUES (currId, row.ид, currId);
                        currId = currId + 1;
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_фильмы(число int)
RETURNS VOID AS $$
DECLARE
	currId int = 0;
	row Сети%ROWTYPE;
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
                INSERT INTO Фильмы(ид, название, начало_съемок, конец_съемок, премьера, продолжительность, бюджет, возрастной_рейтинг, кассовые_сборы) 
                VALUES (currId, 'Звездные войны ' || currId, start_scene, end_scene, release, (120 + 10 * random()), (200 + 100 * random()), 'NC-17', (50 + 120 * random()));
                currId = currId + 1;
        END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION сгенерировать_сеансы(число_на_фильм int)
RETURNS VOID AS $$
DECLARE
	currId int = 0;
	row Фильм%ROWTYPE;
	start timestamp;
	end timestamp;
BEGIN
	    SELECT MAX(ид) + 1 INTO currId FROM Сеансы;
	    IF currId IS NULL THEN
	    	currId = 0;
	    END IF;
	
		FOR row IN SELECT * FROM Кинотеатры LOOP
        	FOR j IN 1 .. число_на_фильм LOOP
        			
        	END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION сгенерировать_базу(count int) -- count - это коэффициент масштабирования ( по умолчанию будем запускать с count = 1)
RETURNS VOID AS $$
BEGIN
        PERFORM сгенерировать_сети(20 * count);
        PERFORM сгенерировать_кинотеатры(10 * count);
        PERFORM сгенерировть_залы(5 * count);
        PERFORM сгенерировать_фильмы(1000 * count);
        PERFORM сгенерировать_пользователей(1000 * count);
        PERFORM сгенерировать_оценки(2000 * count); -- по ~2000 оценок на фильм - рандомно раскидать по разным пользователям
        PERFORM сгенерировать_сеансы(150 * count); -- по 150 сеансов на фильм
    	PEFORM сгенерировать_места(60 * count); -- по 60 мест на каждый зал
    	PERFORM сгенерировать_билеты(15 * count); -- абсолютно рандомно сгенерить билеты по 15 на сеанс 
        
END;
$$ LANGUAGE plpgsql;


