# what_script_mbi
only for tests at the moment


The script allows you to generate a custom procedure with the /usr/share/centreon-bi/etl/centreonbiMonitoring.pl --db-content output.

Exemple of MBI db-content output : 
```
[root@mbi-2204 ~]# /usr/share/centreon-bi/etl/centreonbiMonitoring.pl --db-content
[mod_bam_reporting_ba_availabilities: 2023-03-29 00:00:00] [hoststateevents: 2023-03-24 00:00:00] [servicestateevents: 2023-03-24 00:00:00] [mod_bi_hoststateevents: 2023-03-23 19:05:38] [mod_bi_servicestateevents: 2023-03-23 19:12:33] [mod_bi_time: 2023-04-04 00:00:00] [mod_bi_hostavailability: 2023-03-23 00:00:00] [mod_bi_serviceavailability: 2023-03-23 00:00:00] [data_bin: 2023-03-23 23:59:59] [mod_bi_metricdailyvalue: 2023-03-04 00:00:00] [mod_bi_metricmonthcapacity: 2023-02-01 00:00:00] [Table mod_bi_metrichourlyvalue: EMPTY] [mod_bi_metriccentiledailyvalue: 2023-03-23 00:00:00] [mod_bi_metriccentileweeklyvalue: 2023-03-20 00:00:00]
```

Usage : 
```
[root@mbi-2204 ~]# ./what_script_mbi.sh "[mod_bam_reporting_ba_availabilities: 2023-03-29 00:00:00] [hoststateevents: 2023-03-24 00:00:00] [servicestateevents: 2023-03-24 00:00:00] [mod_bi_hoststateevents: 2023-03-23 19:05:38] [mod_bi_servicestateevents: 2023-03-23 19:12:33] [mod_bi_time: 2023-04-04 00:00:00] [mod_bi_hostavailability: 2023-03-23 00:00:00] [mod_bi_serviceavailability: 2023-03-23 00:00:00] [data_bin: 2023-03-23 23:59:59] [mod_bi_metricdailyvalue: 2023-03-04 00:00:00] [mod_bi_metricmonthcapacity: 2023-02-01 00:00:00] [Table mod_bi_metrichourlyvalue: EMPTY] [mod_bi_metriccentiledailyvalue: 2023-03-23 00:00:00] [mod_bi_metriccentileweeklyvalue: 2023-03-20 00:00:00]"
```

Output generated : 


Pour la table ``mod_bam_reporting_ba_availabilities`` : <u>(sur le serveur Central)</u>
```
/usr/share/centreon/www/modules/centreon-bam-server/engine/centreon-bam-rebuild-events --all >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``mod_bam_reporting_ba_availabilities`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/importData.pl -r --bam-only -s 2023-03-29 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour les tables ``hoststateevents`` et ``servicestateevents`` : <u>(sur le serveur Central)</u>
```
/usr/share/centreon/cron/eventReportBuilder --config=/etc/centreon/conf.pm -s 2023-03-24 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour les tables ``hoststateevents`` et ``servicestateevents`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/importData.pl -r --ignore-databin -s 2023-03-24 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour les tables ``mod_bi_hoststateevents`` et ``mod_bi_servicestateevents`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/eventStatisticsBuilder.pl -r --events-only -s 2023-03-23 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour les tables ``mod_bi_hostavailability`` et ``mod_bi_serviceavailability`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/eventStatisticsBuilder.pl -r --no-purge --availability-only -s 2023-03-23 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``data_bin`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/importData.pl -r --no-purge --databin-only -s 2023-03-23 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``mod_bi_metricdailyvalue`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/perfdataStatisticsBuilder.pl -r --no-purge -s 2023-03-04 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``mod_bi_metricmonthcapacity`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/perfdataStatisticsBuilder.pl -r --no-purge --month-only --no-centile >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``mod_bi_metrichourlyvalue`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/etl/perfdataStatisticsBuilder.pl -r --no-purge >> /tmp/partial_rebuild_2023-04-07.log
```


Pour les tables ``mod_bi_metriccentiledailyvalue`` et ``mod_bi_metriccentileweeklyvalue`` : <u>(sur le serveur MBI)</u>
```
/usr/share/centreon-bi/bin/centreonBIETL -rIC >> /tmp/partial_rebuild_2023-04-07.log
```


Pour les tables ``mod_bi_metriccentiledailyvalue`` et ``mod_bi_metriccentileweeklyvalue`` : <u>(sur le serveur MBI étape 2)</u>
```
/usr/share/centreon-bi/etl/dimensionsBuilder.pl -r --no-purge --centile >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``mod_bi_metriccentiledailyvalue`` : <u>(sur le serveur MBI étape 3)</u>
```
/usr/share/centreon-bi/etl/perfdataStatisticsBuilder.pl -r --centile-only -s 2023-03-23 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


Pour la table ``mod_bi_metriccentileweeklyvalue`` : <u>(sur le serveur MBI étape 3)</u>
```
/usr/share/centreon-bi/etl/perfdataStatisticsBuilder.pl -r --centile-only -s 2023-03-20 -e 2023-04-07 >> /tmp/partial_rebuild_2023-04-07.log
```


What are the functionnalities of the script : 
* Formatting in Markdown.
* Support EMPTY table.
* Regroup tables with same script and same period of time on one step.
* Support multistep and multiserver for one table.
* Support case when db-content output table are \[Table table_name: date] or \[table_name: date].
* Support custom CENTRAL_SCRIPT and MBI_SCRIPT paths.

Note : please use if if you know what you are doing.
This is not 100% compatible wifh 22.10 MBI version (issus with --no-purge option), I recommand you to modify the procedure to use legacy script (perfdataStatisticsBuilder_legacy.pl instead of perfdataStatisticsBuilder.pl).
Be carefull when using -r, -s and -e without --no-purge options otherwise it will empty statistics tables. Note :  Does not work on raw data tables, only on Centreon BI statistics tables.

Feel free to send me feedback or do a PR if you find a bug.
