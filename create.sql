CREATE TABLE "Сети" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	"url" TEXT UNIQUE,
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
	"номер_зала" int NOT NULL CONSTRAINT csr_room_id CHECK ("номер_зала" > 0),
	PRIMARY KEY ("ид")
);

CREATE TABLE "Места" (
	"ид" SERIAL NOT NULL,
	"ид_зала" INTEGER NOT NULL REFERENCES "Залы" ON DELETE CASCADE,
	"ряд" int NOT NULL 
		CONSTRAINT csr_row CHECK ("ряд" > 0),
	"место" int NOT NULL 
		CONSTRAINT csr_place CHECK ("место" > 0),
	"стоимость" int NOT NULL 
		CONSTRAINT csr_seat_price CHECK ("стоимость" > 0),
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
	"дата_регистрации" TIMESTAMP NOT NULL
				CONSTRAINT csr_date_reg CHECK ("дата_регистрации" <= NOW()),
	PRIMARY KEY ("ид")
);

CREATE TABLE "Фильмы" (
	"ид" SERIAL NOT NULL,
	"название" TEXT NOT NULL,
	"дата_начала_съемок" TIMESTAMP NOT NULL,
	"дата_конца_съемок" TIMESTAMP,
	"дата_премьеры" TIMESTAMP,
	"продолжительность" int NOT NULL 
		CONSTRAINT csr_duration CHECK ("продолжительность" > 0),
	"бюджет" int,
		CONSTRAINT csr_budget CHECK ("бюджет" > 0),
	"возрастной_рейтинг" VARCHAR(4) NOT NULL CHECK("возрастной_рейтинг" in('G','PG','PG-13','R','NC-17')),
	"слоган" TEXT,
	CONSTRAINT csr_movie_start_end_range CHECK ("дата_конца_съемок" > "дата_начала_съемок"),
	CONSTRAINT csr_movie_release_end CHECK ("дата_конца_съемок" < "дата_премьеры"),
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
	"значение" int NOT NULL CONSTRAINT csr_rate CHECK ("значение" >= 1 AND "значение" <= 10), 
	"комментарий" TEXT,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Награды" (
	"ид" SERIAL NOT NULL,
	"ид_фильма" INTEGER NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_человека" INTEGER NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"Название" TEXT NOT NULL,
	"Тип" TEXT NOT NULL,
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
	"дата_начала" TIMESTAMP NOT NULL,
	"дата_конца" TIMESTAMP NOT NULL,
	CONSTRAINT csr_session_date CHECK ("дата_начала" < "дата_конца"),
	PRIMARY KEY ("ид")
);


CREATE TABLE "Билеты" (
	"ид_места" INTEGER NOT NULL REFERENCES "Места" ON DELETE RESTRICT,
	"ид_сеанса" INTEGER NOT NULL REFERENCES "Сеансы" ON DELETE CASCADE,
	"ид_пользователя" int REFERENCES "Пользователи" ON DELETE RESTRICT,
	"стоимость" int NOT NULL CONSTRAINT csr_ticket_price CHECK ("стоимость" > 0),
	"статус" int NOT NULL,
	PRIMARY KEY ("ид_места", "ид_сеанса")
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

CREATE TABLE "Люди_Группы" (
	"ид_человека" INTEGER NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"ид_группы" INTEGER NOT NULL REFERENCES "Группы" ON DELETE CASCADE,
	PRIMARY KEY ("ид_человека", "ид_группы")
);

CREATE TABLE "Награды_Люди" (
	"ид_человека" INTEGER NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"ид_награды" INTEGER NOT NULL REFERENCES "Награды" ON DELETE CASCADE,
	PRIMARY KEY ("ид_человека", "ид_награды")
);
