#!/bin/bash

if ! command -v git >/dev/null 2>&1; then
	xcode-select --install
fi

if ! command -v brew >/dev/null 2>&1; then
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
fi
