CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(10),
    last_name VARCHAR(10),
    birth_date DATE,
    sex VARCHAR(1),
    salary INT,
    super_id INT,
    branch_id INT
);

CREATE TABLE branch (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(20),
    mgr_id INT,
    mgr_start_date DATE,
    FOREIGN KEY (mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

--ON DELETE SET NULL because if one entry from employee is deleted then it will be replaced by null

ALTER TABLE employee 
ADD FOREIGN KEY (super_id) REFERENCES employee(emp_id) ON DELETE NO ACTION;
ALTER TABLE employee
ADD FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE NO ACTION;


CREATE TABLE client (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(20),
    branch_id INT,
    FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

CREATE TABLE works_with (
    emp_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY (emp_id,client_id),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

-- Here oN DELETE CASCADE because when one entry from employee is delted the whole row from works_with will be delted

CREATE TABLE branch_supplier (
    branch_id INT,
    supplier_name VARCHAR(20),
    supply_type VARCHAR(20),
    PRIMARY KEY(branch_id,supplier_name),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE 
);

-- Inserting Values into the table

INSERT INTO employee VALUES(100,'David','Wallace','1967-11-17','M',250000,NULL,NULL);
INSERT INTO branch VALUES(1,'Corporate',100,'2006-02-09');

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;

INSERT INTO employee VALUES(101,'Jan','Levinson','1961-05-11','F',110000,100,1);

INSERT INTO employee VALUES(102,'Michael','Scott','1964-03-15','M',75000,100,NULL);
INSERT INTO branch VALUES(2,'Scranton',102,'1992-04-06');
UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

INSERT INTO employee VALUES(103,'Angela','Martin','1971-06-25','F',63000,102,2);
INSERT INTO employee VALUES(104,'Kelly','Kapoor','1980-02-05','F',55000,102,2);
INSERT INTO employee VALUES(105,'Stanley','Hudson','1958-02-19','M',69000,102,2);

INSERT INTO employee VALUES(106,'Josh','Porter','1969-09-05','M',78000,100,NULL);
INSERT INTO branch VALUES(3,'Stamford',106,'1998-02-13');

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

INSERT INTO employee VALUES(107,'Andy','Bernard','1973-07-22','M',65000,106,3);
INSERT INTO employee VALUES(108,'Jim','Halpert','1978-10-01','M',71000,106,3);

-- Branch Supplier
INSERT INTO branch_supplier VALUES(2, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Patriot Paper', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'J.T. Forms & Labels', 'Custom Forms');
INSERT INTO branch_supplier VALUES(3, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(3, 'Stamford Lables', 'Custom Forms');

-- CLIENT
INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);
INSERT INTO client VALUES(401, 'Lackawana Country', 2);
INSERT INTO client VALUES(402, 'FedEx', 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);
INSERT INTO client VALUES(405, 'Times Newspaper', 3);
INSERT INTO client VALUES(406, 'FedEx', 2);

-- WORKS_WITH
INSERT INTO works_with VALUES(105, 400, 55000);
INSERT INTO works_with VALUES(102, 401, 267000);
INSERT INTO works_with VALUES(108, 402, 22500);
INSERT INTO works_with VALUES(107, 403, 5000);
INSERT INTO works_with VALUES(108, 403, 12000);
INSERT INTO works_with VALUES(105, 404, 33000);
INSERT INTO works_with VALUES(107, 405, 26000);
INSERT INTO works_with VALUES(102, 406, 15000);
INSERT INTO works_with VALUES(105, 406, 130000);

SELECT * FROM employee;
SELECT * FROM client;

-- Tasks on Select Statements


-- Find all employees by salary 
SELECT * FROM employee ORDER BY salary desc;

-- Find all employees ordered by sex then name
SELECT * FROM employee ORDER BY sex,first_name;

-- Find first 5 employees from the table
SELECT * FROM employee ORDER BY emp_id LIMIT  5;

-- Find forename and Surname of all employees
SELECT first_name AS forename, last_name AS surname FROM employee;

-- Find out all different genders
SELECT DISTINCT sex AS genders from employee;

--Find number of employees
SELECT COUNT(emp_id) AS 'number of employees' FROM employee;

--Find number of female employees born after 1970
SELECT COUNT(emp_id) FROM employee WHERE sex='F' AND birth_date > '1970-01-01';

--Find average of all employees
SELECT SUM(salary)/COUNT(salary) FROM employee;
SELECT AVG(salary) FROM employee WHERE sex = 'M';

--Find out how many males and females
SELECT COUNT(sex), sex FROM employee GROUP BY sex ;

--Find total sales by each salesman
SELECT DISTINCT emp_id,SUM(total_sales) FROM works_with GROUP BY emp_id;

--Find how much did each client spent
SELECT client_id,SUM(total_sales) FROM works_with GROUP BY client_id;

#--Find any client who are an LLC
SELECT Client_id,client_name FROM client WHERE client_name = 'John Daly Law, LLC';
SELECT * FROM client WHERE client_name LIKE '%LLC';

--Find any Branch suppliers who are in label business
SELECT * FROM branch_supplier WHERE supplier_name LIKE '%Label%';

--Find any employee born in october
SELECT * FROM employee WHERE birth_date Like '%10%';

--Find list of employees and branch names
SELECT first_name FROM employee UNION SELECT branch_name FROM branch;

--Find branches and name of their managers
SELECT emp_id,first_name,branch_name FROM employee JOIN branch ON emp_id=mgr_id;

--Find names of all employees who have sold over 30000 to a client
SELECT employee.first_name,employee.last_name
FROM employee
WHERE employee.emp_id IN (
    SELECT works_with.emp_id
    FROM works_with
    WHERE total_sales>30000
);

--Find all employees who are handled by the branch that Michael Scott manages
SELECT first_name FROM employee WHERE super_id = 102;

--Find all clients who are handled by the branch that Michael Scott manages
SELECT client.client_name
FROM client
WHERE client.branch_id IN (
    SELECT branch.branch_id
    FROM branch
    WHERE branch.mgr_id = 102
);