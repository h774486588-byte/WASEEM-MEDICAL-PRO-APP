-- WASEEM MEDICAL PRO - PostgreSQL foundation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(150) NOT NULL,
  phone VARCHAR(30),
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  name VARCHAR(150) NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role VARCHAR(30) NOT NULL DEFAULT 'reception',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  file_no VARCHAR(30) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  national_id VARCHAR(80),
  birth_date DATE,
  gender VARCHAR(20),
  department VARCHAR(150),
  service VARCHAR(200),
  doctor VARCHAR(200),
  alternate_phone VARCHAR(40),
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor VARCHAR(200),
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'confirmed',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS packages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  price NUMERIC(14,2) NOT NULL DEFAULT 0,
  paid NUMERIC(14,2) NOT NULL DEFAULT 0,
  sessions_count INTEGER NOT NULL DEFAULT 0,
  remaining_sessions INTEGER NOT NULL DEFAULT 0,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  package_id UUID REFERENCES packages(id) ON DELETE SET NULL,
  therapist VARCHAR(200),
  session_date DATE NOT NULL,
  session_time TIME,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  invoice_no VARCHAR(50) UNIQUE NOT NULL,
  total NUMERIC(14,2) NOT NULL DEFAULT 0,
  paid NUMERIC(14,2) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'partial',
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  amount NUMERIC(14,2) NOT NULL,
  method VARCHAR(30) NOT NULL DEFAULT 'cash',
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes TEXT
);

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,
  channel VARCHAR(30) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  recipient VARCHAR(100),
  message TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'queued',
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  entity VARCHAR(100),
  entity_id UUID,
  details JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(status);


-- PRODUCTION EXTENSIONS
CREATE TABLE IF NOT EXISTS clinic_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), branch_id UUID UNIQUE REFERENCES branches(id) ON DELETE CASCADE,
  clinic_name VARCHAR(200) NOT NULL, logo_url TEXT, currency VARCHAR(20) DEFAULT 'YER', phone VARCHAR(40), address TEXT,
  whatsapp_enabled BOOLEAN NOT NULL DEFAULT FALSE, sms_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS roles_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), role VARCHAR(30) NOT NULL, permission VARCHAR(100) NOT NULL,
  allowed BOOLEAN NOT NULL DEFAULT TRUE, UNIQUE(role, permission)
);
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL, category VARCHAR(150), price NUMERIC(14,2) NOT NULL DEFAULT 0,
  duration_minutes INTEGER, is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(branch_id,name)
);
CREATE TABLE IF NOT EXISTS invoice_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL, description VARCHAR(300) NOT NULL,
  quantity NUMERIC(12,2) NOT NULL DEFAULT 1, unit_price NUMERIC(14,2) NOT NULL DEFAULT 0,
  total NUMERIC(14,2) NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  category VARCHAR(100) NOT NULL, description TEXT, amount NUMERIC(14,2) NOT NULL,
  payment_method VARCHAR(30) NOT NULL DEFAULT 'cash', expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS message_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
  event_type VARCHAR(60) NOT NULL, channel VARCHAR(20) NOT NULL, title VARCHAR(200), body TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(branch_id,event_type,channel)
);
CREATE TABLE IF NOT EXISTS notification_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
  provider VARCHAR(80), attempt_no INTEGER NOT NULL DEFAULT 1, status VARCHAR(30) NOT NULL,
  provider_message_id VARCHAR(200), error_message TEXT, attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS backups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  backup_type VARCHAR(30) NOT NULL, storage_location TEXT, status VARCHAR(30) NOT NULL,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sessions_patient_date ON sessions(patient_id,session_date);
CREATE INDEX IF NOT EXISTS idx_packages_patient ON packages(patient_id);
CREATE INDEX IF NOT EXISTS idx_invoices_patient ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments(invoice_id);
CREATE INDEX IF NOT EXISTS idx_notifications_patient ON notifications(patient_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);
