-- This query filters HackerNews data for easier processing later

-- HN API output fields: id,deleted,type,by,time,text,dead,parent,kids,url,score,title,parts,descendants

-- USE dc3186;

CREATE EXTERNAL TABLE IF NOT EXISTS hn_api_records (record_line string)
LOCATION 's3://deweichen/hackernews/api_output/';
-- LOCATION '/user/dc3186/hiveInputHn/api/';

CREATE EXTERNAL TABLE IF NOT EXISTS hn_api_data (
	id int, 
	type string, 
	author string, 
	time int, 
	text string, 
	url string, 
	score int, 
	title string, 
	descendants int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

ADD FILE s3://deweichen/hackernews/hive_scripts/filter_hn_api_fields.py;
-- ADD FILE /home/dc3186/bigdata_project/hive/filter_hn_api_fields.py;

INSERT OVERWRITE TABLE hn_api_data
SELECT TRANSFORM(record_line)
USING 'filter_hn_api_fields.py' AS id, type, author, time, text, url, score, title, descendants
FROM hn_api_records;

-- Clean the data
CREATE EXTERNAL TABLE IF NOT EXISTS hn_api_data_clean (
	id int, 
	type string, 
	author string, 
	time int, 
	text string, 
	url string, 
	score int, 
	title string, 
	descendants int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION 's3://deweichen/hackernews/emr_output/processed_api_data/';
-- LOCATION '/user/dc3186/hive_results/'

-- Take non-null descendants
INSERT OVERWRITE TABLE hn_api_data_clean
SELECT * FROM hn_api_data
WHERE descendants IS NOT NULL;

-- INSERT OVERWRITE LOCAL DIRECTORY 'hive_results'
-- ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
-- SELECT * FROM hn_api_data_clean;
