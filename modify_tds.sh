#!/bin/bash
#Script for modifying task definion files

env=$1
source_dir="/tmp/taskdefinitions/us-west-2/"
target_dir="/tmp/test/taskdefinitions/us-west-2/"

if [ -z ${env} ];then

	echo "No environment given. Please specify the environment(TMS/NG)"
        exit 1
fi

if [ ${env} == "NG" ] || [ ${env} == "invitemanager" ];then

	file_lists=$(find $source_dir -type f | grep -ve "tms" -e "datacollector")

fi

if [ ${env} == "TMS" ] || [ ${env} == "tms" ];then

	file_lists=$(find $source_dir | grep tms)

fi

	for current_file in $file_lists; do
        current_file_mod=`basename $current_file`
	echo "$target_dir$current_file_mod"
	    jq -r '.containerDefinitions[].environment |= .+ [{ "name": "ENVIRONMENT", "value": "development" }]' "$current_file" > "$target_dir$current_file_mod"

	done


