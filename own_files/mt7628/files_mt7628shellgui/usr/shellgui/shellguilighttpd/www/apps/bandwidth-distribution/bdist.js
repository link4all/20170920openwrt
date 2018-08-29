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
// UI.monthNames = ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'];

setBrowserTimeCookie();

var testAjax = getRequestObj();

var tzMinutes = 480;

var bndwS=new Object();

var plotsInitializedToDefaults = false;
var updateInProgress = false;
var pieChart = null;
var initialized = false;

var timeFrameIntervalData = [];
var idList = [];
var resetColors = false;

var label_colors = getRandomColor(100);

function initializePlotsAndTable()
{
	updateInProgress = false;
	initFunction();
}

function initFunction()
{	
	pieChart = document.getElementById("pie_chart_container");
	if(pieChart != null)
	{
		doUpdate(); 
		setInterval( doUpdate, 2000);
	}
	else
	{
		setTimeout(initFunction, 50); 
	} 
}

function getHostDisplay(ip)
{
	var hostDisplay = getSelectedValue("host_display");
	var host = ip;
	if(hostDisplay == "hostname" && ipToHostname[ip] != null)
	{
		host = ipToHostname[ip];
		host = host.length < 25 ? host : host.substr(0,22)+"...";
	}
	return host;
}


function getHostList(ipList)
{
	var hostList = [];
	var ipIndex =0;
	for(ipIndex=0; ipIndex < ipList.length; ipIndex++)
	{
		hostList.push( getHostDisplay(ipList[ipIndex]));
	}
	return hostList;
}


function doUpdate()
{
	if(!updateInProgress && pieChart != null)
	{
		var bdistId = getSelectedValue("time_frame");

		// get names of monitors to query (those that match bdistId)
		var downloadName = "";
		var uploadName = "";
		var mIndex=0;
		for(mIndex=0; mIndex < monitorNames.length; mIndex++)
		{
			var m = monitorNames[mIndex];
			if(m.indexOf(bdistId) >= 0)
			{
				if(m.indexOf("upload") >= 0)
				{
					uploadName = "" + m;
				}
				if(m.indexOf("download") >= 0)
				{
					downloadName = "" + m;
				}
			}
		}

		//query monitor data
		var queryNames = downloadName + " " + uploadName;
		var param = 'app=bandwidth-usage&action=get_bandwidth&' + getParameterDefinition("monitor", queryNames);
		var stateChangeFunction = function(req)
		{
			var monitors=null;
			if(req.readyState == 4)
			{
				if(!req.responseText.match(/ERROR/))
				{
					var parsed = parseMonitors(req.responseText);
					
					
					//calculate max intervals (we make everything this length by adding zeros)
					//also, get a list of all ids, in case up/down don't have same set of ips
					var numIntervals = 1;
					var dirIndex = 0;
					var latestTime = 0;
					var allIds = [];
					for(dirIndex=0; dirIndex < parsed.length; dirIndex++)
					{
						var dirData = parsed[dirIndex];
						for (id in dirData)
						{
							var idPoints = dirData[id][0];
							latestTime = parseInt(dirData[id][1]);
							numIntervals = idPoints.length > numIntervals ? idPoints.length : numIntervals;
							allIds[id] = 1;
						}
					}
					
					idList = [];
					for (id in allIds)
					{
						idList.push(id);
					}


					var currentIntervalIndex = getSelectedValue("time_interval");
					var currentIntervalText = getSelectedText("time_interval");
					var timeIntervalValues = [];
					var timeIntervalNames = [];

					var nextDate = new Date();
					nextDate.setTime(latestTime*1000);
					nextDate.setUTCMinutes( nextDate.getUTCMinutes()+tzMinutes );
					var nextIntervalStart = nextDate.valueOf()/1000;

					timeFrameIntervalData = [];
					var intervalNames = [];
					var intervalIndex;
					for (intervalIndex=0; intervalIndex < numIntervals; intervalIndex++)
					{
						var nextIntervalData = [];
						var dirIndex;
						var combinedData = [];
						for(dirIndex=0; dirIndex < parsed.length; dirIndex++)
						{
							var dirData = parsed[dirIndex];
							var nextDirData = [];
							var idIndex;
							for(idIndex=0; idIndex < idList.length; idIndex++)
							{
								var id = idList[idIndex];
								id =  id == currentWanIp ? currentLanIp : id ;	
								var value = 0;
								if(dirData[id] != null)
								{
									var idPoints = dirData[id][0];
									if(idPoints != null)
									{
										value = idPoints[idPoints.length-1-intervalIndex];
										value = value==null? 0 : parseFloat(value);
									}
								}
								nextDirData.push(value);
								combinedData[idIndex] = combinedData[idIndex] == null ? value : combinedData[idIndex] + value;
							}
							nextIntervalData.push(nextDirData);
						}
						nextIntervalData.unshift(combinedData);
						timeFrameIntervalData.push(nextIntervalData);
						
						
						
						var monthNames = UI.monthNames;
						var twod = function(num) { var nstr = "" + num; nstr = nstr.length == 1 ? "0" + nstr : nstr; return nstr; }
						
						nextDate.setTime(parseInt(nextIntervalStart)*1000);
						var intervalName = "";
						if(uploadName.match("minute"))
						{
							intervalName = "" + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
							nextDate.setUTCMinutes( nextDate.getUTCMinutes()-1);
							
						}
						else if(uploadName.match("hour"))
						{
							intervalName = "" + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
							nextDate.setUTCHours(nextDate.getUTCHours()-1);
						}
						else if(uploadName.match("day"))
						{
							intervalName = monthNames[nextDate.getUTCMonth()] + " " + nextDate.getUTCDate();
							nextDate.setUTCDate(nextDate.getUTCDate()-1);
						}
						else if(uploadName.match("month"))
						{
							intervalName = monthNames[nextDate.getUTCMonth()] + " " + nextDate.getUTCFullYear();
							nextDate.setUTCMonth(nextDate.getUTCMonth()-1);
						}
						else
						{
							var splitName = uploadName.split(/-/);
							var numIntervals = splitName.pop();
							var interval = splitName.pop();
							if(parseInt(interval) >= 28*24*60*60)
							{
								intervalName = monthNames[nextDate.getUTCMonth()] + " " + nextDate.getUTCFullYear() + " " + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
							}
							else if(parseInt(interval) >= 24*60*60)
							{
								intervalName = monthNames[nextDate.getUTCMonth()] + " " + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
							}
							else
							{
								intervalName = "" + twod(nextDate.getUTCHours()) + ":" + twod(nextDate.getUTCMinutes());
							}
							nextDate.setTime(nextDate.getTime()-(parseInt(interval)*1000));
						}
						timeIntervalNames.push(intervalName);
						timeIntervalValues.push(""+intervalIndex);
						nextIntervalStart = nextDate.valueOf()/1000;
					}
					setAllowableSelections("time_interval", timeIntervalValues, timeIntervalNames);
					if(currentIntervalIndex == null || currentIntervalIndex == 0)
					{
						setSelectedValue("time_interval", "0");
					}	
					else
					{
						setSelectedText("time_interval", currentIntervalText);
					}
				}
				updateInProgress = false;
				resetDisplayInterval();
			}
		}
		runAjax("POST", "/", param, stateChangeFunction);
	}
}

var resetPie = true;
function resetTimeFrame(){
	var pieDom = '<div class="col-sm-6 text-left" style="margin-bottom: 20px" >'
			   + 	'<canvas id="total_pie" height="200"></canvas>'
			   + '</div>'
			   + '<div class="col-sm-6 text-left" style="margin-bottom: 20px" >'
			   +	'<canvas id="down_pie" height="200"></canvas>'
			   + '</div>'
			   + '<div class="col-sm-6 text-left" style="margin-bottom: 20px" >'
			   +	'<canvas id="up_pie" height="200"></canvas>'
			   + '</div>';
	$('#pie_chart_container').empty().append(pieDom);

	resetPie = true;
	resetColors = true;
	doUpdate();
}

$('.tf_btn').click(function(){
	var id = $(this).prop('id').replace('bdistf_','');
	$('#time_frame').val('bdist' + id);
	$('.tf_btn').removeClass('active');
	$(this).addClass('active');
	resetTimeFrame();
});


function resetDisplayInterval()
{
	var plotFunction = getPieTotals;
	if(plotFunction != null && pieChart != null && (!updateInProgress) && timeFrameIntervalData.length > 0 )
	{
		updateInProgress = true;
		//first, update pie chart
		var intervalIndex = getSelectedValue("time_interval");
		intervalIndex = intervalIndex == null ? 0 : intervalIndex;
		
		var data = timeFrameIntervalData[intervalIndex];
		var pieTotals = plotFunction(idList, [bndwS.Totl, bndwS.Dnld, bndwS.Upld ], getHostList(idList), data, 0, 9, resetColors);
		resetColors = false;

		//then update table, sorting ids alphabetically so order is consistant
		var sortedIdIndices = [];
		var idIndex;
		for(idIndex=0; idIndex < idList.length; idIndex++) { sortedIdIndices.push(idIndex) };//0,1
		var idSort = function(a,b) { return idList[a] < idList[b] ? 1 : -1; }	
		sortedIdIndices.sort( idSort );//1,0
		
		var pieNames = [bndwS.Totl, bndwS.Down, bndwS.Up];
		var tableRows = [];
		var pieDatas = [];
		// pieDatas.push(data);

		var pieIndex;
		zeroPies = [];
		for(pieIndex=0; pieIndex<pieNames.length; pieIndex++)
		{
			idIndex=0;
			var pieIsZero = true;
			for(idIndex=0; idIndex < idList.length; idIndex++)
			{
				pieIsZero = pieIsZero && data[pieIndex][idIndex] == 0;
			}
			zeroPies.push(pieIsZero);
		}

		var sum = [0,0,0];
		for(idIndex=0; idIndex < sortedIdIndices.length; idIndex++)
		{
			var index = sortedIdIndices[idIndex]; 
			var id = idList[ index ];
			id =  id == currentWanIp ? currentLanIp : id ;	
			
			var tableRow = [getHostDisplay(id)];
			var pieData = [getHostDisplay(id)];
			var pieIndex;
			var allZero = true;
			for(pieIndex=0;pieIndex < pieNames.length; pieIndex++)
			{
				var value = parseBytes(data[pieIndex][index]);
				value = value.replace("ytes", "");
				tableRow.push(value);
				pieData.push(value);
				sum[pieIndex] = sum[pieIndex] + data[pieIndex][index];
			}
			for(pieIndex=0;pieIndex < pieNames.length; pieIndex++)
			{
				var percent = zeroPies[pieIndex] ? 100/idList.length : data[pieIndex][index]*100/pieTotals[pieIndex];
				// var percent = zeroPies[pieIndex] ? 100/idList.length : data[pieIndex][index]*100/sum[pieIndex];
				var pctStr = "" + (parseInt(percent*10)/10) + "%";
				tableRow.push(pctStr);
				pieData.push(pctStr);
			}
			tableRows.push(tableRow);
			pieDatas.push(pieData);
		}
		tableRows.push([UI.Sum,parseBytes(sum[0]),parseBytes(sum[1]),parseBytes(sum[2]),"","",""]);


		var columnNames = [bndwS.Host];
		for(pieIndex=0;pieIndex < pieNames.length; pieIndex++){ columnNames.push(pieNames[pieIndex]); }
		for(pieIndex=0;pieIndex < pieNames.length; pieIndex++){ columnNames.push(pieNames[pieIndex] + " %"); }
	
		/* 表格数据就从这里拿到了 */

		if(total_pie!='undefined' && down_pie!='undefined' && up_pie!='undefined' && !resetPie){
			makePieChart(pieDatas,true);
		}else{
			makePieChart(pieDatas);
		}

		var dom = createTr(tableRows);
		$('#bdist_data_container').empty();
		$('#bdist_data_container').append(dom);
		Ha.setFooterPosition();
		updateInProgress = false;
	}
}

function getPieTotals(individualNames, pieNames, individualLabels, values, rankIndex, maxIndividualNames, recomputeColorsAndVisible, adjustLabelFunction){
	var sum = [0,0,0];
	for(var i=0; i<3; i++){
		for(var j=0; j<individualNames.length; j++){
			sum[i] += values[i][j];
		}
		if(sum[i] == 0){
			sum[i] = individualNames.length;
		}
	}
	return sum;
}

var total_pie,up_pie,down_pie,total_cxt,up_cxt,down_cxt,label_total,label_down,label_up,total_data,down_data,up_data;
var total_config,down_config,up_config;

function makePieChart(data,isUpdate){
	var label = [];
	for(var i=0; i<data.length; i++){
		label.push(data[i][0] + '(' + data[i][4] + '|' + data[i][5] + '|' + data[i][6] + ')');
	}
	total_cxt = document.getElementById('total_pie');
	down_cxt = document.getElementById('down_pie');
	up_cxt = document.getElementById('up_pie');

	var label_num = data.length;
	var color = label_colors.slice(0,label_num);

	label_total = getPieLabel(data,'total');
	label_down = getPieLabel(data,'down');
	label_up = getPieLabel(data,'up');
	total_data = getPieData(data,'total');
	down_data = getPieData(data,'down');
	up_data = getPieData(data,'up');


	total_config = configPie(total_data,label_total,color,UI.Total);
	down_config = configPie(down_data,label_down,color,UI.Download);
	up_config = configPie(up_data,label_up,color,UI.Upload);
	

	if(isUpdate){
		for(var i=0; i<label.length; i++){
			$('#legend_text_' + i).html(label[i]);
		}

		$('.legend_item').each(function(){
			var hidden = $(this).find('.line-through').hasClass('hidden');
			var id = $(this).find('.legend_label').find('span').prop('id');
			var locate = id.split('_').pop();
			if(!hidden){
				total_data[locate] = 0;
				down_data[locate] = 0;
				up_data[locate] = 0;
			}
		});
		total_pie.config.data.labels = label_total;
		down_pie.config.data.labels = label_down;
		up_pie.config.data.labels = label_up;
		total_pie.config.data.datasets[0].data = total_data;
		down_pie.config.data.datasets[0].data = down_data;
		up_pie.config.data.datasets[0].data = up_data;

		total_pie.update();
		down_pie.update();
		up_pie.update();

		return;
	}

	$('#legend_container').empty();
	for(var i=0; i<label.length; i++){
    	var legend_dom = '<div class="legend_item" style="background-color: ' + color[i] + '">'
    				   + 	'<span class="legend_label">&nbsp;&nbsp;<span id="legend_text_' + i + '">' + label[i] + '</span></span>'
    				   +	'<span class="line-through hidden"></span>'
    				   + '</div>';
    	$('#legend_container').append(legend_dom);
    }

    $('.legend_item').click(function(){
    	if($(this).find('.line-through').hasClass('hidden')){
    		$(this).find('.line-through').removeClass('hidden');
    		makePieChart(data,true);
    	}else{
    		$(this).find('.line-through').addClass('hidden');
    		makePieChart(data,true);
    	}
    });

    

	total_pie = new Chart(total_cxt,total_config);
	down_pie = new Chart(down_cxt,down_config);
	up_pie = new Chart(up_cxt,up_config);

	resetPie = false;
}


function getRandomColor(num){
	var colors = [];
	for(var i=0; i<num; i++){
	 	var color = 'rgb(' + randomColorFactory() + ',' + randomColorFactory() + ',' + randomColorFactory() + ')';
	 	colors.push(color);
	}
	return colors;
}

function randomColorFactory(){
	return Math.round(Math.random()*255);
}

function getPieData(data,type){
	var datas = [];
	if(type=='total'){
		for(var i=0; i<data.length; i++){
			datas.push(parseFloat(data[i][4]));
		}
	}else if(type=='down'){
		for(var i=0; i<data.length; i++){
			datas.push(parseFloat(data[i][5]));
		}
	}else{
		for(var i=0; i<data.length; i++){
			datas.push(parseFloat(data[i][6]));
		}
	}
	return datas;
}

function getPieLabel(data,type){
	var label = [];
	if(type=='total'){
		for(var i=0; i<data.length; i++){
			label.push(data[i][0] + '_' + data[i][1] + '_' + data[i][4]);
		}
	}else if(type=='down'){
		for(var i=0; i<data.length; i++){
			label.push(data[i][0] + '_' + data[i][2] + '_' + data[i][5]);
		}
	}else{
		for(var i=0; i<data.length; i++){
			label.push(data[i][0] + '_' + data[i][3] + '_' + data[i][6]);
		}
	}
	return label;
}

function configPie(data,label,color,type){
	var config = {
		type: 'pie',
        data: {
	        labels: label,
	        datasets: [
	            {
	                data: data,
	                backgroundColor: color,
	                hoverBackgroundColor: color
	            }]
	    },
        options:{
        	legend: {
        		display: false
        	},
        	title:{
                display:true,
                text: type
            },
            tooltips: {
                enabled: true,
                callbacks: {
                    label: resetLabels
                }
            }
        }
	}

	return config;
}

function resetLabels(arr,data){
	var data = data.labels[arr.index];
	var datas = data.split('_');
	var label = [];
	label.push(datas[0]);
	label.push(datas[1]);
	label.push(datas[2]);
	return label;
}

function createTr(data){
	var dom = ''
	for(var i=0; i<data.length; i++){
		var td_dom = '';
		for(var j=0; j<data[i].length; j++){
			td_dom += '<td>' + data[i][j] + '</td>';
		}
		dom += '<tr>' + td_dom + '</tr>';
	}
	return dom;
}

function parseMonitors(outputData)
{
	var monitors = [ [],[] ];
	var dataLines = outputData.split("\n");
	var currentDate = parseInt(dataLines.shift());
	var lineIndex;
	for(lineIndex=0; lineIndex < dataLines.length; lineIndex++)
	{
		if(dataLines[lineIndex].length > 0)
		{
			var monitorType = (dataLines[lineIndex].split(/[\t ]+/))[0];
			monitorType = monitorType.match(/download/) ? 0 : 1;
			var monitorIp = (dataLines[lineIndex].split(/[\t ]+/))[1];

			lineIndex++; 
			var firstTimeStart = dataLines[lineIndex];
			lineIndex++;
			var firstTimeEnd = dataLines[lineIndex];
			lineIndex++; 
			var lastTimePoint = dataLines[lineIndex];
			lineIndex++;
			var points = dataLines[lineIndex].split(",");
			if(monitorIp != "COMBINED")
			{
				monitors[monitorType][monitorIp] = [points, lastTimePoint ];
			}
		}
	}
	return monitors;
}

initializePlotsAndTable();



function setBrowserTimeCookie()
{
	var browserSecondsUtc = Math.floor( ( new Date() ).getTime() / 1000 );
	document.cookie="browser_time=" +browserSecondsUtc + "; path=/"; //don't bother with expiration -- who cares when the cookie was set? It just contains the current time, which the browser already knows
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
		alert("Error: " + selectId + " Not Existes");
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

function getParameterDefinition(parameter, definition)
{
	return(encodeURIComponent(parameter) + "=" + encodeURIComponent(definition));
}

function getSelectedText(selectId, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	selectedIndex = controlDocument.getElementById(selectId).selectedIndex;
	selectedText = "";
	if(selectedIndex >= 0)
	{
		selectedText= controlDocument.getElementById(selectId).options[ controlDocument.getElementById(selectId).selectedIndex ].text;
	}
	return selectedText;

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

function setSelectedText(selectId, selection, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	selectElement = controlDocument.getElementById(selectId);
	selectionFound = false;
	for(optionIndex = 0; optionIndex < selectElement.options.length && (!selectionFound); optionIndex++)
	{
		selectionFound = (selectElement.options[optionIndex].text == selection);
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