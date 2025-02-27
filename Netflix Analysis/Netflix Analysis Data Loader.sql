USE Netflix_DW;
GO

GO


INSERT INTO dim.Shows(ShowID,Show_Name,Genre)
	SELECT stg.ID 
		  ,stg.ShowName
		  ,stg.Genre
	FROM stg.Shows stg

;
GO


INSERT INTO dim.Movies(MovieID, Movie_Name,Genre)
	SELECT stg.Movie_ID
		  ,stg.MovieName
		  ,stg.Genre
	FROM stg.Movies stg
;
GO


INSERT INTO dim.Calendar(PK_CalendarDate,[Year],[Month],[MonthName],[Day],[DayName],Weekend,WeekofYear)
	SELECT stg.[Date]
		  ,stg.[Year]
		  ,stg.[Month]
		  ,stg.[MonthName]
		  ,stg.[Day]
		  ,stg.[DayName]
		  ,stg.Weekend
		  ,stg.WeekofYear
	FROM stg.Calendar stg
;

GO

INSERT INTO dim.Profiles(Profile_ID, Profile_Name)
	SELECT stg.Profile_ID
		  ,stg.[Profile Name]
	FROM stg.Profiles stg
;

GO

INSERT INTO dim.Genres(Genre_ID,Genre)
	SELECT stg.Genre_ID
		,stg.Genre
	FROM stg.Genres stg

;
GO

INSERT INTO dim.Devices(Device_ID, Device_Type,Times_Device_Used,Device_Usage)
	SELECT stg.Device_ID
		,stg.Device_Type
		,stg.[Times_Device_Used]
		,stg.[Device_Usage]
	FROM stg.Devices stg

;
GO

--Fact Tables

CREATE OR ALTER VIEW vw.fNetflixMovies AS
SELECT [Date]
	,Profile_ID 
	,Movie_ID
	,Genre_ID
	,Device_ID
	,CONVERT(INT, SUM(Duration) * 24 * 60 * 60) as 'Duration_Seconds'
FROM stg.fNetflixMovies
GROUP BY Profile_ID,Movie_ID,Genre_ID,Device_ID,[Date];
;

GO

CREATE OR ALTER VIEW vw.fNetflixShows AS
SELECT [Date] as 'Date'
	,Profile_ID
	,Show_ID
	,Genre_ID
	,Device_ID
	,CONVERT(INT, SUM(Duration) * 24 * 60 * 60) as 'Duration_Seconds'
FROM stg.fNetflixShows f
GROUP BY [Date],Profile_ID,Show_ID,Genre_ID,Device_ID,[Date];

GO


INSERT INTO fact.NetflixShows ([Date],Profile_ID, Show_ID, Show_Name, Genre_ID, Device_ID, Total_Duration)
SELECT 
    vw.[Date],
    vw.Profile_ID,
	vw.Show_ID,
	sh.Show_Name,
    vw.Genre_ID,
    vw.Device_ID,
    vw.[Duration_Seconds]
FROM 
    vw.fNetflixShows vw
INNER JOIN 
    dim.Calendar cal ON vw.[Date] = cal.[PK_CalendarDate]
INNER JOIN 
    dim.Shows sh ON vw.Show_ID = sh.ShowID
;


GO

INSERT INTO fact.NetflixMovies([Date],Profile_ID,Movie_ID, Movie_Name,Genre_ID, Device_ID, Total_Duration)
	SELECT vw.[Date]
		,vw.Profile_ID
		,vw.Movie_ID
		,mv.Movie_Name
		,vw.Genre_ID
		,vw.Device_ID,
		(vw.[Duration_Seconds])
	FROM vw.fNetflixMovies vw
	INNER JOIN dim.Calendar cal 
	ON vw.[Date] = cal.[PK_CalendarDate]
	INNER JOIN dim.Movies mv
	ON vw.Movie_ID = mv.MovieID;

GO

ALTER TABLE dim.Shows
DROP COLUMN ShowID;

ALTER TABLE dim.Movies
DROP COLUMN MovieID;

ALTER TABLE dim.Shows
ADD Title_ID SMALLINT NULL;

ALTER TABLE dim.Movies
ADD Title_ID SMALLINT NULL;

GO 

CREATE OR ALTER VIEW vw.dim AS
SELECT mv.Movie_Name as 'Title'
	,mv.Genre
	,mv.Title_ID
FROM dim.Movies mv
UNION ALL
SELECT sh.Show_Name as 'Title'
	,sh.Genre
	,sh.Title_ID
FROM dim.Shows sh;

GO

INSERT INTO dim.Titles(Title,Genre)
SELECT Title
	,Genre
FROM vw.dim;
GO

UPDATE dim.Titles
SET Title_ID = 10000 + PK_MovieShow_ID;

UPDATE dim.Titles
SET [Type] = 'Movie'
WHERE Title_ID < 11402;

UPDATE dim.Titles
SET [Type] = 'Show'
WHERE Title_ID >= 11402;

GO
CREATE OR ALTER VIEW vw.Fact AS
SELECT sh.[Date]
	,sh.Show_Name as 'Title'
	,sh.Show_ID as 'Title_ID'
	,sh.Profile_ID
	,sh.Genre_ID
	,sh.Device_ID
	,sh.Total_Duration as 'Duration_Seconds'
FROM fact.NetflixShows sh
UNION ALL
SELECT mv.[Date]
	,mv.Movie_Name as 'Title'
	,mv.Movie_ID as 'Title_ID'
	,mv.Profile_ID
	,mv.Genre_ID
	,mv.Device_ID
	,mv.Total_Duration as 'Duration_Seconds'
FROM fact.NetflixMovies mv;

GO


INSERT INTO fact.Netflix([Date],Title,Title_ID,Profile_ID, Genre_ID, Device_ID, Total_Duration)
SELECT 
    f.[Date],
	f.Title,
    f.Title_ID,
    f.Profile_ID,
    f.Genre_ID,
    f.Device_ID,
    f.[Duration_Seconds] as 'Total_Duration_Seconds'
FROM vw.Fact f
ORDER BY f.[Date] ASC;

ALTER TABLE fact.Netflix
ALTER COLUMN Title_ID SMALLINT NULL;

UPDATE fact.Netflix
SET Title_ID = NULL;

UPDATE fact.Netflix
SET fact.Netflix.Title_ID = dim.Titles.Title_ID
FROM fact.Netflix
INNER JOIN dim.Titles ON fact.Netflix.Title = dim.Titles.Title;


ALTER TABLE dim.Titles
ALTER COLUMN Title_ID SMALLINT NOT NULL;

ALTER TABLE fact.Netflix
ALTER COLUMN Title_ID SMALLINT NOT NULL;

ALTER TABLE dim.Titles
DROP COLUMN PK_MovieShow_ID;

ALTER TABLE fact.Netflix
DROP COLUMN Netflix_ID;

ALTER TABLE fact.Netflix
DROP COLUMN Title;

ALTER TABLE dim.Titles
ADD CONSTRAINT PK_Titles PRIMARY KEY(Title_ID);

ALTER TABLE fact.Netflix
ADD CONSTRAINT PK_NETFLIXtoTITLES 
FOREIGN KEY (Title_ID) 
REFERENCES dim.Titles(Title_ID); 

CREATE CLUSTERED INDEX IDX_DATE
ON fact.Netflix ([Date]);
