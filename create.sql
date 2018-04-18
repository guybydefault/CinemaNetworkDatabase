CREATE TABLE "Места" (
	"ид" serial NOT NULL,
	"ид_зала" int NOT NULL,
	"ряд" int NOT NULL,
	"место" int NOT NULL,
	"стоимость" int NOT NULL,
	CONSTRAINT Места_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Жанры" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	CONSTRAINT Жанры_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Кинотеатры " (
	"ид" serial NOT NULL,
	"ид_сети" int NOT NULL,
	"название" TEXT NOT NULL,
	"город" TEXT NOT NULL,
	"адрес" TEXT NOT NULL,
	CONSTRAINT Кинотеатры _pk PRIMARY KEY ("ид")
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
	"дата_регистрации" TIMESTAMP NOT NULL,
	CONSTRAINT Пользователи_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Медиа" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL,
	"ид_фильма" int NOT NULL,
	"тип" TEXT NOT NULL,
	"url" TEXT NOT NULL,
	CONSTRAINT Медиа_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Фильмы" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL,
	"дата_начала_съемок" TIMESTAMP NOT NULL,
	"	дата_конца_съемок" TIMESTAMP,
	"дата_премьеры" TIMESTAMP,
	"продолжительность" int NOT NULL,
	"бюджет" int,
	"возрастной_рейтинг" varchar(4) NOT NULL,
	"слоган" TEXT,
	CONSTRAINT Фильмы_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Оценки" (
	"ид" serial NOT NULL,
	"ид_фильма" int NOT NULL,
	"ид_пользователя" int NOT NULL,
	"значение" int NOT NULL,
	"комментарий" TEXT,
	CONSTRAINT Оценки_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Награды" (
	"ид" serial NOT NULL,
	"ид_фильма" int NOT NULL,
	"ид_человека" int NOT NULL,
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
	"ид_человека" int NOT NULL,
	"ид_группы" int NOT NULL,
	CONSTRAINT Роли_pk PRIMARY KEY ("название","ид_человека","ид_группы")
);



CREATE TABLE "Сети" (
	"ид" serial NOT NULL,
	"название" TEXT NOT NULL UNIQUE,
	"сайт" TEXT UNIQUE,
	CONSTRAINT Сети_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Сеансы" (
	"ид" serial NOT NULL,
	"ид_фильма" int NOT NULL,
	"ид_зала" int NOT NULL,
	"дата_начала" TIMESTAMP NOT NULL,
	"дата_конца" TIMESTAMP NOT NULL,
	CONSTRAINT Сеансы_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Залы" (
	"ид" serial NOT NULL,
	"ид_кинотеатра" int NOT NULL,
	"номер зала" int NOT NULL,
	CONSTRAINT Залы_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Билеты" (
	"ид" serial NOT NULL,
	"ид_места" int NOT NULL,
	"ид_сеанса" int NOT NULL,
	"ид_пользователя" int,
	"стоимость" int NOT NULL,
	"статус" int NOT NULL,
	CONSTRAINT Билеты_pk PRIMARY KEY ("ид")
);



CREATE TABLE "Фильмы_Жанры" (
	"ид_фильма" int NOT NULL,
	"ид_жанра" int NOT NULL
);



CREATE TABLE "Фильмы_Группы" (
	"ид_фильма" int NOT NULL,
	"ид_группы" int NOT NULL
);



CREATE TABLE "Люди_Группы" (
	"ид_человека" int NOT NULL,
	"ид_группы" int NOT NULL
);



CREATE TABLE "Награды_Люди" (
	"ид_человека" int NOT NULL,
	"ид_награды" int NOT NULL
);



ALTER TABLE "Места" ADD CONSTRAINT "Места_fk0" FOREIGN KEY ("ид_зала") REFERENCES "Залы"("ид");


ALTER TABLE "Кинотеатры " ADD CONSTRAINT "Кинотеатры _fk0" FOREIGN KEY ("ид_сети") REFERENCES "Сети"("ид");



ALTER TABLE "Медиа" ADD CONSTRAINT "Медиа_fk0" FOREIGN KEY ("ид_фильма") REFERENCES "Фильмы"("ид");


ALTER TABLE "Оценки" ADD CONSTRAINT "Оценки_fk0" FOREIGN KEY ("ид_фильма") REFERENCES "Фильмы"("ид");
ALTER TABLE "Оценки" ADD CONSTRAINT "Оценки_fk1" FOREIGN KEY ("ид_пользователя") REFERENCES "Пользователи"("ид");

ALTER TABLE "Награды" ADD CONSTRAINT "Награды_fk0" FOREIGN KEY ("ид_фильма") REFERENCES "Фильмы"("ид");
ALTER TABLE "Награды" ADD CONSTRAINT "Награды_fk1" FOREIGN KEY ("ид_человека") REFERENCES "Люди"("ид");


ALTER TABLE "Роли" ADD CONSTRAINT "Роли_fk0" FOREIGN KEY ("ид_человека") REFERENCES "Люди"("ид");
ALTER TABLE "Роли" ADD CONSTRAINT "Роли_fk1" FOREIGN KEY ("ид_группы") REFERENCES "Группы"("ид");


ALTER TABLE "Сеансы" ADD CONSTRAINT "Сеансы_fk0" FOREIGN KEY ("ид_фильма") REFERENCES "Фильмы"("ид");
ALTER TABLE "Сеансы" ADD CONSTRAINT "Сеансы_fk1" FOREIGN KEY ("ид_зала") REFERENCES "Залы"("ид");

ALTER TABLE "Залы" ADD CONSTRAINT "Залы_fk0" FOREIGN KEY ("ид_кинотеатра") REFERENCES "Кинотеатры "("ид");

ALTER TABLE "Билеты" ADD CONSTRAINT "Билеты_fk0" FOREIGN KEY ("ид_места") REFERENCES "Места"("ид");
ALTER TABLE "Билеты" ADD CONSTRAINT "Билеты_fk1" FOREIGN KEY ("ид_сеанса") REFERENCES "Сеансы"("ид");
ALTER TABLE "Билеты" ADD CONSTRAINT "Билеты_fk2" FOREIGN KEY ("ид_пользователя") REFERENCES "Пользователи"("ид");

ALTER TABLE "Фильмы_Жанры" ADD CONSTRAINT "Фильмы_Жанры_fk0" FOREIGN KEY ("ид_фильма") REFERENCES "Фильмы"("ид");
ALTER TABLE "Фильмы_Жанры" ADD CONSTRAINT "Фильмы_Жанры_fk1" FOREIGN KEY ("ид_жанра") REFERENCES "Жанры"("ид");

ALTER TABLE "Фильмы_Группы" ADD CONSTRAINT "Фильмы_Группы_fk0" FOREIGN KEY ("ид_фильма") REFERENCES "Фильмы"("ид");
ALTER TABLE "Фильмы_Группы" ADD CONSTRAINT "Фильмы_Группы_fk1" FOREIGN KEY ("ид_группы") REFERENCES "Группы"("ид");

ALTER TABLE "Люди_Группы" ADD CONSTRAINT "Люди_Группы_fk0" FOREIGN KEY ("ид_человека") REFERENCES "Люди"("ид");
ALTER TABLE "Люди_Группы" ADD CONSTRAINT "Люди_Группы_fk1" FOREIGN KEY ("ид_группы") REFERENCES "Группы"("ид");

ALTER TABLE "Награды_Люди" ADD CONSTRAINT "Награды_Люди_fk0" FOREIGN KEY ("ид_человека") REFERENCES "Люди"("ид");
ALTER TABLE "Награды_Люди" ADD CONSTRAINT "Награды_Люди_fk1" FOREIGN KEY ("ид_награды") REFERENCES "Награды"("ид");

