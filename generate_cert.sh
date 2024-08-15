sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /opt/exchange-execution/private_key.key -out /opt/exchange-execution/certificate.crt \
-subj "/C=SE/ST=Stckholm Country/L=Stockholm/O=Sprintly Exchange/OU=Exchange/CN=app.sprintly-exchange.com"

