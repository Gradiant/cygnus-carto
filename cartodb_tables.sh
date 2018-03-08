#!/bin/bash
#
# Copyright (C) 2017  Gradiant <https://www.gradiant.org/>
#
# This file is part of CYGNUS-CARTO 
#
# CYGNUS-CARTO is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# CYGNUS-CARTO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


if [ "$CARTODB_CONFIG" == "false" ]; then
    exit 0
fi

sleep $CARTODB_TIMEOUT

ENDPOINT="$CARTODB_ENDPOINT"	# Our carto instance endpoint
API_KEY="$CYGNUS_CARTO_KEY"  	# Got from our carto instance web interface
TABLE_NAME="x002f"			    # For dm-by-service-path this is the table name if path=/
USER="$CYGNUS_CARTO_USER"
COLUMNS="$CARTO_TABLE_COLUMNS"
SCHEMA="public"
VERSION="v2"

# expand columns
COLUMNS_C=$(echo $COLUMNS | tr " " "|")
COLUMN_L=(${COLUMNS_C//,/ })
NEW_C=""
for COLUMN in ${COLUMN_L[@]}
do
    echo $COLUMN
    COLUMN_C=$(echo $COLUMN | tr "|" " ")
    echo $COLUMN_C
    COLUMN_S=(${COLUMN_C// / })
    COLUMN_NAME=${COLUMN_S[0]}
    echo $COLUMN_NAME
    COLUMN_TYPE=${COLUMN_S[1]}
    echo $COLUMN_TYPE
    NEW_C="$NEW_C $COLUMN_NAME $COLUMN_TYPE, ${COLUMN_NAME}_md text,"
done

# create table (x002f) for all the entities on the same fiware service path (/)
curl -G "http://$ENDPOINT/user/$USER/api/$VERSION/sql?api_key=$API_KEY" \
     --data-urlencode "q=CREATE TABLE $TABLE_NAME (recvTime text, fiwareServicePath text, entityId text, entityType text, $NEW_C the_geom geometry(POINT,4326))" &&

# Every table in Carto has to be cartodbfied, if you want it appears in Carto web-based dashboard
curl -G "http://$ENDPOINT/user/$USER/api/$VERSION/sql?api_key=$API_KEY" --data-urlencode "q=SELECT CDB_CartodbfyTable('$SCHEMA', '$TABLE_NAME')"

