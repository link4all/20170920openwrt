#!/bin/sh

rsync -a --delete --password-file=/etc/rsync.pwd --progress uftp@www.0470wifi.com::my_rsync/0/ /etc/nodogsplash/htdocs/images
