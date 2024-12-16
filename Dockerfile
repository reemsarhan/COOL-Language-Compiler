# This Dockerfile builds an image for a COOL (Classroom Object-Oriented Language) 
# compiler development environment. It sets up the necessary tools and dependencies 
# for compiling and running COOL programs.
#
# Usage:
# 1. Place this Dockerfile in the same directory as your "student-dist.tar.gz" archive.
# 2. Build the image: sudo docker build --no-cache --build-arg "USER_NAME=cool" --build-arg "USER_PASS=cool123" --tag "cs423:1.0" .
#    Note: Change the USER_NAME and USER_PASS with the container username and password you would like to use
#           to remote ssh into the container 
# 3. Run the container, mounting your local host directory:
#    sudo docker run [-d] -it [-p 2222:22] [--name cool] [-v /path/to/your/host/dir:/host] cs423:1.0
#           [-d] optional arugment to deamonized the started container
#           [-p 2222:22] map a host port to the ssh default port from inside the container.
#           [-v /path/to/your/host/dir:/host] map a host directory into a container directory to share content
#           between your host machine and the container.
# 4. if you would like to remote ssh to the running container
#    docker run  



#sudo docker build --no-cache --build-arg "USER_NAME=cool" --build-arg "USER_PASS=cool123" --tag "cs423:1.0" .
#sudo docker run -d -it -p 2222:22 --name cool -v /mnt/d/'Fourth Year'/:/host cs423:1.0
#sudo docker exec -it cool bash -->to go inside container

FROM ubuntu:20.04

# Install essential packages
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
build-essential \
wget \
tar \
gzip \
flex \
bison \
python3 \
gcc-multilib \
g++-multilib \
libncurses5-dev \
libc6-dev-i386 \
libx11-dev \
libxtst-dev \
sudo \
vim \
tree \  
openssh-server

ENV TZ=Africa/Cairo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# The running container writes all the build artefacts to a host directory (outside the container).
# The container can only write files to host directories, if it uses the same user ID and
# group ID owning the host directories. The host_uid and group_uid are passed to the docker build
# command with the --build-arg option. By default, they are both 1001. The docker image creates
# a group with host_gid and a user with host_uid and adds the user to the group. The symbolic
# name of the group and user is cuteradio.
ARG USER_NAME
ARG USER_PASS
RUN useradd -m $USER_NAME && echo $USER_NAME:$USER_PASS | chpasswd && usermod -aG sudo $USER_NAME

# Create a directory for COOL and set it as the working directory
WORKDIR /cool

# Copy the COOL tools archive into the container
COPY student-dist /cool/

# Extract the archive
# RUN tar -xzvf student-dist.tar.gz && rm student-dist.tar.gz

# Set up environment variables (adjust paths if needed)
ENV COOL_HOME=/cool
ENV PATH=$COOL_HOME/bin:$PATH
RUN echo "export PATH=/cool/bin:$PATH" >> /home/$USER_NAME/.bashrc

# Configure SSHD to start by default.
RUN update-rc.d ssh defaults
RUN service ssh start

# Create and execute the script to start SSH and bash
RUN echo '#!/bin/bash\n\nservice ssh start\nbash' > /usr/local/bin/start_services.sh && \
chmod +x /usr/local/bin/start_services.sh

# Start the services when the container launches
CMD ["/usr/local/bin/start_services.sh"]
