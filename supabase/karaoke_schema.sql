-- ================================================================
-- SPARKYSYNC LIVE KARAOKE & CROWD APPLAUSE ENGINE SCHEMA
-- Handles synchronized track queues, lyrics, and 70/30 tipping
-- ================================================================

-- 1. KARAOKE MASTER TRACK CATALOG
CREATE TABLE IF NOT EXISTS karaoke_tracks (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(150) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    emoji VARCHAR(10) DEFAULT '🎤',
    instrumental_url TEXT NOT NULL,         -- Path to raw .mp3 background track or CDN stream
    lyrics_lrc_url TEXT NOT NULL,           -- Path to synchronized time-stamped .lrc file
    duration_seconds INT NOT NULL DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. LIVE ROOM PERFORMANCE QUEUE MATRIX
CREATE TABLE IF NOT EXISTS karaoke_room_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id VARCHAR(100) NOT NULL,           -- e.g. 'room_afrobeat_vibes'
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    track_id INT REFERENCES karaoke_tracks(id) ON DELETE CASCADE,
    credit_fee_paid INT DEFAULT 30,
    queue_position INT NOT NULL,             -- Lower numbers perform first
    performance_status VARCHAR(20) DEFAULT 'waiting', -- 'waiting', 'singing', 'skipped', 'completed'
    total_tips_collected INT DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for speedy room queue polling and broadcast order
CREATE INDEX IF NOT EXISTS idx_karaoke_room_queue_status 
ON karaoke_room_queue(room_id, performance_status, queue_position);

-- 3. SECURE STORED PROCEDURE TO JOIN THE LIVE KARAOKE QUEUE
CREATE OR REPLACE FUNCTION join_karaoke_queue(
    p_user_id UUID,
    p_room_id VARCHAR(100),
    p_track_id INT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    allocated_position INT
) AS $$
DECLARE
    v_wallet_balance INT;
    v_fee INT := 30;
    v_next_position INT;
BEGIN
    -- 1. Check wallet balance with row-level safety locking
    SELECT wallet_balance INTO v_wallet_balance 
    FROM profiles 
    WHERE id = p_user_id 
    FOR UPDATE;
    
    IF v_wallet_balance IS NULL OR v_wallet_balance < v_fee THEN
        RETURN QUERY SELECT FALSE, 'Insufficient credits to request a song (Requires 30 🪙).'::TEXT, 0;
        RETURN;
    END IF;

    -- 2. Prevent duplicate entries by the same user in the same active room queue
    IF EXISTS (
        SELECT 1 
        FROM karaoke_room_queue 
        WHERE room_id = p_room_id 
          AND user_id = p_user_id 
          AND performance_status = 'waiting'
    ) THEN
        RETURN QUERY SELECT FALSE, 'You are already in the performance queue for this room.'::TEXT, 0;
        RETURN;
    END IF;

    -- 3. Deduct currency fee structure
    UPDATE profiles 
    SET wallet_balance = wallet_balance - v_fee 
    WHERE id = p_user_id;

    -- 4. Calculate next available position index inside target room line
    SELECT COALESCE(MAX(queue_position), 0) + 1 INTO v_next_position 
    FROM karaoke_room_queue 
    WHERE room_id = p_room_id 
      AND performance_status = 'waiting';

    -- 5. Insert queue record row into the live state ledger
    INSERT INTO karaoke_room_queue (room_id, user_id, track_id, queue_position, credit_fee_paid)
    VALUES (p_room_id, p_user_id, p_track_id, v_next_position, v_fee);

    RETURN QUERY SELECT TRUE, 'Successfully added to the live performance queue!', v_next_position;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. SPRAY NAIRA REVENUE SPLIT STORED PROCEDURE (70% Singer, 30% House)
CREATE OR REPLACE FUNCTION spray_naira_on_singer(
    p_spender_id UUID,
    p_singer_id UUID,
    p_room_id VARCHAR(100),
    p_amount INT DEFAULT 50
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    singer_received INT
) AS $$
DECLARE
    v_spender_balance INT;
    v_singer_share INT;
BEGIN
    IF p_amount <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Invalid spray amount.'::TEXT, 0;
        RETURN;
    END IF;

    -- Lock spender profile
    SELECT wallet_balance INTO v_spender_balance 
    FROM profiles 
    WHERE id = p_spender_id 
    FOR UPDATE;

    IF v_spender_balance IS NULL OR v_spender_balance < p_amount THEN
        RETURN QUERY SELECT FALSE, 'Insufficient credits to spray Naira!'::TEXT, 0;
        RETURN;
    END IF;

    -- Calculate 70% singer cut, 30% house cut
    v_singer_share := (p_amount * 0.70)::INT;

    -- Deduct 50 from spender
    UPDATE profiles 
    SET wallet_balance = wallet_balance - p_amount 
    WHERE id = p_spender_id;

    -- Credit 35 to singer (if singer is a registered user)
    IF p_singer_id IS NOT NULL THEN
        UPDATE profiles 
        SET wallet_balance = wallet_balance + v_singer_share 
        WHERE id = p_singer_id;
    END IF;

    RETURN QUERY SELECT TRUE, 'Sprayed Naira successfully!', v_singer_share;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. SEED INITIAL AFROBEAT KARAOKE TRACKS
INSERT INTO karaoke_tracks (title, artist, emoji, instrumental_url, lyrics_lrc_url, duration_seconds)
VALUES 
('Essence', 'Wizkid ft. Tems', '✨', 'https://sparksync.app/audio/karaoke/essence_inst.mp3', 'https://sparksync.app/audio/karaoke/essence.lrc', 32),
('Last Last (Breakfast)', 'Burna Boy', '💔', 'https://sparksync.app/audio/karaoke/last_last_inst.mp3', 'https://sparksync.app/audio/karaoke/last_last.lrc', 28),
('Lonely At The Top', 'Asake', '🪵', 'https://sparksync.app/audio/karaoke/lonely_top_inst.mp3', 'https://sparksync.app/audio/karaoke/lonely_top.lrc', 30),
('Calm Down', 'Rema', '💃', 'https://sparksync.app/audio/karaoke/calm_down_inst.mp3', 'https://sparksync.app/audio/karaoke/calm_down.lrc', 28),
('Rush', 'Ayra Starr', '⚡', 'https://sparksync.app/audio/karaoke/rush_inst.mp3', 'https://sparksync.app/audio/karaoke/rush.lrc', 28)
ON CONFLICT DO NOTHING;
