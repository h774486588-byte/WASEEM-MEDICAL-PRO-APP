-- WASEEM MEDICAL PRO - PostgreSQL foundation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(150) NOT NULL,
  phone VARCHAR(30),
  address TEXT,
  next_patient_number INTEGER NOT NULL DEFAULT 1001,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  name VARCHAR(150) NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role VARCHAR(30) NOT NULL DEFAULT 'reception',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS personal_access_tokens (
  id BIGSERIAL PRIMARY KEY,
  tokenable_type VARCHAR(255) NOT NULL,
  tokenable_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  token VARCHAR(64) UNIQUE NOT NULL,
  abilities TEXT,
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_personal_access_tokens_tokenable ON personal_access_tokens(tokenable_type, tokenable_id);

CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  file_no VARCHAR(30) NOT NULL,
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
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(branch_id, file_no)
);

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor VARCHAR(200),
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'confirmed',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (remaining_sessions <= sessions_count)
);

CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  package_id UUID REFERENCES packages(id) ON DELETE SET NULL,
  therapist VARCHAR(200),
  session_date DATE NOT NULL,
  session_time TIME,
  status VARCHAR(30) NOT NULL DEFAULT 'attended',
  notes TEXT,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  invoice_no VARCHAR(50) UNIQUE NOT NULL,
  total NUMERIC(14,2) NOT NULL DEFAULT 0,
  paid NUMERIC(14,2) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'unpaid',
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
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
CREATE TABLE IF NOT EXISTS medical_staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
  full_name VARCHAR(200) NOT NULL,
  role VARCHAR(80) NOT NULL,
  specialty VARCHAR(150),
  phone VARCHAR(40),
  email VARCHAR(200),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_medical_staff_branch ON medical_staff(branch_id);

CREATE TABLE IF NOT EXISTS inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
  sku VARCHAR(100),
  barcode VARCHAR(150),
  name VARCHAR(200) NOT NULL,
  category VARCHAR(120),
  unit VARCHAR(40) NOT NULL DEFAULT 'piece',
  quantity NUMERIC(14,3) NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  reorder_level NUMERIC(14,3) NOT NULL DEFAULT 0 CHECK (reorder_level >= 0),
  unit_cost NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (unit_cost >= 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(branch_id, sku),
  UNIQUE(branch_id, barcode)
);
CREATE INDEX IF NOT EXISTS idx_inventory_items_name ON inventory_items(name);
CREATE INDEX IF NOT EXISTS idx_inventory_items_barcode ON inventory_items(barcode);

CREATE TABLE IF NOT EXISTS stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
  movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('opening','purchase','dispense','adjustment','return')),
  quantity NUMERIC(14,3) NOT NULL CHECK (quantity > 0),
  unit_cost NUMERIC(14,2) NOT NULL DEFAULT 0,
  reference VARCHAR(150),
  notes TEXT,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_stock_movements_item_date ON stock_movements(item_id, created_at);

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
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
