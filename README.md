# IT Helpdesk Database – CSC312 Practical Assignment 2

**Team name:** 6ixdevs
**Student numbers:4369626, 4370898, 4337233, 4323187, 4131396, 4119392
**Course:** CSC312 Databases, University of the Western Cape

## About the project

A mid-sized company uses an internal IT Helpdesk. Employees log tickets for hardware, software, network and account access problems. Each ticket is assigned to a technician, has a priority linked to a Service Level Agreement (SLA), and can be linked to an IT asset. Management wants reports on ticket volume per department, average resolution time per technician, and SLA compliance.

This repository contains the MySQL database and a Python program that connects to it and runs queries.

## Files

| File | What it is |
|------|------------|
| `helpdesk_app.py` | Python program: creates the database and tables, loads sample data, runs the 10 report queries, and adds or updates tickets |
| `helpdesk.sql` | The same schema, sample data and queries as a plain SQL script (for MySQL Workbench) |
| `README.md` | This file |

## Requirements

- Python 3.8 or newer
- MySQL 8.0.16 or newer (older versions ignore CHECK constraints)
- The `mysql-connector-python` package

```
pip install mysql-connector-python
```

## Setup

1. Clone or download this repository.
2. Open `helpdesk_app.py` and edit the connection settings at the top of the file:

```python
DB_HOST = "IP Address given to you"             # address of your MySQL server
DB_PORT = 3306                    # port number (no quotes)
DB_USER = "your_username"
DB_PASSWORD = "your_password"
DB_NAME = "it_helpdesk"           # the database the program will create/use
```

3. Make sure your MySQL server is running (if you use a school server, you may need to be on the campus network or the university VPN).

**Do not commit your real password to GitHub.** Put the placeholders back before you push.

## Running the program

```
python helpdesk_app.py
```

On the first run the program creates the database (if it does not exist), creates the tables, and loads the sample data. Then the menu appears:

```
1. Run all queries
2. Run one query
3. Add a new ticket
4. Update a ticket status
5. Reset database (deletes everything and reloads sample data)
0. Exit
```

- **Options 1 and 2** run the report queries and print the results as tables.
- **Option 3** adds a ticket using a parameterised query. If something goes wrong, the change is rolled back.
- **Option 4** changes a ticket's status from a numbered list and logs the change in `Ticket_Update`. Resolving or closing a ticket sets its resolved time, and reopening it clears that time.
- **Option 5** drops and recreates the 10 project tables and reloads the sample data. Only use this when you want a clean start.

## Using the SQL script in MySQL Workbench

1. Open `helpdesk.sql` with **File → Open SQL Script**.
2. If your server only allows certain database names, change the database name in the `DROP DATABASE`, `CREATE DATABASE` and `USE` lines at the top.
3. Run the whole file with **Ctrl+Shift+Enter**, or run one query at a time by selecting it and pressing **Ctrl+Enter**.

## Database design

There are 10 tables, normalised to 3NF.

| Table | Role |
|-------|------|
| `Department` | Company departments |
| `Employee` | Staff who log tickets; each belongs to one department |
| `Technician` | IT staff who work on tickets |
| `Category` | Hardware, Software, Network, Account Access |
| `SLA` | Priority level with response and resolution times |
| `IT_Asset` | Laptops, monitors and software licences |
| `Ticket` | The central table linking employee, technician, category, SLA and asset |
| `Asset_Assignment` | Bridge table for the many-to-many between employees and assets (keeps assignment history) |
| `Technician_Specialisation` | Bridge table for the many-to-many between technicians and categories |
| `Ticket_Update` | Weak entity: its key is `ticket_id` plus `update_no`, so it cannot exist without a ticket |

## Report queries

| # | Question it answers |
|---|---------------------|
| Q1 | Which departments log the most tickets, and how many are still unresolved? |
| Q2 | What is each technician's average and slowest resolution time? |
| Q3 | What percentage of resolved tickets meet their SLA, by priority? |
| Q4 | Which technicians with 3+ resolved tickets meet the SLA less than 80% of the time? |
| Q5 | Which unresolved tickets are already past their SLA deadline? |
| Q6 | Which employees log more tickets than the average? |
| Q7 | Which assets generate the most tickets, and who holds them now? |
| Q8 | Which tickets went to a technician outside their specialisation? |
| Q9 | Which tickets are about passwords, lockouts or access? |
| Q10 | Which departments are slower than the company-wide average resolution time? |

Q5 uses `NOW()`, so its results depend on the day you run it.

## Troubleshooting

| Error | Likely cause |
|-------|--------------|
| `1045 Access denied for user` | Wrong username or password |
| `1044 Access denied ... to database` | The user cannot use that database name. The program tries to create it; if that also fails, ask whoever runs the server which names you may use |
| `2003 Can't connect to MySQL server` | Wrong host or port, MySQL is not running, or you are not on the campus network or VPN |
| CHECK constraints seem ignored | MySQL is older than 8.0.16 |
