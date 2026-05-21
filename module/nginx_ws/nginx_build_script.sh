#!/bin/bash

sudo dnf update -y
sudo dnf install -y nginx
systemctl start nginx
systemctl enable nginx

# Create nginx server config with SSI enabled
sudo tee /etc/nginx/conf.d/ssi.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.shtml index.html;

    location / {
        ssi on;
        ssi_types text/html;
    }

    location ~ \.shtml$ {
        ssi on;
    }
}
EOF

# Create sample SSI page
sudo tee /usr/share/nginx/html/index.shtml > /dev/null <<'EOF'
<html>
<head>
    <title>NGINX SSI Test</title>
</head>
<body>

<h1>SSI is working</h1>

<p>Server time:</p>

<!--#echo var="DATE_LOCAL" -->

<p>Client IP:</p>

<!--#echo var="REMOTE_ADDR" -->

</body>
</html>
EOF

# Remove default config if it exists
if [ -f /etc/nginx/conf.d/default.conf ]; then
    sudo rm -f /etc/nginx/conf.d/default.conf
fi

# Test nginx config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
