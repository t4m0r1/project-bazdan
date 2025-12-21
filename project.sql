
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
    clan_rating INT DEFAULT 1000,
    members_count INT DEFAULT 0
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

-- Связи табл

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

INSERT INTO clans (name, tag, leader_id, clan_rating) VALUES
('PupupuClan', '[PUPUPU]', NULL, 1550),
('LeleleClan', '[LELELE]', NULL, 3000);

INSERT INTO players (username, skill_rating, clan_id, wins_count, losses_count) VALUES
('Tamori', 1500, 1, 10, 5),
('AndreyPRO100', 1600, 1, 6, 10),
('Ivan2004', 1600, 2, 2, 3),
('qwerty', 1600, 2, 14, 1),
('Anuytick_jpg', 1600, 2, 15, 8);

UPDATE clans SET leader_id = 1 WHERE id = 1;
UPDATE clans SET leader_id = 2 WHERE id = 2;

INSERT INTO matches (queue_id, map_id, status, start_time, average_rating, rating_disparity) VALUES
(1, 1, 'finished', '2025-01-15 14:00:00', 1550, 100),
(2, 2, 'finished', '2025-01-15 15:00:00', 1600, 150),
(2, 3, 'finished', '2025-01-15 16:00:00', 1580, 120),
(3, 4, 'finished', '2025-01-15 17:00:00', 1620, 200),
(3, 5, 'finished', '2025-01-15 18:00:00', 1570, 180);

INSERT INTO teams (match_id, team_number, side, average_rating, result) VALUES
(1, 1, 'blue', 1500, 'win'),
(1, 2, 'red', 1600, 'loss'),
(2, 1, 'blue', 1550, 'win'),
(2, 2, 'red', 1650, 'loss'),
(3, 1, 'blue', 1520, 'loss'),
(3, 2, 'red', 1640, 'win'),
(4, 1, 'blue', 1500, 'win'),
(4, 2, 'red', 1740, 'loss'),
(5, 1, 'blue', 1490, 'loss'),
(5, 2, 'red', 1650, 'win');

INSERT INTO player_match_performance (player_id, match_id, team_id, hero_id, kills, deaths, rating_change) VALUES
-- Матч 1
(1, 1, 1, 1, 10, 3, 25),  -- тмр джетт 
(2, 1, 2, 2, 8, 5, -15),   -- андрей сейдж 
-- Матч 2
(1, 2, 3, 1, 15, 8, 20),  -- тмр джетт
(2, 2, 4, 3, 12, 10, -10), -- андрей клов 
(3, 2, 3, 4, 10, 7, 18),  -- иван рейна 
(4, 2, 4, 5, 8, 12, -12),  -- кверти гекко 
(5, 2, 3, 6, 14, 6, 22),  -- джпг феникс 
-- Матч 3
(1, 3, 5, 1, 18, 5, 30),  -- тмр джетт
(2, 3, 6, 2, 9, 11, -18),  -- андрей сейдж
(3, 3, 6, 4, 13, 8, 25),  -- иван рейна
-- Матч 4
(4, 4, 7, 5, 11, 9, 15),  -- кверти гекко
(5, 4, 8, 6, 16, 4, 28),  -- джпг феникс
-- Матч 5
(1, 5, 9, 1, 12, 10, -5),  -- тмр джетт
(4, 5, 10, 3, 14, 7, 20); -- кверти клов

INSERT INTO matchmaking_history (player_id, queue_id, join_time, match_found_time, total_wait_seconds) VALUES
(1, 1, '2025-01-15 14:00:00', '2025-01-15 14:01:30', 90),
(2, 1, '2025-01-15 14:00:10', '2025-01-15 14:01:30', 80),
(1, 2, '2025-01-15 15:00:00', '2025-01-15 15:02:00', 120),
(2, 2, '2025-01-15 15:00:30', '2025-01-15 15:02:00', 90),
(3, 2, '2025-01-15 15:00:45', '2025-01-15 15:02:00', 75);

-- Проверка что таблицы не пустые

SELECT 'players' as table_name, COUNT(*) as records FROM players
UNION ALL SELECT 'clans', COUNT(*) FROM clans
UNION ALL SELECT 'heroes', COUNT(*) FROM heroes
UNION ALL SELECT 'maps', COUNT(*) FROM maps
UNION ALL SELECT 'matchmaking_queues', COUNT(*) FROM matchmaking_queues
UNION ALL SELECT 'matches', COUNT(*) FROM matches
UNION ALL SELECT 'teams', COUNT(*) FROM teams
UNION ALL SELECT 'player_match_performance', COUNT(*) FROM player_match_performance
UNION ALL SELECT 'matchmaking_history', COUNT(*) FROM matchmaking_history
ORDER BY table_name;

-- Задания

-- 1. Выбрать наиболее часто выбираемых героев, топ 5
SELECT 
    h.name AS hero_name,
    h.role AS hero_role,
    COUNT(pmp.id) AS times_picked,
    ROUND(AVG(pmp.kills), 1) AS avg_kills,
    ROUND(AVG(pmp.deaths), 1) AS avg_deaths,
    ROUND(AVG(pmp.kills::DECIMAL / NULLIF(pmp.deaths, 0)), 2) AS avg_kd_ratio
FROM player_match_performance pmp
JOIN heroes h ON pmp.hero_id = h.id
GROUP BY h.id, h.name, h.role
ORDER BY times_picked DESC
LIMIT 5;

-- 2. Выбрать наиболее часто выбираемого героя в 'x' карте (x любой id существующей карты)
SELECT 
    h.name AS hero_name,
    h.role AS hero_role,
    m.name AS map_name,
    COUNT(pmp.id) AS times_picked_on_map
FROM player_match_performance pmp
JOIN heroes h ON pmp.hero_id = h.id
JOIN matches mat ON pmp.match_id = mat.id
JOIN maps m ON mat.map_id = m.id
WHERE mat.map_id = 3  -- 'х' карта
GROUP BY h.id, h.name, h.role, m.name
ORDER BY times_picked_on_map DESC
LIMIT 1;

-- 3. Сумма игр игроков 'x' клана
SELECT 
    c.name AS clan_name,
    SUM(p.wins_count + p.losses_count) AS total_games
FROM clans c
JOIN players p ON c.id = p.clan_id
WHERE c.id = 2  -- 'х' клан
GROUP BY c.id, c.name;