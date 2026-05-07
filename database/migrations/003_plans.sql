CREATE TABLE IF NOT EXISTS plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coach_id UUID REFERENCES users(id) ON DELETE SET NULL,

    title TEXT NOT NULL,
    description TEXT,
    plan_type TEXT NOT NULL CHECK (
        plan_type IN ('training', 'nutrition', 'combined')
    ),
    status TEXT NOT NULL DEFAULT 'active' CHECK (
        status IN ('draft', 'active', 'archived')
    ),

    start_date DATE,
    end_date DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);