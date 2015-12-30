# docker-jira

# DESCRIPTION
=======================================================================

A flexible and configurable docker image to run Atlassian Jira.
(https://www.atlassian.com/software/jira)

Forks Ingensi oracle-jdk Docker image.
(https://hub.docker.com/r/ingensi/oracle-jdk/)

# USAGE
======================================================================

  1. Edit the Makefile header to specify default values for container
     variables.

  2. In case you need any custom /etc/hosts records to be added, check
     image/support-files/install.hosts file, and add those records there.
     Records from this file will be automatically added by container
     bootstrap on container load.

  3. In case you need any CA certificates to be imported into the JVM
     truststore - specify the download links for them, in
     image/support-files/install.certificates file.
     Certificates from this file will be automatically downloaded and
     imported into JVM truststore on container build.

  4. If you wish to build any other version of Atlassian Jira -
     specify the version number in JIRA.VERSION file.

  4. Run 'make'. Container will be built and initialized immediately.

  In case this system already has a previous version
  of this container (say with your current version of Jira)
  data container from it will be automatically remapped to your
  new container to keep your data intact. Stopping the previous
  container remains your job though.

  Enjoy!

# VARIABLES
========================================================================

  Container takes the following variables.

  * CONFIGURE_FRONTEND       - Whether or not to configure Tomcat with
                               proxy awareness. If set to TRUE, Tomcat
                               will be instructed, that it runs behind
                               a reverse proxy. Otherwise, it will not be
                               done and the fields below regarding FE
                               connection may be left blank.
                               (default: FALSE)

  * JAVA_OPTS                - Arguments to be passed to JVM on startup.

  * JIRA_FE_NAME             - Frontend DNS name, where Jira is
                               reachable. (i.e. jira.local)
  * JIRA_FE_PORT             - Frontend port number, where Jira is
                               reachable. (i.e. 443)
  * JIRA_FE_PROTO            - Frontend protocol where Jira is
                               reachable. Either 'http' or 'https'.

  * MEMORY_LIMIT             - Maximum amount of memory that can be used
                               by this container. In megabytes.
                               (i.e. 4096 - means that this container, can
                                use up to 4G of memory)

  * CPU_LIMIT_CPUS           - Either a comma separated or a range (X-Y)
                               list of CPU cores where this container is
                               allowed to execute. Enumerations starts
                               with 0.
                               Default 0-2.

  * CPU_LIMIT_LOAD           - Maximum load in percents, this container
                               can take from CPU-s under subject.
                               Default 100.

  * IO_LIMIT                 - A number between 10 and 1000 representing
                               the priority of this containers I/O load
                               in comparsion to all other containers I/O load.
                               Used within container I/O load prioritization.
                               Default 500.

  Please see Makefile for details.
=======================================================================
