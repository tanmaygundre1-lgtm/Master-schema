-- School ERP Database Schema
-- Simple, focused schema for lead management

-- Drop existing tables if they exist
DROP TABLE IF EXISTS applications CASCADE;

DROP TABLE IF EXISTS parents CASCADE;

DROP TABLE IF EXISTS counselors CASCADE;

DROP TABLE IF EXISTS leads CASCADE;

-- Leads table
CREATE TABLE leads (
    id SERIAL PRIMARY KEY,
    student_first_name VARCHAR(100) NOT NULL,
    student_last_name VARCHAR(100),
    dob DATE,
    gender VARCHAR(20),
    grade VARCHAR(50),
    current_school VARCHAR(255),
    source VARCHAR(100),
    notes TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE calls (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES leads (id) ON DELETE CASCADE,
    call_type VARCHAR(50) NOT NULL CHECK (
        call_type IN ('inbound', 'outbound')
    ),
    duration_seconds INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE emails (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES leads (id) ON DELETE CASCADE,
    subject VARCHAR(255),
    body TEXT,
    status VARCHAR(50) DEFAULT 'sent' CHECK (
        status IN (
            'sent',
            'delivered',
            'read',
            'failed'
        )
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tours (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES leads (id) ON DELETE CASCADE,
    tour_date TIMESTAMP NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'scheduled' CHECK (
        status IN (
            'scheduled',
            'completed',
            'cancelled'
        )
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Parents table
CREATE TABLE parents (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER REFERENCES leads (id) ON DELETE CASCADE,
    type VARCHAR(20) CHECK (type IN ('father', 'mother')),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    occupation VARCHAR(100),
    company VARCHAR(255)
);

-- Counselors table
CREATE TABLE counselors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Applications table
CREATE TABLE applications (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER REFERENCES leads (id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending' CHECK (
        status IN (
            'pending',
            'approved',
            'rejected'
        )
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_leads_status ON leads (status);

CREATE INDEX idx_leads_created_at ON leads (created_at);

CREATE INDEX idx_calls_lead_id ON calls (lead_id);

CREATE INDEX idx_calls_created_at ON calls (created_at);

CREATE INDEX idx_emails_lead_id ON emails (lead_id);

CREATE INDEX idx_emails_created_at ON emails (created_at);

CREATE INDEX idx_tours_lead_id ON tours (lead_id);

CREATE INDEX idx_tours_tour_date ON tours (tour_date);

CREATE INDEX idx_tours_created_at ON tours (created_at);

CREATE INDEX idx_parents_lead_id ON parents (lead_id);

CREATE INDEX idx_applications_lead_id ON applications (lead_id);

CREATE INDEX idx_applications_status ON applications (status);

-- Settings Module Database Schema
-- This file creates all necessary tables for the Settings module

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'Counselor' CHECK (
        role IN (
            'Admin',
            'Counselor',
            'Manager'
        )
    ),
    profile_photo VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for email lookup
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- 2. Notification Settings Table
CREATE TABLE IF NOT EXISTS notification_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    new_lead_assignments BOOLEAN DEFAULT true,
    task_reminders BOOLEAN DEFAULT true,
    application_updates BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    whatsapp_notifications BOOLEAN DEFAULT false,
    notification_frequency VARCHAR(50) DEFAULT 'immediately' CHECK (
        notification_frequency IN (
            'immediately',
            'daily',
            'weekly'
        )
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Index for user_id lookup
CREATE INDEX IF NOT EXISTS idx_notification_settings_user_id ON notification_settings (user_id);

-- 3. System Settings Table
CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20) NOT NULL DEFAULT '2024-2025',
    time_zone VARCHAR(100) NOT NULL DEFAULT 'Asia/Kolkata',
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    date_format VARCHAR(20) NOT NULL DEFAULT 'DD/MM/YYYY',
    organization_name VARCHAR(255),
    organization_logo VARCHAR(500),
    organization_email VARCHAR(255),
    organization_phone VARCHAR(20),
    max_login_attempts INTEGER DEFAULT 5,
    session_timeout_minutes INTEGER DEFAULT 30,
    enable_2fa BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Audit Logs Table (for tracking user activities)
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    action VARCHAR(255) NOT NULL,
    table_name VARCHAR(100),
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
);

-- Index for user_id and created_at in audit logs
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs (user_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs (created_at);

-- 5. User Sessions Table (for tracking active sessions)
CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(50),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Index for user_id and token_hash
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions (user_id);

CREATE INDEX IF NOT EXISTS idx_user_sessions_token_hash ON user_sessions (token_hash);

-- Insert default system settings
INSERT INTO
    system_settings (
        academic_year,
        time_zone,
        currency,
        date_format,
        organization_name
    )
VALUES (
        '2024-2025',
        'Asia/Kolkata',
        'INR',
        'DD/MM/YYYY',
        'Your School Name'
    )
ON CONFLICT DO NOTHING;

-- SaaS-based Lead CRM Database Schema
-- Multi-tenant system with school_id isolation
-- Production-ready, scalable, 3NF normalized

-- Drop existing tables if they exist (CAUTION: Use with care in production)
DROP TABLE IF EXISTS lead_application_map CASCADE;

DROP TABLE IF EXISTS application CASCADE;

DROP TABLE IF EXISTS applications CASCADE;

DROP TABLE IF EXISTS lead_note CASCADE;

DROP TABLE IF EXISTS lead_tag CASCADE;

DROP TABLE IF EXISTS tag CASCADE;

DROP TABLE IF EXISTS inactivity_alert CASCADE;

DROP TABLE IF EXISTS lead_activity CASCADE;

DROP TABLE IF EXISTS communication_log CASCADE;

DROP TABLE IF EXISTS lead_assignment CASCADE;

DROP TABLE IF EXISTS "user" CASCADE;

DROP TABLE IF EXISTS follow_up_history CASCADE;

DROP TABLE IF EXISTS follow_up CASCADE;

DROP TABLE IF EXISTS lead_pipeline CASCADE;

DROP TABLE IF EXISTS pipeline_stage CASCADE;

DROP TABLE IF EXISTS lead_source CASCADE;

DROP TABLE IF EXISTS academic_year CASCADE;

DROP TABLE IF EXISTS school CASCADE;

DROP TABLE IF EXISTS lead CASCADE;

DROP TABLE IF EXISTS parents CASCADE;

-- Core multi-tenancy table: School
CREATE TABLE school (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    subscription_plan VARCHAR(50) DEFAULT 'basic',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Academic Year table (per school)
CREATE TABLE academic_year (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    year VARCHAR(20) NOT NULL, -- e.g., '2023-2024'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (school_id, year)
);

-- Lead Source normalization (per school)
CREATE TABLE lead_source (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (school_id, name)
);

-- CRITICAL: Lead table (DO NOT MODIFY - as per requirements)
CREATE TABLE lead(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    academic_year_id BIGINT NOT NULL REFERENCES academic_year (id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    desired_class VARCHAR(100),
    source VARCHAR(100),
    follow_up_status VARCHAR(50) DEFAULT 'pending' CHECK (
        follow_up_status IN (
            'pending',
            'contacted',
            'interested',
            'not-interested',
            'converted',
            'lost'
        )
    ),
    notes TEXT,
    metadata JSONB,
    inactivity_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_to VARCHAR(100),
    last_contacted_at TIMESTAMP,
    created_by VARCHAR(100)
);

-- User table for authentication and assignment
CREATE TABLE "user" (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (
        role IN (
            'admin',
            'manager',
            'agent',
            'viewer'
        )
    ),
    is_active BOOLEAN DEFAULT TRUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (school_id, username),
    UNIQUE (school_id, email)
);

-- Pipeline Management: Dynamic stages per school
CREATE TABLE pipeline_stage (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    order_position INTEGER NOT NULL,
    color VARCHAR(7), -- hex color
    is_active BOOLEAN DEFAULT TRUE,
    created_by BIGINT REFERENCES "user" (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (school_id, name),
    UNIQUE (school_id, order_position)
);

-- Lead Pipeline: Link leads to stages
CREATE TABLE lead_pipeline (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    stage_id BIGINT NOT NULL REFERENCES pipeline_stage (id) ON DELETE CASCADE,
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    exited_at TIMESTAMP,
    current_stage BOOLEAN DEFAULT TRUE,
    entered_by BIGINT REFERENCES "user" (id),
    exited_by BIGINT REFERENCES "user" (id),
    UNIQUE (lead_id, current_stage) -- only one current stage per lead
);

-- Follow-Up System
CREATE TABLE follow_up (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    scheduled_at TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (
        status IN (
            'pending',
            'completed',
            'cancelled',
            'overdue'
        )
    ),
    type VARCHAR(50) CHECK (
        type IN (
            'call',
            'email',
            'meeting',
            'visit',
            'whatsapp'
        )
    ),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (
        priority IN (
            'low',
            'medium',
            'high',
            'urgent'
        )
    ),
    subject VARCHAR(255),
    notes TEXT,
    outcome TEXT,
    created_by BIGINT REFERENCES "user" (id),
    assigned_to BIGINT REFERENCES "user" (id),
    completed_at TIMESTAMP,
    completed_by BIGINT REFERENCES "user" (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Follow-Up History (Audit log)
CREATE TABLE follow_up_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    follow_up_id BIGINT NOT NULL REFERENCES follow_up (id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL, -- 'created', 'updated', 'completed', 'cancelled'
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    changed_by BIGINT REFERENCES "user" (id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lead Assignment
CREATE TABLE lead_assignment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES "user" (id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT REFERENCES "user" (id),
    unassigned_at TIMESTAMP,
    unassigned_by BIGINT REFERENCES "user" (id),
    notes TEXT,
    UNIQUE (lead_id, user_id, assigned_at) -- prevent duplicate assignments at same time
);

-- Communication Tracking
CREATE TABLE communication_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (
        type IN (
            'call',
            'email',
            'whatsapp',
            'sms',
            'meeting'
        )
    ),
    direction VARCHAR(20) NOT NULL CHECK (
        direction IN ('inbound', 'outbound')
    ),
    subject VARCHAR(255),
    message TEXT,
    duration_minutes INTEGER, -- for calls
    status VARCHAR(50) CHECK (
        status IN (
            'sent',
            'delivered',
            'read',
            'answered',
            'missed',
            'failed'
        )
    ),
    user_id BIGINT REFERENCES "user" (id), -- who made the communication
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- additional data like email_id, call_sid, etc.
);

-- Lead CRM activity details for dashboard overview
CREATE TABLE calls (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES "user" (id),
    call_type VARCHAR(50) NOT NULL CHECK (
        call_type IN ('inbound', 'outbound')
    ),
    duration_seconds INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE emails (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES "user" (id),
    subject VARCHAR(255),
    body TEXT,
    status VARCHAR(50) DEFAULT 'sent' CHECK (
        status IN (
            'sent',
            'delivered',
            'read',
            'failed'
        )
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tours (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES "user" (id),
    tour_date TIMESTAMP NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'scheduled' CHECK (
        status IN (
            'scheduled',
            'completed',
            'cancelled'
        )
    ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity Timeline
CREATE TABLE lead_activity (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL, -- 'created', 'updated', 'assigned', 'followed_up', 'communicated', 'converted'
    description TEXT NOT NULL,
    metadata JSONB,
    created_by BIGINT REFERENCES "user" (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inactivity Tracking
CREATE TABLE inactivity_alert (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    alert_type VARCHAR(50) NOT NULL CHECK (
        alert_type IN (
            'no_contact',
            'overdue_followup',
            'stale_lead'
        )
    ),
    alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    days_inactive INTEGER NOT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMP,
    resolved_by BIGINT REFERENCES "user" (id),
    notes TEXT
);

-- Tags System
CREATE TABLE tag (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7), -- hex color
    description TEXT,
    created_by BIGINT REFERENCES "user" (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (school_id, name)
);

-- Lead Tags (Many-to-Many)
CREATE TABLE lead_tag (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    tag_id BIGINT NOT NULL REFERENCES tag (id) ON DELETE CASCADE,
    tagged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tagged_by BIGINT REFERENCES "user" (id),
    UNIQUE (lead_id, tag_id)
);

-- Notes System
CREATE TABLE lead_note (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    is_private BOOLEAN DEFAULT FALSE,
    created_by BIGINT REFERENCES "user" (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversion System
-- Assuming application table exists (for admissions/applications)
CREATE TABLE application (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    academic_year_id BIGINT NOT NULL REFERENCES academic_year (id) ON DELETE CASCADE,
    application_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (
        status IN (
            'pending',
            'under_review',
            'approved',
            'rejected',
            'withdrawn'
        )
    ),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by BIGINT REFERENCES "user" (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lead Application Mapping
CREATE TABLE lead_application_map (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    application_id BIGINT NOT NULL REFERENCES application (id) ON DELETE CASCADE,
    converted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    conversion_type VARCHAR(50) DEFAULT 'admission',
    notes TEXT,
    converted_by BIGINT REFERENCES "user" (id),
    UNIQUE (lead_id, application_id)
);

-- Indexes for Performance
-- School-based isolation indexes
CREATE INDEX idx_school_active ON school (is_active);

CREATE INDEX idx_academic_year_school_active ON academic_year (school_id, is_active);

CREATE INDEX idx_lead_source_school_active ON lead_source (school_id, is_active);

-- Lead table indexes
CREATE INDEX idx_lead_school_status ON lead(school_id, follow_up_status);

CREATE INDEX idx_lead_school_created ON lead(school_id, created_at);

CREATE INDEX idx_lead_school_updated ON lead(school_id, updated_at);

CREATE INDEX idx_lead_school_academic_year ON lead(school_id, academic_year_id);

CREATE INDEX idx_lead_phone ON lead(phone);

CREATE INDEX idx_lead_email ON lead(email);

CREATE INDEX idx_lead_last_contacted ON lead(last_contacted_at);

-- User indexes
CREATE INDEX idx_user_school_role ON "user" (school_id, role);

CREATE INDEX idx_user_school_active ON "user" (school_id, is_active);

CREATE INDEX idx_user_email ON "user" (email);

-- Pipeline indexes
CREATE INDEX idx_pipeline_stage_school_order ON pipeline_stage (school_id, order_position);

CREATE INDEX idx_lead_pipeline_lead_current ON lead_pipeline (lead_id, current_stage);

CREATE INDEX idx_lead_pipeline_stage ON lead_pipeline (stage_id);

-- Follow-up indexes
CREATE INDEX idx_follow_up_school_lead ON follow_up (school_id, lead_id);

CREATE INDEX idx_follow_up_scheduled ON follow_up (scheduled_at);

CREATE INDEX idx_follow_up_status ON follow_up (status);

CREATE INDEX idx_follow_up_assigned ON follow_up (assigned_to);

-- Assignment indexes
CREATE INDEX idx_lead_assignment_lead ON lead_assignment (lead_id);

CREATE INDEX idx_lead_assignment_user ON lead_assignment (user_id);

CREATE INDEX idx_lead_assignment_school ON lead_assignment (school_id);

-- Communication indexes
CREATE INDEX idx_communication_log_lead ON communication_log (lead_id);

CREATE INDEX idx_communication_log_type ON communication_log(type);

CREATE INDEX idx_communication_log_timestamp ON communication_log (timestamp);

-- Dashboard overview indexes
CREATE INDEX idx_calls_lead_created_at ON calls (lead_id, created_at);

CREATE INDEX idx_emails_lead_created_at ON emails (lead_id, created_at);

CREATE INDEX idx_tours_lead_created_at ON tours (lead_id, created_at);

CREATE INDEX idx_tours_tour_date ON tours (tour_date);

-- Activity indexes
CREATE INDEX idx_lead_activity_lead ON lead_activity (lead_id);

CREATE INDEX idx_lead_activity_type ON lead_activity (activity_type);

CREATE INDEX idx_lead_activity_created ON lead_activity (created_at);

-- Inactivity indexes
CREATE INDEX idx_inactivity_alert_lead ON inactivity_alert (lead_id);

CREATE INDEX idx_inactivity_alert_resolved ON inactivity_alert (resolved);

-- Tag indexes
CREATE INDEX idx_tag_school ON tag (school_id);

CREATE INDEX idx_lead_tag_lead ON lead_tag (lead_id);

CREATE INDEX idx_lead_tag_tag ON lead_tag (tag_id);

-- Note indexes
CREATE INDEX idx_lead_note_lead ON lead_note (lead_id);

CREATE INDEX idx_lead_note_created ON lead_note (created_at);

-- Application indexes
CREATE INDEX idx_application_school_status ON application (school_id, status);

CREATE INDEX idx_application_lead ON application (lead_id);

-- Conversion indexes
CREATE INDEX idx_lead_application_map_lead ON lead_application_map (lead_id);

CREATE INDEX idx_lead_application_map_application ON lead_application_map (application_id);

-- Communications table for Compose Message system
CREATE TABLE communications (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    school_id BIGINT NOT NULL REFERENCES school (id) ON DELETE CASCADE,
    lead_id BIGINT NOT NULL REFERENCES lead(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('email', 'sms', 'whatsapp')
    ),
    subject VARCHAR(255), -- nullable, only for email
    message TEXT NOT NULL,
    phone_number VARCHAR(20), -- nullable, for sms/whatsapp
    status VARCHAR(20) DEFAULT 'draft' CHECK (
        status IN (
            'draft',
            'sent',
            'delivered',
            'read',
            'failed'
        )
    ),
    sender_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Communications indexes
CREATE INDEX idx_comm_school ON communications (school_id);

CREATE INDEX idx_comm_type ON communications(type);

CREATE INDEX idx_comm_status ON communications (status);

CREATE INDEX idx_comm_lead ON communications (lead_id);

CREATE INDEX idx_comm_created_at ON communications (created_at);

-- Sample Data Insertion
-- Insert sample school
INSERT INTO
    school (
        name,
        domain,
        address,
        phone,
        email
    )
VALUES (
        'Demo School',
        'demo.school.com',
        '123 Education St, City, State',
        '+1-555-0123',
        'admin@demo.school.com'
    );

-- Insert sample academic year
INSERT INTO
    academic_year (
        school_id,
        year,
        start_date,
        end_date
    )
VALUES (
        1,
        '2024-2025',
        '2024-08-01',
        '2025-07-31'
    );

-- Insert sample lead sources
INSERT INTO
    lead_source (school_id, name, description)
VALUES (
        1,
        'Website',
        'Leads from school website'
    ),
    (
        1,
        'Referral',
        'Referred by existing parents'
    ),
    (
        1,
        'Social Media',
        'Facebook, Instagram campaigns'
    ),
    (
        1,
        'Walk-in',
        'Direct visitors to school'
    );

-- Insert sample pipeline stages
INSERT INTO
    pipeline_stage (
        school_id,
        name,
        description,
        order_position,
        color
    )
VALUES (
        1,
        'New Lead',
        'Freshly acquired leads',
        1,
        '#FF6B6B'
    ),
    (
        1,
        'Contacted',
        'Initial contact made',
        2,
        '#4ECDC4'
    ),
    (
        1,
        'Interested',
        'Shown interest in admission',
        3,
        '#45B7D1'
    ),
    (
        1,
        'Application Submitted',
        'Application form submitted',
        4,
        '#96CEB4'
    ),
    (
        1,
        'Admitted',
        'Successfully admitted',
        5,
        '#FECA57'
    );

-- Insert sample user (password: demo123 - hashed)
INSERT INTO
    "user" (
        school_id,
        username,
        email,
        password_hash,
        role,
        first_name,
        last_name
    )
VALUES (
        1,
        'admin',
        'admin@demo.school.com',
        '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'admin',
        'School',
        'Admin'
    );

-- Insert sample lead
INSERT INTO
    lead(
        school_id,
        academic_year_id,
        first_name,
        last_name,
        email,
        phone,
        desired_class,
        source,
        follow_up_status
    )
VALUES (
        1,
        1,
        'John',
        'Doe',
        'john.doe@email.com',
        '+1-555-0199',
        'Grade 1',
        'Website',
        'pending'
    );

-- Insert sample lead pipeline
INSERT INTO
    lead_pipeline (
        school_id,
        lead_id,
        stage_id,
        current_stage
    )
VALUES (1, 1, 1, TRUE);

-- Insert sample follow-up
INSERT INTO follow_up (school_id, lead_id, scheduled_at, type, subject, created_by) VALUES
(1, 1, CURRENT_TIMESTAMP + INTERVAL '1 day', 'call', 'Initial contact call', 1);

-- SaaS-based Lead CRM Database Initialization
-- Multi-tenant system with school_id isolation

-- Create database if it does not exist
DO
$$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'school_erp') THEN
    CREATE DATABASE school_erp;
  END IF;
END
$$;

\c school_erp;

-- Run the main schema
\i schema.sql;

-- Optional sample data for initial development
INSERT INTO
    school (name, domain, phone, email)
VALUES (
        'Demo School',
        'demoschool.edu',
        '+1-555-0000',
        'info@demoschool.edu'
    )
ON CONFLICT (domain) DO NOTHING;

INSERT INTO
    academic_year (
        school_id,
        year,
        start_date,
        end_date
    )
SELECT id, '2025-2026', '2025-06-01', '2026-05-31'
FROM school
WHERE
    domain = 'demoschool.edu'
ON CONFLICT (school_id, year) DO NOTHING;

INSERT INTO
    "user" (
        school_id,
        username,
        email,
        password_hash,
        role,
        first_name,
        last_name
    )
SELECT s.id, 'admin', 'admin@demoschool.edu', 'PASSWORD_HASH_PLACEHOLDER', 'admin', 'Admin', 'User'
FROM school s
WHERE
    s.domain = 'demoschool.edu'
ON CONFLICT (school_id, username) DO NOTHING;

-- Grant permissions (optional - adjust as needed)
-- GRANT ALL PRIVILEGES ON DATABASE school_erp TO postgres;

-- Bulk Upload Leads table schema
-- Simple table for bulk lead imports

-- Create bulk upload LEADS table
CREATE TABLE IF NOT EXISTS bulk_leads (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    source VARCHAR(100),
    course_interest VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_bulk_leads_email ON bulk_leads (email);

CREATE INDEX IF NOT EXISTS idx_bulk_leads_source ON bulk_leads (source);

CREATE INDEX IF NOT EXISTS idx_bulk_leads_created_at ON bulk_leads (created_at);

-- ============================================================================
-- Communication Module Database Migration
-- Multi-Tenant SaaS Backend for School Lead CRM
-- ============================================================================
-- IMPORTANT: Every table includes school_id for multi-tenant data isolation
-- CRITICAL: All queries MUST filter by school_id to prevent data leakage
-- ============================================================================

BEGIN TRANSACTION;

-- ============================================================================
-- 1. CREATE COMMUNICATIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS communications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    school_id BIGINT NOT NULL,
    lead_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (
        type IN (
            'email',
            'sms',
            'whatsapp',
            'call'
        )
    ),
    message TEXT,
    subject VARCHAR(255),
    phone_number VARCHAR(20),
    status VARCHAR(50) NOT NULL DEFAULT 'sent' CHECK (
        status IN (
            'draft',
            'sent',
            'delivered',
            'read',
            'failed',
            'pending'
        )
    ),
    sender_name VARCHAR(255),
    recipient VARCHAR(100),
    direction VARCHAR(50) NOT NULL DEFAULT 'outbound' CHECK (
        direction IN ('inbound', 'outbound')
    ),
    duration INTEGER COMMENT 'Duration in seconds for calls',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_communications_school FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
    CONSTRAINT fk_communications_lead FOREIGN KEY (lead_id) REFERENCES lead(id) ON DELETE CASCADE
);

-- ============================================================================
-- 2. CREATE ACTIVITIES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    school_id BIGINT NOT NULL,
    lead_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (
        type IN (
            'call',
            'email',
            'tour',
            'meeting',
            'visit'
        )
    ),
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (
        status IN (
            'completed',
            'pending',
            'cancelled'
        )
    ),
    duration INTEGER COMMENT 'Duration in minutes',
    icon VARCHAR(50),
    action VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_activities_school FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
    CONSTRAINT fk_activities_lead FOREIGN KEY (lead_id) REFERENCES lead(id) ON DELETE CASCADE
);

-- ============================================================================
-- 3. CREATE INDEXES FOR OPTIMAL PERFORMANCE
-- CRITICAL: Indexes enable fast filtering by school_id
-- ============================================================================

-- Communications Indexes
CREATE INDEX IF NOT EXISTS idx_comm_school ON communications (school_id);

CREATE INDEX IF NOT EXISTS idx_comm_school_type ON communications(school_id, type);

CREATE INDEX IF NOT EXISTS idx_comm_school_created ON communications (school_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comm_lead_school ON communications (lead_id, school_id);

CREATE INDEX IF NOT EXISTS idx_comm_created ON communications (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comm_status ON communications (status);

CREATE INDEX IF NOT EXISTS idx_comm_type ON communications(type);

CREATE INDEX IF NOT EXISTS idx_comm_direction ON communications (direction);

-- Activities Indexes
CREATE INDEX IF NOT EXISTS idx_act_school ON activities (school_id);

CREATE INDEX IF NOT EXISTS idx_act_school_type ON activities(school_id, type);

CREATE INDEX IF NOT EXISTS idx_act_school_created ON activities (school_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_act_lead_school ON activities (lead_id, school_id);

CREATE INDEX IF NOT EXISTS idx_act_created ON activities (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_act_status ON activities (status);

CREATE INDEX IF NOT EXISTS idx_act_type ON activities(type);

-- ============================================================================
-- 4. ADD school_id TO LEADS TABLE (if not already present)
-- ============================================================================
DO $$ 
BEGIN
  IF NOT EXISTS(SELECT 1 FROM information_schema.columns 
                WHERE table_name='lead' AND column_name='school_id') THEN
    ALTER TABLE lead ADD COLUMN school_id BIGINT;
    CREATE INDEX idx_leads_school ON lead(school_id);
  END IF;
END $$;

-- ============================================================================
-- 5. SAMPLE DATA (for testing - remove in production)
-- ============================================================================
-- Uncomment to populate test data
/*
INSERT INTO communications (school_id, lead_id, type, message, status, sender_name, direction)
VALUES 
(1, 1, 'email', 'Welcome to our school!', 'delivered', 'Admin', 'outbound'),
(1, 2, 'sms', 'Your application is under review', 'sent', 'Admin', 'outbound'),
(1, 3, 'whatsapp', 'Please confirm your visit schedule', 'pending', 'Admin', 'outbound');

INSERT INTO activities (school_id, lead_id, type, status, notes, duration)
VALUES 
(1, 1, 'call', 'completed', 'Discussed admission process', 15),
(1, 2, 'tour', 'pending', 'Campus tour scheduled', 60),
(1, 3, 'meeting', 'completed', 'Parent meeting', 30);
*/

-- ============================================================================
-- 6. GRANT PERMISSIONS
-- ============================================================================
-- Adjust based on your database user setup
-- GRANT SELECT, INSERT, UPDATE, DELETE ON communications TO app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON activities TO app_user;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (run after migration)
-- ============================================================================
/*
-- Check table structure
\d communications
\d activities

-- Check indexes
\di idx_comm_*
\di idx_act_*

-- Verify school_id filtering
SELECT COUNT(*) FROM communications WHERE school_id = 1;
SELECT COUNT(*) FROM activities WHERE school_id = 1;
*/