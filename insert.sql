insert into Фильмы(название, дата_начала_съемок, дата_конца_съемок,дата_премьеры,продолжительность,бюджет,возрастной_рейтинг) 
	values('Звездные войны','1976-03-22','1977-04-10','1977-05-25','121','11000','G');

insert into Группы(название) values('Режиссеры');
insert into Люди(фио) values('Джон Уолтон Лукас');
insert into Роли(название,ид_человека,ид_группы) values('Режиссер',currval('Люди_ид_seq'), currval('Группы_ид_seq'));
insert into Фильмы_Группы values(currval('Фильмы_ид_seq'), currval('Группы_ид_seq'));
insert into Группы(название) values('Актеры');
insert into Фильмы_Группы values(currval('Фильмы_ид_seq'), currval('Группы_ид_seq'));
insert into Люди(фио) values('Марк Хэммил');
insert into Роли(название,ид_человека,ид_группы) values('Роль Люка Скайоукера',currval('Люди_ид_seq'), currval('Группы_ид_seq'));
insert into Люди(фио) values('Харрисон Форд');
insert into Роли(название,ид_человека,ид_группы) values('Роль Хана Соло',currval('Люди_ид_seq'), currval('Группы_ид_seq'));
insert into Люди(фио) values('Харрисон Форд');
insert into Роли(название,ид_человека,ид_группы) values('Роль Хана Соло',currval('Люди_ид_seq'), currval('Группы_ид_seq'));
insert into Люди(фио) values('Кэрри Фишер');
insert into Роли(название,ид_человека,ид_группы) values('Роль Леи Органа',currval('Люди_ид_seq'), currval('Группы_ид_seq'));
insert into Жанры(название) values('Космическая опера');
insert into Фильмы_Жанры values(currval('Фильмы_ид_seq'), currval('Жанры_ид_seq'));
insert into Медиа(название, ид_фильма, тип, url) values('Звёздные войны: Новая надежда', currval('Фильмы_ид_seq'), 'фильм', 'https://starwars.com/ep4.mp4');

insert into Сети(название, url) values('Алмаз', 'http://almaz.ru');
insert into Кинотеатры(ид_сети, название, город, адрес) values(currval('Сети_ид_seq'), 'АлмазСПБ', 'Санкт-Петербург', 'Думская 8');
insert into Залы(ид_кинотеатра, номер_зала) values (currval('Кинотеатры_ид_seq'), 1);
insert into Места(ид_зала, ряд, место, стоимость) values(currval('Залы_ид_seq'), 1, 1, 100);


