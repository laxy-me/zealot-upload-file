#!/bin/bash
while [ $# -gt 0 ]; do
  case "$1" in
    --host*|-H*)
      if [[ "$1" != *=* ]]; then shift; fi
      HOST="${1#*=}"
      ;;
    --token*|-T*)
      if [[ "$1" != *=* ]]; then shift; fi
      TOKEN="${1#*=}"
      ;;
    --channel_key*|-C*)
      if [[ "$1" != *=* ]]; then shift; fi
      CHANNEL_KEY="${1#*=}"
      ;;
    --changelog*|-L*)
      if [[ "$1" != *=* ]]; then shift; fi
      CHANGE_LOG="${1#*=}"
      ;;
    --file*|-F*)
      if [[ "$1" != *=* ]]; then shift; fi
      FILE="${1#*=}"
      ;;
    --help|-h)
      echo "-------------------------------------------------------------------"
      echo "Bash script to upload a file to a zealot using a file request"
      echo "-------------------------------------------------------------------"
      echo
      echo "Syntax: bash upload.sh --host [HOST] --token [TOKEN] --file [FILE_TO_UPLOAD] [--changelog [CHANGELOG]] [--channel_key [CHANNEL_KEY]]"
      echo
      echo "Options:"
      echo "-H,  --host           Host name of the zealot, including the protocol (HTTP/HTTPS) and the port, without trailing slash"
      echo "-T, --token           Upload token"
      echo "-C, --channel_key     Channel key (optional)"
      echo "-L, --changelog       Changelog (optional)"
      echo "-F, --file            The file to upload"
      echo
      echo "For more details, see https://zealot.ews.im/zh-Hans/docs/developer-guide/api/apps"
      echo
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$HOST" ]
then
	echo "Invalid host"
	exit 1
fi

if [ -z "$TOKEN" ]
then
	echo "Invalid TOKEN"
	exit 1
fi

if [ -z "$FILE" ]
then
	echo "Invalid file"
	exit 1
fi

curl_command="curl -m 300 -s -L -X POST "$HOST/api/apps/upload" -F token=$TOKEN -F file=@$FILE"

if [ -n "$CHANNEL_KEY" ]
then
  curl_command="$curl_command -F channel_key=$CHANNEL_KEY"
fi


if [ -n "$CHANGE_LOG" ]
then
  log=`cat $CHANGE_LOG`
  if [ -n "$log" ]
  then
    curl_command="$curl_command -F changelog=\"$log\""
  fi
fi

echo "Uploading the file..."

response=$(eval "$curl_command")
echo "$response"
