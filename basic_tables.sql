DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(90) NOT NULL,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `password` CHAR(40) NOT NULL COMMENT 'SHA1 hash',
    `date_added` DATETIME NOT NULL,
    `status` ENUM('active', 'deactivated', 'on hold') NOT NULL DEFAULT 'active',
    PRIMARY KEY (`user_id`),
	UNIQUE (`email`)
);
