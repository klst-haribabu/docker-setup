FROM ubuntu:14.04

MAINTAINER Haribabu <hpasypathy@klstinc.com>

ENV ENVIRONMENT=docker

#Mongo PHP driver version

ENV MONGO_VERSION 3.4
ENV MONGO_PGP 3.4
ENV MONGO_PHP_VERSION 1.5.5

#Install php and dependenceis
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -yq install \
        curl \
        git \
        make \
        apache2 \
        libapache2-mod-php5 \
        php5 \
        php5-dev \
        php5-gd \
        php5-curl \
        php5-mcrypt \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
  && echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/$MONGO_VERSION multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
  && apt-get update \
  && apt-get install -y mongodb-org \

RUN pecl install mongo-$MONGO_PHP_VERSION && \
    mkdir -p /etc/php5/mods-available && \
    echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini && \
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/mongo.ini && \
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/apache2/conf.d/mongo.ini && \
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/mcrypt.ini && \
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/mcrypt.ini

RUN a2enmod headers php5 rewrite ssl vhost_alias
RUN rm -f /etc/apache2/sites-enabled/000-default.conf

VOLUME ["/var/log/apache2"]

EXPOSE 80 80

#ADD sites-enabled/vhost.conf /etc/apache2/sites-enabled/
#CMD ["/run.sh"]

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/bin/bash"]
