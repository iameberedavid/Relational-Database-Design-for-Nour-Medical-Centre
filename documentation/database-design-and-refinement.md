# Nour Medical Centre

## Database Design & Refinement

---

## 1. Purpose of This Document

This document explains the reasoning behind the relational database design developed for Nour Medical Centre.

Rather than presenting only the final database structure, the document evaluates how the business requirements were translated into a relational model, how the resulting schema satisfies core database principles, and where the design could be further refined as the medical centre's operational requirements become more sophisticated.

The design process follows:

> **Requirements Analysis → Entity Identification → Relationship Modeling → Schema Design → Evaluation → Refinement**

---

# 2. Business Context

Nour Medical Centre is a small medical facility that requires a database to manage its day-to-day operations.

The initial requirements focus on four areas:

* Patient management
* Doctor management
* Appointment management
* Post-appointment clinical records

The database should provide a reliable and structured way to store this information while maintaining relationships between patients, doctors, appointments, and medical records.

---

# 3. Business Requirements

The following requirements were provided:

### Patients

Each patient must have:

* A unique ID
* Full name
* Date of birth
* Contact number

### Doctors

Each doctor must have:

* A unique ID
* Name
* Specialisation

### Appointments

Patients can book appointments with specific doctors.

Each appointment must record:

* Patient
* Doctor
* Date
* Time
* Reason for visit

### Medical Outcome

After an appointment:

* A diagnosis must be recorded.
* Prescribed medication must be recorded.

### Relationships

* One patient can have many appointments.
* One doctor can see many patients.

---

# 4. Requirements-to-Entity Mapping

The business requirements were translated into four entities.

| Requirement            | Entity            | Key Information                          |
| ---------------------- | ----------------- | ---------------------------------------- |
| Patient management     | `Patients`        | Patient identity and contact information |
| Doctor management      | `Doctors`         | Doctor identity and specialisation       |
| Appointment management | `Appointments`    | Patient, doctor, date/time and reason    |
| Clinical outcome       | `Medical Records` | Diagnosis and prescribed medication      |

This separation ensures that each table represents a distinct business concept.

---

# 5. Initial Relational Design

## 5.1 Patients

```text
PATIENTS
--------
patient_id          PK
full_name
date_of_birth
contact_number
```

### Design rationale

Patient-specific information is stored separately so that it does not have to be repeated for every appointment.

For example, if a patient has ten appointments, their name, date of birth, and contact number are stored once rather than ten times.

---

## 5.2 Doctors

```text
DOCTORS
-------
doctor_id           PK
doctor_name
specialisation
```

### Design rationale

Doctor information is similarly separated from appointment information.

A doctor's name and specialisation do not change from one appointment to another, so storing these attributes in `Appointments` would introduce unnecessary duplication.

---

## 5.3 Appointments

```text
APPOINTMENTS
------------
appointment_id     PK
patient_id         FK
doctor_id          FK
appointment_datetime
reason
```

### Design rationale

Appointments represent the interaction between patients and doctors.

This table is particularly important because it resolves the many-to-many relationship between patients and doctors:

> A patient can see many doctors, and a doctor can see many patients.

Rather than storing multiple doctors inside a patient record or multiple patients inside a doctor record, the relationship is represented through individual appointment records.

---

## 5.4 Medical Records

```text
MEDICAL_RECORDS
---------------
medical_record_id       PK
appointment_id          FK
diagnosis
prescribed_medication
```

### Design rationale

Diagnosis and prescribed medication are outcomes of an appointment rather than characteristics of the patient, doctor, or appointment itself.

Separating them into a medical record allows an appointment to exist before the consultation has been completed.

The `appointment_id` is unique in this table to maintain a one-to-one relationship in the current design.

---

# 6. Relationship Analysis

## Patient → Appointment

**One-to-Many**

One patient can have many appointments.

```text
PATIENT
   1
   │
   │
   M
APPOINTMENT
```

The relationship is implemented using:

```text
appointments.patient_id
        ↓
patients.patient_id
```

---

## Doctor → Appointment

**One-to-Many**

One doctor can conduct many appointments.

```text
DOCTOR
   1
   │
   │
   M
APPOINTMENT
```

The relationship is implemented using:

```text
appointments.doctor_id
        ↓
doctors.doctor_id
```

---

## Appointment → Medical Record

**One-to-One**

Each completed appointment has one corresponding medical record in the current design.

```text
APPOINTMENT
    1
    │
    │
    1
MEDICAL RECORD
```

The relationship is enforced by making `medical_records.appointment_id` unique.

---

# 7. Why the Design Is Relational

The design demonstrates the characteristics of a relational database because:

1. Data is organized into tables.
2. Each table represents a logical entity.
3. Each table has a primary key.
4. Foreign keys establish relationships between tables.
5. Relationships are represented through key values rather than duplicated data.
6. Data can be queried across related tables using SQL JOIN operations.
7. Integrity constraints can be applied to maintain valid relationships.

The database therefore follows the relational model rather than relying on unstructured or purely in-memory data structures.

---

# 8. Persistence

The database is implemented in MySQL using persistent database tables.

Unlike temporary application variables or in-memory structures, records inserted into the database remain available after the application or database session ends, subject to normal database administration and retention processes.

The use of the **InnoDB** storage engine also provides transactional capabilities required for reliable operational data management.

---

# 9. CRUD Capability

Each core entity supports CRUD operations.

| Entity          | Create | Read | Update | Delete |
| --------------- | :----: | :--: | :----: | :----: |
| Patients        |    ✓   |   ✓  |    ✓   |    ✓   |
| Doctors         |    ✓   |   ✓  |    ✓   |    ✓   |
| Appointments    |    ✓   |   ✓  |    ✓   |    ✓   |
| Medical Records |    ✓   |   ✓  |    ✓   |    ✓   |

Examples include:

* Registering a new patient.
* Adding a doctor.
* Booking an appointment.
* Updating a patient's contact number.
* Recording a diagnosis.
* Retrieving a patient's appointment history.

In a production healthcare environment, deletion of clinical records would require appropriate retention and governance policies rather than unrestricted hard deletion.

---

# 10. Primary Key Evaluation

Every table has a primary key.

| Table             | Primary Key         |
| ----------------- | ------------------- |
| `Patients`        | `patient_id`        |
| `Doctors`         | `doctor_id`         |
| `Appointments`    | `appointment_id`    |
| `Medical Records` | `medical_record_id` |

This ensures that every row can be uniquely identified.

---

# 11. Foreign Key Evaluation

The following foreign keys maintain the relationships:

```text
Appointments.patient_id
        ↓
Patients.patient_id
```

```text
Appointments.doctor_id
        ↓
Doctors.doctor_id
```

```text
Medical_Records.appointment_id
        ↓
Appointments.appointment_id
```

These relationships help prevent orphan records and maintain referential integrity.

---

# 12. Normalization Assessment

The initial schema was assessed against the first three normal forms.

## 1NF

The schema uses atomic attributes and does not intentionally store repeating groups.

## 2NF

Attributes are associated with the entity whose primary key determines them.

## 3NF

Non-key attributes depend on the primary key rather than on other non-key attributes.

For example:

```text
Patient → patient_id → contact_number
Doctor → doctor_id → specialisation
Appointment → appointment_id → appointment_datetime
```

This prevents information such as a doctor's specialisation from being repeatedly stored across appointment records.

---

# 13. ACID and Transaction Reliability

The database can support ACID-compliant transactions when implemented with MySQL's InnoDB storage engine.

Consider an appointment workflow where the system needs to:

1. Create an appointment.
2. Record the diagnosis.
3. Record prescribed medication.

These operations can be handled within a transaction.

If all operations succeed:

```text
COMMIT
```

If an error occurs:

```text
ROLLBACK
```

This supports:

### Atomicity

The transaction can be treated as a single unit.

### Consistency

Database constraints help ensure that invalid relationships are not committed.

### Isolation

Concurrent database transactions can be isolated according to the configured isolation level.

### Durability

Once committed, the database engine is responsible for persisting the transaction.

Therefore, the schema can support reliable appointment processing when combined with appropriate transactional application logic.

---

# 14. Design Evaluation

The initial schema was evaluated against the following criteria:

| Evaluation Area       | Result                             |
| --------------------- | ---------------------------------- |
| Persistent storage    | Satisfied                          |
| Relational structure  | Satisfied                          |
| Primary keys          | Satisfied                          |
| Foreign keys          | Satisfied                          |
| Referential integrity | Satisfied                          |
| CRUD capability       | Satisfied                          |
| Normalization         | Satisfied for current requirements |
| Transaction support   | Supported through InnoDB           |
| Required attributes   | Satisfied                          |
| Future scalability    | Further refinement possible        |

The evaluation indicates that the initial schema satisfies the stated requirements while leaving room for further development.

---

# 15. Identified Design Limitations

The evaluation identified several areas where the design could become restrictive if Nour Medical Centre expands its operations.

The most significant limitation concerns **prescription management**.

The current model stores prescribed medication as a text attribute:

```text
prescribed_medication
```

This satisfies the initial requirement but does not provide a structured way to manage multiple medications, dosages, frequencies, or treatment durations.

Additional potential limitations include:

* No appointment lifecycle/status tracking.
* No audit timestamps.
* No billing or payment management.
* No laboratory test management.
* No structured insurance information.
* No staff or department management.

These are not considered failures of the initial schema because they were not part of the original business requirements.

Instead, they represent potential future requirements.

---

# 16. Future Refinement 1 — Structured Prescription Management

## Current State

The current `Medical Records` table contains:

```text
medical_record_id
appointment_id
diagnosis
prescribed_medication
```

Medication is stored as text.

---

## Reason for Refinement

A single appointment may involve multiple medications.

For example:

```text
Paracetamol
Amoxicillin
Vitamin C
```

Storing these values together in one text field makes the information difficult to:

* Query
* Validate
* Analyze
* Standardize
* Report

It also makes it difficult to capture medication-specific information such as dosage and frequency.

---

## Proposed Change

Introduce two additional entities:

### Medications

```text
MEDICATIONS
-----------
medication_id PK
medication_name
```

### Prescriptions

```text
PRESCRIPTIONS
-------------
prescription_id PK
appointment_id FK
medication_id FK
dosage
frequency
duration
```

The `prescribed_medication` field would then be removed from `Medical Records`.

---

## Relationship Change

The relationship becomes:

```text
Appointments
      │
      │ 1
      │
      │ M
Prescriptions
      │
      │ M
      │
      │ 1
Medications
```

This allows one appointment to have multiple prescriptions and allows the same medication to be referenced across many prescriptions.

---

## Expected Result

The refined design would provide:

* Structured medication data.
* Support for multiple medications per appointment.
* Medication-specific dosage and frequency.
* Reduced duplication.
* Improved query performance and reporting.
* Greater scalability.
* Better alignment with normalized relational design.

### Decision

**Future refinement.**

The current implementation remains appropriate for the original requirements, while the structured prescription model provides a clear path for future expansion.

---

# 17. Future Refinement 2 — Appointment Status

## Current State

The current `Appointments` table records:

```text
appointment_id
patient_id
doctor_id
appointment_datetime
reason
```

It does not indicate what happened to the appointment.

---

## Reason for Refinement

A real medical centre needs to distinguish between appointments that are:

* Scheduled
* Completed
* Cancelled
* No-show

Without this information, operational reporting becomes limited.

---

## Proposed Change

Add:

```text
appointment_status
```

Possible values include:

```text
Scheduled
Completed
Cancelled
No-show
```

---

## Structural Change

```text
APPOINTMENTS
------------
appointment_id PK
patient_id FK
doctor_id FK
appointment_datetime
reason
appointment_status
```

---

## Expected Result

The medical centre would be able to answer questions such as:

* How many appointments were completed?
* How many were cancelled?
* How many patients failed to attend?
* What is each doctor's appointment completion rate?
* What percentage of appointments are cancelled?

This would make the database more useful for **operational performance analysis**.

### Decision

**Future enhancement.**

Appointment status is not explicitly required in the initial scenario, so it is documented as an extension rather than unnecessarily expanding the initial schema.

---

# 18. Future Refinement 3 — Audit Timestamps

## Current State

The database does not record when individual records were created or modified.

---

## Reason for Refinement

Audit timestamps can become important as the medical centre grows.

They can support:

* Data auditing
* Troubleshooting
* Change tracking
* Data governance
* Operational reporting

---

## Proposed Change

Introduce fields such as:

```text
created_at
updated_at
```

For example:

```text
PATIENTS
--------
patient_id
full_name
date_of_birth
contact_number
created_at
updated_at
```

The same approach could be applied to other operational tables where tracking record history is valuable.

---

## Expected Result

The system would be able to determine:

* When a record was created.
* When it was last modified.
* Which records have recently changed.

This improves traceability and supports stronger data governance.

### Decision

**Future enhancement.**

The fields are not necessary to satisfy the current requirements but would be valuable in a production environment.

---

# 19. Future Refinement 4 — Payment Management

## Reason for Refinement

The current database focuses on clinical operations and does not capture financial transactions.

If Nour Medical Centre wants to manage billing through the system, payment information would require its own entity rather than being added to patient or appointment records.

---

## Proposed Change

Introduce a `Payments` entity:

```text
PAYMENTS
--------
payment_id PK
appointment_id FK
amount
payment_date
payment_method
payment_status
```

---

## Expected Result

This would allow the medical centre to:

* Track payments.
* Monitor outstanding balances.
* Analyze revenue.
* Associate payments with appointments.
* Generate financial reports.

### Decision

**Future enhancement.**

Financial management is outside the scope of the current requirements.

---

# 20. Future Refinement 5 — Laboratory Management

## Reason for Refinement

A medical centre may eventually require laboratory testing as part of patient care.

Laboratory information should not be stored directly in appointments because one appointment may involve multiple tests.

---

## Proposed Structure

Potential entities include:

```text
LAB_TESTS
---------
test_id PK
test_name

LAB_ORDERS
----------
lab_order_id PK
appointment_id FK
test_id FK
test_date
result
status
```

---

## Expected Result

This would allow the database to support:

* Multiple laboratory tests per appointment.
* Structured test results.
* Test history.
* Patient laboratory reporting.

### Decision

**Future enhancement.**

---

# 21. Refinement Summary

| Refinement               | Reason                               | Structural Change                     | Expected Result                            | Classification     |
| ------------------------ | ------------------------------------ | ------------------------------------- | ------------------------------------------ | ------------------ |
| Structured prescriptions | Medication stored as free text       | Add `Medications` and `Prescriptions` | Structured, scalable medication management | Future Refinement  |
| Appointment status       | No appointment lifecycle information | Add `appointment_status`              | Better operational reporting               | Future Enhancement |
| Audit timestamps         | No record-change tracking            | Add `created_at`, `updated_at`        | Better traceability and governance         | Future Enhancement |
| Payment management       | No financial tracking                | Add `Payments`                        | Revenue and payment reporting              | Future Enhancement |
| Laboratory management    | No test/result management            | Add `Lab Tests` and `Lab Orders`      | Structured laboratory workflows            | Future Enhancement |

---

# 22. Design Decision: Avoiding Over-Engineering

An important principle applied during this project was **requirements-driven design**.

It would be possible to introduce numerous tables for:

* Payments
* Insurance
* Laboratories
* Prescriptions
* Staff
* Departments
* Medical procedures
* Patient addresses
* Emergency contacts

However, introducing entities that are not supported by the current requirements could unnecessarily increase the complexity of the database.

Therefore, the initial schema intentionally focuses on the four entities required to satisfy the current business problem:

```text
Patients
Doctors
Appointments
Medical Records
```

Future requirements can then drive subsequent schema evolution.

This approach balances **simplicity, correctness, and scalability**.

---

# 23. Final Design Assessment

The initial schema successfully satisfies the stated requirements.

It:

* Stores data persistently.
* Uses a relational database structure.
* Provides a primary key for every table.
* Uses foreign keys to establish relationships.
* Correctly represents the relationship between patients and doctors through appointments.
* Supports CRUD operations.
* Supports transactional processing through MySQL InnoDB.
* Applies normalization principles.
* Maintains referential integrity.
* Provides a foundation for future expansion.

The evaluation also demonstrates that a database design should not be viewed as static. As business requirements evolve, the schema can be refined to accommodate more complex operational needs.

---

# 24. Conclusion

The Nour Medical Centre database demonstrates a requirements-driven approach to relational database design.

The initial schema provides an appropriately scoped solution to the stated business problem while applying fundamental principles of relational modeling, normalization, data integrity, and transaction reliability.

The subsequent evaluation identified opportunities for further refinement, particularly around structured prescription management, appointment lifecycle tracking, auditability, payments, and laboratory services.

The key design principle is therefore:

> **Build for the current requirements, evaluate against sound database principles, and design a clear path for future scalability.**

This approach ensures that the database remains practical for the current business problem while providing a foundation that can evolve alongside Nour Medical Centre's operational needs.

