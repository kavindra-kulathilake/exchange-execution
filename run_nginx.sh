podman run -d \
  -p 8080:80 \
  -v /root/exchange-execution/nginx.conf:/etc/nginx/nginx.conf:ro \
  --name nginx \
  nginx:latest
