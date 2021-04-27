# Dockerfile-Grafana
Use to build the image to run the Grafana Server

## Description
A container image for running Grafana and let you can run it with your own settings file or using env variable to set Grafana. It makes you run Grafana service more easily.

## Run
### Docker
You can run the image by using `docker` command. To use `-p` option to expose the service.

`docker run -p 3000:3000/tcp chouhongming/grafana`

Also, you must use `-v` option to mount the folder if you want to keep everything and you don't run the container only for testing.

`docker run -p 3000:3000/tcp -v ./data:/var/lib/grafana chouhongming/prometheus`

### Docker Compose
You can use the `docker-compose.yml` file to run the service easily. Due to the different directory structure, you may need to change your working directory to example directory or use `-f` option to start the service.

`docker-compose -f example/docker-compose.yml up -d`

The command for stopping the service, if you use `-f` option to start the service.

`docker-compose -f example/docker-compose.yml down`

And you can use exec action to login to the container to run the command that you want.

`docker-compose -f example/docker-compose.yml exec prometheus bash`

If you want to rebuild the image, you can replace `image: chouhongming/grafana` with `build: ..` and run the `docker-compose` with `--build` option, for example:

```
version: "3.7"
services:
  grafana:
    build:
      context: ..
      dockerfile: Alpine.Dockerfile
    ports:
      - "3000:3000/tcp"
```

`docker-compose -f example/docker-compose.yml up -d --build`

### Kubernetes
You can copy the `k8s-resource.yml` file and do the following step to let the setting be correct:
1. To replace the word `[YOUR_K8S_NAMESPACE]` with the namespace that you want to apply the service.
2. To replace the word `[YOUR_NFS_PATH]` and `[YOUR_NFS_ADDRESS]` with your NFS setting. If you don't use NFS as your _PersistentVolume_, you can replace `nfs` section with your storage setting.

    ```yaml
      nfs:
        path: [YOUR_NFS_PATH]
        server: [YOUR_NFS_ADDRESS]
    ```
3. To replace the word `[YOUR_DOMAIN]` with your domain name to let Traefik redirect the traffic into Prometheus Pod if you use Traefik as your Ingress controller.
4. If you also use Traefik 2.0+ as your Kubernetes ingress controller, you can replace the word `[YOUR_HTTPS_REDIRECT_MIDDLEWARE]` and `[YOUR_RESOLVER_NAME]` with your middleware of HTTPS redirector and your cert resolver. Or you can delete the YAML section of the two IngressRoute and add the new one to fit your ingress controller. Also, you can delete the YAML sections of the IngressRoute is called `prometheus-web` and `prometheus-websecure` and you can delete the following section in the `prometheus-web` IngressRoute section if you don't want to use HTTPS.

    ```yaml
        middlewares:
        - name: [YOUR_K8S_REDIRECT-MIDDLEWARES]
    ```

After your done the `k8s-resource.yml` file, you can apply to the Kubernetes cluster.

`kubectl apply -f k8s-resource.yml`

## Volume
- /var/lib/grafana

    To save the data that Grafana produces when running.

- /etc/grafana/grafana.ini

    To import your own Granafa settings when you set the environment `MOUNT_CONFIG` as true. You can edit the example for the specific service and mount it again.

- Others

    You can mount another path for Grafana data, log, plugin, and provisioning. If you mount it, you must set the environment too.

## Environment
- TIMEZONE=UTC

    Set the timezone in the container.

- MOUNT_CONFIG=false

    To choose that you want to mount your own Grafana config file or not. If you set it as true, you need to mount your config file, or you can set the environment of the Grafana setting to change the setting that you want at startup.

- Grafana Setting

    In the file `asset/grafana.ini`, each value of the setting is the name of the environment. You can use it to set the environment to update the Grafana setting that you want.

