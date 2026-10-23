-- ==============================================================================
-- SPARKYSYNC DATABASE SCHEMA (SUPABASE POSTGRESQL)
-- A Gamified Lagos Dating Life-Sim Platform
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. USER PROFILES TABLE (Linked with Supabase Auth auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(50) DEFAULT 'Lekki Resident',
    avatar_emoji VARCHAR(10) DEFAULT '😎',
    level INT DEFAULT 1,
    xp INT DEFAULT 0,
    wallet_balance INT DEFAULT 500,     -- 🪙 Spark Coins
    energy INT DEFAULT 100,             -- ⚡ Stamina (0-100)
    max_energy INT DEFAULT 100,
    neighborhood VARCHAR(50) DEFAULT 'Lekki Phase 1',
    bio TEXT,
    interests TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profiles RLS & Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id OR auth.uid() IS NULL);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Automatic Profile Creation Trigger on Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        username,
        neighborhood,
        wallet_balance,
        energy,
        level
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'neighborhood', 'Lekki Phase 1'),
        600,
        100,
        1
    )
    ON CONFLICT (id) DO UPDATE SET
        username = EXCLUDED.username,
        neighborhood = EXCLUDED.neighborhood;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. VIRTUAL ITEMS & GIFTS CATALOG
CREATE TABLE IF NOT EXISTS public.items (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(20) NOT NULL,       -- 'consumable', 'fashion', 'romanticGift'
    token_cost INT NOT NULL,
    emoji VARCHAR(10) NOT NULL,
    description TEXT,
    effect_description TEXT,
    energy_boost INT DEFAULT 0
);

-- Populate starter items catalog
INSERT INTO public.items (id, name, category, token_cost, emoji, description, effect_description, energy_boost)
VALUES
    ('amala_shitta', 'Hot Amala & Gbegiri', 'consumable', 45, '🍲', 'Authentic steaming hot Amala from Shitta, Surulere with goat meat.', 'Restores +45 ⚡ Energy immediately.', 45),
    ('glover_suya_pack', 'Spicy Glover Suya Platter', 'consumable', 35, '🥩', 'Well-seasoned beef suya with fresh red onions and yaji pepper.', 'Restores +35 ⚡ Energy immediately.', 35),
    ('gen_fuel', '20L Generator Diesel Jerrycan', 'consumable', 70, '⛽', 'Keep the AC and lights freezing even when NEPA fails you.', 'Restores +70 ⚡ Energy & protects against blackouts.', 70),
    ('agbada_gold', 'Royal Agbada + Heavy Gold Chain', 'fashion', 320, '👑', 'Crisp starched navy blue Agbada that screams Big Baller.', '+30% Charisma boost in high-end venues.', 0),
    ('tech_hoodie', 'Silicon Lagoon Tech Hoodie', 'fashion', 180, '🧥', 'Minimalist designer black hoodie. Gives off YC funded energy.', '+15% extra coins on dev hustles.', 0),
    ('red_roses', 'Bouquet of Red Roses', 'romanticGift', 50, '🌹', 'A classic declaration of romantic intent.', '+1 Relationship Point with your match.', 0),
    ('belgian_chocolates', 'Belgian Chocolate Truffles', 'romanticGift', 80, '🍫', 'Imported silky luxury chocolates that melt instantly.', '+2 Relationship Points & unlocks sweet chat prompt.', 0),
    ('moet_champagne', 'Moët & Chandon Nectar Impérial', 'romanticGift', 200, '🍾', 'The golden standard of Lagos celebration and romantic flexing.', '+4 Relationship Points & VIP spark flare.', 0),
    ('gwagon_keys', 'Mercedes G-Wagon Keys', 'romanticGift', 650, '🗝️', 'The ultimate symbol of Lagos romance. Pure unadulterated luxury.', 'Instant couple unlock & "Owambe Official" eligibility!', 0),
    ('chilled_malt', 'Chilled Malt Drink', 'consumable', 20, '🧃', 'Ice-cold refreshing malt drink. Perfect afternoon pick-me-up.', 'Instantly replenishes +10 ⚡ Energy pool points.', 10),
    ('party_jollof', 'Party Jollof Feast', 'consumable', 65, '🍲', 'Smoky Lagos wedding party Jollof rice with fried plantain and peppered beef.', 'Maximizes stamina pool with +50 ⚡ Energy.', 50),
    ('neon_chat_flare', 'Exclusive Neon Chat Flare', 'profileFlair', 250, '✨', 'Exclusive animated neon text trail in public lounges and VIP rooms. Displays your clout!', 'Exclusive 24-hour animated neon chat flare text trail in lounges.', 0)
ON CONFLICT (id) DO NOTHING;

-- 4. USER INVENTORY
CREATE TABLE IF NOT EXISTS public.user_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    item_id VARCHAR(50) REFERENCES public.items(id) ON DELETE CASCADE,
    quantity INT DEFAULT 1 CHECK (quantity >= 0),
    is_equipped BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_item UNIQUE (user_id, item_id)
);

-- 5. MATCHES & DATING PROGRESSION
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_one UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_two UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'matched', -- 'pending', 'matched', 'blocked'
    relationship_stage VARCHAR(30) DEFAULT 'talkingStage', -- 'talkingStage', 'situationship', 'mainSqueeze', 'owambeOfficial'
    total_gifts_exchanged INT DEFAULT 0,
    sync_score INT DEFAULT 85,
    matched_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_pair UNIQUE (user_one, user_two)
);

-- 6. DIRECT MESSAGES
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    gift_item_id VARCHAR(50) REFERENCES public.items(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. VENUES & LIVE PUBLIC ROOM CHATS
CREATE TABLE IF NOT EXISTS public.venue_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id VARCHAR(50) NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_name VARCHAR(50) NOT NULL,
    sender_avatar VARCHAR(10) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. AUDIT TRANSACTIONS LEDGER (Financial Security)
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount INT NOT NULL,                 -- Positive for rewards, negative for expenses
    transaction_type VARCHAR(30) NOT NULL,
    reference_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- ATOMIC STORED PROCEDURES (PL/pgSQL RPC)
-- ==============================================================================

-- Atomic Gift Transaction: Deducts wallet balance, records ledger, increments gift count, updates relationship milestone
CREATE OR REPLACE FUNCTION public.send_gift_to_match(
    p_sender_id UUID,
    p_match_id UUID,
    p_item_id VARCHAR(50)
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cost INT;
    v_balance INT;
    v_gifts_count INT;
    v_new_stage VARCHAR(30);
BEGIN
    -- 1. Fetch item cost
    SELECT token_cost INTO v_cost FROM public.items WHERE id = p_item_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item does not exist';
    END IF;

    -- 2. Check balance with row locking
    SELECT wallet_balance INTO v_balance FROM public.profiles WHERE id = p_sender_id FOR UPDATE;
    IF v_balance < v_cost THEN
        RAISE EXCEPTION 'Insufficient Spark Coins balance';
    END IF;

    -- 3. Deduct balance & award XP
    UPDATE public.profiles
    SET wallet_balance = wallet_balance - v_cost,
        xp = xp + 50
    WHERE id = p_sender_id;

    -- 4. Record ledger transaction
    INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
    VALUES (p_sender_id, -v_cost, 'send_gift', p_item_id);

    -- 5. Increment gifts count and upgrade relationship stage
    UPDATE public.matches
    SET total_gifts_exchanged = total_gifts_exchanged + 1
    WHERE id = p_match_id
    RETURNING total_gifts_exchanged INTO v_gifts_count;

    IF v_gifts_count >= 10 THEN
        v_new_stage := 'owambeOfficial';
    ELSIF v_gifts_count >= 5 THEN
        v_new_stage := 'mainSqueeze';
    ELSIF v_gifts_count >= 2 THEN
        v_new_stage := 'situationship';
    ELSE
        v_new_stage := 'talkingStage';
    END IF;

    UPDATE public.matches SET relationship_stage = v_new_stage WHERE id = p_match_id;

    -- 6. Insert chat message record
    INSERT INTO public.messages (match_id, sender_id, content, gift_item_id)
    VALUES (p_match_id, p_sender_id, 'Sent a romantic gift!', p_item_id);

    RETURN jsonb_build_object(
        'success', true,
        'new_balance', v_balance - v_cost,
        'relationship_stage', v_new_stage,
        'total_gifts', v_gifts_count
    );
END;
$$;

-- Atomic Hustle Completion: Deducts energy, adds coins & xp, logs ledger
CREATE OR REPLACE FUNCTION public.complete_hustle(
    p_user_id UUID,
    p_energy_cost INT,
    p_coin_reward INT,
    p_job_id VARCHAR(50)
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_energy INT;
    v_balance INT;
    v_level INT;
    v_xp INT;
BEGIN
    SELECT energy, wallet_balance, level, xp
    INTO v_energy, v_balance, v_level, v_xp
    FROM public.profiles WHERE id = p_user_id FOR UPDATE;

    IF v_energy < p_energy_cost THEN
        RAISE EXCEPTION 'Not enough energy';
    END IF;

    UPDATE public.profiles
    SET energy = energy - p_energy_cost,
        wallet_balance = wallet_balance + p_coin_reward,
        xp = xp + 30
    WHERE id = p_user_id;

    INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
    VALUES (p_user_id, p_coin_reward, 'hustle_payout', p_job_id);

    RETURN jsonb_build_object(
        'success', true,
        'new_energy', v_energy - p_energy_cost,
        'new_balance', v_balance + p_coin_reward
    );
END;
$$;

-- Atomic Daily Bonus Claim
CREATE OR REPLACE FUNCTION public.claim_daily_bonus(
    p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_coins_bonus INT := 120;
    v_energy_bonus INT := 35;
    v_max_energy INT;
BEGIN
    SELECT max_energy INTO v_max_energy FROM public.profiles WHERE id = p_user_id;

    UPDATE public.profiles
    SET wallet_balance = wallet_balance + v_coins_bonus,
        energy = LEAST(max_energy, energy + v_energy_bonus),
        xp = xp + 40
    WHERE id = p_user_id;

    INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
    VALUES (p_user_id, v_coins_bonus, 'daily_gacha', 'daily_bonus');

    RETURN jsonb_build_object(
        'success', true,
        'coins_added', v_coins_bonus,
        'energy_added', v_energy_bonus
    );
END;
$$;

-- 2go Nostalgia & Clout: Atomic Purchase Customization Stored Procedure
CREATE OR REPLACE FUNCTION public.purchase_customization_item(
    p_user_id UUID,
    p_item_id VARCHAR(50),
    p_auto_equip BOOLEAN DEFAULT TRUE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    new_balance INT
) AS $$
DECLARE
    v_wallet_balance INT;
    v_token_cost INT;
    v_item_type VARCHAR(20);
    v_item_name VARCHAR(100);
BEGIN
    -- 1. Lock the specific user row to prevent race conditions / double spending
    SELECT wallet_balance INTO v_wallet_balance
    FROM public.profiles
    WHERE id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'User account not found.'::TEXT, 0;
        RETURN;
    END IF;

    -- 2. Fetch item parameters and cost
    SELECT token_cost, category, name INTO v_token_cost, v_item_type, v_item_name
    FROM public.items
    WHERE id = p_item_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Target customization item does not exist.'::TEXT, v_wallet_balance;
        RETURN;
    END IF;

    -- 3. Verify user has enough money in their balance
    IF v_wallet_balance < v_token_cost THEN
        RETURN QUERY SELECT FALSE, 'Insufficient Sparksync credit balance.'::TEXT, v_wallet_balance;
        RETURN;
    END IF;

    -- 4. Deduct the price from user's account wallet and award Clout XP
    UPDATE public.profiles
    SET wallet_balance = wallet_balance - v_token_cost,
        xp = xp + 100
    WHERE id = p_user_id
    RETURNING wallet_balance INTO v_wallet_balance;

    -- 5. If auto-equipping a profile modification, unequip old modifications of that same type first
    IF p_auto_equip = TRUE AND v_item_type = 'profile_flair' THEN
        UPDATE public.user_inventory
        SET is_equipped = FALSE
        WHERE user_id = p_user_id AND item_id IN (SELECT id FROM public.items WHERE category = 'profile_flair');
    END IF;

    -- 6. Insert item into the user's Inventory
    INSERT INTO public.user_inventory (user_id, item_id, quantity, is_equipped)
    VALUES (p_user_id, p_item_id, 1, p_auto_equip)
    ON CONFLICT (user_id, item_id) DO UPDATE
    SET quantity = public.user_inventory.quantity + 1,
        is_equipped = p_auto_equip;

    -- 7. Log to audit Transaction ledger for account security
    INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
    VALUES (p_user_id, -v_token_cost, 'purchase_customization', p_item_id);

    -- 8. Return successful response schema
    RETURN QUERY SELECT TRUE, 'Purchase successful! Item ' || v_item_name || ' added.', v_wallet_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2go Public & Vibe Chatroom Messages
CREATE TABLE IF NOT EXISTS public.room_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id VARCHAR(50) NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_name VARCHAR(50) NOT NULL,
    sender_avatar VARCHAR(10) NOT NULL,
    sender_rank VARCHAR(20) DEFAULT 'novice',
    content TEXT NOT NULL,
    has_neon_glow BOOLEAN DEFAULT FALSE,
    is_announcement BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Option C: Rolling 25-Message Buffer Trigger (SparkSync Default)
-- Automatically prunes older historical messages beyond the rolling 25-message window
CREATE OR REPLACE FUNCTION public.prune_room_messages_rolling_buffer()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.room_messages
    WHERE room_id = NEW.room_id
      AND id NOT IN (
          SELECT id FROM public.room_messages
          WHERE room_id = NEW.room_id
          ORDER BY created_at DESC
          LIMIT 25
      );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prune_room_messages ON public.room_messages;
CREATE TRIGGER trg_prune_room_messages
    AFTER INSERT ON public.room_messages
    FOR EACH ROW
    EXECUTE FUNCTION public.prune_room_messages_rolling_buffer();

-- Populate 2go store customizations into catalog
INSERT INTO public.items (id, name, category, token_cost, emoji, description, effect_description, energy_boost)
VALUES
    ('neon_night_glow', 'Neon Night Glow Theme', 'profile_flair', 350, '⭐', 'Make your profile card pulse with a vibrant neon light effect inside every public chatroom.', 'Pulsing cyber rainbow neon glow in chatrooms and cards.', 0),
    ('golden_vip_pass', 'Golden VIP Lounge Pass', 'room_pass', 200, '🎟️', 'Gain immediate access to all exclusive high-clout VIP lounges regardless of your Star Rank.', 'Unlocks Billionaires Club & Penthouse Lounges.', 0),
    ('crown_of_lekki', 'Crown of Lekki Flair', 'profile_flair', 500, '👑', 'Royal gold aura badge pinned to your name in every public room and swipe deck.', 'High-roller gold crown badge displayed with shimmering aura.', 0),
    ('champagne_round', 'Room Champagne Round', 'consumable', 100, '🍾', 'Buy a round of virtual drinks for everyone in your active chatroom with full room banner announcement!', 'Awards +150 Clout XP and flashes room-wide banner announcement.', 0),
    ('ghost_cloak', 'Ghost Mode Cloak', 'profile_flair', 250, '👻', 'Browse rooms and swipe decks completely undetected. Your profile stays invisible on room rosters.', 'Toggles Invisible Mode anytime without alerting other ballers.', 0)
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 2GO NOSTALGIA & LEVEL PROGRESSION TRIGGER ENGINE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.experience_milestones (
    level_tier INT PRIMARY KEY,
    xp_required_floor INT NOT NULL,
    unlocked_rank_name VARCHAR(40) NOT NULL
);

INSERT INTO public.experience_milestones (level_tier, xp_required_floor, unlocked_rank_name) VALUES
(1, 0, 'Novice'),
(2, 500, 'Amateur'),
(3, 2500, 'Senior'),
(4, 7500, 'Master'),
(5, 20000, 'Professional'),
(6, 50000, 'Expert'),
(7, 120000, 'Veteran'),
(8, 300000, 'Ultimate')
ON CONFLICT (level_tier) DO NOTHING;

-- Automated Level & Rank Calculation Routine Trigger
CREATE OR REPLACE FUNCTION public.trigger_evaluate_user_level_up()
RETURNS TRIGGER AS $$
DECLARE
    v_calculated_level INT;
    v_calculated_rank VARCHAR(40);
BEGIN
    SELECT level_tier, unlocked_rank_name INTO v_calculated_level, v_calculated_rank
    FROM public.experience_milestones
    WHERE NEW.xp >= xp_required_floor
    ORDER BY level_tier DESC
    LIMIT 1;

    IF v_calculated_level IS DISTINCT FROM OLD.level THEN
        NEW.level := v_calculated_level;
        NEW.title := v_calculated_rank || ' Baller';
        -- Bonus credits graduation gift
        NEW.wallet_balance := NEW.wallet_balance + (v_calculated_level * 50);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_xp_accumulation ON public.profiles;
CREATE TRIGGER on_xp_accumulation
    BEFORE UPDATE OF xp ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_evaluate_user_level_up();

-- ==============================================================================
-- CHATROOM MESSAGES (WEBSOCKET STREAM PIPELINE)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.chatroom_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id VARCHAR(50) NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    sender_username VARCHAR(50) DEFAULT 'Baller',
    sender_rank VARCHAR(40) DEFAULT 'Novice',
    message_text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Option C: Rolling 25-Message Buffer Trigger for Public Chatroom
CREATE OR REPLACE FUNCTION public.prune_chatroom_messages_rolling_buffer()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.chatroom_messages
    WHERE room_id = NEW.room_id
      AND id NOT IN (
          SELECT id FROM public.chatroom_messages
          WHERE room_id = NEW.room_id
          ORDER BY created_at DESC
          LIMIT 25
      );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prune_chatroom_messages ON public.chatroom_messages;
CREATE TRIGGER trg_prune_chatroom_messages
    AFTER INSERT ON public.chatroom_messages
    FOR EACH ROW
    EXECUTE FUNCTION public.prune_chatroom_messages_rolling_buffer();

-- ==============================================================================
-- PRIVATE DM (DIRECT MESSAGE) RECURSIVE CONVERSATION ENGINE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.private_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    message_content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Automated Conversation Instantiation on Mutual Match
CREATE OR REPLACE FUNCTION public.auto_create_conversation_on_match()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'matched' AND (OLD.status IS DISTINCT FROM 'matched' OR OLD IS NULL) THEN
        INSERT INTO public.conversations (match_id)
        VALUES (NEW.id)
        ON CONFLICT (match_id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_mutual_match_create_dm_room ON public.matches;
CREATE TRIGGER on_mutual_match_create_dm_room
    AFTER INSERT OR UPDATE OF status ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_create_conversation_on_match();

-- ==============================================================================
-- ALGORITHMIC DISCOVERY SWIPE ENGINE
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_discovery_swipe_deck(
    p_viewer_id UUID,
    p_viewer_gender VARCHAR(10),
    p_target_gender VARCHAR(10),
    p_viewer_lat DOUBLE PRECISION,
    p_viewer_lng DOUBLE PRECISION,
    p_max_distance_km DOUBLE PRECISION DEFAULT 25.0,
    p_limit INT DEFAULT 20
)
RETURNS TABLE (
    candidate_id UUID,
    username VARCHAR(50),
    avatar_url TEXT,
    rank_title VARCHAR(40),
    current_level INT,
    status_text TEXT,
    distance_km DOUBLE PRECISION,
    final_match_score DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id as candidate_id,
        u.username,
        u.avatar_emoji as avatar_url,
        COALESCE(u.title, 'Novice') as rank_title,
        COALESCE(u.level, 1) as current_level,
        COALESCE(u.bio, 'Hey there! Vibe with me.') as status_text,
        -- Spherical distance approximation in km
        (6371 * acos(
            cos(radians(p_viewer_lat)) * cos(radians(6.4474)) *
            cos(radians(3.4849) - radians(p_viewer_lng)) +
            sin(radians(p_viewer_lat)) * sin(radians(6.4474))
        )) as distance_km,
        (
            (COALESCE(u.level, 1) * 15.0) +
            50.0 + -- Active user weighting
            30.0   -- Local hood booster
        ) as final_match_score
    FROM public.profiles u
    WHERE u.id != p_viewer_id
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- REALTIME ENABLEMENT
-- ==============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.venue_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.room_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chatroom_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.private_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.matches;

-- ==============================================================================
-- MUTUAL MATCH CHECK & REALTIME BROADCAST PIPELINE
-- ==============================================================================
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS user_one_id UUID REFERENCES public.profiles(id);
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS user_two_id UUID REFERENCES public.profiles(id);
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS interaction_status VARCHAR(20) DEFAULT 'matched';

CREATE OR REPLACE FUNCTION public.handle_mutual_match_check()
RETURNS TRIGGER AS $$
DECLARE
    v_mutual_exists BOOLEAN;
    v_target_user_one UUID;
    v_target_user_two UUID;
BEGIN
    v_target_user_one := COALESCE(NEW.user_one_id, NEW.user_one);
    v_target_user_two := COALESCE(NEW.user_two_id, NEW.user_two);

    -- Only evaluate if action is a liked interaction
    IF COALESCE(NEW.interaction_status, NEW.status) <> 'liked' THEN
        RETURN NEW;
    END IF;

    -- Check if reverse relationship already exists with 'liked' status
    SELECT EXISTS (
        SELECT 1 FROM public.matches
        WHERE (
            (user_one = v_target_user_two AND user_two = v_target_user_one) OR
            (user_one_id = v_target_user_two AND user_two_id = v_target_user_one)
        )
        AND COALESCE(interaction_status, status) = 'liked'
    ) INTO v_mutual_exists;

    IF v_mutual_exists THEN
        NEW.status := 'matched';
        NEW.interaction_status := 'matched';

        UPDATE public.matches
        SET status = 'matched', interaction_status = 'matched'
        WHERE (
            (user_one = v_target_user_two AND user_two = v_target_user_one) OR
            (user_one_id = v_target_user_two AND user_two_id = v_target_user_one)
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_swipe_match_evaluation ON public.matches;
CREATE TRIGGER on_swipe_match_evaluation
    BEFORE INSERT OR UPDATE OF interaction_status, status ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_mutual_match_check();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) FOR CONVERSATIONS & PRIVATE MESSAGES
-- ==============================================================================
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.private_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can only view their own mutual conversations" ON public.conversations;
CREATE POLICY "Users can only view their own mutual conversations" ON public.conversations
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m 
            WHERE m.id = conversations.match_id 
              AND (
                  m.user_one = auth.uid() OR m.user_two = auth.uid() OR
                  m.user_one_id = auth.uid() OR m.user_two_id = auth.uid()
              )
        )
    );

DROP POLICY IF EXISTS "Users can view messages inside their active conversations" ON public.private_messages;
CREATE POLICY "Users can view messages inside their active conversations" ON public.private_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.conversations c
            JOIN public.matches m ON c.match_id = m.id
            WHERE c.id = private_messages.conversation_id
              AND (
                  m.user_one = auth.uid() OR m.user_two = auth.uid() OR
                  m.user_one_id = auth.uid() OR m.user_two_id = auth.uid()
              )
        )
    );

DROP POLICY IF EXISTS "Users can write messages inside their active conversations" ON public.private_messages;
CREATE POLICY "Users can write messages inside their active conversations" ON public.private_messages
    FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.conversations c
            JOIN public.matches m ON c.match_id = m.id
            WHERE c.id = conversation_id
              AND (m.status = 'matched' OR m.interaction_status = 'matched')
              AND (
                  m.user_one = auth.uid() OR m.user_two = auth.uid() OR
                  m.user_one_id = auth.uid() OR m.user_two_id = auth.uid()
              )
        )
    );

-- ==============================================================================
-- 10. PHOTO VAULT & UNMATCH / BLOCK COMPLIANCE SCHEMA
-- ==============================================================================

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
    SELECT id, total_gifts_exchanged INTO v_match_id, v_current_gifts
    FROM public.matches
    WHERE (user_one = p_user_id AND user_two = p_target_id)
       OR (user_one = p_target_id AND user_two = p_user_id);

    IF v_match_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No active connection found.'::TEXT;
        RETURN;
    END IF;

    -- Charge 50 credits if high connection tier (Tier 3+: gifts >= 5) and not an abuse/harassment report
    IF v_current_gifts >= 5 AND p_reason <> 'harassment' AND p_reason <> 'scam' THEN
        SELECT wallet_balance INTO v_wallet_balance FROM public.profiles WHERE id = p_user_id FOR UPDATE;
        
        IF v_wallet_balance < v_penalty_cost THEN
            RETURN QUERY SELECT FALSE, 'Insufficient credits to sever this high-tier connection. 50 Credits required for emotional damages penalty.'::TEXT;
            RETURN;
        END IF;

        UPDATE public.profiles SET wallet_balance = wallet_balance - v_penalty_cost WHERE id = p_user_id;
        INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
        VALUES (p_user_id, -v_penalty_cost, 'unmatch_penalty', v_match_id::TEXT);
    END IF;

    -- ON DELETE CASCADE on messages purges chat histories instantly
    DELETE FROM public.matches WHERE id = v_match_id;

    IF p_action_type = 'block' THEN
        INSERT INTO public.profile_blacklist (initiator_id, target_id, reason_category)
        VALUES (p_user_id, p_target_id, COALESCE(p_reason, 'general'))
        ON CONFLICT (initiator_id, target_id) DO NOTHING;
    END IF;

    RETURN QUERY SELECT TRUE, 'Connection successfully severed. Vault relocked and histories purged cleanly.'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 10. DAILY LOGIN GACHA REWARDS & STREAK SYSTEM
-- ==============================================================================

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_login_claim_at TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_streak_days INT DEFAULT 0;

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
    
    v_tier VARCHAR(20);
    v_title VARCHAR(100);
    v_credit_payout INT := 0;
    v_item_id VARCHAR(50) := NULL;
    v_energy_boost INT := 0;
BEGIN
    SELECT last_login_claim_at, current_streak_days, wallet_balance 
    INTO v_last_claim, v_current_streak, v_wallet_balance
    FROM public.profiles WHERE id = p_user_id FOR UPDATE;

    IF v_wallet_balance IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User profile record not found.'::TEXT, 'NONE'::VARCHAR, 'None'::VARCHAR, 0, 0;
        RETURN;
    END IF;

    v_current_streak := COALESCE(v_current_streak, 0);

    IF v_last_claim IS NOT NULL AND v_last_claim >= date_trunc('day', NOW()) THEN
        RETURN QUERY SELECT FALSE, 'You have already claimed today''s daily reward! Come back tomorrow.'::TEXT, 'NONE'::VARCHAR, 'None'::VARCHAR, v_wallet_balance, v_current_streak;
        RETURN;
    END IF;

    IF v_last_claim IS NOT NULL AND v_last_claim < (NOW() - INTERVAL '48 hours') THEN
        v_current_streak := 1;
    ELSE
        v_current_streak := v_current_streak + 1;
    END IF;

    v_random_roll := floor(random() * 100) + 1;

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

    UPDATE public.profiles 
    SET last_login_claim_at = NOW(), 
        current_streak_days = v_current_streak
    WHERE id = p_user_id;

    INSERT INTO public.transactions (user_id, amount, transaction_type, reference_id)
    VALUES (p_user_id, v_credit_payout, 'daily_gacha_claim', v_tier);

    RETURN QUERY SELECT TRUE, 'Reward successfully claimed!'::TEXT, v_tier, v_title, v_wallet_balance, v_current_streak;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


