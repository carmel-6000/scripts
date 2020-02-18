#!/bin/bash
DB=$1
HOST=localhost
DUMPS_DIR=../../dumps

checkDependencies(){
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' jq|grep "install ok installed")
	#echo Checking for somelib: $PKG_OK
	if [ "" == "$PKG_OK" ]; then
		echo "Package jq is missing. Please run 'sudo apt install jq' and run again"
		exit
	fi
}

USER=$(cat ../../server/datasources.json | jq -r '.msql.user')
PW=$(cat ../../server/datasources.json | jq -r '.msql.password')

if [ -z "$DB" ]; then
	echo "Please specify database name."
	exit
fi

if [ -f $DUMPS_DIR/db_changes.wc ];then
	#make sure the file db_changes.wc contain a number
	read -r start<$DUMPS_DIR/db_changes.wc
	re='^[0-9]+([.][0-9]+)?$'
	if ! [[ $start =~ $re ]]; then
   		echo "error: value in file db_changes.wc is not a number"
 		exit
	fi			
	if [ $start -eq 0 ]; then
		#The file contained the number 0 -> Overwrite the exiting DB with a clean dump
		echo -n "Are you sure you would like to override your existing database? [Y/n] "
     		read confirm
     		if [ $confirm == "Y" ] || [ $confirm == "y" ]; then
          		echo -n "Overriding database"
	  		echo 
          		mysql -h$HOST -u$USER -p$PW $DB < $DUMPS_DIR/$DB.dump.sql
     		else
          		echo Ok..so chao!====
          		exit
     		fi	
	else 
		echo -n "Run latest changes to the DB? [Y/n] "
     		read confirm
     		if [ $confirm != "Y" ] && [ $confirm != "y" ]; then
          		echo Ok..so chao!
          		exit
     		fi
	fi	
	#In any case, need run the latest changes file from the point where it was last run
	echo "run $DB.changes.sql starting from row $start"
	
	#Trim new lines and white spaces from the end of $DB.changes.sql
	sed '/^ *$/d' $DUMPS_DIR/$DB.changes.sql > /tmp/$DB.changes.sql.new
	mv /tmp/$DB.changes.sql.new $DUMPS_DIR/$DB.changes.sql	

	#run the SQL 	
	SQL=$(tail -n +$start $DUMPS_DIR/$DB.changes.sql)	
	mysql -h$HOST -u$USER -p$PW $DB -e "$SQL"	
	
	#update the line number to start from last time
	num_lines=$(wc -l < $DUMPS_DIR/$DB.changes.sql)
	new_start=$((num_lines+1))
	echo $new_start> $DUMPS_DIR/db_changes.wc
	echo "next start will be from row $new_start"
else
	echo "No such file db_changes.wc in $DUMPS_DIR"
	exit
fi

echo "Done"
