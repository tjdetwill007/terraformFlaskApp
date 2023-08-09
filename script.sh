#! /bin/bash
sudo yum update -y
sudo dnf install mariadb105-server  mariadb105-devel gcc -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo yum install python3-devel -y
sudo yum install pip -y
sudo yum install git -y
cd /home/ec2-user/ && git clone https://github.com/tjdetwill007/flaskapp
cd flaskapp
python3 -m venv venv
sleep 5
source /home/ec2-user/flaskapp/venv/bin/activate
sudo sleep 3
pip install flask
pip install mysqlclient
pip install flask_mysqldb
sleep 5
echo "****wait****"
pip install gunicorn
tee -a myflask.service << EFO
[Unit]
Description=Gunicorn instance for creating flask application
After=network.target
[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/flaskapp
ExecStart=/home/ec2-user/flaskapp/venv/bin/gunicorn -b localhost:8000 app:app
Restart=always
[Install]
WantedBy=multi-user.target
EFO
sudo mv myflask.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start myflask.service
sudo systemctl enable myflask.service
sudo yum install nginx -y
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo cp /etc/nginx/nginx.conf .
echo "Waiting for response"
sudo sleep 10
sudo awk 'NR==36{print "    include /etc/nginx/sites-enabled/*;"}1' /etc/nginx/nginx.conf | sudo tee /etc/nginx/nginx.conf
if [ -s /etc/nginx/nginx.conf ]; then
        cat /etc/nginx/nginx.conf >> success.txt
else
        echo "Wait nginx.conf was not edited, Retrying...."
        sleep 5
        cp nginx.conf ./venv/
        awk 'NR==36{print "    include /etc/nginx/sites-enabled/*;"}1' nginx.conf | sudo tee /etc/nginx/nginx.conf
fi
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo mv default /etc/nginx/sites-available/
sudo systemctl start nginx
sudo systemctl enable nginx

sudo sleep 5

sudo yum install expect -y

expect -f - <<-EOF

set timeout 10
spawn sudo mysql_secure_installation

expect "Enter current password for root (enter for none):"
send -- "\r"

expect "Switch to unix_socket authentication"
send -- "n\r"

expect "Change the root password?"
send -- "y\r"

expect "New password:"
send -- "tjdetwill\r"

expect "Re-enter new password:"
send -- "tjdetwill\r"

expect "Remove anonymous users?"
send -- "n\r"

expect "Disallow root login remotely?"
send -- "n\r"

expect "Remove test database and access to it?"
send -- "n\r"

expect "Reload privilege tables now?"
send -- "y\r"

expect eof
EOF

mysql -u root -ptjdetwill <<-EOF
CREATE DATABASE geeklogin;
EOF

mysql -u root -ptjdetwill geeklogin < geeklogindb.sql

