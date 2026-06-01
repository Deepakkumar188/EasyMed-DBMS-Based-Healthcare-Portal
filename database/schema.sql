-- ============================================================
-- EasyMed Healthcare Portal - Complete Database Schema
-- Version: 1.0.0
-- Author: EasyMed Technologies Pvt. Ltd.
-- ============================================================

CREATE DATABASE IF NOT EXISTS easymed_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE easymed_db;

-- ============================================================
-- TABLE: departments
-- ============================================================
CREATE TABLE IF NOT EXISTS departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    head_doctor_id INT DEFAULT NULL,
    floor_number INT DEFAULT 1,
    room_count INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: users (patients, doctors, admins, staff)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin','doctor','patient','staff','receptionist') NOT NULL DEFAULT 'patient',
    gender ENUM('Male','Female','Other') DEFAULT 'Other',
    date_of_birth DATE,
    blood_group ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') DEFAULT NULL,
    profile_image VARCHAR(255) DEFAULT 'default-avatar.png',
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_uuid (uuid)
);

-- ============================================================
-- TABLE: patients (extended patient data)
-- ============================================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    patient_code VARCHAR(20) UNIQUE NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    country VARCHAR(50) DEFAULT 'India',
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(50),
    marital_status ENUM('Single','Married','Divorced','Widowed') DEFAULT 'Single',
    occupation VARCHAR(100),
    insurance_provider VARCHAR(100),
    insurance_policy_number VARCHAR(50),
    insurance_expiry DATE,
    known_allergies TEXT,
    chronic_conditions TEXT,
    current_medications TEXT,
    registration_date DATE DEFAULT (CURDATE()),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_patient_code (patient_code),
    INDEX idx_user_id (user_id)
);

-- ============================================================
-- TABLE: doctors (extended doctor data)
-- ============================================================
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    doctor_code VARCHAR(20) UNIQUE NOT NULL,
    dept_id INT,
    specialization VARCHAR(100) NOT NULL,
    qualification VARCHAR(200),
    experience_years INT DEFAULT 0,
    license_number VARCHAR(50) UNIQUE,
    consultation_fee DECIMAL(10,2) DEFAULT 500.00,
    follow_up_fee DECIMAL(10,2) DEFAULT 300.00,
    bio TEXT,
    available_days VARCHAR(100) DEFAULT 'Mon,Tue,Wed,Thu,Fri',
    slot_duration INT DEFAULT 30,
    max_patients_per_day INT DEFAULT 20,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    joining_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
    INDEX idx_specialization (specialization),
    INDEX idx_dept_id (dept_id)
);

-- ============================================================
-- TABLE: doctor_schedules
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    break_start TIME DEFAULT NULL,
    break_end TIME DEFAULT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    UNIQUE KEY unique_doctor_day (doctor_id, day_of_week)
);

-- ============================================================
-- TABLE: appointments
-- ============================================================
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_code VARCHAR(20) UNIQUE NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    dept_id INT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    end_time TIME,
    appointment_type ENUM('New','Follow-up','Emergency','Teleconsult') DEFAULT 'New',
    status ENUM('Scheduled','Confirmed','Checked-In','In-Progress','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    reason_for_visit TEXT,
    symptoms TEXT,
    priority ENUM('Normal','Urgent','Emergency') DEFAULT 'Normal',
    consultation_fee DECIMAL(10,2),
    payment_status ENUM('Pending','Paid','Waived','Insurance') DEFAULT 'Pending',
    payment_method ENUM('Cash','Card','UPI','Insurance','Online') DEFAULT NULL,
    transaction_id VARCHAR(100) DEFAULT NULL,
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_by ENUM('Patient','Doctor','Admin') DEFAULT NULL,
    reminder_sent BOOLEAN DEFAULT FALSE,
    booked_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
    INDEX idx_appointment_date (appointment_date),
    INDEX idx_patient_id (patient_id),
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_status (status),
    INDEX idx_appointment_code (appointment_code)
);

-- ============================================================
-- TABLE: medical_records
-- ============================================================
CREATE TABLE IF NOT EXISTS medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    chief_complaint TEXT,
    history_of_illness TEXT,
    physical_examination TEXT,
    vital_signs JSON,
    diagnosis TEXT,
    icd_code VARCHAR(20),
    treatment_plan TEXT,
    prescription TEXT,
    lab_tests_ordered TEXT,
    follow_up_date DATE,
    follow_up_notes TEXT,
    doctor_notes TEXT,
    is_confidential BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    INDEX idx_patient_id (patient_id),
    INDEX idx_visit_date (visit_date)
);

-- ============================================================
-- TABLE: prescriptions
-- ============================================================
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_code VARCHAR(20) UNIQUE NOT NULL,
    record_id INT,
    appointment_id INT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    prescription_date DATE NOT NULL,
    diagnosis TEXT,
    notes TEXT,
    is_dispensed BOOLEAN DEFAULT FALSE,
    dispensed_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE SET NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT
);

-- ============================================================
-- TABLE: prescription_items
-- ============================================================
CREATE TABLE IF NOT EXISTS prescription_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_name VARCHAR(100) NOT NULL,
    generic_name VARCHAR(100),
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50),
    quantity INT DEFAULT 1,
    instructions TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: lab_tests
-- ============================================================
CREATE TABLE IF NOT EXISTS lab_tests (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    test_code VARCHAR(20) UNIQUE NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    test_name VARCHAR(100) NOT NULL,
    test_category ENUM('Blood','Urine','Radiology','Pathology','Microbiology','Cardiology','Other') DEFAULT 'Other',
    ordered_date DATE NOT NULL,
    sample_collected_date DATE,
    result_date DATE,
    status ENUM('Ordered','Sample Collected','Processing','Completed','Cancelled') DEFAULT 'Ordered',
    result TEXT,
    result_file VARCHAR(255),
    normal_range VARCHAR(100),
    interpretation TEXT,
    urgency ENUM('Routine','Urgent','STAT') DEFAULT 'Routine',
    cost DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE: bills
-- ============================================================
CREATE TABLE IF NOT EXISTS bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_number VARCHAR(20) UNIQUE NOT NULL,
    patient_id INT NOT NULL,
    appointment_id INT,
    bill_date DATE NOT NULL,
    due_date DATE,
    subtotal DECIMAL(10,2) DEFAULT 0.00,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    tax_percent DECIMAL(5,2) DEFAULT 18.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    paid_amount DECIMAL(10,2) DEFAULT 0.00,
    balance_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_status ENUM('Unpaid','Partial','Paid','Overdue','Waived') DEFAULT 'Unpaid',
    payment_method ENUM('Cash','Card','UPI','Insurance','Online','Cheque') DEFAULT NULL,
    transaction_id VARCHAR(100),
    insurance_claim_number VARCHAR(50),
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE: bill_items
-- ============================================================
CREATE TABLE IF NOT EXISTS bill_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    item_type ENUM('Consultation','Lab Test','Medicine','Procedure','Room','Other') DEFAULT 'Other',
    description VARCHAR(200) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bills(bill_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: staff
-- ============================================================
CREATE TABLE IF NOT EXISTS staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    staff_code VARCHAR(20) UNIQUE NOT NULL,
    dept_id INT,
    designation VARCHAR(100),
    employee_type ENUM('Full-Time','Part-Time','Contract','Intern') DEFAULT 'Full-Time',
    joining_date DATE,
    salary DECIMAL(10,2),
    shift ENUM('Morning','Afternoon','Night','Rotating') DEFAULT 'Morning',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('Appointment','Lab Result','Bill','System','Reminder','Alert') DEFAULT 'System',
    is_read BOOLEAN DEFAULT FALSE,
    related_id INT DEFAULT NULL,
    related_type VARCHAR(50) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, is_read)
);

-- ============================================================
-- TABLE: doctor_reviews
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    is_anonymous BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    UNIQUE KEY unique_patient_appointment (patient_id, appointment_id)
);

-- ============================================================
-- TABLE: audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);

-- ============================================================
-- TABLE: system_settings
-- ============================================================
CREATE TABLE IF NOT EXISTS system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('string','integer','boolean','json') DEFAULT 'string',
    description VARCHAR(255),
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- VIEWS for common queries
-- ============================================================

CREATE OR REPLACE VIEW vw_appointment_details AS
SELECT 
    a.appointment_id,
    a.appointment_code,
    a.appointment_date,
    a.appointment_time,
    a.status,
    a.appointment_type,
    a.priority,
    a.consultation_fee,
    a.payment_status,
    a.reason_for_visit,
    CONCAT(pu.first_name,' ',pu.last_name) AS patient_name,
    p.patient_code,
    pu.phone AS patient_phone,
    pu.email AS patient_email,
    pu.date_of_birth AS patient_dob,
    pu.blood_group,
    CONCAT(du.first_name,' ',du.last_name) AS doctor_name,
    d.doctor_code,
    d.specialization,
    dept.dept_name,
    dept.dept_code
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN users pu ON p.user_id = pu.user_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN users du ON d.user_id = du.user_id
LEFT JOIN departments dept ON a.dept_id = dept.dept_id;

CREATE OR REPLACE VIEW vw_doctor_profile AS
SELECT 
    d.doctor_id,
    d.doctor_code,
    d.specialization,
    d.qualification,
    d.experience_years,
    d.consultation_fee,
    d.follow_up_fee,
    d.rating,
    d.total_reviews,
    d.is_available,
    d.available_days,
    d.slot_duration,
    d.max_patients_per_day,
    CONCAT(u.first_name,' ',u.last_name) AS full_name,
    u.email,
    u.phone,
    u.gender,
    u.profile_image,
    dept.dept_name,
    dept.dept_code
FROM doctors d
JOIN users u ON d.user_id = u.user_id
LEFT JOIN departments dept ON d.dept_id = dept.dept_id
WHERE u.is_active = TRUE;

CREATE OR REPLACE VIEW vw_patient_summary AS
SELECT 
    p.patient_id,
    p.patient_code,
    p.city,
    p.insurance_provider,
    CONCAT(u.first_name,' ',u.last_name) AS full_name,
    u.email,
    u.phone,
    u.date_of_birth,
    u.blood_group,
    u.gender,
    u.profile_image,
    TIMESTAMPDIFF(YEAR, u.date_of_birth, CURDATE()) AS age,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    MAX(a.appointment_date) AS last_visit
FROM patients p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN appointments a ON p.patient_id = a.patient_id AND a.status = 'Completed'
GROUP BY p.patient_id;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_generate_patient_code()
BEGIN
    DECLARE new_code VARCHAR(20);
    DECLARE max_num INT;
    SELECT COALESCE(MAX(CAST(SUBSTRING(patient_code, 4) AS UNSIGNED)), 0) + 1 INTO max_num FROM patients;
    SET new_code = CONCAT('PAT', LPAD(max_num, 6, '0'));
    SELECT new_code AS patient_code;
END //

CREATE PROCEDURE IF NOT EXISTS sp_get_doctor_available_slots(
    IN p_doctor_id INT,
    IN p_date DATE
)
BEGIN
    DECLARE day_name VARCHAR(10);
    SET day_name = DAYNAME(p_date);
    
    SELECT 
        TIME_FORMAT(slot_time, '%h:%i %p') AS slot_time_formatted,
        slot_time,
        CASE 
            WHEN a.appointment_id IS NOT NULL THEN 'Booked'
            ELSE 'Available'
        END AS availability
    FROM (
        SELECT ADDTIME(ds.start_time, SEC_TO_TIME(n * d.slot_duration * 60)) AS slot_time
        FROM doctor_schedules ds
        JOIN doctors d ON ds.doctor_id = d.doctor_id
        CROSS JOIN (
            SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
            UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
            UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14
            UNION SELECT 15
        ) numbers
        WHERE ds.doctor_id = p_doctor_id AND ds.day_of_week = day_name
        HAVING slot_time < (SELECT end_time FROM doctor_schedules WHERE doctor_id = p_doctor_id AND day_of_week = day_name)
    ) slots
    LEFT JOIN appointments a ON a.doctor_id = p_doctor_id 
        AND a.appointment_date = p_date 
        AND a.appointment_time = slots.slot_time
        AND a.status NOT IN ('Cancelled','No-Show');
END //

CREATE PROCEDURE IF NOT EXISTS sp_dashboard_stats()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM patients) AS total_patients,
        (SELECT COUNT(*) FROM doctors WHERE is_available = TRUE) AS active_doctors,
        (SELECT COUNT(*) FROM appointments WHERE appointment_date = CURDATE()) AS today_appointments,
        (SELECT COUNT(*) FROM appointments WHERE status = 'Scheduled' AND appointment_date >= CURDATE()) AS pending_appointments,
        (SELECT COUNT(*) FROM appointments WHERE status = 'Completed' AND MONTH(appointment_date) = MONTH(CURDATE())) AS monthly_completed,
        (SELECT COALESCE(SUM(total_amount), 0) FROM bills WHERE MONTH(bill_date) = MONTH(CURDATE()) AND payment_status = 'Paid') AS monthly_revenue,
        (SELECT COUNT(*) FROM lab_tests WHERE status = 'Ordered' OR status = 'Processing') AS pending_lab_tests,
        (SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURDATE()) AS new_registrations_today;
END //

DELIMITER ;

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

CREATE TRIGGER IF NOT EXISTS trg_appointment_code_generate
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF NEW.appointment_code IS NULL OR NEW.appointment_code = '' THEN
        SET NEW.appointment_code = CONCAT('APT', DATE_FORMAT(NOW(), '%Y%m'), LPAD(FLOOR(RAND() * 99999), 5, '0'));
    END IF;
END //

CREATE TRIGGER IF NOT EXISTS trg_update_doctor_rating
AFTER INSERT ON doctor_reviews
FOR EACH ROW
BEGIN
    UPDATE doctors 
    SET rating = (SELECT AVG(rating) FROM doctor_reviews WHERE doctor_id = NEW.doctor_id AND is_approved = TRUE),
        total_reviews = (SELECT COUNT(*) FROM doctor_reviews WHERE doctor_id = NEW.doctor_id AND is_approved = TRUE)
    WHERE doctor_id = NEW.doctor_id;
END //

CREATE TRIGGER IF NOT EXISTS trg_bill_balance
BEFORE INSERT ON bills
FOR EACH ROW
BEGIN
    SET NEW.balance_amount = NEW.total_amount - NEW.paid_amount;
    IF NEW.balance_amount <= 0 THEN
        SET NEW.payment_status = 'Paid';
    ELSEIF NEW.paid_amount > 0 THEN
        SET NEW.payment_status = 'Partial';
    END IF;
END //

DELIMITER ;

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_appointments_date_doctor ON appointments(appointment_date, doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date_patient ON appointments(appointment_date, patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_patient_date ON medical_records(patient_id, visit_date);
CREATE INDEX IF NOT EXISTS idx_bills_patient_status ON bills(patient_id, payment_status);
