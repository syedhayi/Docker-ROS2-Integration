#!/bin/bash
# ---------------------------------------------------------
# ROS 2 Container Entrypoint
# ---------------------------------------------------------

# We do NOT use 'set -e' globally here because we want the 
# container to start even if a minor permission fix fails.

# 1. Fix permissions for the mounted workspace
# We add '|| true' because volume mounts (especially from Windows) 
# can be stubborn with permission changes.
if [ -d "/root/ros2_ws" ]; then
    echo "🔧 Setting workspace permissions..."
    chmod -R 777 /root/ros2_ws || true
    chmod +x /root/ros2_ws/*.sh 2>/dev/null || true
fi

# 2. Fix permissions for Personal Tools
scripts=("/root/setup_vscode_ext.sh" "/root/build_completion.sh")
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script" || true
    fi
done

# 3. Final Check
# ${ROS_DISTRO^} capitalizes the first letter (e.g., Jazzy)
echo "🚀 ROS 2 ${ROS_DISTRO^} Container Ready!"

# 4. Hand over to the command (usually 'bash')
# This must be the very last line.
exec "$@"