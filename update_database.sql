-- For right now, the only table that exists in our database is the <university_professors> table, which holds more than just this one entity!
-- So we're going to update our database model to more qppropriately suit our data.

-- -- -- -- -- -- -- -- -- --

-- First thing's first: make tables for each of the entities...

-- Create a table for the professors entity type
CREATE TABLE professors (
 firstname text,
 lastname text
);

-- Create a table for the universities entity type
CREATE TABLE universities (
 university_shortname text,
 university text,
 university_city text
);

-- Create table for affiliations

-- Create table for organizations

-- OOPS! Just realized we forgot to include an attribute/column in the <professors> table
-- Let's fix that:
-- Add the university_shortname column
ALTER TABLE professors
ADD COLUMN university_shortname text;

-- -- -- -- -- -- -- -- -- --

-- We now need to migrate the original data to these new tables...

-- Insert unique professors into the new table
INSERT INTO professors 
SELECT DISTINCT firstname, lastname, university_shortname 
FROM university_professors;

-- Insert unique universities into the new table

-- Insert unique affiliations into the new table
INSERT INTO affiliations 
SELECT DISTINCT firstname, lastname, function, organization 
FROM university_professors;

-- Insert unique organizations into the new table

-- -- -- -- -- -- -- -- -- --

-- We must now delete the unnecessary university_professors table (because we no longer need it)...

-- Delete the university_professors table
DROP TABLE university_professors;

-- -- -- -- -- -- -- -- -- --

-- We can set up some constraints...

-- Disallow NULL values in firstname
ALTER TABLE professors 
ALTER COLUMN firstname SET NOT NULL;

-- Disallow NULL values in lastname
ALTER TABLE professors
ALTER COLUMN lastname SET NOT NULL;

-- Make universities.university_shortname unique
ALTER TABLE universities
ADD CONSTRAINT university_shortname_unq UNIQUE(university_shortname);

-- Make organizations.organization unique
ALTER TABLE organizations
ADD CONSTRAINT organization_unq UNIQUE(organization);

-- Add *Key Constraints* to the appropriate tables (organizations, professors, & universities)...

-- For organizations:
-- Rename the organization column to id
ALTER TABLE organizations
RENAME COLUMN organization TO id;
-- Make id a *primary key*
ALTER TABLE organizations
ADD CONSTRAINT organization_pk PRIMARY KEY (id);

-- For universities:
-- Rename the university_shortname column to id
ALTER TABLE universities
RENAME COLUMN university_shortname TO id;
-- Make id a *primary key*
ALTER TABLE universities
ADD CONSTRAINT university_pk PRIMARY KEY (id);

-- For professors:
-- (Since there's no single column candidate key [only a composite key candidate consisting of firstname, lastname],
-- we'll add a new column, "id," to that table.)
-- Add the new column to the table
ALTER TABLE professors
ADD COLUMN id serial;
-- Make id a primary key
ALTER TABLE professors 
ADD CONSTRAINT professors_pkey PRIMARY KEY (id);
-- Have a look at the first 10 rows of professors
SELECT * FROM professors
LIMIT 10;

-- -- -- -- -- -- -- -- -- -- (Modeling 1:N Relationships) (<-- NOTE this is only in the professors-to-universities relationship)

-- We should make sure that our tables are able to reference one another (with Foreign Keys [FKs])...

-- In this database, we want the professors table to reference the universities table.
-- Here's FK from professors to universities:
-- Rename the university_shortname column
ALTER TABLE professors
RENAME COLUMN university_shortname TO university_id;
-- Add a foreign key on professors referencing universities
ALTER TABLE professors 
ADD CONSTRAINT professors_fkey FOREIGN KEY (university_id) REFERENCES universities (id);
-- NOTE that inserting a professor with non-existing university ID would violate the foreign key constraint we just made!

-- -- -- -- -- -- -- -- -- --

-- We could now JOIN two tables that are linked by a foreign key!

-- (consider, specifically, i.e. retain all records where the foreign key of professors is equal to the primary key of universities)
-- Select all professors working for universities in the city of Zurich
SELECT professors.lastname, universities.id, universities.university_city
FROM professors
JOIN universities
ON professors.university_id = universities.id
WHERE universities.university_city = 'Zurich';

-- -- -- -- -- -- -- -- -- -- (Modeling N:M Relationships) (<-- such as with the professors-to-organizations-via-affiliations relationship)

-- Note that we are remodeling our database (see "final database model" ER diagram in your notebook),
-- to include the N:M relationship that affiliations facilitates between professors & organizations.

-- Because we've already created the affiliations table, we need to restructure it; giving it a new form complete with foreign keys that point to and from those other 2 entities!

-- Add a professor_id column
ALTER TABLE affiliations
ADD COLUMN professor_id integer REFERENCES professors (id);

-- Rename the organization column to organization_id
ALTER TABLE affiliations
RENAME organization TO organization_id;

-- Add a foreign key on organization_id
ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id);

-- Populate the "professor_id" column now!
-- Update professor_id to professors.id where firstname, lastname correspond to rows in professors
UPDATE affiliations
SET professor_id = professors.id
FROM professors
WHERE affiliations.firstname = professors.firstname AND affiliations.lastname = professors.lastname;

-- Have a look at the 10 first rows of affiliations again
SELECT * FROM affiliations
LIMIT 10;

-- NOTE that {firstname, lastname} is a candidate key of professors, but NOT in affiliations (because professors can have more than one affiliation).
-- So we can drop those columns in the aff. table (in order to reduce redundancy).
-- Drop the firstname column
ALTER TABLE affiliations
DROP COLUMN firstname;

-- Drop the lastname column
ALTER TABLE affiliations
DROP COLUMN lastname;

-- -- -- -- -- -- -- -- -- -- Changing Referential Integrity behavior of certain key(s)

-- So far, we've implemented 3 foreign key constraints:
-- 1) professors.university_id TO universities.id
-- 2) affiliations.organization_id TO organizations.id
-- 3) affiliations.professor_id to professors.id
-- For now, these keys each have behavior DELETE NO ACTION and throw an error when you try to violate ref. integrity.

-- We're going to play with one of the FKs' behavior...

-- Identify the correct constraint name
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY';

-- For this EX., let's say we want to CASCADE deletion if a referenced record in "organizations" is deleted...
-- Drop the right foreign key constraint
ALTER TABLE affiliations
DROP CONSTRAINT affiliations_organization_id_fkey;

-- Add a new foreign key constraint from affiliations to organizations which cascades deletion
ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id) ON DELETE CASCADE;

-- Let's see if that does the trick...
-- EX. (part 2):
-- Delete an organization 
DELETE FROM organizations 
WHERE id = 'CUREM';

-- Check that no more affiliations with this organization exist
SELECT * FROM affiliations
WHERE organization_id = 'CUREM';

-- -- -- -- -- -- -- -- -- -- USING the database to answer real-world questions!

-- Let's run some example SQL queries on the database.
--
-- EX.1:
-- Find out which university has the most affiliations (through its professors)
-- -- --
-- SOLUTION:
-- Count the total number of affiliations per university
SELECT COUNT(*), professors.university_id 
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
-- Group by the university ids of professors
GROUP BY professors.university_id 
ORDER BY count DESC;
--
--
-- EX. 2:
-- Find the university city of the professor with the most affiliations in the sector "Media & communication."
-- -- --
-- SOLUTION:
-- STEP 1;
--   Join all tables
--      SELECT *
--      FROM affiliations
--      JOIN professors
--      ON affiliations.professor_id = professors.id
--      JOIN organizations
--      ON affiliations.organization_id = organizations.id
--      JOIN universities
--      ON professors.university_id = universities.id;
--
-- STEP 2;
--   Group the table by organization sector, professor ID and university city & COUNT the number of rows
--      SELECT COUNT(*), organizations.organization_sector, professors.id, universities.university_city
--   FROM affiliations
--   JOIN professors
--   ON affiliations.professor_id = professors.id
--   JOIN organizations
--   ON affiliations.organization_id = organizations.id
--   JOIN universities
--   ON professors.university_id = universities.id;
--      GROUP BY organizations.organization_sector, professors.id, universities.university_city;
--
-- STEP 3;
--   Only retain rows with "Media & communication" as organization sector, and sort the table by count, in descending order.
--   SELECT COUNT(*), organizations.organization_sector, professors.id, universities.university_city
--   FROM affiliations
--   JOIN professors
--   ON affiliations.professor_id = professors.id
--   JOIN organizations
--   ON affiliations.organization_id = organizations.id
--   JOIN universities
--   ON professors.university_id = universities.id;
--      WHERE organizations.organization_sector = 'Media & communication'
--   GROUP BY organizations.organization_sector, professors.id, universities.university_city
--      ORDER BY COUNT(*) DESC;
--
-- So(!!!) here's our final query:

-- Filter the table and sort it
SELECT COUNT(*), organizations.organization_sector, professors.id, universities.university_city
FROM affiliations
JOIN professors
ON affiliations.professor_id = professors.id
JOIN organizations
ON affiliations.organization_id = organizations.id
JOIN universities
ON professors.university_id = universities.id
WHERE organizations.organization_sector = 'Media & communication'
GROUP BY organizations.organization_sector, professors.id, universities.university_city
ORDER BY COUNT DESC;

-- -- -- After running the code above, we can see that whoever the professor with id #538 is 
-- -- -- has the most affiliations in the "Media & communications"
-- -- -- and that s/he lives in Lausanne.
