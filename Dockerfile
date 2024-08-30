FROM nginx:latest
COPY nginx.conf /etc/nginx/nginx.conf
COPY app_sprintly-exchange_com.pem  /etc/nginx/certificate.crt
COPY app.sprintly_exchange.com.privkey-decrypted.pem /etc/nginx/private_key.key

EXPOSE 8080
EXPOSE 8443
CMD ["nginx", "-g", "daemon off;"]

