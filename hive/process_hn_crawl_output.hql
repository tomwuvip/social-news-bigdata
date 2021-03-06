-- This query filters HackerNews data for easier processing later

-- HN crawled data fields: item_id,url,num_links,num_images,num_scripts,num_styles,headers,text

-- USE dc3186;

CREATE EXTERNAL TABLE IF NOT EXISTS hn_crawl_records (record_line string)
LOCATION 's3://deweichen/hackernews/crawl_output/';
-- LOCATION '/user/dc3186/hiveInputHn/crawl/';

CREATE EXTERNAL TABLE IF NOT EXISTS hn_crawl_data (
    item_id int, 
    url string, 
    num_links int, 
    num_images int, 
    num_scripts int, 
    num_styles int, 
    headers string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION 's3://deweichen/hackernews/emr_output/processed_crawl_data';
-- LOCATION '/user/dc3186/processed_crawl_data/';

ADD FILE s3://deweichen/hackernews/hive_scripts/filter_hn_crawl_fields.py;
-- ADD FILE /home/dc3186/bigdata_project/hive/filter_hn_crawl_fields.py;

INSERT OVERWRITE TABLE hn_crawl_data
SELECT TRANSFORM(record_line)
USING 'filter_hn_crawl_fields.py' AS item_id,url,num_links,num_images,num_scripts,num_styles,headers
FROM hn_crawl_records;