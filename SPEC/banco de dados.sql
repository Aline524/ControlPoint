-- =============================================================================
-- SCHEMA DDL - SISTEMA DE CONTROLE DE PONTO ELETRÔNICO (SUPABASE / POSTGRESQL)
-- =============================================================================

-- 1. Tabela de Funcionários (Employees)
CREATE TABLE IF NOT EXISTS public.employees (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    pis VARCHAR(20) UNIQUE NOT NULL,
    cpf VARCHAR(20) UNIQUE NOT NULL,
    pin VARCHAR(10),
    rfid VARCHAR(50),
    company_name VARCHAR(255) DEFAULT 'Empresa Demo Tecnologia LTDA',
    cnpj VARCHAR(20) DEFAULT '12.345.678/0001-90',
    address TEXT DEFAULT 'Av. Paulista, 1000 - São Paulo/SP',
    cargo VARCHAR(100),
    turno VARCHAR(100) DEFAULT '08:00 - 17:00',
    shift_start VARCHAR(5) DEFAULT '08:00',
    shift_end VARCHAR(5) DEFAULT '17:00',
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Registros de Ponto (Punches) - Imutável (RN-03)
CREATE TABLE IF NOT EXISTS public.punches (
    id VARCHAR(100) PRIMARY KEY,
    employee_id VARCHAR(50) NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
    event_type VARCHAR(20) NOT NULL CHECK (event_type IN ('ENTRADA', 'SAIDA_INTERVALO', 'RETORNO_INTERVALO', 'SAIDA')),
    timestamp_utc TIMESTAMPTZ NOT NULL,
    photo_base64 TEXT,
    auth_method VARCHAR(50) NOT NULL,
    justification TEXT,
    synced_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Índices para otimização de consultas por funcionário e data/hora
CREATE INDEX IF NOT EXISTS idx_punches_employee_id ON public.punches(employee_id);
CREATE INDEX IF NOT EXISTS idx_punches_timestamp ON public.punches(timestamp_utc);

-- 3. Tabela de Inconsistências (Inconsistencies - RF-04 / RN-04)
CREATE TABLE IF NOT EXISTS public.inconsistencies (
    id VARCHAR(100) PRIMARY KEY,
    employee_id VARCHAR(50) NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- Ex: 'DIVERGENCIA_HORARIO', 'FALTA_INJUSTIFICADA'
    description TEXT NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_inconsistencies_employee_date ON public.inconsistencies(employee_id, date);

-- 4. Tabela de Atestados e Abonos (RF-07)
CREATE TABLE IF NOT EXISTS public.atestados (
    id VARCHAR(100) PRIMARY KEY,
    employee_id VARCHAR(50) NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    motivo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_atestados_employee_date ON public.atestados(employee_id, date);

-- =============================================================================
-- SEED DATA (INSERÇÃO DE DADOS DEMO)
-- =============================================================================

INSERT INTO public.employees (id, name, pis, cpf, pin, rfid, cargo, email)
VALUES 
    ('emp-001', 'Carlos Silva', '12345678901', '111.222.333-44', '1234', 'RFID-1001', 'Desenvolvedor Senior', 'carlos.silva@empresa.com.br'),
    ('emp-002', 'Ana Souza', '98765432109', '555.666.777-88', '5678', 'RFID-1002', 'Analista de RH', 'ana.souza@empresa.com.br')
ON CONFLICT (id) DO NOTHING;
