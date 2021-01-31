#!/bin/bash

### set new password
sudo passwd pi

### take care of raspi-config settings
sudo raspi-config nonint do_boot_behaviour B2
sudo raspi-config nonint do_boot_splash 0
sudo raspi-config nonint do_change_locale en_US.UTF-8
. /etc/default/locale
sudo raspi-config nonint do_change_timezone US/Central
sudo raspi-config nonint do_configure_keyboard us
sudo raspi-config nonint do_overscan 1

### update package lists and upgrade
sudo apt-get -y update
sudo apt-get -y upgrade

### install required packages
sudo apt-get -y install --no-install-recommends xserver-xorg
sudo apt-get -y install --no-install-recommends x11-xserver-utils
sudo apt-get -y install --no-install-recommends xinit
sudo apt-get -y install --no-install-recommends openbox
sudo apt-get -y install --no-install-recommends chromium-browser
sudo apt-get -y install --no-install-recommends nginx
sudo apt-get -y install --no-install-recommends php-fpm
sudo apt-get -y install --no-install-recommends php-curl
sudo apt-get -y install --no-install-recommends sox
sudo apt-get -y install --no-install-recommends libsox-fmt-mp3
sudo apt-get -y install --no-install-recommends git

## remove redundant package files
sudo apt-get clean

### setup openbox
cat << EOT | sudo tee -a /etc/xdg/openbox/autostart

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

### start x server automatically
cat << 'EOT' >> .profile

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor
EOT

#### configure and start nginx web server
sudo sed -i '/\troot \/var\/www\/html;/a \\taccess_log off;' /etc/nginx/sites-enabled/default
sudo sed -i 's/index\.nginx-debian.html/index\.php/' /etc/nginx/sites-enabled/default
sudo sed -i 's/#\(location ~ \\\.php\$ {\)/\1/' /etc/nginx/sites-enabled/default
sudo sed -i 's/#\(\tinclude snippets\/fastcgi-php\.conf;\)/\1/' /etc/nginx/sites-enabled/default
sudo sed -i 's/#\(\tfastcgi_pass unix:\/var\/run\/php\/php[0-9][0-9]*\.[0-9][0-9]*-fpm\.sock;\)/\1/' /etc/nginx/sites-enabled/default
sudo sed -i '/#\tfastcgi_pass 127\.0\.0\.1:9000;/{n;s/#//}' /etc/nginx/sites-enabled/default
sudo rm /var/www/html/index.nginx-debian.html
sudo /etc/init.d/nginx start

#### set audio volume
amixer sset PCM -- -8dB


### mount /tmp in ram (and /var/log?)
cat << EOT | sudo tee -a /etc/fstab

tmpfs /tmp tmpfs defaults,noatime,nosuid,size=64M 0 0
EOT

## all done - remove self and reboot after 1 minute
rm install.sh
#sudo shutdown -r +1
