#!/bin/bash
# ---------------------------------------------------------
# VS Code Extension Installer (Source-Safe Version)
# ---------------------------------------------------------

# --- EXIT HANDLER ---
# This prevents the terminal from closing if the script is 'sourced'
safe_exit() {
    [[ $_ != $0 ]] && return "$1" || exit "$1"
}

# 1. AUTO-DETECTION LOGIC
if command -v code-insiders &> /dev/null; then
    DETECTED_BINARY="code-insiders"
elif command -v code &> /dev/null; then
    DETECTED_BINARY="code"
else
    echo "⚠️ Error: Neither 'code' nor 'code-insiders' was found in your PATH."
    echo "Make sure you are running this inside a VS Code terminal."
    safe_exit 1
fi

# 2. ASSIGN BINARY
VSCODE_BINARY=${1:-$DETECTED_BINARY}

echo "-----------------------------------------------"
echo "  VS Code Extension Installer"
echo "-----------------------------------------------"
echo "Detected App: $DETECTED_BINARY"
echo "Using Binary: $VSCODE_BINARY"
echo "-----------------------------------------------"

# 3. YOUR BUNDLE
EXTENSIONS=(
    # "ms-vscode.cpptools"
    # "ms-vscode.cmake-tools"
    "ms-python.python"
    # "morningfrog.urdf-visualizer"
    "Ranch-Hand-Robotics.rde-pack"
    "ms-vscode.cpptools-extension-pack"
)

# 4. INSTALLATION
for ext in "${EXTENSIONS[@]}"; do
    echo "📦 Installing: $ext..."
    # --force ensures it updates if already installed
    if ! $VSCODE_BINARY --install-extension "$ext" --force; then
        echo "❌ Failed to install $ext"
    fi
done

echo ""
echo "✅ All extensions processed for $VSCODE_BINARY."
echo "-----------------------------------------------"