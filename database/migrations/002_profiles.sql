CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    sex TEXT CHECK (sex IN ('male', 'female')),
    age INTEGER CHECK (age >= 13 AND age <= 120),
    height_cm NUMERIC(5,2) CHECK (height_cm > 0),
    weight_kg NUMERIC(5,2) CHECK (weight_kg > 0),
    target_weight_kg NUMERIC(5,2) CHECK (target_weight_kg > 0),
    goal TEXT CHECK (goal IN 
            ('lose_weight', 
            'maintain_weight', 
            'gain_weight')),
    activity_level TEXT CHECK (activity_level IN 
            ('sedentary', 
            'lightly_active', 
            'moderately_active', 
            'active', 
            'very_active')),
    dietary_preferences TEXT CHECK (dietary_preferences IN 
            ('none', 
            'vegetarian', 
            'vegan', 
            'pescatarian', 
            'keto', 
            'paleo')),
    training_preferences TEXT CHECK (training_preferences IN 
            ('none', 
            'cardio', 
            'strength_training', 
            'mixed')),
    training_frequency_per_week INTEGER CHECK (training_frequency_per_week >= 0 AND training_frequency_per_week <= 14),
    allergies TEXT,
    medical_conditions TEXT,
    visual_body_fat_category TEXT CHECK (
        visual_body_fat_category IN (
            'very_lean',
            'lean',
            'average',
            'above_average',
            'high_body_fat'
        )
    ),
    bmi NUMERIC(5,2) GENERATED ALWAYS AS (
        ROUND((weight_kg / (height_cm * height_cm) * 10000)::numeric, 2)
    ) STORED,
    tdee NUMERIC(7,2) CHECK (tdee > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);