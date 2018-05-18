#!/bin/bash
# -------
# This is script to setup eform workplace
# -------

# Configure constants
if [ -f "constants.sh" ]; then
	. constants.sh
fi

# Configure colors
if [ -f "colors.sh" ]; then
	. colors.sh
fi

echogreen "Setting up Camunda Insurance..........."


if [ -d "$TMP_INSTALL/camunda-insurance" ]; then
	sudo rm -rf $TMP_INSTALL/camunda-insurance
fi

git clone https://bitbucket.org/workplace101/camunda-insurance.git $TMP_INSTALL/camunda-insurance
cd $TMP_INSTALL/camunda-insurance
mvn clean install

if [ -d "$CATALINA_HOME/webapps/camunda-insurance" ]; then
	sudo rm -rf $CATALINA_HOME/webapps/camunda-insurance*
fi
sudo rsync -avz $TMP_INSTALL/camunda-insurance/target/camunda-insurance.war $CATALINA_HOME/webapps/insurance.war

# Use version 2.0 rather than 1.1
sudo rm  $CATALINA_HOME/webapps/insurance/WEB-INF/lib/jsr311-api-1.1.1.jar

# Use newer version of mysql connector
sudo rm  $CATALINA_HOME/lib/mysql-connector-java*.jar
curl -# -o $CATALINA_HOME/lib/mysql-connector-java-5.1.46.jar $MYSQL_CONNECTOR_5146_URL


. $DEVOPS_HOME/devops-service.sh restart