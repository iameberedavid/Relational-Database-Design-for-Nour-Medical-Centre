-- ============================================================
-- Nour Medical Centre
-- Relational Database Design
--
-- IMPORTANT:
-- All names, telephone numbers and clinical records are fictional.
-- They are generated for portfolio, testing and SQL-analysis use.
--
-- TARGET RECORD COUNTS
-- Patients:        13,243
-- Doctors:             21
-- Medications:         31
-- Appointments:    37,918
-- Medical Records: 37,918
-- Prescriptions:   44,731
--
-- IMPORTANT:
-- Appointments and medical_records intentionally have equal counts
-- because the current business rule says that every appointment
-- results in a diagnosis being recorded.
-- ============================================================

USE nour_medical_centre;
SET SESSION cte_max_recursion_depth = 50000;

-- ============================================================
-- 0. RESET DATA
-- Reset existing sample data before reloading.
-- Run child tables first so foreign-key constraints are respected,
-- as foreign-key relationships depend on the parent records.
-- This makes the script safely re-runnable during development.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
-- Foreign-key checks are temporarily disabled to allow the development dataset to be completely reset and regenerated.

TRUNCATE TABLE prescriptions;
TRUNCATE TABLE medical_records;
TRUNCATE TABLE appointments;
TRUNCATE TABLE medications;
TRUNCATE TABLE doctors;
TRUNCATE TABLE patients;

SET FOREIGN_KEY_CHECKS = 1;
-- After the operation, we have to re-enable the foreign-key checks to maintain the foreign-key integrity

-- ============================================================
-- 1. DOCTORS (21 Doctors)
-- ============================================================

INSERT INTO doctors (doctor_id, doctor_name, specialisation)
VALUES
    (1,  'Dr. James Anderson',       'General Practice'),
    (2,  'Dr. Emily Thompson',       'Family Medicine'),
    (3,  'Dr. Michael Brown',        'Internal Medicine'),
    (4,  'Dr. Olivia Wilson',        'Paediatrics'),
    (5,  'Dr. Sophie Martin',        'Obstetrics & Gynaecology'),
    (6,  'Dr. Daniel Campbell',      'General Surgery'),
    (7,  'Dr. Chloe Bennett',        'Dermatology'),
    (8,  'Dr. Ryan Mitchell',        'Psychiatry'),
    (9,  'Dr. Sarah Patel',          'Cardiology'),
    (10, 'Dr. Ethan Clark',           'Ophthalmology'),
    (11, 'Dr. Hannah Roberts',        'Orthopaedics'),
    (12, 'Dr. Matthew Lewis',        'Ear, Nose & Throat'),
    (13, 'Dr. Benjamin Walker',      'General Practice'),
    (14, 'Dr. Charlotte Hughes',     'Family Medicine'),
    (15, 'Dr. William Turner',       'Internal Medicine'),
    (16, 'Dr. Grace Morgan',         'Paediatrics'),
    (17, 'Dr. Noah Williams',        'General Surgery'),
    (18, 'Dr. Amelia Carter',        'Obstetrics & Gynaecology'),
    (19, 'Dr. Liam Foster',          'Radiology'),
    (20, 'Dr. Isabella Cooper',      'Neurology'),
    (21, 'Dr. Alexander Reed',       'Urology');

-- ============================================================
-- 2. MEDICATIONS (31 medications)
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
    (25, 'Ferrous Sulfate'),
    (26, 'Amoxicillin/Clavulanate'),
    (27, 'Montelukast'),
    (28, 'Levothyroxine'),
    (29, 'Gabapentin'),
    (30, 'Aspirin'),
    (31, 'Cetirizine/Pseudoephedrine');

-- ============================================================
-- 3. PATIENTS (13,243 patients)
-- ============================================================
-- ELT() is used instead of JSON_EXTRACT() deliberately.
-- This avoids JSON-path compatibility issues while keeping the
-- generation deterministic and reproducible in MySQL.
-- ============================================================

INSERT INTO patients
    (patient_id, full_name, date_of_birth, contact_number)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 13243
)
SELECT
    n AS patient_id,
    CONCAT(
        ELT(
            1 + MOD(n * 17, 44),
            'James','Emily','Michael','Olivia','Daniel','Sophie',
            'William','Charlotte','Thomas','Amelia','George','Isla',
            'Henry','Grace','Jack','Ella','Noah','Ava',
            'Oliver','Mia','Arthur','Sophia','Leo','Freya',
            'Harry','Lily','Ethan','Chloe','Benjamin','Emma',
            'Liam','Harper','Alexander','Evelyn','Samuel','Abigail',
            'Jacob','Jessica','Lucas','Scarlett','Matthew','Sarah',
            'David','Victoria'
        ),
        ' ',
        ELT(
            1 + MOD(n * 23, 44),
            'Smith','Johnson','Williams','Brown','Jones','Miller',
            'Davis','Wilson','Taylor','Anderson','Thomas','Moore',
            'Martin','Jackson','Thompson','White','Harris','Clark',
            'Lewis','Walker','Hall','Young','Allen','Wright',
            'King','Scott','Green','Baker','Adams','Nelson',
            'Carter','Mitchell','Roberts','Campbell','Phillips',
            'Evans','Turner','Parker','Collins','Edwards','Stewart',
            'Sullivan','Morgan','Cooper','Reed'
        )
    ) AS full_name,

    DATE_ADD(
        '1940-01-01',
        INTERVAL MOD(n * 7919, 31536) DAY
    ) AS date_of_birth,
    CASE MOD(n, 3)
        WHEN 0 THEN CONCAT(
            '+1 416-',
            LPAD(MOD(n * 7919, 10000), 4, '0'),
            '-',
            LPAD(MOD(n * 104729, 10000), 4, '0')
        )
        WHEN 1 THEN CONCAT(
            '+1 212-',
            LPAD(MOD(n * 7919, 10000), 4, '0'),
            '-',
            LPAD(MOD(n * 104729, 10000), 4, '0')
        )
        ELSE CONCAT(
            '+44 20 ',
            LPAD(MOD(n * 7919, 10000), 4, '0'),
            ' ',
            LPAD(MOD(n * 104729, 10000), 4, '0')
        )
    END AS contact_number
FROM seq;

-- ============================================================
-- 4. APPOINTMENTS (37,918 appointments)
-- ============================================================

INSERT INTO appointments
    (appointment_id, patient_id, doctor_id, appointment_datetime, reason)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 37918
)
SELECT
    n AS appointment_id,
    1 + MOD(n * 37 + 11, 13243) AS patient_id,
    1 + MOD(n * 17 + 5, 21) AS doctor_id,
    TIMESTAMP(
        DATE_ADD(
            '2024-01-01',
            INTERVAL MOD(n * 13 + 7, 958) DAY
        ),
        MAKETIME(
            8 + MOD(n * 5 + 3, 9),
            15 * MOD(n * 11 + 1, 4),
            0
        )
    ) AS appointment_datetime,
    CASE MOD(n * 19, 17)
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
        WHEN 14 THEN 'Mental health consultation'
        WHEN 15 THEN 'Urinary symptoms'
        WHEN 16 THEN 'Persistent fatigue'
    END AS reason
FROM seq;

-- ============================================================
-- 5. MEDICAL RECORDS (37,918 medical records)
-- Number of appointments and number of medical records are the same
-- because a medical record is generated after every appointment
-- ============================================================

INSERT INTO medical_records
    (medical_record_id, appointment_id, diagnosis)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 37918
)
SELECT
    n AS medical_record_id,
    n AS appointment_id,
    CASE MOD(n * 29, 22)
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
        WHEN 18 THEN 'Asthma exacerbation'
        WHEN 19 THEN 'Hypothyroidism'
        WHEN 20 THEN 'Peripheral neuropathic pain'
        WHEN 21 THEN 'Hyperlipidaemia'
    END AS diagnosis
FROM seq;

-- ============================================================
-- 6. PRESCRIPTIONS
-- ============================================================

INSERT INTO prescriptions
    (prescription_id, appointment_id, medication_id,
     dosage, frequency, duration)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 44731
)
SELECT
    n AS prescription_id,
    1 + MOD(n * 23 + 7, 37918) AS appointment_id,
    1 + MOD(n * 11 + 3, 31) AS medication_id,
    CASE MOD(n * 7, 31)
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
        WHEN 25 THEN '625 mg'
        WHEN 26 THEN '10 mg'
        WHEN 27 THEN '50 mcg'
        WHEN 28 THEN '300 mg'
        WHEN 29 THEN '81 mg'
        WHEN 30 THEN '5 mg/120 mg'
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

-- TABLE COUNT VALIDATION - To confirm that all tables have the expected number of records
SELECT 'patients' AS table_name, COUNT(*) AS record_count FROM patients
UNION ALL
SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL
SELECT 'medications', COUNT(*) FROM medications
UNION ALL
SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'medical_records', COUNT(*) FROM medical_records
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM prescriptions;


-- ============================================================
-- FOREIGN-KEY / RELATIONSHIP VALIDATION
-- Expected result:
--   invalid_records = 0
--   validation_status = 'PASS'
-- A non-zero value indicates that one or more records reference a parent record that does not exist.
-- Relationships being tested:
--   1. appointments → patients
--   2. appointments → doctors
--   3. medical_records → appointments
--   4. prescriptions → appointments
--   5. prescriptions → medications
-- ============================================================

SELECT
    'Appointments → Patients' AS validation_check,
    COUNT(*) AS invalid_records,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM appointments AS a
LEFT JOIN patients AS p
    ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL

UNION ALL

SELECT
    'Appointments → Doctors' AS validation_check,
    COUNT(*) AS invalid_records,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM appointments AS a
LEFT JOIN doctors AS d
    ON a.doctor_id = d.doctor_id
WHERE d.doctor_id IS NULL

UNION ALL

SELECT
    'Medical Records → Appointments' AS validation_check,
    COUNT(*) AS invalid_records,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM medical_records AS mr
LEFT JOIN appointments AS a
    ON mr.appointment_id = a.appointment_id
WHERE a.appointment_id IS NULL

UNION ALL

SELECT
    'Prescriptions → Appointments' AS validation_check,
    COUNT(*) AS invalid_records,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM prescriptions AS pr
LEFT JOIN appointments AS a
    ON pr.appointment_id = a.appointment_id
WHERE a.appointment_id IS NULL

UNION ALL

SELECT
    'Prescriptions → Medications' AS validation_check,
    COUNT(*) AS invalid_records,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM prescriptions AS pr
LEFT JOIN medications AS m
    ON pr.medication_id = m.medication_id
WHERE m.medication_id IS NULL;