#!/bin/sh

mv_ramips(){
for file in `cat ramip.txt`; 
do 
    if [ `echo $file |grep "\.asp"` ];then
       cp $file ./ramip_new/; 
   fi;
   if [ `echo $file |grep "cgi-bin"` ];then
       cp $file ./ramip_new/cgi-bin/; 
   fi; 
   if [ `echo $file |grep "zh_cn"` ];then
       cp $file ./ramip_new/data/lang/zh_cn/;
   fi;
   if [ `echo $file |grep "en_us"` ];then 
       cp $file ./ramip_new/data/lang/en_us/; 
   fi;
 done
}

mv_ar71xx(){
for file in `cat 71xx.txt`;
do
      if [ `echo $file |grep "\.asp"` ];then
         cp $file ./ar71xx_new/;
     fi;
    if [ `echo $file |grep "cgi-bin"` ];then
       cp $file ./ar71xx_new/cgi-bin/;
    fi;
    if [ `echo $file |grep "zh_cn"` ];then
    cp $file ./ar71xx_new/data/lang/zh_cn/;
    fi;
  if [ `echo $file |grep "en_us"` ];then
       cp $file ./ar71xx_new/data/lang/en_us/;
    fi;
 done
		   
}
del_same(){

for file in `cat 71xx.txt`;
do
	rm www_common/$file -f
done

}
