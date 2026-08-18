-- ============================================================
-- Nour Medical Centre
--
-- OBJECTIVE:
--   Answer practical business and operational questions using
--   the relational database created for Nour Medical Centre.
--
-- ANALYTICAL AREAS:
--   1. Patient activity
--   2. Appointment trends
--   3. Doctor workload
--   4. Specialisation demand
--   5. Diagnosis patterns
--   6. Medication utilisation
--   7. Patient retention / repeat visits
--   8. Operational workload
-- ============================================================

USE nour_medical_centre;

-- 1. PATIENT OVERVIEW
-- 1.1 Total Number of Registered Patients
-- Business Question: How many patients are registered at Nour Medical Centre?
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_registered_patients
FROM patients;

-- ------------------------------------------------------------
-- 1.2 Patient Age Distribution
-- Business Question: How are patients distributed across different age groups?
-- This helps management understand the demographic profile of the patient population.
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) < 18
            THEN 'Less than 18'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE)
             BETWEEN 18 AND 34
            THEN '18-34'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE)
             BETWEEN 35 AND 49
            THEN '35-49'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE)
             BETWEEN 50 AND 64
            THEN '50-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS patient_count
FROM patients
GROUP BY age_group
ORDER BY
    patient_count DESC;

-- 2. APPOINTMENT ANALYSIS
-- 2.1 Total Number of Appointments
-- Business Question: How many appointments have been recorded?
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_appointments
FROM appointments;

-- 2.2 Appointments by Month
-- Business Question: How does appointment volume change over time?
-- This identifies periods of higher or lower demand.
-- ------------------------------------------------------------

SELECT
    DATE_FORMAT(appointment_datetime, '%Y-%m') AS appointment_month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    DATE_FORMAT(appointment_datetime, '%Y-%m')
ORDER BY
    appointment_month;

-- 2.3 Appointments by Day of the Week
-- Business Question: Which days of the week experience the highest appointment volume?
-- Answering this question can support staffing and scheduling decisions.
-- ------------------------------------------------------------

SELECT
    DAYNAME(appointment_datetime) AS day_of_week,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    DAYOFWEEK(appointment_datetime),
    DAYNAME(appointment_datetime)
ORDER BY
    DAYOFWEEK(appointment_datetime);

-- 2.4 Appointments by Hour
-- Business Question: What times of day experience the highest appointment demand?
-- This can help management optimise doctor schedules and reception/front-desk staffing.
-- ------------------------------------------------------------

SELECT
    HOUR(appointment_datetime) AS appointment_hour,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    HOUR(appointment_datetime)
ORDER BY
    appointment_hour;


-- 3. DOCTOR WORKLOAD ANALYSIS
-- 3.1 Appointments by Doctor
-- Business Question: Which doctors handle the highest number of appointments?
-- ------------------------------------------------------------

SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialisation,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors AS d
LEFT JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    d.specialisation
ORDER BY
    total_appointments DESC;

-- 3.2 Average Appointments per Doctor
-- Business Question: What is the average appointment workload per doctor?
-- ------------------------------------------------------------

SELECT
    ROUND(COUNT(appointment_id) / COUNT(DISTINCT doctor_id), 2) AS average_appointments_per_doctor
FROM appointments;

-- 4. SPECIALISATION DEMAND
-- 4.1 Appointments by Medical Specialisation
-- Business Question: Which medical specialisations receive the highest demand?
-- ------------------------------------------------------------

SELECT
    d.specialisation,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors AS d
LEFT JOIN appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.specialisation
ORDER BY
    total_appointments DESC;

-- 4.2 Doctor Count by Specialisation
-- Business Question: How many doctors are available within each specialisation?
-- ------------------------------------------------------------

SELECT
    specialisation,
    COUNT(*) AS number_of_doctors
FROM doctors
GROUP BY
    specialisation
ORDER BY
    number_of_doctors DESC;

-- 5. PATIENT ENGAGEMENT & RETENTION
-- 5.1 Patients with Multiple Appointments
-- Business Question: How many patients have returned for more than one appointment?
-- Repeat visits can provide an indication of ongoing care, follow-up activity or patient retention.
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS patients_with_multiple_appointments
FROM
(
    SELECT
        patient_id
    FROM appointments
    GROUP BY
        patient_id
    HAVING COUNT(*) > 1
) AS repeat_patients;

-- 5.2 Top Patients by Number of Appointments
-- Business Question: Which patients have the highest number of recorded visits?
-- ------------------------------------------------------------

SELECT
    p.patient_id,
    p.full_name,
    COUNT(a.appointment_id) AS total_appointments
FROM patients AS p
INNER JOIN appointments AS a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.full_name
ORDER BY
    total_appointments DESC
LIMIT 20;

-- 6. DIAGNOSIS ANALYSIS
-- 6.1 Most Common Diagnoses
-- Business Question: What diagnoses occur most frequently?
-- This can help the medical centre understand common health conditions within its patient population.
-- ------------------------------------------------------------

SELECT
    diagnosis,
    COUNT(*) AS diagnosis_count
FROM medical_records
GROUP BY
    diagnosis
ORDER BY
    diagnosis_count DESC;

-- 6.2 Top 10 Diagnoses
-- Business Question: What are the ten most frequently recorded diagnoses?
-- ------------------------------------------------------------

SELECT
    diagnosis,
    COUNT(*) AS diagnosis_count
FROM medical_records
GROUP BY
    diagnosis
ORDER BY
    diagnosis_count DESC
LIMIT 10;

-- 7. MEDICATION ANALYSIS
-- 7.1 Most Frequently Prescribed Medications
-- Business Question: What are the ten most frequently prescribed medications?
-- ------------------------------------------------------------

SELECT
    m.medication_name,
    COUNT(pr.prescription_id) AS prescription_count
FROM medications AS m
INNER JOIN prescriptions AS pr
    ON m.medication_id = pr.medication_id
GROUP BY
    m.medication_id,
    m.medication_name
ORDER BY
    prescription_count DESC
LIMIT 10;

-- 8. APPOINTMENT-TO-PRESCRIPTION ANALYSIS
-- 8.1 Average Number of Prescriptions per Appointment
-- Business Question: On average, how many medications are prescribed per appointment?
-- ------------------------------------------------------------

SELECT
    ROUND(COUNT(pr.prescription_id)/ COUNT(DISTINCT a.appointment_id), 2) AS average_prescriptions_per_appointment
FROM appointments AS a
LEFT JOIN prescriptions AS pr
    ON a.appointment_id = pr.appointment_id;

-- 8.2 Appointments with Multiple Prescriptions
-- ------------------------------------------------------------
-- Business Question: How many appointments resulted in more than one medication being prescribed?
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS appointments_with_multiple_prescriptions
FROM
(
    SELECT
        appointment_id
    FROM prescriptions
    GROUP BY
        appointment_id
    HAVING COUNT(*) > 1
) AS multi_prescription_appointments;

-- 9. PATIENT APPOINTMENT FREQUENCY
-- 9.1 Average Number of Visits per Patient
-- ------------------------------------------------------------
-- Business Question: What is the average number of appointments recorded per patient?
-- ------------------------------------------------------------

SELECT
    ROUND(COUNT(*) / COUNT(DISTINCT patient_id), 2) AS average_appointments_per_patient
FROM appointments;

-- 9.2 Patient Visit Frequency Distribution
-- Business Question: How many patients have attended once, twice, three times, etc.?
-- This provides a more detailed view of patient engagement.
-- ------------------------------------------------------------

SELECT
    appointment_count,
    COUNT(*) AS number_of_patients
FROM
(
    SELECT
        patient_id,
        COUNT(*) AS appointment_count
    FROM appointments
    GROUP BY
        patient_id
) AS patient_visits
GROUP BY
    appointment_count
ORDER BY
    appointment_count;


-- ============================================================
-- 10. EXECUTIVE SUMMARY METRICS
-- ============================================================
-- This section produces a small set of high-level metrics that
-- could later feed a Power BI or Tableau dashboard.
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM patients)
        AS total_patients,
    (SELECT COUNT(*) FROM doctors)
        AS total_doctors,
    (SELECT COUNT(*) FROM appointments)
        AS total_appointments,
    (SELECT COUNT(*) FROM medical_records)
        AS total_medical_records,
    (SELECT COUNT(*) FROM prescriptions)
        AS total_prescriptions,
    ROUND((SELECT COUNT(*) FROM appointments)/(SELECT COUNT(*) FROM patients), 2) AS appointments_per_patient;