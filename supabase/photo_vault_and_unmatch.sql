-- ==============================================================================
-- PHOTO VAULT & UNMATCH / BLOCK COMPLIANCE SCHEMA
-- SparkSync Dating Simulation: Gamified Status, Vault & Anti-Ghosting Penalty
-- ==============================================================================

-- 1. EXTEND SCHEMA TO SUPPORT INTERACTION MANAGEMENT BLACKLISTS
CREATE TABLE IF NOT EXISTS public.profile_blacklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    initiator_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    target_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason_category VARCHAR(40) DEFAULT 'general', -- 'boring', 'harassment', 'scam', 'general'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_blacklist_pair UNIQUE (initiator_id, target_id)
);

ALTER TABLE public.profile_blacklist ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own blacklist" ON public.profile_blacklist;
CREATE POLICY "Users can read own blacklist" ON public.profile_blacklist
    FOR SELECT USING (auth.uid() = initiator_id);

DROP POLICY IF EXISTS "Users can insert into own blacklist" ON public.profile_blacklist;
CREATE POLICY "Users can insert into own blacklist" ON public.profile_blacklist
    FOR INSERT WITH CHECK (auth.uid() = initiator_id);

-- 2. SECURE COMPLIANCE STORED PROCEDURE ROUTINE FOR ACCOUNT SEVERANCE
CREATE OR REPLACE FUNCTION public.sever_match_connection(
    p_user_id UUID,
    p_target_id UUID,
    p_action_type VARCHAR(20), -- 'unmatch' OR 'block'
    p_reason VARCHAR(40) DEFAULT 'general'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_match_id UUID;
    v_current_gifts INT;
    v_wallet_balance INT;
    v_penalty_cost INT := 50;
BEGIN
    -- Locate active relationship record between users
    SELECT id, total_gifts_exchanged INTO v_match_id, v_current_gifts
    FROM public.matches
    WHERE (user_one = p_user_id AND user_two = p_target_id)
       OR (user_one = p_target_id AND user_two = p_user_id);

    IF v_match_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No active connection found.'::TEXT;
        RETURN;
    END IF;

    -- ANTI-GHOSTING PENALTY MECHANIC RULE CHECK
    -- Charge user 50 credits if high connection tier (Tier 3+: gifts >= 5) and not an abuse/harassment report
    IF v_current_gifts >= 5 AND p_reason <> 'harassment' AND p_reason <> 'scam' THEN
        SELECT wallet_balance INTO v_wallet_balance FROM public.profiles WHERE id = p_user_id FOR UPDATE;
        
        IF v_wallet_balance < v_penalty_cost THEN
            RETURN QUERY SELECT FALSE, 'Insufficient credits to sever this high-tier connection. 50 Credits required for emotional damages penalty.'::TEXT;
            RETURN;
        END IF;

        -- Deduct penalty fee structure from initiator
        UPDATE public.profiles SET wallet_balance = wallet_balance - v_penalty_cost WHERE id = p_user_id;
        INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
        VALUES (p_user_id, -v_penalty_cost, 'unmatch_penalty', v_match_id::TEXT);
    END IF;

    -- CORE PURGE WORKFLOWS
    -- ON DELETE CASCADE on messages table means deleting the match instantly purges all shared message histories.
    DELETE FROM public.matches WHERE id = v_match_id;

    -- If the action is a hard Block, register the users in the blacklist index
    IF p_action_type = 'block' THEN
        INSERT INTO public.profile_blacklist (initiator_id, target_id, reason_category)
        VALUES (p_user_id, p_target_id, COALESCE(p_reason, 'general'))
        ON CONFLICT (initiator_id, target_id) DO NOTHING;
    END IF;

    RETURN QUERY SELECT TRUE, 'Connection successfully severed. Vault relocked and histories purged cleanly.'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. BIOMETRIC SELFIE, AVATAR & PHOTO VAULT COLUMNS
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS verified_photo_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_feature_profile JSONB;

-- 4. STORAGE BUCKET FOR USER AVATARS & BIOMETRIC VAULT
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public Avatar Access" ON storage.objects;
CREATE POLICY "Public Avatar Access" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
CREATE POLICY "Authenticated users can upload avatars" ON storage.objects
    FOR ALL USING (bucket_id = 'avatars');
