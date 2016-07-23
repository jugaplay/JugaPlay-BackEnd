
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
  detail string,
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







