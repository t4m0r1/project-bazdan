
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

-- Ключи для связей таблиц

-- Игроки -> Кланы
ALTER TABLE players ADD CONSTRAINT fk_players_clan 
FOREIGN KEY (clan_id) REFERENCES clans(id);

-- Кланы -> Лидер (игроки)
ALTER TABLE clans ADD CONSTRAINT fk_clans_leader 
FOREIGN KEY (leader_id) REFERENCES players(id);

-- Игроки в очереди -> Игроки
ALTER TABLE queue_entries ADD CONSTRAINT fk_queue_entries_player 
FOREIGN KEY (player_id) REFERENCES players(id);

-- Игроки в очереди -> Типы очередей
ALTER TABLE queue_entries ADD CONSTRAINT fk_queue_entries_queue 
FOREIGN KEY (queue_id) REFERENCES matchmaking_queues(id);

-- Матчи -> Типы очередей
ALTER TABLE matches ADD CONSTRAINT fk_matches_queue 
FOREIGN KEY (queue_id) REFERENCES matchmaking_queues(id);

-- Матчи -> Карты
ALTER TABLE matches ADD CONSTRAINT fk_matches_map 
FOREIGN KEY (map_id) REFERENCES maps(id);

-- Команды -> Матчи
ALTER TABLE teams ADD CONSTRAINT fk_teams_match 
FOREIGN KEY (match_id) REFERENCES matches(id);

-- Статистика -> Игроки
ALTER TABLE player_match_performance ADD CONSTRAINT fk_performance_player 
FOREIGN KEY (player_id) REFERENCES players(id);

-- Статистика -> Матчи
ALTER TABLE player_match_performance ADD CONSTRAINT fk_performance_match 
FOREIGN KEY (match_id) REFERENCES matches(id);

-- Статистика -> Команды
ALTER TABLE player_match_performance ADD CONSTRAINT fk_performance_team 
FOREIGN KEY (team_id) REFERENCES teams(id);

-- Статистика -> Герои
ALTER TABLE player_match_performance ADD CONSTRAINT fk_performance_hero 
FOREIGN KEY (hero_id) REFERENCES heroes(id);

-- История -> Игроки
ALTER TABLE matchmaking_history ADD CONSTRAINT fk_history_player 
FOREIGN KEY (player_id) REFERENCES players(id);

-- История -> Типы очередей
ALTER TABLE matchmaking_history ADD CONSTRAINT fk_history_queue 
FOREIGN KEY (queue_id) REFERENCES matchmaking_queues(id);

-- Данные

INSERT INTO players (username, skill_rating, wins_count, losses_count) VALUES
('Tamori', 1500, 10, 5),
('AndreyPRO100', 1600, 6, 10),
('Ivan2004', 1600, 2, 3),
('qwerty', 1600, 14, 1),
('Anuytick_jpg', 1600, 15, 8);

INSERT INTO clans (name, tag, leader_id, clan_rating, members_count) VALUES
('PupupuClan', '[PUPUPU]', 1, 1550, 2),
('LeleleClan', '[LELELE]', 2, 3000, 5);

UPDATE players SET clan_id = 1 WHERE id IN (1, 2);
UPDATE players SET clan_id = 2 WHERE id IN (3, 4, 5);

INSERT INTO heroes (name, role) VALUES
('Jett', 'Duelist'),
('Sage', 'Sentinel'),
('Clove', 'Controller'),
('Reyna', 'Duelist'),
('Gekko', 'Initiator'),
('Phoenix', 'Duelist');

INSERT INTO maps (name) VALUES
('Lotus'),
('Bind'),
('Abyss'),
('Pearl'),
('Heaven');

INSERT INTO matchmaking_queues (name, team_size, rating_tolerance) VALUES
('Casual 1v1', 1, 300),
('Ranked 5v5', 5, 200),
('Unrated', 5, 500);

INSERT INTO matches (queue_id, map_id, status, average_rating, rating_disparity) VALUES
(1, 1, 'finished', 1550, 100),
(2, 2, 'finished', 1600, 150),
(2, 3, 'finished', 1580, 120),
(3, 4, 'finished', 1620, 200),
(3, 5, 'finished', 1570, 180);


INSERT INTO teams (match_id, team_number, side, average_rating, result) VALUES
-- 1
(1, 1, 'blue', 1500, 'win'),
(1, 2, 'red', 1600, 'loss'),
-- 2
(2, 1, 'blue', 1550, 'win'),
(2, 2, 'red', 1650, 'loss'),
-- 3
(3, 1, 'blue', 1520, 'loss'),
(3, 2, 'red', 1640, 'win'),
-- 4
(4, 1, 'blue', 1500, 'win'),
(4, 2, 'red', 1740, 'loss'),
-- 5
(5, 1, 'blue', 1490, 'loss'),
(5, 2, 'red', 1650, 'win');


INSERT INTO player_match_performance (player_id, match_id, team_id, hero_id, kills, deaths, rating_change) VALUES
-- 1
(1, 1, 1, 1, 10, 3, +25),  -- тмр джетт
(2, 1, 2, 2, 8, 5, -15),   -- андрей сейдж
-- 2
(1, 2, 3, 1, 15, 8, +20),  -- тмр джетт
(2, 2, 4, 3, 12, 10, -10), -- андрей клов
(3, 2, 3, 4, 10, 7, +18),  -- иван рейна
(4, 2, 4, 5, 8, 12, -12),  -- кверти гекко
(5, 2, 3, 6, 14, 6, +22),  -- джпг феникс
-- 3
(1, 3, 5, 1, 18, 5, +30),  -- тмр джетт
(2, 3, 6, 2, 9, 11, -18),  -- андрей сейдж
(3, 3, 6, 4, 13, 8, +25),  -- иван рейна
-- 4
(4, 4, 7, 5, 11, 9, +15),  -- кверти гекко
(5, 4, 8, 6, 16, 4, +28),  -- джпг феникс
-- 5
(1, 5, 9, 1, 12, 10, -5),  -- тмр джетт
(4, 5, 10, 3, 14, 7, +20); -- кверти клов

INSERT INTO matchmaking_history (player_id, queue_id, join_time, match_found_time, total_wait_seconds) VALUES
(1, 1, '2024-01-15 14:00:00', '2024-01-15 14:01:30', 90),
(2, 1, '2024-01-15 14:00:10', '2024-01-15 14:01:30', 80),
(1, 2, '2024-01-15 15:00:00', '2024-01-15 15:02:00', 120),
(2, 2, '2024-01-15 15:00:30', '2024-01-15 15:02:00', 90),
(3, 2, '2024-01-15 15:00:45', '2024-01-15 15:02:00', 75);