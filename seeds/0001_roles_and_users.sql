-- ===========================================================================
-- Seed 01 : roles, demo accounts and taxonomy
--
-- Every demo account uses the password  Password123!
-- The hash below is a real bcrypt digest of it (cost 10), so you can log in
-- through the User Service straight after seeding. Demo data only - never ship
-- these accounts to an environment reachable from the internet.
-- ===========================================================================

INSERT INTO identity.roles (name, description) VALUES
  ('student',    'Can enrol in courses, track progress and take quizzes.'),
  ('instructor', 'Can author courses, lessons, articles and quizzes.'),
  ('admin',      'Full administrative access to every service.')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO identity.users
  (id, email, password_hash, full_name, headline, bio, avatar_url, status, email_verified_at)
VALUES
  ('11111111-1111-4111-8111-111111111111', 'admin@learning.test',
   '$2b$10$GniVgK067gfhChrCvr0QZ.Nndd0cbNv3hSyVq8naKxxhOzx7kgVVK',
   'Ada Admin', 'Platform administrator', 'Keeps the lights on.',
   'https://i.pravatar.cc/240?img=47', 'active', UTC_TIMESTAMP(3)),

  ('22222222-2222-4222-8222-222222222222', 'grace@learning.test',
   '$2b$10$GniVgK067gfhChrCvr0QZ.Nndd0cbNv3hSyVq8naKxxhOzx7kgVVK',
   'Grace Ramirez', 'Backend engineer and instructor',
   'Fifteen years of building APIs, now mostly explaining them.',
   'https://i.pravatar.cc/240?img=32', 'active', UTC_TIMESTAMP(3)),

  ('33333333-3333-4333-8333-333333333333', 'kenji@learning.test',
   '$2b$10$GniVgK067gfhChrCvr0QZ.Nndd0cbNv3hSyVq8naKxxhOzx7kgVVK',
   'Kenji Watanabe', 'Data engineer',
   'Writes SQL for a living and for fun, which worries people.',
   'https://i.pravatar.cc/240?img=12', 'active', UTC_TIMESTAMP(3)),

  ('44444444-4444-4444-8444-444444444444', 'sam@learning.test',
   '$2b$10$GniVgK067gfhChrCvr0QZ.Nndd0cbNv3hSyVq8naKxxhOzx7kgVVK',
   'Sam Okafor', 'Learning to code', 'Career changer, six months in.',
   'https://i.pravatar.cc/240?img=68', 'active', UTC_TIMESTAMP(3)),

  ('55555555-5555-4555-8555-555555555555', 'lena@learning.test',
   '$2b$10$GniVgK067gfhChrCvr0QZ.Nndd0cbNv3hSyVq8naKxxhOzx7kgVVK',
   'Lena Novak', 'Frontend developer', 'Refuses to write CSS without a grid.',
   'https://i.pravatar.cc/240?img=5', 'active', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

INSERT INTO identity.user_roles (user_id, role_id)
SELECT u.id, r.id
  FROM (
    SELECT 'admin@learning.test' AS email, 'admin'      AS role_name
    UNION ALL SELECT 'admin@learning.test', 'instructor'
    UNION ALL SELECT 'grace@learning.test', 'instructor'
    UNION ALL SELECT 'kenji@learning.test', 'instructor'
    UNION ALL SELECT 'sam@learning.test',   'student'
    UNION ALL SELECT 'lena@learning.test',  'student'
  ) v
  JOIN identity.users u ON u.email = v.email
  JOIN identity.roles r ON r.name = v.role_name
ON DUPLICATE KEY UPDATE granted_at = identity.user_roles.granted_at;

-- ---------------------------------------------------------------------------
-- Categories and tags
-- ---------------------------------------------------------------------------
INSERT INTO catalog.categories (id, slug, name, description, `position`) VALUES
  ('aaaaaaa1-0000-4000-8000-000000000001', 'backend',   'Backend Development', 'APIs, services and everything behind the browser.', 1),
  ('aaaaaaa1-0000-4000-8000-000000000002', 'databases', 'Databases',            'Modelling, querying and operating data stores.',    2),
  ('aaaaaaa1-0000-4000-8000-000000000003', 'frontend',  'Frontend Development', 'Markup, styling and browser runtime.',              3)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO catalog.tags (id, slug, name) VALUES
  ('bbbbbbb1-0000-4000-8000-000000000001', 'nodejs',        'Node.js'),
  ('bbbbbbb1-0000-4000-8000-000000000002', 'microservices', 'Microservices'),
  ('bbbbbbb1-0000-4000-8000-000000000003', 'mysql',         'MySQL'),
  ('bbbbbbb1-0000-4000-8000-000000000004', 'sql',           'SQL'),
  ('bbbbbbb1-0000-4000-8000-000000000005', 'php',           'PHP'),
  ('bbbbbbb1-0000-4000-8000-000000000006', 'rest-api',      'REST API'),
  ('bbbbbbb1-0000-4000-8000-000000000007', 'architecture',  'Architecture')
ON DUPLICATE KEY UPDATE name = VALUES(name);
