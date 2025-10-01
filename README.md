# mise-gcc

A [mise](https://github.com/jdx/mise) plugin for [GCC](https://gcc.gnu.org/) (GNU Compiler Collection) that builds from source.

## Features

- 🔨 Builds GCC from source for maximum compatibility
- 📦 Automatically downloads required prerequisites (GMP, MPFR, MPC, ISL)
- 🚀 Parallel compilation support
- 🧹 Automatic cleanup of build artifacts to save disk space
- 📝 Lists all available GCC versions from GNU FTP mirrors

## Prerequisites

### Build Tools

GCC requires several tools to build from source:

**Required:**
- C and C++ compiler (bootstrap compiler)
- make
- tar, gzip, bzip2, xz
- wget or curl (for downloading prerequisites)

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install build-essential libgmp-dev libmpfr-dev libmpc-dev
```

**Linux (Arch):**
```bash
sudo pacman -S base-devel gmp mpfr libmpc
```

**macOS:**
```bash
# Xcode Command Line Tools required
xcode-select --install
```

## Installation

### Install Plugin

```bash
mise plugins install gcc https://github.com/jotoft/mise-gcc.git
```

### Install GCC

```bash
# Install latest version
mise install gcc@latest

# Install specific version
mise install gcc@13.2.0

# Set global version
mise use -g gcc@13.2.0
```

## Usage

### List Available Versions

```bash
mise ls-remote gcc
```

### Use in Project

Add to your `.mise.toml`:

```toml
[tools]
gcc = "13.2.0"
```

Or use with `mise use`:

```bash
mise use gcc@13.2.0
```

### Verify Installation

```bash
gcc --version
g++ --version
```

## Build Time and Disk Space

**⚠️ Important Notes:**

- **Build time**: GCC compilation can take significant time depending on your system
- **Disk space**: Requires substantial space during build, cleaned up after installation
- **Memory**: Adequate RAM recommended for parallel compilation

To see full build output:

```bash
mise install --raw gcc@13.2.0
```

## Configuration

### Parallel Jobs

The plugin automatically detects the number of CPU cores and uses parallel compilation. You can override this by setting the number of make jobs before installation.

### Languages

By default, only C and C++ compilers are built. To include additional languages, you would need to modify the `hooks/post_install.lua` file and change the `--enable-languages` configure option.

## Troubleshooting

### Build Fails

If the build fails:

1. Check that you have all prerequisites installed
2. Ensure you have enough disk space
3. Try with `--raw` flag to see full build output:
   ```bash
   mise install --raw gcc@13.2.0
   ```

### Out of Memory

If you experience out-of-memory errors during compilation:

1. Reduce parallel jobs by modifying `lib/helper.lua`
2. Close other applications to free up RAM
3. Consider adding swap space

## How It Works

This plugin:

1. **Lists versions** by parsing the mirror directory listing
2. **Downloads** the source tarball from `https://mirror.koddos.net/gcc/releases/`
3. **Downloads prerequisites** using GCC's `contrib/download_prerequisites` script
4. **Configures** GCC with:
   - `--enable-languages=c,c++`
   - `--disable-multilib` (single-arch build)
   - `--disable-bootstrap` (faster build, requires existing compiler)
5. **Builds** using parallel make jobs
6. **Installs** to mise's managed directory
7. **Cleans up** build artifacts to save disk space

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Related

- [mise](https://github.com/jdx/mise) - The polyglot version manager
- [GCC](https://gcc.gnu.org/) - The GNU Compiler Collection
- [mise-doxygen](https://github.com/jotoft/mise-doxygen) - Similar plugin for Doxygen

## Author

[@jotoft](https://github.com/jotoft)
