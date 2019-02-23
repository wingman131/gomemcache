delimiter $$

/*DROP DATABASE IF EXISTS `winningstr`$$*/
CREATE DATABASE IF NOT EXISTS `winningstr` DEFAULT CHARACTER SET utf8mb4$$
use `winningstr`$$

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(65) NOT NULL,
  `password` char(40) NOT NULL,
  `first_name` varchar(45) DEFAULT NULL,
  `last_name` varchar(45) DEFAULT NULL,
  `status` enum('unconfirmed','active','deactivated','on hold') NOT NULL DEFAULT 'active',
  `created` date NOT NULL,
  `gender` enum('m','f') DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `timezone` tinyint(4) unsigned DEFAULT '0',
  `week_start` enum('Sunday','Monday') NOT NULL DEFAULT 'Sunday',
  `mobile_phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  KEY `email` (`email`(3))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4$$

CREATE TABLE IF NOT EXISTS `goal` (
  `goal_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `name` varchar(45) NOT NULL,
  `description` varchar(255) NOT NULL,
  `mon` bit(1) NOT NULL DEFAULT b'1',
  `tue` bit(1) NOT NULL DEFAULT b'1',
  `wed` bit(1) NOT NULL DEFAULT b'1',
  `thu` bit(1) NOT NULL DEFAULT b'1',
  `fri` bit(1) NOT NULL DEFAULT b'1',
  `sat` bit(1) NOT NULL DEFAULT b'1',
  `sun` bit(1) NOT NULL DEFAULT b'1',
  `remind_email` bit(1) NOT NULL DEFAULT b'0',
  `remind_txt` bit(1) NOT NULL DEFAULT b'0',
  `remind_phone` bit(1) NOT NULL DEFAULT b'0',
  `status` enum('active','deactivated','on hold') NOT NULL DEFAULT 'active',
  `start` date DEFAULT NULL,
  `end` date DEFAULT NULL,
  PRIMARY KEY (`goal_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_goal_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4$$

CREATE TABLE IF NOT EXISTS `calendar` (
  `calendar_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `the_date` date DEFAULT NULL,
  `the_year` smallint(6) unsigned DEFAULT NULL,
  `the_month` tinyint(4) unsigned DEFAULT NULL,
  `day_of_year` smallint(6) unsigned DEFAULT NULL,
  `day_of_month` tinyint(4) unsigned DEFAULT NULL,
  `day_of_week` tinyint(4) unsigned DEFAULT NULL,
  `week_of_year` tinyint(4) unsigned DEFAULT NULL,
  `day_of_week_text` varchar(10) DEFAULT NULL,
  `day_of_week_short_text` varchar(3) DEFAULT NULL,
  `month_text` varchar(10) DEFAULT NULL,
  `month_short_text` varchar(4) DEFAULT NULL,
  `quarter` tinyint(4) unsigned DEFAULT NULL,
  PRIMARY KEY (`calendar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4$$

CREATE  TABLE `winningstr`.`goal_log` (
  `goal_log_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `goal_id` INT UNSIGNED NOT NULL ,
  `calendar_id` MEDIUMINT UNSIGNED NOT NULL ,
  `entered` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`goal_log_id`) ,
  UNIQUE INDEX `goal_id_UNIQUE` (`goal_id` ASC, `calendar_id` ASC) ,
  INDEX `fk_goal_log_1_idx` (`goal_id` ASC) ,
  CONSTRAINT `fk_goal_log_goal`
    FOREIGN KEY (`goal_id` )
    REFERENCES `winningstr`.`goal` (`goal_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_log_cal`
    FOREIGN KEY (`calendar_id`)
    REFERENCES `winningstr`.`calendar` (`calendar_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4$$

delimiter ;
