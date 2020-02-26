echo
echo  "Creating module's samples json (modules/samples/samples_array_data.json)..."
pwd=$(pwd)
modulesFolder=$pwd/src/modules

node $modulesFolder/samples/scripts/create-samples-json.js >/dev/null 
retVal=$?
if [ "$retVal" -ne 0 ]; then
	echo "Error creating samples json (samples/scripts/create-samples-json.js, please check your code..."
else
	echo  "${GREEN}OK${NOCOLOR}"
fi
echo