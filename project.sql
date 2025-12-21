
-- 1. Таблица игроков
CREATE TABLE IF NOT EXISTS players (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    skill_rating INT DEFAULT 1000,
    clan_id INT,
    wins_count INT DEFAULT 0,
    losses_count INT DEFAULT 0
);

-- 2. Таблица кланов  
CREATE TABLE IF NOT EXISTS clans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    tag VARCHAR(10) UNIQUE NOT NULL,
    leader_id INT,
    clan_rating INT DEFAULT 1000
);

-- 3. Таблица героев
CREATE TABLE IF NOT EXISTS heroes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL
);

-- 4. Таблица карт
CREATE TABLE IF NOT EXISTS maps (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- 5. Таблица типов очередей
CREATE TABLE IF NOT EXISTS matchmaking_queues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    team_size INT DEFAULT 5,
    rating_tolerance INT DEFAULT 200
);

-- 6. Таблица игроков в очереди
CREATE TABLE IF NOT EXISTS queue_entries (
    id SERIAL PRIMARY KEY,
    player_id INT,
    queue_id INT,
    join_time TIMESTAMP DEFAULT NOW(),
    search_radius INT DEFAULT 100,
    status VARCHAR(20) DEFAULT 'searching'
);

-- 7. Таблица матчей
CREATE TABLE IF NOT EXISTS matches (
    id SERIAL PRIMARY KEY,
    queue_id INT,
    map_id INT,
    status VARCHAR(20) DEFAULT 'forming',
    start_time TIMESTAMP,
    average_rating INT,
    rating_disparity INT
);

-- 8. Таблица команд
CREATE TABLE IF NOT EXISTS teams (
    id SERIAL PRIMARY KEY,
    match_id INT,
    team_number INT CHECK (team_number IN (1, 2)),
    side VARCHAR(10) DEFAULT 'blue',
    average_rating INT,
    result VARCHAR(10)
);

-- 9. Таблица статистики игроков
CREATE TABLE IF NOT EXISTS player_match_performance (
    id SERIAL PRIMARY KEY,
    player_id INT,
    match_id INT,
    team_id INT,
    hero_id INT,
    kills INT DEFAULT 0,
    deaths INT DEFAULT 0,
    rating_change INT DEFAULT 0
);

-- 10. Таблица истории подбора
CREATE TABLE IF NOT EXISTS matchmaking_history (
    id SERIAL PRIMARY KEY,
    player_id INT,
    queue_id INT,
    join_time TIMESTAMP,
    match_found_time TIMESTAMP,
    total_wait_seconds INT
);

