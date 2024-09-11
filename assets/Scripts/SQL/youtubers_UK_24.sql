use youtube_db;

/*
# Data Cleaning Steps

-remove unnecessary columns by only selecting what we need
-extract the youtube channel names from the first columns
-rename the column names
*/

select 
	NOMBRE,
	total_subscribers,
	total_views,
	total_videos
from top_uk_youtubers_2024;

--charindex

select CHARINDEX('@',NOMBRE),NOMBRE from top_uk_youtubers_2024;

--substring/view/casting

create view view_uk_youtubers_2024 as

select 
	cast(substring(NOMBRE,1,CHARINDEX('@',NOMBRE)-1)as varchar(100)) as channel_name,
	total_subscribers,
	total_videos,
	total_views
from top_uk_youtubers_2024;

/*
#Data Quality Checks

--The data needs to be 100 records of youtube channels(row count test)
--The data needs four fields(column count test)
--The channel name must be string format and  other columns numerical data types(data type check)
--each record much be unique in the dataset
--Row count = 100
--column count = 4
channel_name = varchar
total_subs = int
totak_views = int
total_videos = int
duplicate count = 0

*/

--Row count check
select count(*) as no_of_rows from view_uk_youtubers_2024;

--column count check
select count(*)
from information_schema.columns
where table_name = 'view_uk_youtubers_2024';

--data type check
select 
	column_name,
	DATA_TYPE
from information_schema.columns
where table_name = 'view_uk_youtubers_2024';

--duplicate records check
select 
	channel_name,
	count(*) as duplicate_count
from view_uk_youtubers_2024
group by channel_name
having count(*) > 1;




