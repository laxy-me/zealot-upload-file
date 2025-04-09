#!/bin/bash

# Function to check if a URL is valid
check_url() {
    local url=$1
    if [[ ! $url =~ ^https?:// ]]; then
        echo "❌ Error: Host must start with http:// or https://"
        exit 1
    fi
}

# Function to check if file exists and is readable
check_file() {
    local file=$1
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        echo "❌ Error: File '$file' does not exist or is not readable"
        exit 1
    fi

    # Check file size (max 500MB)
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    if [ "${size:-0}" -gt 524288000 ]; then
        echo "❌ Error: File size exceeds 500MB limit"
        exit 1
    fi
    echo "✅ File '$file' exists and is readable, size: $size bytes"
}

# Function to perform the upload
do_upload() {
    local -n args=$1 # reference to the curl_args array
    local max_retries=3
    local retry_count=0
    local wait_time=5

    while [ $retry_count -lt $max_retries ]; do
        echo "🔄 Attempt $((retry_count + 1)) of $max_retries..."

        local response
        response=$(curl "${args[@]}" -w '\n%{http_code}')
        local curl_exit_code=$?
        local status_code
        status_code=$(echo "$response" | tail -n1)
        local body
        body=$(echo "$response" | sed '$d')

        if [[ "$status_code" == "200" || "$status_code" == "201" ]]; then
            echo "✅ Upload successful!"
            echo "$body"
            return 0
        else
            echo "❌ Upload failed with status code: $status_code"
            echo "Response: $body"
            echo "curl exit code: $curl_exit_code"
            if [ $retry_count -lt $((max_retries - 1)) ]; then
                echo "⏳ Retrying in $wait_time seconds..."
                sleep $wait_time
                wait_time=$((wait_time * 2))
            fi
        fi
        retry_count=$((retry_count + 1))
    done

    echo "❌ Failed to upload after $max_retries attempts"
    return 1
}

# Parse arguments
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
            echo "-----------------------------------------------"
            echo "Upload a file to Zealot via API"
            echo "-----------------------------------------------"
            echo
            echo "Usage:"
            echo "  bash upload.sh --host [HOST] --token [TOKEN] --file [FILE] [--changelog [LOG]] [--channel_key [KEY]]"
            echo
            echo "Options:"
            echo "  -H, --host         Zealot host URL (e.g., https://zealot.laxy.pub)"
            echo "  -T, --token        Upload token"
            echo "  -F, --file         File to upload"
            echo "  -C, --channel_key  Channel key (optional)"
            echo "  -L, --changelog    Changelog text file (optional)"
            echo
            exit 0
            ;;
        *)
            echo "❌ Error: Invalid argument '$1'"
            exit 1
            ;;
    esac
    shift
done

# Normalize HOST (remove trailing slash)
HOST="${HOST%/}"

# Validate required inputs
if [ -z "$HOST" ]; then echo "❌ Error: Host is required"; exit 1; fi
if [ -z "$TOKEN" ]; then echo "❌ Error: Token is required"; exit 1; fi
if [ -z "$FILE" ]; then echo "❌ Error: File is required"; exit 1; fi

# Check URL and file
check_url "$HOST"
check_file "$FILE"

# Build curl arguments
curl_args=(
    -m 300
    -v
    --http1.1
    -L
    -X POST "${HOST}/api/apps/upload"
    -F "token=${TOKEN}"
    -F "file=@${FILE}"
    --progress-bar
)

if [ -n "$CHANNEL_KEY" ]; then
    curl_args+=(-F "channel_key=${CHANNEL_KEY}")
fi

if [ -n "$CHANGE_LOG" ]; then
    if [ -f "$CHANGE_LOG" ] && [ -r "$CHANGE_LOG" ]; then
        echo "✅ Changelog file '$CHANGE_LOG' exists and is readable."
        changelog_content=$(cat "$CHANGE_LOG")
        curl_args+=(-F "changelog=$changelog_content")
    else
        echo "⚠️  Warning: Changelog file not found or unreadable: $CHANGE_LOG"
    fi
fi

echo "🚀 Starting upload to ${HOST}/api/apps/upload..."
do_upload curl_args