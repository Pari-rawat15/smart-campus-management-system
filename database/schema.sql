-- =========================================================
-- SMART CAMPUS MANAGEMENT SYSTEM
-- DATABASE SCHEMA
-- =========================================================

-- =========================================================
-- 1. DEPARTMENTS
-- =========================================================

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- 2. COURSES
-- =========================================================

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    department_id INTEGER NOT NULL,
    duration_years INTEGER NOT NULL CHECK (duration_years > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 3. USERS
-- =========================================================

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,

    role VARCHAR(20) NOT NULL
        CHECK (role IN ('ADMIN', 'FACULTY', 'STUDENT')),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- 4. STUDENTS
-- =========================================================

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL UNIQUE,

    enrollment_number VARCHAR(50) NOT NULL UNIQUE,

    course_id INTEGER NOT NULL,

    semester INTEGER NOT NULL
        CHECK (semester BETWEEN 1 AND 12),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_student_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_student_course
        FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE RESTRICT
);


-- =========================================================
-- 5. FACULTY
-- =========================================================

CREATE TABLE faculty (
    faculty_id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL UNIQUE,

    department_id INTEGER NOT NULL,

    employee_id VARCHAR(50) NOT NULL UNIQUE,

    designation VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_faculty_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_faculty_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
);


-- =========================================================
-- 6. SUBJECTS
-- =========================================================

CREATE TABLE subjects (
    subject_id SERIAL PRIMARY KEY,

    subject_code VARCHAR(20) NOT NULL UNIQUE,

    subject_name VARCHAR(100) NOT NULL,

    course_id INTEGER NOT NULL,

    semester INTEGER NOT NULL
        CHECK (semester BETWEEN 1 AND 12),

    credits INTEGER DEFAULT 4
        CHECK (credits > 0),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_subject_course
        FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 7. FACULTY-SUBJECT MAPPING
-- =========================================================

CREATE TABLE faculty_subjects (
    faculty_subject_id SERIAL PRIMARY KEY,

    faculty_id INTEGER NOT NULL,

    subject_id INTEGER NOT NULL,

    academic_year VARCHAR(20),

    CONSTRAINT fk_fs_faculty
        FOREIGN KEY (faculty_id)
        REFERENCES faculty(faculty_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fs_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_faculty_subject
        UNIQUE(faculty_id, subject_id)
);


-- =========================================================
-- 8. ENROLLMENTS
-- =========================================================

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,

    student_id INTEGER NOT NULL,

    subject_id INTEGER NOT NULL,

    academic_year VARCHAR(20),

    enrollment_date DATE DEFAULT CURRENT_DATE,

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_enrollment_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_student_subject
        UNIQUE(student_id, subject_id)
);


-- =========================================================
-- 9. ATTENDANCE
-- =========================================================

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,

    student_id INTEGER NOT NULL,

    subject_id INTEGER NOT NULL,

    attendance_date DATE NOT NULL,

    status VARCHAR(10) NOT NULL
        CHECK (status IN ('PRESENT', 'ABSENT')),

    marked_by INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_attendance_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_attendance_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_attendance_faculty
        FOREIGN KEY (marked_by)
        REFERENCES faculty(faculty_id)
        ON DELETE SET NULL,

    CONSTRAINT unique_attendance
        UNIQUE(student_id, subject_id, attendance_date)
);


-- =========================================================
-- 10. ASSIGNMENTS
-- =========================================================

CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,

    subject_id INTEGER NOT NULL,

    faculty_id INTEGER NOT NULL,

    title VARCHAR(200) NOT NULL,

    description TEXT,

    assigned_date DATE DEFAULT CURRENT_DATE,

    deadline TIMESTAMP NOT NULL,

    max_marks DECIMAL(5,2) DEFAULT 100,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_assignment_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_assignment_faculty
        FOREIGN KEY (faculty_id)
        REFERENCES faculty(faculty_id)
        ON DELETE RESTRICT
);


-- =========================================================
-- 11. ASSIGNMENT SUBMISSIONS
-- =========================================================

CREATE TABLE assignment_submissions (
    submission_id SERIAL PRIMARY KEY,

    assignment_id INTEGER NOT NULL,

    student_id INTEGER NOT NULL,

    submission_file VARCHAR(500),

    submission_text TEXT,

    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    marks DECIMAL(5,2),

    feedback TEXT,

    status VARCHAR(20) DEFAULT 'SUBMITTED'
        CHECK (
            status IN (
                'SUBMITTED',
                'LATE',
                'GRADED'
            )
        ),

    CONSTRAINT fk_submission_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES assignments(assignment_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_submission_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_assignment_submission
        UNIQUE(assignment_id, student_id)
);


-- =========================================================
-- 12. MARKS
-- =========================================================

CREATE TABLE marks (
    mark_id SERIAL PRIMARY KEY,

    student_id INTEGER NOT NULL,

    subject_id INTEGER NOT NULL,

    assessment_type VARCHAR(30) NOT NULL,

    marks_obtained DECIMAL(5,2) NOT NULL,

    maximum_marks DECIMAL(5,2) NOT NULL,

    academic_year VARCHAR(20),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_marks_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_marks_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE
);


-- =========================================================
-- 13. CLASSROOMS
-- =========================================================

CREATE TABLE classrooms (
    classroom_id SERIAL PRIMARY KEY,

    room_number VARCHAR(50) NOT NULL UNIQUE,

    building_name VARCHAR(100),

    capacity INTEGER NOT NULL
        CHECK (capacity > 0),

    room_type VARCHAR(50),

    has_projector BOOLEAN DEFAULT FALSE,

    has_ac BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- 14. TIMETABLE
-- =========================================================

CREATE TABLE timetable (
    timetable_id SERIAL PRIMARY KEY,

    subject_id INTEGER NOT NULL,

    faculty_id INTEGER NOT NULL,

    classroom_id INTEGER,

    day_of_week VARCHAR(15) NOT NULL,

    start_time TIME NOT NULL,

    end_time TIME NOT NULL,

    semester INTEGER NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_timetable_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_timetable_faculty
        FOREIGN KEY (faculty_id)
        REFERENCES faculty(faculty_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_timetable_classroom
        FOREIGN KEY (classroom_id)
        REFERENCES classrooms(classroom_id)
        ON DELETE SET NULL
);


-- =========================================================
-- 15. NOTICES
-- =========================================================

CREATE TABLE notices (
    notice_id SERIAL PRIMARY KEY,

    title VARCHAR(200) NOT NULL,

    description TEXT NOT NULL,

    created_by INTEGER,

    target_role VARCHAR(20)
        CHECK (
            target_role IN (
                'ALL',
                'STUDENT',
                'FACULTY'
            )
        ),

    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_notice_creator
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);


-- =========================================================
-- 16. EVENTS
-- =========================================================

CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,

    title VARCHAR(200) NOT NULL,

    description TEXT,

    event_date DATE NOT NULL,

    start_time TIME,

    end_time TIME,

    location VARCHAR(200),

    created_by INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_event_creator
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);


-- =========================================================
-- 17. COMPLAINTS
-- =========================================================

CREATE TABLE complaints (
    complaint_id SERIAL PRIMARY KEY,

    student_id INTEGER NOT NULL,

    category VARCHAR(50) NOT NULL,

    title VARCHAR(200) NOT NULL,

    description TEXT NOT NULL,

    location VARCHAR(200),

    status VARCHAR(30) DEFAULT 'SUBMITTED'
        CHECK (
            status IN (
                'SUBMITTED',
                'ASSIGNED',
                'IN_PROGRESS',
                'RESOLVED',
                'REJECTED'
            )
        ),

    assigned_to INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    resolved_at TIMESTAMP,

    CONSTRAINT fk_complaint_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_complaint_assignee
        FOREIGN KEY (assigned_to)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);


-- =========================================================
-- 18. LEAVE REQUESTS
-- =========================================================

CREATE TABLE leave_requests (
    leave_id SERIAL PRIMARY KEY,

    student_id INTEGER NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE NOT NULL,

    reason TEXT NOT NULL,

    status VARCHAR(20) DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'APPROVED',
                'REJECTED'
            )
        ),

    reviewed_by INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    reviewed_at TIMESTAMP,
        CONSTRAINT fk_leave_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_leave_reviewer
        FOREIGN KEY (reviewed_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);

   