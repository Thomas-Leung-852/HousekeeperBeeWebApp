#!/bin/bash

echo ========================================================
echo Setup App Updater
echo ========================================================
echo

file=$(find ~ -wholename '*/HousekeeperBeeWebAppUpdateTool/update_version.sh' | head -n 1)

if [ -z "$file" ]; then

   if [ -z "$HOUSEKEEPER_BEE_HOME" ]; then
      HOUSEKEEPER_BEE_HOME=$(dirname "$HOUSEKEEPER_BEE_SETUP_PATH")
   fi

   cd $HOUSEKEEPER_BEE_HOME
   git clone https://github.com/Thomas-Leung-852/HousekeeperBeeWebAppUpdateTool.git
   wait

   sudo chmod +x $HOUSEKEEPER_BEE_HOME/HousekeeperBeeWebAppUpdateTool/*.sh

   $HOUSEKEEPER_BEE_HOME/HousekeeperBeeWebAppUpdateTool/manage_auto_update.sh enable-auto-update 
   wait

   cd "$HOUSEKEEPER_BEE_SETUP_PATH"

   echo "Setup Completed!"
else
   echo "App Updater already installed!"
fi







