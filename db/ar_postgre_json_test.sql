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

CREATE TABLE public.posts (
    id integer NOT NULL,
    old_data json,
    data jsonb
);

CREATE INDEX index_posts_data_gin ON public.posts USING  gin (data);

CREATE VIEW public.post_questions AS
 SELECT posts.id,
    (posts.data ->> 'title'::text) AS title,
    (posts.data #>> '{author,name}'::text[]) AS author_name,
    (posts.data #>> '{author,email}'::text[]) AS author_email,
    ((posts.data ->> 'tags'::text))::jsonb AS tags,
    ((posts.data ->> 'draft'::text))::boolean AS draft
   FROM public.posts;

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);

ALTER TABLE ONLY public.posts ADD CONSTRAINT posts_pkey PRIMARY KEY (id);
