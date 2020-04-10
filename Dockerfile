#as of April 2020, this is the latest version of Ubuntu stable
FROM ubuntu:18.04


# the usual apt-get updates. Notice that I am using Amazon's corretto JDK
RUN apt-get update -y && apt-get install wget gnupg software-properties-common python -y \
    && wget https://apt.corretto.aws/corretto.key -O -| apt-key add - \
    && apt-get update \
    && add-apt-repository 'deb https://apt.corretto.aws stable main' \
    && apt-get install -y java-11-amazon-corretto-jdk


#minio stuff. Note that minio will serve data from /data directory
RUN mkdir /minio && mkdir /data
RUN wget https://dl.min.io/server/minio/release/linux-amd64/minio -P /minio/ && chmod +x /minio/minio
ADD runMinio.sh /
ADD launch.sh /
EXPOSE 9000
RUN chmod +x /runMinio.sh

#presto stuff

RUN wget https://repo1.maven.org/maven2/io/prestosql/presto-server/332/presto-server-332.tar.gz -P /tmp/ \
    && tar -zxvf /tmp/presto-server-332.tar.gz && mv /presto-server-332 /presto-server

EXPOSE 8080

#presto configuration
ADD config.properties /presto-server/etc/config.properties
ADD jvm.config /presto-server/etc/jvm.config
ADD node.properties /presto-server/etc/node.properties
ADD rabbithole.properties /presto-server/etc/catalog/rabbithole.properties


RUN mkdir -p /data/catalog/ && mkdir -p /data/csvdata
ADD data.csv /data/csvdata/

RUN chmod +x /launch.sh

CMD ["/launch.sh"]
