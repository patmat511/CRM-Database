# 📊 CRM Database Project

A comprehensive SQL-based Customer Relationship Management (CRM) database for **Microsoft SQL Server**, designed to manage clients, employees, services, interactions, and system integrations.

---

## 📋 Project Overview

This CRM solution includes:

- **Tables** – Klient, Pracownicy, Biezace_interakcje, Historia_interakcji, Uslugi, Uzytkownicy, Uprawnienia, Integracja.
- **Triggers** – Enforce data integrity (e.g., email format, phone number validation).
- **Views** – Predefined reports like `vw_ClientServices`, `vw_UserPermissions`, `vw_ClientInteractionHistory`.
- **Stored Procedures** – CRUD operations: `sp_AddClient`, `sp_UpdateClient`, etc.
- **Sample Data** – 5 records per table for testing purposes.

The main SQL script: `CRM_Matusiak_Patryk.sql`.

---


## 🛠️ Prerequisites

- Microsoft SQL Server 2016 or later
- SQL Server Management Studio (SSMS) or any T-SQL compatible client
- Administrative privileges to create databases
- Minimum disk space: 10MB (data), 5MB (log)

---

## ⚙️ Setup Instructions

### 1. Clone or Download

```bash
git clone https://github.com/patmat511/CRM-Database.git
cd CRM-Matusiak-Patryk
```

### 2. Update File Paths
Open CRM_Matusiak_Patryk.sql in SSMS and update the database file paths:
```sql
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CRM_Matusiak_Patryk.mdf',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CRM_Matusiak_Patryk_log.ldf'
```
Adjust these paths to match your SQL Server data directory.

### 3. Execute the Script
In SSMS:

- Connect to your SQL Server instance

- Run the entire CRM_Matusiak_Patryk.sql script

The script will:

- Drop the database if it exists

- Create CRM_Matusiak_Patryk with appropriate data/log files

- Generate all tables, triggers, views, and stored procedures

- Insert test data (clients, employees, etc.)

---

### ✅ Verification Checklist
Database appears under Databases in SSMS

Sample query:

```sql
SELECT * FROM Klient;
SELECT * FROM vw_ClientServices;
EXEC sp_AddClient ...;
```
---
### 📎 Notes
All constraints and validation rules are handled via triggers.

The script is destructive – existing database with same name will be dropped.

Ensure all active connections to the DB are closed before running the script.
---
👨‍💻 Author
Patryk Matusiak – CRM SQL Project for college labs
