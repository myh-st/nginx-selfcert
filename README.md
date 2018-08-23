# Self-Certification
Auto Deploy Reverse Proxy TLS with Self-Certification

Script nginx-selfcert
Run the script:

    git clone https://github.com/myh-st/nginx-selfcert.git
    cd nginx-selfcert
    sh setup-selfcert.sh

# Example configuration file for generating self-signed certificates and certificate requests
    
    ex-configcert.conf

# Example use reverse proxy nginx with kibana 
Change kibana.conf IP 192.168.100.146 to your kibana IP. and copy to /etc/nginx/conf.d

# Config Kibana Enables SSL 
Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
These settings enable SSL for outgoing requests from the Kibana server to the browser.

    server.ssl.enabled: true
    server.ssl.key: /path/to/your/server.key
    server.ssl.certificate: /path/to/your/server.crt

Don't forget to restart service 

    service kibana restart
    service nginx restart

# Certificate output path

    Self-Signed Certificate path /opt/selfcert
