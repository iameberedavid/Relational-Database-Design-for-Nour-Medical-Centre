# Relational Database Design for Nour Medical Centre

![Data Analysis](https://img.shields.io/badge/Data%20Analysis-blue)
![Healthcare Analysis](https://img.shields.io/badge/Healthcare%20Analysis-brightgreen)
![Database Design](https://img.shields.io/badge/Database%20Design-blue)
![Medical Centre](https://img.shields.io/badge/Medical%20Centre-brightgreen)
![SQL](https://img.shields.io/badge/SQL-blue)
![MIT](https://img.shields.io/badge/MIT%20License-brightgreen)

## 📌 Project Overview

Nour Medical Centre is a small medical facility that requires a structured database to manage its day-to-day clinical operations.

This project involves the design and implementation of a **relational database schema using MySQL** to manage patients, doctors, appointments, diagnoses, and prescribed medications. The database is designed using core relational database principles, with emphasis on **data integrity, normalization, appropriate relationships, scalability, and efficient data management**.

The project follows a structured database design process, beginning with the identification of business requirements and entities, followed by relationship modeling, schema development, normalization, MySQL implementation, and evaluation of the final design against core database principles.

---

## 🎯 Project Objectives

The primary objectives of this project are to:

* Translate business requirements into a structured relational database model.
* Identify the key entities, attributes, and relationships required by the medical centre.
* Design a normalized database schema that minimizes data redundancy.
* Establish appropriate primary and foreign key relationships.
* Implement data integrity constraints using MySQL.
* Create a scalable database structure that can accommodate future operational requirements.
* Evaluate and refine the schema against established relational database design principles.
* Demonstrate practical application of SQL and relational database design.

---

## 🏥 Business Requirements

The database is designed based on the following business rules for Nour Medical Centre:

1. The medical centre has **patients**, and each patient has:

   * A unique patient ID
   * Full name
   * Date of birth
   * Contact number

2. The medical centre employs **doctors**, and each doctor has:

   * A unique doctor ID
   * Name
   * Specialisation

3. Patients can **book appointments** with a specific doctor.

   Each appointment records:

   * The patient
   * The doctor
   * Appointment date and time
   * Reason for the visit

4. After each appointment, the doctor records:

   * The diagnosis
   * Any prescribed medication

5. A patient can have **multiple appointments**.

6. A doctor can see **multiple patients**.

These requirements form the foundation for the entity-relationship model and relational schema developed in this project.

---

## 🧩 Entity Identification

Based on the business requirements, the following core entities were identified:

| Entity              | Purpose                                                                 |
| ------------------- | ----------------------------------------------------------------------- |
| **Patients**        | Stores information about patients registered at the medical centre.     |
| **Doctors**         | Stores information about doctors employed by the medical centre.        |
| **Appointments**    | Records appointments between patients and doctors.                      |
| **Medical Records** | Stores diagnoses and prescribed medication resulting from appointments. |

---

## 🔗 Entity Relationships

The database contains the following key relationships:

* A **patient** can have many appointments.
* A **doctor** can have many appointments.
* Each **appointment** belongs to one patient and one doctor.
* An appointment may have one corresponding medical record.
* The relationship between patients and doctors is **many-to-many**, resolved through the `Appointments` entity.

### Relationship Overview

```text
Patients                    Doctors
   │                           │
   │ 1                       1 │
   │                           │
   │ M                       M │
   └─────── Appointments ──────┘
                    │
                    │ 1
                    │
                    │ 0..1
                    │
             Medical Records
```

---

## 🗃️ Relational Schema

The proposed relational schema consists of four core tables.

### 1. Patients

Stores demographic and contact information for each patient.

| Column           | Data Type    | Constraint         | Description                        |
| ---------------- | ------------ | ------------------ | ---------------------------------- |
| `patient_id`     | INT          | PK, AUTO_INCREMENT | Unique identifier for each patient |
| `full_name`      | VARCHAR(100) | NOT NULL           | Patient's full name                |
| `date_of_birth`  | DATE         | NOT NULL           | Patient's date of birth            |
| `contact_number` | VARCHAR(20)  | NOT NULL           | Patient's contact number           |

---

### 2. Doctors

Stores information about doctors working at the medical centre.

| Column           | Data Type    | Constraint         | Description                       |
| ---------------- | ------------ | ------------------ | --------------------------------- |
| `doctor_id`      | INT          | PK, AUTO_INCREMENT | Unique identifier for each doctor |
| `doctor_name`    | VARCHAR(100) | NOT NULL           | Doctor's name                     |
| `specialisation` | VARCHAR(100) | NOT NULL           | Doctor's area of specialisation   |

---

### 3. Appointments

Acts as the transactional table connecting patients and doctors.

| Column                 | Data Type    | Constraint         | Description                   |
| ---------------------- | ------------ | ------------------ | ----------------------------- |
| `appointment_id`       | INT          | PK, AUTO_INCREMENT | Unique appointment identifier |
| `patient_id`           | INT          | FK, NOT NULL       | References the patient        |
| `doctor_id`            | INT          | FK, NOT NULL       | References the doctor         |
| `appointment_datetime` | DATETIME     | NOT NULL           | Date and time of appointment  |
| `reason`               | VARCHAR(255) | NOT NULL           | Reason for the visit          |

---

### 4. Medical Records

Stores clinical information recorded following an appointment.

| Column                  | Data Type | Constraint           | Description                                     |
| ----------------------- | --------- | -------------------- | ----------------------------------------------- |
| `medical_record_id`     | INT       | PK, AUTO_INCREMENT   | Unique medical record identifier                |
| `appointment_id`        | INT       | FK, NOT NULL, UNIQUE | References the appointment                      |
| `diagnosis`             | TEXT      | NOT NULL             | Diagnosis recorded by the doctor                |
| `prescribed_medication` | TEXT      | NULL                 | Medication prescribed following the appointment |

The `UNIQUE` constraint on `appointment_id` ensures that an appointment can have at most one medical record in this design.

---

## 🧱 Database Normalization

The schema was evaluated using the principles of **database normalization** to reduce redundancy and improve data integrity.

### First Normal Form (1NF)

The tables contain atomic values and do not contain repeating groups.

For example, patient details are stored in the `Patients` table rather than being repeatedly stored within appointment records.

### Second Normal Form (2NF)

Non-key attributes depend on the complete primary key of their respective tables.

The database separates patient, doctor, appointment, and medical record information into distinct entities, ensuring that attributes are associated with the entity they describe.

### Third Normal Form (3NF)

Non-key attributes depend only on the primary key and not on other non-key attributes.

For example:

* Patient contact information is stored in `Patients`.
* Doctor specialisation is stored in `Doctors`.
* Appointment information is stored in `Appointments`.
* Diagnosis and prescribed medication are stored in `Medical Records`.

This separation minimizes redundancy and helps maintain consistency when information changes.

---

## 🛡️ Data Integrity

Several database constraints are incorporated to maintain data quality and enforce valid relationships.

### Primary Keys

Each core entity has a unique primary key:

* `patient_id`
* `doctor_id`
* `appointment_id`
* `medical_record_id`

### Foreign Keys

Foreign keys establish referential relationships between tables:

```text
Appointments.patient_id
        ↓
Patients.patient_id

Appointments.doctor_id
        ↓
Doctors.doctor_id

Medical_Records.appointment_id
        ↓
Appointments.appointment_id
```

### NOT NULL Constraints

Required attributes such as patient names, doctor names, appointment details, and diagnoses cannot be left empty.

### UNIQUE Constraint

`Medical_Records.appointment_id` is unique to prevent multiple medical records from being unintentionally associated with the same appointment.

---

## 💻 MySQL Implementation

The database is implemented using **MySQL**.

### Technology Stack

| Component                  | Technology                   |
| -------------------------- | ---------------------------- |
| Database Management System | MySQL                        |
| Query Language             | SQL                          |
| Database Model             | Relational                   |
| Design Approach            | Normalized Relational Schema |

The SQL implementation covers:

* Database creation
* Table creation
* Primary key definitions
* Foreign key relationships
* Data integrity constraints
* Sample data insertion
* Data retrieval
* Data validation
* Business-oriented SQL queries

---

## 📊 Example SQL Queries

The completed database can be queried to answer operational questions relevant to the medical centre.

### 1. View appointments by doctor

```sql
SELECT
    d.doctor_name,
    p.full_name AS patient_name,
    a.appointment_datetime,
    a.reason
FROM appointments a
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN patients p
    ON a.patient_id = p.patient_id
ORDER BY d.doctor_name, a.appointment_datetime;
```

### 2. View a patient's appointment history

```sql
SELECT
    p.full_name,
    a.appointment_datetime,
    d.doctor_name,
    a.reason,
    mr.diagnosis,
    mr.prescribed_medication
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
LEFT JOIN medical_records mr
    ON a.appointment_id = mr.appointment_id
WHERE p.patient_id = 1
ORDER BY a.appointment_datetime DESC;
```

### 3. View appointments with recorded diagnoses

```sql
SELECT
    a.appointment_id,
    p.full_name AS patient_name,
    d.doctor_name,
    a.appointment_datetime,
    mr.diagnosis,
    mr.prescribed_medication
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN medical_records mr
    ON a.appointment_id = mr.appointment_id
ORDER BY a.appointment_datetime;
```

---

## 🔍 Schema Evaluation and Refinement

Following the initial schema design, the database was evaluated against core relational database principles.

The evaluation considered:

* Data redundancy
* Normalization
* Entity separation
* Primary key selection
* Foreign key relationships
* Referential integrity
* Attribute dependencies
* Data consistency
* Query efficiency
* Scalability

The schema was subsequently refined to address potential structural limitations and ensure that each entity has a clear purpose within the relational model.

This **design → evaluate → refine** approach ensures that the final database is not only functional but also structurally sound and maintainable.

---

## 📈 Scalability and Future Enhancements

The current schema addresses the core requirements of Nour Medical Centre while providing a foundation for future expansion.

Potential future entities include:

* **Medications** — A structured catalogue of medications.
* **Prescriptions** — Records individual medications prescribed during consultations.
* **Staff** — Stores nurses, administrators, and other healthcare personnel.
* **Departments** — Supports multiple medical departments or units.
* **Payments** — Tracks consultation and treatment payments.
* **Insurance** — Stores patient insurance information.
* **Laboratory Tests** — Tracks requested laboratory tests and results.
* **Appointment Status** — Tracks scheduled, completed, cancelled, or missed appointments.

### Potential Refinement: Prescription Management

The current requirements allow prescribed medication to be stored as a text attribute in `Medical Records`.

However, in a more advanced production environment, medication management could be further normalized by introducing separate `Medications` and `Prescriptions` entities.

This would allow:

* Multiple medications to be prescribed during one appointment.
* Medication names to be standardized.
* Dosage and frequency to be recorded independently.
* Medication records to be reused across multiple prescriptions.
* More detailed prescription reporting.

This represents a potential next stage of schema refinement as the system's requirements become more complex.

---

## 🗂️ Project Structure

```text
Relational-Database-Design-for-Nour-Medical-Centre/
│
├── README.md
│
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_sample_data.sql
│   └── 04_queries.sql
│
├── documentation/
│   ├── ERD.png
│   └── schema-design.md
│
└── screenshots/
    └── mysql-workbench.png
```

---

## 💡 Key Learning Outcomes

This project demonstrates practical application of:

* Relational database design
* Business requirements analysis
* Entity and attribute identification
* Entity-Relationship Modeling (ERD)
* Database normalization
* Primary and foreign key implementation
* Referential integrity
* SQL data definition and manipulation
* Data validation
* Multi-table SQL queries
* JOIN operations
* Translating business requirements into technical database structures
* Evaluating and refining relational database schemas
* Designing databases with future scalability in mind

---

## 🚀 Conclusion

The Nour Medical Centre database provides a structured relational foundation for managing core clinical operations.

By separating patients, doctors, appointments, and medical records into logically related entities, the design reduces unnecessary data duplication while maintaining referential integrity and supporting efficient information retrieval.

More importantly, the project demonstrates the complete database design process—from **business requirements analysis and entity identification to schema development, normalization, implementation, evaluation, and refinement**.

The resulting MySQL database provides a scalable foundation that can be extended to support additional healthcare operations such as prescription management, billing, laboratory services, insurance, and staff management.

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
