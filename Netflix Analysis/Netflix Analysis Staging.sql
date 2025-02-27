USE Netflix_DW;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dim' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA dim AUTHORIZATION dbo;'
END
;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA stg AUTHORIZATION dbo;'
END
;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'fact' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA fact AUTHORIZATION dbo;'
END


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =  'vw'  )
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA vw AUTHORIZATION dbo;'
END



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Calendar')
BEGIN
	CREATE TABLE dim.Calendar(
       PK_CalendarDate DATE NOT NULL,
       Year INT NOT NULL,
       Month TINYINT NOT NULL,
       MonthName NVARCHAR(10) NULL,
       Day TINYINT NOT NULL,
	   DayName NVARCHAR(10) NULL,
	   Weekend NVARCHAR(3) NULL,
	   WeekofYear TINYINT NOT NULL
       );

	ALTER TABLE dim.Calendar
	ADD CONSTRAINT PK_Date PRIMARY KEY(PK_CalendarDate);

END


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Devices')
BEGIN
	CREATE TABLE dim.Devices(
	   Device_ID TINYINT NOT NULL,
	   Device_Type NVARCHAR(50) NULL,
	   Times_Device_Used SMALLINT NOT NULL,
	   Device_Usage NVARCHAR(20) NULL
       );

	ALTER TABLE dim.Devices
	ADD CONSTRAINT PK_Devices PRIMARY KEY(Device_ID);

END


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Genres')
BEGIN
	CREATE TABLE dim.Genres(
	   Genre_ID TINYINT NOT NULL,
	   Genre NVARCHAR(25) NOT NULL
       );

	ALTER TABLE dim.Genres
	ADD CONSTRAINT PK_Genre PRIMARY KEY(Genre_ID);

END


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Profiles')
BEGIN
	CREATE TABLE dim.Profiles(
	   Profile_ID TINYINT NOT NULL,
	   Profile_Name NVARCHAR(10) NOT NULL
       );

	ALTER TABLE dim.Profiles
	ADD CONSTRAINT PK_Profile PRIMARY KEY(Profile_ID);

	ALTER TABLE dim.Profiles
	ADD CONSTRAINT UC_Profile UNIQUE (Profile_Name);


END


--Dim tables to form new dim

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Shows')
BEGIN
	CREATE TABLE dim.Shows(
	   ShowID smallint NOT NULL,
	   Show_Name nvarchar(100) NOT NULL,
	   Genre nvarchar(25) NOT NULL,
	   );

END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Movies')
BEGIN
	CREATE TABLE dim.Movies(
	   MovieID smallint NOT NULL,
	   Movie_Name nvarchar(100) NOT NULL,
	   Genre nvarchar(25) NOT NULL,
	   );

END
--New dim

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Titles')
BEGIN
    CREATE TABLE dim.Titles (
       PK_MovieShow_ID INT IDENTITY(1,1) NOT NULL,
	   Title_ID SMALLINT NULL,
       Title VARCHAR(100) NOT NULL,
       Genre NVARCHAR(25) NOT NULL,
	   [Type] NVARCHAR(6) NULL,
       );

END

-- Fact tables
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'fact' AND TABLE_NAME = 'NetflixShows')
BEGIN
    CREATE TABLE fact.NetflixShows (
        PK_Shows_ID INT IDENTITY(1,1) NOT NULL,
        [Date] DATE NOT NULL,
        Profile_ID TINYINT NOT NULL,
		Show_Name NVARCHAR(100) NOT NULL,
        Show_ID SMALLINT NOT NULL,
        Genre_ID TINYINT NOT NULL,
        Device_ID TINYINT NOT NULL,
        Total_Duration INT NOT NULL
        );
END
--
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'fact' AND TABLE_NAME = 'NetflixMovies')
BEGIN
	CREATE TABLE fact.NetflixMovies (
        PK_Movies_ID INT IDENTITY(1,1) NOT NULL,
        [Date] DATE NOT NULL,
        Profile_ID TINYINT NOT NULL,
		Movie_Name NVARCHAR(100) NOT NULL,
        Movie_ID SMALLINT NOT NULL,
        Genre_ID TINYINT NOT NULL,
        Device_ID TINYINT NOT NULL,
        Total_Duration FLOAT NOT NULL
    );
END



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'fact' AND TABLE_NAME = 'Netflix')
BEGIN
    CREATE TABLE fact.Netflix (
	    Netflix_ID INT IDENTITY(100,1) NOT NULL,
        [Date] DATE NOT NULL,
		Title NVARCHAR(100) NOT NULL,
		Title_ID SMALLINT NOT NULL,
        Profile_ID TINYINT NOT NULL, 
        Genre_ID TINYINT NOT NULL, 
        Device_ID TINYINT NOT NULL, 
        Total_Duration INT NOT NULL 
    );
END

    ALTER TABLE fact.Netflix
    ADD CONSTRAINT FK_NETFLIXtoCAL
    FOREIGN KEY ([Date])                 
    REFERENCES dim.Calendar(PK_CalendarDate);

    ALTER TABLE fact.Netflix
    ADD CONSTRAINT FK_NETFLIXtoPROFILES
    FOREIGN KEY (Profile_ID)            
    REFERENCES dim.Profiles(Profile_ID);

    ALTER TABLE fact.Netflix
    ADD CONSTRAINT FK_NETFLIXtoDEVICE
    FOREIGN KEY (Device_ID)             
    REFERENCES dim.Devices(Device_ID);

	ALTER TABLE fact.Netflix
	ADD CONSTRAINT FK_NETFLIXtoGENRE
	FOREIGN KEY (Genre_ID)            
	REFERENCES dim.Genres (Genre_ID);

END

