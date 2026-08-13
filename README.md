# Relational Database Design for Nour Medical Centre

![Data Analysis](https://img.shields.io/badge/Data%20Analysis-blue)
![Healthcare Analysis](https://img.shields.io/badge/Healthcare%20Analysis-brightgreen)
![Database Design](https://img.shields.io/badge/Database%20Design-blue)
![Medical Centre](https://img.shields.io/badge/Medical%20Centre-brightgreen)
![SQL](https://img.shields.io/badge/SQL-blue)
![MIT](https://img.shields.io/badge/MIT%20License-brightgreen)

## 📌 Project Overview

Nour Medical Centre is a small medical facility that requires a structured database to manage its day-to-day clinical operations.

This project involves the **design and implementation of a relational database schema using MySQL** to manage patients, doctors, appointments, diagnoses, and prescribed medications.

The database was developed using a **requirements-driven approach**, applying core relational database principles including entity-relationship modeling, normalization, primary and foreign keys, referential integrity, data consistency, and transaction reliability.

The project follows a complete database design process:

> **Business Requirements → Entity Identification → Relational Schema → Normalization → Implementation → Evaluation → Refinement**

---

## 🎯 Project Objectives

The objectives of this project are to:

* Translate business requirements into a structured relational database model.
* Identify the entities, attributes, and relationships required by the medical centre.
* Design a normalized schema that minimizes unnecessary data redundancy.
* Establish appropriate primary and foreign key relationships.
* Implement the database using MySQL.
* Apply constraints to maintain data integrity and consistency.
* Evaluate the schema against core relational database principles.
* Identify potential limitations and propose future refinements.
* Demonstrate practical application of SQL and relational database design.

---

## 🏥 Business Requirements

The database is based on the following requirements:

### Patients

Each patient has:

* A unique patient ID
* Full name
* Date of birth
* Contact number

### Doctors

Each doctor has:

* A unique doctor ID
* Name
* Specialisation

### Appointments

Patients can book appointments with specific doctors.

Each appointment records:

* Patient
* Doctor
* Date and time
* Reason for visit

### Medical Records

After an appointment, the doctor records:

* Diagnosis
* Prescribed medication

### Relationships

* A patient can have many appointments.
* A doctor can see many patients.
* Each appointment belongs to one patient and one doctor.
* Each appointment can have one corresponding medical record.

---

## 🧩 Database Entities

The requirements were translated into four core entities:

| Entity              | Purpose                                                                  |
| ------------------- | ------------------------------------------------------------------------ |
| **Patients**        | Stores patient demographic and contact information.                      |
| **Doctors**         | Stores information about doctors and their specialisations.              |
| **Appointments**    | Records appointments between patients and doctors.                       |
| **Medical Records** | Stores diagnoses and prescribed medication associated with appointments. |

---

## 🔗 Entity Relationships

The database uses the following relationships:

```text
Patients 1 ───────────< Appointments >─────────── 1 Doctors
                              │
                              │ 1
                              │
                              │ 1
                              ▼
                       Medical Records
```

### Cardinality

* **Patients → Appointments:** One-to-Many (1:M)
* **Doctors → Appointments:** One-to-Many (1:M)
* **Appointments → Medical Records:** One-to-One (1:1)

The `Appointments` table resolves the many-to-many relationship between patients and doctors.

---

## 🗃️ Relational Schema

### Patients

| Field            | Data Type    | Key / Constraint   |
| ---------------- | ------------ | ------------------ |
| `patient_id`     | INT          | PK, AUTO_INCREMENT |
| `full_name`      | VARCHAR(100) | NOT NULL           |
| `date_of_birth`  | DATE         | NOT NULL           |
| `contact_number` | VARCHAR(20)  | NOT NULL           |

### Doctors

| Field            | Data Type    | Key / Constraint   |
| ---------------- | ------------ | ------------------ |
| `doctor_id`      | INT          | PK, AUTO_INCREMENT |
| `doctor_name`    | VARCHAR(100) | NOT NULL           |
| `specialisation` | VARCHAR(100) | NOT NULL           |

### Appointments

| Field                  | Data Type    | Key / Constraint   |
| ---------------------- | ------------ | ------------------ |
| `appointment_id`       | INT          | PK, AUTO_INCREMENT |
| `patient_id`           | INT          | FK, NOT NULL       |
| `doctor_id`            | INT          | FK, NOT NULL       |
| `appointment_datetime` | DATETIME     | NOT NULL           |
| `reason`               | VARCHAR(255) | NOT NULL           |

### Medical Records

| Field                   | Data Type | Key / Constraint     |
| ----------------------- | --------- | -------------------- |
| `medical_record_id`     | INT       | PK, AUTO_INCREMENT   |
| `appointment_id`        | INT       | FK, UNIQUE, NOT NULL |
| `diagnosis`             | TEXT      | NOT NULL             |
| `prescribed_medication` | TEXT      | NOT NULL             |

---

## 🔑 Keys and Relationships

The database uses primary and foreign keys to establish entity relationships and maintain referential integrity.

### Primary Keys

* `patients.patient_id`
* `doctors.doctor_id`
* `appointments.appointment_id`
* `medical_records.medical_record_id`

### Foreign Keys

```text
appointments.patient_id
        ↓
patients.patient_id

appointments.doctor_id
        ↓
doctors.doctor_id

medical_records.appointment_id
        ↓
appointments.appointment_id
```

---

## 🧱 Normalization

The schema was evaluated against the first three normal forms.

### First Normal Form (1NF)

The design uses atomic attributes and avoids repeating groups.

### Second Normal Form (2NF)

Non-key attributes are dependent on the primary key of their respective entities.

### Third Normal Form (3NF)

Non-key attributes depend on the primary key and not on other non-key attributes.

For example:

* Patient contact information belongs to `Patients`.
* Doctor specialisation belongs to `Doctors`.
* Appointment details belong to `Appointments`.
* Diagnosis and prescribed medication belong to `Medical Records`.

This separation reduces unnecessary duplication and improves data consistency.

---

## 🛡️ Data Integrity

The schema uses:

* Primary keys for row-level uniqueness.
* Foreign keys for referential integrity.
* `NOT NULL` constraints for required attributes.
* `UNIQUE` constraint on `medical_records.appointment_id` to maintain the one-to-one appointment-to-medical-record relationship.

The MySQL **InnoDB** storage engine is used to support transactional integrity and ACID properties.

---

## 💾 Persistence and ACID

The database stores data persistently in MySQL rather than in temporary or in-memory structures.

Using InnoDB allows database transactions to support the **ACID principles**:

* **Atomicity** — transactions are completed fully or rolled back.
* **Consistency** — constraints help prevent invalid data states.
* **Isolation** — concurrent transactions are managed according to the database isolation level.
* **Durability** — committed transactions are persisted by the database engine.

This ensures that operations such as creating an appointment and recording its clinical outcome can be handled reliably within a transaction.

---

## 🔄 CRUD Operations

All four core tables support standard CRUD operations:

| Table           | Create | Read | Update | Delete |
| --------------- | :----: | :--: | :----: | :----: |
| Patients        |    ✓   |   ✓  |    ✓   |    ✓   |
| Doctors         |    ✓   |   ✓  |    ✓   |    ✓   |
| Appointments    |    ✓   |   ✓  |    ✓   |    ✓   |
| Medical Records |    ✓   |   ✓  |    ✓   |    ✓   |

---

## 📊 Business Queries

The database can support operational questions such as:

* Which patients are scheduled to see each doctor?
* What is a patient's appointment history?
* Which appointments have recorded diagnoses?
* Which medications have been prescribed?
* How many appointments has each doctor handled?
* What are the most common reasons for patient visits?

SQL queries demonstrating these use cases are included in the `database/04_business_queries.sql` file.

---

## 🔍 Design Evaluation & Refinement

After the initial schema was developed, it was evaluated against:

* Relational database principles
* Normalization
* Primary and foreign key integrity
* Data redundancy
* Referential integrity
* CRUD requirements
* Persistence
* ACID transaction principles
* Scalability
* Future operational requirements

The evaluation identified several opportunities for future refinement, particularly around **prescription management, appointment status tracking, and auditability**.

These refinements are documented separately to distinguish between requirements necessary for the current solution and enhancements appropriate for a more mature production environment.

📄 **[View the Database Design & Refinement Documentation](documentation/database-design-and-refinement.md)**

---

## 🚀 Future Enhancements

Potential future improvements include:

* Separating medications and prescriptions into dedicated entities.
* Adding appointment status tracking.
* Adding record creation and modification timestamps.
* Introducing payment and billing management.
* Adding laboratory test management.
* Adding insurance information.
* Introducing staff and department management.

These enhancements are discussed in detail in the 📄 **[Database Design & Refinement Documentation](documentation/database-design-and-refinement.md)**.

---

## 🛠️ Technology

* **Database:** MySQL
* **Language:** SQL
* **Database Model:** Relational
* **Storage Engine:** InnoDB
* **Design Approach:** Requirements-driven relational database design

---

## 📂 Project Structure

```text
Relational-Database-Design-for-Nour-Medical-Centre/
│
├── README.md
│
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_sample_data.sql
│   └── 04_business_queries.sql
│
├── documentation/
│   ├── database-design-and-refinement.md
│   └── ERD.png
│
└── screenshots/
    └── mysql-workbench.png
```

---

## 💡 Key Learning Outcomes

This project demonstrates practical experience in:

* Requirements analysis
* Relational database design
* Entity and relationship identification
* Entity-Relationship Modeling
* Database normalization
* Primary and foreign key implementation
* Referential integrity
* SQL database implementation
* CRUD operations
* Multi-table queries and JOINs
* Transaction management
* Database evaluation and refinement
* Designing for future scalability

---

## 👤 Author

**Chidiebere David Ogbonna**

Data Analyst | SQL | Power BI | Tableau | Python | Excel

## Contact

Feel free to send your reviews, suggestions, questions and collaboration requests to chidieberedavid326@gmail.com

| Detail | Link |
| ------ | ---- |
| Email | chidieberedavid326@gmail.com |
| LinkedIn | [chidieberedavidogbonna](https://www.linkedin.com/in/chidieberedavidogbonna/) |
| GitHub | [iameberedavid](https://github.com/iameberedavid) |
| Medium | [eberedavid](https://eberedavid.medium.com) |
| Twitter | [iameberedavid](https://twitter.com/iameberedavid) |

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## ⚠️ Disclaimer

Nour Medical Centre is a fictional medical facility created solely for educational and portfolio purposes.
