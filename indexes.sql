CREATE UNIQUE INDEX Оценки_фильм_id ON Оценки (ид_фильма);
CREATE UNIQUE INDEX Оценки_пользователь_id ON Оценки (ид_пользователя);
CREATE UNIQUE INDEX Сеансы_дата_начала_id ON Сеансы(дата_начала);
CREATE UNIQUE INDEX Сеансы_дата_конца_id ON Сеансы(дата_конца);
