-- phpMyAdmin SQL Dump
-- version 4.6.6deb4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Czas generowania: 25 Gru 2018, 07:14
-- Wersja serwera: 10.1.26-MariaDB-0+deb9u1
-- Wersja PHP: 7.0.30-0+deb9u1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `teamSpeak3-mrge`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `channel_create` (IN `cid` INT, IN `canDelete` INT, IN `client_database_id` INT)  NO SQL
INSERT INTO `channels` (`TS_cid`, `channel_created`, `can_delete`, `clients_id`) VALUES (cid, UNIX_TIMESTAMP(), canDelete, (SELECT `id` FROM `clients` WHERE `clients`.`TS_client_database_id` = client_database_id))$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `client_join` (IN `client_unique_identifier` VARCHAR(40), IN `client_database_id` INT, IN `clid` INT, IN `client_nickname` VARCHAR(40), IN `client_platform` VARCHAR(100), IN `connection_client_ip` VARCHAR(20), IN `client_version` VARCHAR(100), IN `client_country` VARCHAR(50), IN `cid` INT)  NO SQL
BEGIN
  SELECT `clients`.`id`
  INTO   @id
  FROM   `clients`
  WHERE  `clients`.`ts_client_database_id` = client_database_id;

  IF @id IS NULL then
  INSERT INTO `clients`
              (
                          `ts_client_unique_identifier`,
                          `ts_client_database_id`
              )
              VALUES
              (
                          client_unique_identifier,
                          client_database_id
              );

  SELECT `clients`.`id`
  INTO   @id
  FROM   `clients`
  WHERE  `clients`.`ts_client_database_id` = client_database_id;

  INSERT INTO `connections`
              (
                          `ts_clid`,
                          `ts_client_nickname`,
                          `ts_client_platform`,
                          `ts_connection_client_ip`,
                          `ts_client_version`,
                          `connection_start`,
                          `ts_client_country`,
                          `clients_id`
              )
              VALUES
              (
                          clid,
                          client_nickname,
                          client_platform,
                          connection_client_ip,
                          client_version,
                          unix_timestamp(),
                          client_country,
                          @id
              );

  UPDATE `clients`
  SET    `clients`.`first_connection_id` = `getconnectionid`(clid)
  WHERE  `clients`.`id`=@id;

  SELECT 0                AS `total_connection_time`,
         1                AS `total_connection_count`,
         0                AS`total_inactivity_time`,
         unix_timestamp() AS `first_connection`,
         unix_timestamp() AS `last_connection`;

  else
  SELECT `clients`.`total_connection_time`,
         `clients`.`total_connection_count` + 1 AS `total_connection_count`,
         `clients`.`total_inactivity_time`,
         `connections_last`.`connection_start`  AS `first_connection`,
         `connections_first`.`connection_start` AS `last_connection`
  FROM   `clients`
  JOIN   `connections` `connections_first`
  ON     `clients`.`first_connection_id`=`connections_first`.`id`
  JOIN   `connections` `connections_last`
  ON     `clients`.`last_connection_id`=`connections_last`.`id`
  WHERE  `clients`.`id`=@id;

  INSERT INTO `connections`
              (
                          `ts_clid`,
                          `ts_client_nickname`,
                          `ts_client_platform`,
                          `ts_connection_client_ip`,
                          `ts_client_version`,
                          `connection_start`,
                          `ts_client_country`,
                          `clients_id`
              )
              VALUES
              (
                          clid,
                          client_nickname,
                          client_platform,
                          connection_client_ip,
                          client_version,
                          unix_timestamp(),
                          client_country,
                          @id
              );

END IF;END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `client_leave` (IN `clid` INT, IN `client_idle_time` INT)  NO SQL
BEGIN
  IF client_idle_time > 0 THEN
  CALL `client_stop_inactivity`(clid, client_idle_time);
END IF;
set @connectionID = `getconnectionid`(clid);UPDATE `connections`
SET    `connection_stop` = unix_timestamp(),
       `total_connection_time` = `connection_stop` - `connection_start`
WHERE  `id` = @connectionID;SELECT @clients_id:=`clients_id`,
       @total_connection_time:=`total_connection_time`,
       @total_inactivity_time:= `total_inactivity_time`
FROM   `connections`
WHERE  `id` = @connectionID;UPDATE `clients`
SET    `total_inactivity_time` =`total_inactivity_time`  + @total_inactivity_time,
       `total_connection_time` = `total_connection_time` + @total_connection_time
WHERE  `id` = @clients_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `client_move` (IN `clid` INT, IN `cid` INT)  NO SQL
BEGIN
SET @id = `getConnectionID`(clid);
IF @id IS NOT NULL THEN
INSERT INTO `visited_channels` (`TS_cid`, `date`, `connections_id`) VALUES (cid, UNIX_TIMESTAMP(), @id);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `client_stop_inactivity` (IN `clid` INT, IN `client_idle_time` INT)  NO SQL
BEGIN
SET @id = `getConnectionID`(clid);
IF @id IS NOT NULL THEN
INSERT INTO `inactivity_periods` (`inactivity_start`, `inactivity_stop`,`inactivity_time`, `connections_id`) VALUES (UNIX_TIMESTAMP() - client_idle_time, UNIX_TIMESTAMP(), client_idle_time, @id);
END IF;
END$$

--
-- Funkcje
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getConnectionID` (`clid` INT) RETURNS INT(11) NO SQL
BEGIN
SELECT `id` into @id FROM `connections` WHERE `TS_clid`=clid AND `connection_stop` IS NULL;
RETURN @id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `channels`
--

CREATE TABLE `channels` (
  `id` int(11) NOT NULL,
  `TS_cid` int(11) DEFAULT NULL,
  `channel_created` int(11) DEFAULT NULL,
  `can_delete` int(11) DEFAULT NULL,
  `clients_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `TS_client_unique_identifier` varchar(40) DEFAULT NULL,
  `TS_client_database_id` int(11) DEFAULT NULL,
  `client_type` int(11) NOT NULL DEFAULT '0',
  `total_connection_time` int(11) NOT NULL DEFAULT '0',
  `total_inactivity_time` int(11) NOT NULL DEFAULT '0',
  `total_connection_count` int(11) NOT NULL DEFAULT '0',
  `last_connection_id` int(11) DEFAULT NULL,
  `first_connection_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `connections`
--

CREATE TABLE `connections` (
  `id` int(11) NOT NULL,
  `TS_clid` int(11) NOT NULL,
  `TS_client_nickname` varchar(40) DEFAULT NULL,
  `TS_client_platform` varchar(100) DEFAULT NULL,
  `TS_connection_client_ip` varchar(20) DEFAULT NULL,
  `TS_client_version` varchar(100) DEFAULT NULL,
  `connection_start` int(11) DEFAULT NULL,
  `connection_stop` int(11) DEFAULT NULL,
  `total_inactivity_time` int(11) NOT NULL DEFAULT '0',
  `total_connection_time` int(11) NOT NULL DEFAULT '0',
  `TS_client_country` varchar(50) DEFAULT NULL,
  `clients_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Wyzwalacze `connections`
--
DELIMITER $$
CREATE TRIGGER `last_connection_id` AFTER INSERT ON `connections` FOR EACH ROW UPDATE `clients` SET `clients`.`last_connection_id` = NEW.`id` WHERE `clients`.`id` = NEW.`clients_id`
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `total_connection_count` BEFORE INSERT ON `connections` FOR EACH ROW UPDATE `clients` SET `clients`.`total_connection_count` = `total_connection_count` + 1 WHERE `clients`.`id` = NEW.`clients_id`
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `inactivity_periods`
--

CREATE TABLE `inactivity_periods` (
  `id` int(11) NOT NULL,
  `inactivity_start` int(11) DEFAULT NULL,
  `inactivity_stop` int(11) DEFAULT NULL,
  `inactivity_time` int(11) DEFAULT NULL,
  `connections_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Wyzwalacze `inactivity_periods`
--
DELIMITER $$
CREATE TRIGGER `afk` AFTER INSERT ON `inactivity_periods` FOR EACH ROW UPDATE `connections` SET `connections`.`total_inactivity_time` = `connections`.`total_inactivity_time`+ NEW.`inactivity_time` WHERE `connections`.`id`=NEW.`connections_id`
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `online_clients`
-- (See below for the actual view)
--
CREATE TABLE `online_clients` (
`TS_clid` int(11)
,`TS_client_nickname` varchar(40)
,`TS_client_platform` varchar(100)
,`TS_connection_client_ip` varchar(20)
,`TS_client_version` varchar(100)
,`connection_start` int(11)
,`TS_client_country` varchar(50)
,`TS_client_database_id` int(11)
,`TS_client_unique_identifier` varchar(40)
);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `ranking_total_connection_count`
-- (See below for the actual view)
--
CREATE TABLE `ranking_total_connection_count` (
`id` int(11)
,`TS_client_unique_identifier` varchar(40)
,`TS_client_database_id` int(11)
,`client_type` int(11)
,`total_connection_time` int(11)
,`total_inactivity_time` int(11)
,`total_connection_count` int(11)
,`last_connection_id` int(11)
,`first_connection_id` int(11)
,`TS_client_nickname` varchar(40)
);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `ranking_total_connection_time`
-- (See below for the actual view)
--
CREATE TABLE `ranking_total_connection_time` (
`id` int(11)
,`TS_client_unique_identifier` varchar(40)
,`TS_client_database_id` int(11)
,`client_type` int(11)
,`total_connection_time` int(11)
,`total_inactivity_time` int(11)
,`total_connection_count` int(11)
,`last_connection_id` int(11)
,`first_connection_id` int(11)
,`TS_client_nickname` varchar(40)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `visited_channels`
--

CREATE TABLE `visited_channels` (
  `id` int(11) NOT NULL,
  `TS_cid` int(11) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  `connections_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura widoku `online_clients`
--
DROP TABLE IF EXISTS `online_clients`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `online_clients`  AS  select `connections`.`TS_clid` AS `TS_clid`,`connections`.`TS_client_nickname` AS `TS_client_nickname`,`connections`.`TS_client_platform` AS `TS_client_platform`,`connections`.`TS_connection_client_ip` AS `TS_connection_client_ip`,`connections`.`TS_client_version` AS `TS_client_version`,`connections`.`connection_start` AS `connection_start`,`connections`.`TS_client_country` AS `TS_client_country`,`clients`.`TS_client_database_id` AS `TS_client_database_id`,`clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier` from (`connections` join `clients` on((`clients`.`id` = `connections`.`clients_id`))) where isnull(`connections`.`connection_stop`) ;

-- --------------------------------------------------------

--
-- Struktura widoku `ranking_total_connection_count`
--
DROP TABLE IF EXISTS `ranking_total_connection_count`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ranking_total_connection_count`  AS  select `clients`.`id` AS `id`,`clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,`clients`.`TS_client_database_id` AS `TS_client_database_id`,`clients`.`client_type` AS `client_type`,`clients`.`total_connection_time` AS `total_connection_time`,`clients`.`total_inactivity_time` AS `total_inactivity_time`,`clients`.`total_connection_count` AS `total_connection_count`,`clients`.`last_connection_id` AS `last_connection_id`,`clients`.`first_connection_id` AS `first_connection_id`,`connections`.`TS_client_nickname` AS `TS_client_nickname` from (`clients` join `connections` on((`clients`.`last_connection_id` = `connections`.`id`))) where (`clients`.`client_type` = 0) order by `clients`.`total_connection_count` desc ;

-- --------------------------------------------------------

--
-- Struktura widoku `ranking_total_connection_time`
--
DROP TABLE IF EXISTS `ranking_total_connection_time`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ranking_total_connection_time`  AS  select `clients`.`id` AS `id`,`clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,`clients`.`TS_client_database_id` AS `TS_client_database_id`,`clients`.`client_type` AS `client_type`,`clients`.`total_connection_time` AS `total_connection_time`,`clients`.`total_inactivity_time` AS `total_inactivity_time`,`clients`.`total_connection_count` AS `total_connection_count`,`clients`.`last_connection_id` AS `last_connection_id`,`clients`.`first_connection_id` AS `first_connection_id`,`connections`.`TS_client_nickname` AS `TS_client_nickname` from (`clients` join `connections` on((`clients`.`last_connection_id` = `connections`.`id`))) where (`clients`.`client_type` = 0) order by `clients`.`total_connection_time` desc ;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indexes for table `channels`
--
ALTER TABLE `channels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `clients_id` (`clients_id`);

--
-- Indexes for table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `last_connection_id` (`last_connection_id`),
  ADD KEY `first_connection_id` (`first_connection_id`);

--
-- Indexes for table `connections`
--
ALTER TABLE `connections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `clients_id` (`clients_id`);

--
-- Indexes for table `inactivity_periods`
--
ALTER TABLE `inactivity_periods`
  ADD PRIMARY KEY (`id`),
  ADD KEY `connections_id` (`connections_id`);

--
-- Indexes for table `visited_channels`
--
ALTER TABLE `visited_channels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `connections_id` (`connections_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `channels`
--
ALTER TABLE `channels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT dla tabeli `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT dla tabeli `connections`
--
ALTER TABLE `connections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT dla tabeli `inactivity_periods`
--
ALTER TABLE `inactivity_periods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT dla tabeli `visited_channels`
--
ALTER TABLE `visited_channels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `channels`
--
ALTER TABLE `channels`
  ADD CONSTRAINT `channels_ibfk_1` FOREIGN KEY (`clients_id`) REFERENCES `clients` (`id`);

--
-- Ograniczenia dla tabeli `clients`
--
ALTER TABLE `clients`
  ADD CONSTRAINT `clients_ibfk_1` FOREIGN KEY (`last_connection_id`) REFERENCES `connections` (`id`),
  ADD CONSTRAINT `clients_ibfk_2` FOREIGN KEY (`first_connection_id`) REFERENCES `connections` (`id`);

--
-- Ograniczenia dla tabeli `connections`
--
ALTER TABLE `connections`
  ADD CONSTRAINT `connections_ibfk_1` FOREIGN KEY (`clients_id`) REFERENCES `clients` (`id`);

--
-- Ograniczenia dla tabeli `inactivity_periods`
--
ALTER TABLE `inactivity_periods`
  ADD CONSTRAINT `inactivity_periods_ibfk_1` FOREIGN KEY (`connections_id`) REFERENCES `connections` (`id`);

--
-- Ograniczenia dla tabeli `visited_channels`
--
ALTER TABLE `visited_channels`
  ADD CONSTRAINT `visited_channels_ibfk_1` FOREIGN KEY (`connections_id`) REFERENCES `connections` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
