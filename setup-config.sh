#!/bin/bash

# Install required packages
sudo apt-get update
sudo apt-get install -y x11-xserver-utils unclutter

# 1. Create the kiosk.service file
cat <<EOF | sudo tee /etc/systemd/system/kiosk.service > /dev/null
[Unit]
Description=Correr Kiosk al iniciar
After=network.target

[Service]
User=tv
Environment=XAUTHORITY=/home/tv/.Xauthority
Environment=DISPLAY=:0
ExecStart=/bin/bash -c "xsetroot -cursor_name left_ptr && xset s off && xset -dpms && /usr/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk --incognito --autoplay-policy=no-user-gesture-required https://tv.coocentral.com & unclutter -idle 1"
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# 2. Reload systemd to recognize the new service
sudo systemctl daemon-reload

# 3. Enable and start the kiosk service
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

# 4. Add reboot cron job to root's crontab
( sudo crontab -l 2>/dev/null; echo "0 */6 * * * /sbin/reboot" ) | sudo crontab -
