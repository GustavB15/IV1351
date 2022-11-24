

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.discounts(
    discount_id SERIAL NOT NULL,
    sibling_discount INT,

    CONSTRAINT discount_id_pk PRIMARY KEY (discount_id)
);

ALTER TABLE public.discounts OWNER TO postgres;

CREATE TABLE public.person (
    person_id SERIAL NOT NULL,
    street character varying(100),
    zip character varying(20),
    city character varying(100),
    person_number character(11) NOT NULL UNIQUE,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    phone_number character varying(100),
    email_adress character varying(100),

    CONSTRAINT person_id_pk PRIMARY KEY (person_id)
);


ALTER TABLE public.person OWNER TO postgres;

CREATE TABLE public.instructor (
    instructor_id SERIAL NOT NULL,
    person_id INT NOT NULL,

    CONSTRAINT instructor_id_pk PRIMARY KEY (instructor_id),
    CONSTRAINT person_id_fk FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE
);


ALTER TABLE public.instructor OWNER TO postgres;

CREATE TABLE public.genre (
    genre_id SERIAL NOT NULL,
    genre character varying(100) NOT NULL UNIQUE,

    CONSTRAINT genre_id_pk PRIMARY KEY(genre_id)
);

ALTER TABLE public.genre OWNER TO postgres;

CREATE TABLE public.known_genres(
    genre_id INT NOT NULL,
    instructor_id INT NOT NULL,

    CONSTRAINT known_genres_pk PRIMARY KEY (genre_id, instructor_id),
    CONSTRAINT genre_id_fk FOREIGN KEY (genre_id) REFERENCES public.genre(genre_id) ON DELETE CASCADE,
    CONSTRAINT instructor_id_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instructor_id) ON DELETE CASCADE

);

ALTER TABLE public.known_genres OWNER TO postgres;

CREATE TABLE public.difficulty (
    difficulty_id SERIAL NOT NULL,
    difficulty character varying(50) NOT NULL UNIQUE,
    difficulty_cost INT NOT NULL,

    CONSTRAINT difficulty_id_pk PRIMARY KEY (difficulty_id)
);

ALTER TABLE public.difficulty OWNER TO postgres;

CREATE TABLE public.instrument_type(
    instrument_type_id SERIAL NOT NULL,
    instrument_type character varying(100) NOT NULL UNIQUE,

    CONSTRAINT instrument_type_id_pk PRIMARY KEY (instrument_type_id)
);

ALTER TABLE public.instrument_type OWNER TO postgres;

CREATE TABLE public.instrument (
    instrument_type_id INT NOT NULL,
    person_id INT NOT NULL,
    difficulty_id INT NOT NULL,

    CONSTRAINT instrument_pk PRIMARY KEY (instrument_type_id, person_id),
    CONSTRAINT instrument_type_id_fk FOREIGN KEY (instrument_type_id) REFERENCES public.instrument_type(instrument_type_id) ON DELETE CASCADE,
    CONSTRAINT person_id_fk FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE,
    CONSTRAINT difficulty_id_fk FOREIGN KEY (difficulty_id) REFERENCES public.difficulty(difficulty_id) ON DELETE CASCADE
);

ALTER TABLE public.instrument OWNER TO postgres;


CREATE TABLE public.student (
    student_id SERIAL NOT NULL,
    person_id INT NOT NULL,
    caregiver_phone_number character varying(20),
    caregiver_email_adress character varying(100),
    discount_id INT NOT NULL,

    CONSTRAINT student_id_pk PRIMARY KEY(student_id),
    CONSTRAINT person_id_fk FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE,
    CONSTRAINT discount_id_fk FOREIGN KEY (discount_id) REFERENCES public.discounts(discount_id)
);

ALTER TABLE public.student OWNER TO postgres;

CREATE TABLE public.stock(
    stock_id SERIAL NOT NULL,
    brand character varying(100),
    instrument_type character varying(100) NOT NULL,
    cost_to_rent INT NOT NULL,
    model character varying(100),

    CONSTRAINT stock_id_pk PRIMARY KEY (stock_id)
);

ALTER TABLE public.stock OWNER TO postgres;

CREATE TABLE public.instrument_for_rent(
    instrument_for_rent_id SERIAL NOT NULL,
    stock_id INT NOT NULL,

    CONSTRAINT instrument_for_rent_id_pk PRIMARY KEY (instrument_for_rent_id),
    CONSTRAINT stock_id_fk FOREIGN KEY(stock_id) REFERENCES public.stock(stock_id)

);

ALTER TABLE public.instrument_for_rent OWNER TO postgres;

CREATE TABLE public.lease(
    student_id INT NOT NULL,
    instrument_for_rent_id INT NOT NULL,
    start_rent_date TIMESTAMP NOT NULL,
    end_rent_date TIMESTAMP NOT NULL,

    CONSTRAINT lease_pk PRIMARY KEY(student_id, instrument_for_rent_id),
    CONSTRAINT instrument_for_rent_id_fk FOREIGN KEY(instrument_for_rent_id) REFERENCES public.instrument_for_rent(instrument_for_rent_id),
    CONSTRAINT student_id_fk FOREIGN KEY(student_id) REFERENCES public.student(student_id) ON DELETE CASCADE

);

ALTER TABLE public.lease OWNER TO postgres;

CREATE TABLE public.siblings(
    student_id INT NOT NULL,
    student_sibling_id INT NOT NULL,

        CONSTRAINT siblings_pk PRIMARY KEY(student_id, student_sibling_id),
        CONSTRAINT student_id_fk FOREIGN KEY(student_id) REFERENCES public.student(student_id) ON DELETE CASCADE,
        CONSTRAINT student_sibling_id_fk FOREIGN KEY(student_sibling_id) REFERENCES public.student(student_id) ON DELETE CASCADE
);

ALTER TABLE public.siblings OWNER TO postgres;

CREATE TABLE public.location(
    location_id SERIAL NOT NULL,
    room character varying(20) NOT NULL,
    campus character varying(100) NOT NULL,

    CONSTRAINT location_id_pk PRIMARY KEY(location_id)
);

ALTER TABLE public.location OWNER TO postgres;

CREATE TABLE public.lesson_type(
    lesson_type_id SERIAL NOT NULL,
    lesson_type character varying(50) NOT NULL UNIQUE, 
    type_cost INT NOT NULL,

    CONSTRAINT lesson_type_id_pk PRIMARY KEY (lesson_type_id)
);

ALTER TABLE public.lesson_type OWNER TO postgres;

CREATE TABLE public.lesson(
    lesson_id SERIAL NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    location_id INT NOT NULL,
    instructor_id INT NOT NULL,
    minimum_participants INT,
    maximum_participants INT,
    instrument_type_id INT,
    difficulty_id INT,
    lesson_type_id INT NOT NULL,
    genre_id INT,

    CONSTRAINT lesson_id_pk PRIMARY KEY(lesson_id),
    CONSTRAINT instrument_type_id_fk FOREIGN KEY (instrument_type_id) REFERENCES public.instrument_type(instrument_type_id),
    CONSTRAINT difficulty_id_fk FOREIGN KEY (difficulty_id) REFERENCES public.difficulty(difficulty_id),
    CONSTRAINT lesson_type_id_fk FOREIGN KEY(lesson_type_id) REFERENCES public.lesson_type(lesson_type_id),
    CONSTRAINT instructor_id_fk FOREIGN KEY(instructor_id) REFERENCES public.instructor(instructor_id),
    CONSTRAINT location_id_fk FOREIGN KEY(location_id) REFERENCES public.location(location_id)
);

ALTER TABLE public.lesson OWNER TO postgres;

CREATE TABLE public.student_lesson_xref(
    student_id INT NOT NULL,
    lesson_id INT NOT NULL,

    CONSTRAINT student_lesson_xref_pk PRIMARY KEY(student_id, lesson_id),
    CONSTRAINT lesson_id_fk FOREIGN KEY (lesson_id) REFERENCES public.lesson(lesson_id) ON DELETE CASCADE,
    CONSTRAINT student_id_fk FOREIGN KEY(student_id) REFERENCES public.student(student_id) ON DELETE CASCADE
);

ALTER TABLE public.student_lesson_xref OWNER TO postgres;