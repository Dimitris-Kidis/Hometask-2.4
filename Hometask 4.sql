-- Hometask 4

-- 1. Write three correlated subqueries: ✅
--     - one in SELECT ✅
--     - one in WHERE ✅
--     - one in HAVING ✅
-- 2. Combine queries using:
--     - IN ✅
--     - EXISTS ✅
--     - ANY ✅
--     - ALL ✅
-- 3. Write one query using CASE in SELECT ✅
-- 4. Write one query using Relational Division ✅
-- 5. .DOCX 1
-- 6. .DOCX 2 ✅
		
USE Employees 
GO 
ALTER DATABASE Employees set TRUSTWORTHY ON; 
GO 
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false 
GO 
sp_configure 'show advanced options', 1; 
GO 
RECONFIGURE; 
GO 
sp_configure 'clr enabled', 1; 
GO 
RECONFIGURE; 
GO


-- 1 --

-- Correlated query in SELECT
USE SCHEDULE
SELECT SpecialistId, Specialists.Domain, Price, Specialists.AvgWorkSessionsPerMonth,
    (SELECT 
            ROUND(Price * AvgWorkSessionsPerMonth * 12, 0)
        FROM
            [Services]
        WHERE
            SpecialistId = e.SpecialistId) AverageSalaryPerYear
FROM [Services] e
INNER JOIN Specialists ON Specialists.Id = e.SpecialistId

-- Correlated query in WHERE
SELECT 
    Id, 
	SpecialistId,
    FirstName, 
    LastName
FROM
    Users e
WHERE
    EXISTS(SELECT Id
        FROM Specialists d
        WHERE d.Id = e.Id)
ORDER BY Id

-- Correlated query in HAVING
SELECT Gender, COUNT(e.Gender) AS AgeCountColumn FROM Users e
INNER JOIN Specialists ON Specialists.Id = e.SpecialistId
INNER JOIN [Services] ON [Services].SpecialistId = Specialists.Id
WHERE EXISTS(SELECT Id
        FROM Specialists d
        WHERE d.Id = e.Id)
GROUP BY Gender, Price
HAVING Price > (SELECT AVG(Price) FROM [Services])


-- 2 --

-- IN
SELECT c.Id, FirstName, LastName, s.MeetingDate FROM Users u
INNER JOIN Clients c ON c.Id = u.ClientId
INNER JOIN Schedules s ON s.ClientId = c.Id
WHERE s.MeetingDate IN(SELECT TOP 2 [Date] FROM Reviews)

-- EXISTS
SELECT e.SpecialistId, FirstName, LastName, Price
FROM Users e
INNER JOIN Specialists s ON s.Id = e.SpecialistId
INNER JOIN [Services] s2 ON s2.SpecialistId = s.Id
WHERE
    EXISTS(SELECT Id
        FROM Specialists d
        WHERE d.Id = e.Id)
ORDER BY Price DESC

-- ANY
SELECT ServiceName 
FROM [Services]
WHERE SpecialistId > ANY (SELECT Id FROM Specialists WHERE WorkExperience = 2);

-- ALL
SELECT ServiceName 
FROM [Services]
WHERE SpecialistId = ALL (SELECT Id FROM Specialists WHERE WorkExperience = 1);


-- 3 --

-- CASE in SELECT
SELECT Id, FirstName, LastName, Age,
CASE
  WHEN Age < 35 THEN 'Young'
  WHEN Age >= 35 AND Age < 65 THEN 'Middle-Aged'
  WHEN Age >= 65 THEN 'Elder person'
END AgeMetrics
FROM Users
ORDER BY Age;


-- 4 --

-- Relational Division
USE Employees
CREATE TABLE Workers (
	Id INT NOT NULL,
	[Name] NVARCHAR(10) NOT NULL,
	PaymentMethod INT NOT NULL
)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (1, 'Nick',  1)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (1, 'Nick',  2)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (1, 'Nick',  3)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (2, 'Michael',  1)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (3, 'Simon',  1)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (4, 'Brad',  2)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (5, 'Joe',  1)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (5, 'Joe',  2)
INSERT INTO Workers (Id, [Name], PaymentMethod) VALUES (5, 'Joe',  3)


CREATE TABLE PaymentMethod (
	Method INT NOT NULL
)
INSERT INTO PaymentMethod (Method) VALUES (1)
INSERT INTO PaymentMethod (Method) VALUES (2)
INSERT INTO PaymentMethod (Method) VALUES (3)

SELECT DISTINCT Workers.Id, Workers.[Name] FROM Workers
WHERE NOT EXISTS (SELECT * FROM PaymentMethod AS Method
				  WHERE NOT EXISTS (SELECT * FROM Workers AS employees
								    WHERE employees.Id = Workers.Id AND employees.PaymentMethod = Method.Method))
ORDER BY Id

DROP TABLE Workers
DROP TABLE PaymentMethod


-- 5 --
USE ACDB

-- 1.	Display the first name, last name, city and state for all customers who live 
--      in the same state as customer number 170 (Customers table).
SELECT First_Name, Last_Name, City, State FROM customers
WHERE State = (SELECT State FROM customers WHERE Customer_Id = 170)

-- 2.	Display the package number, internet speed and sector number for all packages 
--      whose sector number equals to the sector number of package number 10 (Packages table).
SELECT pack_id, speed, sector_id FROM packages
WHERE sector_id = (SELECT sector_id FROM packages WHERE pack_id = 10)

-- 3.	Display the first name, last name and join date for all customers who joined the 
--      company after customer number 540 (Customers table).
SELECT First_Name, Last_Name, Join_Date FROM customers
WHERE Join_Date > ANY(SELECT Join_Date FROM customers WHERE Customer_Id = 540)

-- 4.	Display the first name, last name and join date for all customers who joined 
--      the company on the same month and on the same year as customer number 372 (Customers table).
SELECT First_Name, Last_Name, Join_Date FROM customers
WHERE MONTH(Join_Date) = (SELECT MONTH(Join_Date) FROM customers WHERE Customer_Id = 372)
	  AND
	  YEAR(Join_Date) = (SELECT YEAR(Join_Date) FROM customers WHERE Customer_Id = 372)

-- 5.	Display the first name, last name, city, state and package number for all customers
--      whose internet speed is “5Mbps” (Customers and Packages table).
SELECT First_Name, Last_Name, City, State, c.pack_id FROM customers c
INNER JOIN packages p ON p.pack_id = c.pack_id
WHERE speed = '5Mbps'

-- 6.	Display the package number, internet speed and strt_date (the date it became available)
--      for all packages who became available on the same year as package number 7 (Packages table).
SELECT pack_id, speed, strt_date FROM packages
WHERE YEAR(strt_date) = (SELECT YEAR(strt_date) FROM packages WHERE pack_id = 7)

-- 7.	Display the first name, monthly discount, package number, main phone number and secondary
--      phone number for all customers whose sector name is Business (Customers, Packages and Sectors tables).
SELECT First_Name, monthly_discount, c.pack_id, main_phone_num, secondary_phone_num FROM customers c
INNER JOIN packages p ON p.pack_id = c.pack_id
INNER JOIN sectors s ON s.sector_id = p.sector_id
WHERE s.sector_name = 'Business'

-- 8.	Display the first name, monthly discount and package number for all customers whose monthly payment
--      is greater than the average monthly payment (Customers and Packages table).
SELECT First_Name, monthly_discount, c.pack_id FROM customers c
INNER JOIN packages p ON p.pack_id = c.pack_id
WHERE monthly_payment > (SELECT AVG(monthly_payment) FROM packages)

-- 9.	Display the first name, city, state, birthdate and monthly discount for all customers
--      who was born on the same date as customer number 179, and whose monthly 
--      discount is greater than the monthly discount of customer number 107 (Customers table)
SELECT First_Name, City, State, Birth_Date, monthly_discount FROM customers
WHERE Birth_Date = (SELECT Birth_Date FROM customers WHERE Customer_Id = 179)
	  AND
	  monthly_discount > (SELECT monthly_discount FROM customers WHERE Customer_Id = 107)

-- 10.	Display all the data from Packages table for packages whose internet speed equals
--      to the internet speed of package number 30, and whose monthly payment is greater 
--      than the monthly payment of package number 7 (Packages table).
SELECT * FROM packages 
WHERE speed = (SELECT speed FROM packages WHERE pack_id = 30)
      AND
	  monthly_payment > (SELECT monthly_payment FROM packages WHERE pack_id = 7)

-- 11.	Display the package number, internet speed, and monthly payment for all packages
--      whose monthly payment is greater than the maximum monthly payment of packages with
--      internet speed equals to “5Mbps” (Packages table).
SELECT pack_id, speed, monthly_payment FROM packages
WHERE monthly_payment > (SELECT MAX(monthly_payment) FROM packages WHERE speed = '5Mbps')

-- 12.	Display  the package number, internet speed and monthly payment for all packages 
--      whose monthly payment is greater than the minimum monthly payment of packages with 
--      internet speed equals to “5Mbps” (Packages table).
SELECT pack_id, speed, monthly_payment FROM packages
WHERE monthly_payment > (SELECT MIN(monthly_payment) FROM packages WHERE speed = '5Mbps')

-- 13.	Display the package number, internet speed and monthly payment for all packages whose 
--      monthly payment is lower than the minimum monthly payment of packages with internet
--      speed equals to “5Mbps” (Packages table).
SELECT pack_id, speed, monthly_payment FROM packages
WHERE monthly_payment < (SELECT MIN(monthly_payment) FROM packages WHERE speed = '5Mbps')

-- 14.	Display the first name, monthly discount and package number for all customers whose
--      monthly discount is lower than the average monthly discount, and whose package number
--      is the same as customer named “Kevin”
SELECT First_Name, monthly_discount, pack_id FROM customers
WHERE monthly_discount < (SELECT AVG(monthly_discount) FROM customers WHERE First_Name = 'Kevin')


-- 6 -- 
USE Employees

-- 1.	Display the first name and salary for all employees who earn more than employee number 103 (Employees table).
SELECT first_name, salary FROM employees
WHERE salary > ANY(SELECT salary FROM employees WHERE employee_id = 103) 

-- 2.	Display the department number and department name for all departments whose location number
--      is equal to the location number of department number 11 (Departments table).
USE Employees
SELECT department_id, department_name FROM departments
WHERE location_id = (SELECT location_id FROM departments WHERE department_id = 11)

-- 3.	Display the last name and hire date for all employees who was hired after employee number 101 (Employees table).
SELECT last_name, hire_date FROM Employees
WHERE hire_date > ANY(SELECT hire_date FROM Employees WHERE employee_id = 101)

-- 4.	Display the first name, last name, and department number for all
--      employees who work in Sales department (Employees and Departments table).
SELECT first_name, last_name, d.department_id FROM employees e
INNER JOIN departments d ON d.department_id = e.department_id
WHERE department_name = 'Sales'

-- 5.	Display the department number and department name for all departments located in Toronto (Departments table).
SELECT department_id, department_name FROM departments d
INNER JOIN locations l ON l.location_id = d.location_id
WHERE city = 'Toronto'

-- 6.	Display the first name, salary and department number for all employees 
--      who work in the department as employee number 123 (Employees table). -- 124 не было в базе
SELECT first_name, salary, department_id FROM employees
WHERE department_id IN (SELECT department_id FROM employees WHERE employee_id = 123)

-- 7.	Display the first name, salary, and department number for all employees who earn more 
--      than the average salary (Employees table).
SELECT first_name, salary, department_id FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)

-- 8.	Display the first name, salary, and department number for all employees whose salary
--      equals one of the salaries in department number 1 (Employees table).
SELECT first_name, salary, department_id FROM employees
WHERE salary = (SELECT salary FROM employees WHERE department_id = 1)

-- 9.	Display the first name, salary, and department number for all employees who 
--      earn more than maximum salary in department number 2 (Employees table).
SELECT first_name, salary, department_id FROM employees
WHERE salary > (SELECT MAX(salary) FROM employees WHERE department_id = 2)

-- 10.	Display the first name, salary, and department number for all employees who
--      earn more than the minimum salary in department number 3 (Employees table).
SELECT first_name, salary, department_id FROM employees
WHERE salary > (SELECT MIN(salary) FROM employees WHERE department_id = 3)

-- 11.	Display the first name, salary, and department number for all employees who 
--	    earn less than the minimum salary of department number 4 (Employees table).
SELECT first_name, salary, department_id FROM employees
WHERE salary < (SELECT MIN(salary) FROM employees WHERE department_id = 4)

-- 12.	Display the first name, salary and department number for all employees 
--      whose department is located Seattle (Employees, Departments and Locations table).
SELECT first_name, salary, e.department_id FROM employees e
INNER JOIN departments d ON d.department_id = e.department_id
INNER JOIN locations l ON l.location_id = d.location_id
WHERE city = 'Seattle'

-- 13.	Display the first name, salary, and department number for all employees who earn less than
--      the average salary, and also work at the same department as employee whose first name is Karen
SELECT first_name, salary, department_id FROM employees
WHERE salary < (SELECT AVG(salary) FROM employees ) 
	  AND
	  department_id IN (SELECT department_id FROM employees WHERE first_name = 'Karen')
	  AND
	  first_name <> 'Karen'



