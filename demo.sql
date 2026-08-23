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