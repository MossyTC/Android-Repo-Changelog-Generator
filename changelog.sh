#!/bin/bash
#TODO Allow user specified excluded folders
OLDPWD=`pwd`

function trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}


function showCommitsForRepo() {
	pushd $1 > /dev/null

	repoName=${1/#\.\//}
	repoName=${repoName//\//_}
	
	logs=`git log --since="$sinceTime"  --until="$untilTime" --oneline`

	if [[ $? -ne 0 ]]
	then
		echostderr
		echostderr "Error processing repository \"$repoName\" \($gitFile\)"
		echostderr
		exit
	fi

	if [[ ! ${#debug} -eq 0 ]]
	then
		echostderr "Processing $1:"
		echostderr "`pwd`"
		echostderr "git log --since=\"$sinceTime\"  --until=\"$untilTime\" --oneline"
		echostderr "$logs"
		echostderr ""
	fi

	if [[ ${#logs} -ne 0 ]]
	then 
		echo
		echo "[$repoName]"
		IFS='\n' readarray -t logArray <<< "$logs"

		index=0
		while [[ 0 -ne ${#logArray[$index]} ]]
		do 
			echo ${logArray[$index]}
			let index=index+1
		done
	fi

	popd > /dev/null
}

function echostderr {
	>&2 echo "$@"
}

function usage {
	echostderr
	echostderr
	echostderr "Android Repo Changelog Generator"
	echostderr "Show commit comments from repos within the given timeframe."
	echostderr
	echostderr "Usage:"
	echostderr "    $0 timestamp-file [repolist-file]"
	echostderr 
	echostderr "Must be run from the top of tree (try running 'croot' first)"
	echostderr

	echostderr "timestamp-file"
	echostderr "    File containing a list of timestamps corresponding to repo syncs associated with each release. The last two timestamps will be used as the start and end times for the commit comments."
	echostderr
	echostderr "repolist-file"
	echostderr "   The list of repositories from which commit comments are to be retrieved. If not speicifed then commit comments from all repositories will be retrieved."

	echostderr
	echostderr
	echostderr "Example:"
	echostderr
	echostderr "    $0 repostamp.txt repolist.txt"
	echostderr
	echostderr

}

if [[ "$#" -lt 1 || "$#" -gt 2 ]]
then
	usage 
	exit
fi

if [ ! -d .repo ]
then
	echostderr "First change directory to the top of the tree (try running 'croot') before running '$0'"
	exit
fi

ROOTPWD=`pwd`

if [[ ! -f $1 ]]
then
	echostderr "Timestamp file '$1' does not exist."
	exit
fi

if [[ ${#2} -gt 0 && ! -f $2 ]]
then
	echostderr "Repository list file '$2' does not exist."
	exit
fi

stampFile="$1"
repoFile="$2"

while read -r timestamp
do
    if [[ ${#sinceTime} -eq 0 ]]
    then
        sinceTime="$timestamp"
    else
        untilTime="$timestamp"
    fi

done< <(tail -n 2 $stampFile)

echostderr "Commit logs since: $sinceTime"
echostderr "Commit logs until: $untilTime"

if [[ ${#sinceTime} -eq 0 || ${#untilTime} -eq 0  ]]
then
	echostderr "Error processing time stamps"
	exit
fi

if [[ ! ${#repoFile} -eq 0 ]]
then
	# ignore1/ignore2_folder1_folder2_..._folderN, e.g. "CyanogenMod/android_device_bn_hummingbird" corresponding to "device/bn/hummingbird"
	repoPattern="[^\/]+\/[^_]+_(.*)"
	hashPattern="(.*)#"

	# parse line get folder
	while read repoLine
	do
		originalLine=$repoLine
		[[ $repoLine =~ $hashPattern ]]

		# Remove comments
		if [[ ${#BASH_REMATCH[0]} -gt 0 ]]
		then
			repoLine="${BASH_REMATCH[1]}"
		fi

		repoLine=`trim $repoLine`

		if [[ ${#repoLine} -eq 0 ]]
		then
			continue
		fi

		[[ $repoLine =~ $repoPattern ]]

		if [[ ${#BASH_REMATCH[0]} -eq 0 ]]
		then
			echostderr "Error processing the following line from $repoFile - "
			echostderr "$originalLine"
			exit
		fi

		repoFolder="${BASH_REMATCH[1]//_/\/}"
		if [[ ! -d $repoFolder ]]
		then
			echostderr "Folder '$repoFolder' specified by the following line in '$repoFile' does not exist, continuing - "
			echostderr "$originalLine"
			echostderr ""
			continue
		fi

		showCommitsForRepo "$repoFolder"
		
	done < $repoFile

else
	echostderr "Finding repos..."
	IFS='\n' readarray -t gitFiles <<< `find . -path ./.repo -prune -o -name .git -print`
	#gitFiles=`find . -path ./.repo -prune -o -name .git -print`
	IFS=' ' gitFilesNewLines=( $gitFiles )


	echostderr "Examining logs..."

	for gitFile in $gitFiles
	do 
		repoFolder=`dirname $gitFile`
		showCommitsForRepo "$repoFolder"
	done
fi
