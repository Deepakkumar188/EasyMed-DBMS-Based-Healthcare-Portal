-- ============================================================
-- EasyMed Healthcare Portal - Seed Data
-- ============================================================
USE easymed_db;

-- Departments
INSERT INTO departments (dept_name, dept_code, description, floor_number, room_count) VALUES
('Cardiology', 'CARD', 'Heart and cardiovascular diseases treatment', 3, 15),
('Neurology', 'NEURO', 'Brain and nervous system disorders', 4, 12),
('Orthopedics', 'ORTHO', 'Bones, joints, and musculoskeletal system', 2, 18),
('Pediatrics', 'PEDS', 'Medical care for infants, children and adolescents', 1, 20),
('Gynecology', 'GYNE', 'Female reproductive system and obstetrics', 2, 15),
('Dermatology', 'DERM', 'Skin, hair, and nail conditions', 1, 10),
('Ophthalmology', 'OPTH', 'Eye diseases and vision care', 1, 8),
('ENT', 'ENT', 'Ear, Nose and Throat disorders', 1, 10),
('Oncology', 'ONCO', 'Cancer diagnosis and treatment', 5, 20),
('Psychiatry', 'PSYCH', 'Mental health and behavioral disorders', 4, 12),
('Gastroenterology', 'GASTRO', 'Digestive system disorders', 3, 10),
('Pulmonology', 'PULMO', 'Respiratory system and lung diseases', 3, 12),
('Endocrinology', 'ENDO', 'Hormonal and metabolic disorders', 2, 8),
('Urology', 'URO', 'Urinary tract and male reproductive system', 3, 10),
('Emergency Medicine', 'EMERG', '24/7 emergency medical services', 0, 25);

-- Admin User (password: Admin@123)
INSERT INTO users (uuid, first_name, last_name, email, password_hash, phone, role, gender, date_of_birth) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Admin', 'EasyMed', 'admin@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543210', 'admin', 'Male', '1985-01-15');

-- Doctor Users (password: Doctor@123)
INSERT INTO users (uuid, first_name, last_name, email, password_hash, phone, role, gender, date_of_birth, blood_group) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Rajesh', 'Sharma', 'rajesh.sharma@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543211', 'doctor', 'Male', '1975-03-22', 'B+'),
('550e8400-e29b-41d4-a716-446655440002', 'Priya', 'Patel', 'priya.patel@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543212', 'doctor', 'Female', '1980-07-14', 'O+'),
('550e8400-e29b-41d4-a716-446655440003', 'Anil', 'Kumar', 'anil.kumar@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543213', 'doctor', 'Male', '1972-11-05', 'A+'),
('550e8400-e29b-41d4-a716-446655440004', 'Sunita', 'Verma', 'sunita.verma@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543214', 'doctor', 'Female', '1983-05-28', 'AB+'),
('550e8400-e29b-41d4-a716-446655440005', 'Vikram', 'Singh', 'vikram.singh@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543215', 'doctor', 'Male', '1978-09-12', 'O-'),
('550e8400-e29b-41d4-a716-446655440006', 'Meera', 'Nair', 'meera.nair@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543216', 'doctor', 'Female', '1985-02-17', 'A-'),
('550e8400-e29b-41d4-a716-446655440007', 'Suresh', 'Gupta', 'suresh.gupta@easymed.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9876543217', 'doctor', 'Male', '1970-12-03', 'B-');

-- Doctors extended data
INSERT INTO doctors (user_id, doctor_code, dept_id, specialization, qualification, experience_years, license_number, consultation_fee, follow_up_fee, bio, available_days, slot_duration, max_patients_per_day, joining_date) VALUES
(2, 'DOC000001', 1, 'Cardiologist', 'MBBS, MD (Cardiology), DM', 18, 'MCI-CARD-2006-12345', 800.00, 400.00, 'Dr. Rajesh Sharma is a highly experienced cardiologist with 18 years of expertise in interventional cardiology and heart failure management.', 'Mon,Tue,Wed,Thu,Fri', 30, 25, '2010-04-01'),
(3, 'DOC000002', 2, 'Neurologist', 'MBBS, MD (Neurology), DM', 13, 'MCI-NEURO-2011-67890', 900.00, 450.00, 'Dr. Priya Patel specializes in stroke management, epilepsy, and movement disorders. She has published over 30 research papers.', 'Mon,Tue,Thu,Fri', 30, 20, '2012-06-15'),
(4, 'DOC000003', 3, 'Orthopedic Surgeon', 'MBBS, MS (Orthopedics), Fellowship in Joint Replacement', 21, 'MCI-ORTHO-2003-11111', 700.00, 350.00, 'Dr. Anil Kumar is a pioneer in minimally invasive joint replacement surgeries with over 2000 successful procedures.', 'Mon,Wed,Fri', 45, 15, '2008-01-10'),
(5, 'DOC000004', 4, 'Pediatrician', 'MBBS, MD (Pediatrics), Fellowship in PICU', 15, 'MCI-PEDS-2009-22222', 600.00, 300.00, 'Dr. Sunita Verma is a compassionate pediatrician with special interest in neonatal care and childhood immunization.', 'Mon,Tue,Wed,Thu,Fri,Sat', 20, 30, '2011-09-01'),
(6, 'DOC000005', 5, 'Gynecologist', 'MBBS, MS (Obstetrics & Gynecology)', 16, 'MCI-GYNE-2008-33333', 750.00, 375.00, 'Dr. Vikram Singh is an expert in high-risk pregnancies, laparoscopic gynecological surgeries, and reproductive medicine.', 'Mon,Tue,Wed,Thu,Fri', 30, 20, '2009-03-20'),
(7, 'DOC000006', 6, 'Dermatologist', 'MBBS, MD (Dermatology), Fellowship in Aesthetic Dermatology', 12, 'MCI-DERM-2012-44444', 650.00, 325.00, 'Dr. Meera Nair is a renowned dermatologist specializing in cosmetic procedures, hair disorders, and complex skin conditions.', 'Tue,Thu,Fri,Sat', 25, 22, '2013-07-05'),
(8, 'DOC000007', 10, 'Psychiatrist', 'MBBS, MD (Psychiatry), Fellowship in Child Psychiatry', 20, 'MCI-PSYCH-2004-55555', 850.00, 425.00, 'Dr. Suresh Gupta is a senior psychiatrist with expertise in mood disorders, anxiety, and addiction treatment.', 'Mon,Wed,Thu,Fri', 45, 12, '2007-11-15');

-- Doctor Schedules
INSERT INTO doctor_schedules (doctor_id, day_of_week, start_time, end_time, break_start, break_end) VALUES
(1, 'Monday', '09:00:00', '17:00:00', '13:00:00', '14:00:00'),
(1, 'Tuesday', '09:00:00', '17:00:00', '13:00:00', '14:00:00'),
(1, 'Wednesday', '09:00:00', '17:00:00', '13:00:00', '14:00:00'),
(1, 'Thursday', '09:00:00', '17:00:00', '13:00:00', '14:00:00'),
(1, 'Friday', '09:00:00', '14:00:00', NULL, NULL),
(2, 'Monday', '10:00:00', '18:00:00', '13:30:00', '14:30:00'),
(2, 'Tuesday', '10:00:00', '18:00:00', '13:30:00', '14:30:00'),
(2, 'Thursday', '10:00:00', '18:00:00', '13:30:00', '14:30:00'),
(2, 'Friday', '10:00:00', '16:00:00', NULL, NULL),
(3, 'Monday', '08:00:00', '16:00:00', '12:30:00', '13:30:00'),
(3, 'Wednesday', '08:00:00', '16:00:00', '12:30:00', '13:30:00'),
(3, 'Friday', '08:00:00', '14:00:00', NULL, NULL),
(4, 'Monday', '09:00:00', '18:00:00', '13:00:00', '14:00:00'),
(4, 'Tuesday', '09:00:00', '18:00:00', '13:00:00', '14:00:00'),
(4, 'Wednesday', '09:00:00', '18:00:00', '13:00:00', '14:00:00'),
(4, 'Thursday', '09:00:00', '18:00:00', '13:00:00', '14:00:00'),
(4, 'Friday', '09:00:00', '18:00:00', '13:00:00', '14:00:00'),
(4, 'Saturday', '09:00:00', '13:00:00', NULL, NULL);

-- Patient Users (password: Patient@123)
INSERT INTO users (uuid, first_name, last_name, email, password_hash, phone, role, gender, date_of_birth, blood_group) VALUES
('550e8400-e29b-41d4-a716-446655440010', 'Arjun', 'Mehta', 'arjun.mehta@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9812345670', 'patient', 'Male', '1990-04-15', 'O+'),
('550e8400-e29b-41d4-a716-446655440011', 'Kavita', 'Reddy', 'kavita.reddy@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9812345671', 'patient', 'Female', '1985-08-22', 'B+'),
('550e8400-e29b-41d4-a716-446655440012', 'Rahul', 'Joshi', 'rahul.joshi@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9812345672', 'patient', 'Male', '1978-12-30', 'A+'),
('550e8400-e29b-41d4-a716-446655440013', 'Anjali', 'Singh', 'anjali.singh@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9812345673', 'patient', 'Female', '1995-06-10', 'AB-'),
('550e8400-e29b-41d4-a716-446655440014', 'Deepak', 'Chaudhary', 'deepak.chaudhary@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9812345674', 'patient', 'Male', '1965-01-25', 'O-'),
('550e8400-e29b-41d4-a716-446655440015', 'Pooja', 'Iyer', 'pooja.iyer@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiG3VG3KEE8XdLmOnbK6yzU0jPGe', '9812345675', 'patient', 'Female', '2000-09-18', 'A-');

-- Patients extended data
INSERT INTO patients (user_id, patient_code, address, city, state, pincode, emergency_contact_name, emergency_contact_phone, emergency_contact_relation, marital_status, occupation, insurance_provider, insurance_policy_number, known_allergies, chronic_conditions, current_medications) VALUES
(9, 'PAT000001', '42, Nehru Nagar, Sector 15', 'Mumbai', 'Maharashtra', '400001', 'Sunita Mehta', '9800012345', 'Spouse', 'Married', 'Software Engineer', 'Star Health Insurance', 'SHI-2024-12345', 'Penicillin', 'Hypertension', 'Amlodipine 5mg'),
(10, 'PAT000002', '8, Gandhi Road, Koramangala', 'Bangalore', 'Karnataka', '560034', 'Ramesh Reddy', '9800012346', 'Father', 'Single', 'Teacher', 'HDFC ERGO Health', 'HE-2024-67890', 'None', 'Type 2 Diabetes', 'Metformin 500mg, Glipizide 5mg'),
(11, 'PAT000003', '15, MG Road, Banjara Hills', 'Hyderabad', 'Telangana', '500034', 'Rekha Joshi', '9800012347', 'Wife', 'Married', 'Business Owner', 'Bajaj Allianz Health', 'BAH-2024-11111', 'Sulfa drugs', 'Asthma, Hypertension', 'Salbutamol inhaler, Atenolol 50mg'),
(12, 'PAT000004', '27, Ring Road, Civil Lines', 'Delhi', 'Delhi', '110054', 'Ravi Singh', '9800012348', 'Brother', 'Single', 'Student', 'None', NULL, 'Dust, Pollen', 'Allergic Rhinitis', 'Cetirizine 10mg'),
(13, 'PAT000005', '5, Shivaji Nagar, Camp Area', 'Pune', 'Maharashtra', '411001', 'Meena Chaudhary', '9800012349', 'Wife', 'Married', 'Retired Government Officer', 'New India Assurance', 'NIA-2024-22222', 'Aspirin, NSAIDs', 'Diabetes, Heart Disease, Arthritis', 'Insulin, Losartan, Methotrexate'),
(14, 'PAT000006', '12, Anna Nagar, West', 'Chennai', 'Tamil Nadu', '600040', 'Vijay Iyer', '9800012350', 'Father', 'Single', 'College Student', 'None', NULL, 'None', 'None', 'None');

-- System Settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('hospital_name', 'EasyMed Healthcare', 'string', 'Hospital/Clinic name'),
('hospital_address', '123, Medical Hub, Tech City, India - 400001', 'string', 'Hospital address'),
('hospital_phone', '+91-22-12345678', 'string', 'Hospital contact number'),
('hospital_email', 'info@easymed.com', 'string', 'Hospital email'),
('appointment_reminder_hours', '24', 'integer', 'Hours before appointment to send reminder'),
('max_advance_booking_days', '30', 'integer', 'Maximum days in advance for booking'),
('min_advance_booking_hours', '2', 'integer', 'Minimum hours in advance for booking'),
('gst_percentage', '18', 'integer', 'GST percentage for bills'),
('default_consultation_fee', '500', 'integer', 'Default consultation fee'),
('currency_symbol', '₹', 'string', 'Currency symbol'),
('portal_version', '1.0.0', 'string', 'Portal version');
