#!/bin/bash

# abort on error
set -e

#Locations
PGMAJOR="9.5"
DATADIR="/var/lib/postgresql/$PGMAJOR/main"
CONF="/etc/postgresql/$PGMAJOR/main/postgresql.conf"
CONF_NET="/etc/postgresql/$PGMAJOR/main/pg_hba.conf"
POSTGRES="/usr/lib/postgresql/$PGMAJOR/bin/postgres"
INITDB="/usr/lib/postgresql/$PGMAJOR/bin/initdb"
PID_LOC="/var/run/postgresql/$PGMAJOR-main.pid"
#LOCALONLY="-c listen_addresses='127.0.0.1, ::1'"

# Setup networking parameters
echo $DB_SUBNET
echo "host    all             all             $DB_SUBNET               trust"
echo "listen_addresses = '*'" >> $CONF
echo "port = 5432" >> $CONF
#echo "host    all             all             0.0.0.0/0               trust" >> $CONF_NET
echo "host    all             all             $DB_SUBNET               trust" >> $CONF_NET
echo "host    all             all             192.168.0.0/16               md5" >> $CONF_NET
#if [ "$ALLOW_IP_RANGE" ]
#then
#  echo "host    all             all             $ALLOW_IP_RANGE              md5" >> $CONF_NET
#fi

# Needed under debian, wasnt needed under ubuntu, not sure why
mkdir -p /var/run/postgresql/$PGMAJOR-main.pg_stat_tmp
chmod 0777 /var/run/postgresql/$PGMAJOR-main.pg_stat_tmp

# Check if DATADIR is existent
if [ ! -d $DATADIR ]; then
  echo "Creating Postgres data directory at $DATADIR"
  mkdir -p $DATADIR
fi

# Make DATADIR owned by postgres (needs to be done by root so no USER in dockerfile)
chown -R postgres:postgres $DATADIR

# Test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then

  # No content yet - first time pg is being run - so initialise db
  echo "Initializing Postgres Database at $DATADIR"
  su - postgres -c "$INITDB --encoding='utf-8' $DATADIR"
fi

#Start db
su - postgres -c "$POSTGRES -D $DATADIR -c config_file=$CONF &"
until /usr/bin/pg_isready; do
    echo "$(date) - Waiting for postgres database...."
    sleep 1
done
echo "The postgres database is up, setup script will continue."

#Test if user exists and create role if not
RESULT=`su - postgres -c "psql -c '\du' | grep $PGUSER | wc -l"`
if [[ ${RESULT} == '1' ]]
then
  echo "User $PGUSER already exists."
else
  echo "Creating new superuser role for user: $PGUSER with password: $PGPASSWORD"
  sudo -u postgres psql --command "CREATE USER $PGUSER WITH SUPERUSER PASSWORD '$PGPASSWORD'"
fi

#Test for db files and don't run if already exists
#DB_NAME=testdb3
#RESULT=`su - postgres -c "psql -l | grep $DB_NAME | wc -l"`
#if [[ ${RESULT} == '1' ]]
#then
#    echo "Postgres database $DB_NAME already exists."
#else
#    echo "Postgres database $DB_NAME is missing, beginning database setup."
    #sudo -u postgres psql --command "createdb $DB_NAME"
#    sudo -u postgres psql -c "create database $DB_NAME;"
#fi

# Print out DB tables and users
su - postgres -c "psql -l"
su - postgres -c "psql -c '\du'"

# Kill PID and wait for exit (remove any other lock files if still around)
PID=`cat /var/run/postgresql/$PGMAJOR-main.pid`
kill -TERM ${PID}
while [ "$(ls -A /var/run/postgresql/$PGMAJOR-main.pid 2>/dev/null)" ]; do
  sleep 1
done
rm /var/run/postgresql/*.pid || true

#Restart DB
echo "Postgres initialisation process completed .... restarting in foreground"
su - postgres -c "$POSTGRES -D $DATADIR -c config_file=$CONF"
