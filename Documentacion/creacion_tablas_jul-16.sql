
-- Table: explanations

-- DROP TABLE explanations;

CREATE TABLE explanations
(
  id serial NOT NULL,
  name character varying,
  detail text,
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





INSERT INTO 
channels(
user_id, mail, sms, 
whatsapp, push, created_at, updated_at)

SELECT 

 id,

 CASE WHEN (users.email is not null)
 THEN true
 ELSE false
 END AS mail,

 CASE WHEN (users.telephone is not null)
 THEN true
 ELSE false
 END AS sms,

 CASE WHEN (users.telephone is not null)
 THEN true
 ELSE false
 END AS whatsapp,

 CASE WHEN (users.push_token is not null)
 THEN true
 ELSE false
 END AS push ,

 Now(),
 Now()

 FROM users 
;


INSERT INTO notification_types (
name, created_at, updated_at)
values('result',
now(),
now())
;


INSERT INTO notification_types (
name, created_at, updated_at)
values('challenge',
now(),
now())
;

INSERT INTO notification_types (
name, created_at, updated_at)
values('news',
now(),
now())
;


INSERT INTO notification_types (
name, created_at, updated_at)
values('personal',
now(),
now())
;




