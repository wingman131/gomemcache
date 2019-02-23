SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `poetry` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci ;
SHOW WARNINGS;
USE `poetry` ;

-- -----------------------------------------------------
-- Table `poetry`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`user` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`user` (
  `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `email` VARCHAR(75) NOT NULL ,
  `first_name` VARCHAR(50) NOT NULL ,
  `last_name` VARCHAR(50) NOT NULL ,
  `username` VARCHAR(50) NOT NULL ,
  `password` VARCHAR(255) NULL ,
  `salt` VARCHAR(255) NULL ,
  `status` ENUM('unconfirmed','active','deactivated','on hold') NOT NULL DEFAULT 'active' ,
  `created` DATETIME NOT NULL ,
  PRIMARY KEY (`user_id`) ,
  UNIQUE INDEX `email` (`email` ASC) ,
  UNIQUE INDEX `username` (`username` ASC) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `poetry`.`role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`role` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`role` (
  `role_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `description` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`role_id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `poetry`.`poem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`poem` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`poem` (
  `poem_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `body` VARCHAR(255) NOT NULL ,
  `about` VARCHAR(255) NOT NULL ,
  `status` ENUM('draft','published','unpublished','private','removed') NOT NULL DEFAULT 'draft' ,
  `created` DATETIME NOT NULL ,
  PRIMARY KEY (`poem_id`) ,
  INDEX `user_idx` (`user_id` ASC) ,
  CONSTRAINT `fk_user_p`
    FOREIGN KEY (`user_id` )
    REFERENCES `poetry`.`user` (`user_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `poetry`.`comment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`comment` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`comment` (
  `comment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `poem_id` INT UNSIGNED NOT NULL ,
  `user_id` INT UNSIGNED NOT NULL ,
  `comment_text` TEXT NOT NULL ,
  `status` ENUM('published','removed') NOT NULL DEFAULT 'published' ,
  `created` DATETIME NOT NULL ,
  `parent_comment_id` INT UNSIGNED NULL ,
  PRIMARY KEY (`comment_id`) ,
  INDEX `user_idx` (`user_id` ASC) ,
  INDEX `pcomment_idx` (`parent_comment_id` ASC) ,
  INDEX `poem_idx` (`poem_id` ASC) ,
  CONSTRAINT `fk_poem_c`
    FOREIGN KEY (`poem_id` )
    REFERENCES `poetry`.`poem` (`poem_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_user_c`
    FOREIGN KEY (`user_id` )
    REFERENCES `poetry`.`user` (`user_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_c`
    FOREIGN KEY (`parent_comment_id` )
    REFERENCES `poetry`.`comment` (`comment_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `poetry`.`like`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`like` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`like` (
  `like_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `poem_id` INT UNSIGNED NOT NULL ,
  `user_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`like_id`) ,
  INDEX `poem_idx` (`poem_id` ASC) ,
  INDEX `user_idx` (`user_id` ASC) ,
  CONSTRAINT `fk_poem_l`
    FOREIGN KEY (`poem_id` )
    REFERENCES `poetry`.`poem` (`poem_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_user_l`
    FOREIGN KEY (`user_id` )
    REFERENCES `poetry`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `poetry`.`favorite`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`favorite` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`favorite` (
  `favorite_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `poem_id` INT UNSIGNED NULL ,
  `poet_user_id` INT UNSIGNED NULL ,
  PRIMARY KEY (`favorite_id`) ,
  INDEX `user_idx` (`user_id` ASC) ,
  INDEX `poem_idx` (`poem_id` ASC) ,
  INDEX `poet_idx` (`poet_user_id` ASC) ,
  CONSTRAINT `fk_user_f`
    FOREIGN KEY (`user_id` )
    REFERENCES `poetry`.`user` (`user_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_poem_f`
    FOREIGN KEY (`poem_id` )
    REFERENCES `poetry`.`poem` (`poem_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `poet`
    FOREIGN KEY (`poet_user_id` )
    REFERENCES `poetry`.`user` (`user_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `poetry`.`user_role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poetry`.`user_role` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `poetry`.`user_role` (
  `user_role_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `role_id` TINYINT UNSIGNED NOT NULL ,
  PRIMARY KEY (`user_role_id`) ,
  INDEX `fk_user_id_ur_idx` (`user_id` ASC) ,
  INDEX `fk_role_id_ur_idx` (`role_id` ASC) ,
  UNIQUE INDEX `uniq_user_role` (`user_id` ASC, `role_id` ASC) ,
  CONSTRAINT `fk_user_id_ur`
    FOREIGN KEY (`user_id` )
    REFERENCES `poetry`.`user` (`user_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_role_id_ur`
    FOREIGN KEY (`role_id` )
    REFERENCES `poetry`.`role` (`role_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SHOW WARNINGS;
USE `poetry` ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


INSERT INTO`poetry`.`role` VALUES
('1', 'guest', 'guest/not logged in'),
('2', 'poet', 'poet/basic user'),
('3', 'moderator', 'moderator'),
('4', 'admin', 'administrator/superuser');
