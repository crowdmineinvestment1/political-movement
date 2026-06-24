-- Security Monitoring & Penetration Testing Platform Schema
-- Designed for authorized security testing and defensive monitoring

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Core Assets/Targets Table
CREATE TABLE IF NOT EXISTS public.assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hostname TEXT,
    ip_address INET,
    mac_address MACADDR,
    asset_type TEXT CHECK (asset_type IN ('workstation', 'server', 'mobile_device', 'network_device', 'iot_device', 'application')),
    operating_system TEXT,
    os_version TEXT,
    owner TEXT,
    department TEXT,
    criticality_level INTEGER CHECK (criticality_level >= 1 AND criticality_level <= 5),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'decommissioned', 'quarantined')),
    tags TEXT[], -- Array of tags for categorization
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Security Events / Findings Table
CREATE TABLE IF NOT EXISTS public.security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'vulnerability', 'misconfiguration', 'malware_detected', 'suspicious_process',
        'failed_login', 'privilege_escalation', 'lateral_movement', 'data_exfiltration',
        'network_anomaly', 'policy_violation', 'authentication_event', 'file_integrity_change',
        'web_vulnerability', 'api_security_issue', 'container_vulnerability'
    )),
    severity TEXT NOT NULL CHECK (severity IN ('info', 'low', 'medium', 'high', 'critical')),
    confidence INTEGER CHECK (confidence >= 0 AND confidence <= 100),
    title TEXT NOT NULL,
    description TEXT,
    evidence JSONB, -- Structured evidence data
    remediation TEXT,
    cve_ids TEXT[], -- Array of related CVE identifiers
    cvss_score DECIMAL(3,1),
    false_positive BOOLEAN DEFAULT FALSE,
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by TEXT,
    tags TEXT[]
);

-- Network Traffic Analysis Table
CREATE TABLE IF NOT EXISTS public.network_traffic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_ip INET,
    destination_ip INET,
    source_port INTEGER,
    destination_port INTEGER,
    protocol TEXT,
    method TEXT, -- HTTP method
    hostname TEXT,
    url TEXT,
    user_agent TEXT,
    referer TEXT,
    status_code INTEGER,
    response_time_ms INTEGER,
    request_size_bytes BIGINT,
    response_size_bytes BIGINT,
    headers JSONB,
    cookies JSONB,
    query_params JSONB,
    post_data JSONB,
    ssl_info JSONB, -- TLS/SSL certificate and connection details
    threat_indicators JSONB, -- Detected threats/SIEM correlations
    is_malicious BOOLEAN DEFAULT FALSE,
    malware_family TEXT,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- User Behavior Analytics (Privacy-Focused)
CREATE TABLE IF NOT EXISTS public.user_behavior (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID, -- Anonymous session identifier
    page_url TEXT,
    element_interacted TEXT,
    interaction_type TEXT CHECK (interaction_type IN ('click', 'input', 'scroll', 'hover', 'keypress', 'submit')),
    input_type TEXT, -- For form fields: text, password, email, etc.
    input_length INTEGER, -- Length of input (not the actual content for privacy)
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    user_agent TEXT,
    screen_resolution TEXT,
    viewport_size TEXT,
    referrer TEXT,
    ip_hash TEXT, -- Hashed IP for basic geolocation without storing actual IP
    consent_given BOOLEAN DEFAULT FALSE,
    data_retention_expires TIMESTAMP WITH TIME ZONE
);

-- Application Inventory & Security Posture
CREATE TABLE IF NOT EXISTS public.asset_software (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE CASCADE,
    software_name TEXT NOT NULL,
    version TEXT,
    vendor TEXT,
    install_date TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE,
    is_authorized BOOLEAN DEFAULT TRUE,
    license_key_hash TEXT, -- Hashed license key for compliance tracking
    vulnerability_count INTEGER DEFAULT 0,
    last_vulnerability_scan TIMESTAMP WITH TIME ZONE,
    tags TEXT[],
    UNIQUE(asset_id, software_name, version)
);

-- System Configuration & Compliance
CREATE TABLE IF NOT EXISTS public.system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE CASCADE,
    config_type TEXT NOT NULL CHECK (config_type IN (
        'os_settings', 'firewall_rules', 'antivirus_config', 'patch_level',
        'password_policy', 'account_lockout', 'audit_policy', 'services',
        'scheduled_tasks', 'startup_items', 'browser_extensions', 'firewall_logs'
    )),
    config_key TEXT,
    config_value TEXT,
    is_compliant BOOLEAN,
    compliance_standard TEXT, -- e.g., 'CIS', 'NIST', 'PCI_DSS', 'HIPAA'
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    check_interval_hours INTEGER DEFAULT 24
);

-- Vulnerability Scan Results
CREATE TABLE IF NOT EXISTS public.vulnerability_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE SET NULL,
    scan_type TEXT NOT NULL CHECK (scan_type IN ('network', 'web_app', 'database', 'host', 'container', 'code')),
    scanner_tool TEXT NOT NULL, -- e.g., 'Nessus', 'OpenVAS', 'Qualys', 'Nikto', 'ZAP'
    scan_start TIMESTAMP WITH TIME ZONE,
    scan_end TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'completed' CHECK (status IN ('running', 'completed', 'failed', 'cancelled')),
    total_hosts_scanned INTEGER,
    total_vulnerabilities_found INTEGER,
    critical_count INTEGER DEFAULT 0,
    high_count INTEGER DEFAULT 0,
    medium_count INTEGER DEFAULT 0,
    low_count INTEGER DEFAULT 0,
    info_count INTEGER DEFAULT 0,
    scan_config JSONB,
    report_url TEXT, -- Link to detailed report
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Security Incidents & Response Tracking
CREATE TABLE IF NOT EXISTS public.security_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    status TEXT NOT NULL CHECK (status IN ('open', 'investigating', 'contained', 'eradicated', 'recovered', 'closed')),
    incident_type TEXT NOT NULL CHECK (incident_type IN (
        'malware', 'phishing', 'ddos', 'insider_threat', 'data_breach',
        'unauthorized_access', 'privilege_escalation', 'ransomware', 'apt'
    )),
    affected_assets UUID[], -- Array of asset IDs
    timeline JSONB, -- Chronological events of the incident
    indicators_of_compromise JSONB,
    mitre_attack_techniques TEXT[], -- MITRE ATT&CK framework techniques
    assigned_to TEXT,
    reported_by TEXT,
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    resolved_at TIMESTAMP WITH TIME ZONE,
    lessons_learned TEXT,
    preventive_measures TEXT
);

-- Authentication & Access Monitoring
CREATE TABLE IF NOT EXISTS public.auth_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE SET NULL,
    username TEXT,
    source_ip INET,
    authentication_method TEXT, -- password, mfa, certificate, token, etc.
    success BOOLEAN,
    failure_reason TEXT,
    session_id TEXT,
    user_agent TEXT,
    login_time TIMESTAMP WITH TIME ZONE,
    logout_time TIMESTAMP WITH TIME ZONE,
    mfa_used BOOLEAN DEFAULT FALSE,
    risk_score INTEGER CHECK (risk_score >= 0 AND risk_score <= 100),
    geolocation JSONB, -- Country, city from IP
    device_fingerprint TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- File Integrity Monitoring
CREATE TABLE IF NOT EXISTS public.file_integrity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE SET NULL,
    file_path TEXT NOT NULL,
    file_hash TEXT, -- SHA-256 hash
    previous_hash TEXT,
    change_type TEXT NOT NULL CHECK (change_type IN ('created', 'modified', 'deleted', 'permissions_changed')),
    hash_algorithm TEXT DEFAULT 'SHA-256',
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    legitimate_change BOOLEAN DEFAULT FALSE,
    change_reason TEXT
);

-- Threat Intelligence Feed
CREATE TABLE IF NOT EXISTS public.threat_intelligence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    indicator_type TEXT NOT NULL CHECK (indicator_type IN (
        'ip_address', 'domain', 'url', 'file_hash', 'email_address', 'registry_key', 'mutex', 'user_agent'
    )),
    indicator_value TEXT NOT NULL,
    threat_type TEXT NOT NULL CHECK (threat_type IN (
        'malware', 'phishing', 'command_and_control', 'botnet', 'ransomware',
        'apt', 'exploit_kit', 'spyware', 'adware', 'trojan', 'worm'
    )),
    confidence INTEGER CHECK (confidence >= 0 AND confidence <= 100),
    severity TEXT NOT NULL CHECK (severity IN ('info', 'low', 'medium', 'high', 'critical')),
    source TEXT, -- Threat feed name
    reference_url TEXT,
    first_seen TIMESTAMP WITH TIME ZONE,
    last_seen TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text: now())
);

-- Compliance & Audit Tracking
CREATE TABLE IF NOT EXISTS public.compliance_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES public.assets(id) ON DELETE SET NULL,
    standard TEXT NOT NULL CHECK (standard IN ('PCI_DSS', 'HIPAA', 'GDPR', 'SOX', 'ISO_27001', 'NIST_800_53', 'SOC_2')),
    control_id TEXT, -- Specific control identifier (e.g., 'PCI_DSS_3.4')
    control_description TEXT,
    status TEXT NOT NULL CHECK (status IN ('compliant', 'non_compliant', 'partially_compliant', 'not_applicable')),
    evidence TEXT,
    remediation_plan TEXT,
    tested_by TEXT,
    tested_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    notes TEXT
);

-- Security Alerts & Notifications
CREATE TABLE IF NOT EXISTS public.security_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type TEXT NOT NULL CHECK (alert_type IN (
        'threshold_exceeded', 'anomaly_detected', 'policy_violation', 'threat_intel_match',
        'vulnerability_discovered', 'failed_auth_burst', 'privilege_escalation',
        'data_exfiltration_suspected', 'lateral_movement_detected', 'malware_detected'
    )),
    severity TEXT NOT NULL CHECK (severity IN ('info', 'low', 'medium', 'high', 'critical')),
    title TEXT NOT NULL,
    description TEXT,
    source_table TEXT, -- Which table triggered the alert
    source_record_id UUID,
    correlation_id UUID, -- For grouping related alerts
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by TEXT,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_by TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    escalated BOOLEAN DEFAULT FALSE,
    escalated_to TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text: now())
);

-- User Consent & Privacy Management
CREATE TABLE IF NOT EXISTS public.user_consent (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_identifier TEXT, -- Could be email, UUID, or other identifier (hashed for privacy)
    consent_type TEXT NOT NULL CHECK (consent_type IN (
        'monitoring', 'data_collection', 'analytics', 'screen_recording', 'keystroke_logging',
        'network_monitoring', 'application_tracking', 'location_tracking'
    )),
    scope TEXT, -- What systems/data are covered
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    granted_by TEXT, -- Who gave consent (user, guardian, admin)
    consent_document TEXT, -- Reference to consent form/record
    withdrawn BOOLEAN DEFAULT FALSE,
    withdrawn_at TIMESTAMP WITH TIME ZONE,
    withdrawn_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text: now())
);

-- API Access & Audit Log
CREATE TABLE IF NOT EXISTS public.api_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    api_endpoint TEXT,
    http_method TEXT,
    user_agent TEXT,
    ip_address INET,
    user_id TEXT, -- Could be API key, user ID, or service account
    api_key_id TEXT, -- Reference to API key used
    request_id TEXT, -- For tracing requests
    status_code INTEGER,
    response_time_ms INTEGER,
    request_size INTEGER,
    response_size INTEGER,
    request_headers JSONB,
    response_headers JSONB,
    request_body TEXT, -- Limited size for security
    response_body TEXT, -- Limited size for security
    authenticated BOOLEAN DEFAULT FALSE,
    authorized BOOLEAN DEFAULT FALSE,
    rate_limited BOOLEAN DEFAULT FALSE,
    blocked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text: now())
);

-- Enable Row Level Security (RLS) on all tables for multi-tenant scenarios
DO $$ 
DECLARE
    r record;
BEGIN
    FOR r IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', r.tablename);
    END LOOP;
END $$;

-- Create basic policies for authenticated access (adjust as needed for your security model)
DO $$ 
DECLARE
    r record;
BEGIN
    FOR r IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('
            CREATE POLICY "Allow authenticated access" ON %I 
            FOR ALL 
            USING (true)
            WITH CHECK (true);
        ', r.tablename);
    END LOOP;
END $$;

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_security_events_asset_id ON public.security_events(asset_id);
CREATE INDEX IF NOT EXISTS idx_security_events_event_type ON public.security_events(event_type);
CREATE INDEX IF NOT EXISTS idx_security_events_severity ON public.security_events(severity);
CREATE INDEX IF NOT EXISTS idx_security_events_detected_at ON public.security_events(detected_at);
CREATE INDEX IF NOT EXISTS idx_network_traffic_source_ip ON public.network_traffic(source_ip);
CREATE INDEX IF NOT EXISTS idx_network_traffic_destination_ip ON public.network_traffic(destination_ip);
CREATE INDEX IF NOT EXISTS idx_network_traffic_timestamp ON public.network_traffic(captured_at);
CREATE INDEX IF NOT EXISTS idx_network_traffic_malicious ON public.network_traffic(is_malicious);
CREATE INDEX IF NOT EXISTS idx_user_behavior_session_id ON public.user_behavior(session_id);
CREATE INDEX IF NOT EXISTS idx_user_behavior_timestamp ON public.user_behavior(timestamp);
CREATE INDEX IF NOT EXISTS idx_asset_software_asset_id ON public.asset_software(asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_software_vuln_count ON public.asset_software(vulnerability_count);
CREATE INDEX IF NOT EXISTS idx_system_config_asset_id ON public.system_config(asset_id);
CREATE INDEX IF NOT EXISTS idx_system_config_compliant ON public.system_config(is_compliant);
CREATE INDEX IF NOT EXISTS idx_vulnerability_scans_asset_id ON public.vulnerability_scans(asset_id);
CREATE INDEX IF NOT EXISTS idx_vulnerability_scans_scan_type ON public.vulnerability_scans(scan_type);
CREATE INDEX IF NOT EXISTS idx_vulnerability_scans_status ON public.vulnerability_scans(status);
CREATE INDEX IF NOT EXISTS idx_security_incidents_status ON public.security_incidents(status);
CREATE INDEX IF NOT EXISTS idx_security_incidents_type ON public.security_incidents(incident_type);
CREATE INDEX IF NOT EXISTS idx_auth_events_asset_id ON public.auth_events(asset_id);
CREATE INDEX IF NOT EXISTS @@auth_events_username ON public.auth_events(username);
CREATE INDEX IF NOT EXISTS idx_auth_events_login_time ON public.auth_events(login_time);
CREATE INDEX IF NOT EXISTS idx_file_integrity_asset_id ON public.file_integrity(asset_id);
CREATE INDEX IF NOT EXISTS idx_file_integrity_path ON public.file_integrity(file_path);
CREATE INDEX IF NOT EXISTS idx_file_integrity_detected_at ON public.file_integrity(detected_at);
CREATE INDEX IF NOT EXISTS idx_threat_intelligence_type ON public.threat_intelligence(indicator_type);
CREATE INDEX IF NOT EXISTS idx_threat_intelligence_value ON public.threat_intelligence(indicator_value);
CREATE INDEX IF NOT EXISTS idx_threat_intelligence_active ON public.threat_intelligence(is_active);
CREATE INDEX IF NOT EXISTS idx_compliance_checks_asset_id ON public.compliance_checks(asset_id);
CREATE INDEX IF NOT EXISTS idx_compliance_checks_standard ON public.compliance_checks(standard);
CREATE INDEX IF NOT EXISTS idx_compliance_checks_status ON public.compliance_checks(status);
CREATE INDEX IF NOT EXISTS idx_security_alerts_type ON public.security_alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_security_alerts_severity ON public.security_alerts(severity);
CREATE INDEX IF NOT EXISTS idx_security_alerts_created_at ON public.security_alerts(created_at);
CREATE INDEX IF NOT EXISTS idx_user_consent_identifier ON public.user_consent(user_identifier);
CREATE INDEX IF NOT EXISTS idx_user_consent_type ON public.user_consent(consent_type);
CREATE INDEX IF NOT EXISTS idx_user_consent_active ON public.user_consent(withdrawn);
CREATE INDEX IF NOT EXISTS idx_api_audit_endpoint ON public.api_audit_log(api_endpoint);
CREATE INDEX IF NOT EXISTS idx_api_audit_timestamp ON public.api_audit_log(created_at);
CREATE INDEX IF NOT EXISTS idx_api_audit_user_id ON public.api_audit_log(user_id);