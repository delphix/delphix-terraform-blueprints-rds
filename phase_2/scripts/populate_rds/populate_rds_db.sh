#!/bin/bash
echo ORACLE_HOME is ${ORACLE_HOME}
export ORACLE_SID="${2}"
echo ORACLE_SID is ${ORACLE_SID}
echo untaring employees_1m.tgz
tar xvf /home/oracle/populate_rds/employees_1m.tgz -C /home/oracle/populate_rds
RDSHOST="$(dig +short $1)"
echo RDSHOST is ${RDSHOST}
RDSSID="ORCL"
echo RDSSID is ${RDSSID}
CONNECT_2="delphixdb/${3}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${RDSHOST}) (PORT=1521))(CONNECT_DATA=(SID=${RDSSID})))"
echo "Connecting to ${1} via ${CONNECT_2}"
echo "Creating link and transferring file"
sqlplus / as sysdba <<EOF
CREATE DIRECTORY dumpdir_1 AS '/home/oracle/populate_rds';
drop database link to_rds;
create database link to_rds connect to delphixdb identified by ${3} using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${RDSHOST})(PORT=1521))(CONNECT_DATA=(SID=$RDSSID)))';
BEGIN
DBMS_FILE_TRANSFER.PUT_FILE(
source_directory_object       => 'dumpdir_1',
source_file_name              => 'employees_1m.dmp',
destination_directory_object  => 'DATA_PUMP_DIR',
destination_file_name         => 'employees_1m.dmp',
destination_database          => 'to_rds'
);
END;
/
quit
EOF

echo "Running impdp against ${1}"
impdp delphixdb/${3}@${RDSHOST}:1521/${RDSSID} FROMUSER=delphixdb TOUSER=delphixdb TABLES=EMPLOYEES FILE=employees_1m.dmp LOG=impdp.log

echo "Updating perms on ${1}"

sqlplus "${CONNECT_2}" <<EOM

exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours',24);

exec rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD');

exec rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD','PRIMARY KEY');

quit

EOM