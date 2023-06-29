# Kubernetes

Have a cluster at home and want to add steam headless to it?

Requirements
- NVIDIA Device plugin (if using nvidia GPU) https://github.com/NVIDIA/k8s-device-plugin 
- A storageclass

Tasks
1. Configure the statefulset to your liking. Things to note:
    - CPU & Memory
    - Env vars (see compose-files/.env for documentation)
2. Change the PVC to your liking. Things to note:
    - Storage Class
    - Size
3. Deploy it: `kubectl create -f k8s-files/*`
