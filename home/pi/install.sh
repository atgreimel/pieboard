#!/bin/bash

sudo raspi-config nonint do_boot_behaviour B2
sudo raspi-config nonint do_change_locale en_US.UTF-8
sudo raspi-config nonint do_change_timezone US/Central
sudo raspi-config nonint do_configure_keyboard us

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install --no-install-recommends xserver-xorg
sudo apt-get -y install --no-install-recommends x11-xserver-utils
sudo apt-get -y install --no-install-recommends xinit
sudo apt-get -y install --no-install-recommends openbox
sudo apt-get -y install --no-install-recommends chromium-browser
sudo apt-get -y install --no-install-recommends nginx
sudo apt-get -y install --no-install-recommends php-fpm
sudo apt-get -y install --no-install-recommends php-curl

cat <<'EOT' | sudo tee -a /etc/xdg/openbox/autostart

# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp

# Start Chromium in kiosk mode
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
chromium-browser --disable-infobars --kiosk 'http://localhost/index.html'
EOT

cat <<'EOT' >> .profile

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor
EOT

sudo sed -i 's|index\.nginx-debian.html|index\.php|' /etc/nginx/sites-enabled/default
sudo sed -i 's|#\(location ~ \\\.php\$ {\)|\1|' /etc/nginx/sites-enabled/default
sudo sed -i 's|#\(\tinclude snippets/fastcgi-php\.conf;\)|\1|' /etc/nginx/sites-enabled/default
sudo sed -i 's|#\(\tfastcgi_pass unix:/var/run/php/php7\.0-fpm\.sock;\)|\1|' /etc/nginx/sites-enabled/default
sudo sed -i '/#\tfastcgi_pass 127\.0\.0\.1:9000;/{n;s/#//}' /etc/nginx/sites-enabled/default

sudo rm /var/www/html/index.nginx-debian.html
sudo /etc/init.d/nginx start

sudo wget -P /var/www/config/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/config/acsUser.php
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/bg.png
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/dailySlide.phtml
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/eboard.css
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/eboard.js
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/eboard.php
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/index.html
sudo wget -P /var/www/html/ https://raw.githubusercontent.com/atgreimel/pieboard/master/var/www/html/jquery-3.4.0.min.js
