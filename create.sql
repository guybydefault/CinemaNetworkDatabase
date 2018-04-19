CREATE TABLE "Сети" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	"сайт" TEXT UNIQUE,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Кинотеатры" (
	"ид" serial NOT NULL,
	"ид_сети" serial NOT NULL REFERENCES "Сети" ON DELETE CASCADE,
	"название" TEXT NOT NULL,
	"город" TEXT NOT NULL,
	"адрес" TEXT NOT NULL,
	PRIMARY KEY ("ид")
);

CREATE TABLE "Залы" (
	"ид" serial NOT NULL,
	"ид_кинотеатра" serial NOT NULL REFERENCES "Кинотеатры" ON DELETE CASCADE,
	"номер_зала" serial NOT NULL CONSTRAINT csr_room_id CHECK ("номер_зала" > 0),
	PRIMARY KEY ("ид")
);

CREATE TABLE "Места" (
	"ид" serial NOT NULL,
	"ид_зала" serial NOT NULL REFERENCES "Залы" ON DELETE CASCADE,
	"ряд" int NOT NULL 
		CONSTRAINT csr_row CHECK ("ряд" > 0),
	"место" int NOT NULL 
		CONSTRAINT csr_place CHECK ("место" > 0),
	"стоимость" int NOT NULL 
		CONSTRAINT csr_seat_price CHECK ("стоимость" > 0),
	PRIMARY KEY ("ид")
);

CREATE TABLE "Жанры" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	PRIMARY KEY ("ид")
);


CREATE TABLE "Люди" (
	"ид" serial NOT NULL,
	"фио" TEXT NOT NULL,
	CONSTRAINT Люди_pk PRIMARY KEY ("ид")
);

CREATE TABLE "Пользователи" (
	"ид" serial NOT NULL,
	"логин" TEXT NOT NULL UNIQUE,
	"пароль" TEXT NOT NULL,
	"фио" TEXT NOT NULL,
	"дата_регистрации" TIMESTAMP NOT NULL
				CONSTRAINT csr_date_reg CHECK ("дата_регистрации" <= NOW()),
	CONSTRAINT Пользователи_pk PRIMARY KEY ("ид")
);

CREATE TABLE "Фильмы" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL,
	"дата_начала_съемок" TIMESTAMP NOT NULL,
	"дата_конца_съемок" TIMESTAMP,
	"дата_премьеры" TIMESTAMP,
	"продолжительность" int NOT NULL 
		CONSTRAINT csr_duration CHECK ("продолжительность" > 0),
	"бюджет" int,
		CONSTRAINT csr_budget CHECK ("бюджет" > 0),
	"возрастной_рейтинг" varchar(4) NOT NULL,
	"слоган" TEXT,
	CONSTRAINT csr_movie_start_end_range CHECK ("дата_конца_съемок" > "дата_начала_съемок"),
	CONSTRAINT csr_movie_release_end CHECK ("дата_конца_съемок" < "дата_премьеры"),
	CONSTRAINT Фильмы_pk PRIMARY KEY ("ид")
);


CREATE TABLE "Медиа" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL,
	"ид_фильма" serial NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"тип" TEXT NOT NULL,
	"url" TEXT NOT NULL
		CONSTRAINT csr_url CHECK ("url" SIMILAR TO '^(https?://|www\\.)[\.A-Za-z0-9\-]+\\.[a-zA-Z]{2,4}'),
	CONSTRAINT Медиа_pk PRIMARY KEY ("ид")
);

CREATE TABLE "Оценки" (
	"ид" serial NOT NULL,
	"ид_фильма" serial NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_пользователя" serial NOT NULL REFERENCES "Пользователи" ON DELETE CASCADE,
	"значение" int NOT NULL CONSTRAINT csr_rate CHECK ("значение" >= 1 AND "значение" <= 10), 
	"комментарий" TEXT,
	CONSTRAINT Оценки_pk PRIMARY KEY ("ид")
);

CREATE TABLE "Награды" (
	"ид" serial NOT NULL,
	"ид_фильма" serial NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_человека" serial NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"Название" TEXT NOT NULL,
	"Тип" TEXT NOT NULL,
	CONSTRAINT Награды_pk PRIMARY KEY ("ид")
);

CREATE TABLE "Группы" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL,
	CONSTRAINT Группы_pk PRIMARY KEY ("ид")
);

CREATE TABLE "Роли" (
	"название" serial NOT NULL,
	"ид_человека" serial NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"ид_группы" serial NOT NULL REFERENCES "Группы" ON DELETE CASCADE,
	PRIMARY KEY ("название","ид_человека","ид_группы")
);


CREATE TABLE "Сеансы" (
	"ид" serial NOT NULL,
	"ид_фильма" serial NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_зала" serial NOT NULL REFERENCES "Залы" ON DELETE CASCADE,
	"дата_начала" TIMESTAMP NOT NULL,
	"дата_конца" TIMESTAMP NOT NULL,
	CONSTRAINT csr_session_date CHECK ("дата_начала" < "дата_конца"),
	PRIMARY KEY ("ид")
);


CREATE TABLE "Билеты" (
	"ид" serial NOT NULL,
	"ид_места" serial NOT NULL REFERENCES "Места" ON DELETE RESTRICT,
	"ид_сеанса" serial NOT NULL REFERENCES "Сеансы" ON DELETE CASCADE,
	"ид_пользователя" int REFERENCES "Пользователи" ON DELETE RESTRICT,
	"стоимость" int NOT NULL CONSTRAINT csr_ticket_price CHECK ("стоимость" > 0),
	"статус" int NOT NULL,
	PRIMARY KEY ("ид")
);


CREATE TABLE "Фильмы_Жанры" (
	"ид_фильма" serial NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_жанра" serial NOT NULL REFERENCES "Жанры" ON DELETE CASCADE,
	PRIMARY KEY ("ид_фильма", "ид_жанра")
);

CREATE TABLE "Фильмы_Группы" (
	"ид_фильма" serial NOT NULL REFERENCES "Фильмы" ON DELETE CASCADE,
	"ид_группы" serial NOT NULL REFERENCES "Группы" ON DELETE CASCADE,
	PRIMARY KEY ("ид_фильма", "ид_группы")
);

CREATE TABLE "Люди_Группы" (
	"ид_человека" serial NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"ид_группы" serial NOT NULL REFERENCES "Группы" ON DELETE CASCADE,
	PRIMARY KEY ("ид_человека", "ид_группы")
);

CREATE TABLE "Награды_Люди" (
	"ид_человека" serial NOT NULL REFERENCES "Люди" ON DELETE CASCADE,
	"ид_награды" serial NOT NULL REFERENCES "Награды" ON DELETE CASCADE,
	PRIMARY KEY ("ид_человека", "ид_награды")
);
