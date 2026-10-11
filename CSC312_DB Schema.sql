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

    # priority is stored here (not in Ticket) so we dont repeat the
    # response/resolution times for every ticket (3NF)
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

    # many-to-many: employee <-> asset (an asset can be passed on to
    # another employee later, so we keep the dates)
CREATE TABLE Asset_Assignment (
        assignment_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_id INT NOT NULL,
        employee_id INT NOT NULL,
        assigned_date DATE NOT NULL,
        returned_date DATE NULL,
        FOREIGN KEY (asset_id) REFERENCES IT_Asset(asset_id),
        FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
    );

    # many-to-many: technician <-> category (composite primary key)
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

    # weak entity - primary key is ticket_id + update_no
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
DESCRIBE TABLE Ticket_Update