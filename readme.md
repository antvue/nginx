```
docker build -t antvue/nginx .
docker push antvue/nginx
```

volumes:
 - /usr/local/openresty/nginx/conf/conf.d
 - /usr/local/openresty/nginx/logs


