FROM phusion/baseimage:0.9.16
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

MAINTAINER Crobays <crobays@userex.nl>
ENV DOCKER_NAME nginx
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:nginx/stable && \
	apt-get update

RUN apt-get install -y \
	nginx

# Exposed ENV
ENV TIMEZONE Etc/UTC
ENV ENVIRONMENT production
ENV SERVE_PATH /project/public
ENV ALLOWED all
ENV NGINX_CONF nginx-virtual.conf

VOLUME  ["/project"]
WORKDIR /project

# HTTP ports
EXPOSE 80 443

RUN echo '/sbin/my_init' > /root/.bash_history

RUN mkdir /etc/service/nginx && echo "#!/bin/bash\nnginx" > /etc/service/nginx/run

RUN echo "#!/bin/bash\necho \"\$TIMEZONE\" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata" > /etc/my_init.d/01-timezone.sh
ADD /scripts/nginx-config.sh /etc/my_init.d/02-nginx-config.sh

RUN chmod +x /etc/my_init.d/* && chmod +x /etc/service/*/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /conf /conf


