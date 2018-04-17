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

echogreen "Setting up Eforms Camunda..........."

if [ "`which git`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echored "Please run ubuntu-upgrade.sh firstly to install git before running this script."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
fi

if [ -d "$TMP_INSTALL/workplacebpm" ]; then
	sudo rm -rf $TMP_INSTALL/workplacebpm
fi

sudo git clone https://DigitalBusiness@bitbucket.org/workplace101/workplacebpm.git $TMP_INSTALL/workplacebpm
cd $TMP_INSTALL/workplacebpm/src/eForm
source /etc/profile.d/maven.sh
mvn clean install
sudo rsync -avz $TMP_INSTALL/workplacebpm/src/eForm/gateway/target/eform.war $CATALINA_HOME/webapps

read -e -p "Please enter the public host name for Camunda server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" CAMUNDA_HOSTNAME
	
if [ -f "/etc/nginx/sites-available/$CAMUNDA_HOSTNAME.conf" ]; then
	sudo sed -i "0,/server/s/server/upstream eform {	    \n\tserver localhost:$TOMCAT_HTTP_PORT;	\n}\n\n&/" /etc/nginx/sites-available/$CAMUNDA_HOSTNAME.conf
 
 # Insert camunda configuration content before the last line in domain.conf in nginx
 #sudo sed -i "$e cat $NGINX_CONF/sites-available/camunda.conf" /etc/nginx/sites-available/$hostname.conf
 sudo mkdir temp
 sudo cp $NGINX_CONF/sites-available/eform.snippet	temp/
 sudo sed -e '/##EFORM##/ {' -e 'r temp/eform.snippet' -e 'd' -e '}' -i /etc/nginx/sites-available/$CAMUNDA_HOSTNAME.conf
 sudo rm -rf temp
fi