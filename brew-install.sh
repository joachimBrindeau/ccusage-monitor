#!/bin/bash
set -e

echo "Setting up CCUsage Monitor for Homebrew distribution..."

# Create release build
swift build -c release

# Test the build
if [ -f ".build/release/ccusage-monitor" ]; then
    echo "✓ Build successful"
else
    echo "✗ Build failed"
    exit 1
fi

echo "✓ Ready for Homebrew distribution"
echo ""
echo "Next steps:"
echo "1. Create a GitHub release with tag v1.0.0"
echo "2. Update the Homebrew formula with the correct SHA256"
echo "3. Submit to homebrew-core or create your own tap"