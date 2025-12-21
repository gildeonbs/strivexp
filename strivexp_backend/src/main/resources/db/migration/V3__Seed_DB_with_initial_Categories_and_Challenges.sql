-- CATEGORIES
-- id | code | created_at | description | icon | name
INSERT INTO categories (id, code, name, description, icon) VALUES
(gen_random_uuid(), 'MND', 'Mind & Learning', 'Cognitive growth and learning challenges', 'brain'),
(gen_random_uuid(), 'HLT', 'Body & Health', 'Physical health and body care activities', 'arm'),
(gen_random_uuid(), 'EMP', 'Kindness & Empathy', 'Compassionate actions and social connection', 'yellow-heart'),
(gen_random_uuid(), 'MBW', 'Mindfulness & Mental Well-being', 'Mental balance and emotional well-being practices', 'meditation-girl'),
(gen_random_uuid(), 'CRT', 'Creativity & Curiosity', 'Creative expression and exploration challenges', 'palette'),
(gen_random_uuid(), 'ENV', 'Environment & Responsibility', 'Sustainability and environmental responsibility actions', 'world')
    ON CONFLICT (code) DO NOTHING;


-- CHALLENGES
-- id | title | description | category_id | difficulty | xp_reward | motivation_text | is_active | recurrence | metadata | created_at | updated_at
INSERT INTO challenges (id, title, description, category_id, difficulty, xp_reward, motivation_text, recurrence) VALUES
(gen_random_uuid(), 'Reading Mini-Habit', 'Read at least 5 pages of a book today.', (SELECT id FROM categories WHERE code='MND'), 1, 15, 'Small readings build great knowledge','daily'),
(gen_random_uuid(), 'Healthy Walk', 'Take a 15-minute walk.', (SELECT id FROM categories WHERE code='HLT'), 1, 20, 'Every step brings you closer to a stronger version of yourself','daily'),
(gen_random_uuid(), 'Act of Kindness', 'Do a kind act for someone today, even a simple one.', (SELECT id FROM categories WHERE code='EMP'), 1, 15, 'Small gestures can transform someone’s day','daily'),
(gen_random_uuid(), 'Breathe and Relax', 'Pause for 2 minutes and practice deep, mindful breathing.', (SELECT id FROM categories WHERE code='MBW'), 1, 10, 'Your mind deserves a moment of peace','daily'),
(gen_random_uuid(), 'Creative Inspiration', 'Write a small creative idea or make a simple drawing.', (SELECT id FROM categories WHERE code='CRT'), 1, 15, 'Every great creation starts with a small sketch','daily'),
(gen_random_uuid(), 'Mindful Recycling', 'Properly separate today’s recyclable waste.', (SELECT id FROM categories WHERE code='ENV'), 1, 20, 'Your care helps the planet breathe better','daily'),
(gen_random_uuid(), 'Daily Learning', 'Watch an educational video of at least 5 minutes.', (SELECT id FROM categories WHERE code='MND'), 2, 25, 'Learning something new is an investment in your future','daily'),
(gen_random_uuid(), 'Body Movement', 'Stretch for at least 10 minutes.', (SELECT id FROM categories WHERE code='HLT'), 2, 30, 'Your body thanks you when you take care of it','daily'),
(gen_random_uuid(), 'Kind Words', 'Send a positive message to someone special.', (SELECT id FROM categories WHERE code='EMP'), 2, 20, 'Shared kindness returns multiplied','daily'),
(gen_random_uuid(), 'Zen Moment', 'Do a 5-minute guided meditation.', (SELECT id FROM categories WHERE code='MBW'), 2, 25, 'The calm you seek is also seeking you','daily'),
(gen_random_uuid(), 'Original Idea', 'Create something: write a paragraph, compose a sentence, or make a more detailed drawing.', (SELECT id FROM categories WHERE code='CRT'), 3, 40, 'Creating is giving life to what exists only in your imagination','daily'),
(gen_random_uuid(), 'Green Action', 'Reduce plastic use today (bottles, bags, etc.).', (SELECT id FROM categories WHERE code='ENV'), 2, 30, 'Small changes generate big impacts','daily'),
(gen_random_uuid(), 'Memory Challenge', 'Memorize a sentence, quote, or short poem.', (SELECT id FROM categories WHERE code='MND'), 3, 35, 'Your mind is more powerful than you imagine','daily'),
(gen_random_uuid(), 'Quick Workout', 'Do a 10-minute mini workout (jumping jacks, squats, etc.).', (SELECT id FROM categories WHERE code='HLT'), 3, 40, 'The energy you seek is born from action','daily'),
(gen_random_uuid(), 'Human Connection', 'Give someone a sincere compliment today.', (SELECT id FROM categories WHERE code='EMP'), 1, 15, 'An honest compliment can brighten an entire day','daily'),
(gen_random_uuid(), 'Morning Gratitude', 'List 3 things you are grateful for today.', (SELECT id FROM categories WHERE code='MBW'), 1, 20, 'Gratitude transforms what we have into enough','daily'),
(gen_random_uuid(), 'Creative Burst', 'Create something new using simple materials — an object, craft, or decoration.', (SELECT id FROM categories WHERE code='CRT'), 4, 60, 'Your creativity has no limits — explore it','daily'),
(gen_random_uuid(), 'Mindful Cleaning', 'Organize and clean a small space (desk, drawer, bag).', (SELECT id FROM categories WHERE code='ENV'), 2, 25, 'Clean environments create clear minds','daily'),
(gen_random_uuid(), 'Focused Study Challenge', 'Study a topic for 20 minutes without distractions.', (SELECT id FROM categories WHERE code='MND'), 4, 70, 'When you focus, you grow','daily'),
(gen_random_uuid(), 'Super Hydration', 'Drink at least 1 liter of water throughout the day.', (SELECT id FROM categories WHERE code='HLT'), 2, 30, 'Hydrating your body is also caring for your energy','daily');


/*
-- Brazilian portuguese text version
INSERT INTO challenges (id, title, description, category_id, difficulty, xp_reward, motivation_text, recurrence) VALUES
(gen_random_uuid(), 'Mini-Hábito de Leitura', 'Leia pelo menos 5 páginas de um livro hoje.', (SELECT id FROM categories WHERE code='MND'), 1, 15, 'Pequenas leituras constroem grandes saberes','daily'),
(gen_random_uuid(), 'Caminhada Saudável', 'Faça uma caminhada de 15 minutos.', (SELECT id FROM categories WHERE code='HLT'), 1, 20, 'Cada passo te aproxima de uma versão mais forte de você','daily'),
(gen_random_uuid(), 'Ato de Bondade', 'Faça uma gentileza para alguém hoje, mesmo que simples.', (SELECT id FROM categories WHERE code='EMP'), 1, 15, 'Pequenos gestos podem transformar o dia de alguém','daily'),
(gen_random_uuid(), 'Respire e Relaxe', 'Pare por 2 minutos e faça respiração profunda e consciente.', (SELECT id FROM categories WHERE code='MBW'), 1, 10, 'Sua mente merece um momento de paz','daily'),
(gen_random_uuid(), 'Inspiração Criativa', 'Escreva uma pequena ideia criativa ou desenho simples.', (SELECT id FROM categories WHERE code='CRT'), 1, 15, 'Toda grande criação começa com um pequeno rascunho','daily'),
(gen_random_uuid(), 'Reciclagem Consciente', 'Separe corretamente o lixo reciclável de hoje.', (SELECT id FROM categories WHERE code='ENV'), 1, 20, 'Seu cuidado ajuda o planeta a respirar melhor','daily'),
(gen_random_uuid(), 'Aprendizado do Dia', 'Assista a um vídeo educativo de no mínimo 5 minutos.', (SELECT id FROM categories WHERE code='MND'), 2, 25, 'Aprender algo novo é investir no seu futuro','daily'),
(gen_random_uuid(), 'Movimento do Corpo', 'Faça alongamentos por pelo menos 10 minutos.', (SELECT id FROM categories WHERE code='HLT'), 2, 30, 'Seu corpo agradece quando você cuida dele','daily'),
(gen_random_uuid(), 'Palavra Gentil', 'Envie uma mensagem positiva para alguém especial.', (SELECT id FROM categories WHERE code='EMP'), 2, 20, 'Gentileza compartilhada volta multiplicada','daily'),
(gen_random_uuid(), 'Momento Zen', 'Faça uma meditação guiada de 5 minutos.', (SELECT id FROM categories WHERE code='MBW'), 2, 25, 'A calma que você procura também te procura','daily'),
(gen_random_uuid(), 'Ideia Original', 'Crie algo: escreva um parágrafo, componha uma frase ou faça um desenho mais elaborado.', (SELECT id FROM categories WHERE code='CRT'), 3, 40, 'Criar é dar vida ao que só existe na sua imaginação','daily'),
(gen_random_uuid(), 'Ação Verde', 'Reduza o uso de plástico hoje (garrafas, sacolas etc.).', (SELECT id FROM categories WHERE code='ENV'), 2, 30, 'Pequenas mudanças geram grandes impactos','daily'),
(gen_random_uuid(), 'Desafio da Memória', 'Memorize uma frase, citação ou pequeno poema.', (SELECT id FROM categories WHERE code='MND'), 3, 35, 'Sua mente é mais poderosa do que você imagina','daily'),
(gen_random_uuid(), 'Treino Rápido', 'Realize um mini-treino de 10 minutos (polichinelos, agachamentos, etc.).', (SELECT id FROM categories WHERE code='HLT'), 3, 40, 'A energia que você busca nasce da ação','daily'),
(gen_random_uuid(), 'Conexão Humana', 'Faça um elogio sincero a alguém hoje.', (SELECT id FROM categories WHERE code='EMP'), 1, 15, 'Um elogio honesto pode iluminar um dia inteiro','daily'),
(gen_random_uuid(), 'Gratidão Matinal', 'Liste 3 coisas pelas quais você é grato hoje.', (SELECT id FROM categories WHERE code='MBW'), 1, 20, 'A gratidão transforma o que temos em suficiente','daily'),
(gen_random_uuid(), 'Explosão Criativa', 'Crie algo novo usando materiais simples — um objeto, artesanato ou decoração.', (SELECT id FROM categories WHERE code='CRT'), 4, 60, 'Sua criatividade não tem limites — explore','daily'),
(gen_random_uuid(), 'Limpeza Consciente', 'Organize e limpe um pequeno espaço (mesa, gaveta, bolsa).', (SELECT id FROM categories WHERE code='ENV'), 2, 25, 'Ambientes limpos criam mentes claras','daily'),
(gen_random_uuid(), 'Desafio do Estudo Focado', 'Estude um conteúdo por 20 minutos sem distrações.', (SELECT id FROM categories WHERE code='MND'), 4, 70, 'Quando você foca, você evolui','daily'),
(gen_random_uuid(), 'Super Hidratação', 'Beba ao menos 1 litro de água ao longo do dia.', (SELECT id FROM categories WHERE code='HLT'), 2, 30, 'Hidratar seu corpo é também cuidar da sua energia','daily');
*/

