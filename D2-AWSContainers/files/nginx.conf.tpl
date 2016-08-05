events {
  worker_connections 4096;
}
http {
  server {
    listen 80;
    server_name ${discovery_endpoint};
    server_name 127.0.0.1;

    location /sydney {
      proxy_pass http://${ndc_sydney_elb_address}/;
    }

  }
}
