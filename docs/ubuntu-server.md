# Ubuntu Server Setup

Use these instructions to install **Steam Headless** on an Ubuntu Server system.

> ⚠️ **Note**
>
> These steps assume you are running a minimal **Ubuntu Server** installation **without any desktop environment**.
> This setup **will not work** on Ubuntu Desktop.

---

## INSTALL NVIDIA DRIVER:

Although you're on a server system, using the `-server` variant of the NVIDIA driver can cause compatibility issues.  
Instead, install the standard driver **without recommended extras**:

```bash
apt install --no-install-recommends nvidia-driver-570
```

> 🔍 Feel free to `570` with the latest available version.

To find the latest version of the standard (non-`-server`, non-`-open`) drivers, run:

```bash
apt-cache search ^nvidia-driver- | awk '{print $1}' | grep -vE '(-server|-open)' | xargs -n1 apt-cache policy | awk '/^nvidia-driver-/{driver=$1} /Candidate:/ {print driver, $2}'
```

---

## INSTALL DOCKER:

Install `docker-ce` on your Ubuntu server by following the [official Docker instructions](https://docs.docker.com/engine/install/ubuntu/).

Make sure you also install the `docker-compose-plugin` as noted in the Docker documentation.

---

## INSTALL NVIDIA CONTAINER TOOLKIT

To enable GPU support inside Docker containers, install the [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit?tab=readme-ov-file).

Follow the [APT-based installation steps](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt) provided in the official documentation.

Once installed, configure Docker to use the NVIDIA runtime by default:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
```

> 💡 You *can* also run the container without the NVIDIA runtime by manually uncommenting the `/dev/nvidia*` device entries in the Compose file — but this approach is **not recommended**.

---

## CONFIGURE DOCKER COMPOSE:

After installing Docker, proceed to the [Compose Files](./docker-compose.md) section and select the appropriate configuration for your hardware setup.
