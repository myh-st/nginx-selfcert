#!/bin/sh
echo ""
echo "   1) Setup Self-Certificate with reverse proxy "
echo "   2) Add Multiple IP Address to Self-Certificate "
echo "   3) Exit "
echo ""
read -p "Select an option [1-3]: " option
echo ""
case $option in
                1)
yum -y install epel-release
yum -y install nginx httpd-tools bc
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sed -i -e '38,87d' /etc/nginx/nginx.conf
mkdir /etc/nginx/ssl && mkdir /etc/nginx/conf.d
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
echo "I need to ask you a few questions before starting the setup"
read -p "Certificate Name: " -e CERN
read -p "Domain Name: " -e DN
read -p "Reverse Proxy Application IP: " -e APPIP
read -p "Reverse Proxy Application Port: " -e APPPORT
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
cat <<EOT> $CERN.conf
 
[ req ]
 
default_bits        = 2048
default_keyfile     = server-key.pem
distinguished_name  = subject
req_extensions      = req_ext
x509_extensions     = x509_ext
string_mask         = utf8only
 
[ subject ]
 
countryName                 = Country Name (2 letter code)
countryName_default         = TH
 
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = Bangkok
 
localityName                = Locality Name (eg, city)
localityName_default        = Bangkok
 
organizationName            = Organization Name (eg, company)
organizationName_default    = YOURCOMPANY
 
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_default          = YOURCOMPANY
 
emailAddress                = Email Address
emailAddress_default        = YOUREMAIL@YOURCOMPANY.com
 
[ x509_ext ]
 
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
 
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment
subjectAltName         = @alternate_names
nsComment              = "OpenSSL Generated Certificate"
 
[ req_ext ]
 
subjectKeyIdentifier = hash
 
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, keyEncipherment
subjectAltName       = @alternate_names
nsComment            = "OpenSSL Generated Certificate"
 
[ alternate_names ]
 
DNS.1 = $DN
IP.1 = $IP
EOT
openssl req -config $CERN.conf -new -sha256 -newkey rsa:2048 \
-nodes -keyout /etc/nginx/ssl/$CERN.key -x509 -days 365 \
-out /etc/nginx/ssl/$CERN.crt
 
cat <<EOF> /etc/nginx/conf.d/$CERN.conf
server {
listen 80 default_server;
listen [::]:80 default_server;
server_name $IP;
return 301 https://$IP;
}
server {
listen 443 ssl;
server_name _;root /usr/share/nginx/html;
index index.html index.htm;ssl_certificate /etc/nginx/ssl/$CERN.crt;
ssl_certificate_key /etc/nginx/ssl/$CERN.key;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_stapling on;
ssl_stapling_verify on;
add_header Strict-Transport-Security max-age=15768000;
location / {
proxy_pass http://$APPIP:$APPPORT;
proxy_http_version 1.1;
proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection 'upgrade';
proxy_set_header Host \$host;
proxy_cache_bypass \$http_upgrade;
}
}
EOF
chkconfig nginx on
service nginx restart
mkdir /opt/selfcert
cd /opt/selfcert
cp -f /etc/nginx/ssl/$CERN.crt /opt/selfcert
echo ""
echo "Self-Signed Certificate path /opt/selfcert"
echo "Import Self-Signed Certificate on WindowsOS" 
echo "Step 1: Double-click $CERN.crt"
echo "Step 2: Install Certificate"
echo "Step 3: Store Localtion -> Local Machine" 
echo "Step 4: Place all Certificates the following store"
echo "Step 5: Browse and Choose Trusted Root Certification Authorities"
echo "Step 6: Reopen Browser"
echo "If you want to use domain name on WindowsOS add $IP $DN to hosts file" 
echo "Step 1: windows+r" 
echo "Step 2: C:\Windows\System32\Drivers\etc\hosts"
echo "Step 3: Enter"
echo "Complete!"
echo "Please make sure you enable the 80 and 443 firewall ports"
            exit
            ;;
                2)
while :
do
clear
echo "What do you want to add to Self-Certificate?"
echo "   1) Add IP Address "
echo "   2) Add Domain Name "
echo "   3) Exit "
echo ""
read -p "Select an option [1-3]: " option
echo ""
case $option in
            1)
					   #IPD="1"
                       echo "I need to ask you a few questions before starting the setup"
                       read -p "Certificate Name: " -e CERN
                       read -p "IP Number: " -e IPN
                       read -p "IP Address: " -e IP
                       	#NUMV=$(grep "IP." $CERN.conf | awk 'NF{print$1}')
                       	#NUMV2=$(echo $NUMV | rev | cut -d'.' -f 1 | rev)
 						#sed -i "/IP.$NUMV2/a IP.$IPN = $IP" $CERN.conf
                       echo "IP.$IPN = $IP" >> $CERN.conf
                        openssl req -config $CERN.conf -new -sha256 -newkey rsa:2048 \
                       -nodes -keyout /etc/nginx/ssl/$CERN.key -x509 -days 365 \
                       -out /etc/nginx/ssl/$CERN.crt
                       cp -f /etc/nginx/ssl/$CERN.crt /opt/selfcert
                       service nginx restart
                   	echo ""
        exit
        ;;
            2)
					   #DND="1"
                       echo "I need to ask you a few questions before starting the setup"
                       read -p "Certificate Name: " -e CERN
                       read -p "Domain Number: " -e DMN
                       read -p "Domain Name: " -e DM
                       	#NUMV=$(grep "DNS." $CERN.conf | awk 'NF{print$1}')
                       	#NUMV2=$(echo $NUMV | rev | cut -d'.' -f 1 | rev)
						#sed -i "/DNS.$NUMV/a DNS.$DMN = $DM" $CERN.conf
                        echo "DNS.$DMN = $DM" >> $CERN.conf     
                        openssl req -config $CERN.conf -new -sha256 -newkey rsa:2048 \
                       -nodes -keyout /etc/nginx/ssl/$CERN.key -x509 -days 365 \
                       -out /etc/nginx/ssl/$CERN.crt
                       cp -f /etc/nginx/ssl/$CERN.crt /opt/selfcert    
                       service nginx restart       
                       echo ""
        exit
        ;;
 
            3)
        echo ""
        exit
        ;;
esac
done
            exit
            ;;
                3)

            exit
            ;;
            
    esac
done
 
           exit
                ;;
