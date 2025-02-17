# Zealot File Upload Script

A bash script for uploading files to Zealot service with support for changelogs and channel keys.

## Features

- Easy file upload to Zealot service
- Support for changelogs
- Support for channel keys
- Automatic retry on failure
- Progress bar display
- File size validation
- URL format validation

## Dependencies

The script requires:
- `bash` (version 3.2 or later)
- `curl` (version 7.0 or later)

## Installation

### Option 1: Clone the Repository

```bash
git clone https://github.com/laxy-me/zealot-upload-file.git
cd zealot-upload-file
chmod +x upload.sh
```

### Option 2: Direct Download

Using wget:
```bash
wget https://raw.githubusercontent.com/laxy-me/zealot-upload-file/master/upload.sh
chmod +x upload.sh
```

Using curl:
```bash
curl -O https://raw.githubusercontent.com/laxy-me/zealot-upload-file/master/upload.sh
chmod +x upload.sh
```

## Usage

### Basic Usage
```bash
./upload.sh --host [HOST] --token [TOKEN] --file [FILE_TO_UPLOAD]
```

### Advanced Usage
```bash
./upload.sh --host [HOST] --token [TOKEN] --file [FILE_TO_UPLOAD] [--changelog [CHANGELOG]] [--channel_key [CHANNEL_KEY]]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| -H, --host | Yes | Host name of the zealot service, including the protocol (HTTP/HTTPS) and the port, without trailing slash.<br>Examples:<br>- `http://192.168.0.123:8085`<br>- `https://www.example.com:8085` |
| -T, --token | Yes | Upload token for authentication.<br>You can find your token at: `https://[your-zealot-host]/users/edit` |
| -F, --file | Yes | Path to the file you want to upload |
| -L, --changelog | No | Path to a changelog file (optional) |
| -C, --channel_key | No | Channel key for specific upload target (optional) |

### Examples

1. Basic upload:
```bash
./upload.sh --host https://zealot.example.com --token your_token --file app.ipa
```

2. Upload with changelog:
```bash
./upload.sh --host https://zealot.example.com --token your_token --file app.ipa --changelog changelog.txt
```

3. Upload with channel key:
```bash
./upload.sh --host https://zealot.example.com --token your_token --file app.ipa --channel_key beta
```

## Error Handling

The script includes several safety checks:
- Validates the host URL format
- Checks if the file exists and is readable
- Verifies file size (max 500MB)
- Implements automatic retry on upload failure

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For more information about the Zealot API, please visit:
https://zealot.ews.im/zh-Hans/docs/developer-guide/api/apps