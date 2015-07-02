#!/bin/bash

mongoexport --port 7081 --collection githubData --db meteor --csv --fields timestamp,subscribers_count,stargazers_count --out github.csv
mongoexport --port 7081 --collection demoSandstormData --db meteor --csv --fields timestamp,dailyActiveUsers,dailyAppDemoUsers,dailyActiveGrains --out demoSandstorm.csv
mongoexport --port 7081 --collection logData --db meteor --csv --fields 'timestamp,url,method,status_code,client,channel,from,type'  --out logData.csv
mongoexport --port 7081 --collection mailchimpData --db meteor --csv --fields 'stats_member_count,stats_unsubscribe_count,stats_member_count_since_send,stats_unsubscribe_count_since_send,stats_open_rate,stats_click_rate,timestamp'  --out mailchimp.csv
mongoexport --port 7081 --collection oasisSandstormData --db meteor --csv --fields timestamp,dailyActiveUsers,dailyActiveGrains --out oaisis.csv
mongoexport --port 7081 --collection sandstormData --db meteor --csv --fields timestamp,dailyActiveUsers,dailyActiveGrains --out alpha.csv
mongoexport --port 7081 --collection preorders --db meteor --csv --fields timestamp,count --out preorders.csv
mongoexport --port 7081 --collection twitterData --db meteor --csv --fields timestamp,followers_count,listed_count,favourites_count,statuses_count --out twitter.csv

mongoexport --port 7081 --collection googleData --db meteor --out googleAnalytics.json
