![ROS2](https://img.shields.io/badge/ROS2-Jazzy-blue)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange?logo=ubuntu)

> `Host Portability:` Run ROS 2 on any machine without installation. 
>
> `System Integrity:` No "messy" libraries or broken dependencies on your main Ubuntu.
> 
> `Instant Recovery:`  `docker compose down && docker compose up -d` to fix a corrupted environment.

# ROS 2 Jazzy Docker Workspace
This document provides a detailed explanation of the Docker setup for a ROS 2 Jazzy development environment.

## 📂 Directory Structure
```bash
	
	├── ros2_jazzy/
		├── docker/
		│  	├── build_completion.sh			# Tab auto-completion for build and clean ROS2 ws	
		│  	├── build.sh					# script includesbuild and clean for ROS2 ws
		│  	├── docker-compose.yml 			# Hardware & GPU mapping
		│  	├── Dockerfile 					# Multi-stage: Base & Desktop
		│  	├── entrypoint.sh 				# this file runs as soon as a new session is opened
		│  	├── README.md 					# Documentation
		│  	├── setup_vscode_ext.sh 		# VS Code automation script for extensions i use 
		├── ros2_ws/ 						# Persistent ROS 2 Workspace
		│  	└── src/ 						# Source code (C++/Python)
		│  		└── learning_ros2/ 			# I'd prefer bundling my packages for the projects
		│  			└── ros2_pkg/ 
		
```
## Host Machine Setup (NVIDIA). 

> Note: only if you are going to build Desktop version of ROS2 in docker container.

Before building the container, your **Ubuntu Host** must be configured to share the GPU with Docker. Run these commands on your **Host PC** terminal (not inside a container).

### 1. Install NVIDIA Container Toolkit
```bash

	# 1. Add the package repositories
	curl  -fsSL [https://nvidia.github.io/libnvidia-container/gpgkey](https://nvidia.github.io/libnvidia-container/gpgkey) | sudo  gpg  --dearmor  -o  /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
	curl  -s  -L [https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list](https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list) | \
	sed  's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
	sudo  tee  /etc/apt/sources.list.d/nvidia-container-toolkit.list
	
	# 2. Install the toolkit
	sudo  apt  update && sudo  apt  install  -y  nvidia-container-toolkit
	
	# 3. Configure Docker to use the NVIDIA runtime
	sudo  nvidia-ctk  runtime  configure  --runtime=docker
	sudo  systemctl  restart  docker
	
```
### 2. Enable GUI Access (X11)
Run this command on your host PC to allow the container to display windows:
```bash
	xhost +local:docker
```

> Note: run this command every time you open a new session.

Alternatively, you could add the line below to your .bashrc through terminal command
```bash
     echo "xhost +local:docker > /dev/null" >> ~/.bashrc
```

## Start the Docker Container

Now, Let's start setting up the container
- Navigate to the docker directory:
```bash
	# In my case, docker-compose.yml file is present in ~/ros2_jazzy/docker/
	cd $HOME/ros2_jazzy/docker/
	
	# run 'docker compose up' to build the container 
	docker compose up -d --build
	
```
- once the container is up and running in the background, To start running your ROS 2 nodes, you need to open a shell inside the running container:
```bash
	# docker compose exec -it <NAME> bash
	docker compose exec -it jazzy_dev bash
```

> Note: To get your service_name, change directory to where the docker-compose.yml file is and run `docker compose ps` 
> ```bash 
> output:
> NAME        IMAGE               COMMAND                  SERVICE      CREATED        STATUS         PORTS
>jazzy_dev   docker-ros2_jazzy   "/root/entrypoint.sh…"   ros2_jazzy   13 hours ago   Up 6 minutes  
> ```

- use `exit` command on docker terminal to exit the docker container shell.
- To stop the docker running in background, run the below command from the directory where your docker-compose.yml file is located.
```bash
	docker compose stop
```

## ROS2 useful commands
Use the helper scripts located at `/root/build_completion.sh` and `/root/build.sh` to streamline the building and cleaning of your ROS 2 packages.
>Note: For convenience, aliases for `build` and `clean` have been added to `.bashrc`, allowing you to execute the helper scripts directly from any directory.

Build Commands:
```bash
	# Build a specific ROS 2 package 
	build <pkg_name> 
	# Build the entire workspace 
	build all 
	# Default build (equivalent to colcon build --symlink-install) 
	build
```
Clean Commands:
```bash
	# Clean artifacts for a specific package
	clean <pkg_name>
	# Clean the entire workspace (all/default behavior)
	clean all		
	#or	
	clean
```
>Note: The script located at `/root/build_completion.sh` dynamically scans the `/root/ros2_ws/src` directory for ROS 2 package names. By integrating this into your shell environment, you can simply type `build` or `clean` followed by a **`Tab`** key press to automatically list and select available packages from your workspace.

## Verifying the ROS2 Installation (Talker/Listener)

To verify that your ROS 2 Jazzy environment is correctly configured, you can run the built-in demo nodes.

1.  **Start the Talker:**    
    In your first container terminal, run the following command to start publishing messages:    
```bash
	ros2 run demo_nodes_py talker
```    
2.  **Start the Listener:**   
    Open a second terminal on your host machine, enter the container, and run the listener to receive those messages:    
```bash
	# Open new terminal on host
	docker exec -it jazzy_dev bash

	# Run listener inside container
	ros2 run demo_nodes_py listener
```
