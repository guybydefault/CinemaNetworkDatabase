CREATE TABLE "Сети" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	"сайт" TEXT UNIQUE,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Кинотеатры" (
	"ид" SERIAL NOT NULL,
	"ид_сети" INTEGER NOT NULL REFERENCES "Сети" ON DELETE CASCADE,
	"название" TEXT NOT NULL,
	"город" TEXT NOT NULL,
	"адрес" TEXT NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Залы" (
	"ид" SERIAL NOT NULL,
	"ид_кинотеатра" INTEGER NOT NULL REFERENCES "Кинотеатры" ON DELETE CASCADE,
	"номер_зала" INTEGER NOT NULL UNIQUE CONSTRAINT csr_room_id CHECK ("номер_зала" > 0),
	PRIMARY KEY ("ид")
);

CREATE TABLE "Места" (
	"ид" SERIAL NOT NULL,
	"ид_зала" INTEGER NOT NULL REFERENCES "Залы" ON DELETE CASCADE,
	"ряд" INTEGER NOT NULL 
		CONSTRAINT csr_row CHECK ("ряд" > 0),
	"место" INTEGER NOT NULL 
		CONSTRAINT csr_place CHECK ("место" > 0),
	"стоимость" INTEGER NOT NULL 
		CONSTRAINT csr_seat_price CHECK ("стоимость" > 0), 
	CONSTRAINT csr_unique_seat UNIQUE (ид_зала, ряд, место), 
	PRIMARY KEY ("ид")
);

CREATE TABLE "Жанры" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	PRIMARY KEY ("ид")
);


CREATE TABLE "Люди" (
	"ид" SERIAL NOT NULL,
	"фио" TEXT NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Пользователи" (
	"ид" SERIAL NOT NULL,
	"логин" TEXT NOT NULL UNIQUE,
	"пароль" TEXT NOT NULL,
	"фио" TEXT NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Фильмы" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL,
	"начало_съемок" TIMESTAMP NOT NULL,
	"конец_съемок" TIMESTAMP,
	"премьера" TIMESTAMP,
	"продолжительность" INTEGER NOT NULL 
		CONSTRAINT csr_duration CHECK ("продолжительность" > 0),
	"бюджет" int,
		CONSTRAINT csr_budget CHECK ("бюджет" > 0),
	"возрастной_рейтинг" VARCHAR(5) NOT NULL 
		CONSTRAINT csr_age_rate CHECK("возрастной_рейтинг" in('G','PG','PG-13','R','NC-17')),
	"слоган" TEXT,
	"кассовые_сборы" int,
		CONSTRAINT csr_money CHECK ("кассовые_сборы" > 0),
	CONSTRAINT csr_movie_start_end_range CHECK ("начало_съемок" < "конец_съемок"),
	CONSTRAINT csr_movie_release_end CHECK ("конец_съемок" < "премьера"),
	PRIMARY KEY ("ид")
);


CREATE TABLE "Медиа" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL,
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"тип" TEXT NOT NULL,
	"url" TEXT NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Оценки" (
	"ид" SERIAL NOT NULL,
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_пользователя" INTEGER NOT NULL REFERENCES "Пользователи" ON DELETE CASCADE,
	"значение" INTEGER NOT NULL CONSTRAINT csr_rate CHECK ("значение" BETWEEN 1 AND 10), 
	"комментарий" TEXT,
	"дата_время" TIMESTAMP NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Награды" (
	"ид" SERIAL NOT NULL,
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_человека" INTEGER NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"название" TEXT NOT NULL,
	"тип" TEXT NOT NULL,
	"дата" TIMESTAMP NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Группы" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Роли" (
	"название" TEXT NOT NULL,
	"ид_человека" INTEGER NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"ид_группы" INTEGER NOT NULL REFERENCES "Группы" ON DELETE CASCADE,
	PRIMARY KEY ("название","ид_человека","ид_группы")
);


CREATE TABLE "Сеансы" (
	"ид" SERIAL NOT NULL,
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_зала" INTEGER NOT NULL REFERENCES "Залы" ON DELETE CASCADE,
	"начало" TIMESTAMP NOT NULL,
	"конец" TIMESTAMP NOT NULL,
	CONSTRAINT csr_session_date CHECK ("начало" < "конец"),
	PRIMARY KEY ("ид")
);


CREATE TABLE "Билеты" (
	"ид" SERIAL NOT NULL,
	"ид_сеанса" INTEGER NOT NULL REFERENCES "Сеансы" ON DELETE CASCADE,
	"ид_места" INTEGER NOT NULL REFERENCES "Места" ON DELETE RESTRICT,
	"ид_пользователя" INTEGER REFERENCES "Пользователи" ON DELETE RESTRICT,
	"стоимость" INTEGER NOT NULL CONSTRAINT csr_ticket_price CHECK ("стоимость" > 0),
	"статус" INTEGER NOT NULL, 
		CONSTRAINT csr_tickets_state CHECK("статус" BETWEEN 0 AND 2),
	PRIMARY KEY ("ид")
);


CREATE TABLE "Фильмы_Жанры" (
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_жанра" INTEGER NOT NULL REFERENCES "Жанры" ON DELETE CASCADE,
	PRIMARY KEY ("ид_фильма", "ид_жанра")
);

CREATE TABLE "Фильмы_Группы" (
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_группы" INTEGER NOT NULL REFERENCES "Группы" ON DELETE CASCADE,
	PRIMARY KEY ("ид_фильма", "ид_группы")
);



----
---- Триггеры
----

DROP TRIGGER IF EXISTS сеансы_до_премьеры_запрещены ON "Сеансы";
DROP TRIGGER IF EXISTS проверка_сеансов ON "Сеансы";
DROP TRIGGER IF EXISTS награды_до_премьеры_запрещены ON "Награды";
DROP TRIGGER IF EXISTS оценки_до_премьеры_запрещены ON "Оценки";

----
CREATE OR REPLACE FUNCTION проверка_сеансов () RETURNS trigger AS $$ 
DECLARE 
	премьера timestamp;
BEGIN
SELECT Фильмы.премьера INTO премьера FROM "Фильмы" WHERE ид = NEW.ид_фильма;
IF NEW.начало < премьера THEN
	RAISE EXCEPTION 'Дата премьеры фильма (%) не может быть позже, чем дата начала показа (%)', премьера, NEW.начало;
END IF;

RETURN NEW;
END;
$$  LANGUAGE plpgsql;

CREATE TRIGGER "сеансы_до_премьеры_запрещены" BEFORE INSERT OR UPDATE ON "Сеансы" 
FOR EACH ROW EXECUTE PROCEDURE сеансы_до_премьеры_запрещены();
----

CREATE OR REPLACE FUNCTION награды_до_премьеры_запрещены() RETURNS trigger AS $$ 
DECLARE 
	премьера timestamp;
BEGIN
SELECT Фильмы.премьера INTO премьера FROM "Фильмы" WHERE ид = NEW.ид_фильма;
IF now() < премьера THEN
	RAISE EXCEPTION 'Награда не может вручаться до выхода фильма (премьера %)', премьера;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "награды_до_премьеры_запрещены" BEFORE INSERT OR UPDATE ON "Награды" 
FOR EACH ROW EXECUTE PROCEDURE награды_до_премьеры_запрещены();
----

CREATE OR REPLACE FUNCTION оценки_до_премьеры_запрещены() RETURNS trigger AS $$ 
DECLARE 
	премьера timestamp;
BEGIN
SELECT Фильмы.премьера INTO премьера FROM "Фильмы" WHERE ид = NEW.ид_фильма;
IF NEW.дата_время < премьера THEN
	RAISE EXCEPTION 'Оценка не может быть поставлена до премьеры фильма (премьера %)', премьера;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "оценки_до_премьеры_запрещены" BEFORE INSERT OR UPDATE ON "Оценки" 
FOR EACH ROW EXECUTE PROCEDURE оценки_до_премьеры_запрещены();