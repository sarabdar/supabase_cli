CREATE TABLE employees (
  id bigint generated always as identity primary key,
  name text,
  email text unique
);