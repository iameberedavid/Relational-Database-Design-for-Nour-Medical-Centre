-- ============================================================
-- Nour Medical Centre
-- Relational Database Design
-- File: 02_create_tables.sql
-- Purpose: Create all database tables and relationships
-- ============================================================

USE nour_medical_centre;


-- ============================================================
-- 1. PATIENTS
-- ============================================================

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    contact_number VARCHAR(20) NOT NULL
) ENGINE = InnoDB;


-- ============================================================
-- 2. DOCTORS
-- ============================================================

CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    specialisation VARCHAR(100) NOT NULL
) ENGINE = InnoDB;


-- ============================================================
-- 3. MEDICATIONS
-- ============================================================

CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE = InnoDB;


-- ============================================================
-- 4. APPOINTMENTS
-- ============================================================

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    reason VARCHAR(255) NOT NULL,

    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
) ENGINE = InnoDB;


-- ============================================================
-- 5. MEDICAL RECORDS
-- ============================================================

CREATE TABLE medical_records (
    medical_record_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    diagnosis TEXT NOT NULL,

    CONSTRAINT fk_medical_records_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
) ENGINE = InnoDB;


-- ============================================================
-- 6. PRESCRIPTIONS
-- ============================================================

CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration VARCHAR(100) NOT NULL,

    CONSTRAINT fk_prescriptions_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),

    CONSTRAINT fk_prescriptions_medication
        FOREIGN KEY (medication_id)
        REFERENCES medications(medication_id)
) ENGINE = InnoDB;
