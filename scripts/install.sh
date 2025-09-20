#!/bin/bash
set -e

echo "Installing CCUsage Monitor..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "Error: Swift command line tools not found"
    echo "Please install Xcode Command Line Tools:"
    echo "xcode-select --install"
    exit 1
fi

# Check if Node.js is available
if ! command -v npm &> /dev/null; then
    echo "Error: Node.js/npm not found"
    echo "Please install Node.js from https://nodejs.org"
    exit 1
fi

# Install ccusage if not present
if ! command -v ccusage &> /dev/null; then
    echo "Installing ccusage dependency..."
    npm install -g ccusage
fi

echo "Starting CCUsage Monitor..."
nohup swift main.swift > /dev/null 2>&1 &

echo "✓ CCUsage Monitor is now running in your menu bar"
echo "Use 'pkill -f main.swift' to stop the monitor"