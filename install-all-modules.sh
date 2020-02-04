#!/bin/bash

echo
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ All Modules installer ver 1.0   ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo

checkDependencies(){

	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' jq|grep "install ok installed")
	#echo Checking for somelib: $PKG_OK
	if [ "" == "$PKG_OK" ]; then
		echo "Package jq is missing. Please run 'sudo apt install jq' and run again"
		exit
	fi
}

#checkDependencies

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
pwd=$(pwd)
modulesFolder=$pwd/src/modules

if [ ! -d "$modulesFolder" ];then
	echo
	echo "Could not find $modulesFolder" 
	echo "make sure you run this script from your project root path"
	echo "and you do have modules installed and then try again"
	echo
    exit
#else
	#cd $modulesFolder
fi	

if [ ! -d "$modulesFolder/scripts" ];then
	echo
	echo "Could not find $modulesFolder/scripts" 
	echo "Make sure you clone this module (cd src/modules && git clone https://github.com/carmel-6000/scripts scripts) and try again"
	echo
        exit
fi

#Iterate through all models in model-config
#Does it exit? great, update it.
#If doesn't exist, clone it
readarray -t modulesList < <(cat ../../server/model-config.json | jq -r '._meta.modules|.[]|.name')
readarray -t modulesPath < <(cat ../../server/model-config.json | jq -r '._meta.modules|.[]|.path')
readarray -t modulesGit < <(cat ../../server/model-config.json | jq -r '._meta.modules|.[]|.github')
#printf '%s\n' "${modulesList[@]}"
#printf '%s\n' "${modulesPath[@]}"
#currDir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
#echo "currDir--->$currDir"
#echo "currDir 2? $(dirname "$0")"
#currDir="$currDir/../../server"
#echo "BASH_SOURCE? $BASH_SOURCE"
#echo "BASH 2? $(dirname ${BASH_SOURCE[0]})"
#currDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
currDir=$(dirname ${BASH_SOURCE[0]})

echo "currDir? $currDir"

for module in "${!modulesList[@]}"
do
   #echo "Module:${modulesList[$module]}"    
   modPath="server/${modulesPath[$module]}"
   #echo "modPath:$modPath"
   if [ ! -d "$modPath" ]; then

   	echo "Installing module $newModule..."
	#mFolder=$(basename ${modulesPath[$module]})
	#echo "Cloning $newModule into $mFolder.."
	echo "git clone ${modulesGit[$module]} $modPath"
	echo "CURRENT PWD? $(pwd)"
	git clone ${modulesGit[$module]} $modPath
			
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "git clone error. Try to clone this module manually"
	else
		echo -e "${GREEN}OK${NOCOLOR}"
		echo "Module has been successfully installed, on model-config.json switch enabled to 'true' to enable on your project"
	fi

	else
		echo "Module (${modulesList[$module]}) is already installed on folder $modPath"
	fi
done
#moduleEntry=$(cat ../../server/model-config.json |jq '._meta.modules')
#echo "moduleEntry: $moduleEntry"