-- ============================================================
-- EasyMed Healthcare Portal - Complete Database Schema
-- Version: 1.0.0
-- ============================================================

CREATE DATABASE IF NOT EXISTS easymed_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE easymed_db;

-- ============================================================
-- TABLE: departments
-- ============================================================
CREATE TABLE IF NOT EXISTS departments (
    dept_id       INT AUTO_INCREMENT PRIMARY KEY,
    dept_name     VARCHAR(100) NOT NULL UNIQUE,
    dept_code     VARCHAR(10) NOT NULL UNIQUE,
    description   TEXT,
    floor_number  TINYINT DEFAULT 1,
    head_name     VARCHAR(100),
    contact_ext   VARCHAR(10),
    is_active     TINYINT(1) DEFAULT 1,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO departments (dept_name, dept_code, description, floor_number, head_name, contact_ext) VALUES
('Cardiology',        'CARD', 'Heart and cardiovascular system care',              3, 'Dr. Arjun Mehta',   '301'),
('Neurology',         'NEUR', 'Brain, spine and nervous system treatment',         4, 'Dr. Priya Sharma',  '401'),
('Orthopedics',       'ORTH', 'Bones, joints, muscles and ligament care',          2, 'Dr. Rahul Verma',   '201'),
('Pediatrics',        'PEDI', 'Healthcare for infants, children and adolescents',  1, 'Dr. Sunita Rao',    '101'),
('Gynecology',        'GYNO', 'Women\'s reproductive and general health',          2, 'Dr. Kavita Singh',  '202'),
('Dermatology',       'DERM', 'Skin, hair and nail conditions',                    1, 'Dr. Amit Joshi',    '102'),
('Ophthalmology',     'OPHT', 'Eye care and vision treatment',                     1, 'Dr. Neha Patel',    '103'),
('ENT',               'ENT',  'Ear, nose and throat specialisation',               2, 'Dr. Vikram Sinha',  '203'),
('Gastroenterology',  'GAST', 'Digestive system and gastrointestinal care',        3, 'Dr. Deepa Nair',    '302'),
('Oncology',          'ONCO', 'Cancer diagnosis and treatment',                    5, 'Dr. Suresh Kumar',  '501'),
('Radiology',         'RADI', 'Diagnostic imaging services',                       B1,'Dr. Alok Tiwari',   'B101'),
('Emergency',         'EMER', '24x7 Emergency and trauma care',                    G, 'Dr. Anita Gupta',   '001'),
('General Medicine',  'GENM', 'Primary healthcare and general consultations',      1, 'Dr. Ramesh Dubey',  '104'),
('Psychiatry',        'PSYC', 'Mental health and psychiatric services',            4, 'Dr. Meena Agarwal', '402'),
('Urology',           'UROL', 'Urinary tract and male reproductive health',        3, 'Dr. Pankaj Mishra', '303');

-- ============================================================
-- TABLE: doctors
-- ============================================================
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id        INT AUTO_INCREMENT PRIMARY KEY,
    dept_id          INT NOT NULL,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    phone            VARCHAR(15) NOT NULL,
    specialization   VARCHAR(100),
    qualification    VARCHAR(200),
    experience_years TINYINT DEFAULT 0,
    registration_no  VARCHAR(30) UNIQUE,
    gender           ENUM('Male','Female','Other') DEFAULT 'Male',
    dob              DATE,
    joining_date     DATE,
    consultation_fee DECIMAL(8,2) DEFAULT 500.00,
    rating           DECIMAL(3,2) DEFAULT 4.00,
    total_reviews    INT DEFAULT 0,
    bio              TEXT,
    profile_img      VARCHAR(255) DEFAULT 'default-doctor.png',
    availability     JSON,
    is_active        TINYINT(1) DEFAULT 1,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE RESTRICT
);

INSERT INTO doctors (dept_id, first_name, last_name, email, phone, specialization, qualification, experience_years, registration_no, gender, dob, joining_date, consultation_fee, rating, total_reviews, bio) VALUES
(1,  'Arjun',   'Mehta',    'arjun.mehta@easymed.in',   '9876543210', 'Interventional Cardiologist',  'MBBS, MD (Cardiology), DM',        18, 'MCI-2005-12345', 'Male',   '1975-03-15', '2010-01-10', 1200.00, 4.8, 256, 'Specializes in angioplasty and cardiac catheterization.'),
(2,  'Priya',   'Sharma',   'priya.sharma@easymed.in',  '9876543211', 'Neurologist',                  'MBBS, MD (Neurology), DM',         14, 'MCI-2008-23456', 'Female','1979-07-22', '2012-03-15', 1000.00, 4.7, 189, 'Expert in stroke management and epilepsy treatment.'),
(3,  'Rahul',   'Verma',    'rahul.verma@easymed.in',   '9876543212', 'Orthopedic Surgeon',            'MBBS, MS (Ortho), DNB',            16, 'MCI-2006-34567', 'Male',   '1977-11-30', '2011-06-01', 900.00,  4.6, 312, 'Joint replacement and sports injury specialist.'),
(4,  'Sunita',  'Rao',      'sunita.rao@easymed.in',    '9876543213', 'Pediatrician',                 'MBBS, MD (Pediatrics)',             12, 'MCI-2010-45678', 'Female','1981-05-18', '2013-09-01', 700.00,  4.9, 421, 'Neonatal and developmental pediatrics specialist.'),
(5,  'Kavita',  'Singh',    'kavita.singh@easymed.in',  '9876543214', 'Obstetrician & Gynecologist',   'MBBS, MS (OBG)',                   15, 'MCI-2007-56789', 'Female','1978-09-12', '2012-01-20', 800.00,  4.8, 398, 'High-risk pregnancy and laparoscopic surgery expert.'),
(6,  'Amit',    'Joshi',    'amit.joshi@easymed.in',    '9876543215', 'Dermatologist',                'MBBS, MD (Dermatology)',            10, 'MCI-2012-67890', 'Male',   '1983-02-28', '2015-04-10', 700.00,  4.5, 267, 'Cosmetic dermatology and skin disease specialist.'),
(7,  'Neha',    'Patel',    'neha.patel@easymed.in',    '9876543216', 'Ophthalmologist',              'MBBS, MS (Ophthalmology), DOMS',    11, 'MCI-2011-78901', 'Female','1982-12-05', '2014-07-01', 750.00,  4.7, 203, 'LASIK surgery and retinal disease specialist.'),
(8,  'Vikram',  'Sinha',    'vikram.sinha@easymed.in',  '9876543217', 'ENT Specialist',               'MBBS, MS (ENT)',                   13, 'MCI-2009-89012', 'Male',   '1980-06-17', '2013-02-15', 650.00,  4.6, 178, 'Cochlear implant and sinus surgery specialist.'),
(9,  'Deepa',   'Nair',     'deepa.nair@easymed.in',    '9876543218', 'Gastroenterologist',           'MBBS, MD, DM (Gastroenterology)',  16, 'MCI-2006-90123', 'Female','1977-04-08', '2011-11-01', 950.00,  4.7, 234, 'Advanced endoscopy and IBD management specialist.'),
(10, 'Suresh',  'Kumar',    'suresh.kumar@easymed.in',  '9876543219', 'Medical Oncologist',           'MBBS, MD (Medicine), DM (Onco)',   20, 'MCI-2003-01234', 'Male',   '1973-08-25', '2008-05-01', 1500.00, 4.9, 156, 'Breast and lung cancer chemotherapy expert.'),
(13, 'Ramesh',  'Dubey',    'ramesh.dubey@easymed.in',  '9876543220', 'General Physician',            'MBBS, MD (General Medicine)',       9, 'MCI-2013-12340', 'Male',   '1984-01-14', '2016-08-01', 500.00,  4.5, 567, 'Primary care and preventive medicine specialist.'),
(14, 'Meena',   'Agarwal',  'meena.agarwal@easymed.in', '9876543221', 'Psychiatrist',                 'MBBS, MD (Psychiatry)',             11, 'MCI-2011-23451', 'Female','1982-10-30', '2014-03-01', 800.00,  4.8, 145, 'Anxiety, depression and trauma management specialist.'),
(15, 'Pankaj',  'Mishra',   'pankaj.mishra@easymed.in', '9876543222', 'Urologist',                   'MBBS, MS (Urology), MCh',          14, 'MCI-2008-34562', 'Male',   '1979-03-22', '2012-09-10', 900.00,  4.6, 198, 'Kidney stone and prostate surgery specialist.'),
(1,  'Rohit',   'Kapoor',   'rohit.kapoor@easymed.in',  '9876543223', 'Cardiac Electrophysiologist',  'MBBS, MD (Cardiology), DM, FSCAI', 12, 'MCI-2010-45673', 'Male',   '1981-07-11', '2014-01-15', 1100.00, 4.7, 134, 'Pacemaker implantation and arrhythmia management.'),
(2,  'Ananya',  'Krishnan', 'ananya.k@easymed.in',      '9876543224', 'Neurosurgeon',                 'MBBS, MS (Neurosurgery), MCh',     10, 'MCI-2012-56784', 'Female','1983-11-19', '2016-05-01', 1300.00, 4.8, 112, 'Brain tumour and spinal surgery specialist.');

-- ============================================================
-- TABLE: patients
-- ============================================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id      INT AUTO_INCREMENT PRIMARY KEY,
    patient_uid     VARCHAR(20) NOT NULL UNIQUE,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone           VARCHAR(15) NOT NULL,
    alt_phone       VARCHAR(15),
    password_hash   VARCHAR(255) NOT NULL,
    gender          ENUM('Male','Female','Other') NOT NULL,
    dob             DATE NOT NULL,
    blood_group     ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') DEFAULT NULL,
    address_line1   VARCHAR(200),
    address_line2   VARCHAR(200),
    city            VARCHAR(60),
    state           VARCHAR(60),
    pincode         VARCHAR(10),
    country         VARCHAR(60) DEFAULT 'India',
    emergency_contact_name  VARCHAR(100),
    emergency_contact_phone VARCHAR(15),
    emergency_contact_rel   VARCHAR(30),
    insurance_provider VARCHAR(100),
    insurance_policy_no VARCHAR(50),
    known_allergies TEXT,
    chronic_conditions TEXT,
    profile_img     VARCHAR(255) DEFAULT 'default-patient.png',
    is_active       TINYINT(1) DEFAULT 1,
    email_verified  TINYINT(1) DEFAULT 0,
    last_login      TIMESTAMP NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: appointments
-- ============================================================
CREATE TABLE IF NOT EXISTS appointments (
    appt_id         INT AUTO_INCREMENT PRIMARY KEY,
    appt_uid        VARCHAR(20) NOT NULL UNIQUE,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    dept_id         INT NOT NULL,
    appt_date       DATE NOT NULL,
    appt_time       TIME NOT NULL,
    appt_type       ENUM('Consultation','Follow-up','Emergency','Telemedicine','Procedure') DEFAULT 'Consultation',
    status          ENUM('Pending','Confirmed','Completed','Cancelled','No-Show','Rescheduled') DEFAULT 'Pending',
    reason          TEXT,
    notes           TEXT,
    symptoms        TEXT,
    fee             DECIMAL(8,2),
    payment_status  ENUM('Pending','Paid','Refunded','Waived') DEFAULT 'Pending',
    payment_method  ENUM('Cash','Card','UPI','Insurance','Online') DEFAULT NULL,
    transaction_id  VARCHAR(100),
    cancelled_by    ENUM('Patient','Doctor','Admin') DEFAULT NULL,
    cancel_reason   TEXT,
    reminder_sent   TINYINT(1) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)  ON DELETE RESTRICT,
    FOREIGN KEY (dept_id)    REFERENCES departments(dept_id) ON DELETE RESTRICT
);

-- ============================================================
-- TABLE: medical_records
-- ============================================================
CREATE TABLE IF NOT EXISTS medical_records (
    record_id       INT AUTO_INCREMENT PRIMARY KEY,
    record_uid      VARCHAR(20) NOT NULL UNIQUE,
    appt_id         INT,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    visit_date      DATE NOT NULL,
    chief_complaint TEXT,
    diagnosis       TEXT NOT NULL,
    icd_code        VARCHAR(20),
    treatment_plan  TEXT,
    prescription    JSON,
    lab_tests       JSON,
    vital_signs     JSON,
    follow_up_date  DATE,
    follow_up_notes TEXT,
    attachments     JSON,
    is_confidential TINYINT(1) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appt_id)    REFERENCES appointments(appt_id)   ON DELETE SET NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)    ON DELETE CASCADE,
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)      ON DELETE RESTRICT
);

-- ============================================================
-- TABLE: prescriptions
-- ============================================================
CREATE TABLE IF NOT EXISTS prescriptions (
    rx_id           INT AUTO_INCREMENT PRIMARY KEY,
    rx_uid          VARCHAR(20) NOT NULL UNIQUE,
    record_id       INT NOT NULL,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    issue_date      DATE NOT NULL,
    valid_until     DATE,
    medicine_name   VARCHAR(150) NOT NULL,
    dosage          VARCHAR(50),
    frequency       VARCHAR(100),
    duration        VARCHAR(50),
    instructions    TEXT,
    refills_allowed TINYINT DEFAULT 0,
    is_dispensed    TINYINT(1) DEFAULT 0,
    dispensed_date  TIMESTAMP NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id)  REFERENCES medical_records(record_id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)       ON DELETE CASCADE,
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)         ON DELETE RESTRICT
);

-- ============================================================
-- TABLE: lab_tests
-- ============================================================
CREATE TABLE IF NOT EXISTS lab_tests (
    test_id         INT AUTO_INCREMENT PRIMARY KEY,
    test_uid        VARCHAR(20) NOT NULL UNIQUE,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    record_id       INT,
    test_name       VARCHAR(150) NOT NULL,
    test_category   ENUM('Blood','Urine','Imaging','Biopsy','Microbiology','Genetics','Other') DEFAULT 'Blood',
    ordered_date    DATE NOT NULL,
    sample_date     TIMESTAMP NULL,
    result_date     TIMESTAMP NULL,
    status          ENUM('Ordered','Sample Collected','Processing','Completed','Cancelled') DEFAULT 'Ordered',
    result_value    TEXT,
    reference_range VARCHAR(100),
    unit            VARCHAR(30),
    is_abnormal     TINYINT(1) DEFAULT 0,
    lab_notes       TEXT,
    report_file     VARCHAR(255),
    cost            DECIMAL(8,2),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)    ON DELETE CASCADE,
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)      ON DELETE RESTRICT,
    FOREIGN KEY (record_id)  REFERENCES medical_records(record_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE: staff / admin users
-- ============================================================
CREATE TABLE IF NOT EXISTS staff (
    staff_id        INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    phone           VARCHAR(15),
    role            ENUM('Admin','Receptionist','Nurse','Lab Technician','Pharmacist','Billing') DEFAULT 'Receptionist',
    dept_id         INT,
    shift           ENUM('Morning','Afternoon','Night','Rotating') DEFAULT 'Morning',
    is_active       TINYINT(1) DEFAULT 1,
    last_login      TIMESTAMP NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

-- Insert default admin
INSERT INTO staff (first_name, last_name, email, password_hash, phone, role) VALUES
('Super','Admin','admin@easymed.in','$2b$10$defaulthashplaceholder','9800000000','Admin');

-- ============================================================
-- TABLE: doctor_schedules
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_schedules (
    schedule_id     INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id       INT NOT NULL,
    day_of_week     ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    slot_duration   TINYINT DEFAULT 20,
    max_patients    TINYINT DEFAULT 15,
    is_available    TINYINT(1) DEFAULT 1,
    UNIQUE KEY uq_doc_day (doctor_id, day_of_week),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: feedback / reviews
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id       INT AUTO_INCREMENT PRIMARY KEY,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    appt_id         INT,
    rating          TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text     TEXT,
    is_anonymous    TINYINT(1) DEFAULT 0,
    is_approved     TINYINT(1) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)   ON DELETE CASCADE,
    FOREIGN KEY (appt_id)    REFERENCES appointments(appt_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    notif_id        INT AUTO_INCREMENT PRIMARY KEY,
    user_type       ENUM('Patient','Doctor','Staff') NOT NULL,
    user_id         INT NOT NULL,
    title           VARCHAR(150) NOT NULL,
    message         TEXT NOT NULL,
    type            ENUM('Appointment','Lab','Prescription','Payment','General','Alert') DEFAULT 'General',
    is_read         TINYINT(1) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: billing / invoices
-- ============================================================
CREATE TABLE IF NOT EXISTS invoices (
    invoice_id      INT AUTO_INCREMENT PRIMARY KEY,
    invoice_uid     VARCHAR(20) NOT NULL UNIQUE,
    patient_id      INT NOT NULL,
    appt_id         INT,
    issue_date      DATE NOT NULL,
    due_date        DATE,
    subtotal        DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(10,2) DEFAULT 0,
    tax             DECIMAL(10,2) DEFAULT 0,
    total_amount    DECIMAL(10,2) NOT NULL,
    paid_amount     DECIMAL(10,2) DEFAULT 0,
    balance         DECIMAL(10,2) GENERATED ALWAYS AS (total_amount - paid_amount) STORED,
    status          ENUM('Draft','Issued','Paid','Partial','Overdue','Cancelled') DEFAULT 'Issued',
    payment_method  ENUM('Cash','Card','UPI','Insurance','Online','Multiple') DEFAULT NULL,
    notes           TEXT,
    created_by      INT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (appt_id)    REFERENCES appointments(appt_id) ON DELETE SET NULL
);

-- ============================================================
-- VIEWS
-- ============================================================
CREATE OR REPLACE VIEW vw_appointment_details AS
SELECT
    a.appt_id, a.appt_uid,
    CONCAT(p.first_name,' ',p.last_name) AS patient_name, p.phone AS patient_phone, p.email AS patient_email,
    CONCAT('Dr. ',d.first_name,' ',d.last_name) AS doctor_name, d.specialization,
    dep.dept_name,
    a.appt_date, a.appt_time, a.appt_type, a.status,
    a.fee, a.payment_status, a.reason
FROM appointments a
JOIN patients    p   ON a.patient_id = p.patient_id
JOIN doctors     d   ON a.doctor_id  = d.doctor_id
JOIN departments dep ON a.dept_id    = dep.dept_id;

CREATE OR REPLACE VIEW vw_doctor_stats AS
SELECT
    d.doctor_id,
    CONCAT(d.first_name,' ',d.last_name) AS doctor_name,
    d.specialization,
    dep.dept_name,
    COUNT(a.appt_id) AS total_appointments,
    SUM(CASE WHEN a.status='Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN a.status='Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(AVG(r.rating),2) AS avg_rating
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN reviews r      ON d.doctor_id = r.doctor_id
LEFT JOIN departments dep ON d.dept_id  = dep.dept_id
GROUP BY d.doctor_id;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_register_patient (
    IN p_fname VARCHAR(50), IN p_lname VARCHAR(50),
    IN p_email VARCHAR(100), IN p_phone VARCHAR(15),
    IN p_password VARCHAR(255), IN p_gender ENUM('Male','Female','Other'),
    IN p_dob DATE, IN p_blood VARCHAR(5)
)
BEGIN
    DECLARE v_uid VARCHAR(20);
    SET v_uid = CONCAT('PAT', YEAR(NOW()), LPAD(FLOOR(RAND()*100000),5,'0'));
    INSERT INTO patients (patient_uid, first_name, last_name, email, phone, password_hash, gender, dob, blood_group)
    VALUES (v_uid, p_fname, p_lname, p_email, p_phone, p_password, p_gender, p_dob, p_blood);
    SELECT patient_id, patient_uid FROM patients WHERE email = p_email;
END //

CREATE PROCEDURE IF NOT EXISTS sp_book_appointment (
    IN p_patient_id INT, IN p_doctor_id INT, IN p_dept_id INT,
    IN p_date DATE, IN p_time TIME, IN p_type VARCHAR(20),
    IN p_reason TEXT, IN p_symptoms TEXT
)
BEGIN
    DECLARE v_uid VARCHAR(20);
    DECLARE v_fee DECIMAL(8,2);
    SELECT consultation_fee INTO v_fee FROM doctors WHERE doctor_id = p_doctor_id;
    SET v_uid = CONCAT('APT', YEAR(NOW()), LPAD(FLOOR(RAND()*100000),5,'0'));
    INSERT INTO appointments (appt_uid, patient_id, doctor_id, dept_id, appt_date, appt_time, appt_type, reason, symptoms, fee)
    VALUES (v_uid, p_patient_id, p_doctor_id, p_dept_id, p_date, p_time, p_type, p_reason, p_symptoms, v_fee);
    SELECT appt_id, appt_uid FROM appointments WHERE appt_uid = v_uid;
END //

DELIMITER ;

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_appt_patient  ON appointments(patient_id);
CREATE INDEX idx_appt_doctor   ON appointments(doctor_id);
CREATE INDEX idx_appt_date     ON appointments(appt_date);
CREATE INDEX idx_appt_status   ON appointments(status);
CREATE INDEX idx_records_patient ON medical_records(patient_id);
CREATE INDEX idx_patient_phone   ON patients(phone);
CREATE INDEX idx_patient_uid     ON patients(patient_uid);

-- Done
SELECT 'EasyMed Database Schema Installed Successfully!' AS message;
