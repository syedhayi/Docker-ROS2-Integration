#!/bin/bash
# -----------------------------------------------------------------------------
# ROS 2 Build & Clean Helper Script - Milestone Version
# -----------------------------------------------------------------------------

# 1. Define and Enter Workspace
WORKSPACE_DIR="/root/ros2_ws"

if [ -d "$WORKSPACE_DIR" ]; then
    cd "$WORKSPACE_DIR"
else
    echo "❌ Error: $WORKSPACE_DIR not found!"
    return 1
fi

# 2. Logic for "clean" (Supports: clean all OR clean <pkg_name>)
if [ "$1" == "clean" ]; then
    shift # Move to the next argument
    
    if [ "$1" == "all" ] || [ -z "$1" ]; then
        echo "🧹 [CLEAN ALL] Wiping build, install, and log folders..."
        rm -rf build/ install/ log/
        echo "✅ Workspace is 100% clean."
    else
        PKG_NAME=$1
        echo "🪒 [CLEAN PARTIAL] Removing build/install artifacts for: $PKG_NAME"
        # We remove the specific folders in build and install
        rm -rf "build/$PKG_NAME"
        rm -rf "install/$PKG_NAME"
        # Also remove the colcon index for this package to prevent 'ghost' references
        rm -rf "install/share/$PKG_NAME" 2>/dev/null || true
        echo "✅ Package [$PKG_NAME] cleaned."
    fi
    return 0

# 3. Enhanced Debug Mode (Supports: debug OR debug <pkg_name>)
elif [ "$1" == "debug" ]; then
    # Move to the next argument
    shift 
    
    if [ -z "$1" ]; then
        echo "🐞 [DEBUG ALL] Building entire workspace with Debug symbols..."
        colcon build --cmake-args -DCMAKE_BUILD_TYPE=Debug
    else
        echo "🐞 [DEBUG PARTIAL] Building package [$1] with Debug symbols..."
        PKG_NAME=$1
        shift
        # We use --packages-above to ensure dependencies are handled, 
        # or --packages-select for just that one.
        colcon build --packages-select "$PKG_NAME" --cmake-args -DCMAKE_BUILD_TYPE=Debug "$@"
    fi
    echo "✅ Debug build complete."

# 4. Triple-Threat Build Logic
elif [ "$1" == "all" ]; then
    echo "🏗️  [FORCE ALL] Rebuilding every package (Release)..."
    shift
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release "$@"

elif [ -n "$1" ] && [[ "$1" != --* ]]; then
    echo "📦 [PARTIAL BUILD] Targeting package: $1..."
    PKG_NAME=$1
    shift
    colcon build --packages-select "$PKG_NAME" --symlink-install "$@"

else
    echo "⚡ [INCREMENTAL BUILD] Building changes..."
    colcon build --symlink-install "$@"
fi

# 5. Re-source the workspace
if [ -f "$WORKSPACE_DIR/install/setup.bash" ]; then
    source "$WORKSPACE_DIR/install/setup.bash"
    echo "🔄 Environment re-sourced."
fi