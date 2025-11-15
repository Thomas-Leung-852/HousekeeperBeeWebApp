#!/bin/bash

FINDER_DIR=$(dirname $(find ~ -wholename "*/housekeeping_bee/finder/setup_server.sh" | head -n 1 ))

cd $FINDER_DIR
chmod +x *.sh
./setup_server.sh

cd "$HOUSEKEEPER_BEE_SETUP_PATH"

