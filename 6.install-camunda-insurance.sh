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


if [ -d "$TMP_INSTALL/workplacebpm" ]; then
	sudo rm -rf $TMP_INSTALL/workplacebpm
fi

git clone https://bitbucket.org/workplace101/workplacebpm.git $TMP_INSTALL/workplacebpm
cd $TMP_INSTALL/workplacebpm/src/camunda-showcase-insurance-application-master
mvn clean install -Dmaven.test.skip=true

if [ -d "$CATALINA_HOME/webapps/camunda-showcase-insurance-application" ]; then
	sudo rm -rf $CATALINA_HOME/webapps/camunda-showcase-insurance-application*
fi
sudo rsync -avz $TMP_INSTALL/workplacebpm/src/camunda-showcase-insurance-application-master/target/camunda-showcase-insurance-application.war $CATALINA_HOME/webapps/camunda-showcase-insurance-application.war

sleep 20

# Use version 2.0 rather than 1.1
sudo rm $CATALINA_HOME/webapps/camunda-showcase-insurance-application/WEB-INF/lib/jsr311-api-1.1.1.jar

# Use newer version of mysql connector
sudo rm -rf $CATALINA_HOME/lib/mysql-connector-*.jar
curl -# -o $CATALINA_HOME/lib/mysql-connector-java-5.1.46.jar $MYSQL_CONNECTOR_5146_URL


. $DEVOPS_HOME/devops-service.sh restart
