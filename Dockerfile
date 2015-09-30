#
# Moscrack server Dockerfile
#
# https://github.com/
#

# Pull base image.
FROM debian:latest

MAINTAINER hihouhou < hihouhou@hihouhou.com >

ENV MOSCRACK_VERSION moscrack-2.08b

# Update & install packages for moscrack
RUN apt-get update && \
    apt-get install -y wget supervisor perl-modules libhttp-server-simple-perl libjson-perl libconfig-std-perl libmodule-implementation-perl libdatetime-locale-perl libparams-validate-perl libdatetime-perl libgetopt-lucid-perl libstruct-compare-perl libwww-perl libnet-ssh2-perl libterm-readkey-perl libdatetime-format-duration-perl 

#Get moscrack repository and install it
#RUN svn co https://moscrack.svn.sourceforge.net/svnroot/moscrack moscrack  && \
RUN wget http://sourceforge.net/projects/moscrack/files/${MOSCRACK_VERSION}.tar.gz && \
    tar xvf ${MOSCRACK_VERSION}.tar.gz && \
    ls / && \
    cd $MOSCRACK_VERSION && \
    ./install_modules && \ 
    ./install_modules --install

#Configure 
ADD moscrack.conf /etc/moscrack/moscrack.conf
RUN mkdir /opt/moscrack

#Configure nodes
ADD nodes.dat /opt/moscrack/

#ADD plugins
RUN mv /${MOSCRACK_VERSION}/plugins /etc/moscrack/

#ADD links
RUN ln -s /${MOSCRACK_VERSION}/moscrack /usr/local/bin/moscrack && \
    ln -s /${MOSCRACK_VERSION}/mosctop /usr/local/bin/mosctop && \
    ln -s /${MOSCRACK_VERSION}/moscd /usr/local/bin/moscd && \
    ln -s /${MOSCRACK_VERSION}/moscapid /usr/local/bin/moscapid &&\
    ln -s $(find /root/ -type d -name *Acme*) /usr/lib/perl5/Acme

#Configure supervisord
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:moscapid]" >> /etc/supervisord.conf && \
    echo "command=/usr/local/bin/moscapid" >> /etc/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
