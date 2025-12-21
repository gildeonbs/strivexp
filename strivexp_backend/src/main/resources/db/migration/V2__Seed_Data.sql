INSERT INTO categories (id, code, name, description, icon) VALUES 
(gen_random_uuid(), 'FIT', 'Fitness', 'Physical health challenges', 'dumbbell'),
(gen_random_uuid(), 'MIN', 'Mindfulness', 'Mental clarity tasks', 'brain')
    ON CONFLICT (code) DO NOTHING;


INSERT INTO challenges (id, title, category_id, difficulty, xp_reward, recurrence) VALUES
(gen_random_uuid(), 'Drink 2L Water', (SELECT id FROM categories WHERE code='FIT'), 1, 10, 'daily'),
(gen_random_uuid(), '10 Min Meditation', (SELECT id FROM categories WHERE code='MIN'), 2, 20, 'daily');


