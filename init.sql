-- --------------------------------------------------------

CREATE DATABASE TeamSpeakBotData;

-- --------------------------------------------------------

CREATE TABLE `TeamSpeakBotData`.`channels` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `TS_cid` int(11) DEFAULT NULL,
    `channel_created` int(11) DEFAULT NULL,
    `clients_id` int(11) DEFAULT NULL
);


CREATE TABLE `TeamSpeakBotData`.`clients` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT ,
    `TS_client_unique_identifier` varchar(40) DEFAULT NULL,
    `TS_client_database_id` int(11) DEFAULT NULL,
    `client_type` int(11) NOT NULL DEFAULT '0',
    `total_connection_time` int(11) NOT NULL DEFAULT '0',
    `total_inactivity_time` int(11) NOT NULL DEFAULT '0',
    `total_connection_count` int(11) NOT NULL DEFAULT '0',
    `last_connection_id` int(11) DEFAULT NULL,
    `first_connection_id` int(11) DEFAULT NULL
);


CREATE TABLE `TeamSpeakBotData`.`connections` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `TS_clid` int(11) NOT NULL,
    `TS_client_nickname` varchar(100) DEFAULT NULL,
    `TS_client_platform` varchar(100) DEFAULT NULL,
    `TS_connection_client_ip` varchar(100) DEFAULT NULL,
    `TS_client_version` varchar(100) DEFAULT NULL,
    `connection_start` int(11) DEFAULT NULL,
    `connection_stop` int(11) DEFAULT NULL,
    `total_inactivity_time` int(11) NOT NULL DEFAULT '0',
    `total_connection_time` int(11) NOT NULL DEFAULT '0',
    `TS_client_country` varchar(50) DEFAULT NULL,
    `clients_id` int(11) DEFAULT NULL
);


CREATE TABLE `TeamSpeakBotData`.`inactivity_periods` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `inactivity_start` int(11) DEFAULT NULL,
    `inactivity_stop` int(11) DEFAULT NULL,
    `inactivity_time` int(11) DEFAULT NULL,
    `connections_id` int(11) DEFAULT NULL
);


CREATE TABLE `TeamSpeakBotData`.`visited_channels` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `TS_cid` int(11) DEFAULT NULL,
    `date` int(11) DEFAULT NULL,
    `connections_id` int(11) DEFAULT NULL
);

-- --------------------------------------------------------

ALTER TABLE `TeamSpeakBotData`.`clients`
    ADD FOREIGN KEY (`last_connection_id`) REFERENCES `TeamSpeakBotData`.`connections`(`id`),
    ADD FOREIGN KEY (`first_connection_id`) REFERENCES `TeamSpeakBotData`.`connections`(`id`);


ALTER TABLE `TeamSpeakBotData`.`channels`
    ADD FOREIGN KEY (`clients_id`) REFERENCES `TeamSpeakBotData`.`clients` (`id`);


ALTER TABLE `TeamSpeakBotData`.`connections`
    ADD FOREIGN KEY (`clients_id`) REFERENCES `TeamSpeakBotData`.`clients` (`id`);


ALTER TABLE `TeamSpeakBotData`.`inactivity_periods`
    ADD FOREIGN KEY (`connections_id`) REFERENCES `TeamSpeakBotData`.`connections` (`id`);


ALTER TABLE `TeamSpeakBotData`.`visited_channels` 
    ADD FOREIGN KEY (`connections_id`) REFERENCES `TeamSpeakBotData`.`connections` (`id`);


-- --------------------------------------------------------


DELIMITER $$
CREATE FUNCTION `TeamSpeakBotData`.`getClientID`(`client_database_id` INT) RETURNS INT
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN 
    SELECT `clients`.`id` INTO @clientID FROM `TeamSpeakBotData`.`clients` WHERE `clients`.`TS_client_database_id` = client_database_id;
    RETURN @clientID; 
END $$


CREATE FUNCTION `TeamSpeakBotData`.`getConnectionID`(`clid` INT) RETURNS INT 
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SELECT `id` into @connectionId FROM `TeamSpeakBotData`.`connections` WHERE `TS_clid` = clid AND `connection_stop` IS NULL;
    RETURN @connectionId;
END $$
DELIMITER ;

-- --------------------------------------------------------

DELIMITER $$
CREATE  PROCEDURE `TeamSpeakBotData`.`client_join`(
    IN `client_unique_identifier` VARCHAR(40),
    IN `client_database_id` INT,
    IN `clid` INT,
    IN `client_nickname` VARCHAR(100),
    IN `client_platform` VARCHAR(100),
    IN `connection_client_ip` VARCHAR(100),
    IN `client_version` VARCHAR(100),
    IN `client_country` VARCHAR(50),
    IN `cid` INT
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SELECT `TeamSpeakBotData`.`getClientID`(client_database_id) INTO  @clientID;
    IF @clientID IS NULL THEN
        INSERT INTO `TeamSpeakBotData`.`clients` (
                        `TS_client_unique_identifier`,
                        `TS_client_database_id`
                    ) VALUES (
                        client_unique_identifier,
                        client_database_id
                    );
        SELECT `TeamSpeakBotData`.`getClientID`(client_database_id) INTO  @clientID;
        INSERT INTO `TeamSpeakBotData`.`connections` (
                        `TS_clid`,
                        `TS_client_nickname`,
                        `TS_client_platform`,
                        `TS_connection_client_ip`,
                        `TS_client_version`,
                        `connection_start`,
                        `TS_client_country`,
                        `clients_id`
                ) VALUES (
                        clid,
                        client_nickname,
                        client_platform,
                        connection_client_ip,
                        client_version,
                        unix_timestamp(),
                        client_country,
                        @clientID
                );
        UPDATE `TeamSpeakBotData`.`clients` SET
            `clients`.`first_connection_id` = `getConnectionID`(clid)
        WHERE `clients`.`id` = @clientID;

        SELECT  0                AS `total_connection_time`,
                1                AS `total_connection_count`,
                0                AS `total_inactivity_time`,
                unix_timestamp() AS `first_connection`,
                unix_timestamp() AS `last_connection`;
    ELSE
        SELECT 
            `clients`.`total_connection_time`,
            `clients`.`total_connection_count` + 1 AS `total_connection_count`,
            `clients`.`total_inactivity_time`,
            `connections_last`.`connection_start`  AS `last_connection`,
            `connections_first`.`connection_start` AS `first_connection`
        FROM `TeamSpeakBotData`.`clients`
            JOIN `TeamSpeakBotData`.`connections` `connections_first` ON `clients`.`first_connection_id` = `connections_first`.`id`
            JOIN `TeamSpeakBotData`.`connections` `connections_last` ON `clients`.`last_connection_id` = `connections_last`.`id`
        WHERE  `clients`.`id` = @clientID;

        INSERT INTO `TeamSpeakBotData`.`connections` (
                        `TS_clid`,
                        `TS_client_nickname`,
                        `TS_client_platform`,
                        `TS_connection_client_ip`,
                        `TS_client_version`,
                        `connection_start`,
                        `TS_client_country`,
                        `clients_id`
                    ) VALUES (
                        clid,
                        client_nickname,
                        client_platform,
                        connection_client_ip,
                        client_version,
                        unix_timestamp(),
                        client_country,
                        @clientID
                    );

    END IF;
    SELECT `TeamSpeakBotData`.`getConnectionID`(clid) INTO  @connectionID;

    UPDATE `TeamSpeakBotData`.`clients` SET 
        `clients`.`last_connection_id` = @connectionID,
        `clients`.`total_connection_count` = `total_connection_count` + 1
    WHERE `clients`.`id` = @clientID;

    INSERT INTO `TeamSpeakBotData`.`visited_channels` (
            `TS_cid`,
            `date`,
            `connections_id`
        ) VALUES (
            cid,
            UNIX_TIMESTAMP(),
            @connectionID
        );

END $$



CREATE PROCEDURE `TeamSpeakBotData`.`client_leave`(
    IN `clid` INT,
    IN `client_idle_time` INT
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
   
    SET @connectionID := `TeamSpeakBotData`.`getConnectionID`(clid);
    SET @unix_timestamp := unix_timestamp();

     IF @connectionID IS NOT NULL THEN
        IF client_idle_time > 0 THEN
            INSERT INTO `TeamSpeakBotData`.`inactivity_periods` (
                    `inactivity_start`,
                    `inactivity_stop`,
                    `inactivity_time`, 
                    `connections_id`
                ) VALUES (
                    unix_timestamp - client_idle_time,
                    unix_timestamp,
                    client_idle_time, 
                    @connectionID
                );

            UPDATE `TeamSpeakBotData`.`connections` SET
                `connections`.`total_inactivity_time` = `connections`.`total_inactivity_time` + client_idle_time,
                `connections`.`connection_stop` = @unix_timestamp,
                `connections`.`total_connection_time` = @unix_timestamp - `connections`.`connection_start`
            WHERE `connections`.`id` = @connectionID;
        ELSE
            UPDATE `TeamSpeakBotData`.`connections` SET
                `connections`.`connection_stop` = @unix_timestamp,
                `connections`.`total_connection_time` = @unix_timestamp - `connections`.`connection_start`
            WHERE `connections`.`id`= @connectionID;
        END IF;

        SELECT
            `connections`.`clients_id`,
            `connections`.`total_connection_time`,
            `connections`.`total_inactivity_time`
        INTO
            @clientID,
            @total_connection_time,
            @total_inactivity_time
        FROM `TeamSpeakBotData`.`connections`
        WHERE `connections`.`id`= @connectionID;

        UPDATE `TeamSpeakBotData`.`clients` SET
            `clients`.`total_inactivity_time` = `clients`.`total_inactivity_time` + @total_inactivity_time,
            `clients`.`total_connection_time` = `clients`.`total_connection_time` + @total_connection_time
        WHERE `clients`.`id` = @clientID;
    END IF;
END $$



CREATE PROCEDURE `TeamSpeakBotData`.`client_move`(
    IN `clid` INT,
    IN `cid` INT
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SELECT `TeamSpeakBotData`.`getConnectionID`(clid) INTO  @connectionID;
    IF @connectionID IS NOT NULL THEN
        INSERT INTO `TeamSpeakBotData`.`visited_channels` (
                `TS_cid`,
                `date`,
                `connections_id`
            ) VALUES (
                cid,
                UNIX_TIMESTAMP(),
                @connectionID
            );
    END IF;
END $$



CREATE  PROCEDURE `TeamSpeakBotData`.`client_stop_inactivity`(
    IN `clid` INT,
    IN `client_idle_time` INT
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SELECT `TeamSpeakBotData`.`getConnectionID`(clid) INTO  @connectionID;
    IF @connectionID IS NOT NULL THEN
        INSERT INTO `TeamSpeakBotData`.`inactivity_periods` (
                `inactivity_start`,
                `inactivity_stop`,
                `inactivity_time`, 
                `connections_id`
             ) VALUES (
                UNIX_TIMESTAMP() - client_idle_time,
                UNIX_TIMESTAMP(),
                client_idle_time, 
                @connectionID
            );


        UPDATE `TeamSpeakBotData`.`connections` SET
            `connections`.`total_inactivity_time` = `connections`.`total_inactivity_time` + client_idle_time
        WHERE `connections`.`id` = @connectionID;
    END IF;
END $$



CREATE  PROCEDURE `TeamSpeakBotData`.`channel_create`(
    IN `cid` INT, 
    IN `client_database_id` INT
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    INSERT INTO `TeamSpeakBotData`.`channels` (
            `TS_cid`, 
            `channel_created`,
            `clients_id`
        ) VALUES (
            cid,
            UNIX_TIMESTAMP(),
            `getClientID`(client_database_id)
        );
END $$


DELIMITER ;
-- --------------------------------------------------------

CREATE 
SQL SECURITY INVOKER
VIEW `TeamSpeakBotData`.`ranking_total_connection_time` AS
SELECT 
    `clients`.`id` AS `id`,
    `clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,
    `clients`.`TS_client_database_id` AS `TS_client_database_id`,
    `connections`.`TS_client_nickname` AS `TS_client_nickname`,
    `clients`.`total_connection_time` AS `total_connection_time`,
    `clients`.`total_inactivity_time` AS `total_inactivity_time` 
FROM `TeamSpeakBotData`.`clients`
JOIN `TeamSpeakBotData`.`connections` ON `clients`.`last_connection_id` = `connections`.`id`
WHERE `clients`.`client_type` = 0
ORDER BY `clients`.`total_connection_time` DESC;


CREATE 
SQL SECURITY INVOKER
VIEW `TeamSpeakBotData`.`ranking_total_connection_count` AS
SELECT 
    `clients`.`id` AS `id`,
    `clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,
    `clients`.`TS_client_database_id` AS `TS_client_database_id`,
    `connections`.`TS_client_nickname` AS `TS_client_nickname`,
    `clients`.`total_connection_count` AS `total_connection_count`
FROM `TeamSpeakBotData`.`clients`
JOIN `TeamSpeakBotData`.`connections` ON `clients`.`last_connection_id` = `connections`.`id`
WHERE `clients`.`client_type` = 0
ORDER BY `clients`.`total_connection_count` DESC;


CREATE 
SQL SECURITY INVOKER
VIEW `TeamSpeakBotData`.`ranking_longest_connection` AS
SELECT 
    `clients`.`id` AS `id`,
    `clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,
    `clients`.`TS_client_database_id` AS `TS_client_database_id`,
    `last`.`TS_client_nickname` AS `TS_client_nickname`,
    MAX(`connections`.`total_connection_time`) AS `connection_time`
FROM `TeamSpeakBotData`.`clients`
JOIN `TeamSpeakBotData`.`connections`  `last` ON `clients`.`last_connection_id` = `last`.`id`
JOIN `TeamSpeakBotData`.`connections` ON `clients`.`id` = `connections`.`clients_id`
WHERE `clients`.`client_type` = 0
GROUP BY `clients`.`id`
ORDER BY `connection_time` DESC;


CREATE 
SQL SECURITY INVOKER
VIEW `TeamSpeakBotData`.`online_clients` AS
SELECT 
    `connections`.`TS_clid` AS `TS_clid`,
    `connections`.`TS_client_nickname` AS `TS_client_nickname`,
    `connections`.`TS_client_platform` AS `TS_client_platform`,
    `connections`.`TS_connection_client_ip` AS `TS_connection_client_ip`,
    `connections`.`TS_client_version` AS `TS_client_version`,
    `connections`.`TS_client_country` AS `TS_client_country`,
    `clients`.`TS_client_database_id` AS `TS_client_database_id`,
    `clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,
    `connections`.`connection_start` AS `connection_start`
FROM `TeamSpeakBotData`.`clients`
JOIN `TeamSpeakBotData`.`connections` ON `clients`.`id` = `connections`.`clients_id`
WHERE `connections`.`connection_stop` IS NULL;


-- --------------------------------------------------------