#!/bin/bash

# Prerequisities and checks start.

# --- Add /etc/hosts records
if [ -f /etc/hosts.install ]; then
    /bin/cat /etc/hosts.install >>/etc/hosts
fi

# --- Fix file permissions.
/usr/bin/find /var/atlassian/jira -type d -exec /bin/chmod 750 '{}' ';'
/usr/bin/find /var/atlassian/jira -type f -exec /bin/chmod 640 '{}' ';'
/usr/bin/find /usr/local/atlassian/jira -type d -exec /bin/chmod 750 '{}' ';' 
/usr/bin/find /usr/local/atlassian/jira -type f -exec /bin/chmod 640 '{}' ';'
/bin/chmod 755 /var/atlassian
/bin/chmod 755 /usr/local/atlassian
/bin/chmod 750 /usr/local/atlassian/jira/bin/*
/bin/chown root:root /var/atlassian
/bin/chown root:root /usr/local/atlassian
/bin/chown -R jira:jira /var/atlassian/jira
/bin/chown -R jira:jira /usr/local/atlassian/jira

# --- Clean up the logs.
if [ ! -d /var/atlassian/jira/logs ]; then
    /bin/rm -f /var/atlassian/jira/logs >/dev/null 2>&1
    /bin/mkdir /var/atlassian/jira/logs
    /bin/chown jira:jira /var/atlassian/jira/logs
    /bin/chmod 750 /var/atlassian/jira/logs
fi

if [ ! -e /var/atlassian/jira/log ]; then
    /bin/ln -s /var/atlassian/jira/logs /var/atlassian/jira/log
    /bin/chown -h jira:jira /var/atlassian/jira/log
fi

cd /var/atlassian/jira/logs

for logfile in $(/usr/bin/find /var/atlassian/jira/logs -type f | /bin/grep -Eiv '\.gz$'); do
    /usr/bin/gzip ${logfile}
    /bin/mv ${logfile}.gz ${logfile}-$(/usr/bin/date +%d%m%Y-%H%M%S).gz
done

for logfile in $(/usr/bin/find /var/atlassian/jira/logs -type f -mtime +7); do
    /bin/echo "Startup logfile ${logfile} is older than 7 days. Removing it."
    /bin/rm -f ${logfile}
done

# --- Prepare environment variables.
if [ -f /usr/local/atlassian/jira/conf/server.xml.template ]; then
    export JIRA_FE_NAME_ESCAPED=$(/bin/echo ${JIRA_FE_NAME} | sed s/'\\'/'\\\\'/g | sed s/'\/'/'\\\/'/g | sed s/'('/'\\('/g | sed s/')'/'\\)'/g | sed s/'&'/'\\&'/g)
    export JIRA_FE_PORT_ESCAPED=$(/bin/echo ${JIRA_FE_PORT} | sed s/'\\'/'\\\\'/g | sed s/'\/'/'\\\/'/g | sed s/'('/'\\('/g | sed s/')'/'\\)'/g | sed s/'&'/'\\&'/g)
    export JIRA_FE_PROTO_ESCAPED=$(/bin/echo ${JIRA_FE_PROTO} | sed s/'\\'/'\\\\'/g | sed s/'\/'/'\\\/'/g | sed s/'('/'\\('/g | sed s/')'/'\\)'/g | sed s/'&'/'\\&'/g)
    export CONFIGURE_FRONTEND_ESCAPED=$(/bin/echo ${CONFIGURE_FRONTEND} | sed s/'\\'/'\\\\'/g | sed s/'\/'/'\\\/'/g | sed s/'('/'\\('/g | sed s/')'/'\\)'/g | sed s/'&'/'\\&'/g | sed -r s/'[ ]+'/''/g)
    
    if [ "${CONFIGURE_FRONTEND_ESCAPED}" != "TRUE" -a "${CONFIGURE_FRONTEND_ESCAPED}" != "true" ]; then 
        /bin/sed -r s/'proxyName="[^"]+" proxyPort="[^"]+" scheme="[^"]+" '//g /usr/local/atlassian/jira/conf/server.xml.template >/usr/local/atlassian/jira/conf/server.xml.template.2
        /bin/mv /usr/local/atlassian/jira/conf/server.xml.template.2 /usr/local/atlassian/jira/conf/server.xml.template
    fi
    
    /bin/cat /usr/local/atlassian/jira/conf/server.xml.template | /bin/sed s/'\%JIRA_FE_NAME\%'/"${JIRA_FE_NAME_ESCAPED}"/g          \
                                                                | /bin/sed s/'\%JIRA_FE_PORT\%'/"${JIRA_FE_PORT_ESCAPED}"/g          \
                                                                | /bin/sed s/'\%JIRA_FE_PROTO\%'/"${JIRA_FE_PROTO_ESCAPED}"/g        \
                                                                >/usr/local/atlassian/jira/conf/server.xml

    /bin/chown jira:jira /usr/local/atlassian/jira/conf/server.xml
    /bin/chmod 640 /usr/local/atlassian/jira/conf/server.xml
    /bin/rm -f /usr/local/atlassian/jira/conf/server.xml.template
fi
    
if [ -f /usr/local/atlassian/jira/bin/setenv.sh.template ]; then
    export JAVA_MEM_MIN_ESCAPED=$(/bin/echo ${JAVA_MEM_MIN} | sed s/'\\'/'\\\\'/g | sed s/'\/'/'\\\/'/g | sed s/'('/'\\('/g | sed s/')'/'\\)'/g | sed s/'&'/'\\&'/g)
    export JAVA_MEM_MAX_ESCAPED=$(/bin/echo ${JAVA_MEM_MAX} | sed s/'\\'/'\\\\'/g | sed s/'\/'/'\\\/'/g | sed s/'('/'\\('/g | sed s/')'/'\\)'/g | sed s/'&'/'\\&'/g)

    /bin/cat /usr/local/atlassian/jira/bin/setenv.sh.template | /bin/sed s/'\%JAVA_MEM_MIN\%'/"${JAVA_MEM_MIN}"/g          \
                                                              | /bin/sed s/'\%JAVA_MEM_MAX\%'/"${JAVA_MEM_MAX}"/g          \
                                                              >/usr/local/atlassian/jira/bin/setenv.sh
    
    /bin/chown jira:jira /usr/local/atlassian/jira/bin/setenv.sh
    /bin/chmod 750 /usr/local/atlassian/jira/bin/setenv.sh
    /bin/rm -f /usr/local/atlassian/jira/bin/setenv.sh.template
fi

# --- Prerequisities finished, all clear for takeoff.

# --- Environment variables.
export APP=jira
export USER=jira
export CONF_USER=jira
export BASE=/usr/local/atlassian/jira
export CATALINA_HOME="/usr/local/atlassian/jira"
export CATALINA_BASE="/usr/local/atlassian/jira"
export LANG=en_US.UTF-8

# --- Start Jira
/usr/bin/su -m ${USER} -c "ulimit -n 63536 && cd $BASE && $BASE/bin/start-jira.sh -fg"
