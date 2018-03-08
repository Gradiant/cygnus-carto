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

while :
do
    sleep 86400

    if [ -z ${ORION_HOST+x} ]; then
        ORION_HOST="orion"
    fi

    if [ -z ${ORION_PORT+x} ]; then
        ORION_PORT="1026"
    fi

    if [ -z ${CYGNUS_HOST+x} ]; then
        CYGNUS_HOST="cygnus"
    fi

    if [ -z ${CYGNUS_PORT+x} ]; then
        CYGNUS_PORT="9091"
    fi

    if [ -z ${SUBSCRIPTION_ID+x} ]; then
        SUBSCRIPTION_ID=$(cat subscription_id)
    fi

    if [ -z ${SUBSCRIPTION_ID+x} ]; then
        SUBSCRIPTION_ID="$(curl --request POST --url http://$ORION_HOST:$ORION_PORT/v1/subscribeContext --header 'accept: application/json' --header 'content-type: application/json'  --data '{"entities": [{"type": "BARCO", "isPattern": "true", "id": "/*"}, {"type": "ALERTA", "isPattern": "true", "id": "/*"}, {"type": "BOYA", "isPattern": "true", "id": "/*"}],"attributes": ["location", "tipo_barco", "rumbo", "velocidad", "lance_activo", "en_puerto", "tipo_alerta", "emisor", "mmsi", "tripulante", "activa", "cancelador", "barco", "boya_calada", "desplegada", "arte", "tripulacion"], "reference": "http://'$CYGNUS_HOST':'$CYGNUS_PORT'/notify", "duration": "P1M", "notifyConditions": [{"type": "ONCHANGE", "condValues": ["location"]}]}' | jq -r .subscribeResponse.subscriptionId)"
        echo $SUBSCRIPTION_ID > subscription_id
    else
        RESULT="$(curl --request POST --url http://$ORION_HOST:$ORION_PORT/v1/updateContextSubscription --header 'accept: application/json' --header 'content-type: application/json' --data '{"subscriptionId": "'$SUBSCRIPTION_ID'", "duration": "P1M"}' | jq .subscribeError)"
        if [ $RESULT == "null" ]; then
            SUBSCRIPTION_ID="$(curl --request POST --url http://$ORION_HOST:$ORION_PORT/v1/subscribeContext --header 'accept: application/json' --header 'content-type: application/json'  --data '{"entities": [{"type": "BARCO", "isPattern": "true", "id": "/*"}, {"type": "ALERTA", "isPattern": "true", "id": "/*"}, {"type": "BOYA", "isPattern": "true", "id": "/*"}],"attributes": ["location", "tipo_barco", "rumbo", "velocidad", "lance_activo", "en_puerto", "tipo_alerta", "emisor", "mmsi", "tripulante", "activa", "cancelador", "barco", "boya_calada", "desplegada", "arte", "tripulacion"], "reference": "http://'$CYGNUS_HOST':'$CYGNUS_PORT'/notify", "duration": "P1M", "notifyConditions": [{"type": "ONCHANGE", "condValues": ["location"]}]}' | jq -r .subscribeResponse.subscriptionId)"
            echo $SUBSCRIPTION_ID > subscription_id
        fi
    fi
done