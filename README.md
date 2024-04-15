# Bash script to upload a file to a zealot
## Dependencies

This script requires to have `bash` and `curl` installed.

## Download

Clone the repository:

`git clone https://github.com/laxy-me/zealot-upload-file.git`

Or download the script directly:

`wget https://raw.githubusercontent.com/laxy-me/zealot-upload-file/master/upload.sh`

Or:

`curl -O https://raw.githubusercontent.com/laxy-me/zealot-upload-file/master/upload.sh`

## Usage

`bash upload.sh --host [HOST] --token [TOKEN] --file [FILE_TO_UPLOAD]`
`bash upload.sh --host [HOST] --token [TOKEN] --file [FILE_TO_UPLOAD] [--changelog [CHANGELOG]] [--channel_key [CHANNEL_KEY]]`

### Options

|Parameter|Required|Description|
|---|---|---|
|-H,  --host|Required|Host name of the zealot service, including the protocol (HTTP/HTTPS) and the port, without trailing slash<br />Examples: `http://192.168.0.123:8085`, `https://www.example.com:8085`|
|-S, --token|Required|Apt token of zealot user.<br />see: https://www.example.com:8085/users/edit
|-F, --file|Required|The file to upload|