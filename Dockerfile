FROM nginx:latest
COPY nginx.conf /etc/nginx/nginx.conf
COPY certificate.crt /etc/nginx//certificate.crt
COPY private_key.key /etc/nginx/private_key.key

EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]

