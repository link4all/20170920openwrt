// var wifiLines = new Array();
// var interfaces;
// $.post('/','app=wifi-spectrum&action=get_dev',function(data){
// 	var interfacedata = [];
// 	for(var key in data){
// 		var inter = [];
// 		inter.push(data[key]);
// 		if(key == 'dev_2_4'){
// 			inter.push('2.4GHz');
// 		}else{
// 			inter.push('5GHz');
// 		}
// 		interfacedata.push(inter);
// 	}
// 	if(interfacedata.length == 0) { interfacedata = -1; }
// 	interfaces = interfacedata;
// 	initialiseAll();
// },'json');

var interfaces;
var freq_low;
var freq_high;
var detected;
var band;
var plotdata = [];
var legendCount;

// Xband = [[channel #],[centre freq],[low freq],[high freq]]
var gband = [
				[1,2,3,4,5,6,7,8,9,10,11,12,13,14],
				[2.412,2.417,2.422,2.427,2.432,2.437,2.442,2.447,2.452,2.457,2.462,2.467,2.472,2.484],
				[2.401,2.406,2.411,2.416,2.421,2.426,2.431,2.436,2.441,2.446,2.451,2.456,2.461,2.473],
				[2.423,2.428,2.433,2.438,2.443,2.448,2.453,2.458,2.463,2.468,2.473,2.478,2.483,2.495]
			]
var aband = [
				[36,40,44,48,52,56,60,64,100,104,108,112,116,120,124,128,132,136,140,149,153,157,161,165],
				[5.180,5.200,5.220,5.240,5.260,5.280,5.300,5.320,5.500,5.520,5.540,5.560,5.580,5.600,5.620,5.640,5.660,5.680,5.700,5.745,5.765,5.785,5.805,5.825],
				[5.170,5.190,5.210,5.230,5.250,5.270,5.290,5.310,5.490,5.510,5.530,5.550,5.570,5.590,5.610,5.630,5.650,5.670,5.690,5.735,5.755,5.775,5.795,5.815],
				[5.190,5.210,5.230,5.250,5.270,5.290,5.310,5.330,5.510,5.530,5.550,5.570,5.590,5.610,5.630,5.650,5.670,5.690,5.710,5.755,5.775,5.795,5.815,5.835]
			]

function initialiseAll()
{
	var ivalues = [];
	var inames = [];
	//First, we should adjust the drop down list for the interfaces. We should identify which ones are 2.4 and 5ghz as well.
	// interfaces = interfaces;
	interfaces = parseInterfaces(wifiLines);
	if(interfaces != -1)
	{
		for(var x = 0; x < interfaces.length; x++)
		{
			ivalues.push(interfaces[x][0]);
			inames.push(interfaces[x][0] + ' ' + interfaces[x][1]);
		}
		setAllowableSelections('interface', ivalues, inames);
		
		// $('option').each(function(index){
		// 	var mod = $(this).html();
		// 	mod = mod.replace(/wlan\d\s/,'');
		// 	if(mod == '2.4GHz'){
		// 		$(this).prop('selected',true);
		// 	}else{
		// 		$(this).prop('selected',false);
		// 	}
		// });
		changeBand();
		// initialisePlots();

		// getWifiData();
	}
	//otherwise do nothing
}


function initialisePlots()
{
	//get the selected band, and then set the limits of the graph appropriately
	band = interfaces[document.getElementById("interface").selectedIndex][1];
	if(band == "2.4GHz")
	{
		freq_low = 2.4;		//technically 2.401, but 2.400 graphs better
		freq_high = 2.5;		//technically 2.495, but 2.500 graphs better
	}
	else
	{
		freq_low = 5.165;	//technically 5.170, but 5.165 graphs better
		freq_high = 5.840;	//technically 5.835, but 5.840 graphs better
	}
}

function changeBand()
{
	var mod = $('#interface').val();
	var type = $('[value="' + mod + '"]').html();
	if(type.indexOf('2.4') > -1){
		$('#sm-range,#xs-range').addClass('hidden');
	}else{
		$('#sm-range,#xs-range').removeClass('hidden')
	}
	initialisePlots();
	getWifiData();
}

function parseInterfaces(lines)
{
	//if we have no interfaces detected, exit
	if(lines.length == 0) { return -1; }

	//otherwise, populate the data and assign correct frequency band
	var interfaceData = [];
	lineIndex = 0;

	//lines is of the format:	wlanX ##; wlanY ##; etc etc.
	for(lineIndex=0; lineIndex < lines.length; lineIndex++)
	{
		var nextLine = lines[lineIndex];
		var wlan = nextLine.split(" ");

		var guest  = wlan[0].indexOf("-");
		if(guest != -1)
		{
			continue;
		}

		var interfaceid = wlan[0];
		if(wlan[1] > 14)
		{
			var interfaceband = "5GHz";
		}
		else
		{
			var interfaceband = "2.4GHz";
		}

		interfaceData.push( [ interfaceid, interfaceband ] );
	}
	return interfaceData;
}


function getWifiData()
{
	Ha.mask.show();
	var Commands = [];
	var parsedWifiData = [];
	//推荐接口
	var mod = $('#interface').val();
	var param = 'app=wifi-spectrum&action=get_scan&dev=' + mod;
	var stateChangeFunction = function(data)
	{
			var shell_output = data.replace(/Success/, "");		//raw output from the shell
			shell_output = shell_output.replace(/\"/g,"");					//remove any doubleq quotes
			parsedWifiData = parseWifiData(shell_output);
			if(parsedWifiData == -1)
			{
				Ha.mask.hide();
				$('#canvas').remove();
				Ha.showNotify({status: 1,msg: UI.There_does_not_have_any_SSID});
				//自动切换(或者只显示文本信息)
				// setTimeout(function(){
				// 	$('#interface').find('option').each(function(){
				// 		$(this).prop('selected',false);
				// 	});
				// 	changeBand();
				// 	// setTimeout(changeBand,0);
				// },5000);
			}
			else
			{
				Ha.mask.hide();
				// $('#canvas').remove();
				// $('#line_container').append('<canvas id="canvas"></canvas>');
				var type = $('[value="' + mod + '"]').html();
				if(type.indexOf('2.4') > -1){
					type = 2.4;
				}else{
					type = 5;
				}

				var lines = getPointsData(parsedWifiData);
				createLines(lines,type);

			}
			$('#footer').removeClass('absolute');
	}
	$.post('/',param,stateChangeFunction);
}

//获取数据点
function getPointsData(detected){
	var plotdata=[];
	var freqoffset=.001;//for making the graphs look pretty
	var htoffset=4;//for 802.11n channels
	var vhtoffset=12;//for 802.11ac channels
	if(band=="2.4GHz"){
		for(x=0;x<detected[0].length;x++){
			var SSID=detected[0][x];
			var channel=detected[1][x];
			var secondary=detected[2][x];
			var level=detected[3][x];
			plotdata[x] = {ssid: SSID,level: parseInt(level),channel: parseInt(channel),secondary: secondary};
			var index = gband[0].indexOf(parseInt(channel));
			plotdata[x].freq = gband[1][index];
			if(secondary=="no secondary"){
				plotdata[x].lowfreq = getfreqData(channel,2);
				plotdata[x].highfreq = getfreqData(channel,3);
				
			}
			if(secondary=="above"){
				plotdata[x].lowfreq = getfreqData(channel,2);
				plotdata[x].highfreq = getfreqData(channel- -htoffset,3);
				
			}
			if(secondary=="below"){
				plotdata[x].lowfreq = getfreqData(channel-htoffset,2);
				plotdata[x].highfreq = getfreqData(channel,3);
			
			}
			plotdata[x].channel_low = plotdata[x].channel - (plotdata[x].freq*1000 - plotdata[x].lowfreq*1000 - 1)/5;
			plotdata[x].channel_high = plotdata[x].channel + ((plotdata[x].highfreq*1000 - 1) - plotdata[x].freq*1000)/5;
		}
	}else if(band=="5GHz"){
		for(x=0;x<detected[0].length;x++){
			var SSID=detected[0][x];
			var channel=detected[1][x];
			var secondary=detected[2][x];
			var level=detected[3][x];
			var vhtwidth=detected[4][x];
			plotdata[x] = {ssid: SSID,level: parseInt(level),channel: parseInt(channel),secondary: secondary};
			var index = aband[0].indexOf(parseInt(channel));
			plotdata[x].freq = aband[1][index];
			if(secondary=="no secondary"){
				plotdata[x].lowfreq = getfreqData(channel,2);
				plotdata[x].highfreq = getfreqData(channel,3);
			}
			if(secondary=="above"){
				if(!vhtwidth){
					plotdata[x].lowfreq = getfreqData(channel,2);
					plotdata[x].highfreq =  getfreqData(channel- -htoffset,3);
				}else{
					plotdata[x].lowfreq = getfreqData(channel,2);
					plotdata[x].highfreq =  getfreqData(channel- -vhtoffset,3);
				}
			}
			if(secondary=="below"){
				plotdata[x].lowfreq = getfreqData(channel-htoffset,2);
				plotdata[x].highfreq =  getfreqData(channel,3);
			}
			plotdata[x].channel_low = plotdata[x].channel - ((plotdata[x].freq*100 - plotdata[x].lowfreq*100)*2);
			plotdata[x].channel_high = plotdata[x].channel + ((plotdata[x].highfreq*100 - plotdata[x].freq*100)*2);
		}
	}else{
		plotdata=-1
		//something is wroooooooooooooooooong
	}
	legendCount = plotdata.length;
	var lines = parsePoints(plotdata);
	return lines;
}
function parsePoints(plotdata){
	var lines = [];
	for(var i=0; i<plotdata.length; i++){
		var line = {};
		line.channel = plotdata[i].channel;
		if(plotdata[i].ssid.indexOf('\\x') > -1){
			plotdata[i].ssid = plotdata[i].ssid.replace(/\\x/g,'%');
			plotdata[i].ssid = plotdata[i].ssid.replace(/%00/g,'');
			plotdata[i].ssid = decodeURI(plotdata[i].ssid);
		}
		line.label = plotdata[i].ssid ? plotdata[i].ssid : UI.Unknow_device;
		line.lowfreq = plotdata[i].lowfreq;
		line.highfreq = plotdata[i].highfreq;
		line.freq = plotdata[i].freq;
		line.level = parseInt(plotdata[i].level) >= -100 ? parseInt(plotdata[i].level) : -100;
		line.data = [];
		var firstX = plotdata[i].channel_low;
		var lastX = plotdata[i].channel_high;		

		line.data[0] = {x: firstX,y: 0};
		line.data[1] = {x: line.channel,y: line.level + 100};
		line.data[2] = {x: lastX,y: 0};
		lines.push(line);
	}
	return lines;
}

function createLines(data,mod){
	var scatterChartData = {
	  datasets: data
	};
	var placeholderline = {
	  label: '',
	  data: [{
	      x: -2,
	      y: 100,
	  }, {
	      x: 16,
	      y: 0,
	  }]
	};
	scatterChartData.datasets.push(placeholderline);
	var setColors = function(i,dataset){
		var color = randomColor(0.6);
      dataset.borderColor = color;
      dataset.backgroundColor = randomColor(0.1,color);
      dataset.pointBorderColor = randomColor(0.7,color);
      dataset.pointBackgroundColor = randomColor(0.5,color);
      dataset.pointBorderWidth = 1;

      if(dataset.label == ''){
        dataset.pointBorderColor = 'transparent';
        dataset.pointBackgroundColor = 'transparent';
        dataset.pointBorderWidth = 0;
        dataset.borderColor = 'transparent';
        dataset.backgroundColor = 'transparent';
      }
	}
	$.each(scatterChartData.datasets, setColors);
  $('#line_container').empty();
  $('.chartjs-hidden-iframe').remove();
  if(mod == 2.4){
  	console.log(scatterChartData)
		$('#line_container').append('<canvas id="canvas"></canvas>');
	  var ctx = document.getElementById("canvas").getContext("2d");
	  var width = $(window).width();
  	if(width <= 768){
  		$('#line_container').find('canvas').prop('height',360 + legendCount*12);
  	}
	  window.myScatter = Chart.Scatter(ctx, setConfig(scatterChartData,[1,2,3,4,5,6,7,8,9,10,11,12,13,16],-2,16,1,setTick2_4,'2401-2495 MHz'));
  }else if(mod == 5){
  	scatterChartData.datasets.pop();
  	var len1,len2,len3,lineData_1={datasets: []},lineData_2={datasets: []},lineData_3={datasets: []};
  	for(var i=0; i<scatterChartData.datasets.length; i++){
  		if(scatterChartData.datasets[i].channel < 100){
  			lineData_1.datasets.push(scatterChartData.datasets[i]);
  		}else if(scatterChartData.datasets[i].channel < 149){
  			lineData_2.datasets.push(scatterChartData.datasets[i]);
  		}else{
  			lineData_3.datasets.push(scatterChartData.datasets[i]);
  		}
  	}
  	for(var n=0; n<lineData_3.datasets.length; n++){
  		for(var m=0; m<lineData_3.datasets[n].data.length; m++){
  			lineData_3.datasets[n].data[m].x -= 1;
  		}
  	}
  	len1 = lineData_1.datasets.length;
  	len2 = lineData_2.datasets.length;
  	len3 = lineData_3.datasets.length;
  	var maxlen = Math.max(len1,len2,len3);

  	$('#5g_1_btn').find('.badge').html(len1 || '');
  	$('#5g_2_btn').find('.badge').html(len2 || '');
  	$('#5g_3_btn').find('.badge').html(len3 || '');
  	$('#xs-range').find('[value="5g_1"]').html('5170-5330 (' + len1 + ')');
  	$('#xs-range').find('[value="5g_2"]').html('5490-5710 (' + len2 + ')');
  	$('#xs-range').find('[value="5g_3"]').html('5735-5835 (' + len3 + ')');
  	lineData_1.datasets.push({
  		label: '',
		  data: [{
		      x: 36,
		      y: 100,
		  }, {
		      x: 64,
		      y: 0,
		  }]
  	});
  	lineData_2.datasets.push({
  		label: '',
		  data: [{
		      x: 96,
		      y: 100,
		  }, {
		      x: 142,
		      y: 0,
		  }]
  	});
  	lineData_3.datasets.push({
  		label: '',
		  data: [{
		      x: 145,
		      y: 100,
		  }, {
		      x: 167,
		      y: 0,
		  }]
  	});
  	$.each(lineData_1.datasets, setColors)
  	$.each(lineData_2.datasets, setColors)
  	$.each(lineData_3.datasets, setColors)
  	$('#line_container').append('<canvas id="5g_1"></canvas><canvas id="5g_2"></canvas><canvas id="5g_3"></canvas>')
  	var width = $(window).width();
  	if(width <= 768){
  		$('#line_container').find('canvas').prop('height',360 + legendCount*12);
  	}
  	var ctx_1 = document.getElementById("5g_1").getContext("2d");
  	var ctx_2 = document.getElementById("5g_2").getContext("2d");
  	var ctx_3 = document.getElementById("5g_3").getContext("2d");
  	window.Scatter_5g1 = Chart.Scatter(ctx_1, setConfig(lineData_1,[36,40,44,48,52,56,60,64],32,72,4,setTick,'5170-5330 MHz'));
  	
	  window.Scatter_5g2 = Chart.Scatter(ctx_2, setConfig(lineData_2,[100,104,108,112,116,120,124,128,132,136,140],96,142,4,setTick,'5490-5710 GHz'));
	  
	  window.Scatter_5g3 = Chart.Scatter(ctx_3, setConfig(lineData_3,[148,152,156,160,164],144,168,4,setTick3,'5735-5835 GHz'));

	  if(len1 == maxlen){
  		changeRange(1);
  	}else if(len2 == maxlen){
  		changeRange(2);
  	}else{
  		changeRange(3);
  	}
  }
}

$('#xs-range').change(function(){
	console.log($(this).val());
	var range = $(this).val().replace('5g_','');
	changeRange(range);
});
$('#sm-range').find('.btn').click(function(){
	var id = $(this).prop('id');
	var range = id.replace('5g_','').replace('_btn','');
	changeRange(range);
});
function changeRange(range){
	$('#5g_2,#5g_3,#5g_1').addClass('hidden');
	$('#5g_' + range).removeClass('hidden');
	$('#sm-range').find('.btn').removeClass('active');
	$('#5g_' + range + '_btn').addClass('active');
	$('#xs-range').val('5g_' + range);
}
function setConfig(data,range,min,max,step,tickCallback,title){
	var config = {
		type: 'line',
	  data: data,
	  options: {
	      title: {
	          display: true,
	          text: title
	      },
	      tooltips: {
	          enabled: true,
	          callbacks: {
	              label: function(arr,data){
	                  return setLabel(arr,data);
	              }
	          }
	      },
	      scales: {
	          xAxes: [{
	              position: 'bottom',
	              ticks: {
	                  autoSkip: false,
	                  min: min,
	                  max: max,
	                  stepSize: step,
	                  userCallback: function(tick) {
	                      var bands = range;
	                      return tickCallback(tick,bands);
	                  },
	              },
	              scaleLabel: {
	                  display: true,
	                  labelString: UI.Wireless_channel__GHz,
	                  fontSize: 14
	              }
	          }],
	          yAxes: [{
	              position: 'left',
	              ticks: {
	                  userCallback: function(tick) {
	                      return setTicky(tick);
	                  },
	              },
	              scaleLabel: {
	                  display: true,
	                  labelString: UI.Signal_strength__dBm,
	                  fontSize: 14
	              }
	          }]
	      }
	  }
	}
	return config;
}
function setTick2_4(tick,range){
	if(range.indexOf(tick) < 0){
      return '';
  }else if(tick == 16){
      return 14;
  }else{
      return tick;
  }
}
function setTick(tick,range){
	if(range.indexOf(tick) >= 0){
      return tick;   
  }else{
      return '';
  }
}
function setTick3(tick,range){
  if(range.indexOf(tick) >= 0){
      return tick + 1;   
  }else{
      return '';
  }
}
function setTicky(tick){
	if(tick == 100){
      return '';
  }else{
      return tick - 100;
  }
}
function setLabel(arr,data){
    var msg = [];
    var label = data.datasets[arr.datasetIndex].label;
    var level = 'level: ' + (data.datasets[arr.datasetIndex].level) + 'dBm';
    var cha = 'channel: ' + (data.datasets[arr.datasetIndex].channel);
    var freq;
    if(arr.index == 0){
        freq = 'lowfreq: ' + (data.datasets[arr.datasetIndex].lowfreq) + 'MHz';
    }else if(arr.index == 1){
        freq = 'freq: ' + (data.datasets[arr.datasetIndex].freq) + 'MHz';
    }else{
        freq = 'highfreq: ' + (data.datasets[arr.datasetIndex].highfreq) + 'MHz';
    }
    msg.push(label);
    msg.push(level);
    msg.push(cha);
    msg.push(freq);
    if(label == ''){
        return '';
    }
    return msg;
}

function randomColor(opacity,origin) {
    if(typeof origin == 'undefined'){
        return 'rgba(' + Math.round(Math.random() * 255) + ',' + Math.round(Math.random() * 255) + ',' + Math.round(Math.random() * 255) + ',' + (opacity || '.3') + ')';
    }else{
        var color = origin.split(',');
        color[3] = opacity + ')';
        return color.join(',');
    }
};
function parseWifiData(rawScanOutput)
{
	if((rawScanOutput != null) && (rawScanOutput.indexOf("\n") != 0) && (rawScanOutput.indexOf("\r") != 0))
	{
		var parsed = [ [],[],[],[],[] ];
		var cells = rawScanOutput.split(/BSS [A-Fa-f0-9]{2}[:]/g);
		cells.shift(); //get rid of anything before first AP data
	
		var getCellValues=function(id, cellLines)
		{
			var vals=[];
			var lineIndex;
			for(lineIndex=0; lineIndex < cellLines.length; lineIndex++)
			{
				var line = cellLines[lineIndex];
				var idIndex = line.indexOf(id);
				var cIndex  = line.indexOf(":");
				var eqIndex = line.indexOf("=");
				var splitIndex = cIndex;
				if(splitIndex < 0 || (eqIndex >= 0 && eqIndex < splitIndex))
				{
					splitIndex = eqIndex;
				}
				if(idIndex >= 0 && splitIndex > idIndex)
				{
					var val=line.substr(splitIndex+1);
					val = val.replace(/^[^\"]*\"/g, "");
					val = val.replace(/\".*$/g, "");
					val = val.replace(/^[ ]/g,"");
					val = val.replace(/ dBm/g,"");
					val = val.replace(/channel /g,"");
					vals.push(val);
				}
			}
			return vals;
		}

		while(cells.length > 0)
		{
			var cellData  = cells.shift();
			var cellLines = cellData.split(/[\r\n]+/);

			var ssid    = getCellValues("SSID", cellLines).shift();
			var prichannel = getCellValues("DS Parameter set", cellLines).shift();
			var secchannel = getCellValues("secondary channel offset", cellLines).shift();
			var sigStr = getCellValues("signal", cellLines).shift();
			var vhtwidth = getCellValues("* channel width", cellLines).shift();

			//if we don't get a primary channel then the network isn't following the standard. attempt to retrieve it from the HT operation data. If we can't find this section then toss it out.
			if (! prichannel)
			{
				var prichannel = getCellValues("* primary channel", cellLines).shift();
			}
			if (! secchannel)
			{
				secchannel = "no secondary";	//if we don't get a result for the secondary channel, set it to this so we don't error
			}

			if(ssid != null && prichannel != null && secchannel != null && sigStr != null ) 
			{
				parsed[0].push(ssid);
				parsed[1].push(prichannel);
				parsed[2].push(secchannel);
				parsed[3].push(sigStr);
				parsed[4].push(vhtwidth);
				//parsed[4].push( prichannel > 30 ? "5GHz" : "2.4GHz")	we don't need this anymore
			}
		}
		//check for duplicate data and append _# if necessary
		for(x = 0; x < parsed[0].length; x++)
		{
			append = 2;
			for(y = (x+1); y < parsed[0].length; y++)
			{
				if((parsed[0][x] == parsed[0][y])/* && (parsed[4][x] == parsed[4][y])*/)	//second part only necessary if we end up scanning both spectrum at once
				{
					parsed[0][y] = parsed[0][y]+"_"+append;
					append += 1;
				}
			}
			if(append > 2)
			{
				parsed[0][x] = parsed[0][x]+"_1";
			}
		}
		return parsed;
	}
	else
	{
		return(-1);
	}
}


function getfreqData(channel,info)
{
	//info = 1, return centrefreq	info = 2, return lowfreq	info = 3, return highfreq
	if(channel > 14)
	{
		a = aband[0].indexOf(parseInt(channel));
		return aband[info][a];
	}
	else
	{
		a = gband[0].indexOf(parseInt(channel));
		return gband[info][a];
	}
}


//common 方法
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
function removeAllOptionsFromSelectElement(selectElement)
{
	while(selectElement.length > 0)
	{
		try { selectElement.remove(0); } catch(e){}
	}
}
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

initialiseAll();