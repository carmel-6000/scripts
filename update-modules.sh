#!/bin/bash

echo
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Modules auto update ver 1.0 ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo

pwd=$(pwd)

modulesFolder=$pwd/src/modules

checkDependencies(){

	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' jq|grep "install ok installed")
	#echo Checking for somelib: $PKG_OK
	if [ "" == "$PKG_OK" ]; then
		echo "Package jq is missing. Please run 'sudo apt install jq' and run again"
		exit
	fi
}


updateModule(){

	st=$1
	module="${st/\//}"
	echo	
	echo -n "Updating module '$module'..."
        cd $module
	#pwd
	hasDiffs=$(git status -s | cut -c4-)
	if [ ! -z "$hasDiffs" ];then
		echo "There are diffs, please checkout or commit repository and then try again"
		sleep 1
	else
		#git pull origin master
		ls >/dev/null
	        retVal=$?
		if [ $retVal -ne 0 ]; then
			echo "git error. Try to update this module manually."
		        sleep 1
		else
			echo "OK"
		fi	
	fi	
	cd ..	
}

if [ ! -d "$modulesFolder" ];then
	echo
	echo "Could not find $modulesFolder" 
	echo "make sure you run this script from your project root path"
	echo "and you do have modules installed and then try again"
	echo
        exit
else
	cd $modulesFolder
fi	

checkDependencies

echo "Updating existing modules..."
for moduleDir in */; do
	#echo $moduleDir
	updateModule $moduleDir
done

echo Done
