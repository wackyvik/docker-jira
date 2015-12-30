FROM ingensi/oracle-jdk:latest
MAINTAINER Viktor Larionov <larionov@viktor.ee>

VOLUME [ "/var/atlassian/jira" ]

# Install required utilities.
RUN /usr/bin/yum install -y gzip   && \
    /usr/bin/yum install -y tar    && \
    /usr/bin/yum install -y bzip2

# Import certificates to JVM truststore.
ADD support-files/install.certificates /var/tmp/install.certificates
RUN for certificate_url in $(/bin/cat /var/tmp/install.certificates); do                                                   \
        certificate=/var/tmp/$(/bin/basename ${certificate_url});                                                          \
        /usr/bin/wget --progress=bar:force ${certificate_url} -O ${certificate};                                           \
        alias=$(/bin/basename ${certificate} | /bin/sed s/'\.pem'/''/g | /bin/sed s/'\.crt'/''/g);                         \
        /usr/java/default/bin/keytool -importcert -trustcacerts -file ${certificate} -alias ${alias} -keystore /etc/pki/ca-trust/extracted/java/cacerts -storepass changeit -storetype JKS -noprompt; \
        /usr/java/default/bin/keytool -importcert -trustcacerts -file ${certificate} -alias ${alias} -keystore /usr/java/default/jre/lib/security/cacerts -storepass changeit -storetype JKS -noprompt; \
        /bin/rm -f ${certificate};                                                                                         \
    done                                                                                                                && \
    /bin/rm -f /var/tmp/install.certificates

# Prepare the directory layout.
RUN /bin/mkdir -p /usr/local/atlassian/jira && \
    /bin/mkdir -p /var/atlassian/jira

# Creating user and group.
RUN /sbin/groupadd -g 9998 jira                                                                                            && \
    /sbin/useradd -u 9998 -d /usr/local/atlassian/jira -c "Atlassian Jira" -g jira -M -s /bin/bash jira

# Install Jira binaries from package.
ADD support-files/JIRA.VERSION /usr/local/atlassian/jira/JIRA.VERSION
RUN VERSION=$(/bin/cat /usr/local/atlassian/jira/JIRA.VERSION)                              && \
    /usr/bin/wget --progress=bar:force https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${VERSION}-jira-${VERSION}.tar.gz -O /var/tmp/atlassian-jira-software-${VERSION}-standalone.tar.gz && \
    cd /var/tmp                                                                                                       && \
    /usr/bin/tar -xvzf /var/tmp/atlassian-jira-software-${VERSION}-standalone.tar.gz                                  && \
    /bin/cp -rfa /var/tmp/atlassian-jira-software-${VERSION}-standalone/atlassian-jira /usr/local/atlassian/jira/     && \
    /bin/cp -rfa /var/tmp/atlassian-jira-software-${VERSION}-standalone/bin /usr/local/atlassian/jira/                && \
    /bin/cp -rfa /var/tmp/atlassian-jira-software-${VERSION}-standalone/conf /usr/local/atlassian/jira/               && \
    /bin/cp -rfa /var/tmp/atlassian-jira-software-${VERSION}-standalone/lib /usr/local/atlassian/jira/                && \
    /bin/cp -rfa /var/tmp/atlassian-jira-software-${VERSION}-standalone/webapps /usr/local/atlassian/jira/            && \
    /bin/cp -rfa /var/tmp/atlassian-jira-software-${VERSION}-standalone/work /usr/local/atlassian/jira/               && \
    /bin/rm -rf /var/tmp/atlassian-jira-software-${VERSION}-standalone                                                && \
    /bin/rm -rf /var/tmp/atlassian-jira-software-${VERSION}-standalone.tar.gz

# Install Jira RC scripts.
ADD support-files/install.hosts /etc/hosts.install
ADD support-files/jira-init.sh /sbin/jira-init.sh

# Create symlinks for correct layout.
RUN /bin/ln -s /var/tmp /usr/local/atlassian/jira/temp                  && \
    /bin/ln -s /var/atlassian/jira/logs /usr/local/atlassian/jira/logs  && \
    /bin/ln -s /var/atlassian/jira/logs /var/atlassian/jira/log

# Install configuration overlay.
ADD conf-overlay/logging.properties /usr/local/atlassian/jira/conf/
ADD conf-overlay/jira-application.properties /usr/local/atlassian/jira/atlassian-jira/WEB-INF/classes/jira-application.properties
ADD conf-overlay/setenv.sh /usr/local/atlassian/jira/bin/setenv.sh.template
ADD conf-overlay/server.xml /usr/local/atlassian/jira/conf/server.xml.template

# ENTRYPOINT
RUN /bin/chown root:root /sbin/jira-init.sh && \
    /bin/chmod 755 /sbin/jira-init.sh
CMD /sbin/jira-init.sh

# Expose default ports for Jira.
EXPOSE 8080
