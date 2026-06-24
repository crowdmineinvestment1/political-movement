-- Create targets table
CREATE TABLE IF NOT EXISTS public.targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    zip TEXT,
    ip TEXT,
    user_agent TEXT,
    screen_resolution TEXT,
    platform TEXT,
    language TEXT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    activated_at TIMESTAMP WITH TIME ZONE
);

-- Create tracking_logs table
CREATE TABLE IF NOT EXISTS public.tracking_logs (
    id BIGSERIAL PRIMARY KEY,
    email TEXT,
    action TEXT NOT NULL,
    details JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Create surveillance_logs table
CREATE TABLE IF NOT EXISTS public.surveillance_logs (
    id BIGSERIAL PRIMARY KEY,
    target_id UUID REFERENCES public.targets(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    details JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Create surveillance_payloads table
CREATE TABLE IF NOT EXISTS public.surveillance_payloads (
    id BIGSERIAL PRIMARY KEY,
    target_email TEXT NOT NULL,
    payload TEXT,
    deployed BOOLEAN DEFAULT false,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracking_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surveillance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surveillance_payloads ENABLE ROW LEVEL SECURITY;

-- Create policies to allow anonymous insert, select, and update for tracking simulation
CREATE POLICY "Allow anonymous insert on targets" ON public.targets 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on targets" ON public.targets 
    FOR SELECT USING (true);

CREATE POLICY "Allow anonymous update on targets" ON public.targets 
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow anonymous insert on tracking_logs" ON public.tracking_logs 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on tracking_logs" ON public.tracking_logs 
    FOR SELECT USING (true);

CREATE POLICY "Allow anonymous insert on surveillance_logs" ON public.surveillance_logs 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on surveillance_logs" ON public.surveillance_logs 
    FOR SELECT USING (true);

CREATE POLICY "Allow anonymous insert on surveillance_payloads" ON public.surveillance_payloads 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous select on surveillance_payloads" ON public.surveillance_payloads 
    FOR SELECT USING (true);
