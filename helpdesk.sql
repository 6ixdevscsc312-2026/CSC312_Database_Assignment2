-- Team Name:       6ixdevs
-- Student Numbers: 4369626, 4370898, 4337233, 4323187, 4131396, 4119392
-- File Name:       helpdesk.sql
-- Course:          CSC312 - Database Project (Practical 2)
-- Scenario:        IT Helpdesk

-- PART 1: CREATE THE DATABASE AND TABLES (normalised, 3NF)

DROP DATABASE IF EXISTS it_helpdesk;
CREATE DATABASE it_helpdesk;
USE it_helpdesk;

CREATE TABLE Department (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50) NOT NULL
);

CREATE TABLE Employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Technician (
    technician_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    hire_date DATE NOT NULL
);

CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(40) NOT NULL UNIQUE
);

-- priority is stored here (not in Ticket) so we don't repeat the
-- response/resolution times for every ticket (3NF)
CREATE TABLE SLA (
    sla_id INT AUTO_INCREMENT PRIMARY KEY,
    priority_level ENUM('Low','Medium','High','Critical') NOT NULL UNIQUE,
    response_hours INT NOT NULL,
    resolution_hours INT NOT NULL,
    CHECK (response_hours > 0 AND resolution_hours >= response_hours)
);

CREATE TABLE IT_Asset (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_tag VARCHAR(20) NOT NULL UNIQUE,
    asset_type ENUM('Laptop','Monitor','Software Licence') NOT NULL,
    make_model VARCHAR(80) NOT NULL,
    purchase_date DATE NOT NULL
);

-- many-to-many: employee <-> asset (an asset can be passed on to
-- another employee later, so we keep the dates)
CREATE TABLE Asset_Assignment (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    returned_date DATE NULL,
    FOREIGN KEY (asset_id) REFERENCES IT_Asset(asset_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- many-to-many: technician <-> category (composite primary key)
CREATE TABLE Technician_Specialisation (
    technician_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (technician_id, category_id),
    FOREIGN KEY (technician_id) REFERENCES Technician(technician_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    technician_id INT NULL,
    category_id INT NOT NULL,
    sla_id INT NOT NULL,
    asset_id INT NULL,
    title VARCHAR(100) NOT NULL,
    status ENUM('Open','In Progress','On Hold','Resolved','Closed') NOT NULL DEFAULT 'Open',
    created_at DATETIME NOT NULL,
    first_response_at DATETIME NULL,
    resolved_at DATETIME NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (technician_id) REFERENCES Technician(technician_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (sla_id) REFERENCES SLA(sla_id),
    FOREIGN KEY (asset_id) REFERENCES IT_Asset(asset_id),
    CHECK (resolved_at IS NULL OR resolved_at >= created_at)
);

-- weak entity - primary key is ticket_id + update_no
CREATE TABLE Ticket_Update (
    ticket_id INT NOT NULL,
    update_no INT NOT NULL,
    technician_id INT NULL,
    update_time DATETIME NOT NULL,
    old_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    note VARCHAR(255),
    PRIMARY KEY (ticket_id, update_no),
    FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES Technician(technician_id)
);


-- PART 2: SAMPLE DATA

INSERT INTO Department (dept_name, location) VALUES
('IT', 'Bellville HQ'),
('HR', 'Bellville HQ'),
('Finance', 'Cape Town'),
('Sales', 'Cape Town'),
('Operations', 'Stellenbosch');

INSERT INTO Employee (first_name, last_name, email, dept_id) VALUES
('Thandi', 'Mokoena', 'thandi@acme.co.za', 3),
('Sipho', 'Dlamini', 'sipho@acme.co.za', 4),
('Aisha', 'Patel', 'aisha@acme.co.za', 2),
('Liam', 'Jacobs', 'liam@acme.co.za', 5),
('Naledi', 'Khumalo', 'naledi@acme.co.za', 3),
('Pieter', 'van Wyk', 'pieter@acme.co.za', 4),
('Zanele', 'Nkosi', 'zanele@acme.co.za', 1),
('Ruan', 'Botha', 'ruan@acme.co.za', 5);

INSERT INTO Technician (first_name, last_name, email, hire_date) VALUES
('Kabelo', 'Mahlangu', 'kabelo@acme.co.za', '2021-03-01'),
('Jenna', 'Pillay', 'jenna@acme.co.za', '2022-07-15'),
('Declan', 'Smith', 'declan@acme.co.za', '2023-01-09');

INSERT INTO Category (category_name) VALUES
('Hardware'), ('Software'), ('Network'), ('Account Access');

INSERT INTO SLA (priority_level, response_hours, resolution_hours) VALUES
('Low', 24, 72),
('Medium', 8, 24),
('High', 4, 8),
('Critical', 1, 4);

INSERT INTO IT_Asset (asset_tag, asset_type, make_model, purchase_date) VALUES
('LT-0001', 'Laptop', 'Dell Latitude 5440', '2024-01-05'),
('LT-0002', 'Laptop', 'Lenovo ThinkPad T14', '2024-03-12'),
('LT-0003', 'Laptop', 'HP EliteBook 840', '2024-06-20'),
('MN-0001', 'Monitor', 'Dell U2422H', '2024-01-05'),
('SW-0001', 'Software Licence', 'Microsoft 365', '2025-01-01'),
('SW-0002', 'Software Licence', 'Adobe Acrobat Pro', '2025-02-01');

-- LT-0001 belonged to Zanele first and then got given to Thandi
INSERT INTO Asset_Assignment (asset_id, employee_id, assigned_date, returned_date) VALUES
(1, 7, '2024-01-10', '2025-02-01'),
(1, 1, '2025-02-05', NULL),
(2, 2, '2024-03-15', NULL),
(3, 3, '2024-06-25', NULL),
(4, 1, '2024-01-10', NULL),
(5, 1, '2025-01-02', NULL),
(5, 2, '2025-01-02', NULL),
(6, 5, '2025-02-03', NULL);

INSERT INTO Technician_Specialisation (technician_id, category_id) VALUES
(1, 1), (1, 3), (2, 2), (2, 4), (3, 1), (3, 2);

-- employee, technician, category, sla, asset, title, status, created, first response, resolved
INSERT INTO Ticket (employee_id, technician_id, category_id, sla_id, asset_id, title, status, created_at, first_response_at, resolved_at) VALUES
(1, 1, 1, 2, 1,    'Laptop screen flickering',        'Closed',      '2026-09-01 08:30', '2026-09-01 09:10', '2026-09-01 15:00'),
(2, 2, 2, 3, 5,    'Outlook crashes on startup',      'Closed',      '2026-09-01 09:00', '2026-09-01 10:30', '2026-09-01 16:00'),
(3, 1, 3, 2, NULL, 'WiFi drops in HR office',         'Closed',      '2026-09-02 10:00', '2026-09-02 11:00', '2026-09-03 12:00'),
(4, 3, 2, 1, NULL, 'Request Adobe install',           'Closed',      '2026-09-02 13:00', '2026-09-03 09:00', '2026-09-04 10:00'),
(5, 2, 4, 4, NULL, 'Locked out of finance system',    'Closed',      '2026-09-03 07:45', '2026-09-03 07:55', '2026-09-03 10:30'),
(6, 1, 3, 3, NULL, 'VPN fails for sales team',        'Closed',      '2026-09-04 08:00', '2026-09-04 13:00', '2026-09-05 09:00'),
(1, 3, 1, 2, 4,    'Monitor has no signal',           'Closed',      '2026-09-07 09:00', '2026-09-07 09:30', '2026-09-07 11:00'),
(7, 3, 2, 2, NULL, 'Need Visio licence',              'Closed',      '2026-09-07 10:00', '2026-09-07 15:00', '2026-09-08 09:00'),
(8, 2, 4, 3, NULL, 'Password reset needed',           'Closed',      '2026-09-08 08:15', '2026-09-08 08:45', '2026-09-08 09:30'),
(3, 2, 4, 4, NULL, 'Compromised account suspected',   'Closed',      '2026-09-17 07:30', '2026-09-17 07:40', '2026-09-17 13:00'),
(4, 1, 1, 3, NULL, 'Laptop battery swollen',          'Closed',      '2026-09-10 09:00', '2026-09-10 09:20', '2026-09-10 18:30'),
(2, 2, 2, 3, 5,    'Excel macro security error',      'Closed',      '2026-09-15 10:00', '2026-09-15 11:00', '2026-09-15 20:00'),
(5, 1, 1, 2, NULL, 'Laptop will not boot',            'Resolved',    '2026-09-16 08:00', '2026-09-16 08:40', '2026-09-16 14:00'),
(8, 3, 3, 3, NULL, 'No internet at Operations dock',  'In Progress', '2026-10-08 08:00', '2026-10-08 08:30', NULL),
(6, NULL, 2, 2, NULL, 'Request Power BI licence',     'Open',        '2026-10-09 14:00', NULL, NULL),
(3, NULL, 4, 4, NULL, 'Cannot access payroll system', 'Open',        '2026-10-10 07:00', NULL, NULL);

INSERT INTO Ticket_Update (ticket_id, update_no, technician_id, update_time, old_status, new_status, note) VALUES
(1, 1, 1, '2026-09-01 09:10', 'Open', 'In Progress', 'Display cable suspected'),
(1, 2, 1, '2026-09-01 15:00', 'In Progress', 'Resolved', 'Replaced display cable'),
(5, 1, 2, '2026-09-03 07:55', 'Open', 'In Progress', 'Unlocking account'),
(5, 2, 2, '2026-09-03 10:30', 'In Progress', 'Resolved', 'Access restored'),
(14, 1, 3, '2026-10-08 08:30', 'Open', 'In Progress', 'Checking the switch at the dock');



-- PART 3: QUERIES
-- resolution time in hours = TIMESTAMPDIFF(MINUTE, created_at, resolved_at) / 60

-- Q1: Ticket volume per department
-- Purpose: which departments log the most tickets and how many are still unresolved. Useful for planning support.
SELECT d.dept_name, COUNT(t.ticket_id) AS total_tickets,
       SUM(t.status IN ('Open','In Progress','On Hold')) AS still_open
FROM Department d
LEFT JOIN Employee e ON e.dept_id = d.dept_id
LEFT JOIN Ticket t ON t.employee_id = e.employee_id
GROUP BY d.dept_id, d.dept_name
ORDER BY total_tickets DESC;

-- Q2: Average resolution time per technician
-- Purpose: how fast each technician resolves tickets, so management can balance the workload.
SELECT CONCAT(te.first_name, ' ', te.last_name) AS technician,
       COUNT(*) AS resolved_tickets,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)) / 60, 1) AS avg_hours,
       ROUND(MAX(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)) / 60, 1) AS slowest_hours
FROM Technician te
INNER JOIN Ticket t ON t.technician_id = te.technician_id
WHERE t.resolved_at IS NOT NULL
GROUP BY te.technician_id, te.first_name, te.last_name
ORDER BY avg_hours;

-- Q3: SLA compliance rate per priority
-- Purpose: are we meeting the resolution times promised in the SLA for each priority level?
SELECT s.priority_level, COUNT(*) AS resolved_tickets,
       SUM(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_hours * 60) AS met_sla,
       ROUND(100 * SUM(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_hours * 60)
             / COUNT(*), 1) AS compliance_percent
FROM Ticket t
INNER JOIN SLA s ON s.sla_id = t.sla_id
WHERE t.resolved_at IS NOT NULL
GROUP BY s.sla_id, s.priority_level
ORDER BY s.sla_id DESC;

-- Q4: Technicians with SLA compliance below 80% (HAVING)
-- Purpose: finds technicians with 3 or more resolved tickets who met the SLA less than 80% of the time.
SELECT CONCAT(te.first_name, ' ', te.last_name) AS technician,
       COUNT(*) AS resolved_tickets,
       ROUND(100 * SUM(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_hours * 60)
             / COUNT(*), 1) AS compliance_percent
FROM Technician te
INNER JOIN Ticket t ON t.technician_id = te.technician_id
INNER JOIN SLA s ON s.sla_id = t.sla_id
WHERE t.resolved_at IS NOT NULL
GROUP BY te.technician_id, te.first_name, te.last_name
HAVING COUNT(*) >= 3
   AND SUM(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_hours * 60) / COUNT(*) < 0.8;

-- Q5: Unresolved tickets that are past their SLA deadline
-- Purpose: a watch-list of tickets still not resolved after the time the SLA allows. These need escalation.
SELECT t.ticket_id, t.title, s.priority_level, t.status,
       DATE_ADD(t.created_at, INTERVAL s.resolution_hours HOUR) AS sla_deadline
FROM Ticket t
INNER JOIN SLA s ON s.sla_id = t.sla_id
WHERE t.resolved_at IS NULL
  AND DATE_ADD(t.created_at, INTERVAL s.resolution_hours HOUR) < NOW()
ORDER BY sla_deadline;

-- Q6: Employees with more tickets than the average (subquery)
-- Purpose: shows employees who log more tickets than average. Could mean faulty equipment or a training gap.
SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee, d.dept_name,
       COUNT(t.ticket_id) AS tickets_logged
FROM Employee e
INNER JOIN Department d ON d.dept_id = e.dept_id
INNER JOIN Ticket t ON t.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, d.dept_name
HAVING COUNT(t.ticket_id) > (SELECT COUNT(*) / COUNT(DISTINCT employee_id) FROM Ticket);

-- Q7: Assets with the most tickets and who holds them now
-- Purpose: helps decide which assets to replace. The current holder is the assignment with no returned date.
SELECT a.asset_tag, a.make_model, COUNT(t.ticket_id) AS tickets,
       CONCAT(e.first_name, ' ', e.last_name) AS current_holder
FROM IT_Asset a
INNER JOIN Ticket t ON t.asset_id = a.asset_id
LEFT JOIN Asset_Assignment aa ON aa.asset_id = a.asset_id AND aa.returned_date IS NULL
LEFT JOIN Employee e ON e.employee_id = aa.employee_id
GROUP BY a.asset_id, a.asset_tag, a.make_model, e.employee_id, e.first_name, e.last_name
ORDER BY tickets DESC;

-- Q8: Tickets given to a technician outside their specialisation (NOT EXISTS)
-- Purpose: checks if tickets are being sent to technicians that actually specialise in that category.
SELECT t.ticket_id, t.title, c.category_name,
       CONCAT(te.first_name, ' ', te.last_name) AS technician
FROM Ticket t
INNER JOIN Category c ON c.category_id = t.category_id
INNER JOIN Technician te ON te.technician_id = t.technician_id
WHERE NOT EXISTS (SELECT 1 FROM Technician_Specialisation ts
                  WHERE ts.technician_id = t.technician_id
                    AND ts.category_id = t.category_id);

-- Q9: Account access tickets found with LIKE
-- Purpose: finds password / lockout / access tickets to see if a self-service password reset would help.
SELECT t.ticket_id, CONCAT(e.first_name, ' ', e.last_name) AS raised_by,
       d.dept_name, t.title, t.status
FROM Ticket t
INNER JOIN Employee e ON e.employee_id = t.employee_id
INNER JOIN Department d ON d.dept_id = e.dept_id
WHERE t.title LIKE '%password%' OR t.title LIKE '%locked%' OR t.title LIKE '%access%'
ORDER BY t.created_at;

-- Q10: Departments slower than the company average (nested subquery + HAVING)
-- Purpose: departments with 3 or more resolved tickets whose average resolution time is above the company average.
SELECT d.dept_name, COUNT(t.ticket_id) AS resolved_tickets,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)) / 60, 1) AS avg_hours,
       SUM(s.priority_level IN ('High','Critical')) AS high_priority_tickets
FROM Department d
INNER JOIN Employee e ON e.dept_id = d.dept_id
INNER JOIN Ticket t ON t.employee_id = e.employee_id
INNER JOIN SLA s ON s.sla_id = t.sla_id
WHERE t.resolved_at IS NOT NULL
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(t.ticket_id) >= 3
   AND AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)) >
       (SELECT AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at))
        FROM Ticket WHERE resolved_at IS NOT NULL)
ORDER BY avg_hours DESC;
