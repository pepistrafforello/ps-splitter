# PowerShell File Splitter

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://microsoft.com/PowerShell/)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows/)

A robust PowerShell utility for splitting large binary files into smaller, manageable chunks. Perfect for handling large files that need to be transferred, stored, or processed in smaller segments.

## ✨ Features

- 🔧 **Flexible Chunk Sizes**: Support for KB, MB, GB units with decimal precision
- 📁 **Smart Output Management**: Automatic directory creation with customizable naming
- 🎯 **Progress Tracking**: Real-time progress display with completion percentage
- 🔒 **Safe Operations**: Built-in file validation and optional overwrite protection
- 🎨 **Customizable Prefixes**: Configure chunk file naming patterns
- 🔇 **Quiet Mode**: Minimal output for automated scripts
- 📦 **Easy Installation**: Simple module installation script included

## 🚀 Quick Start

### Installation

1. **Clone or download** this repository:
   ```powershell
   git clone https://github.com/pepistrafforello/ps-splitter.git
   cd ps-splitter
   ```

2. **Install as PowerShell module** (requires Administrator privileges):
   ```powershell
   .\Setup-Splitter.ps1
   ```

3. **Import the module** (if not auto-imported):
   ```powershell
   Import-Module FileSplitter
   ```

### Basic Usage

Split a file into 10MB chunks:
```powershell
Split-File -InputFile "C:\data\largefile.zip" -ChunkSize 10MB
```

## 📖 Usage Examples

### Example 1: Basic File Splitting
```powershell
# Split a large archive into 50MB chunks
Split-File -InputFile "backup.tar" -ChunkSize 50MB
```

### Example 2: Custom Output Directory and Prefix
```powershell
# Split with custom output location and file naming
Split-File -InputFile "video.mp4" -OutputDirectory "C:\Chunks" -ChunkSize 100MB -ChunkPrefix "video_part_"
```

### Example 3: Automated Script Mode
```powershell
# Silent operation with automatic overwrite
Split-File -InputFile "database.bak" -ChunkSize 2GB -Overwrite -Quiet
```

### Example 4: Using Different Size Units
```powershell
# Various size formats supported
Split-File -InputFile "data.bin" -ChunkSize 512KB    # Kilobytes
Split-File -InputFile "data.bin" -ChunkSize 1.5GB    # Decimal gigabytes
Split-File -InputFile "data.bin" -ChunkSize 1000000  # Raw bytes
```

## 🔧 Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `InputFile` | String | ✅ Yes | - | Path to the file to be split |
| `OutputDirectory` | String | ❌ No | `{filename}_chunks` | Directory for output chunks |
| `ChunkSize` | String | ❌ No | `1MB` | Size of each chunk (supports KB, MB, GB) |
| `ChunkPrefix` | String | ❌ No | `chunk_` | Prefix for chunk filenames |
| `Overwrite` | Switch | ❌ No | `false` | Overwrite existing files without prompting |
| `Quiet` | Switch | ❌ No | `false` | Suppress progress output |

## 📁 Output Format

Chunks are saved with sequential numbering:
```
chunk_0001.bin
chunk_0002.bin
chunk_0003.bin
...
```

With custom prefix:
```
video_part_0001.bin
video_part_0002.bin
video_part_0003.bin
...
```

## 🛠️ Requirements

- **Windows** operating system
- **PowerShell 3.0** or higher
- **Administrator privileges** (for module installation only)

## 📊 Performance

The script uses efficient binary file operations with:
- Buffered reading for optimal memory usage
- Stream-based processing to handle large files
- Progress tracking without significant performance impact

## 🔍 Error Handling

The script includes comprehensive error handling for:
- ❌ Non-existent input files
- ❌ Invalid chunk size formats
- ❌ Insufficient disk space
- ❌ Permission issues
- ❌ Invalid file paths

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Follow PowerShell best practices
2. Include appropriate comment-based help
3. Add parameter validation where appropriate
4. Test with various file sizes and formats

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE.md](LICENSE.md) file for details.

## 📧 Contact

**Author**: Giuseppe Strafforello  
**Email**: giuseppe.strafforello@titantechnologies.com  
**Company**: Titan Technologies

## 🔖 Version History

### Version 1.0
- Initial release
- Core file splitting functionality
- Progress tracking and error handling
- Module installation support

---

## 🆘 Troubleshooting

### Common Issues

**Q: "Execution of scripts is disabled on this system"**  
A: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` to allow script execution.

**Q: Module not found after installation**  
A: Try running `Import-Module FileSplitter -Force` or restart your PowerShell session.

**Q: Access denied during installation**  
A: Ensure you're running the setup script as Administrator.

**Q: Out of disk space errors**  
A: Check available disk space in the output directory before splitting large files.

---

⭐ **Like this project?** Give it a star on GitHub!
