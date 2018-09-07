g4_restart(){

 apn=`uci -q get config4g.@4G[0].apn`
 user=`uci -q get config4g.@4G[0].user`
 password=`uci -q get config4g.@4G[0].password`
 auth=`uci -q get config4g.@4G[0].auth`
 pincode=`uci -q get config4g.@4G[0].pincode`

	if [ "$pincode" != "" ]; then 
	/bin/quectel-CM  -s "${apn}"  "${user}" "${password}" "${auth}" -p "${pincode}" &
	elif [ "$apn" != "" ]; then
	/bin/quectel-CM  -s "${apn}"  &
	else
	/bin/quectel-CM  & 
	fi
    ifup 4g
}

wan_wwan_watcher(){
    ifup wan
    ifup wwan
    sleep 3
    if ping 114.114.114.114 -c1 -W3 -I eth0.2 ;then
        if ! route |grep default|grep eth0.2 ;then 
        ifup wan
        fi
        else
        ifdown wan
    fi
    if ping 114.114.114.114 -c1 -W3 -I apcli0 ;then
        if ! route |grep default|grep apcli0 ;then 
        ifup wwan
        fi
        else 
        ifdown wwan
    fi
}

 g4_ifup(){

       if ping 114.114.114.114 -c1 -W3 -I eth1 ;then
         ifup  4g
       fi 
 }

detect_4g(){
    if ! ping 114.114.114.114 -c1 -W3 -I eth1 ;then
        g4_restart  
        sleep 3
       if ping 114.114.114.114 -c1 -W3 -I eth1 ;then
        ifup  4g
       fi 
    else
        if ! route |grep default|grep eth1 ;then 
        ifup 4g
        fi  
    fi
}

loop_detect_4g(){
  while true 
  do
    detect_4g
    wan_wwan_watcher
  sleep 60
  done

}