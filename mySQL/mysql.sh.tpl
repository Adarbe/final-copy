apt-get install mysql-common
apt-get install debsums
apt-get install libaio1
apt-get install libmecab2
sudo apt-get install gnupg2
wget https://repo.percona.com/apt/percona-release_latest.bionic_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
sudo apt-get update
sudo apt-get install percona-server-server + version number