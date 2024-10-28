-- Here is a quick review exercise from DataCamp on attributes & key constraints.

-- Pretend there is some entity type, "student."
-- A student has:
--    - a last name consisting of up to 128 characters (required),
--    - a unique social security number, consisting only of integers, that should serve as a key,
--    - a phone number of fixed length 12, consisting of numbers and characters (but some students don't have one).
-- Given the above description of a student entity, create a table students with the correct column types.

-- -- -- SOLUTION: -- -- --

-- Create the table
CREATE TABLE students (
  last_name varchar(128) NOT NULL,
  ssn int PRIMARY KEY,
  phone_no char(12)
);
-- NOTE that we added a PRIMARY KEY for the ssn;
-- and that there is no formal length requirement for the integer column. The application would have to make sure it's a correct SSN!

-- -- -- -- -- -- -- -- -- --

-- A note about FOREIGN KEYS:

-- Specifying FKs to existing tables
ALTER TABLE a
ADD CONSTRAINT a_fkey FOREIGN KEY (b_id) REFERENCES b (id);
