-- Initial MySQL setup script
-- Runs once on first container startup

CREATE DATABASE IF NOT EXISTS `appdb`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `appdb_test`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Grant privileges to application user
GRANT ALL PRIVILEGES ON `appdb`.* TO 'appuser'@'%';
GRANT ALL PRIVILEGES ON `appdb_test`.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
