PHY-OBJS += phys/athrf1_phy.o
MAC-OBJS += ag934x.o athrs_gmac_ctrl.o athrs_phy_ctrl.o
obj-m					:= athrs_gmac.o 
athrs_gmac-objs				:= $(PHY-OBJS) $(MAC-OBJS) athrs_mac.o athrs_mac_timer.o athrs_flowmac.o


clean:
	rm -f *.o *.ko 
	rm -f phys/*.o *.ko

