set +x
podman system prune -f
podman network create exchange
podman pull sprintlyinterchange/exchange:latest
podman pull sprintlyinterchange/exchange-web:latest
podman stop exchange
podman rm exchange
podman stop exchange-web 
podman rm exchange-web
podman run -d --restart=always --name exchange --network exchange -e FILE_STORAGE_DIR=/exchange -e CONFIG_STORAGE_DIR=/exchange -v $PWD/exchange:/exchange:z -p 4000:4000  docker.io/sprintlyinterchange/exchange:latest
podman run -d --restart=always  --name exchange-web  --network exchange -e REACT_APP_API_BASE_URL=https://app.sprintly-exchange.com  -p 3000:3000 docker.io/sprintlyinterchange/exchange-web:latest
docker build -t kkulathilake/nginx-exchange:latest .
podman stop nginx-exchange
podman rm nginx-exchange
podman run -d --restart=always -p 8080:8080 -p 8443:8443 --network exchange --name nginx-exchange   localhost/kkulathilake/nginx-exchange:latest

