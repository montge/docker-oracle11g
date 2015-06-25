FROM hedlund/oraclelinux:6
MAINTAINER henrik@hedlund.im

# Add extra packages
RUN yum install -y oracle-rdbms-server-11gR2-preinstall unzip

# Create directories
RUN mkdir /opt/oracle /opt/oraInventory /opt/datafile && chown oracle:oinstall -R /opt

# Add the *huge* installation files
ADD linux.x64_11gR2_database_1of2.zip /tmp/
ADD linux.x64_11gR2_database_2of2.zip /tmp/

# Add response files
ADD db_install.rsp /tmp/
ADD dbca.rsp /tmp/

# Install xorg stuff
RUN yum install -y xorg-x11-app*

# Unpack the installation files
WORKDIR /tmp
RUN unzip linux.x64_11gR2_database_1of2.zip
RUN unzip linux.x64_11gR2_database_2of2.zip
RUN rm -f linux.x64_11gR2_database_?of2.zip

# Make user the oracle user *REALLY* is in the oinstall group
RUN usermod -a -G oinstall oracle
RUN echo "* - nproc 16384" >> /etc/security/limits.d/90-nproc.conf

# Setup the environment variables
USER oracle
ENV ORACLE_BASE /opt/oracle
ENV ORACLE_HOME /opt/oracle/product/11.2.0/dbhome_1
ENV ORACLE_SID orcl
ENV PATH $ORACLE_HOME/bin:$PATH

# Run the installer (which spawns a new process), and wait for it to finish (takes a while)
RUN /tmp/database/runInstaller -silent -ignorePrereq -responseFile /tmp/db_install.rsp && JAVAPID=$(pidof java) && while [ -e /proc/$JAVAPID ]; do echo "Waiting for install process to finish"; sleep 10s; done

# Run the remaining install scripts as root
USER root
RUN /opt/oraInventory/orainstRoot.sh
RUN /opt/oracle/product/11.2.0/dbhome_1/root.sh

# Add the startup script
ADD startup.sh /usr/sbin/
RUN chmod +x /usr/sbin/startup.sh

USER oracle

# Create a listener
RUN export DISPLAY=hostname:0.0 && netca -silent -responseFile /tmp/database/response/netca.rsp

# Override the generated listener setting to make it listen on 0.0.0.0
ADD listener.ora /opt/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora

# Create a database
RUN lsnrctl start && dbca -silent -createDatabase -responseFile /tmp/dbca.rsp

# Expose the relevant port
EXPOSE 1521

# Do some cleanup
USER root
RUN rm -rf /tmp/database
USER oracle

# Run the startup script and then tail the listener log to keep something alive
CMD /usr/sbin/startup.sh && tail -f tail -f /opt/oracle/diag/tnslsnr/$HOSTNAME/listener/alert/log.xml
