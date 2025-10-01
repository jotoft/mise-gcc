#!/bin/bash
# Quick test to verify the Available hook works

set -e

echo "Testing GCC version listing..."
echo "Fetching from https://mirror.koddos.net/gcc/releases/"
echo ""

# Test the HTTP endpoint directly
time curl -s --max-time 30 https://mirror.koddos.net/gcc/releases/ | grep -o 'href="gcc-[^"]*/"' | head -20

echo ""
echo "If you see gcc-X.Y.Z/ entries above, the endpoint works fine."
