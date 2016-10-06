FROM java:openjdk-8
MAINTAINER u6k.apps@gmail.com

### Setup Typesafe Activator ###

RUN mkdir -p /usr/local/src/
WORKDIR /usr/local/src/

RUN curl -OL https://downloads.typesafe.com/typesafe-activator/1.3.10/typesafe-activator-1.3.10-minimal.zip && \
    unzip typesafe-activator-1.3.10-minimal.zip && \
    mkdir -p /opt/ && \
    mv activator-1.3.10-minimal/ /opt/activator && \
    chmod a+x /opt/activator/bin/activator && \
    ln -s /opt/activator/bin/activator /usr/local/bin/activator

RUN activator new my-app play-scala && \
    cd my-app/ && \
    activator compile dist && \
    cd ../ && \
    rm -rf my-app/

### Update apt-get ###

RUN apt-get update

### Setup supervisor ###

RUN apt-get install -y supervisor
RUN (echo '[supervisord]' && \
     echo 'nodaemon=true' && \
     echo '[program:play-app]' && \
     echo 'command=activator run' && \
     echo 'stdout_logfile=/dev/fd/1' && \
     echo 'stdout_logfile_maxbytes=0') > /etc/supervisord.conf

### Setup other tool ###

RUN apt-get install -y vim

### Create play-scala project ###

WORKDIR /var/lib/
RUN activator new my-app play-scala
WORKDIR /var/lib/my-app/

EXPOSE 9000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
