#!/bin/bash
VERSION="0.7"

# CONFIG
SHIFT_DIRECTORY=~/shift-lisk

# EXPORT
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#============================================================
#= snapshot.sh v0.2 created by mrgr                         =
#= Please consider voting for delegate mrgr                 =
#============================================================

#============================================================
#= snapshot.sh v0.7 created by Mx                           =
#= Please consider voting for delegate 'mx'                 =
#============================================================

# markdown
redTextOpen="\e[31m"
greenTextOpen="\e[1;32m"
boldTextOpen="\e[1m"
highlitedTextOpen="\e[44m"
colorTextClose="\e[0m"

echo " "

if [ ! -f ${SHIFT_DIRECTORY}/app.js ]; then
  echo -e "${redTextOpen}Error: No shift-lisk installation detected in the directory ${SHIFT_DIRECTORY}${colorTextClose}"
  echo -e "Please, change config: ${boldTextOpen}nano shift-snapshot.sh${colorTextClose}"
  echo "or install: https://github.com/ShiftNrg/shift-lisk"
  exit 1
fi

if [ "\$USER" == "root" ]; then
  echo -e "${redTextOpen}Error: shift-lisk should not be run be as root. Exiting.${colorTextClose}"
  exit 1
fi

SHIFT_CONFIG=${SHIFT_DIRECTORY}/config.json
DB_NAME="$(grep "database" $SHIFT_CONFIG | cut -f 4 -d '"')"
DB_USER="$(grep "user" $SHIFT_CONFIG | cut -f 4 -d '"')"
DB_PASS="$(grep "password" $SHIFT_CONFIG | cut -f 4 -d '"' | head -1)"
SNAPSHOT_COUNTER=snapshot/counter.json
SNAPSHOT_LOG=snapshot/snapshot.log
if [ ! -f "snapshot/counter.json" ]; then
  mkdir -p snapshot
  sudo chmod +x shift-snapshot.sh
  echo "0" > $SNAPSHOT_COUNTER
  sudo chown postgres:${USER:=$(/usr/bin/id -run)} snapshot
  sudo chmod -R 777 snapshot
fi
SNAPSHOT_DIRECTORY=snapshot/


NOW=$(date +"%d-%m-%Y - %T")
################################################################################

# intercept user input function
ctrlc_count=0

no_ctrlc() 
{
  let ctrlc_count++
  echo
  if [[ $ctrlc_count == 1 ]]; then
    echo -e "${redTextOpen}!Warning. At shutdown, errors in the database are possible.${colorTextClose}"
    # echo "If you really want to exit, press Ctrl+C again."
  else
     echo -e "${redTextOpen}Exit.${colorTextClose}"
     exit
  fi
}

# progress bar
sp=",.·•oὀ0*' "
sp1="/-\|+"
i_pb=1

progress_bar() {
    while ps -p $2 >/dev/null 2>&1
    do
        printf "\b${1:i_pb++%${#1}:1}"
        sleep 0.1
    done
}

create_snapshot() {
  export PGPASSWORD=$DB_PASS
  echo -e " ${boldTextOpen}+ Creating compressed snapshot${colorTextClose}"
  echo "--------------------------------------------------"
  snapshotName="shift_db$NOW.snapshot.sql.gz"
  snapshotLocation="$SNAPSHOT_DIRECTORY'$snapshotName'"
  trap no_ctrlc SIGINT # intercept user input
  (sudo su postgres -c "pg_dump -Fp -Z 1 $DB_NAME > $snapshotLocation") & # to start progress bar
  app_pid=$! # progress bar
  progress_bar "$sp" "$app_pid" # progress bar
  blockHeight=`psql -d $DB_NAME -U $DB_USER -h localhost -p 5432 -t -c "select height from blocks order by height desc limit 1;"`
  dbSize=`psql -d $DB_NAME -U $DB_USER -h localhost -p 5432 -t -c "select pg_size_pretty(pg_database_size('$DB_NAME'));"`
  trap -- SIGINT # release interception user input

  if [ $? != 0 ]; then
    echo -e "\n${redTextOpen}X Failed to create compressed snapshot.${colorTextClose}" | tee -a $SNAPSHOT_LOG
    exit 1
  else
    myFileSizeCheck=$(du -h "$SNAPSHOT_DIRECTORY$snapshotName" | cut -f1)
    echo -e "\n$NOW -- ${greenTextOpen}OK compressed snapshot created successfully${colorTextClose} at block$blockHeight ($myFileSizeCheck)." | tee -a $SNAPSHOT_LOG
  fi

}

restore_snapshot(){
  echo -e " ${boldTextOpen}+ Restoring snapshot${colorTextClose}"
  echo "--------------------------------------------------"
  SNAPSHOT_FILE=`ls -t snapshot/shift_db* | head  -1`
  if [ -z "$SNAPSHOT_FILE" ]; then
    echo -e "${redTextOpen}!No snapshot to restore, please consider create it first${colorTextClose}"
    echo -e "Using: bash shift-snapshot.sh create"
    echo " "
    exit 1
  fi
  echo -e "Snapshot to restore = $SNAPSHOT_FILE"
  read -p "$(echo -e ${highlitedTextOpen}"shift-lisk node will be stopped, are you ready (y/n)?"${colorTextClose})  " -r

  if [[ ! $REPLY =~ ^[Yyнд]$ ]]
  then
     echo -e "${redTextOpen}!Please stop app.js first. Then execute restore again${colorTextClose}"
     echo " "
     exit 1
  fi

  bash ${SHIFT_DIRECTORY}/shift_manager.bash stop

  trap no_ctrlc SIGINT # intercept user input

  # snapshot restoring
  export PGPASSWORD=$DB_PASS
  # drop db
  resp=$(sudo -u postgres dropdb --if-exists "$DB_NAME" 2> /dev/null)
  resp=$(sudo -u postgres createdb -O "$DB_USER" "$DB_NAME" 2> /dev/null)
  resp=$(sudo -u postgres psql -t -c "SELECT count(*) FROM pg_database where datname='$DB_NAME'" 2> /dev/null)

  if [[ $resp -eq 1 ]]; then
    echo "√ Database reset successfully."
  else
    echo "X Failed to create Postgresql database."
    exit 1
  fi

  echo -e "\n${boldTextOpen}Snapshot restoring started${colorTextClose}"
  echo "Please keep calm and don't push the button :)"

  # restore dump
  (gunzip -fcq "$SNAPSHOT_FILE" | psql -d $DB_NAME -U $DB_USER -h localhost -q &> /dev/null) & # to start progress bar
  app_pid=$! # progress bar
  progress_bar "$sp1" "$app_pid" # progress bar

  trap -- SIGINT # release interception user input

  if [ $? != 0 ]; then
    echo -e "${redTextOpen}X Failed to restore.${colorTextClose}"
    exit 1
  else
    echo -e "${greenTextOpen}OK snapshot restored successfully.${colorTextClose}"
  fi

  bash ${SHIFT_DIRECTORY}/shift_manager.bash start

}

show_log(){
  echo " + Snapshot Log"
  echo "--------------------------------------------------"
  cat snapshot/snapshot.log
  echo "--------------------------------------------------END"
}

################################################################################

case $1 in
"create")
  create_snapshot
  ;;
"restore")
  restore_snapshot
  ;;
"verify")
  echo "Hello my friend - $NOW"
  ;;
"create_verified")
  echo "Hello my friend - $NOW"
  ;;
"log")
  show_log
  ;;
"hello")
  echo "Hello my friend - $NOW"
  ;;
"test")
  start_test
  ;;
"help")
  echo "Available commands are: "
  echo "  create   - Create new snapshot"
  echo "  restore  - Restore the last snapshot available in folder snapshot/"
  echo "  log      - Display log"
  ;;
*)
  echo "Error: Unrecognized command."
  echo ""
  echo "Available commands are: create, restore, log, help"
  echo "Try: bash shift-snapshot.sh help"
  ;;
esac