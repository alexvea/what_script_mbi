#!/bin/bash
#
# Script d'exemple pour extraire les noms et les dates des tables d'une base de données
# Auteur: AV
# Licence: MIT


CENTRAL_SCRIPT_PATH="/usr/share/centreon/www/modules/centreon-bam-server/engine"
MBI_SCRIPT_PATH="/usr/share/centreon-bi/etl"

# Tableau associatif avec les noms de scripts pour chaque table et chaque serveur
declare -A table_script_relations=(
  ["",""]=""
  ["mod_bam_reporting_ba_availabilities","Central"]="${CENTRAL_SCRIPT_PATH}/centreon-bam-rebuild-events --all"
  ["mod_bam_reporting_ba_availabilities","MBI"]="${MBI_SCRIPT_PATH}/importData.pl -r --bam-only"
  ["hoststateevents","Central"]="/usr/share/centreon/cron/eventReportBuilder --config=/etc/centreon/conf.pm"
  ["hoststateevents","MBI"]="${MBI_SCRIPT_PATH}/importData.pl -r --ignore-databin"
  ["servicestateevents","Central"]="/usr/share/centreon/cron/eventReportBuilder --config=/etc/centreon/conf.pm"
  ["servicestateevents","MBI"]="${MBI_SCRIPT_PATH}/importData.pl -r --ignore-databin"
  ["mod_bi_hoststateevents","MBI"]="${MBI_SCRIPT_PATH}/eventStatisticsBuilder.pl -r --events-only"
  ["mod_bi_servicestateevents","MBI"]="${MBI_SCRIPT_PATH}/eventStatisticsBuilder.pl -r --events-only"
#  ["mod_bi_time","MBI"]="${MBI_SCRIPT_PATH}/perfdataStatisticsBuilder.pl -r --no-purge"
  ["mod_bi_hostavailability","MBI"]="${MBI_SCRIPT_PATH}/eventStatisticsBuilder.pl -r --no-purge --availability-only"
  ["mod_bi_serviceavailability","MBI"]="${MBI_SCRIPT_PATH}/eventStatisticsBuilder.pl -r --no-purge --availability-only"
  ["mod_bi_hgmonthavailability","MBI"]="${MBI_SCRIPT_PATH}/eventStatisticsBuilder.pl -r --no-purge --availability-only"
  ["mod_bi_hgservicemonthavailability","MBI"]="${MBI_SCRIPT_PATH}/eventStatisticsBuilder.pl -r --no-purge --availability-only"
  ["data_bin","MBI"]="${MBI_SCRIPT_PATH}/importData.pl -r --no-purge --databin-only"
  ["mod_bi_metricdailyvalue","MBI"]="${MBI_SCRIPT_PATH}/perfdataStatisticsBuilder.pl -r --no-purge"
  ["mod_bi_metricmonthcapacity","MBI"]="${MBI_SCRIPT_PATH}/perfdataStatisticsBuilder.pl -r --no-purge"
  ["mod_bi_metrichourlyvalue","MBI"]="${MBI_SCRIPT_PATH}/perfdataStatisticsBuilder.pl -r --no-purge"
  ["mod_bi_metriccentiledailyvalue","MBI"]="/usr/share/centreon-bi/bin/centreonBIETL -rIC"
  ["mod_bi_metriccentiledailyvalue","MBI_2"]="${MBI_SCRIPT_PATH}/dimensionsBuilder.pl -d"
  ["mod_bi_metriccentiledailyvalue","MBI_3"]="${MBI_SCRIPT_PATH}/perfdataStatisticsBuilder.pl -r --centile-only"
  ["mod_bi_metriccentilemonthlyvalue","MBI"]="/usr/share/centreon-bi/bin/centreonBIETL -rIC"
  ["mod_bi_metriccentilemonthlyvalue","MBI_2"]="${MBI_SCRIPT_PATH}/dimensionsBuilder.pl -d"
  ["mod_bi_metriccentilemonthlyvalue","MBI_3"]="${MBI_SCRIPT_PATH}/perfdataStatisticsBuilder.pl -r --centile-only"
)

[ -e /tmp/mib_db_content_csv ] && rm /tmp/mib_db_content_csv

# Fonction pour afficher les informations sur la table
a=0
function convert_to_csv {
    ((a+=1))
    local table_name="$1"
    local server_name="$2"
    local script_name="${table_script_relations[$table_name,$server_name]}"
    local date_value="$3"

    if [[ $date_value == "EMPTY" || "$script_name" == *"centreon-bam-rebuild-events"* ]]; then
        echo "$a;$table_name;$server_name;$script_name" >> /tmp/mib_db_content_csv
    else
        today=$(date +%Y-%m-%d)
        echo "$a;$table_name;$server_name;$script_name -s $date_value -e $today" >> /tmp/mib_db_content_csv
    fi
}

function display_scripts {
        #Concatene les noms des tables si la commande de script est identique (comprend les dates)
        cat /tmp/mib_db_content_csv | awk -F";" 'FNR==0{print;next} {a[$4]=a[$4]?a[$4] :$1} {b[$4]=b[$4]?b[$4] "," $2:$2} {c[$4]=c[$4]?c[$4] :$3} {d[$4]=d[$4]?d[$4] :$4} END{for(i in a){print a[i]";"b[i]";"c[i]";"d[i]}}' | sort -n | while read line  || [[ -n $line ]];
        do
                table_name_ds=($(echo $line | cut -d";" -f2))
                server_step_ds=($(echo $line | cut -d";" -f3))
                script_ds=$(echo $line | awk -F";" '{print $4}')
                if [[ "$table_name_ds" =~ .*",".* ]]; then
                         table_conjug="les tables"
                else
                         table_conjug="la table"
                fi
                         echo "Pour $table_conjug \`\`${table_name_ds/,/ et }\`\` : <u>(sur le serveur ${server_step_ds/_/ étape })</u>"
                         echo "\`\`\`"
                         echo "${script_ds} >> /tmp/partial_rebuild_$today.log"
                         echo "\`\`\`"
                echo ""
                echo ""
        done
}

#db-content ouput example
#input="[mod_bam_reporting_ba_availabilities: 2023-02-27 00:00:00] [hoststateevents: 2023-02-24 00:00:00] [servicestateevents: EMPTY] [mod_bi_hoststateevents: 2023-02-24 00:00:00] [mod_bi_servicestateevents: 2023-02-24 00:00:00] [mod_bi_time: 2023-03-01 00:00:00] [mod_bi_hostavailability: 2023-02-23 00:00:00] [mod_bi_serviceavailability: 2023-02-23 00:00:00] [data_bin: 2023-02-28 23:59:59] [mod_bi_metricdailyvalue: 2023-02-27 00:00:00] [mod_bi_metricmonthcapacity: 2023-01-01 00:00:00] [mod_bi_metrichourlyvalue: 2023-02-27 23:00:00] [mod_bi_metriccentiledailyvalue: 2023-02-27 00:00:00] [mod_bi_metriccentilemonthlyvalue: 2023-01-01 00:00:00]"

input=$1

# Récupère le nom de chaque table à partir de la sortie de la commande
tables=($(echo $input | grep -oP '(?<=\[)[^\:[]+'))
# Récupère la date de la dernière entrée pour chaque table à partir de la sortie de la commande
dates=$(echo $input | grep -oP '(?<=: )[^\]]+' | awk '{print $1}')

# Convertit la date en format "aaaa-mm-jj" et gère les cas avec une date manquante (EMPTY)
formatted_dates=()
for date in $dates; do
    if [[ $date == "EMPTY" ]]; then
        formatted_dates+=($date)
    else
        formatted_dates+=($(date -d "$date" +%Y-%m-%d))
    fi
done

# Parcours les tables  en fonction de leur nom, leurs scripts correspondants et leur date
for (( i=0; i<${#tables[@]}; i++ )); do
    table=${tables[$i]}
    date=${formatted_dates[$i]}

  # for key in "${!table_script_relations[@]}"; do
    for key in `printf '%s\n' "${!table_script_relations[@]}" | sort`; do

        script_table="${key%,*}"
        server_name="${key##*,}"
        if [[ "$table" == "$script_table" && "${table_script_relations[$key]}" != "" ]]; then
            convert_to_csv "$table" "$server_name" "$date"
        fi
    done
done


display_scripts
