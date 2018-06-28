FROM debian:stable

RUN apt-get update
RUN apt-get install -y gnupg2 wget ca-certificates rpl pwgen netcat sudo
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5

EXPOSE 5432

ADD start.sh /start.sh
RUN chmod 0755 /start.sh

ENTRYPOINT ["/start.sh"]
