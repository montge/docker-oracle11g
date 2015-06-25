#!/bin/bash

# Start the listener
lsnrctl start

# Start the database
echo "startup"|sqlplus '/ as sysdba'