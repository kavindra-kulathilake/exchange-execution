set +x
podman network create exchange
podman pull kkulathilake/exchange:latest-amd64
podman pull kkulathilake/exchange-web:latest-amd64
podman stop exchange
podman rm exchange
podman stop exchange-web 
podman rm exchange-web
podman run -d --name exchange  --network exchange -p 4000:4000 docker.io/kkulathilake/exchange:latest-amd64
podman run -d  --name exchange-web  --network exchange -e REACT_APP_API_BASE_URL=http://app.sprintly-exchange.com  -p 3000:3000 docker.io/kkulathilake/exchange-web:latest-amd64
docker build -t kkulathilake/nginx-exchange:latest .
podman stop nginx-exchange
podman rm nginx-exchange
podman run -d   -p 80:80  --network exchange --name nginx-exchange   localhost/kkulathilake/nginx-exchange:latest

