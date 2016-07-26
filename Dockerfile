##docker build --no-cache -t castokaribu/ol6_wls:1 .

##docker run -t -i --name pepe oraclelinux:6 /bin/bash
##docker start -i pepe

##docker run -d --name wls -p 7001:7001 castokaribu/ol6_wls:1
##docker run -d --name wls castokaribu/ol6_wls:1
##docker start wls
##docker logs -i wls
##docker exec wls /etc/init.d/wlsbasedom status

FROM centos:6
MAINTAINER Casto Colina <casto.colina@karibu.cl>

RUN mkdir -p /tmp/install
WORKDIR /tmp/install

COPY jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin wls1036_generic.jar ./
COPY silent-jr.xml silent-wls.xml wlsdomain_service.sh base_domain.py base_domain.properties ./

RUN chmod +x ./jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin && chmod +x ./wls1036_generic.jar

##########################  INSTALL JRockit
RUN ./jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin -mode=silent -silent_xml="./silent-jr.xml"
RUN /usr/sbin/alternatives --install /usr/bin/java java /usr/lib/jvm/jrockit-jdk1.6.0_45-R28.2.7-4.1.0/bin/java 1 &&/usr/sbin/alternatives --install /usr/bin/javac javac /usr/lib/jvm/jrockit-jdk1.6.0_45-R28.2.7-4.1.0/bin/javac 1
RUN java -version && javac -version
ENV JAVA_HOME /usr/lib/jvm/jrockit-jdk1.6.0_45-R28.2.7-4.1.0

########################## INSTALL WLS
RUN touch ./wls_installer.log
RUN java -d64 -jar ./wls1036_generic.jar -mode=silent -silent_xml="./silent-wls.xml"
RUN ls -la /u01/app/oracle/middleware/

########################## CREATE WLS DOMAIN
ENV MW_HOME /u01/app/oracle/middleware
ENV WLS_HOME "$MW_HOME/wlserver_10.3"
ENV WL_HOME $WLS_HOME
ENV PATH $JAVA_HOME/bin:$PATH 
ENV CONFIG_JVM_ARGS -Djava.security.egd=file:/dev/./urandom

RUN . $WLS_HOME/server/bin/setWLSEnv.sh

# Create the domain.
RUN java -cp $WLS_HOME/server/lib/weblogic.jar weblogic.WLST base_domain.py -p base_domain.properties

########################## INSTALL SERVICE
RUN mv wlsdomain_service.sh /etc/init.d/wlsbasedom
RUN chmod +x /etc/init.d/wlsbasedom
RUN chkconfig --add wlsbasedom
RUN chkconfig --list
#RUN /sbin/service wlsbasedom status

########################## DELETE FILES
WORKDIR /
RUN rm -rf /tmp/install

########################## UPDATE SYSTEM
RUN yum update -y
RUN yum install nano -y

CMD /etc/init.d/wlsbasedom start

EXPOSE 7001
EXPOSE 7002
