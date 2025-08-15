########   nexus runs on port 8081 #############



1. Install java on the system

sudo yum install java-1.8.0-amazon-corretto-devel

2. Change directory to /opt

cd /opt

3. Download the nexus from their official https://help.sonatype.com/en/download.html

wget https://download.sonatype.com/nexus/3/nexus-3.65.0-02-unix.tar.gz

4. Extract the tar file

tar -xvf nexus-3.65.0-02-unix.tar.gz

5. Chang ename of nexus directory 

sudo mv nexus-3.65.0-02 nexus

5. Add nexus user (Prefer to set password for safety)

sudo adduser nexus

4. Change the ownership of the directories nexus and sonatype

sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

5. change directory 

sudo vi /opt/nexus/bin/nexus.rc

6. Add nexus as user

run_as_user="nexus"

7. Configure to run as nexus as a service

sudo vi /etc/systemd/system/nexus.service

[Unit]
Description=nexus service
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target

8. Create a symbolic link

sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus

9. Add service to boot

sudo chkconfig --add nexus
sudo chkconfig --levels 345 nexus on

10. Start service

sudo service nexus start




########### Getting intial passowrd for admin #########

/opt/sonatype-work/nexus3/admin.password
