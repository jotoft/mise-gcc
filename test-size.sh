#!/bin/bash
# Check the size of a GCC version tarball without downloading it

set -e

VERSION="${1:-13.2.0}"
URL="https://mirror.koddos.net/gcc/releases/gcc-${VERSION}/gcc-${VERSION}.tar.xz"

echo "Checking size of GCC ${VERSION}..."
echo "URL: ${URL}"
echo ""

# Get Content-Length from HTTP headers
SIZE_BYTES=$(curl -sI "${URL}" | grep -i content-length | awk '{print $2}' | tr -d '\r')

if [ -z "$SIZE_BYTES" ]; then
    echo "ERROR: Could not determine file size"
    exit 1
fi

# Convert to human-readable format
SIZE_MB=$((SIZE_BYTES / 1024 / 1024))
SIZE_GB=$(echo "scale=2; $SIZE_BYTES / 1024 / 1024 / 1024" | bc)

echo "Size: ${SIZE_BYTES} bytes"
echo "      ${SIZE_MB} MB"
echo "      ${SIZE_GB} GB"
echo ""
echo "This is just the compressed tarball. Extracted source will be larger."
