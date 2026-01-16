-- rollback: remove seeded reference data
DELETE FROM `users`   WHERE `username` = 'admin';
DELETE FROM `categories` WHERE `slug` IN ('electronics','clothing','home-garden','sports','books');
