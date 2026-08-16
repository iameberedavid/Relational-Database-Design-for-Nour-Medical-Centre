-- ============================================================
-- Nour Medical Centre
-- Relational Database Design
-- File: 03_insert_sample_data.sql
-- Purpose: Populate the database with realistic synthetic data
-- MySQL Version: 8.0+
--
-- DATA NOTE:
-- All names, phone numbers, appointments and clinical details in
-- this script are synthetic and created for portfolio/testing use.
-- They do not represent real patients, doctors or medical records.
--
-- DATASET SIZE
--   Patients:        13,243
--   Doctors:             18
--   Medications:         25
--   Appointments:    40,000
--   Medical Records: 40,000
--   Prescriptions:   48,000
--
-- DATA PERIOD
--   Appointments are generated between 2024-01-01 and 2026-08-15.
--
-- DESIGN APPROACH
--   The data is generated deterministically using MySQL 8 recursive
--   CTEs rather than hard-coding thousands of INSERT statements.
--   This keeps the project reproducible, auditable and easy to reset.
-- ============================================================

USE nour_medical_centre;

-- Increase the recursive CTE limit so MySQL can generate 13,243
-- patient records and 40,000 appointment records in one script.
SET SESSION cte_max_recursion_depth = 50000;


-- ============================================================
-- 1. DOCTORS
-- ============================================================
-- 18 doctors are used for a small-to-medium medical centre.
-- The specialties represent a realistic outpatient mix.
-- ============================================================

INSERT INTO doctors (doctor_id, doctor_name, specialisation)
VALUES
    (1,  'Dr. Chinedu Okafor',       'General Practice'),
    (2,  'Dr. Adaeze Nwosu',         'Family Medicine'),
    (3,  'Dr. Emeka Eze',            'Internal Medicine'),
    (4,  'Dr. Ngozi Okeke',           'Paediatrics'),
    (5,  'Dr. Chiamaka Obi',          'Obstetrics & Gynaecology'),
    (6,  'Dr. Ifeanyi Umeh',          'General Surgery'),
    (7,  'Dr. Amarachi Nnamani',      'Dermatology'),
    (8,  'Dr. Kelechi Eze',           'Psychiatry'),
    (9,  'Dr. Somtochukwu Anya',      'Cardiology'),
    (10, 'Dr. Uchechukwu Ibe',        'Ophthalmology'),
    (11, 'Dr. Nkemdilim Okoro',       'Orthopaedics'),
    (12, 'Dr. Oluchi Ezeani',         'Ear, Nose & Throat'),
    (13, 'Dr. Obinna Chukwu',         'General Practice'),
    (14, 'Dr. Esther Nwankwo',        'Family Medicine'),
    (15, 'Dr. Kingsley Onuoha',       'Internal Medicine'),
    (16, 'Dr. Blessing Opara',        'Paediatrics'),
    (17, 'Dr. Daniel Eze',            'General Surgery'),
    (18, 'Dr. Favour Nwafor',         'Obstetrics & Gynaecology');


-- ============================================================
-- 2. MEDICATIONS
-- ============================================================
-- A controlled medication list avoids repeatedly storing
-- medication names as free text.
-- ============================================================

INSERT INTO medications (medication_id, medication_name)
VALUES
    (1,  'Paracetamol'),
    (2,  'Amoxicillin'),
    (3,  'Azithromycin'),
    (4,  'Metronidazole'),
    (5,  'Artemether/Lumefantrine'),
    (6,  'Cetirizine'),
    (7,  'Loratadine'),
    (8,  'Omeprazole'),
    (9,  'Pantoprazole'),
    (10, 'Ibuprofen'),
    (11, 'Diclofenac'),
    (12, 'Amlodipine'),
    (13, 'Lisinopril'),
    (14, 'Losartan'),
    (15, 'Metformin'),
    (16, 'Glimepiride'),
    (17, 'Atorvastatin'),
    (18, 'Hydrochlorothiazide'),
    (19, 'Salbutamol'),
    (20, 'Prednisolone'),
    (21, 'Fluconazole'),
    (22, 'Clotrimazole'),
    (23, 'Doxycycline'),
    (24, 'Ciprofloxacin'),
    (25, 'Ferrous Sulfate');


-- ============================================================
-- 3. PATIENTS
-- ============================================================
-- 13,243 synthetic patients.
--
-- Names are generated from Nigerian first-name and surname
-- pools. Date-of-birth ranges are varied to produce a realistic
-- age distribution rather than assigning the same age pattern
-- to every patient.
--
-- Phone numbers are synthetic Nigerian-format numbers and are
-- generated algorithmically; they are not real contact numbers.
-- ============================================================

INSERT INTO patients
    (patient_id, full_name, date_of_birth, contact_number)
WITH RECURSIVE
seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 13243
),
first_names AS (
    SELECT
        JSON_UNQUOTE(JSON_EXTRACT(
            '["Chinedu","Adaeze","Emeka","Ngozi","Chiamaka","Ifeanyi",
              "Amarachi","Kelechi","Obinna","Uche","Nneka","Somtochukwu",
              "Ikenna","Chisom","Favour","Daniel","Blessing","Ogechi",
              "Tochukwu","Ebuka","Nkem","Nonso","Precious","Ifeoma",
              "Onyinye","Kingsley","Esther","David","Michael","Grace"]',
            CONCAT('$[', MOD(n - 1, 30), ']')
        )) AS first_name,
        n
    FROM seq
),
last_names AS (
    SELECT
        JSON_UNQUOTE(JSON_EXTRACT(
            '["Okafor","Nwosu","Eze","Okeke","Obi","Umeh","Nnamani",
              "Anya","Ibe","Okoro","Ezeani","Chukwu","Onuoha","Opara",
              "Nwankwo","Nwafor","Ekwueme","Nwachukwu","Ibekwe","Nwobodo",
              "Ojukwu","Ugwu","Mbah","Ezeh","Nwogu","Agu","Ilo",
              "Onoh","Ani","Ogbodo"]',
            CONCAT('$[', MOD(n * 7 - 7, 30), ']')
        )) AS last_name,
        n
    FROM seq
)
SELECT
    s.n AS patient_id,
    CONCAT(f.first_name, ' ', l.last_name) AS full_name,

    DATE_ADD(
        '1945-01-01',
        INTERVAL MOD(s.n * 7919, 28652) DAY
    ) AS date_of_birth,

    CONCAT(
        '080',
        LPAD(MOD(s.n * 7919, 100000000), 8, '0')
    ) AS contact_number

FROM seq s
JOIN first_names f ON f.n = s.n
JOIN last_names l ON l.n = s.n;


-- ============================================================
-- 4. APPOINTMENTS
-- ============================================================
-- 40,000 appointments distributed across the 13,243 patients
-- and 18 doctors.
--
-- Appointment dates fall between 2024-01-01 and 2026-08-15.
-- Reasons are selected from a realistic outpatient reason set.
-- ============================================================

INSERT INTO appointments
    (appointment_id, patient_id, doctor_id, appointment_datetime, reason)
WITH RECURSIVE
seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 40000
)
SELECT
    n AS appointment_id,

    1 + MOD(n * 37, 13243) AS patient_id,

    1 + MOD(n * 7, 18) AS doctor_id,

    TIMESTAMP(
        DATE_ADD(
            '2024-01-01',
            INTERVAL MOD(n * 13, 958) DAY
        ),
        MAKETIME(
            8 + MOD(n * 5, 9),
            15 * MOD(n * 11, 4),
            0
        )
    ) AS appointment_datetime,

    CASE MOD(n, 14)
        WHEN 0 THEN 'Routine medical consultation'
        WHEN 1 THEN 'Fever and general weakness'
        WHEN 2 THEN 'Cough and difficulty breathing'
        WHEN 3 THEN 'Headache and dizziness'
        WHEN 4 THEN 'Abdominal pain'
        WHEN 5 THEN 'Back or joint pain'
        WHEN 6 THEN 'Skin rash or irritation'
        WHEN 7 THEN 'Follow-up consultation'
        WHEN 8 THEN 'Prenatal consultation'
        WHEN 9 THEN 'Child health assessment'
        WHEN 10 THEN 'Blood pressure review'
        WHEN 11 THEN 'Diabetes follow-up'
        WHEN 12 THEN 'Eye discomfort or vision concern'
        WHEN 13 THEN 'Ear, nose or throat complaint'
    END AS reason

FROM seq;


-- ============================================================
-- 5. MEDICAL RECORDS
-- ============================================================
-- Every appointment receives one medical record because the
-- original business requirement states that after each
-- appointment the doctor records a diagnosis.
-- ============================================================

INSERT INTO medical_records
    (medical_record_id, appointment_id, diagnosis)
WITH RECURSIVE
seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 40000
)
SELECT
    n AS medical_record_id,
    n AS appointment_id,

    CASE MOD(n, 18)
        WHEN 0 THEN 'Acute upper respiratory tract infection'
        WHEN 1 THEN 'Malaria'
        WHEN 2 THEN 'Gastroenteritis'
        WHEN 3 THEN 'Essential hypertension'
        WHEN 4 THEN 'Type 2 diabetes mellitus'
        WHEN 5 THEN 'Peptic ulcer disease'
        WHEN 6 THEN 'Allergic rhinitis'
        WHEN 7 THEN 'Dermatitis'
        WHEN 8 THEN 'Musculoskeletal pain'
        WHEN 9 THEN 'Urinary tract infection'
        WHEN 10 THEN 'Migraine'
        WHEN 11 THEN 'Fungal skin infection'
        WHEN 12 THEN 'Iron deficiency anaemia'
        WHEN 13 THEN 'Acute bronchitis'
        WHEN 14 THEN 'Pregnancy-related consultation'
        WHEN 15 THEN 'Otitis media'
        WHEN 16 THEN 'Conjunctivitis'
        WHEN 17 THEN 'Routine follow-up'
    END AS diagnosis

FROM seq;


-- ============================================================
-- 6. PRESCRIPTIONS
-- ============================================================
-- 48,000 prescriptions are generated.
--
-- This creates:
--   - Multiple medications for many appointments.
--   - Some appointments with no prescription.
--   - Structured dosage, frequency and duration.
--
-- Each appointment can therefore have zero, one or more
-- prescription records.
-- ============================================================

INSERT INTO prescriptions
    (prescription_id, appointment_id, medication_id,
     dosage, frequency, duration)
WITH RECURSIVE
seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 48000
)
SELECT
    n AS prescription_id,

    CEIL(n / 2) AS appointment_id,

    1 + MOD(n * 7, 25) AS medication_id,

    CASE MOD(n * 7, 25)
        WHEN 0 THEN '500 mg'
        WHEN 1 THEN '500 mg'
        WHEN 2 THEN '500 mg'
        WHEN 3 THEN '400 mg'
        WHEN 4 THEN '20/120 mg'
        WHEN 5 THEN '10 mg'
        WHEN 6 THEN '10 mg'
        WHEN 7 THEN '20 mg'
        WHEN 8 THEN '40 mg'
        WHEN 9 THEN '400 mg'
        WHEN 10 THEN '50 mg'
        WHEN 11 THEN '5 mg'
        WHEN 12 THEN '10 mg'
        WHEN 13 THEN '50 mg'
        WHEN 14 THEN '500 mg'
        WHEN 15 THEN '4 mg'
        WHEN 16 THEN '20 mg'
        WHEN 17 THEN '25 mg'
        WHEN 18 THEN '100 mcg'
        WHEN 19 THEN '10 mg'
        WHEN 20 THEN '150 mg'
        WHEN 21 THEN '1% cream'
        WHEN 22 THEN '100 mg'
        WHEN 23 THEN '500 mg'
        WHEN 24 THEN '200 mg'
    END AS dosage,

    CASE MOD(n * 11, 5)
        WHEN 0 THEN 'Once daily'
        WHEN 1 THEN 'Twice daily'
        WHEN 2 THEN 'Three times daily'
        WHEN 3 THEN 'Every 8 hours'
        WHEN 4 THEN 'As directed'
    END AS frequency,

    CASE MOD(n * 13, 6)
        WHEN 0 THEN '3 days'
        WHEN 1 THEN '5 days'
        WHEN 2 THEN '7 days'
        WHEN 3 THEN '10 days'
        WHEN 4 THEN '14 days'
        WHEN 5 THEN '30 days'
    END AS duration

FROM seq;


-- ============================================================
-- 7. VALIDATION CHECKS
-- ============================================================
-- These queries provide an immediate quality check after the
-- script runs. They can be retained in this file or moved to
-- 04_business_queries.sql later.
-- ============================================================

SELECT 'patients' AS table_name, COUNT(*) AS record_count
FROM patients

UNION ALL

SELECT 'doctors', COUNT(*)
FROM doctors

UNION ALL

SELECT 'medications', COUNT(*)
FROM medications

UNION ALL

SELECT 'appointments', COUNT(*)
FROM appointments

UNION ALL

SELECT 'medical_records', COUNT(*)
FROM medical_records

UNION ALL

SELECT 'prescriptions', COUNT(*)
FROM prescriptions;
