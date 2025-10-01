# Self-Hosted GitHub Actions Runner

This directory contains configuration for running a self-hosted GitHub Actions runner using Debian 11 (Bullseye) with glibc 2.31.

## Why Self-Hosted?

- **Faster builds**: Use your own hardware
- **Older glibc**: Debian 11 has glibc 2.31 (same as Ubuntu 20.04) for better compatibility
- **Unlimited minutes**: No quota limits

## Prerequisites

- Docker and Docker Compose
- GitHub Personal Access Token with `repo` scope

## Setup

1. **Create a GitHub Personal Access Token**:
   - Go to: https://github.com/settings/tokens?type=beta
   - Click "Generate new token"
   - Set **Repository access**: Only select repositories → jotoft/mise-gcc
   - Set **Repository permissions** → **Administration**: Read and write
   - Generate and copy the token

2. **Create .env file**:
   ```bash
   cp .env.example .env
   # Edit .env and add your token
   ```

3. **Build and start the runner**:
   ```bash
   docker-compose -f docker-compose.runner.yml build
   docker-compose -f docker-compose.runner.yml up -d
   ```

4. **Verify runner is registered**:
   - Go to: https://github.com/jotoft/mise-gcc/settings/actions/runners
   - You should see "debian-bullseye-runner" with status "Idle"

5. **Update workflow to use self-hosted runner**:
   Edit `.github/workflows/build-gcc.yml`:
   ```yaml
   jobs:
     build:
       runs-on: [self-hosted, debian, glibc-2.31]
   ```

## Usage

```bash
# View logs
docker-compose -f docker-compose.runner.yml logs -f

# Stop runner
docker-compose -f docker-compose.runner.yml down

# Remove runner and volumes
docker-compose -f docker-compose.runner.yml down -v
```

## Troubleshooting

**Runner not appearing in GitHub**:
- Check logs: `docker logs mise-gcc-runner`
- Verify GITHUB_TOKEN has correct permissions
- Ensure GITHUB_REPO is correct format: `owner/repo`

**Runner offline**:
```bash
docker-compose -f docker-compose.runner.yml restart
```

## Security Notes

- The runner has access to your repository
- Don't expose the runner to untrusted code
- Keep the container updated
- Use a dedicated token with minimal permissions
- Consider network isolation for production use

## System Requirements

The runner needs sufficient resources for GCC compilation:
- **CPU**: 4+ cores recommended
- **RAM**: 8GB+ recommended
- **Disk**: 20GB+ free space
