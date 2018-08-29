UI.byt = "bytes";
UI.Bu = "B";
UI.KB = "kB";
UI.MB = "MB";
UI.GB = "GB";
UI.TB = "TB";
UI.KB1 = "kByte";
UI.MB1 = "MByte";
UI.GB1 = "GByte";
UI.TB1 = "TByte";
UI.KBy = "kBytes";
UI.MBy = "MBytes";
UI.GBy = "GBytes";
UI.TBy = "TBytes";
UI.Kbs = "kbits/s";
UI.KBs = "kBytes/s";
UI.MBs = "MBytes/s";

setBrowserTimeCookie();

$(window).load(setCanvasHeight);

function setCanvasHeight(){
	var width = $(window).width();
	if(width >= 768){
		$('.canvas_container').empty();
		$('#total_container').append('<canvas id="my_total"></canvas>');
		$('#download_container').append('<canvas id="my_download" height="200"></canvas>');
		$('#upload_container').append('<canvas id="my_upload" height="200"></canvas>');
	}
}

var testAjax = getRequestObj();
if(!testAjax) { window.location = "no_ajax.sh"; }

var bndwS=new Object();

var ipMonitorIds;
var qosUploadMonitorIds;
var qosDownloadMonitorIds;


var uploadMonitors = null;
var downloadMonitors = null;
var tableUploadMonitor = null;
var tableDownloadMonitor = null;


var ipsWithData = [];
var qosDownloadClasses  = [];
var qosDownloadNames = [];
var qosUploadClasses  = [];
var qosUploadNames = [];

var definedUploadClasses = [];
var definedDownloadClasses = [];

var updateTotalPlot = null;
var updateUploadPlot = null;
var updateDownloadPlot = null;

var updateInProgress = false;
var plotsInitializedToDefaults = false;

var expandedWindows = [];
var expandedFunctions = [];

var updateInterval = null;

//清除定时器
function stopInterval()
{
	if(updateInterval != null)
	{
		clearInterval(updateInterval);
	}
}

window.onbeforeunload=stopInterval;//离开页面之前清除定时器



function trim(str)
{
	if ( !str )
	{
		return str;
	}
	return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');//去掉字符串前后空格
}

//缓存类
function BandwidthCookieContainer()
{
	this.prefix = "shellgui.bandwidth_display.";

	this.set = function(key, value)
	{
		var expires = new Date( new Date().getTime() + ( 86400 * 100 * 1000 /*100 days in mills*/) );
		document.cookie = this.prefix + key + "=" + escape(value) + ";expires=" + expires.toUTCString();
	}

	this.remove = function(key)
	{
		var gone = new Date( 0 );
		document.cookie = this.prefix + key + ";expires=" + gone.toUTCString();
	}

	this.get = function(key, defvalue)
	{
		var cookiearray = document.cookie.split( ';' );
		for( var i=0; i < cookiearray.length; i++ )
		{
			var cookie = cookiearray[i].split('=');
			if ( trim(cookie[0]) == this.prefix + key )
			{
				return trim(cookie[1]);
			}
		}
		return defvalue;
	}
}
var bandwidthSettings = new BandwidthCookieContainer();

//初始化图表和表格
function initializePlotsAndTable()
{
	var plotTimeFrame = bandwidthSettings.get("plot_time_frame", "1");
	var tableTimeFrame = bandwidthSettings.get("table_time_frame", "1");

	setSelectedValue("plot_time_frame", plotTimeFrame);//设置select值
	setCurrentTimeFrameBtn(plotTimeFrame);//映射到按钮
	setSelectedValue("table_time_frame", tableTimeFrame);//表格仍然使用select，不需要变动
	setSelectedValue("table_units", "mixed");

	document.getElementById("use_high_res_15m").checked = uciOriginal.get("shellgui", "bandwidth_display", "high_res_15m") == "1" ? true : false;

	var haveQosUpload = false;
	var haveQosDownload = false;
	var haveTor = false;
	var haveOpenvpn = false;
	var haveShadowvpn = false;
	var haveSSLocal = false;
	var haveSSServer = false;
	var haveSSRedir = false;
	var monitorIndex;
	for(monitorIndex=0; monitorIndex < monitorNames.length; monitorIndex++)
	{
		var monId = monitorNames[monitorIndex];
		if(monId.match(/qos/))
		{
			var isQosUpload = monId.match(/up/);
			var isQosDownload = monId.match(/down/);
			haveQosUpload =   haveQosUpload   || isQosUpload;
			haveQosDownload = haveQosDownload || isQosDownload;

			var splitId = monId.split("-");
			splitId.shift();
			splitId.shift();
			splitId.pop();
			splitId.pop();
			var qosClass = splitId.join("-");
			var qosName = uciOriginal.get("qos_shellgui", qosClass, "name");

			if(isQosUpload && definedUploadClasses[qosClass] == null)
			{
				qosUploadClasses.push(qosClass);
				qosUploadNames.push(qosName);
				definedUploadClasses[qosClass] = 1;
			}
			if(isQosDownload && definedDownloadClasses[qosClass] == null)
			{
				qosDownloadClasses.push(qosClass);
				qosDownloadNames.push(qosName);
				definedDownloadClasses[qosClass] = 1;
			}
		}
		haveTor = monId.match(/tor/) ? true : haveTor;
		haveOpenvpn = monId.match(/openvpn/) ? true : haveOpenvpn;
		haveShadowvpn = monId.match(/shadowvpn/) ? true : haveShadowvpn;
		haveSSLocal = monId.match(/sslocal/) ? true : haveSSLocal;
		haveSSServer = monId.match(/ssserver/) ? true : haveSSServer;
		haveSSRedir = monId.match(/ssredir/) ? true : haveSSRedir;
	}
	var plotIdNames = ["plot1_type", "plot2_type", "plot3_type", "table_type"];
	var idIndex;
	for(idIndex=0; idIndex < plotIdNames.length; idIndex++)
	{
		var plotIdName = plotIdNames[idIndex];
		if(haveQosUpload)
		{
			addOptionToSelectElement(plotIdName, UI.QoS_Upload_Class, "qos-upload");
		}
		if(haveQosDownload)
		{
			addOptionToSelectElement(plotIdName, UI.QoS_Download_Class, "qos-download");
		}
		if(haveTor)
		{
			addOptionToSelectElement(plotIdName, "Tor", "tor");
		}
		if(haveOpenvpn)
		{
			addOptionToSelectElement(plotIdName, "OpenVPN", "openvpn");
		}
		if(haveShadowvpn){
			addOptionToSelectElement(plotIdName, "ShadowVPN", "shadowvpn");
		}
		if(haveSSLocal){
			addOptionToSelectElement(plotIdName, "ShadowSocks Local", "sslocal");
		}
		if(haveSSServer){
			addOptionToSelectElement(plotIdName, "ShadowSocks Server", "ssserver");
		}
		if(haveSSRedir){
			addOptionToSelectElement(plotIdName, "ShadowSocks Redir", "ssredir");
		}

		addOptionToSelectElement(plotIdName, UI.Hostname, "hostname");
		addOptionToSelectElement(plotIdName, "IP", "ip");


		var plotType = bandwidthSettings.get(plotIdName, "none");
		setSelectedValue(plotIdName, plotType);
	}
	plotsInitializedToDefaults = false;


	uploadMonitors = ["","",""];
	downloadMonitors = ["","",""];
	updateInProgress = false;
	setTimeout(resetPlots, 150);
	updateInterval = setInterval(doUpdate, 2000);
}


//获取monitorId
function getMonitorId(isUp, graphTimeFrameIndex, plotType, plotId, graphLowRes){
	var nameIndex;
	var selectedName = null;

	var match1 = "";
	var match2 = "";


	var hr15m = uciOriginal.get("shellgui", "bandwidth_display", "high_res_15m");
	graphTimeFrameIndex = graphTimeFrameIndex == 1 && plotType != "total" && (!plotType.match(/tor/)) && (!plotType.match(/openvpn/)) && (!plotType.match(/shadowvpn/)) && (!plotType.match(/sslocal/)) && (!plotType.match(/ssserver/)) && (!plotType.match(/ssredir/)) && hr15m == "1" && (!graphLowRes) ? 0 : graphTimeFrameIndex;



	if(plotType == "total")
	{
		match1 = graphLowRes ? "bdist" + graphTimeFrameIndex : "total" + graphTimeFrameIndex;
	}
	else if(plotType.match(/qos/))
	{
		if( (isUp && plotType.match(/up/)) || ( (!isUp) && plotType.match(/down/)) )
		{
			match1 = "qos" + graphTimeFrameIndex;
			match2 = plotId;
		}
		else
		{
			plotType = "none"; //forces us to return null
		}
	}
	else if(plotType.match(/tor/))
	{
		match1 = graphLowRes ? "tor-lr" + graphTimeFrameIndex : "tor-hr" + graphTimeFrameIndex;
	}
	else if(plotType.match(/openvpn/))
	{
		match1 = graphLowRes ? "openvpn-lr" + graphTimeFrameIndex : "openvpn-hr" + graphTimeFrameIndex;
	}
	else if(plotType.match(/shadowvpn/))
	{
		match1 = graphLowRes ? "shadowvpn-lr" + graphTimeFrameIndex : "shadowvpn-hr" + graphTimeFrameIndex;
	}
	else if(plotType.match(/sslocal/))
	{
		match1 = graphLowRes ? "sslocal-lr" + graphTimeFrameIndex : "sslocal-hr" + graphTimeFrameIndex;
	}
	else if(plotType.match(/ssserver/))
	{
		match1 = graphLowRes ? "ssserver-lr" + graphTimeFrameIndex : "ssserver-hr" + graphTimeFrameIndex;
	}
	else if(plotType.match(/ssredir/))
	{
		match1 = graphLowRes ? "ssredir-lr" + graphTimeFrameIndex : "ssredir-hr" + graphTimeFrameIndex;
	}
	else if(plotType == "ip" || plotType == "hostname")
	{
		match1 = "bdist" + graphTimeFrameIndex;
	}

	if(plotType != "none")
	{
		for(nameIndex=0;nameIndex < monitorNames.length && selectedName == null; nameIndex++)
		{
			var name = monitorNames[nameIndex];
			if(	((name.match("up") && isUp) || (name.match("down") && !isUp)) &&
				(match1 == "" || name.match(match1)) &&
				(match2 == "" || name.match(match2))
			)
			{
				selectedName = name;
			}
		}
	}
	console.log(selectedName);
	return selectedName;
}

//获取主机名列表
function getHostnameList(ipList)
{
	var hostnameList = [];
	var ipIndex =0;
	for(ipIndex=0; ipIndex < ipList.length; ipIndex++)
	{
		var ip = ipList[ipIndex];
		var host = ipToHostname[ip] == null ? ip : ipToHostname[ip];//页面中定义
		host = host.length < 25 ? host : host.substr(0,22)+"...";
		hostnameList.push(host);
	}
	return hostnameList;
}

//重置图表
function resetPlots()
{
	if(window.my_total_line){
		window.my_total_line = undefined;
	}
	if(window.my_upload_line){
		window.my_upload_line = undefined;
	}
	if(window.my_download_line){
		window.my_download_line = undefined;
	}
		
	if( (!updateInProgress) && updateTotalPlot != null && updateUploadPlot != null && updateDownloadPlot != null)
	{
		updateInProgress = true;
		var oldTableDownloadMonitor = tableDownloadMonitor;
		var oldTableUploadMonitor = tableUploadMonitor;
		var oldDownloadMonitors = downloadMonitors.join("\n") + "\n";
		var oldUploadMonitors = uploadMonitors.join("\n") ;

		uploadMonitors = [];
		downloadMonitors = [];

		var graphTimeFrameIndex = getSelectedValue("plot_time_frame");
		var tableTimeFrameIndex = getSelectedValue("table_time_frame");

		var graphLowRes = false;
		var plotNum;
		for(plotNum=1; plotNum<=3; plotNum++)
		{
			var t = getSelectedValue("plot" + plotNum + "_type");
			var is15MHighRes = graphTimeFrameIndex == 1 && uciOriginal.get("shellgui", "bandwidth_display", "high_res_15m") == "1";
			graphLowRes = graphLowRes || (t != "total" && t != "none" && t != "tor" && t != "openvpn" && t != "shadowvpn" && t != "sslocal" && t != "ssserver" && t != "ssredir" && (!is15MHighRes));
		}
		for(plotNum=1; plotNum<=4; plotNum++)
		{
			var plotIdName = plotNum < 4 ? "plot" + plotNum + "_id" : "table_id";
			var plotIdVisName = plotNum < 4 ? plotIdName : plotIdName + "_container";
			var plotTypeName = plotNum < 4 ? "plot" + plotNum + "_type" : "table_type";
			var plotType = getSelectedValue(plotTypeName);
			var plotId= getSelectedValue(plotIdName);
			plotId = plotId == null ? "" : plotId;

			if(plotType == "ip" || plotType == "hostname")
			{
				if(plotId.match(/^[0-9]+\./) == null)
				{
					if(plotType == "hostname")
					{
						setAllowableSelections(plotIdName, ipsWithData, getHostnameList(ipsWithData));
					}
					else
					{
						setAllowableSelections(plotIdName, ipsWithData, ipsWithData);

					}
					setSelectedValue(plotIdName, ipsWithData[0]);
					plotId = ipsWithData[0] == null ? "" : ipsWithData[0];
				}
				$('#' + plotIdVisName).removeClass('hidden');
			}
			else if(plotType == "qos-upload")
			{
				if(definedUploadClasses[plotId] == null)
				{
					setAllowableSelections(plotIdName, qosUploadClasses, qosUploadNames);
					plotId = qosUploadClasses[0]
				}
				$('#' + plotIdVisName).removeClass('hidden');
			}
			else if(plotType == "qos-download")
			{
				if(definedDownloadClasses[plotId] == null)
				{
					setAllowableSelections(plotIdName, qosDownloadClasses, qosDownloadNames);
					plotId = qosDownloadClasses[0];
				}
				$('#' + plotIdVisName).removeClass('hidden');
			}
			else
			{
				$('#' + plotIdVisName).addClass('hidden');
			}

			if(!plotsInitializedToDefaults)
			{
				if(plotType != "" && plotType != "none" && plotType != "total" && plotType != "tor" && plotType != "openvpn" && plotType != "shadowvpn" && plotType != "sslocal" && plotType != "ssserver" && plotType != "ssredir" )
				{
					var idValue = bandwidthSettings.get(plotIdName, "none");
					if(idValue != "" && (plotType == "ip" || plotType == "hostname") )
					{
						setAllowableSelections(plotIdName, [idValue], [idValue]);
					}
					setSelectedValue(plotIdName, idValue);
					plotId = idValue;
				}
			}

			if(plotNum != 4)
			{
				uploadMonitors[plotNum-1]  = getMonitorId(true, graphTimeFrameIndex, plotType, plotId, graphLowRes);
				downloadMonitors[plotNum-1] = getMonitorId(false, graphTimeFrameIndex, plotType, plotId, graphLowRes);
				uploadMonitors[plotNum-1] = uploadMonitors[plotNum-1] == null ? "" : uploadMonitors[plotNum-1];
				downloadMonitors[plotNum-1] = downloadMonitors[plotNum-1] == null ? "" : downloadMonitors[plotNum-1];
			}
			else
			{
				var lowRes = plotType == "total" && tableTimeFrameIndex == 4 ? false : true;
				tableTimeFrameIndex =  lowRes ? tableTimeFrameIndex : 5;
				tableUploadMonitor   = getMonitorId(true,  tableTimeFrameIndex, plotType, plotId, lowRes);
				tableDownloadMonitor = getMonitorId(false, tableTimeFrameIndex, plotType, plotId, lowRes);
				tableUploadMonitor = tableUploadMonitor == null ? "" : tableUploadMonitor;
				tableDownloadMonitor = tableDownloadMonitor == null ? "" : tableDownloadMonitor;
			}
		}
		plotsInitializedToDefaults = true;

		updateInProgress = false;
		if(oldUploadMonitors != uploadMonitors.join("\n") || oldDownloadMonitors != downloadMonitors.join("\n") || oldTableUploadMonitor != tableUploadMonitor || oldTableDownloadMonitor != tableDownloadMonitor )
		{
			doUpdate();
		}

		bandwidthSettings.set('plot_time_frame', getSelectedValue("plot_time_frame"));
		bandwidthSettings.set('table_time_frame', getSelectedValue("table_time_frame"));

		for(plotNum=1; plotNum <= 4; plotNum++)
		{
			var plotIdName = plotNum < 4 ? "plot" + plotNum + "_id" : "table_id";
			var plotTypeName = plotNum < 4 ? "plot" + plotNum + "_type" : "table_type";
			var plotType = getSelectedValue(plotTypeName);
			bandwidthSettings.set(plotTypeName, plotType);

			if(plotType != "" && plotType != "none" && plotType != "total")
			{
				bandwidthSettings.set(plotIdName, getSelectedValue(plotIdName));
			}
			else
			{
				bandwidthSettings.remove(plotIdName);
				bandwidthSettings.remove(plotTypeName);
			}
		}
	}
	else
	{
		setTimeout(resetPlots, 25); //try again in 25 milliseconds
		if(  updateTotalPlot == null || updateDownloadPlot == null ||  updateUploadPlot == null   )
		{
			updateTotalPlot = updateTotalLine;
			updateDownloadPlot = updateDownloadLine;
			updateUploadPlot = updateUploadLine;
		}
	}
}


//-------------图表设置------------------------------------------------------------------
function updateTotalLine(totalPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI){
	var datas = getDisplayData(totalPointSets,plotIntervalLength,plotNumIntervals);
	var times = getDisplayTime(totalPointSets, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint,plotNumIntervals);
	var labels = getDisplayLabel(totalPointSets);
	if(typeof(my_total_line)=='undefined'){
		makeLine('my_total',datas,times, UI.Total,labels);
	}else{
		updateLine('my_total',datas,times);
	}
}

function updateDownloadLine(downloadPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI ){
	
	var datas = getDisplayData(downloadPointSets,plotIntervalLength,plotNumIntervals);
	var times = getDisplayTime(downloadPointSets, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint,plotNumIntervals);
	var labels = getDisplayLabel(downloadPointSets);
	if(typeof(my_download_line)=='undefined'){
		makeLine('my_download',datas,times, UI.Download,labels);
	}else{
		updateLine('my_download',datas,times);
	}
}

function updateUploadLine(uploadPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI ){
	
	var datas = getDisplayData(uploadPointSets,plotIntervalLength,plotNumIntervals);
	var times = getDisplayTime(uploadPointSets, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint,plotNumIntervals);
	var labels = getDisplayLabel(uploadPointSets);
	if(typeof(my_upload_line)=='undefined'){
		makeLine('my_upload',datas,times, UI.Upload,labels);
	}else{
		updateLine('my_upload',datas,times);
	}

}

function getDisplayLabel(pointSets){
	var labels = {};
	for(var i=0; i<3; i++){//三条线各自的数据
		if(pointSets[i]){
			var label = getSelectedValue('plot' + (i+1) + '_type');
			var after_label = '';
			if(label != 'none' && label != 'total' && label != 'openvpn' && label != 'shadowvpn' && label != 'sslocal' && label != 'ssserver' && label != 'ssredir'){
				// label += '-' + getSelectedValue('plot' + (i+1) + '_id');
				after_label = '-' + $('[value="' + getSelectedValue('plot' + (i+1) + '_id') + '"]').html();
			}
			label = $('#plot' + (i+1) + '_type').find('[value="' + label + '"]').html();
			label += after_label;
			labels[i] = label;
		}
	}
	return labels;
}

function getDisplayData(pointSets, plotIntervalLength,plotNumIntervals){
	var intervalLength = getIntervalSeconds(plotIntervalLength);
	var datas = {};
	for(var i=0; i<3; i++){//三条线各自的数据
		if(pointSets[i]){
			var speedData = [];
			var data = pointSets[i];
			var length = data.length < parseInt(plotNumIntervals)+1 ? parseInt(plotNumIntervals)+1 : data.length;
			for(var n=0; n<length; n++){
				if(typeof(data[n]) != 'undefined'){
					speedData.push(data[n]/1024/(parseInt(intervalLength)));// kb/s
				}else{
					speedData.unshift(0);
				}
			}
			datas[i] = speedData;
		}
	}

	return datas;
}

function getIntervalSeconds(str){
	var secs;
	if(str == 'minute'){
		secs = 60;
	}else if(str == 'hour'){
		secs = 3600;
	}else if(str == 'day'){//TODO
		secs = 1024 * 24; //mb/hr 
		// secs = 28800;
		// secs = 86400;
	}else if(str == 'month'){//TODO
		secs = 1024 * 1024 * 12; //gb/day
	}else{
		secs = parseInt(str);
	}

	return secs;
}

function getLastMonth(date){
	var now = parseInt(date)*1000;
	now = new Date(now);
	var year=now.getFullYear();
	var month=now.getMonth();
	if(month == 0){
		year = year-1;
		month = 11;
	}else{
		month = month-1;
	}
	now.setFullYear(year);
	now.setMonth(month);
	return now.getTime()/1000;//毫秒数
}

function getLastYear(date){
	var now = parseInt(date)*1000;
	now = new Date(now);
	var year=now.getFullYear();
	now.setFullYear(year-1);
	return now.getTime()/1000;
}

function getTimeStr(date,formate){
	var now = parseInt(date)*1000;
	now = new Date(now);
	var YYYY=now.getFullYear();
	var MM=now.getMonth()+1;
	var dd=now.getDate();
	var hh=now.getHours();
	var mm=now.getMinutes();
	var ss=now.getSeconds();
	return formate.replace('YYYY',add0(YYYY))
				  .replace('MM',add0(MM))
				  .replace('dd',add0(dd))
				  .replace('hh',add0(hh))
				  .replace('mm',add0(mm))
				  .replace('ss',add0(ss));
}

function makeLine(canvasId,data,time,title,label){
	var datasets = [];
	if(data[0]){
		var line1 = {
			label: label[0],
            data: data[0],
            pointRadius: 0,
            pointHitRadius: 0,
            fill: false,
            borderWidth: 1,
            borderColor: '#5bc0de'
		};
		datasets.push(line1);
	}
	if(data[1]){
		var line2 = {
			label: label[1],
            data: data[1],
            pointRadius: 0,
            pointHitRadius: 0,
            fill: false,
            borderWidth: 1.5,
            borderColor: '#5cb85c'
		};
		datasets.push(line2);
	}
	if(data[2]){
		var line3 = {
			label: label[2],
            data: data[2],
            pointRadius: 0,
            pointHitRadius: 0,
            fill: false,
            borderWidth: 2,
            borderColor: '#d9534f'
        };
        datasets.push(line3);
	}

	//速率单位
	var labelString,timeFrame;
	timeFrame = getSelectedValue('plot_time_frame');
	if(timeFrame > 3){
		if(timeFrame > 4){
			labelString = 'GByte / day';
		}else{
			labelString = 'MByte / hr'
		}
	}else{
		labelString = 'KByte / s'
	}

	var config = {
	            type: 'line',
	            data: {
	                labels: time,
	                datasets: datasets
	            },
	            options: {
	            	animation: {
	            		duration: 0
	            	},
	                responsive: true,
	                title:{
	                    display:true,
	                    text: title
	                },
	                scales: {
	                    xAxes: [{
	                        display: true
	                    }],
	                    yAxes: [{
	                        display: true,
	                        beginAtZero: false,
		                    scaleLabel: {
		                        display: true,
		                        labelString: labelString
		                    }
	                    }]
	                }
	            }
	        };

	var cxt = document.getElementById(canvasId).getContext("2d");
	window[canvasId + '_line'] = new Chart(cxt, config);
}

function updateLine(canvasId,data,time){

	var datas = [];
	for(var line in data){
		datas.push(data[line]);
	}
	for(var i=0; i<window[canvasId+'_line'].config.data.datasets.length; i++){
		window[canvasId+'_line'].config.data.datasets[i].data = datas[i];
	}

	window[canvasId+'_line'].config.data.labels = time;
	window[canvasId +'_line'].update();
}

//----------------------图表时间轴-------------------------------------------------------

function getDisplayTime(pointSets, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint,plotNumIntervals){
	var formate = getXaxesFormate();
	var timeLength = getSelectedValue('plot_time_frame');
	var timeStart;
	var timeEnd = plotLastTimePoint;
	if(timeLength == 1){
		timeStart = plotLastTimePoint - 900;
	}else if(timeLength == 2){
		timeStart = plotLastTimePoint -21600;
	}else if(timeLength == 3){
		timeStart = plotLastTimePoint -86400;
	}else if(timeLength == 4){
		//一个月前
		timeStart = getLastMonth(plotLastTimePoint);
	}else{
		//一年前
		timeStart = getLastYear(plotLastTimePoint);
	}
	var times;
	for(var i=0; i<3; i++){//三条线各自的数据
		if(pointSets[0] || pointSets[1] || pointSets[2]){
			var timePoints = [];
			var data = pointSets[0] || pointSets[1] || pointSets[2];
			var length = data.length < parseInt(plotNumIntervals)+1 ? parseInt(plotNumIntervals)+1 : data.length;
			for(var n=0; n<length; n++){
				timePoints.push('');
			}

			times = timePoints;
		}else{
			var timePoints = [];
			var length = parseInt(plotNumIntervals)+1;
			for(var n=0; n<length; n++){
				timePoints.push('');
			}

			times = timePoints;
		}
	}
	times[0] = timeStart;
	times[times.length-1] = timeEnd;
	var getlabels = getTimeLabels();
	times = getlabels(times);
	return times;
}


function getXaxesFormate(){
	var timeFrame = getSelectedValue('plot_time_frame');
	var plot1_type = getSelectedValue('plot1_type');
	var plot2_type = getSelectedValue('plot2_type');
	var plot3_type = getSelectedValue('plot3_type');

	var labelCounts,pointCounts,labelFormate;
	if(timeFrame == 1){
		labelCounts = 5;
		pointCounts = 16;
		labelFormate = 'hh:mm';
	}else if(timeFrame == 2){
		labelCounts = 6;
		pointCounts = 25;
		labelFormate = 'hh:00';
	}else if(timeFrame == 3){
		labelCounts = 6;
		pointCounts = 25;
		labelFormate = 'hh:00';
	}else if(timeFrame == 4){
		labelCounts = 5;
		pointCounts = 32;
		labelFormate = 'MM-dd';
	}else if(timeFrame == 5){
		labelCounts = 6;
		pointCounts = 13;
		labelFormate = 'YYYY-MM月';
	}

	if(plot1_type == 'total' && plot2_type == 'none' && plot3_type == 'none'){
		pointCounts = 450;
		labelFormate = 'hh:mm:ss';
	}
	return data = {
		timeFrame: timeFrame,
		labelCounts: labelCounts,
		pointCounts: pointCounts,
		labelFormate: labelFormate
	};
}

function add0(num){
	return num > 9 ? num : '0' + num;
}


function get15MinsLabels(times){
	var len = times.length;
	var start = times[0], end = times[len-1];
	if(len == 16){
		for(var i=1; i<len; i++){
			times[i] = times[0] + 60*i;
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'hh:mm');
			if(i%3 != 0 || i == 0){
				times[i] = '';
			}
		}
	}else if(len == 450){
		for(var i=len-2; i>=0; i--){
			times[i] = times[len-1] - 2*(449-i); 
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'hh:mm:ss');
			if(i%30 != 0 || i == 0){
				times[i] = '';
			}
		}
	}
	return times;
}

function get6HoursLabels(times){
	var len = times.length;
	var start = times[0], end = times[len-1];
	if(len == 25){
		for(var i=len-2; i>=0; i--){
			times[i] = end - 900*(24-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'hh:mm');
			if(times[i].split(':').pop() != '00'){
				times[i] = '';
			}
		}
	}else if(len == 360){
		for(var i=len-2; i>=0; i--){
			times[i] = end - 60*(359-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'hh:mm');
			if(times[i].split(':').pop() != '00'){
				times[i] = '';
			}
		}
	}

	return times;
}

function get24HoursLabels(times){
	var len = times.length;
	var start = times[0], end = times[len-1];
	if(len == 25){
		for(var i=len-2; i>=0; i--){
			times[i] = end - 3600*(24-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'hh:00');
			if(i%4 != 0 || i==0){
				times[i] = '';
			}
		}
	}else if(len == 480){
		for(var i=len-2; i>=0; i--){
			times[i] = end - 180*(479-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'hh:mm');
			if(times[i].split(':').pop() != '00'){
				times[i] = '';
			}
		}
	}
	return times;
}

function get30DaysLabels(times){
	var len = times.length;
	var start = times[0], end = times[len-1];
	if(len < 50){
		for(var i=len-2; i>=0; i--){
			times[i] = end - 86400*(len-1-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'MM-dd');
			if(i%5 != 0 || i==0){
				times[i] = '';
			}
		}
	}else if(len > 50){
		for(var i=len-2; i>=0; i--){
			times[i] = end - 7200*(len-1-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'MM-dd');
			if(i%60 != 0 || i==0){
				times[i] = '';
			}
		}
	}
	return times;
}

function get1YearLabels(times){
	var len = times.length;
	var start = times[0], end = times[len-1];
	if(len == 13){
		for(var i=len-2; i>=0; i--){
			times[i] = getLastMonth(times[i+1]);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'MM月');
			if(i%2 != 0 || i==0){
				times[i] = '';
			}
		}
	}else{
		for(var i=len-2; i>=0; i--){
			times[i] = end - 86400*(len-1-i);
		}
		for(var i=0; i<len; i++){
			times[i] = getTimeStr(times[i],'MM-dd');
			if(times[i].split('-').pop()!='01'){
				times[i] = '';
			}
		}
	}
	return times;
}

function getTimeLabels(){
	var id = getSelectedValue('plot_time_frame');
	var getLabels;
	if(id == 1){
		getLabels = get15MinsLabels;
	}else if(id == 2){
		getLabels = get6HoursLabels;
	}else if(id == 3){
		getLabels = get24HoursLabels;
	}else if(id == 4){
		getLabels = get30DaysLabels;
	}else if(id == 5){
		getLabels = get1YearLabels;
	}

	return getLabels;
}




//------------------------------------------------------------------------------

//格式化数据
function parseMonitors(outputData)
{
	var monitors = [ ];
	var dataLines = outputData.split(/[\r\n]+/);
	var currentTime = parseInt(dataLines.shift());
	if(""+currentTime == "NaN")
	{
		return monitors;
	}


	var lineIndex;
	for(lineIndex=0; lineIndex < dataLines.length; lineIndex++)
	{
		if(dataLines[lineIndex] != null && dataLines[lineIndex].length > 0)
		{
			if(dataLines[lineIndex].match(/ /))
			{
				var monitorId = (dataLines[lineIndex].split(/[\t ]+/))[0];
				var monitorIp = (dataLines[lineIndex].split(/[\t ]+/))[1];
				lineIndex++;
				var firstTimeStart = dataLines[lineIndex];
				lineIndex++;
				var firstTimeEnd = dataLines[lineIndex];
				lineIndex++;
				var lastTimePoint = dataLines[lineIndex];
				if(dataLines[lineIndex+1] != null)
				{
					if(dataLines[lineIndex+1].match(/,/) || dataLines[lineIndex+1].match(/^[0-9]+$/))
					{
						lineIndex++;
						var points = dataLines[lineIndex].split(",");
						monitors[monitorId] = monitors[monitorId] == null ? [] : monitors[monitorId];
						monitors[monitorId][monitorIp] = [points, lastTimePoint, currentTime ];
						found = 1
					}
				}
			}
		}
	}
	return monitors;
}

function getDisplayIp(realIp)
{
	var dip = realIp
	if(dip != null && currentWanIp != null && currentLanIp != null && dip != "")
	{
		dip = dip == currentWanIp ? currentLanIp : dip;
	}
	return dip
}

function getRealIp(displayIp)
{
	var rip = displayIp
	if(rip != null && currentWanIp != null && currentLanIp != null && currentWanIp != "" && currentLanIp != "" && rip != "")
	{
		rip = rip == currentLanIp ? currentWanIp : rip;
	}
	return rip

}

//发送更新请求
var updateReq = null;
var updateTimeoutId = null;
function doUpdate()
{
	if(!updateInProgress && updateUploadPlot != null && updateDownloadPlot != null && updateTotalPlot != null)
	{
		updateInProgress = true;
		var monitorQueryNames = uploadMonitors.join(" ") + " " + downloadMonitors.join(" ") + " " + tableDownloadMonitor + " " + tableUploadMonitor ;
		var param = 'app=bandwidth-usage&action=get_bandwidth&' + getParameterDefinition("monitor", monitorQueryNames);
		var stateChangeFunction = function(req)
		{
			if(req.readyState == 4)
			{
				try{ clearTimeout(updateTimeoutId); }catch(e){}
				updateReq = null;

				if(  req.responseText.length > 0 && (!req.responseText.match(/ERROR/)) )
				{

					var monitors = parseMonitors(req.responseText);
					var uploadPointSets = [];
					var downloadPointSets = [];
					var totalPointSets = [];
					var tablePointSets = [];
					var tableTotal = [];
					var plotNumIntervals = 0;
					var plotIntervalLength = 2;
					var tableNumIntervals = 0;
					var tableIntervalLength = 2;
					var plotLastTimePoint = Math.floor( (new Date()).getTime()/1000 );
					var plotCurrentTimePoint = plotLastTimePoint;
					var tableLastTimePoint = plotLastTimePoint;


					for(monitorIndex=0; monitorIndex < 4; monitorIndex++)
					{
						var ipsInitialized = false;
						var dirIndex;
						for(dirIndex = 0; dirIndex < 2; dirIndex++)
						{
							var dataLoaded = false;
							var pointSets;
							var monitorName;
							if(monitorIndex < 3)
							{
								var monitorList = dirIndex == 0 ? downloadMonitors : uploadMonitors;
								pointSets = dirIndex == 0 ? downloadPointSets : uploadPointSets;
								monitorName = monitorList[monitorIndex];
							}
							else
							{
								pointSets = tablePointSets;
								monitorName = dirIndex == 0 ? tableDownloadMonitor : tableUploadMonitor;
							}
							monitorName = monitorName == null ? "" : monitorName;

							var plotTypeName = monitorIndex < 3 ? "plot" + (monitorIndex+1) + "_type" : "table_type";
							var selectedPlotType = getSelectedValue(plotTypeName);
							var monitorData = monitorName == "" ? null : monitors[monitorName];
							if(monitorData != null)
							{
								var selectedIp = "";
								//get list of available ips
								var ipList = [];
								var ip;
								for (ip in monitorData)
								{
									if( ((selectedPlotType == "total" || selectedPlotType.match("qos") || selectedPlotType.match("tor") || selectedPlotType.match("openvpn") || selectedPlotType.match("shadowvpn") || selectedPlotType.match("sslocal") || selectedPlotType.match("ssserver") || selectedPlotType.match("ssredir") ) && ip == "COMBINED") || (selectedPlotType != "total" && ip != "COMBINED") )
									{
										ipList.push(getDisplayIp(ip));
									}
								}
								if(ipList.length > 0)
								{
									var splitName = monitorName.split("-");
									if(monitorIndex < 3)
									{
										plotNumIntervals = splitName.pop();
										plotIntervalLength = splitName.pop();
									}
									else
									{
										tableNumIntervals = splitName.pop();
										tableIntervalLength = splitName.pop();
									}

									if(monitorName.match("bdist") && selectedPlotType != "total")
									{
										var plotIdName   = monitorIndex < 3 ? "plot" + (monitorIndex+1) + "_id"   : "table_id";
										ip = getSelectedValue(plotIdName);
										ip = ip == null ? "" : getRealIp(ip);
										var curIP = $('#' + plotIdName).val();
										if(monitorData[ip] == null && curIP == ip){
											Ha.showNotify({status: 2,msg: UI.Host_IP+':' + ip + UI.have_nothing_data_at_this_period});
											bandwidthSettings.set(plotIdName,ipList[0]);
										}

										ip = monitorData[ip] != null ? ip : ipList[0];


										if(selectedPlotType == "hostname")
										{
											setAllowableSelections(plotIdName, ipList, getHostnameList(ipList));
										}
										else
										{
											setAllowableSelections(plotIdName, ipList, ipList);
										}
										ipsWithData = ipList;
									}
									else
									{
										ip = ipList[0];
									}

									ip = ip == null ? "" : getRealIp(ip);
									var points = monitorData[ip][0]
									if(monitorIndex < 3)
									{
										plotLastTimePoint = monitorData[ip][1];
										plotCurrentTimePoint = monitorData[ip][2];
									}
									else
									{
										tableLastTimePoint = monitorData[ip][1];
									}

									var totalSet;
									if(monitorIndex < 3)
									{
										totalSet = totalPointSets[monitorIndex] == null ? [] : totalPointSets[monitorIndex];
									}
									else
									{
										totalSet = tableTotal;
									}
									var updateIndex;
									for(updateIndex=0; updateIndex < points.length; updateIndex++)
									{
										var pointIndex = points.length-(1+updateIndex);
										var totalIndex = totalSet.length < points.length ? updateIndex : (totalSet.length-points.length)+updateIndex;
										if(totalSet[totalIndex] != null)
										{
											totalSet[totalIndex] = parseInt(totalSet[totalIndex]) + parseInt(points[pointIndex])
										}
										else
										{
											totalSet.push( points[pointIndex] );
										}
									}
									if(monitorIndex < 3)
									{
										totalPointSets[monitorIndex] = totalSet;
									}
									pointSets.push(points);
									dataLoaded=true;

								}
								else if(monitorName.match("bdist") && monitorIndex < 3 )
								{
									var plotTypeName = monitorIndex < 3 ? "plot" + (monitorIndex+1) + "_type" : "table_type";
									var plotIdName   = monitorIndex < 3 ? "plot" + (monitorIndex+1) + "_id"   : "table_id";
									monitorList[monitorIndex] = "";
									setSelectedValue(plotTypeName, "none");
									$('#' + plotIdName).addClass('hidden');
								}
							}
							else if(monitorName.match("bdist") && selectedPlotType != "total" && monitorIndex < 3 )
							{
								var plotIdName   = monitorIndex < 3 ? "plot" + (monitorIndex+1) + "_id"   : "table_id";
								monitorList[monitorIndex] = ""
								setSelectedValue(plotTypeName, "none");
								$('#' + plotIdName).addClass('hidden');
							}
							if(!dataLoaded)
							{
								pointSets.push(null);
							}
						}
						if(monitorIndex < 3)
						{
							totalPointSets[monitorIndex] = totalPointSets[monitorIndex] == null ? null : (totalPointSets[monitorIndex]).reverse()
						}
						else
						{
							tableTotal.reverse();
							tablePointSets.unshift(tableTotal);
						}
					}
					updateTotalPlot(totalPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI);
					updateDownloadPlot(downloadPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI );
					updateUploadPlot(uploadPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI );
					// if(expandedFunctions[bndwS.Totl] != null)
					// {
					// 	var f = expandedFunctions[bndwS.Totl] ;
					// 	f(totalPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI);
					// }
					// if(expandedFunctions[bndwS.Dnld] != null)
					// {
					// 	var f = expandedFunctions[bndwS.Dnld] ;
					// 	f(downloadPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI);
					// }
					// if(expandedFunctions[bndwS.Upld] != null)
					// {
					// 	var f = expandedFunctions[bndwS.Upld] ;
					// 	f(uploadPointSets, plotNumIntervals, plotIntervalLength, plotLastTimePoint, plotCurrentTimePoint, tzMinutes, UI);
					// }
					updateBandwidthTable(tablePointSets, tableIntervalLength, tableLastTimePoint);
				}

				updateInProgress = false;
			}
		}
		var timeoutFun = function()
		{
			updateInProgress = false;
		}
		updateReq = runAjax("POST", "/", param, stateChangeFunction);
		updateTimeoutId = setTimeout(timeoutFun, 5000);
	}
}

function twod(num)
{
	var nstr = "" + num; nstr = nstr.length == 1 ? "0" + nstr : nstr;
	return nstr;
}


// 更新表格数据
function updateBandwidthTable(tablePointSets, interval, tableLastTimePoint)
{
	var rowData = [];
	var rowIndex = 0;
	var displayUnits = getSelectedValue("table_units");
	var timePoint = tableLastTimePoint;
	var nextDate = new Date();
	nextDate.setTime(timePoint*1000);
	nextDate.setUTCMinutes( nextDate.getUTCMinutes()+tzMinutes );
	if((parseInt(interval) == "NaN") && (interval.match(/month/) || interval.match(/day/)))
	{
		nextDate = new Date( nextDate.getTime() + (3*60*60*1000))
	}
	var monthNames = UI.EMonths;

	for(rowIndex=0; rowIndex < (tablePointSets[0]).length; rowIndex++)
	{
		var colIndex = 0;
		var vals = [];
		for(colIndex=0; colIndex < 3; colIndex++)
		{
			var points = tablePointSets[colIndex];
			var val = points == null ? 0 : points[points.length-(1+rowIndex)];
			val = val == null ? 0 : val;
			vals.push(parseBytes(val, displayUnits));
		}

		var timeStr = "";
		if(interval.match(/minute/))
		{
			timeStr = "" + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
			nextDate.setUTCMinutes( nextDate.getUTCMinutes()-1);
		}
		else if(interval.match(/hour/))
		{
			timeStr = "" + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
			nextDate.setUTCHours( nextDate.getUTCHours()-1);
		}
		else if(interval.match(/day/))
		{
			timeStr = monthNames[nextDate.getUTCMonth()] + " " + nextDate.getUTCDate();
			nextDate.setUTCDate( nextDate.getUTCDate()-1);
		}
		else if(interval.match(/month/))
		{
			//nextDate.setDate(2) //set second day of month, so when DST shifts hour back in November we don't push it back to previous month
			timeStr = monthNames[nextDate.getUTCMonth()] + " " + nextDate.getUTCFullYear();
			nextDate.setUTCMonth( nextDate.getUTCMonth()-1);
		}
		else if(parseInt(interval) != "NaN")
		{
			if(parseInt(interval) >= 28*24*60*60)
			{
				timeStr = monthNames[nextDate.getUTCMonth()] + " " + nextDate.getUTCFullYear() + " " + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
			}
			else if(parseInt(interval) >= 24*60*60)
			{
				timeStr = monthNames[nextDate.getUTCMonth()] + " " + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
			}
			else
			{
				timeStr = "" + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
			}
			nextDate.setTime(nextDate.getTime()-(parseInt(interval)*1000));
		}
		vals.unshift(timeStr);
		rowData.push(vals);
		timePoint = nextDate.getTime()/1000;
	}
	updateTableData(rowData);
}

//checkbox相关
function highResChanged()
{
	setControlsEnabled(false, true, bndwS.RstGr);

	var useHighRes15m = document.getElementById("use_high_res_15m").checked;
	var commands = [];
	commands.push("uci set shellgui.bandwidth_display=bandwidth_display");
	commands.push("uci set shellgui.bandwidth_display.high_res_15m=" + (useHighRes15m ? "1" : "0"));
	commands.push("uci commit");
	commands.push("/usr/shellgui/progs/bwmond restart");

	var stateChangeFunction = function(req)
	{
		if(req.readyState == 4)
		{
			window.location = window.location;
			setControlsEnabled(true);
		}
	}
	// var param = getParameterDefinition("commands", commands.join("\n"))  + "&" + getParameterDefinition("hash", document.cookie.replace(/^.*hash=/,"").replace(/[\t ;]+.*$/, ""));
	var param = 'app=bandwidth-usage&action=get_bandwidth&monitor=bdist1-upload-minute-15   bdist1-download-minute-15   bdist1-download-minute-15 bdist1-upload-minute-15';
	// runAjax("POST", "utility/run_commands.sh", param, stateChangeFunction);
	runAjax("POST", "/", param, stateChangeFunction);

}

//删除数据
function deleteData()
{
	if (confirm(bndwS.DelAD) == false)
	{
		return;
	}

	setControlsEnabled(false, true, bndwS.DelDW);

	var commands = [];
	commands.push("/usr/shellgui/progs/bwmond stop");
	commands.push("rm /tmp/data/bwmon/*");
	commands.push("rm /usr/data/bwmon/*");
	commands.push("/usr/shellgui/progs/bwmond start");

	var stateChangeFunction = function(req)
	{
		if(req.readyState == 4)
		{
			setControlsEnabled(true);
		}
	}
	// var param = getParameterDefinition("commands", commands.join("\n"))  + "&" + getParameterDefinition("hash", document.cookie.replace(/^.*hash=/,"").replace(/[\t ;]+.*$/, ""));
	var param = 'app=bandwidth-usage&action=get_bandwidth&monitor=bdist1-upload-minute-15   bdist1-download-minute-15   bdist1-download-minute-15 bdist1-upload-minute-15';
	// runAjax("POST", "utility/run_commands.sh", param, stateChangeFunction);
	runAjax("POST", "/", param, stateChangeFunction);
}

//common 设置选择框的值
function setSelectedValue(selectId, selection, controlDocument)
{
	var controlDocument = controlDocument == null ? document : controlDocument;

	var selectElement = controlDocument.getElementById(selectId);

	var selectionFound = false;
	for(optionIndex = 0; optionIndex < selectElement.options.length && (!selectionFound); optionIndex++)
	{
		selectionFound = (selectElement.options[optionIndex].value == selection);
		if(selectionFound)
		{
			selectElement.selectedIndex = optionIndex;
		}
	}
	if(!selectionFound && selectElement.options.length > 0 && selectElement.selectedIndex < 0)
	{
		selectElement.selectedIndex = 0;
	}
}

//common
function getSelectedValue(selectId, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	if(controlDocument.getElementById(selectId) == null)
	{
		alert(UI.Err+": " + selectId + " "+UI.nex);
		return;
	}

	selectedIndex = controlDocument.getElementById(selectId).selectedIndex;
	selectedValue = "";
	if(selectedIndex >= 0)
	{
		selectedValue= controlDocument.getElementById(selectId).options[ controlDocument.getElementById(selectId).selectedIndex ].value;
	}
	return selectedValue;

}

//common
function addOptionToSelectElement(selectId, optionText, optionValue, before, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	option = controlDocument.createElement("option");
	option.text=optionText;
	option.value=optionValue;

	try
	{
		controlDocument.getElementById(selectId).add(option, before);
	}
	catch(e)
	{
		if(before == null)
		{
			controlDocument.getElementById(selectId).add(option);
		}
		else
		{
			controlDocument.getElementById(selectId).add(option, before.index);
		}
	}
}

//common
function setBrowserTimeCookie()
{
	var browserSecondsUtc = Math.floor( ( new Date() ).getTime() / 1000 );
	document.cookie="browser_time=" +browserSecondsUtc + "; path=/"; //don't bother with expiration -- who cares when the cookie was set? It just contains the current time, which the browser already knows
}

function getParameterDefinition(parameter, definition)
{
	return(encodeURIComponent(parameter) + "=" + encodeURIComponent(definition));
}

//common
function removeStringFromArray(arr, str)
{
	var arrIndex;
	var newArr = [];
	for(arrIndex=0;arrIndex<arr.length; arrIndex++)
	{
		var elFound = false;
		if(typeof(arr[arrIndex]) == "string" )
		{
			elFound = (arr[arrIndex] == str)
		}
		if(!elFound)
		{
			newArr.push(arr[arrIndex]);
		}
	}
	return newArr;
}

//common
function runAjax(method, url, params, stateChangeFunction)
{

	setBrowserTimeCookie();
	var req = getRequestObj();
	if(req)
	{
		req.onreadystatechange = function()
		{
			stateChangeFunction(req);
		}

		if(method == "POST")
		{
			//for some reason we need at least one character of data, so use a space if params == null
			params = (params == null) ? " " : params;

			req.open("POST", url, true);
			req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			//req.setRequestHeader("Content-length", params.length);
			//req.setRequestHeader("Connection", "close");
			req.send(params);
		}
		else if(method == "GET")
		{
			req.open("GET", url + "?" + params, true);
			req.send(null);
		}
	}
	return req;
}


//common
function getRequestObj()
{
	var req;
	try
	{

		// standards compliant browsers
		req = new XMLHttpRequest();
	}
	catch (ex)
	{
		// MicroShit Browsers
		try
		{
			req = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (ex)
		{
			try
			{
				req = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (ex)
			{
				// Browser is not Ajax compliant
				return false;
			}
		}
	}
	return req;
}

//common
function setAllowableSelections(selectId, allowableValues, allowableNames, controlDocument)
{
	if(controlDocument == null) { controlDocument = document; }

	var selectElement = controlDocument.getElementById(selectId);
	if(allowableNames != null && allowableValues != null && selectElement != null)
	{

		var doReplace = true;
		if(allowableValues.length == selectElement.options.length)
		{
			doReplace = false;
			for(optionIndex = 0; optionIndex < selectElement.options.length && (!doReplace); optionIndex++)
			{
				doReplace = doReplace || (selectElement.options[optionIndex].text != allowableNames[optionIndex]) || (selectElement.options[optionIndex].value != allowableValues[optionIndex]) ;
			}
		}
		if(doReplace)
		{
			currentSelection=getSelectedValue(selectId, controlDocument);
			removeAllOptionsFromSelectElement(selectElement);
			for(addIndex=0; addIndex < allowableValues.length; addIndex++)
			{
				addOptionToSelectElement(selectId, allowableNames[addIndex], allowableValues[addIndex], null, controlDocument);
			}
			setSelectedValue(selectId, currentSelection, controlDocument); //restore original settings if still valid
		}
	}
}

//common
//移除select下所有option
function removeAllOptionsFromSelectElement(selectElement)
{
	while(selectElement.length > 0)
	{
		try { selectElement.remove(0); } catch(e){}
	}
}

//common
function parseBytes(bytes, units, abbr, dDgt)
{
	var parsed;
	units = units != "KBytes" && units != "MBytes" && units != "GBytes" && units != "TBytes" ? "mixed" : units;
	spcr = abbr==null||abbr==0 ? " " : "";
	if( (units == "mixed" && bytes > 1024*1024*1024*1024) || units == "TBytes")
	{
		parsed = (bytes/(1024*1024*1024*1024)).toFixed(dDgt||3) + spcr + (abbr?UI.TB:UI.TBy);
	}
	else if( (units == "mixed" && bytes > 1024*1024*1024) || units == "GBytes")
	{
		parsed = (bytes/(1024*1024*1024)).toFixed(dDgt||3) + spcr + (abbr?UI.GB:UI.GBy);
	}
	else if( (units == "mixed" && bytes > 1024*1024) || units == "MBytes" )
	{
		parsed = (bytes/(1024*1024)).toFixed(dDgt||3) + spcr + (abbr?UI.MB:UI.MBy);
	}
	else
	{
		parsed = (bytes/(1024)).toFixed(dDgt||3) + spcr + (abbr?UI.KB:UI.KBy);
	}

	return parsed;
}

//------------------------------------table------------------------------------------------

function setCurrentTimeFrameBtn(id){
	$('.tf_btn').each(function(){
		$(this).removeClass('active');
	});
	$('#plot_tf_' + id + ',#plot_tf_xs_' + id).addClass('active');
}

function updateTableData(data){
	$('#bw_table_container').empty();
	for(var i=0; i<data.length; i++){
		var dom = '<tr>'
				+ 	'<td>' + data[i][0] + '</td>'
				+	'<td>' + data[i][1] + '</td>'
				+	'<td>' + data[i][2] + '</td>'
				+	'<td>' + data[i][3] + '</td>'
				+ '</tr>';
		$('#bw_table_container').append(dom);
	}
}

$('.dropdown-menu').find('a').click(function(e){
	e.preventDefault();
});

$('#table_type').change(function(){
	var value = $(this).val();
	if(value == 'qos-upload' || value == 'qos-download' || value == 'hostname' || value == 'ip'){
		var html = $('#table_id').html();
		$('#table_id_shown').removeClass('hidden').html(html);
	}else{
		var html_none = '';
		$('#table_id_shown').addClass('hidden').html(html_none);
	}
	$('#table_type_shown').val(value);
});

$('.tf_btn').click(function(){
	//表现
	var id = $(this).prop('id').split('_').pop();
	$('.tf_btn').each(function(){
		$(this).removeClass('active');
		var subid = $(this).prop('id').split('_').pop();
		if(subid == id){
			$(this).addClass('active');
		}
	});
	//数据设置
	$('#plot_time_frame').val(id);
	resetPlots();

});

//----------------------------------------------------------------------------------------

initializePlotsAndTable();
