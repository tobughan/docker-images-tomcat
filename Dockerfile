FROM registry.cn-zhangjiakou.aliyuncs.com/jdyh/jdk:8u211

ENV CATALINA_HOME="/opt/tomcat"
ENV TOMCAT_MAJOR=8 \
    TOMCAT_VERSION=8.5.57
ENV PATH="$CATALINA_HOME/bin:$PATH" \
    TOMCAT_NATIVE_LIBDIR="$CATALINA_HOME/lib" \
    TOMCAT_TGZ_URLS="http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

RUN yum install -y wget gcc make apr-devel openssl-devel && \
    wget -O /usr/src/apache-tomcat-$TOMCAT_VERSION.tar.gz ${TOMCAT_TGZ_URLS} && \
    tar -xvf /usr/src/apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt && \
    rm -f /usr/src/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    mv /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME && \
    tar -xvf $CATALINA_HOME/bin/tomcat-native.tar.gz -C /usr/src && \
    rm -f $CATALINA_HOME/bin/tomcat-native.tar.gz && \
    TOMCAT_NATIVE_HOME=$(ls -d /usr/src/tomcat-native*) && \
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
    sed -i '/executor=/a \               maxPostSize="20971520"' $CATALINA_HOME/conf/server.xml && \
    sed -ri '/minSpareThreads/s#(.*\"4\")(.*)#\1 maxSpareThreads=\"10\"\2#' $CATALINA_HOME/conf/server.xml
WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD ["catalina.sh", "run"]
