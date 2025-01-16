/*
  # Initial Schema for Menstrual Health App

  1. New Tables
    - `profiles`
      - Stores user profile information
      - Links to Supabase auth.users
    - `cycles`
      - Tracks menstrual cycle data
    - `symptoms`
      - Stores symptom definitions
    - `symptom_logs`
      - Records symptom occurrences
    - `dietary_preferences`
      - Stores user dietary preferences
    - `partner_connections`
      - Manages partner relationships
    - `nutrition_recommendations`
      - Stores phase-specific nutrition advice

  2. Security
    - Enable RLS on all tables
    - Policies for user data access
    - Partner data sharing controls
*/

-- Create profiles table
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  email text NOT NULL,
  full_name text,
  avatar_url text,
  is_partner boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create cycles table
CREATE TABLE cycles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) NOT NULL,
  start_date date NOT NULL,
  end_date date,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create symptoms table
CREATE TABLE symptoms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Create symptom logs table
CREATE TABLE symptom_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) NOT NULL,
  symptom_id uuid REFERENCES symptoms(id) NOT NULL,
  severity integer CHECK (severity >= 1 AND severity <= 5),
  notes text,
  logged_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create dietary preferences table
CREATE TABLE dietary_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) NOT NULL,
  preference_type text NOT NULL,
  value text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create partner connections table
CREATE TABLE partner_connections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) NOT NULL,
  partner_id uuid REFERENCES profiles(id) NOT NULL,
  status text NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, partner_id)
);

-- Create nutrition recommendations table
CREATE TABLE nutrition_recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cycle_phase text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  ingredients jsonb,
  recipe_steps jsonb,
  dietary_tags text[],
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptoms ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptom_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE dietary_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_recommendations ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can view own cycles"
  ON cycles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own cycles"
  ON cycles FOR ALL
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can view own symptom logs"
  ON symptom_logs FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own symptom logs"
  ON symptom_logs FOR ALL
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can view own dietary preferences"
  ON dietary_preferences FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage own dietary preferences"
  ON dietary_preferences FOR ALL
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can view partner connections"
  ON partner_connections FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR partner_id = auth.uid());

CREATE POLICY "Users can manage own partner connections"
  ON partner_connections FOR ALL
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Everyone can view symptoms"
  ON symptoms FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Everyone can view nutrition recommendations"
  ON nutrition_recommendations FOR SELECT
  TO authenticated
  USING (true);

-- Create function to handle profile updates
CREATE OR REPLACE FUNCTION handle_user_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at timestamps
CREATE TRIGGER update_profiles_timestamp
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_update();

CREATE TRIGGER update_cycles_timestamp
  BEFORE UPDATE ON cycles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_update();

CREATE TRIGGER update_dietary_preferences_timestamp
  BEFORE UPDATE ON dietary_preferences
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_update();

CREATE TRIGGER update_partner_connections_timestamp
  BEFORE UPDATE ON partner_connections
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_update();