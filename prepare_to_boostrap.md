- Rerplace `yourdomain.com` with the actual domain name in the virtual host files.
```
$ export YOUR_DOMAIN_COM=shride.io
$ sudo find /tmp/shoebox/src/apache/conf.d/ -type f -exec sed -i -e 's/yourdomain.com/'"$YOUR_DOMAIN_COM"'/g' {} \;
```
-  Copy the modified virtual host files into the working `conf.d` directory
```
$ sudo cp /tmp/shoebox/src/apache/conf.d/*  /etc/httpd/conf.d
```
- Restart Apache
```
systemctl restart httpd
```