-- For right now, the only table that exists in our database is the <university_professors> table, which holds more than just this one entity!
-- So we're going to update our database model to more qppropriately suit our data.

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

-- We now need to migrate the original data to these new tables
-- -- -- -- --
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

-- We must now delete the unnecessary university_professors table (because we no longer need it)
-- -- -- -- --
-- Delete the university_professors table
DROP TABLE university_professors;

-- -- -- -- -- -- -- -- -- --

-- We can set up some constraints
-- -- -- -- --
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
