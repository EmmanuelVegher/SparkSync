-- ==============================================================================
-- SPARKSYNC DAILY GACHA & LOGIN STREAK REWARDS MIGRATION
-- ==============================================================================

-- 1. TRACK DAILY STREAKS INSIDE THE USERS / PROFILES SYSTEM
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_login_claim_at TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_streak_days INT DEFAULT 0;

-- 2. SECURE ATOMIC GACHA SPIN TRANSACTION STORED PROCEDURE
CREATE OR REPLACE FUNCTION public.spin_daily_gacha_box(p_user_id UUID)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    rolled_tier VARCHAR(20),
    reward_title VARCHAR(100),
    new_wallet INT,
    new_streak INT
) AS $$
DECLARE
    v_last_claim TIMESTAMPTZ;
    v_current_streak INT;
    v_wallet_balance INT;
    v_random_roll INT;
    
    -- Reward Outputs
    v_tier VARCHAR(20);
    v_title VARCHAR(100);
    v_credit_payout INT := 0;
    v_item_id VARCHAR(50) := NULL;
    v_energy_boost INT := 0;
BEGIN
    -- Lock user profile row to prevent multi-tap click race conditions
    SELECT last_login_claim_at, current_streak_days, wallet_balance 
    INTO v_last_claim, v_current_streak, v_wallet_balance
    FROM public.profiles WHERE id = p_user_id FOR UPDATE;

    IF v_wallet_balance IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User profile record not found.'::TEXT, 'NONE'::VARCHAR, 'None'::VARCHAR, 0, 0;
        RETURN;
    END IF;

    -- Default streak to 0 if null
    v_current_streak := COALESCE(v_current_streak, 0);

    -- 1. Verify if user has already claimed a reward in the current calendar day
    IF v_last_claim IS NOT NULL AND v_last_claim >= date_trunc('day', NOW()) THEN
        RETURN QUERY SELECT FALSE, 'You have already claimed today''s daily reward! Come back tomorrow.'::TEXT, 'NONE'::VARCHAR, 'None'::VARCHAR, v_wallet_balance, v_current_streak;
        RETURN;
    END IF;

    -- 2. Update Streak Counter (Reset to 1 if last claim was over 48 hours ago)
    IF v_last_claim IS NOT NULL AND v_last_claim < (NOW() - INTERVAL '48 hours') THEN
        v_current_streak := 1;
    ELSE
        v_current_streak := v_current_streak + 1;
    END IF;

    -- 3. Execute Random Number Generation (Roll between 1 and 100)
    v_random_roll := floor(random() * 100) + 1;

    -- 4. Map Roll Number against Probability Tier Constraints
    -- Tier Matrix:
    -- Common 50%: 20 Credits Box
    -- Common 30%: Chilled Malt Drink (+10 Energy)
    -- Rare   13%: 150 Credits Jackpot!
    -- Rare    5%: Party Jollof Feast (+50 Energy)
    -- Mythic  2%: Exclusive Neon Chat Flare (24h)
    IF v_random_roll <= 50 THEN
        v_tier := 'Common'; v_title := '🪙 20 Credits Box'; v_credit_payout := 20;
    ELSIF v_random_roll <= 80 THEN
        v_tier := 'Common'; v_title := '🧃 Chilled Malt Drink'; v_item_id := 'chilled_malt'; v_energy_boost := 10;
    ELSIF v_random_roll <= 93 THEN
        v_tier := 'Rare'; v_title := '🪙 150 Credits Jackpot!'; v_credit_payout := 150;
    ELSIF v_random_roll <= 98 THEN
        v_tier := 'Rare'; v_title := '🍲 Party Jollof Feast'; v_item_id := 'party_jollof'; v_energy_boost := 50;
    ELSE
        v_tier := 'Mythic'; v_title := '✨ Exclusive Neon Chat Flare (24h)'; v_item_id := 'neon_chat_flare';
    END IF;

    -- 5. Process and Credit the Payout Rewards to Database Rows
    IF v_credit_payout > 0 THEN
        UPDATE public.profiles 
        SET wallet_balance = wallet_balance + v_credit_payout 
        WHERE id = p_user_id;
        v_wallet_balance := v_wallet_balance + v_credit_payout;
    END IF;

    IF v_energy_boost > 0 THEN
        UPDATE public.profiles 
        SET energy = LEAST(max_energy, energy + v_energy_boost) 
        WHERE id = p_user_id;
    END IF;

    IF v_item_id IS NOT NULL THEN
        INSERT INTO public.user_inventory (user_id, item_id, quantity) 
        VALUES (p_user_id, v_item_id, 1)
        ON CONFLICT (user_id, item_id)
        DO UPDATE SET quantity = public.user_inventory.quantity + 1, updated_at = NOW();
    END IF;

    -- Update User Record Timestamp & Streak
    UPDATE public.profiles 
    SET last_login_claim_at = NOW(), 
        current_streak_days = v_current_streak
    WHERE id = p_user_id;

    -- Write Audit Log Ledger Entry
    INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
    VALUES (p_user_id, v_credit_payout, 'daily_gacha_claim', v_tier);

    RETURN QUERY SELECT TRUE, 'Reward successfully claimed!'::TEXT, v_tier, v_title, v_wallet_balance, v_current_streak;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
