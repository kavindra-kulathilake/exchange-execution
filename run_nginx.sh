docker build -t kkulathilake/nginx-exchange:latest .
podman stop nginx-exchange
podman rm nginx-exchange
podman run -d --restart=always -p 8080:8080 -p 8443:8443 --network exchange --name nginx-exchange   localhost/kkulathilake/nginx-exchange:latest
