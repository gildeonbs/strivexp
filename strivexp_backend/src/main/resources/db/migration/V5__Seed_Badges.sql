INSERT INTO badges (id, code, name, description, icon, xp_reward) VALUES
-- Streak Badges
(gen_random_uuid(), 'STREAK_3', 'Streak Keeper', 'Maintain a 3-day activity streak', 'leaf_lightning', 50),
(gen_random_uuid(), 'STREAK_7', 'In Flames', 'Maintain a 7-day activity streak', 'leaf_fire', 100),
(gen_random_uuid(), 'STREAK_10', 'Streak Champion', 'Maintain a 10-day activity streak', 'leaf_', 150),

-- Level Badges
(gen_random_uuid(), 'LEVEL_5', 'Rising Star', 'Reach Level 5', 'leaf_star_bronze', 100),
(gen_random_uuid(), 'LEVEL_10', 'Pathfinder', 'Reach Level 10', 'leaf_star_silver', 200),
(gen_random_uuid(), 'LEVEL_20', 'Trailblazer', 'Reach Level 20', 'leaf_star_gold', 400),
(gen_random_uuid(), 'LEVEL_50', 'Legend', 'Reach Level 50', 'leaf_star_diamond', 1000),

-- Category Completion Badges
(gen_random_uuid(), 'FIT', 'Fitness Focused', 'Complete activities in the Fitness category', 'leaf_fitness_dumbbell', 75),
(gen_random_uuid(), 'MIN', 'Mindful Moment', 'Complete activities in the Mindfulness category', 'leaf_mindfulness_lotus', 75),
(gen_random_uuid(), 'MND', 'Lifelong Learner', 'Complete activities in the Mind & Learning category', 'leaf_ind_brain', 75),
(gen_random_uuid(), 'HLT', 'Healthy Habits', 'Complete activities in the Body & Health category', 'leaf_health_heart', 75),
(gen_random_uuid(), 'EMP', 'Kindness Champion', 'Complete activities in the Kindness & Empathy category', 'leaf_empathy_hands', 75),
(gen_random_uuid(), 'MBW', 'Inner Balance', 'Complete activities in the Mindfulness & Mental Well-being category', 'leaf_mental_balance', 75),
(gen_random_uuid(), 'CRT', 'Creative Spark', 'Complete activities in the Creativity & Curiosity category', 'leaf_creative_lightbulb', 75),
(gen_random_uuid(), 'ENV', 'Earth Guardian', 'Complete activities in the Environment & Responsibility category', 'leaf_globe', 75)

ON CONFLICT (code) DO NOTHING;

