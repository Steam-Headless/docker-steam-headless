# Ubuntu Server

Follow these instructions to install Steam Headless on Ubuntu Server.

> __Note__
>
> This assumes that your Ubuntu Server has not be configured to run any desktop environment!
> 
> This will not work with Ubuntu Desktop.


## INSTALL DOCKER:

Install docker-ce to your Ubuntu server following the [official instructions](https://docs.docker.com/engine/install/ubuntu/).

Ensure you install the `docker-compose-plugin` mentioned within these instructions


## INSTALL NVIDIA CONTAINER TOOLKIT

The easiest way to get running with NVIDIA GPUs is to install the [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit?tab=readme-ov-file).

Follow the [official instructions](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt) for installing the container toolkit to your Ubuntu server with apt.

If you do this, ensure that when you configure Docker Compose in the next step you choose the `nvidia` runtime.

Alternately, it is possible to run the container without the NVIDIA runtime by uncommenting the `/dev/nvidia` devices in the Compose file.


## CONFIGURE DOCKER COMPOSE:

Once you have installed docker, follow the [Compose Files](./docker-compose.md) section and select the right configuration file for your hardware.

