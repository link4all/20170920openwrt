#!/bin/sh

 A_on() {
   echo 0 > /sys/class/gpio/gpio19/value
}

 A_off() {
   echo 1 > /sys/class/gpio/gpio19/value
}

 B_on() {
   echo 0 > /sys/class/gpio/gpio18/value
}

 B_off() {
   echo 1 > /sys/class/gpio/gpio18/value
}

 C_on() {
   echo 0 > /sys/class/gpio/gpio15/value
}

 C_off() {
   echo 1 > /sys/class/gpio/gpio15/value
}

 D_on() {
   echo 0 > /sys/class/gpio/gpio16/value
}

 D_off() {
   echo 1 > /sys/class/gpio/gpio16/value
}

 E_on() {
   echo 0 > /sys/class/gpio/gpio17/value
}

 E_off() {
   echo 1 > /sys/class/gpio/gpio17/value
}

 F_on() {
   echo 0 > /sys/class/gpio/gpio20/value
}

 F_off() {
   echo 1 > /sys/class/gpio/gpio20/value
}

 G_on() {
   echo 0 > /sys/class/gpio/gpio21/value
}

 G_off() {
   echo 1 > /sys/class/gpio/gpio21/value
}

 H_on() {
   echo 0 > /sys/class/gpio/gpio14/value
}

 H_off() {
   echo 1 > /sys/class/gpio/gpio14/value
}


 write0() {
   A_on
   B_on
   C_on
   D_on
   E_on
   F_on
   G_off
}

 write1() {
   A_off
   B_on
   C_on
   D_off
   E_off
   F_off
   G_off
}

 write2() {
   A_on
   B_on
   C_off
   D_on
   E_on
   F_off
   G_on
}

 write3() {
   A_on
   B_on
   C_on
   D_on
   E_off
   F_off
   G_on
}

 write4() {
   A_off
   B_on
   C_on
   D_off
   E_off
   F_on
   G_on
}

 write5() {
   A_on
   B_off
   C_on
   D_on
   E_off
   F_on
   G_on
}

 write6() {
   A_on
   B_off
   C_on
   D_on
   E_on
   F_on
   G_on
}

 write7() {
   A_on
   B_on
   C_on
   D_off
   E_off
   F_off
   G_off
}

 write8() {
   A_on
   B_on
   C_on
   D_on
   E_on
   F_on
   G_on
}

 write9() {
   A_on
   B_on
   C_on
   D_on
   E_off
   F_on
   G_on
}

 writeA() {
   A_on
   B_on
   C_on
   D_off
   E_on
   F_on
   G_on
}

 writeB() {
   A_off
   B_off
   C_on
   D_on
   E_on
   F_on
   G_on
}


 writeC() {
   A_on
   B_off
   C_off
   D_on
   E_on
   F_on
   G_off
}

 writeD() {
   A_off
   B_on
   C_on
   D_on
   E_on
   F_off
   G_on
}

 writeE() {
   A_on
   B_off
   C_off
   D_on
   E_on
   F_on
   G_on
}

 writeF() {
   A_on
   B_off
   C_off
   D_off
   E_on
   F_on
   G_on
}



 test() {
  write0
 sleep 1
 for i in $(seq 9) ;do
  {
   write$i
   sleep 1
   }
 done
 writeA
 sleep 1
 writeB
 sleep 1
 writeC
 sleep 1
 writeD
 sleep 1
 writeE
 sleep 1
 writeF

}

all_on(){
A_on
sleep 1 
B_on
sleep 1 
C_on
sleep 1 
D_on
sleep 1 
E_on
sleep 1 
F_on
sleep 1 
G_on
sleep 1 
H_on
}


all_off(){
A_off
sleep 1 
B_off
sleep 1 
C_off
sleep 1 
D_off
sleep 1 
E_off
sleep 1 
F_off
sleep 1 
G_off
sleep 1 
H_off
}
