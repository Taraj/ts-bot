-- phpMyAdmin SQL Dump
-- version 4.6.6deb4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Czas generowania: 24 Gru 2018, 06:04
-- Wersja serwera: 10.1.26-MariaDB-0+deb9u1
-- Wersja PHP: 7.0.30-0+deb9u1


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `teamSpeak3`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`testy`@`localhost` PROCEDURE `channel_create` (IN `cid` INT, IN `canDelete` INT, IN `client_database_id` INT)  NO SQL
INSERT INTO `channels` (`id`, `TS_cid`, `channel_created`, `can_delete`, `clients_id`) VALUES (NULL, cid, UNIX_TIMESTAMP(), canDelete, (SELECT `id` FROM `clients` WHERE `clients`.`TS_client_database_id` = client_database_id))$$

CREATE DEFINER=`testy`@`localhost` PROCEDURE `channel_delete` (IN `cid` INT)  NO SQL
DELETE FROM `channels` WHERE `TS_cid` = cid$$

CREATE DEFINER=`testy`@`localhost` PROCEDURE `client_join` (IN `client_unique_identifier` VARCHAR(40), IN `client_database_id` INT, IN `clid` INT, IN `client_nickname` VARCHAR(40), IN `client_platform` VARCHAR(100), IN `connection_client_ip` VARCHAR(20), IN `client_version` VARCHAR(100), IN `client_country` VARCHAR(50), IN `cid` INT)  NO SQL
BEGIN
IF (SELECT COUNT(*) FROM `clients` WHERE `TS_client_database_id` = client_database_id) = 0
THEN
INSERT INTO `clients` (`id`, `TS_client_unique_identifier`, `TS_client_database_id`, `total_connection_time`, `total_inactivity_time`, `total_connection_count`, `first_connection`, `last_nickname`) VALUES (NULL, client_unique_identifier, client_database_id, 0, 0, 0, UNIX_TIMESTAMP(), client_nickname);
END IF;
INSERT INTO `connections` (`id`, `TS_clid`, `TS_client_nickname`, `TS_client_platform`, `TS_connection_client_ip`, `TS_client_version`, `connection_start`, `connection_stop`, `total_inactivity_time`, `total_connection_time`, `TS_client_country`, `clients_id`) VALUES (NULL, clid, client_nickname, client_platform, connection_client_ip, client_version, UNIX_TIMESTAMP(), 0, 0, 0, client_country, (SELECT id FROM clients WHERE `TS_client_database_id` = client_database_id));

CALL `client_move`(clid, cid);
END$$

CREATE DEFINER=`testy`@`localhost` PROCEDURE `client_leave` (IN `clid` INT, IN `client_idle_time` INT)  NO SQL
BEGIN
IF client_idle_time > 0
THEN
CALL `client_stop_inactivity`(clid, client_idle_time);
END IF;

SET @connectionID = `getConnectionID`(clid);

SELECT
	SUM(`inactivity_time`) INTO @inactivity_time
FROM `inactivity_periods` WHERE `connections_id` = @connectionID;

UPDATE `connections` SET
	`connection_stop` = UNIX_TIMESTAMP(),
	`total_inactivity_time` = @inactivity_time,
	`total_connection_time` = `connection_stop`-`connection_start`
WHERE `id` = @connectionID;

SELECT
	@clientID:=`clients_id`,
	@total_time:=`total_connection_time`,
	@inactivity_time2:= `total_inactivity_time`,
	@nick:=`TS_client_nickname`
FROM `connections` WHERE `id` = @connectionID;

UPDATE `clients` SET
	`total_connection_count` = `total_connection_count` + 1,
	`total_inactivity_time` =`total_inactivity_time` + @inactivity_time2,
	`total_connection_time` = `total_connection_time` + @total_time,
	`last_connection` = UNIX_TIMESTAMP(),
	`last_nickname` = @nick
WHERE `id` = @clientID;

END$$

CREATE DEFINER=`testy`@`localhost` PROCEDURE `client_move` (IN `clid` INT, IN `cid` INT)  NO SQL
IF `getConnectionID`(clid) IS NOT NULL
THEN
INSERT INTO `visited_channels` (`id`, `TS_cid`, `date`, `connections_id`) VALUES (NULL, cid, UNIX_TIMESTAMP(), `getConnectionID`(clid));
END IF$$

CREATE DEFINER=`testy`@`localhost` PROCEDURE `client_stop_inactivity` (IN `clid` INT, IN `client_idle_time` INT)  NO SQL
IF `getConnectionID`(clid) IS NOT NULL
THEN
INSERT INTO `inactivity_periods` (`id`, `inactivity_start`, `inactivity_stop`,`inactivity_time`, `connections_id`) VALUES (NULL, UNIX_TIMESTAMP() - client_idle_time, UNIX_TIMESTAMP(),client_idle_time, `getConnectionID`(clid));
END IF$$

--
-- Funkcje
--
CREATE DEFINER=`testy`@`localhost` FUNCTION `getConnectionID` (`clid` INT) RETURNS INT(11) NO SQL
BEGIN
SELECT `id` into @id FROM `connections` WHERE `TS_clid`=clid AND `connection_stop` = 0;
RETURN @id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `channels`
--

CREATE TABLE `channels` (
  `id` int(11) NOT NULL,
  `TS_cid` int(11) NOT NULL,
  `channel_created` int(11) NOT NULL,
  `can_delete` int(11) NOT NULL,
  `clients_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `TS_client_unique_identifier` varchar(40) NOT NULL,
  `TS_client_database_id` int(11) NOT NULL,
  `total_connection_time` int(11) NOT NULL,
  `total_inactivity_time` int(11) NOT NULL,
  `total_connection_count` int(11) NOT NULL,
  `last_nickname` varchar(100) NOT NULL,
  `last_connection` int(11) NOT NULL,
  `first_connection` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `connections`
--

CREATE TABLE `connections` (
  `id` int(11) NOT NULL,
  `TS_clid` int(11) NOT NULL,
  `TS_client_nickname` varchar(40) NOT NULL,
  `TS_client_platform` varchar(100) NOT NULL,
  `TS_connection_client_ip` varchar(20) NOT NULL,
  `TS_client_version` varchar(100) NOT NULL,
  `connection_start` int(11) NOT NULL,
  `connection_stop` int(11) NOT NULL,
  `total_inactivity_time` int(11) NOT NULL,
  `total_connection_time` int(11) NOT NULL,
  `TS_client_country` varchar(50) NOT NULL,
  `clients_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `inactivity_periods`
--

CREATE TABLE `inactivity_periods` (
  `id` int(11) NOT NULL,
  `inactivity_start` int(11) NOT NULL,
  `inactivity_stop` int(11) NOT NULL,
  `inactivity_time` int(11) NOT NULL,
  `connections_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `visited_channels`
--

CREATE TABLE `visited_channels` (
  `id` int(11) NOT NULL,
  `TS_cid` int(11) NOT NULL,
  `date` int(11) NOT NULL,
  `connections_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
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
