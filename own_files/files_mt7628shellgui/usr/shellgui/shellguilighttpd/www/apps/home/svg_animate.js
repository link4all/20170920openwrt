var loopInterval;
/* telnetd */
$('#telnetd').mouseenter(function(){
	var telnetdRxInter = setInterval(setRx,5);
	var rx = 100;
	function setRx(){
		$('#telnetdWindow').get(0).setAttribute('rx',rx);
		rx = rx-2;
		if(rx <= 20){
			clearInterval(telnetdRxInter);
			$('#telnetdWindow').get(0).setAttribute('rx',20);
		}
	}
	loopInterval = setInterval(setOp,50);
	var op = 10;add = false;
	function setOp(){
		$('#inputIcon').get(0).setAttribute('opacity',op/10);
		if(add){
			op = 10;
		}else{
			op -= 1;
		}
		if(op <= 0){
			add = true;
		}else if(op >= 10){
			add = false;
		}
	}
}).mouseleave(function(){
	var telnetdRxInter = setInterval(setRx,5);
	var rx = 20;
	function setRx(){
		$('#telnetdWindow').get(0).setAttribute('rx',rx);
		rx = rx+2;
		if(rx >= 100){
			clearInterval(telnetdRxInter);
			$('#telnetdWindow').get(0).setAttribute('rx',100);
		}
	}
	$('#inputIcon').get(0).setAttribute('opacity',1);
	clearInterval(loopInterval);
});;

/*firmware*/
var firmOpInt;
$('#firmware').mouseenter(function(){
	var angl = 1;
	loopInterval = setInterval(rotateCir,5);
	function rotateCir(){
		$('#upCircle').get(0).setAttribute('transform','translate(100,100) scale(0.8,0.8) rotate(' + angl + ')');
		angl -= 1;
	}

	var op = 10,po = 0,ang = 0,v = 5;
	firmOpInt = setInterval(setOp,50);
	function setOp(){
		$('#cpuIcon').get(0).setAttribute('opacity',op/10);
		$('#upCircle').get(0).setAttribute('opacity',po/10);
		$('#cpuIcon').get(0).setAttribute('transform','translate(100,100) rotate(' + ang + ')');
		ang -= v;
		v++;
		op -= 1;
		po += 1;
		if(op <= 0){
			clearInterval(firmOpInt);
			$('#cpuIcon').get(0).setAttribute('opacity',0);
			$('#upCircle').get(0).setAttribute('opacity',1);
			$('#cpuIcon').get(0).setAttribute('transform','translate(100,100)');
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	clearInterval(firmOpInt);
	$('#cpuIcon').get(0).setAttribute('transform','translate(100,100)');
	var op = 1,po = 0;
	var opInterval = setInterval(setOp,10);
	function setOp(){
		$('#cpuIcon').get(0).setAttribute('opacity',po);
		$('#upCircle').get(0).setAttribute('opacity',op);
		op -= 0.1;
		po += 0.1;
		if(op <= 0){
			clearInterval(opInterval);
			$('#cpuIcon').get(0).setAttribute('opacity',1);
			$('#upCircle').get(0).setAttribute('opacity',0);
			clearInterval(loopInterval);
		}
	}
});

/*notice*/
$('#notice').mouseenter(function(){
	$('#notice_all').get(0).setAttribute('transform','translate(-100,-70)');
	$('#notice_all').parent().get(0).setAttribute('transform','translate(100,100),scale(0.9,0.9)');
	$('#notice_lab').get(0).setAttribute('opacity',0);
	$('#notice_lab_up').get(0).setAttribute('opacity',1);
	var y = 0;
	loopInterval = setInterval(setPos,6);
	function setPos(){
		$('#notice_card').get(0).setAttribute('transform','translate(0,' + y + ')');
		y -= 1;
		if(y == -50){
			clearInterval(loopInterval);
			$('#notice_card').get(0).setAttribute('transform','translate(0,-50)');
		}
	}
}).mouseleave(function(){
	$('#notice_all').get(0).setAttribute('transform','translate(-100,-100)');
	$('#notice_all').parent().get(0).setAttribute('transform','translate(100,100),scale(0.9,1.1)');
	$('#notice_lab').get(0).setAttribute('opacity',1);
	$('#notice_lab_up').get(0).setAttribute('opacity',0);
	$('#notice_card').get(0).setAttribute('transform','translate(0,0)');
	clearInterval(loopInterval);
});
/*disk*/
var diskSizeInt,diskRotateInt,diskBlinkInt;
$('#disk').mouseenter(function(){
	$('#disk_circle').get(0).setAttribute('fill','url(#grad1)');
	var x = 25;
	var width = 150;
	diskSizeInt = setInterval(setSize,20);
	function setSize(){
		$('#disk_rect').get(0).setAttribute('x',x);
		$('#disk_rect').get(0).setAttribute('width',width);
		x += 1;
		width -= 2;
		if(x == 35){
			clearInterval(diskSizeInt);
			$('#disk_rect').get(0).setAttribute('x',35);
			$('#disk_rect').get(0).setAttribute('width',130);
		}
	}
	var ang = 0;
	diskRotateInt = setInterval(setAng,5);
	function setAng(){
		$('#disk_circle').get(0).setAttribute('transform','rotate(' + ang + ')');
		ang += 1;
	}
	var op = 1,add = false;
	diskBlinkInt = setInterval(setOp,50);
	function setOp(){
		$('#disk_blink_point').get(0).setAttribute('opacity',op);
		if(add){
			op += 0.1;
		}else{
			op -= 0.1;
		}

		if(op >= 1){
			add = false;
		}else if(op <=0){
			add = true;
		}
	}
}).mouseleave(function(){
	clearInterval(diskSizeInt);
	$('#disk_rect').get(0).setAttribute('x',25);
	$('#disk_rect').get(0).setAttribute('width',150);
	clearInterval(diskRotateInt);
	$('#disk_circle').get(0).setAttribute('fill','white');
	$('#disk_circle').get(0).setAttribute('transform','rotate(0)');
	clearInterval(diskBlinkInt);
	$('#disk_blink_point').get(0).setAttribute('opacity',1);
});

/*sysinfo*/
$('#sysinfo').mouseenter(function(){
	var pe_sc = 1,sys_tr = 0,sys_sc = 1;
	var int = setInterval(setInt,10);
	function setInt(){
		$('#penguin').get(0).setAttribute('transform','translate(200,200) scale(' + pe_sc + ',' + pe_sc + ')');
		$('#syspop').get(0).setAttribute('transform','translate(' + sys_tr + ',' + sys_tr + ') scale(' + sys_sc + ',' + sys_sc + ')');
		pe_sc -= 0.1;
		sys_tr += 2;
		sys_sc += 0.12;
		if(pe_sc <= 0){
			clearInterval(int);
			$('#penguin').get(0).setAttribute('transform','translate(200,200) scale(0,0)');
			$('#syspop').get(0).setAttribute('transform','translate(20,20) scale(2.2,2.2)');
		}
	}
}).mouseleave(function(){
	var pe_sc = 0,sys_tr = 20,sys_sc = 2.2;
	var int = setInterval(setInt,10);
	function setInt(){
		$('#penguin').get(0).setAttribute('transform','translate(200,200) scale(' + pe_sc + ',' + pe_sc + ')');
		$('#syspop').get(0).setAttribute('transform','translate(' + sys_tr + ',' + sys_tr + ') scale(' + sys_sc + ',' + sys_sc + ')');
		pe_sc += 0.1;
		sys_tr -= 2;
		sys_sc -= 0.12;
		if(pe_sc >= 1){
			clearInterval(int);
			$('#penguin').get(0).setAttribute('transform','translate(200,200) scale(1,1)');
			$('#syspop').get(0).setAttribute('transform','translate(0,0) scale(1,1)');
		}
	}
});


/*ac*/
var acSizeInt,acRotateInt;
$('#ac_set').mouseenter(function(){
	var ang = 0,size = 240,add = false;
	acRotateInt = setTimeout(setAng,50);
	function setAng(){
		ang += 5;
		if(ang >= 360){
			ang = 0;
		}
		$('#access').get(0).setAttribute('transform','translate(32,32) scale(' + size/300 + ',' + size/300 + ') rotate(' + ang + ')')
		if(!((ang)%90)){
			acRotateInt = setTimeout(setAng,600);
		}else{
			acRotateInt = setTimeout(setAng,50);
		}
	}
	acSizeInt = setTimeout(setSize,50);
	function setSize(){
		if(add){
			size += 3;
		}else{
			size -= 3;
		}
		if(size >= 240){
			size = 240;
			add = false;
			acSizeInt = setTimeout(setSize,600)
		}else if(size <= 213){
			add = true;
			size = 213;
			acSizeInt = setTimeout(setSize,50)
		}else{
			acSizeInt = setTimeout(setSize,50)
		}
	}
}).mouseleave(function(){
	clearTimeout(acSizeInt);
	clearTimeout(acRotateInt);
	$('#access').get(0).setAttribute('transform','translate(32,32) scale(0.8,0.8) rotate(0)')
});

/*dnscdn*/
$('#dns_cdn').mouseenter(function(){
	var scx=1,scy=1;
	loopInterval = setInterval(setScale,5);
	function setScale(){
		$('#fire').get(0).setAttribute('transform','translate(100,155) scale(' + scx + ',' + scy + ')');
		scx += 0.01;
		scy += 0.015;
		if(scx >= 1.3){
			scx=1;
			scy=1;
			$('#fire').get(0).setAttribute('transform','translate(100,155) scale(1,1)');
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval)
	$('#fire').get(0).setAttribute('transform','translate(100,150) scale(1,1)');
});

/*openvpn*/
$('#openvpn').mouseenter(function(){
	var ang = 0,gna = 0;
	loopInterval = setInterval(setAng,3);
	function setAng(){
		$('#vpn_back').get(0).setAttribute('transform','rotate(' + ang + ')');
		$('#vpn_front').get(0).setAttribute('transform','rotate(' + gna + ')');
		ang += 1;
		gna -= 1;
		if(ang >= 180){
			clearInterval(loopInterval);
			$('#vpn_back').get(0).setAttribute('transform','rotate(180)');
			$('#vpn_front').get(0).setAttribute('transform','rotate(-180)');
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	var ang = 180,gna = -180;
	var rotateInterval = setInterval(setAng,1);
	function setAng(){
		$('#vpn_back').get(0).setAttribute('transform','rotate(' + ang + ')');
		$('#vpn_front').get(0).setAttribute('transform','rotate(' + gna + ')');
		ang += 2;
		gna -= 2;
		if(ang >= 360){
			clearInterval(rotateInterval);
			$('#vpn_back').get(0).setAttribute('transform','rotate(360)');
			$('#vpn_front').get(0).setAttribute('transform','rotate(-360)');
		}
	}
});

/*ping*/
var blinkInterval,translateInterval,untranslateInterval;
$('#ping_watchdog').mouseenter(function(){
	clearInterval(untranslateInterval);
	$('#watch_group').get(0).setAttribute('transform','translate(0,0)');
	var op = 1,add = false;
	blinkInterval = setInterval(setOp,10);
	function setOp(){
		$('#blink_points').get(0).setAttribute('opacity',op);
		if(add){
			op += 0.1;
		}else{
			op -= 0.1;
		}
		if(op >= 1){
			op = 1;
			add = false;
		}else if(op <=0){
			op = 0;
			add = true;
		}
	}
	var x=0,y=0,add1 = false,add2 = false,v1=1,v2=1;
	translateInterval = setInterval(setPosition,25);
	function setPosition(){
		$('#watch_group').get(0).setAttribute('transform','translate(' + x + ',' + y + ')');
		if(!add1){
			x -= v1;
		}else{
			x += v1;
		}
		if(!add2){
			y -= v2;
		}else{
			y += v2;
		}
		if(x<=-15){
			add1 = true;
			x = -15;
			v2 = 0.5;
		}else if(x >= 10){
			clearInterval(translateInterval);
			$('#watch_group').get(0).setAttribute('transform','translate(10,-27)');
		}
	}
}).mouseleave(function(){
	clearInterval(blinkInterval);
	$('#blink_points').get(0).setAttribute('opacity',1);
	clearInterval(translateInterval);
	$('#watch_group').get(0).setAttribute('transform','translate(10,-27)');
	var x=10,y=-27;
	untranslateInterval = setInterval(setPosition,25);
	function setPosition(){
		$('#watch_group').get(0).setAttribute('transform','translate(' + x + ',' + y + ')');
		x -= 1;
		y += 2.7;
		if(x == 0){
			clearInterval(untranslateInterval);
			$('#watch_group').get(0).setAttribute('transform','translate(0,0)');
		}
	}
});

/*shadowvpn*/

/*shadowsocks*/
var trInt,untrInt;
$('#shadowsocks').mouseenter(function(){
	clearInterval(untrInt);
	var dis = 0,op = 0;
	trInt = setInterval(setTra,30);
	function setTra(){
		$('#socks_back').get(0).setAttribute('opacity',op);
		$('#socks_front').get(0).setAttribute('transform','translate(' + dis + ',-' + dis + ')')
		op += 0.1;
		dis += 10;
		if(dis >= 150){
			clearInterval(trInt);
			$('#socks_front').get(0).setAttribute('transform','translate(150,-150)')
			$('#socks_back').get(0).setAttribute('opacity',1);
			setTimeout(function(){
				$('#socks_front').get(0).setAttribute('transform','translate(-160,160)')
			},50);
		}
	}
}).mouseleave(function(){
	clearInterval(trInt);
	$('#socks_front').get(0).setAttribute('transform','translate(150,-150)')
	$('#socks_back').get(0).setAttribute('opacity',1);
	setTimeout(function(){
		$('#socks_front').get(0).setAttribute('transform','translate(-160,160)')
	},50);
	var dis = 160,op = 1;
	untrInt = setInterval(setTra,30);
	function setTra(){
		$('#socks_back').get(0).setAttribute('opacity',op);
		$('#socks_front').get(0).setAttribute('transform','translate(-' + dis + ',' + dis + ')')
		op -= 0.1;
		dis -= 10;
		if(dis <= 0){
			clearInterval(untrInt);
			$('#socks_front').get(0).setAttribute('transform','translate(0,0)')
			$('#socks_back').get(0).setAttribute('opacity',0);
		}
	}
});

/*adbyby*/
$('#adbyby_save').mouseenter(function(){
	var ang1 = 0,ang2 = 0,v = 4;
	var rotateInt = setInterval(setAng,20);
	function setAng(){
		$('#ad_up').get(0).setAttribute('transform','translate(60,100) rotate(' + ang1 + ')');
		$('#ad_down').get(0).setAttribute('transform','translate(30,120) rotate(' + ang2 + ')');
		ang1 -= v;
		ang2 += v;
		v -= 0.25;
		if(v <= 0.5){
			v=0.5;
		}
		if(ang1 <= -20){
			clearInterval(rotateInt)
			$('#ad_up').get(0).setAttribute('transform','translate(60,100) rotate(-20)');
			$('#ad_down').get(0).setAttribute('transform','translate(30,120) rotate(20)');
		}
	}
}).mouseleave(function(){
	$('#ad_up').get(0).setAttribute('transform','translate(60,100) rotate(0)');
	$('#ad_down').get(0).setAttribute('transform','translate(30,120) rotate(0)');
});

/*wol*/
$('#wol').mouseenter(function(){
	var ang = 0,add = true;
	loopInterval = setInterval(setAng,5);
	function setAng(){
		$('#alarm').get(0).setAttribute('transform','translate(100,30) rotate(' + ang + ') scale(0.9,0.9)')
		if(add){
			ang += 1;
		}else{
			ang -= 1;
		}
		if(ang <= -30){
			add = true;
		}else if(ang >= 30){
			add = false;
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#alarm').get(0).setAttribute('transform','translate(100,30) scale(0.9,0.9)')
});

/*bdusage*/
$('#bandwidth_usage').mouseenter(function(){
	var dash = 0;
	loopInterval = setInterval(setDash,5);
	function setDash(){
		$('#usage_line').get(0).setAttribute('stroke-dasharray','' + dash + ',10000');
		dash += 1;
		if(dash >= 220){
			clearInterval(loopInterval);
			var op = 0;
			var opInter = setInterval(setOp,30);
			function setOp(){
				$('#usage_back').get(0).setAttribute('opacity',op);
				op += 0.1;
				if(op >= 0.5){
					clearInterval(opInter);
					$('#usage_back').get(0).setAttribute('opacity',0.5);
				}
			}
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#usage_line').get(0).setAttribute('stroke-dasharray','');
	var op = 0.5;
	var opInter = setInterval(setOp,30);
	function setOp(){
		$('#usage_back').get(0).setAttribute('opacity',op);
		op -= 0.1;
		if(op <= 0){
			clearInterval(opInter);
			$('#usage_back').get(0).setAttribute('opacity',0);
		}
	}
});

/*bddis*/
$('#bddis').mouseenter(function(){
	$('#rotate_line').get(0).setAttribute('x2',90);
	$('#static_line').get(0).setAttribute('x2',90);
	$('#scale_arch').get(0).setAttribute('r',90);
	var ang = 10; add = true;
	loopInterval = setInterval(setAng,5);
	function setAng(){
		$('#rotate_back').get(0).setAttribute('transform','rotate(' + ang + ')');
		$('#rotate_line').get(0).setAttribute('transform','rotate(' + ang + ')');
		if(add){
			ang += 1;
		}else{
			ang -= 1;
		}
		if(ang >= 80){
			add = false;
		}else if(ang <= 0){
			clearInterval(loopInterval);
			$('#rotate_back').get(0).setAttribute('transform','rotate(0)');
			$('#rotate_line').get(0).setAttribute('transform','rotate(0)');

		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#rotate_line').get(0).setAttribute('x2',80);
	$('#static_line').get(0).setAttribute('x2',80);
	$('#scale_arch').get(0).setAttribute('r',80);
	$('#rotate_back').get(0).setAttribute('transform','rotate(0)');
	$('#rotate_line').get(0).setAttribute('transform','rotate(0)');
});

/*usb_mod*/
$('#usb_tethering_modem').mouseenter(function(){
	var op = 0,add = true;
	loopInterval = setInterval(setOp,50);
	function setOp(){
		$('#usb_icon').get(0).setAttribute('opacity',op);
		if(add){
			op += 0.1;
		}else{
			op -= 0.1;
		}
		if(op >= 1){
			add = false;
		}else if(op <= 0){
			add = true;
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#usb_icon').get(0).setAttribute('opacity',0);
});

/*wifi_spectrum*/
$('#wifi_spectrum').mouseenter(function(){
	var point1 = 0,point2 = 0;
	loopInterval = setInterval(setHighest,5);
	function setHighest(){
		$('#spec_line_dash').get(0).setAttribute('d','M 40,160 q 50,' + point1 + ' 100,0');
		$('#spec_line_solid').get(0).setAttribute('d','M 60,160 q 55,' + point2 + ' 110,0');
		point1 -= 2.5;
		point2 -= 1.5;
		if(point1 <= -250){
			clearInterval(loopInterval);
			$('#spec_line_dash').get(0).setAttribute('d','M 40,160 q 50,-250 100,0');
			$('#spec_line_solid').get(0).setAttribute('d','M 60,160 q 55,-150 110,0');
			var op1 = 0,op2 = 0;
			var opInt = setInterval(setOp,10);
			function setOp(){
				$('#spec_back_dash').get(0).setAttribute('opacity',op1);
				$('#spec_back_solid').get(0).setAttribute('opacity',op2);
				op1 += 0.1;
				op2 += 0.1;
				if(op1 >= 0.5){
					clearInterval(opInt);
					$('#spec_back_dash').get(0).setAttribute('opacity','0.5');
					$('#spec_back_solid').get(0).setAttribute('opacity','0.5');
				}
			}
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#spec_line_dash').get(0).setAttribute('d','M 40,160 q 50,-250 100,0');
	$('#spec_line_solid').get(0).setAttribute('d','M 60,160 q 55,-150 110,0');
	$('#spec_back_dash').get(0).setAttribute('opacity','0');
	$('#spec_back_solid').get(0).setAttribute('opacity','0');
});

/*wifi-client*/
var opInter,archInter;
$('#wifi_client').mouseenter(function(){
	var op1 = 1,op2 = 1,add1 = false,add2 = false;
	opInter = setInterval(setOp,10);
	function setOp(){
		$('#sm_point1').get(0).setAttribute('opacity',op1);
		$('#sm_point2').get(0).setAttribute('opacity',op2);
		if(add1){
			op1 += 0.1;
		}else{
			op1 -= 0.1;
		}
		if(op1 <= 0){
			add1 = true;
		}else if(op1 >= 1){
			add1 = false;
		}

		if(add2){
			op2 += 0.01;
		}else{
			op2 -= 0.01;
		}
		if(op2 <= 0){
			add2 = true;
		}else if(op2 >= 1){
			add2 = false;
		}
	}

	var r0 = 0,r1 = 20,r2 = 40,r3 = 60, r4 = 80;
	var opa0 = 100,opa1 = 80,opa2 = 60,opa3 = 40,opa4 = 20;
	archInter = setInterval(setR,50);
	function setR(){
		$('#arch0').get(0).setAttribute('opacity',opa0/100);
		$('#arch1').get(0).setAttribute('opacity',opa1/100);
		$('#arch2').get(0).setAttribute('opacity',opa2/100);
		$('#arch3').get(0).setAttribute('opacity',opa3/100);
		$('#arch4').get(0).setAttribute('opacity',opa4/100);
		$('#arch0').get(0).setAttribute('r',r0);
		$('#arch1').get(0).setAttribute('r',r1);
		$('#arch2').get(0).setAttribute('r',r2);
		$('#arch3').get(0).setAttribute('r',r3);
		$('#arch4').get(0).setAttribute('r',r4);
		r0 += 1;
		r1 += 1;
		r2 += 1;
		r3 += 1;
		r4 += 1;
		if(r0 >= 100){
			r0 = 0;
		}
		if(r1 >= 100){
			r1 = 0;
		}
		if(r2 >= 100){
			r2 = 0;
		}
		if(r3 >= 100){
			r3 = 0;
		}
		if(r4 >= 100){
			r4 = 0;
		}
		opa0 -= 1;
		opa1 -= 1;
		opa2 -= 1;
		opa3 -= 1;
		opa4 -= 1;
		if(opa0 <= 0){
			opa0 = 100;
		}
		if(opa1 <= 0){
			opa1 = 100;
		}
		if(opa2 <= 0){
			opa2 = 100;
		}
		if(opa3 <= 0){
			opa3 = 100;
		}
		if(opa4 <= 0){
			opa4 = 100;
		}
	}
}).mouseleave(function(){
	clearInterval(opInter);
	$('#sm_point1').get(0).setAttribute('opacity',1);
	$('#sm_point2').get(0).setAttribute('opacity',1);
	clearInterval(archInter);
	$('#arch0').get(0).setAttribute('opacity',0);
	$('#arch1').get(0).setAttribute('opacity',0);
	$('#arch2').get(0).setAttribute('opacity',1);
	$('#arch3').get(0).setAttribute('opacity',1);
	$('#arch4').get(0).setAttribute('opacity',1);
	$('#arch0').get(0).setAttribute('r',0);
	$('#arch1').get(0).setAttribute('r',20);
	$('#arch2').get(0).setAttribute('r',40);
	$('#arch3').get(0).setAttribute('r',60);
	$('#arch4').get(0).setAttribute('r',80);
});

/*ap*/
var apArchInterval;
$('#wire_ap').mouseenter(function(){
	var op1=0,op2=0,op3=0;
	apArchInterval = setInterval(setArch,500);
	function setArch(){
		$('#ap_arch1').get(0).setAttribute('opacity',op1);
		$('#ap_arch2').get(0).setAttribute('opacity',op2);
		$('#ap_arch3').get(0).setAttribute('opacity',op3);
		if(op1 == 0 && op2 == 0 && op3 == 0){
			op1 = 1;
		}else if(op1 == 1 && op2 == 0 && op3 == 0){
			op2 = 1;
		}else if(op1 == 1 && op2 == 1 && op3 == 0){
			op3 = 1;
		}else if(op1 == 1&& op2 == 1 && op3 == 1){
			op1 = 0;
			op2 = 0;
			op3 = 0;
		}
	}
}).mouseleave(function(){
	clearInterval(apArchInterval);
	$('#ap_arch1').get(0).setAttribute('opacity',1);
	$('#ap_arch2').get(0).setAttribute('opacity',1);
	$('#ap_arch3').get(0).setAttribute('opacity',1);
});

/*speed_test*/
$('#speed_test').mouseenter(function(){
	var ang = 30,add = false;
	loopInterval = setInterval(setAng,5);
	function setAng(){
		$('#dash_arrow').get(0).setAttribute('transform','translate(100,140) rotate(' + ang + ')')
		if(!add){
			ang -= 1;
		}else{
			ang += 1;
		}
		if(ang >= 30){
			ang = 30;
			add = false;
			clearInterval(loopInterval);
			$('#dash_arrow').get(0).setAttribute('transform','translate(100,140) rotate(30)')
		}else if(ang <= -40){
			ang = -40;
			add = true;
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#dash_arrow').get(0).setAttribute('transform','translate(100,140) rotate(30)')
});

/*quotas*/
var pathInterval2,pathInterval1;
$('#quotas').mouseenter(function(){
	(function(){
		var ctr1 = -30;
		var ctr2 = 24;
		var down = true;
		var position = -5;
		var y = 0;
		var sum = 0;
		setInterval(function(){
			position = Math.floor(Math.random()*20) - 10;
			y = $('#quotas_path1').get(0).getAttribute('transform').replace('translate(0,','');
			y = parseInt(y.replace(')',''));
		},1000);
		pathInterval1 = setInterval(setD,10);
		function setD(){
			$('#quotas_path1').get(0).setAttribute('d','M158,200H42v-84c56,' + ctr1 + ',68,' + ctr2 + ',116-5V200z')
			$('#quotas_path1').get(0).setAttribute('transform','translate(0,' + y + ')')
			if(down){
				ctr1 += 1;
				ctr2 -= 1;
			}else{
				ctr1 -= 1;
				ctr2 += 1;
			}
			if(ctr1 >= 24 || ctr2 <= -30){
				down = false;
			}else if(ctr1 <= -30 || ctr2 >= 24){
				down = true;
			}

			if(y > position){
				sum = y-position;
				var step = sum/5;
				y = y-step;
			}else if(y < position){
				sum = position - y;
				var step = sum/5;
				y = y + step;
			}else{
				y = y-10;
			}
		}
	})();
	(function(){
		var ctr1 = -30;
		var ctr2 = 24;
		var down = true;
		var position = -15;
		var y = 0;
		var sum = 0;
		setInterval(function(){
			position = Math.floor(Math.random()*20) - 10;
			y = $('#quotas_path2').get(0).getAttribute('transform').replace('translate(0,','');
			y = parseInt(y.replace(')',''));
		},1000);
		pathInterval2 = setInterval(setD,20);
		function setD(){
			$('#quotas_path2').get(0).setAttribute('d','M158,200H42v-84c56,' + ctr1 + ',68,' + ctr2 + ',116-5V200z')
			$('#quotas_path2').get(0).setAttribute('transform','translate(0,' + y + ')')
			if(down){
				ctr1 += 1;
				ctr2 -= 1;
			}else{
				ctr1 -= 1;
				ctr2 += 1;
			}
			if(ctr1 >= 24 || ctr2 <= -30){
				down = false;
			}else if(ctr1 <= -30 || ctr2 >= 24){
				down = true;
			}

			if(y > position){
				sum = y-position;
				var step = sum/5;
				y = y-step;
			}else if(y < position){
				sum = position - y;
				var step = sum/5;
				y = y + step;
			}else{
				y = y-10;
			}
		}
	})();
}).mouseleave(function(){
	clearInterval(pathInterval1);
	clearInterval(pathInterval2);
	$('#quotas_path1').get(0).setAttribute('d','M158,200H42v-84c56,-30,68,24,116-5V200z');
	$('#quotas_path1').get(0).setAttribute('transform','translate(0,0)');
	$('#quotas_path2').get(0).setAttribute('d','M158,200H42v-84c56,-30,68,24,116-5V200z');
	$('#quotas_path2').get(0).setAttribute('transform','translate(0,0)');
});

/*restriction*/
$('#restriction').mouseenter(function(){
	var op = 0;
	loopInterval = setInterval(setOp,50);
	function setOp(){
		$('#res_user').get(0).setAttribute('opacity',op);
		op += 0.1;
		if(op >= 1){
			$('#res_user').get(0).setAttribute('opacity',1);
			clearInterval(loopInterval);
		}
	}
}).mouseleave(function(){
	clearInterval(loopInterval);
	$('#res_user').get(0).setAttribute('opacity',0);

});

/*firewall*/
var fireOpInt,brickInterval,brickInterval2;
$('#firewall_extra').mouseenter(function(){
	var op = 1;
	fireOpInt = setInterval(setOp,50);
	function setOp(){
		$('#firewall_fire').get(0).setAttribute('opacity',op);
		op -= 0.1;
		if(op <= 0){
			$('#firewall_fire').get(0).setAttribute('opacity',0);
			clearInterval(fireOpInt);
		}
	}

	var x1=-100,y1=-100;
	var x2=100,y2=-100;
	brickInterval = setInterval(setBrick,5);
	function setBrick(){
		$('#brick1').get(0).setAttribute('transform','translate(' + x1 + ',' + y1 + ')');
		$('#brick2').get(0).setAttribute('transform','translate(' + x2 + ',' + y2 + ')');
		x1 += 1;
		y1 += 1;
		x2 -= 1;
		y2 += 1;
		if(x1 == 0){
			$('#brick1').get(0).setAttribute('transform','translate(0,0)');
			$('#brick2').get(0).setAttribute('transform','translate(0,0)');
			clearInterval(brickInterval);
			var x3 = -100,y3 = -100;
			var x4 = 100,y4 = -100;
			brickInterval2 = setInterval(setBrike2,5);
			function setBrike2(){
				$('#brick3').get(0).setAttribute('transform','translate(' + x3 + ',' + y3 + ')');
				$('#brick4').get(0).setAttribute('transform','translate(' + x4 + ',' + y4 + ')');
				x3 += 1;
				y3 += 1;
				x4 -= 1;
				y4 += 1;
				if(x3 == 0){
					clearInterval(brickInterval2);
					$('#brick3').get(0).setAttribute('transform','translate(0,0)');
					$('#brick4').get(0).setAttribute('transform','translate(0,0)');
				}
			}
		}
	}
}).mouseleave(function(){
	clearInterval(fireOpInt);
	$('#firewall_fire').get(0).setAttribute('opacity',1);
	clearInterval(brickInterval);
	clearInterval(brickInterval2);
	$('#brick1').get(0).setAttribute('transform','translate(-100,-100)');
	$('#brick2').get(0).setAttribute('transform','translate(100,-100)');
	$('#brick3').get(0).setAttribute('transform','translate(-100,-100)');
	$('#brick4').get(0).setAttribute('transform','translate(100,-100)');
});

/*record*/
var reSizeInter,reRotateInter;
$('#lan_net_record').mouseenter(function(){
	var size = 10,ang1 = 30,ang2 = -600;
	reSizeInter = setInterval(setSize,50);
	function setSize(){
		$('#record_clock').get(0).setAttribute('transform','translate(140,140) scale(' + size/10 + ',' + size/10 + ')');
		size += 1;
		if(size >= 16){
			clearInterval(reSizeInter);
			$('#record_clock').get(0).setAttribute('transform','translate(140,140) scale(1.5,1.5)');
			reRotateInter = setInterval(setAng,5);
			function setAng(){
				$('#record_long_line').get(0).setAttribute('transform','rotate(' + ang1 + ')');
				$('#record_short_line').get(0).setAttribute('transform','rotate(' + ang2/10 + ')');
				ang1 += 1;
				ang2 += 1;
				if(ang1 >= 3630){
					$('#record_long_line').get(0).setAttribute('transform','rotate(30)');
					clearInterval(reRotateInter);
				}
			}
		}
	}

}).mouseleave(function(){
	clearInterval(reSizeInter);
	$('#record_clock').get(0).setAttribute('transform','translate(140,140)');
	clearInterval(reRotateInter);
	$('#record_long_line').get(0).setAttribute('transform','rotate(30)');
	$('#record_short_line').get(0).setAttribute('transform','rotate(-60)');
});

/*conntrack*/
var trackInt1,trackInt2,trackInt3;
$('#conntrack').mouseenter(function(){
	clearInterval(trackInt1);
	clearInterval(trackInt2);
	clearInterval(trackInt3);
	$('#conList1').get(0).setAttribute('transform','translate(5,0)');
	$('#conList2').get(0).setAttribute('transform','translate(-5,0)');
	$('#conList3').get(0).setAttribute('transform','translate(5,0)');
	$('#conList4').get(0).setAttribute('transform','translate(-5,0)');
	$('#conList5').get(0).setAttribute('transform','translate(5,0)');
	$('#conList6').get(0).setAttribute('transform','translate(-5,0)');
	trackInt1 = setTimeout(function(){
		$('#conList1').get(0).setAttribute('transform','translate(0,0)');
		$('#conList2').get(0).setAttribute('transform','translate(0,0)');
		trackInt2 = setTimeout(function(){
			$('#conList5').get(0).setAttribute('transform','translate(0,0)');
			$('#conList6').get(0).setAttribute('transform','translate(0,0)');
			trackInt3 = setTimeout(function(){
				$('#conList3').get(0).setAttribute('transform','translate(0,0)');
				$('#conList4').get(0).setAttribute('transform','translate(0,0)');
			},500);
		},500);
	},500);
});