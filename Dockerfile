FROM ubuntu:16.04

#ENV SERVERNAME "172.16.20.211"

RUN apt-get update && apt-get install -y wget git curl zip vim joe openssh-server
RUN apt-get update && apt-get install -y apache2 subversion subversion-tools libapache2-svn libsvn-perl 

RUN adduser --ingroup root --home /var/www/svn scm-admin
RUN echo "scm-admin\nscm-admin\n" | passwd -q scm-admin
RUN echo "scm-admin    ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN usermod -U www-data && chsh -s /bin/bash www-data

#RUN echo "ServerName ${ENV:SERVER_NAME}" >> /etc/apache2/conf-enabled/servername.conf

COPY enable-var-www-html-htaccess.conf /etc/apache2/conf-enabled/
COPY dav_svn.passwd /etc/apache2/dav_svn.passwd
COPY dav_svn.authz /etc/apache2/dav_svn.authz
COPY dav_svn.conf /etc/apache2/mods-available/dav_svn.conf
COPY run_apache.sh /var/www/

RUN a2enmod rewrite cgi headers ldap authnz_ldap ssl
RUN a2ensite default-ssl

WORKDIR /var/www/svn
RUN svnadmin create test_repo_1 && \
    svnadmin create test_repo_2

#volume "/var/log"

RUN mkdir -p /var/www/svn

#VOLUME ["/var/www/html", "/var/log/apache2", "/var/svn" ]
VOLUME ["/var/www/html", "/var/log/apache2", "/var/www/svn" ]

# for main web interface:
EXPOSE 80 443 22

#USER www-data

CMD ["/var/www/run_apache.sh"]
