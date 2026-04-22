-- changeset pranithreddym:1.0.0-004
-- comment: Seed initial reference data (categories + admin user)

INSERT INTO `categories` (`name`, `slug`, `description`, `is_active`) VALUES
    ('Electronics',     'electronics',      'Electronic devices and accessories',   1),
    ('Clothing',        'clothing',         'Apparel and fashion items',            1),
    ('Home & Garden',   'home-garden',      'Home improvement and garden supplies', 1),
    ('Sports',          'sports',           'Sporting goods and equipment',         1),
    ('Books',           'books',            'Books, e-books and educational media', 1);

-- Default admin user (password_hash is bcrypt of "Admin@12345" — change in production)
INSERT INTO `users`
    (`uuid`, `email`, `username`, `password_hash`, `first_name`, `last_name`, `is_active`, `is_verified`, `role`)
VALUES (
    UUID(),
    'admin@example.com',
    'admin',
    '$2b$12$K9BvCB7XqVzjFZFT5V1h4.JHPqVZ2Z2Y9FU6G9nSqJhL0BYxQOFGy',
    'System',
    'Administrator',
    1,
    1,
    'admin'
);
