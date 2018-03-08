# Cygnus NGSI Agent for Carto
This build of [Cygnus NGSI Agent](https://hub.docker.com/r/fiware/cygnus-ngsi/) includes a code patch to allow compatibility with arrays in CartoDB. It also has some utilities for CartoDB table creation, and for automatic subscription refresh to Orion Context Broker.

## Lauch container
### Default container
```
sudo docker run -d --name cygnus -p 5050:5050 gradiant/cygnus
```

### Custom configuration
We can deploy the container with a custom agent.conf file and enable CartoDB table creation and automatic orion subscription renovation.
```
sudo docker run -d --name cygnus -p 5050:5050 -v $PWD/cygnus-agent.conf:/opt/apache-flume/conf/agent.conf -v $PWD/cartodb_keys.conf:/usr/cygnus/conf/cartodb_keys.conf smarnet/cygnus-ngsi -e CARTODB_CONFIG='true' -e CARTO_TABLE_COLUMNS='temperature real, humidity real, enabled boolean' -e CYGNUS_CARTO_USER='smarnet' -e CYGNUS_CARTO_KEY='get-key-from-carto-web' -e CARTODB_ENDPOINT='smarnet.carto' -e CYGNUS_PORT='9091' -e CYGNUS_HOST='192.168.251.183' -e ORION_PORT='1026' -e ORION_HOST='192.168.199.139' -e SUBSCRIPTION_ID='59a7cce7784712b94614ec2e' gradiant/cygnus
```

### Enviroment variables:
```
CARTODB_CONFIG: If true, the container will try to create the needed database table in Carto instance.
CYGNUS_CARTO_USER: Carto username to create the table for.
CARTO_TABLE_COLUMNS: List of Carto database table columns, ignored if CARTODB_CONFIG is false. Format: 'column_1_name column_1_type, column_2_name column_2_type, ..., column_N_name column_N_type'. The metadata columns (columnName_md) will be created automatically, as the basic columns "recvTime", "fiwareServicePath", "entityId", "entityType" and "the_geom"
CYGNUS_CARTO_KEY: User's key to access Carto in its name.
CARTODB_ENDPOINT: Carto endpoint in the form of ip:port (ie: 127.0.0.1:80)
CYGNUS_PORT: Cygnus own public port to create a new subscription once the container starts.
CYGNUS_HOST: Cygnus own public host to create a new subscription once the container starts.
ORION_PORT: Orion public port to create a new subscription once the container starts.
ORION_HOST: Orion public host to create a new subscription once the container starts.
SUBSCRIPTION_ID: If not set, the container will try to create a default subscription and update it periodically. If we provide a valid ID the script will not create a new subscription, but will update it.
```
Some of these variables will also need to be filled in the configuration file.
### Cartodb keys configuration
```
{
   "cartodb_keys": [
      {
         "username": "default",
         "endpoint": "http://smarnet.localhost:8080/",
         "key": "dbd6e11a879e83603e9cdb1dbca0ff0193311646",
         "type": "personal"
      }
   ]
}
```
Variables:
```
username: Must be default for self hosted cartodb, if not cygnus will throw a nullPointerException.
endpoint: Must be in the form: "http://<cartodb_username>.<pattern_in_sqlAPI_config>:<sqlAPI_port>/"
key: Retrieved from carto web interface.
type: Personal for self hosted cartodb.
```
### Orion subscription
We create a subscription on beforehand to the Cygnus startup so we can customize its parameters. The we pass the resulting ID to the Cygnus container using the SUBSCRIPTION_ID environment variable.
```
curl --request POST \
  --url http://ORION_IP:1026/v1/subscribeContext \
  --header 'accept: application/json' \
  --header 'content-type: application/json' \
  --header 'x-auth-token: token' \
  --data '{"entities":[{"type": "ENTITY_1","isPattern": "true","id": "/*"},{"type": "ENTITY_2","isPattern": "true","id": "/*"}],"attributes": ["ATTR_1","ATTR_2","ATTR_3","ATTR_4","ATTR_5","ATTR_6"],"reference": "http://CYGNUS_IP:5050/notify","duration": "P100Y","notifyConditions": [{"type": "ONCHANGE","condValues": ["ATTR_1"]}]}'
```
