DROP TRIGGER IF EXISTS сеансы_до_премьеры_запрещены ON "Сеансы";
DROP TRIGGER IF EXISTS награды_до_премьеры_запрещены ON "Награды";

CREATE OR REPLACE FUNCTION сеансы_до_премьеры_запрещены () RETURNS trigger AS $сеансы_до_премьеры_запрещены$ 
DECLARE 
	дата_премьеры timestamp;
BEGIN
SELECT Фильмы.дата_премьеры INTO дата_премьеры FROM "Фильмы" WHERE ид = NEW.ид_фильма;
IF NEW.дата_начала < дата_премьеры THEN
	RAISE EXCEPTION 'Дата премьеры фильма (%) не может быть позже, чем дата начала показа (%)', дата_премьеры, NEW.дата_начала;
END IF;

RETURN NEW;
END;
$сеансы_до_премьеры_запрещены$  LANGUAGE plpgsql;

CREATE TRIGGER "сеансы_до_премьеры_запрещены" BEFORE INSERT OR UPDATE ON "Сеансы" 
FOR EACH ROW EXECUTE PROCEDURE сеансы_до_премьеры_запрещены();

CREATE OR REPLACE FUNCTION награды_до_премьеры_запрещены() RETURNS trigger AS $награды_до_премьеры_запрещены$ 
DECLARE 
	дата_премьеры timestamp;
BEGIN
SELECT Фильмы.дата_премьеры INTO дата_премьеры FROM "Фильмы" WHERE ид = NEW.ид_фильма;
IF now() < дата_премьеры THEN
	RAISE EXCEPTION 'Награда не может вручаться до выхода фильма (премьера %)', дата_премьеры;
END IF;
RETURN NEW;
END;
$награды_до_премьеры_запрещены$  LANGUAGE plpgsql;

CREATE TRIGGER "награды_до_премьеры_запрещены" BEFORE INSERT OR UPDATE ON "Награды" 
FOR EACH ROW EXECUTE PROCEDURE награды_до_премьеры_запрещены();

-- Тестовые запросы
-- INSERT INTO "Сеансы" VALUES (5,1,1, '1970-06-05', '2017-06-05');
-- INSERT INTO "Сеансы" VALUES (5,1,1, '1978-06-05', '2017-06-05');
-- INSERT INTO "Награды" VALUES (1, 1, 1, 'Оскар', "Ос");
-- INSERT INTO Фильмы(название, дата_начала_съемок, дата_конца_съемок,дата_премьеры,продолжительность,бюджет,возрастной_рейтинг) 
-- 	values('Звездные войны 2','2019-03-22','2019-04-10','2019-05-25','121','11000','G');
-- 	INSERT INTO "Награды" VALUES (3, 2, 1, 'Оскар', 'fsd');