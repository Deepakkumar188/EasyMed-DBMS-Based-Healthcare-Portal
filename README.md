# 🏥 EasyMed – DBMS-Based Healthcare Portal

> A full-stack, production-grade healthcare management system built with **Node.js**, **MySQL**, **EJS**, **Bootstrap 5**, and modern web technologies.

---

## 📋 Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Database Design](#database-design)
- [Installation](#installation)
- [Usage](#usage)
- [Default Credentials](#default-credentials)
- [API Endpoints](#api-endpoints)

---

## ✨ Features

### 👥 Patient Portal
- Patient self-registration with auto-generated Patient ID (PAT000001)
- Personal health dashboard with upcoming appointments, pending bills & notifications
- Online appointment booking with real-time doctor slot availability
- View complete medical records, prescriptions, lab results and bills
- Emergency contact and insurance information management

### 🩺 Doctor Portal
- Personalized daily schedule and appointment queue
- One-click patient consultation flow: Start → Record → Complete
- Full clinical record creation (vitals, diagnosis, treatment, prescriptions, lab orders)
- Patient history access across all visits
- Weekly schedule & availability management

### 🔑 Admin Portal
- Real-time dashboard with KPIs, charts, and live stats
- Complete patient & doctor management (CRUD)
- Appointment monitoring with filters by date, status, department
- Billing & payment tracking with summary cards
- Lab test management across all patients
- Department configuration
- Analytics reports with Chart.js visualizations
- System settings configuration

### 🗄️ Database
- 15+ normalized MySQL tables with foreign keys
- Stored procedures for common operations
- Triggers for auto-code generation, rating updates, billing
- Views for optimized queries (appointment details, patient summary, doctor profile)
- Indexes on all frequently queried columns

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js v18+ |
| Framework | Express.js 4.x |
| Template Engine | EJS (Embedded JavaScript) |
| Database | MySQL 8.0 |
| DB Driver | mysql2 (Promise-based) |
| Authentication | Passport.js (Local Strategy) |
| Password Hashing | bcryptjs (salt rounds: 12) |
| Session | express-session |
| Validation | express-validator |
| CSS Framework | Bootstrap 5.3 |
| Icons | Font Awesome 6 |
| Charts | Chart.js 4 |
| Fonts | Google Fonts (Inter, Playfair Display) |

---

## 📁 Project Structure

```
easymed/
├── config/
│   ├── database.js          # MySQL connection pool
│   └── passport.js          # Auth strategy
├── database/
│   ├── schema.sql           # Full DB schema (tables, views, procedures, triggers)
│   ├── seed.sql             # Sample data
│   └── setup.js             # DB initializer script
├── middleware/
│   └── auth.js              # Role-based access guards
├── public/
│   ├── css/main.css         # Complete custom stylesheet
│   ├── js/main.js           # Client-side utilities
│   └── js/dashboard.js      # Chart.js initialization
├── routes/
│   ├── index.js             # Public pages
│   ├── auth.js              # Login / Register / Logout
│   ├── admin.js             # Admin portal routes
│   ├── doctor.js            # Doctor portal routes
│   ├── patient.js           # Patient portal routes
│   ├── appointments.js      # Slot availability API
│   └── api.js               # JSON API (notifications, stats)
├── views/
│   ├── index.ejs            # Landing page
│   ├── about/contact/services/doctors.ejs
│   ├── auth/                # Login, Register
│   ├── admin/               # 9 admin views
│   ├── doctor/              # 5 doctor views
│   ├── patient/             # 7 patient views
│   ├── partials/            # Shared components
│   └── errors/              # 404, 403, 500
├── server.js                # App entry point
├── package.json
└── .env.example
```

---

## 🗄️ Database Design

### Core Tables (15+)
| Table | Purpose |
|---|---|
| `users` | All portal users (patients, doctors, admins, staff) |
| `patients` | Extended patient profile & medical info |
| `doctors` | Extended doctor profile, fees, schedule config |
| `departments` | Hospital departments |
| `appointments` | Appointment bookings & status tracking |
| `medical_records` | Clinical visit records with vitals (JSON) |
| `prescriptions` | Prescription headers |
| `prescription_items` | Individual medications per prescription |
| `lab_tests` | Lab investigations & results |
| `bills` | Patient billing & payment |
| `bill_items` | Line items per bill |
| `doctor_schedules` | Per-doctor weekly schedule |
| `notifications` | In-app notification system |
| `doctor_reviews` | Patient ratings & feedback |
| `audit_logs` | System activity logs |
| `system_settings` | Configurable portal settings |

### Views
- `vw_appointment_details` – Joined appointment data
- `vw_doctor_profile` – Full doctor info with department
- `vw_patient_summary` – Patient with visit counts

### Stored Procedures
- `sp_generate_patient_code()` – Auto-increment patient ID
- `sp_get_doctor_available_slots()` – Available time slots
- `sp_dashboard_stats()` – KPI aggregation

### Triggers
- Auto-generate appointment codes
- Auto-update doctor rating on new review
- Auto-calculate bill balance and payment status

---

## 🚀 Installation

### Prerequisites
- Node.js v18+
- MySQL 8.0+
- npm

### Steps

```bash
# 1. Clone / extract the project
cd easymed

# 2. Install dependencies
npm install

# 3. Configure environment
cp .env.example .env
# Edit .env with your MySQL credentials

# 4. Initialize the database
npm run setup-db

# 5. Start the server
npm start
# or for development with auto-reload:
npm run dev
```

---

## 🔐 Default Credentials

| Role | Email | Password |
|---|---|---|
| **Admin** | admin@easymed.com | Admin@123 |
| **Doctor** | rajesh.sharma@easymed.com | Doctor@123 |
| **Patient** | arjun.mehta@email.com | Patient@123 |

---

## 🌐 Routes

| Path | Description |
|---|---|
| `/` | Landing page |
| `/auth/login` | Login |
| `/auth/register` | Patient registration |
| `/admin/dashboard` | Admin dashboard |
| `/admin/patients` | Patient management |
| `/admin/doctors` | Doctor management |
| `/admin/appointments` | Appointment management |
| `/admin/departments` | Department management |
| `/admin/billing` | Billing |
| `/admin/lab-tests` | Lab tests |
| `/admin/reports` | Analytics |
| `/admin/settings` | System settings |
| `/doctor/dashboard` | Doctor dashboard |
| `/doctor/appointments` | Doctor's daily schedule |
| `/doctor/patients` | Doctor's patient list |
| `/patient/dashboard` | Patient dashboard |
| `/patient/book-appointment` | Book appointment |
| `/patient/appointments` | My appointments |
| `/patient/medical-records` | Medical history |
| `/patient/prescriptions` | Prescriptions |
| `/patient/lab-results` | Lab results |
| `/patient/bills` | Bills & payments |
| `/api/notifications` | JSON – notifications |
| `/appointments/slots` | JSON – available slots |

---

## 👨‍💻 Author
Name - Deepak Kumar
**EasyMed Technologies Pvt. Ltd.**  
Built as a DBMS-based Healthcare Portal project.

---

*Version 1.0.0 · Node.js · MySQL · Bootstrap 5*
