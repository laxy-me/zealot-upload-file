#!/bin/bash

# Function to check if a URL is valid
check_url() {
    local url=$1
    if [[ ! $url =~ ^https?:// ]]; then
        echo "Error: Host must start with http:// or https://"
        exit 1
    fi
}

# Function to check if file exists and is readable
check_file() {
    local file=$1
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        echo "Error: File '$file' does not exist or is not readable"
        exit 1
    fi

    # Check file size (max 500MB)
    local size=$(stat -f%z "$file")
    if [ $size -gt 524288000 ]; then
        echo "Error: File size exceeds 500MB limit"
        exit 1
    fi
}

# Function to handle the upload
do_upload() {
    local curl_command="$1"
    local max_retries=3
    local retry_count=0
    local wait_time=5

    while [ $retry_count -lt $max_retries ]; do
        echo "Attempt $((retry_count + 1)) of $max_retries..."
        
        # Execute curl command and capture both response and status code
        local response=$(eval "$curl_command -w '\n%{http_code}'")
        local status_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | sed '$d')

        if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ]; then
            echo "Upload successful!"
            echo "$body"
            return 0
        else
            echo "Upload failed with status code: $status_code"
            echo "Response: $body"
            
            if [ $retry_count -lt $((max_retries-1)) ]; then
                echo "Retrying in $wait_time seconds..."
                sleep $wait_time
                wait_time=$((wait_time * 2))
            fi
        fi
        
        retry_count=$((retry_count + 1))
    done

    echo "Failed to upload after $max_retries attempts"
    return 1
}

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

# Validate required parameters
if [ -z "$HOST" ]; then
    echo "Error: Host is required"
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "Error: Token is required"
    exit 1
fi

if [ -z "$FILE" ]; then
    echo "Error: File is required"
    exit 1
fi

# Check URL format
check_url "$HOST"

# Check if file exists and is readable
check_file "$FILE"

# Prepare curl command with proper escaping
curl_command="curl -m 300 -s -L -X POST \"${HOST}/api/apps/upload\" \
    -F \"token=${TOKEN}\" \
    -F \"file=@${FILE}\" \
    --progress-bar"

if [ -n "$CHANNEL_KEY" ]; then
    curl_command="$curl_command -F \"channel_key=${CHANNEL_KEY}\""
fi

if [ -n "$CHANGE_LOG" ]; then
    if [ -f "$CHANGE_LOG" ] && [ -r "$CHANGE_LOG" ]; then
        log=$(cat "$CHANGE_LOG")
        if [ -n "$log" ]; then
            curl_command="$curl_command -F \"changelog=${log}\""
        fi
    else
        echo "Warning: Changelog file not found or not readable: $CHANGE_LOG"
    fi
fi

echo "Starting upload process..."
do_upload "$curl_command"
