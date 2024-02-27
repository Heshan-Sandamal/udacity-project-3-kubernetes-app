CREATE TABLE users
  (
     id         SERIAL NOT NULL CONSTRAINT users_pk PRIMARY KEY,
     first_name VARCHAR(50) NOT NULL,
     last_name  VARCHAR(50) NOT NULL,
     joined_at  TIMESTAMP NOT NULL,
     is_active  BOOLEAN DEFAULT true NOT NULL
  );

CREATE INDEX users_is_active_index
  ON users (is_active);

CREATE TABLE tokens
  (
     id         SERIAL NOT NULL CONSTRAINT tokens_pk PRIMARY KEY,
     user_id    INTEGER NOT NULL CONSTRAINT tokens_users_id_fk REFERENCES users,
     token      VARCHAR(6) NOT NULL,
     created_at TIMESTAMP DEFAULT Now() NOT NULL,
     used_at    TIMESTAMP
  );

CREATE INDEX tokens_user_id_token_used_at_index
  ON tokens (user_id, token, used_at);


-- kubectl port-forward --namespace default svc/db-service1-postgresql 5432:5432 & PGPASSWORD="6GYQR0tHJH" ./psql --host 127.0.0.1 -U postgres -d postgres -p 5432
-- \l
-- \c postgres
-- create data