-- --------------------------------------------------------
-- Table `jail` pour le script de TIG
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `jail` (
  `identifier` VARCHAR(60) NOT NULL,
  `tasks` INT(11) NOT NULL DEFAULT '0',
  `raison` VARCHAR(255) NOT NULL DEFAULT '',
  `date` VARCHAR(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
