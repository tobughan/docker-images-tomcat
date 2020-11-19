FROM anapsix/alpine-java:8u201b09_jdk

ENV CATALINA_HOME="/opt/tomcat" \
    TOMCAT_VERSION=8.5.60 \
    TOMCAT_NATIVE_LIBDIR="/opt/tomcat/lib" \
    TOMCAT_TGZ_URLS="http://mirrors.aliyun.com/apache/tomcat/tomcat-8/v8.5.60/bin/apache-tomcat-8.5.60.tar.gz" \
    PATH="$PATH:/opt/tomcat/bin" \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/opt/tomcat/lib
RUN echo http://mirrors.aliyun.com/alpine/v3.8/main >/etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/v3.8/community >>/etc/apk/repositories && \
    apk add --no-cache gcc make apr-dev openssl-dev libc-dev && \
    wget -O /opt/apache-tomcat-$TOMCAT_VERSION.tar.gz ${TOMCAT_TGZ_URLS} && \
    tar -xvf /opt/apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt && \
    rm -f /opt/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    mv /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME && \
    tar -xvf $CATALINA_HOME/bin/tomcat-native.tar.gz -C /opt && \
    rm -f $CATALINA_HOME/bin/tomcat-native.tar.gz && \
    TOMCAT_NATIVE_HOME=$(ls -d /opt/tomcat-native*) && \
    cd ${TOMCAT_NATIVE_HOME}/native && \
    ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=/opt/jdk${JDK_VERSION} --with-ssl=yes --prefix=$CATALINA_HOME && \
    make && make install && \
    rm -rf ${TOMCAT_NATIVE_HOME} && \
    rm -rf $CATALINA_HOME/webapps/* && \
    sed -ri '/.*<!--The connectors/{N;N;N;N;s#(pools--.\n)(.*--\n)(.*/.\n)(.*)#\1\3#}' $CATALINA_HOME/conf/server.xml && \
    sed -ri '/.*<!--.*pool/{N;N;N;N;N;N;s#(pool--.\n)(.*--\n)(.*/.\n)(.*)#\1\3#}' $CATALINA_HOME/conf/server.xml && \
    sed -i '/Connector port="8080"/i \    <!--' $CATALINA_HOME/conf/server.xml && \
    sed -i '/.*<!--.*pool/i \    -->' $CATALINA_HOME/conf/server.xml && \
    sed -i '/Connector port="8009"/i \    <!--' $CATALINA_HOME/conf/server.xml && \
    sed -i '/Connector port="8009"/a \    -->' $CATALINA_HOME/conf/server.xml && \
    sed -i '/equivalent/a \        <!--' $CATALINA_HOME/conf/server.xml && \
    sed -i '/%b/a \        -->' $CATALINA_HOME/conf/server.xml && \
    sed -i '/executor=/a \               maxPostSize="209715200"' $CATALINA_HOME/conf/server.xml && \
    sed -ri '/minSpareThreads/s#(.*\"4\")(.*)#\1 maxSpareThreads=\"10\"\2#' $CATALINA_HOME/conf/server.xml && \
    sed -ri '/8080\" protocol/s/(.*protocol=)(.*)/\1\"org.apache.coyote.http11.Http11AprProtocol\"/' $CATALINA_HOME/conf/server.xml
WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD ["catalina.sh", "run"]
