-- Location: supabase/migrations/20250914095050_agricultural_app_complete_schema.sql
-- Schema Analysis: Fresh project with no existing schema
-- Integration Type: FRESH_PROJECT - Complete agricultural farm management system
-- Dependencies: Auth system + Farm management tables

-- 1. Custom Types
CREATE TYPE public.user_role AS ENUM ('farmer', 'admin', 'consultant');
CREATE TYPE public.crop_type AS ENUM ('wheat', 'corn', 'rice', 'soybeans', 'cotton', 'vegetables', 'fruits', 'other');
CREATE TYPE public.soil_type AS ENUM ('clay', 'loam', 'sand', 'silt', 'rocky');
CREATE TYPE public.fertilizer_type AS ENUM ('nitrogen', 'phosphorus', 'potassium', 'organic', 'compound');
CREATE TYPE public.weather_condition AS ENUM ('sunny', 'cloudy', 'rainy', 'stormy', 'foggy');
CREATE TYPE public.recommendation_status AS ENUM ('pending', 'applied', 'cancelled');
CREATE TYPE public.alert_type AS ENUM ('irrigation', 'fertilizer', 'pest', 'disease', 'weather');
CREATE TYPE public.alert_priority AS ENUM ('low', 'medium', 'high', 'critical');

-- 2. Core User Tables
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role DEFAULT 'farmer'::public.user_role,
    farm_name TEXT,
    farm_location TEXT,
    total_area_acres DECIMAL(10,2),
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Farm Management Tables
CREATE TABLE public.fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    area_acres DECIMAL(8,2) NOT NULL,
    soil_type public.soil_type NOT NULL,
    crop_type public.crop_type NOT NULL,
    planting_date DATE,
    expected_harvest_date DATE,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Fertilizer Management
CREATE TABLE public.fertilizer_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_id UUID REFERENCES public.fields(id) ON DELETE CASCADE,
    farmer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    fertilizer_type public.fertilizer_type NOT NULL,
    recommended_amount DECIMAL(8,2) NOT NULL, -- in kg/acre
    application_date DATE NOT NULL,
    application_method TEXT,
    cost_estimate DECIMAL(10,2),
    status public.recommendation_status DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Weather Data
CREATE TABLE public.weather_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    temperature DECIMAL(5,2), -- in Celsius
    humidity DECIMAL(5,2), -- percentage
    rainfall DECIMAL(6,2), -- in mm
    wind_speed DECIMAL(5,2), -- in km/h
    condition public.weather_condition NOT NULL,
    recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Alerts System
CREATE TABLE public.alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    field_id UUID REFERENCES public.fields(id) ON DELETE SET NULL,
    alert_type public.alert_type NOT NULL,
    priority public.alert_priority DEFAULT 'medium',
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    action_required BOOLEAN DEFAULT false,
    due_date TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. User Settings
CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    weather_alerts BOOLEAN DEFAULT true,
    fertilizer_reminders BOOLEAN DEFAULT true,
    irrigation_alerts BOOLEAN DEFAULT true,
    preferred_units TEXT DEFAULT 'metric',
    notification_frequency TEXT DEFAULT 'daily',
    theme_preference TEXT DEFAULT 'light',
    language TEXT DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. Essential Indexes
CREATE INDEX idx_user_profiles_id ON public.user_profiles(id);
CREATE INDEX idx_fields_owner_id ON public.fields(owner_id);
CREATE INDEX idx_fertilizer_recommendations_field_id ON public.fertilizer_recommendations(field_id);
CREATE INDEX idx_fertilizer_recommendations_farmer_id ON public.fertilizer_recommendations(farmer_id);
CREATE INDEX idx_weather_data_location ON public.weather_data(location);
CREATE INDEX idx_weather_data_recorded_at ON public.weather_data(recorded_at);
CREATE INDEX idx_alerts_user_id ON public.alerts(user_id);
CREATE INDEX idx_alerts_created_at ON public.alerts(created_at);
CREATE INDEX idx_user_settings_user_id ON public.user_settings(user_id);

-- 9. Functions for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'farmer')::public.user_role
  );
  
  -- Create default settings for new user
  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$;

-- 10. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fertilizer_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weather_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- 11. RLS Policies using corrected patterns

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for other tables
CREATE POLICY "users_manage_own_fields"
ON public.fields
FOR ALL
TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

CREATE POLICY "users_manage_own_fertilizer_recommendations"
ON public.fertilizer_recommendations
FOR ALL
TO authenticated
USING (farmer_id = auth.uid())
WITH CHECK (farmer_id = auth.uid());

CREATE POLICY "users_manage_own_alerts"
ON public.alerts
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_settings"
ON public.user_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for weather data
CREATE POLICY "public_can_read_weather_data"
ON public.weather_data
FOR SELECT
TO public
USING (true);

CREATE POLICY "authenticated_users_manage_weather_data"
ON public.weather_data
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 12. Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 13. Mock Data for Testing
DO $$
DECLARE
    farmer1_id UUID := gen_random_uuid();
    farmer2_id UUID := gen_random_uuid();
    admin_id UUID := gen_random_uuid();
    field1_id UUID := gen_random_uuid();
    field2_id UUID := gen_random_uuid();
    field3_id UUID := gen_random_uuid();
BEGIN
    -- Create complete auth.users records
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (farmer1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'farmer@skyharvest.com', crypt('harvest123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Smith", "role": "farmer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (farmer2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'demo@farm.com', crypt('demo123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Maria Garcia", "role": "farmer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@skyharvest.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample fields
    INSERT INTO public.fields (id, owner_id, name, area_acres, soil_type, crop_type, planting_date, expected_harvest_date, latitude, longitude, notes)
    VALUES
        (field1_id, farmer1_id, 'North Field', 25.5, 'loam', 'corn', '2024-04-15', '2024-10-15', 40.7128, -74.0060, 'Primary corn field with good drainage'),
        (field2_id, farmer1_id, 'South Field', 18.2, 'clay', 'soybeans', '2024-05-01', '2024-11-01', 40.7130, -74.0058, 'Smaller field for rotation crops'),
        (field3_id, farmer2_id, 'West Field', 35.0, 'sand', 'wheat', '2024-03-20', '2024-08-20', 40.7125, -74.0065, 'Large wheat field near irrigation system');

    -- Create fertilizer recommendations
    INSERT INTO public.fertilizer_recommendations (field_id, farmer_id, fertilizer_type, recommended_amount, application_date, application_method, cost_estimate, status, notes)
    VALUES
        (field1_id, farmer1_id, 'nitrogen', 150.0, '2024-05-10', 'Side-dress application', 450.00, 'pending', 'Apply before tasseling stage'),
        (field2_id, farmer1_id, 'phosphorus', 80.0, '2024-05-15', 'Broadcast application', 320.00, 'applied', 'Applied during planting'),
        (field3_id, farmer2_id, 'compound', 120.0, '2024-04-01', 'Pre-plant incorporation', 380.00, 'applied', 'NPK 10-10-10 blend');

    -- Create weather data
    INSERT INTO public.weather_data (location, latitude, longitude, temperature, humidity, rainfall, wind_speed, condition, recorded_at)
    VALUES
        ('Farm Location 1', 40.7128, -74.0060, 22.5, 65.0, 2.5, 15.2, 'cloudy', NOW() - INTERVAL '1 hour'),
        ('Farm Location 1', 40.7128, -74.0060, 25.1, 58.0, 0.0, 12.8, 'sunny', NOW() - INTERVAL '2 hours'),
        ('Farm Location 2', 40.7125, -74.0065, 21.8, 70.0, 5.2, 18.5, 'rainy', NOW() - INTERVAL '3 hours');

    -- Create sample alerts
    INSERT INTO public.alerts (user_id, field_id, alert_type, priority, title, description, action_required, due_date)
    VALUES
        (farmer1_id, field1_id, 'irrigation', 'high', 'Irrigation Required', 'Soil moisture levels are low in North Field. Consider irrigation within 24 hours.', true, NOW() + INTERVAL '1 day'),
        (farmer1_id, field2_id, 'fertilizer', 'medium', 'Fertilizer Application Due', 'Phosphorus application scheduled for South Field next week.', true, NOW() + INTERVAL '7 days'),
        (farmer2_id, field3_id, 'weather', 'critical', 'Storm Warning', 'Heavy rainfall expected in the next 6 hours. Secure equipment and check drainage.', true, NOW() + INTERVAL '6 hours'),
        (farmer2_id, null, 'pest', 'low', 'Pest Monitoring', 'Regular pest inspection recommended for all fields this week.', false, NOW() + INTERVAL '3 days');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;