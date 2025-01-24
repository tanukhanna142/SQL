-- Task 1 - Analyze an existing student database table for normalization and atomic fields
-- Step 1. Connect to the database using MYSQL
-- Step 2. Observe the school database and relevant tables
-- Step 3. Evaluate the database structure for normalization
-- Normalization ensures efficiency, reduces redundancy, and maintains data integrity by organizing data into atomic fields—where each field holds only a single, indivisible value.

SELECT *
FROM student;

-- Columns name are student_id, first_name, middle_name, last_name, grade, curriculum, email_id, address.
-- Observed non-atomic fields in the column 'address'.


-- Task 2 - Use SQL REGEX to check and clean the address in the MySQL table
-- Step 1. Review the data in the address field 
-- Step 2. Develop a regular expression to identify valid address formats
-- Regular expressions (REGEX) are effective tools for cleaning and validating addresses as they allow precise pattern matching and identification of inconsistencies
-- Step 3. Use the NOT regular expression to detect and correct invalid entries

SELECT address
FROM student
WHERE address REGEXP '^[0-9a-zA-Z\. ]+;[a-zA-Z ]+[A-Z ]+;[0-9 ]+$';

SELECT COUNT(address)
FROM student; and 

SELECT COUNT(address)
FROM student
WHERE address REGEXP '^[0-9a-zA-Z\. ]+;[a-zA-Z ]+[A-Z ]+;[0-9 ]+$';

-- If the two counts differ, identify and fix the mismatched entries

SELECT address
FROM student
WHERE address NOT REGEXP '^[0-9a-zA-Z\. ]+;[a-zA-Z ]+[A-Z ]+;[0-9 ]+$';

-- Correct the entries as necessary to ensure consistent formatting


-- TASK 3 - Create a query to display atomic values within the address field 
-- Step 1. Start with the SELECT statement 
-- Step 2. Use the SUBSTRING_INDEX function to extract individual components separated by a delimiter.
-- Step 3. Apply the outer SUBSTRING_INDEX to return specific parts of the address
-- Step 4. Label each component meaningfully

SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 1), ';', -1) AS street,
    SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 2), ';', -1) AS city,
    SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 3), ';', -1) AS 'state', --define it as an identifier and not as a reserve keyword or function in SQL
    SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 4), ';', -1) AS zip
FROM student;


-- TASK 4 - Use the existing address field to create an address table 
-- Step 1. Utilize the CREATE TABLE command
-- Step 2. Define fields based on the components identified in the address query
-- Step 3. Specify appropriate VARCHAR lengths for each field
-- Step 4. Add a column to associate the address with a specific student
-- Separating address data into its own table enhances database normalization, improves efficiency, and simplifies future updates to the address information.

CREATE TABLE address (
    id INT NOT NULL AUTO_INCREMENT,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    'state' VARCHAR(2) NOT NULL,
    zip VARCHAR(10) NOT NULL,
    student_id INT,
    PRIMARY KEY (id)
);


-- TASK 5 - Use SQL to insert the data into the address table using existing data 
-- Step 1. Write an INSERT statement to populate the address table
-- Step 2. Map the fields in the INSERT statement to the corresponding address table columns
-- Step 3. Extract atomic values from the student table’s address data using the SUBSTRING_INDEX query
-- Step 4. Include the student_id to establish a relationship between the student and their address
-- Maintaining data integrity is crucial during this transfer to ensure the relationships and data accuracy are preserved

INSERT INTO address (street, city, 'state', zip, student_id)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 1), ';', -1)) AS street,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 2), ';', -1)) AS city,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 3), ';', -1)) AS 'state',
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ';', 4), ';', -1)) AS zip,
    student_id
FROM student;


-- TASK 6 - Verify the results
SELECT * 
FROM student
JOIN address 
ON student.student_id = address.student_id;
