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

-- We now need to migrate the original data to these new tables

