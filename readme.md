```
docker build -t antvue/nginx .
docker push antvue/nginx
```

volumes:
 - /usr/local/openresty/nginx/conf/conf.d
 - /usr/local/openresty/nginx/logs


```yaml
version: '3'
volumes:
  web:
services:
  web: 
    image: antvue/nginx
    restart: always
    ports:
      - "80:80"
      - "84:84"
      - "443:443"
    user: root
    volumes:
      - web:/usr/local/openresty/nginx/conf/conf.d
    logging:
      driver: json-file
      options:
        max-size: 20m
```
