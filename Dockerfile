
FROM oraclelinux:6.6
MAINTAINER Casto Colina <casto.colina@karibu.cl>

EXPOSE 7001

EXPOSE 7002

########################## ENVIROMENT
ENV JDK_INST=jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin WLS_INST=wls1036_generic.jar
ENV JAVA_HOME /usr/lib/jvm/jrockit-jdk1.6.0_45-R28.2.7-4.1.0
ENV MW_HOME /u01/app/oracle/middleware
ENV WLS_HOME "$MW_HOME/wlserver_10.3"
ENV WL_HOME $WLS_HOME

########################## COPY
RUN mkdir -p /tmp/install
WORKDIR /tmp/install

COPY ${JDK_INST} ${WLS_INST} ./
RUN chmod +x ./${JDK_INST}

COPY silent-jr.xml silent-wls.xml base_domain.py base_domain.properties ./

##########################  INSTALL JRockit
RUN ./${JDK_INST} -mode=silent -silent_xml="./silent-jr.xml"
RUN /usr/sbin/alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 
RUN /usr/sbin/alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1
RUN java -version && javac -version

########################## INSTALL WLS
RUN touch ./wls_installer.log
RUN java -d64 -jar ./${WLS_INST} -mode=silent -silent_xml="./silent-wls.xml"
RUN ls -la ${MW_HOME}

########################## CREATE WLS DOMAIN
ENV PATH $JAVA_HOME/bin:$PATH 
ENV CONFIG_JVM_ARGS -Djava.security.egd=file:/dev/./urandom

RUN . $WLS_HOME/server/bin/setWLSEnv.sh

# Create the domain.
RUN java -cp $WLS_HOME/server/lib/weblogic.jar weblogic.WLST base_domain.py -p base_domain.properties


########################## DELETE FILES
WORKDIR /
RUN rm -rf /tmp/install

RUN yum clean all && rm -rf /var/cache/*

########################## START INSTANCE COMMANDS
ENTRYPOINT ["./u01/app/oracle/middleware/user_projects/domains/base_domain/bin/startWebLogic.sh"]
