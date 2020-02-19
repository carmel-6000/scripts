#!/bin/bash
NC='\033[0m'
BOLD='\e[1m'
ITALIC='\e[3m'
YL='\e[93m'

pwd=$(pwd)
modulesFolder=$pwd/src/modules

if [ ! -d "$modulesFolder" ]; then
    echo
    echo "Could not find $modulesFolder"
    echo "make sure you run this script from your project root path"
    echo "and you do have modules installed and then try again"
    echo
    exit
else
    cd $modulesFolder
fi

if [ ! -d "$modulesFolder/scripts" ]; then
    echo
    echo "Could not find $modulesFolder/scripts"
    echo "Make sure you clone this module (cd src/modules && git clone https://github.com/carmel-6000/scripts scripts) and try again"
    echo
    exit
fi

writeServerConfig() { # params: $1-moduleName  $2-srcFolder $3-srcEnv $4-destPath /optional-- $5- destEnv
    modulename=$1
    confFolderPath=$2
    env=$3
    if [ $env == "dev" ]; then
        srcFileName=config.json
        if [ ! -z $5 ]; then
            destFileName=config.production.json
        else
            destFileName=$srcFileName
        fi
        confFilePath=$confFolderPath/config/$srcFileName
    else
        srcFileName=config.production.json
        if [ ! -z $5 ]; then
            destFileName=config.json
        else
            destFileName=$srcFileName
        fi
        confFilePath=$confFolderPath/config/$srcFileName
    fi

    destPath=$4$destFileName
    # echo "dest: $destPath"

    if [ ! -d $confFolderPath ] || [ ! -d $confFolderPath/config ]; then
        echo -e "no config for $modulename\\n"
    else
        if [ -f $confFilePath ]; then
            echo "adding $modulename to $destFileName"

            moduleEntry=$(cat ../../server/$destFileName | jq '.modules.'$modulename'')
            #echo "moduleEntry: $moduleEntry"
            if [ "$moduleEntry" != "null" ]; then
                echo "Module ($modulename) is already listed on $destFileName"
            else
                echo "Adding module into $destFileName..."
                confData=$(cat $confFilePath | jq '. ' | tr '\n' ' ')

                # echo $confData
                cat $destPath | jq ".modules += {$modulename:$confData}" >/tmp/$destFileName

                if [ ! -s /tmp/$destFileName ]; then
                    echo "Could not add a new entry to $destFileName"
                    echo "please do it manually or fix script or $destFileName syntax on pumba"
                else
                    cp /tmp/$destFileName $destPath
                    echo -e "${YL}added $modulename config. \\n${NC}"
                fi
            fi

        fi
    fi
    echo
}

writeClientConfig() { # $1-moduleName  $2-srcFolder $3-destPath
    modulename=$1
    confFolderPath=$2
    confFilePath=$confFolderPath/config/clientConfig.json
    destFileName=ModulesConfig.json
    destPath=$3$destFileName
    # echo "dest: $destPath"

    if [ ! -d $confFolderPath ] || [ ! -d $confFolderPath/config ]; then
        echo -e "no config for $modulename\\n"
    else
        if [ -f $confFilePath ]; then
            echo "adding $modulename to $destFileName"

            moduleEntry=$(cat ../../src/consts/$destFileName | jq '.'$modulename'')
            #echo "moduleEntry: $moduleEntry"
            if [ "$moduleEntry" != "null" ]; then
                echo "Module ($modulename) is already listed on $destFileName"
            else
                echo "Adding module into $destFileName..."
                confData=$(cat $confFilePath | jq '. ' | tr '\n' ' ')

                # echo $confData
                cat $destPath | jq ". += {$modulename:$confData}" >/tmp/$destFileName

                if [ ! -s /tmp/$destFileName ]; then
                    echo "Could not add a new entry to $destFileName"
                    echo "please do it manually or fix script or $destFileName syntax on pumba"
                else
                    cp /tmp/$destFileName $destPath
                    echo -e "${YL}added $modulename config to $destFileName. \\n${NC}"
                fi
            fi

        fi
    fi
    echo

}

readarray -t modulesList < <(cat ../../server/model-config.json | jq -r '._meta.modules|.[]|.name')
readarray -t enableList < <(cat ../../server/model-config.json | jq -r '._meta.modules|.[]|.enabled')
# printf '%s\n' "${modulesList[@]}"
# printf '%s\n' "${enableList[@]}"

if [ ! -s $pwd/server/config.production.json ]; then # create production config.
    echo -e "creating production config..\\n"
    data=$(cat $pwd/server/config.json)
    if [ "$(echo $data | jq ".modules")" != "null" ]; then
        echo $data | jq "del(.modules[])" >$pwd/server/config.production.json
    else
        echo $data >$pwd/server/config.production.json
    fi
fi

if [ ! -s $pwd/src/consts/ModulesConfig.json ]; then # create client config
    echo -e "creating client config..\\n"
    echo {} >$pwd/src/consts/ModulesConfig.json
fi

for index in "${!modulesList[@]}"; do
    modulename=${modulesList[index]}
    moduleFolderPath=$modulesFolder/$modulename

    if [ "${enableList[$index]}" == "false" ] || [ "${enableList[$index]}" == "null" ]; then
        echo -e "module $modulename is disabled.\\n"
    else
        writeClientConfig $modulename $moduleFolderPath $pwd/src/consts/

        if [ -s $moduleFolderPath/config/config.json ]; then
            writeServerConfig $modulename $moduleFolderPath "dev" $pwd/server/

            if [ ! -s $moduleFolderPath/config/config.production.json ]; then
                echo -e "{$ITALIC}missing config.prod file, using dev-config ${NC}"
                writeServerConfig $modulename $moduleFolderPath "dev" $pwd/server/ "prod"
            fi
        fi

        if [ -s $moduleFolderPath/config/config.production.json ]; then
            writeServerConfig $modulename $moduleFolderPath "prod" $pwd/server/

            if [ ! -s $moduleFolderPath/config/config.json ]; then
                echo -e "${ITALIC}missing dev-config file, using config.production${NC}"
                writeServerConfig $modulename $moduleFolderPath "prod" $pwd/server/ "dev"
            fi
        fi
    fi

done

echo -e "\e[32mDone adding to config.json, \\nfill in all your data.\\n"
