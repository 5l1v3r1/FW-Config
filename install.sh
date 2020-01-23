apt-get install iptables
mkdir /usr/share/astsu
cp astsu.sh /usr/share/astsu/astsu
ln -s /usr/share/astsu/astsu /bin/astsu
ln -s /usr/share/astsu/astsu /usr/bin/astsu

echo "ASTSU has been instaled!"
