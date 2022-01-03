#!/bin/bash

#this is the script used to export the table from hive database in case the metastore upgrade is failed because of some version issue
#This includes:
#1. database create export and import
#2. table
#3. partition


#open the debug in case any errro
set -x


#first is to show databases and create the datbase:
hive -e "show databases" > database 2>> warn.log


#for loop to loop all the databases
for d in `cat database`; do


#for each of the database, create the table
if [ "$d"x != "default"x ]; then
echo "create database $d;" >> createtables.sql
fi

echo "use $d;" >> createtables.sql

hive -e "use $d;show tables" > tables.txt 2>>show_table.log


#for each table, loop and create the partititons
for f in `cat tables.txt`; do

hive -e "use $d;show create table $f" >> createtables.sql 2>>show_create_table_warn.log
echo ";">>createtables.sql

hive -e "use $d;show partitions $f" > partitionlist.txt 2>>show_partition_warn.log

#replace the "/" with ","
sed -i 's/\//,/g' partitionlist.txt


#loop the partition and create one by one
for p in `cat partitionlist.txt`; do

echo "use $d;alter table $f add if not exists partition ($p)">>createtables.sql
echo ";" >>createtables.sql

done
done
done


#clear the tmp files

rm tables.txt
rm warn.log
rm partitionlist.txt
