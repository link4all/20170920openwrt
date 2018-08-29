var tcp_delay,
		downLoadSpeedArr = [],
		upLoadSpeedArr = [],
		downLoadSpeed,upLoadSpeed,downLoadSpeedOri,upLoadSpeedOri;

var downloadPlot = document.getElementById('downLoadPlot'),
		uploadPlot = document.getElementById('upLoadPlot'),
		arrow = document.getElementById('arrow'),
		downloadtext = document.getElementById('downloadtext'),
		uploadtext = document.getElementById('uploadtext'),
		maxData,
		downloadPoint = [],
		uploadPoint = [],
		downloadChartStr,
		downloadPolyStr,
		uploadChartStr,
		uploadPolyStr;
var rect_btn = document.getElementById('rect_btn');
var rotateInterval;
rect_btn.onclick = setLoadingAnimate;

setSVGSize();
function getTestData(){
	var dev = $('#dev_select').val();
	$('#loading-text').html('正在初始化查询...');
	initTest();
	function initTest(){
		$.post('/','app=speed-test&action=do_speedtest&dev=' + dev,function(data){
			if(data.status){
				//正在初始化查询，还没有数据可输出
				//TODO处理延迟动画
				$('#loading-text').html('查询失败，正在重建查询...');
				setTimeout(initTest,500);
				return;
			}else{
				var i=1;
				function getLine(){
					if(i < 27){
						$.post('/','app=speed-test&action=get_line&dev=' + dev + '&line=' + i,function(data){
							if(!data.status){
								//立即有数据反馈
								if(i == 1){
									$('#loading-text').html('正在获取用户信息...');
								}
								if(i == 2){
									//停止上一个动画，展示ip信息等
									//开始加载i=3的等待动画
									$('#loading-text').html('正在获取测速点信息...');
									showUserInfo(data);
									loadingServerInfo();
								}
								if(i == 3){
									//停止正在载入什么的动画，展示服务信息
									$('#loading-text').html('Ping...');

									//开始加载ping的等待动画
									showServerInfo(data);
									loadingPing();									
								}
								if(i == 4 && data.tcp_delay){
									tcp_delay = data.tcp_delay;
									//TODO Ping动画
									showPingResult(tcp_delay);
									$('#loading-text').html('开始下载数据...');
									hideBtn();
								}
								if(i >= 5 && i <= 14){
									var speed = parseSpeedData(data.d_speed);
									downLoadSpeedArr.push(speed);
									$('#loading-text').html('正在测试下载速度...');
									//TODO 放大圆环到dash+chart的高度，逐渐降低透明度最后隐藏
									//TODO 先显示chart+dash，透明度提高到1
									//绘制下载曲线图
									updateDownloadChart();
									updateDash(speed);
									$('#downloadtext').addClass('hideshowalter')
								}
								if(i == 15){
									var speed = parseSpeedData(data.speed);
									downLoadSpeedOri = data.speed;
									downLoadSpeed = speed;
									downLoadSpeedArr.push(speed);
									$('#loading-text').html('开始上传数据...');
									updateDownloadChart();
									//绘制下载测试完成的动画
									finishDownloadChart();
									$('#downloadtext').removeClass('hideshowalter')

								}
								if(i >= 16 && i <= 25 ){
									var speed = parseSpeedData(data.u_speed);
									$('#loading-text').html('正在测试上传速度...');
									upLoadSpeedArr.push(speed);
									//绘制上传曲线图
									updateUploadChart();
									updateDash(speed);
									$('#uploadtext').addClass('hideshowalter')
								}if(i == 26){
									var speed = parseSpeedData(data.speed);
									upLoadSpeedOri = data.speed;
									upLoadSpeed = speed;
									upLoadSpeedArr.push(speed);
									updateUploadChart();
									//绘制测试完成的动画
									finishUploadChart();
									$('#uploadtext').removeClass('hideshowalter')
									//TODO 缩小chart+dash减低透明度，最后隐藏
									//TODO 显示btn，增加不透明度，最后变回初始化的样子。
								}
								i++;
								setSVGSize();
								Ha.setFooterPosition();
							}else{
								//当前没有下一行数据
								//TODO处理延迟动画
							}
						},'json');
						setTimeout(getLine,500);
					}else{
						//执行完了
						//TODO处理完结动画
						finishTest();
						$('#loading-text').html('测速完成，点击按钮重新测速');
					}
				}
				setTimeout(getLine,500);
			}
		},'json');
	}
}

function updateDownloadChart(){
	
	downloadPoint = parsePoints(downLoadSpeedArr,false);
	downloadChartStr = parseChartStr(downloadPoint);
	downloadPolyStr = parsePolyStr(downloadPoint);
	setChartPoints();
	downloadtext.setAttribute('fill','green');
	$('#transLine').addClass('dashline');
	$('#dashbg').attr('opacity',1);
}

function updateUploadChart(){
	
	uploadPoint = parsePoints(upLoadSpeedArr,true);
	uploadChartStr = parseChartStr(uploadPoint);
	uploadPolyStr = parsePolyStr(uploadPoint);
	setChartPoints(true);
	uploadtext.setAttribute('fill','green');
	$('#transLine').addClass('backdashline');
	$('#dashbg').attr('opacity',1);
}
function updateDash(speed){
	speed = parseFloat(speed);
	var curAngle = arrow.getAttribute('transform');
	curAngle = curAngle.replace('rotate(','');
	curAngle = curAngle.replace(')','');
	curAngle = parseFloat(curAngle);
	var angle = -120;
	var	speedstr = addPlaceholder0(speed);
	
	if(speed > 0 && speed <= 1){
		angle = speed*30 - 120;
	}else if(speed >1 && speed <= 5){
		angle = (speed-1)/4*30 - 90;
	}else if(speed >5 && speed <= 10){
		angle = (speed-5)/5*30 - 60;
	}else if(speed > 10 && speed <=30){
		angle = (speed-10)*3 - 30;
	}else if(speed > 30 && speed <=50){
		angle = (speed-30)/2*3 + 30;
	}else if(speed > 50 && speed <= 100){
		angle = (speed-50)/5*6 + 60;
	}
	var i = curAngle;
	var rotateInt = setInterval(setAngle,2);
	function setAngle(){
		if(curAngle > angle){
			if(i <= angle){
				arrow.setAttribute('transform','rotate(' + angle + ')');
				clearInterval(rotateInt);
			}else{
				i = i-1;
				arrow.setAttribute('transform','rotate(' + i + ')');
			}
		}else if(curAngle < angle){
			if(i >= angle){
				arrow.setAttribute('transform','rotate(' + angle + ')');
				clearInterval(rotateInt);
			}else{
				i = i+1;
				arrow.setAttribute('transform','rotate(' + i + ')');
			}
		}
	}

	// $('#num').html(speedstr);
	setNum(speedstr);
}
function setNum(speed){
	var oriNum = $('#num').html().replace('.','');
	var curNum = speed.replace('.','');
	var oriArr = oriNum.split('');
	var curArr = curNum.split('');
	var inters = setInterval(setNumbers,30);
	function setNumbers(){
		if(oriArr.join('') != curArr.join('')){
			for(var i=0; i<4; i++){
				oriArr[i] = parseInt(oriArr[i]);
				curArr[i] = parseInt(curArr[i]);
				if(oriArr[i] > curArr[i]){
					oriArr[i] -= 1;
				}else if(oriArr[i] < curArr[i]){
					oriArr[i] += 1;
				}
				var str = '' + oriArr[0] + oriArr[1] + '.' + oriArr[2] + oriArr[3];
				$('#num').html(str);
			}
		}else{
			clearInterval(inters);
			$('#num').html(speed);
		}
	}
}

function finishDownloadChart(){
	downloadtext.setAttribute('fill','#ccc');
	$('#dashbg').attr('opacity',0);
	$('#downloadresult').html(downLoadSpeed + 'Mbps|' + downLoadSpeedOri);
	$('#transLine').removeClass('dashline');
}

function finishUploadChart() {
	uploadtext.setAttribute('fill','#ccc');
	$('#dashbg').attr('opacity',0);
	$('#uploadresult').html(upLoadSpeed + 'Mbps|' + upLoadSpeedOri);
	$('#transLine').removeClass('backdashline');
}

function finishTest(){
	rect_btn.onclick = setLoadingAnimate;
	$('#num').html('00.00');
	arrow.setAttribute('transform','rotate(-120)');
	stopBtnAni();
	rect_btn.setAttribute('opacity',1);
};

function parseSpeedData(data){
	var speed = (parseFloat(data)*8/1024).toFixed(2);
	return speed;
}

function showUserInfo(data){
	$('#ips').html(data ? data.ISP : '');
	$('#user_position').html(data ? (data.Lat + '|' + data.Lon) : '');
	$('#ip').html(data ? data.Your_IP : '');
}

function loadingServerInfo(){

}

function showServerInfo(data){
	$('#best_server_url').prop('href',data ? data.Best_Server_URL : '');
	$('#country_name').html(data ? (data.Country + ' ' + data.Name) : '');
	$('#dist').html(data? data.Dist : '');
	$('#server_position').html(data? (data.Lat + '|' + data.Lon) : '');
	$('#sponsor').html(data ? data.Sponsor : '');
	$('#servercount').html(data ? data.serverCount : '');
}

function loadingPing(){

}

function showPingResult(data){
	$('#pingresult').html(data || '');
	
}

function addPlaceholder0(num){
	num = num.toFixed(2);
	var str = '' + num;
	if(str.length<5){
		if(str.length == 4){
			if(num<10){
				str = '0' + str;
			}else{
				str = str + '0';
			}
		}else if(str.length == 3){
			str = '0' + str + '0';
		}else if(str.length == 2){
			str = str + '.00';
		}else if(str.length == 1){
			str = '0' + str + '.00';
		}
	}else{
		str = str.slice(0,6);
	}
	return str;
}


function parsePoints(data,isUp){
	if(!isUp){
		maxData = Math.max.apply(Math, data);
	}else{
		if(maxData < (Math.max.apply(Math, data))){
			maxData = Math.max.apply(Math, data);
			var downPoints = [];
			for(var i=0; i<downLoadSpeedArr.length; i++){
				var point = (-200 + 40*i) + ',' + (40 - 80*downLoadSpeedArr[i]/maxData);
				downPoints.push(point);
			}
			downloadChartStr = parseChartStr(downPoints);
			downloadPolyStr = parsePolyStr(downPoints);
			setChartPoints();
		}
	}
	var points = [];
	for(var i=0; i<data.length; i++){
		var point = (-200 + 40*i) + ',' + (40 - 80*data[i]/maxData);
		points.push(point);
	}
	return points;
}

function parseChartStr(points){
	var str = '';
	if(points.length>1){
		for(var i=0; i<points.length; i++){
			if(i==0){
				str += 'M' + points[i];
			}else{
				str += 'L' + points[i];
			}
		}
	}
	return str;
}

function parsePolyStr(points){
	var str = '-200,40 ';
	if(points.length > 1){
		for(var i=0; i<points.length; i++){
			str += points[i] + ' ';
		}
	}
	str += ((points.length-1) * 40 - 200) + ',40';
	return str;
}

function setChartPoints(isUp){
	if(!isUp){
		var downloadChart = downloadPlot.getElementsByTagName('path')[0];
		downloadChart.setAttribute('d',downloadChartStr);
		var downloadPoly = downloadPlot.getElementsByTagName('polygon')[0];
		downloadPoly.setAttribute('points',downloadPolyStr);
	}else{
		var uploadChart = uploadPlot.getElementsByTagName('path')[0];
		uploadChart.setAttribute('d',uploadChartStr);
		var uploadPoly = uploadPlot.getElementsByTagName('polygon')[0];
		uploadPoly.setAttribute('points',uploadPolyStr);
	}
}

//响应式
function setSVGSize(){
	//仪表盘
	var containerWidth = document.getElementById('svg_container').clientWidth;
	var dashbox = document.getElementById('dashbox');
	var dashboxContent = document.getElementById('dashboxContent');
	var fineWidth,fineHeight,scaleSize,noize;
	if(containerWidth > 800){
	  fineWidth = 800;
	  noize = 1;
	}else if(containerWidth <= 800 && containerWidth >= 750){
	  fineWidth = containerWidth;
	  noize = 1;
	}else if(containerWidth < 750){
	  fineWidth = containerWidth;
	  noize = 1.5;
	}
	fineHeight = fineWidth*3/5*noize;
	scaleSize = fineWidth/800*noize;
	dashbox.setAttribute('width',fineWidth);
	dashbox.setAttribute('height',fineHeight);
	dashboxContent.setAttribute('transform','translate(' + fineWidth/2 + ',' + fineHeight/2 + ') scale(' + scaleSize + ',' + scaleSize + ')');
	dashboxContent.setAttribute('opacity','1');

	// 显示表格图
	var chartbox = document.getElementById('chartbox');
	var chart = document.getElementById('chart');
	if(containerWidth >= 440){
		chartbox.setAttribute('width',400);
	  chart.setAttribute('transform','translate(200,40)');
	}else if(containerWidth < 440 && containerWidth > 40){
	  chartbox.setAttribute('width',(containerWidth-40));
	  chart.setAttribute('transform','translate(' + (containerWidth-40)/2 + ',40) scale(' + (containerWidth-40)/400 + ',' + (containerWidth-40)/400 + ')');
	}
}

function stopBtnAni(){
	clearInterval(rotateInterval);
	var btn_text = document.getElementById('btn_text');
	var btn_rect = document.getElementById('btn_rect');
	var inner = document.getElementById('inner-cir');
	inner.setAttribute('opacity',0);
	inner.setAttribute('stroke-dasharray','');
	btn_rect.setAttribute('stroke-dasharray','');
	btn_rect.setAttribute('transform','rotate(0)');
	var i=60,j=-30;
	var widthInterval = setInterval(setWidth,5);
	function setWidth(){
		if(i > 100){
			clearInterval(widthInterval);
			var n=30;var op = 0;
			rxInterval = setInterval(setRx,5)
			function setRx(){
				if(n < 10){
					btn_rect.setAttribute('rx',10);
					btn_text.setAttribute('opacity',1);
					clearInterval(rxInterval);
				}
				n--;
				op = op + 0.1;
				btn_rect.setAttribute('rx',n);
				btn_text.setAttribute('opacity',op);
			}
		}
		i += 1;
		j -= 0.5;
		btn_rect.setAttribute('width',i);
		btn_rect.setAttribute('x',j);
	}
}

function setBtnAni(){
	var btn_text = document.getElementById('btn_text');
	btn_text.setAttribute('opacity',0);
	var btn_rect = document.getElementById('btn_rect');
	var i=100,j=-50;
	var widthInterval = setInterval(setWidth,5);
	function setWidth(){
		if(i < 60){
			btn_rect.setAttribute('width',60);
			btn_rect.setAttribute('x',-30);
			clearInterval(widthInterval);
			var rxInterval = setInterval(setRx,5);
			var n=10;
			function setRx(){
				if(n > 30){
					btn_rect.setAttribute('rx',30);
					clearInterval(rxInterval);
					var inner = document.getElementById('inner-cir');
					inner.setAttribute('opacity',1);
					var outer = btn_rect;
					var r = 30;
				  var R = 20;
				  var len = 2*r*Math.PI;
				  var Len = 2*R*Math.PI;
				  var offset = len/6;
				  var Offset = Len/8;
				  var a=0,b=0;
				  var offsetInterval = setInterval(setOffset,50);
				  function setOffset(){
				    inner.setAttribute('stroke-dasharray',a);
				    outer.setAttribute('stroke-dasharray',b);
				    if(a < offset){
				      a += offset/20;
				    }else{
				      a = offset;
				      clearInterval(offsetInterval);
				    }
				    if(b < Offset){
				      b += Offset/20;
				    }else{
				      b = Offset;
				      clearInterval(offsetInterval);
				      rotateInterval = setInterval(setAngle,5);
						  var j=1,m=360;
						  function setAngle(){
						    inner.setAttribute('transform','rotate(' + j + ')');
						    outer.setAttribute('transform','rotate(' + m + ')');
						    j = j+0.5;
						    m = m-1;
						    if(j > 360){
						      j = 1;
						    }
						    if(m < 1){
						      m = 360;
						    }
						  }
				    }
				  }
				}
				n++;
				btn_rect.setAttribute('rx',n);
			}
		}
		i -= 1;
		j += 0.5;
		btn_rect.setAttribute('width',i);
		btn_rect.setAttribute('x',j);
	}
}

function hideBtn(){
	var i=1;
	var hideInterval = setInterval(setOp,50);
	function setOp(){
		if(i < 0){
			rect_btn.setAttribute('opacity',0);
			clearInterval(hideInterval);
		}else{
			i = i-0.1;
			rect_btn.setAttribute('opacity',i);
		}
	}
}

function setLoadingAnimate(){
	showUserInfo();
	showServerInfo();
	showPingResult();
	$('#downloadresult').html('');
	$('#uploadresult').html('');

	downLoadSpeedArr = [];
	upLoadSpeedArr = [];
	downloadChartStr = '';
	downloadPolyStr = '';
	uploadChartStr = '';
	uploadPolyStr = '';
	setChartPoints(true);
	setChartPoints(false);

	setBtnAni();
	rect_btn.onclick = null;
	getTestData();
}
Ha.setFooterPosition();