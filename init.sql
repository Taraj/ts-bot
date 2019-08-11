-- --------------------------------------------------------

CREATE DATABASE TeamSpeakBotData;

-- --------------------------------------------------------

CREATE TABLE `TeamSpeakBotData`.`channels` (
    `id` INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `TS_cid` INT UNSIGNED NOT NULL,
    `channel_created` TIMESTAMP NOT NULL,
    `clients_id` INT UNSIGNED NOT NULL
);


CREATE TABLE `TeamSpeakBotData`.`clients` (
    `id` INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT ,
    `TS_client_unique_identifier` CHAR(30) NOT NULL,
    `ignore_in_ranking` TINYINT(1) NOT NULL DEFAULT '0',
    `total_connection_time` INT UNSIGNED NOT NULL DEFAULT '0',
    `total_inactivity_time` INT UNSIGNED NOT NULL DEFAULT '0',
    `total_connection_count` MEDIUMINT UNSIGNED NOT NULL DEFAULT '1',
    `longest_connection` INT UNSIGNED NOT NULL DEFAULT '0',
    `last_TS_client_nickname` CHAR(40) NOT NULL,
    `first_connection_start` TIMESTAMP NOT NULL,
    `last_connection_start` TIMESTAMP NOT NULL,
    `TS_client_database_id` INT UNSIGNED NOT NULL,
    INDEX(`ignore_in_ranking`),
    UNIQUE(`TS_client_unique_identifier`)
);


CREATE TABLE `TeamSpeakBotData`.`connections` (
    `id` INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `TS_clid` SMALLINT UNSIGNED NOT NULL,
    `TS_client_nickname` CHAR(40) NOT NULL,
    `TS_client_platform` CHAR(20) NOT NULL,
    `TS_connection_client_ip` CHAR(50) NOT NULL,
    `TS_client_version` CHAR(50) NOT NULL,
    `connection_start` TIMESTAMP NOT NULL,
    `connection_stop` TIMESTAMP DEFAULT NULL,
    `total_inactivity_time` INT UNSIGNED NOT NULL DEFAULT '0',
    `total_connection_time` INT UNSIGNED NOT NULL DEFAULT '0',
    `TS_client_country` CHAR(5) NOT NULL,
    `clients_id` INT UNSIGNED NOT NULL
);


CREATE TABLE `TeamSpeakBotData`.`inactivity_periods` (
    `id` INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `inactivity_start` TIMESTAMP NOT NULL,
    `inactivity_stop` TIMESTAMP NOT NULL,
    `inactivity_time` INT UNSIGNED NOT NULL,
    `connections_id` INT UNSIGNED NOT NULL
);


CREATE TABLE `TeamSpeakBotData`.`visited_channels` (
    `id` INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `TS_cid` INT UNSIGNED NOT NULL,
    `date` TIMESTAMP NOT NULL,
    `connections_id` INT UNSIGNED NOT NULL
);

-- --------------------------------------------------------

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
CREATE FUNCTION `TeamSpeakBotData`.`getClientID`(`client_unique_identifier` CHAR(30)) RETURNS INT
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN 
    SELECT `clients`.`id` INTO @clientID FROM `TeamSpeakBotData`.`clients` WHERE `clients`.`TS_client_unique_identifier` = client_unique_identifier;
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
    IN `client_unique_identifier` CHAR(30),
    IN `client_database_id` INT UNSIGNED,
    IN `clid` SMALLINT UNSIGNED,
    IN `client_nickname` CHAR(40),
    IN `client_platform` CHAR(20),
    IN `connection_client_ip` CHAR(50),
    IN `client_version` CHAR(50),
    IN `client_country` CHAR(5),
    IN `cid` INT UNSIGNED
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SET @clientID := `TeamSpeakBotData`.`getClientID`(client_unique_identifier);
    SET @unix_timestamp := NOW();
    IF @clientID IS NULL THEN
        INSERT INTO `TeamSpeakBotData`.`clients` (
                        `TS_client_unique_identifier`,
                        `TS_client_database_id`,                     
                        `last_TS_client_nickname`,
                        `first_connection_start`,
                        `last_connection_start`
                    ) VALUES (
                        client_unique_identifier,
                        client_database_id,
                        client_nickname,
                        @unix_timestamp,
                        @unix_timestamp
                    );
        SET @clientID := `TeamSpeakBotData`.`getClientID`(client_unique_identifier);
        INSERT INTO `TeamSpeakBotData`.`connections` (
                        `TS_clid`,
                        `TS_client_nickname`,
                        `TS_client_platform`,
                        `TS_connection_client_ip`,
                        `TS_client_version`,
                        `TS_client_country`,
                        `connection_start`,
                        `clients_id`
                ) VALUES (
                        clid,
                        client_nickname,
                        client_platform,
                        connection_client_ip,
                        client_version,
                        client_country,
                        @unix_timestamp,
                        @clientID
                );
        SELECT  0                AS `total_connection_time`,
                1                AS `total_connection_count`,
                0                AS `total_inactivity_time`,
                UNIX_TIMESTAMP(@unix_timestamp) - TIMESTAMPDIFF(SECOND, NOW(), UTC_TIMESTAMP()) AS `first_connection`,
                UNIX_TIMESTAMP(@unix_timestamp) - TIMESTAMPDIFF(SECOND, NOW(), UTC_TIMESTAMP()) AS `last_connection`;
    ELSE
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
                        @unix_timestamp,
                        client_country,
                        @clientID
                    );
        SELECT 
            `clients`.`total_connection_time`,
            `clients`.`total_connection_count` + 1 AS `total_connection_count`,
            `clients`.`total_inactivity_time`,
            UNIX_TIMESTAMP(`clients`.`last_connection_start`) - TIMESTAMPDIFF(SECOND, NOW(), UTC_TIMESTAMP())  AS `last_connection`,
            UNIX_TIMESTAMP(`clients`.`first_connection_start`) - TIMESTAMPDIFF(SECOND, NOW(), UTC_TIMESTAMP()) AS `first_connection`
        FROM `TeamSpeakBotData`.`clients`
        WHERE `clients`.`id` = @clientID;

        UPDATE `TeamSpeakBotData`.`clients` SET 
            `clients`.`last_TS_client_nickname` = client_nickname,
            `clients`.`total_connection_count` =  `clients`.`total_connection_count` + 1,
            `clients`.`last_connection_start` = @unix_timestamp
        WHERE `clients`.`id` = @clientID;

    END IF;

    INSERT INTO `TeamSpeakBotData`.`visited_channels` (
                `TS_cid`,
                `date`,
                `connections_id`
            ) VALUES (
                cid,
                @unix_timestamp,
                `TeamSpeakBotData`.`getConnectionID`(clid)
            );
END $$


CREATE PROCEDURE `TeamSpeakBotData`.`client_leave`(
    IN `clid` INT UNSIGNED,
    IN `client_idle_time` INT UNSIGNED
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
   
    SET @connectionID := `TeamSpeakBotData`.`getConnectionID`(clid);
    SET @unix_timestamp := NOW();

     IF @connectionID IS NOT NULL THEN
        IF client_idle_time > 0 THEN
            INSERT INTO `TeamSpeakBotData`.`inactivity_periods` (
                    `inactivity_start`,  
                    `inactivity_stop`,          
                    `inactivity_time`, 
                    `connections_id`
                ) VALUES (
                    FROM_UNIXTIME(UNIX_TIMESTAMP(@unix_timestamp) - client_idle_time),
                    @unix_timestamp,
                    client_idle_time,
                    @connectionID
                );

            UPDATE `TeamSpeakBotData`.`connections` SET
                `connections`.`total_inactivity_time` = `connections`.`total_inactivity_time` + client_idle_time,
                `connections`.`connection_stop` = @unix_timestamp,
                `connections`.`total_connection_time` = UNIX_TIMESTAMP(@unix_timestamp) - UNIX_TIMESTAMP(`connections`.`connection_start`)
            WHERE `connections`.`id` = @connectionID;
        ELSE
            UPDATE `TeamSpeakBotData`.`connections` SET
                `connections`.`connection_stop` = @unix_timestamp,
                `connections`.`total_connection_time` = UNIX_TIMESTAMP(@unix_timestamp) - UNIX_TIMESTAMP(`connections`.`connection_start`)
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
            `clients`.`total_connection_time` = `clients`.`total_connection_time` + @total_connection_time,
            `clients`.`longest_connection` = GREATEST(`clients`.`longest_connection`,  @total_connection_time)
        WHERE `clients`.`id` = @clientID;
    END IF;
END $$



CREATE PROCEDURE `TeamSpeakBotData`.`client_move`(
    IN `clid`  INT UNSIGNED,
    IN `cid`  INT UNSIGNED
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SET @connectionID := `TeamSpeakBotData`.`getConnectionID`(clid);
    SET @unix_timestamp := NOW();

    IF @connectionID IS NOT NULL THEN
        INSERT INTO `TeamSpeakBotData`.`visited_channels` (
                `TS_cid`,
                `date`,
                `connections_id`
            ) VALUES (
                cid,
                @unix_timestamp,
                @connectionID
            );
    END IF;
END $$



CREATE  PROCEDURE `TeamSpeakBotData`.`client_stop_inactivity` (
    IN `clid` INT UNSIGNED,
    IN `client_idle_time` INT UNSIGNED
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    SET @connectionID := `TeamSpeakBotData`.`getConnectionID`(clid);
    SET @unix_timestamp := NOW();

    IF @connectionID IS NOT NULL THEN
        INSERT INTO `TeamSpeakBotData`.`inactivity_periods` (
                `inactivity_start`,
                `inactivity_stop`,
                `inactivity_time`, 
                `connections_id`
             ) VALUES (
                FROM_UNIXTIME(UNIX_TIMESTAMP(@unix_timestamp) - client_idle_time),
                @unix_timestamp,
                client_idle_time, 
                @connectionID
            );


        UPDATE `TeamSpeakBotData`.`connections` SET
            `connections`.`total_inactivity_time` = `connections`.`total_inactivity_time` + client_idle_time
        WHERE `connections`.`id` = @connectionID;
    END IF;
END $$



CREATE  PROCEDURE `TeamSpeakBotData`.`channel_create`(
    IN `cid` INT UNSIGNED, 
    IN `clid` SMALLINT UNSIGNED
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
            NOW(),
            (SELECT `clients_id` FROM `TeamSpeakBotData`.`connections` WHERE `TS_clid` = clid AND `connection_stop` IS NULL)
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
    `clients`.`last_TS_client_nickname` AS `TS_client_nickname`,
    `clients`.`total_connection_time` AS `total_connection_time`,
    `clients`.`total_inactivity_time` AS `total_inactivity_time` 
FROM `TeamSpeakBotData`.`clients`
WHERE `clients`.`ignore_in_ranking` = 0
ORDER BY `clients`.`total_connection_time` DESC;


CREATE 
SQL SECURITY INVOKER
VIEW `TeamSpeakBotData`.`ranking_total_connection_count` AS
SELECT 
    `clients`.`id` AS `id`,
    `clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,
    `clients`.`last_TS_client_nickname` AS `TS_client_nickname`,
    `clients`.`total_connection_count` AS `total_connection_count`
FROM `TeamSpeakBotData`.`clients`
WHERE `clients`.`ignore_in_ranking` = 0
ORDER BY `clients`.`total_connection_count` DESC;


CREATE 
SQL SECURITY INVOKER
VIEW `TeamSpeakBotData`.`ranking_longest_connection` AS
SELECT 
    `clients`.`id` AS `id`,
    `clients`.`TS_client_unique_identifier` AS `TS_client_unique_identifier`,
    `clients`.`last_TS_client_nickname` AS `TS_client_nickname`,
    `clients`.`longest_connection` AS `connection_time`
FROM `TeamSpeakBotData`.`clients`
WHERE `clients`.`ignore_in_ranking` = 0
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