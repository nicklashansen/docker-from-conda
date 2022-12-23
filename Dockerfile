########################################
# Dockerfile for (mostly) internal use #
# Nicklas Hansen, 2022 (c)             #
# nihansen@ucsd.edu                    #
# ------------------------------------ #
# Desc: builds a docker image from an  #
# existing environment.yml conda file  #
# ------------------------------------ #
# Intructions:                         #
# 1. Place this file in same directory #
#    as your environment.yml file      #
# 2. Build the image with:             #
#    docker build . -t <name:tag>      #
# (Requires an internet connection)    #
########################################

FROM nvidia/cuda:11.3.0-runtime-ubuntu20.04
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# apt-get
RUN apt-get -y update && \
    apt-get install -y git nano rsync vim tree curl wget unzip xvfb patchelf ffmpeg cmake \
    swig libssl-dev libcurl4-openssl-dev cmake libopenmpi-dev python3-dev zlib1g-dev \
    qtbase5-dev qtdeclarative5-dev libglib2.0-0 libglu1-mesa-dev libgl1-mesa-dev \
    libgl1-mesa-glx libosmesa6 libosmesa6-dev libglew-dev
RUN rm -rf /var/lib/apt/lists/*

# mujoco 2.1.0 (required by older packages)
RUN mkdir /root/.mujoco && cd /root/.mujoco
RUN wget --quiet https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz && \
    tar -xzf mujoco210-linux-x86_64.tar.gz && \
    rm mujoco210-linux-x86_64.tar.gz && \
    cp -r mujoco210 mujoco210_linux && \
    cd /root
ENV MJLIB_PATH /root/.mujoco/mujoco210/lib/libmujoco.so.2.1.0
ENV LD_LIBRARY_PATH /root/.mujoco/mujoco210/bin:$LD_LIBRARY_PATH

# conda
CMD ["/usr/sbin/sshd", "-D"]
ENV PATH /opt/conda/bin:$PATH
COPY environment.yml /root/environment.yml
RUN export ENVNAME="$(sed q /root/environment.yml | awk '{print $2}')" && \
    echo "Found environment.yml with env name: $ENVNAME" && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    . /opt/conda/etc/profile.d/conda.sh && \
    conda update -n base -c defaults conda && \
    conda init && \
    conda env create -f /root/environment.yml && \
    conda clean --all && \
    conda activate $ENVNAME && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "conda activate $ENVNAME" >> /root/.bashrc && \
    echo "export PATH=/opt/conda/envs/$ENVNAME/bin:$PATH" >> /root/.bashrc

# finalize
RUN mkdir /root/.ssh && \
    echo "export LANG=C.UTF-8" >> /etc/profile && \
    echo "Done!"
