
-- Table: explanations

-- DROP TABLE explanations;

CREATE TABLE explanations
(
  id serial NOT NULL,
  name character varying,
  detail text,
   active boolean,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT explanations_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE explanations
  OWNER TO ucfdkl13ogoaal;

-- Index: index_explanations_on_name

-- DROP INDEX index_explanations_on_name;

CREATE UNIQUE INDEX index_explanations_on_name
  ON explanations
  USING btree
  (name COLLATE pg_catalog."default");


-- Table: explanations_users

-- DROP TABLE explanations_users;

CREATE TABLE explanations_users
(
  id serial NOT NULL,
  user_id integer NOT NULL,
  explanation_id integer NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT explanations_users_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE explanations_users
  OWNER TO ucfdkl13ogoaal;

-- Index: index_explanations_users_on_user_id_and_explanation_id

-- DROP INDEX index_explanations_users_on_user_id_and_explanation_id;

CREATE UNIQUE INDEX index_explanations_users_on_user_id_and_explanation_id
  ON explanations_users
  USING btree
  (user_id, explanation_id);


-- Table: invitation_statuses

-- DROP TABLE invitation_statuses;

CREATE TABLE invitation_statuses
(
  id serial NOT NULL,
  name character varying,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT invitation_statuses_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE invitation_statuses
  OWNER TO ucfdkl13ogoaal;

-- Index: index_invitation_statuses_on_name

-- DROP INDEX index_invitation_statuses_on_name;

CREATE UNIQUE INDEX index_invitation_statuses_on_name
  ON invitation_statuses
  USING btree
  (name COLLATE pg_catalog."default");


-- Table: invitations

-- DROP TABLE invitations;

CREATE TABLE invitations
(
  id serial NOT NULL,
  won_coins integer,
  guest_ip inet,
  detail character varying,
  invitation_status_id integer NOT NULL,
  request_id integer NOT NULL,
  guest_user_id integer NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT invitations_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE invitations
  OWNER TO ucfdkl13ogoaal;



-- Table: request_types

-- DROP TABLE request_types;

CREATE TABLE request_types
(
  id serial NOT NULL,
  name character varying,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT request_types_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE request_types
  OWNER TO ucfdkl13ogoaal;

-- Index: index_request_types_on_name

-- DROP INDEX index_request_types_on_name;

CREATE UNIQUE INDEX index_request_types_on_name
  ON request_types
  USING btree
  (name COLLATE pg_catalog."default");



-- Table: requests

-- DROP TABLE requests;

CREATE TABLE requests
(
  id serial NOT NULL,
  request_type_id integer NOT NULL,
  host_user_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT requests_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE requests
  OWNER TO ucfdkl13ogoaal;

-- Index: index_requests_on_request_type_id

-- DROP INDEX index_requests_on_request_type_id;

CREATE UNIQUE INDEX index_requests_on_request_type_id
  ON requests
  USING btree
  (request_type_id);


-- Column: push_token

-- ALTER TABLE users DROP COLUMN push_token;

ALTER TABLE users ADD COLUMN push_token character varying;


-- Column: telephone

-- ALTER TABLE users DROP COLUMN telephone;

ALTER TABLE users ADD COLUMN telephone character varying;

ALTER TABLE matches alter column 
  datetime type timestamp with time zone;


ALTER TABLE tables alter column 
  datetime type timestamp with time zone;

-- Table: sent_mails

-- DROP TABLE sent_mails;

CREATE TABLE sent_mails
(
  id serial NOT NULL,
  "from" character varying,
  "to" character varying,
  subject character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT sent_mails_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sent_mails
  OWNER TO ucfdkl13ogoaal;


ALTER TABLE tables alter column 
  start_time type timestamp with time zone;

ALTER TABLE tables alter column 
  end_time type timestamp with time zone;

ALTER TABLE sent_mails alter column 
  created_at type timestamp with time zone;


-- Table: sent_mails

-- DROP TABLE sent_mails;

CREATE TABLE sent_mails
(
  id serial NOT NULL,
  "from" character varying,
  "to" character varying,
  subject character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT sent_mails_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sent_mails
  OWNER TO florencia;


-- Table: channels

-- DROP TABLE channels;

CREATE TABLE channels
(
  id serial NOT NULL,
  user_id integer NOT NULL,
  mail boolean NOT NULL DEFAULT true,
  sms boolean NOT NULL DEFAULT true,
  whatsapp boolean NOT NULL DEFAULT true,
  push boolean NOT NULL DEFAULT true,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT channels_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE channels
  OWNER TO ucfdkl13ogoaal;


-- Table: notifications

-- DROP TABLE notifications;

CREATE TABLE notifications
(
  id serial NOT NULL,
  user_id integer,
  notification_type_id integer,
  title character varying,
  image character varying,
  text text,
  action text,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_75cdc2096d FOREIGN KEY (notification_type_id)
      REFERENCES notification_types (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_b080fb4855 FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE notifications
  OWNER TO ucfdkl13ogoaal;

-- Index: index_notifications_on_notification_type_id

-- DROP INDEX index_notifications_on_notification_type_id;

CREATE INDEX index_notifications_on_notification_type_id
  ON notifications
  USING btree
  (notification_type_id);

-- Index: index_notifications_on_user_id

-- DROP INDEX index_notifications_on_user_id;

CREATE INDEX index_notifications_on_user_id
  ON notifications
  USING btree
  (user_id);



-- Table: languages

-- DROP TABLE languages;

CREATE TABLE languages
(
  id serial NOT NULL,
  name character varying,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT languages_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE languages
  OWNER TO ucfdkl13ogoaal;

-- Index: index_languages_on_name

-- DROP INDEX index_languages_on_name;

CREATE UNIQUE INDEX index_languages_on_name
  ON languages
  USING btree
  (name COLLATE pg_catalog."default");



-- Table: countries

-- DROP TABLE countries;

CREATE TABLE countries
(
  id serial NOT NULL,
  name character varying,
  language_id integer,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT countries_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_6f479b409c FOREIGN KEY (language_id)
      REFERENCES languages (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE countries
  OWNER TO ucfdkl13ogoaal;

-- Index: index_countries_on_language_id

-- DROP INDEX index_countries_on_language_id;

CREATE INDEX index_countries_on_language_id
  ON countries
  USING btree
  (language_id);

-- Index: index_countries_on_name

-- DROP INDEX index_countries_on_name;

CREATE UNIQUE INDEX index_countries_on_name
  ON countries
  USING btree
  (name COLLATE pg_catalog."default");



-- Table: currencies

-- DROP TABLE currencies;

CREATE TABLE currencies
(
  id serial NOT NULL,
  name character varying,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT currencies_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE currencies
  OWNER TO ucfdkl13ogoaal;


-- Table: payment_services

-- DROP TABLE payment_services;

CREATE TABLE payment_services
(
  id serial NOT NULL,
  name character varying,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT payment_services_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE payment_services
  OWNER TO ucfdkl13ogoaal;

-- Index: index_payment_services_on_name

-- DROP INDEX index_payment_services_on_name;

CREATE UNIQUE INDEX index_payment_services_on_name
  ON payment_services
  USING btree
  (name COLLATE pg_catalog."default");



-- Table: t_deposits

-- DROP TABLE t_deposits;

CREATE TABLE t_deposits
(
  id serial NOT NULL,
  coins integer,
  user_id integer,
  detail character varying,
  currency_id integer,
  country_id integer,
  payment_service_id integer,
  transaction_id character varying,
  price double precision,
  operator character varying,
  type character varying,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT t_deposits_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_3bb17d497f FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_74201ea829 FOREIGN KEY (country_id)
      REFERENCES countries (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_bbfcd38b97 FOREIGN KEY (payment_service_id)
      REFERENCES payment_services (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_ee40538629 FOREIGN KEY (currency_id)
      REFERENCES currencies (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE t_deposits
  OWNER TO ucfdkl13ogoaal;

-- Index: index_t_deposits_on_country_id

-- DROP INDEX index_t_deposits_on_country_id;

CREATE INDEX index_t_deposits_on_country_id
  ON t_deposits
  USING btree
  (country_id);

-- Index: index_t_deposits_on_currency_id

-- DROP INDEX index_t_deposits_on_currency_id;

CREATE INDEX index_t_deposits_on_currency_id
  ON t_deposits
  USING btree
  (currency_id);

-- Index: index_t_deposits_on_payment_service_id

-- DROP INDEX index_t_deposits_on_payment_service_id;

CREATE INDEX index_t_deposits_on_payment_service_id
  ON t_deposits
  USING btree
  (payment_service_id);

-- Index: index_t_deposits_on_user_id

-- DROP INDEX index_t_deposits_on_user_id;

CREATE INDEX index_t_deposits_on_user_id
  ON t_deposits
  USING btree
  (user_id);



-- Table: t_prizes

-- DROP TABLE t_prizes;

CREATE TABLE t_prizes
(
  id serial NOT NULL,
  coins integer,
  user_id integer,
  detail character varying,
  prize_id integer,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT t_prizes_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_4d8589d70a FOREIGN KEY (prize_id)
      REFERENCES prizes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_c1b16bfb73 FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE t_prizes
  OWNER TO ucfdkl13ogoaal;

-- Index: index_t_prizes_on_prize_id

-- DROP INDEX index_t_prizes_on_prize_id;

CREATE INDEX index_t_prizes_on_prize_id
  ON t_prizes
  USING btree
  (prize_id);

-- Index: index_t_prizes_on_user_id

-- DROP INDEX index_t_prizes_on_user_id;

CREATE INDEX index_t_prizes_on_user_id
  ON t_prizes
  USING btree
  (user_id);





