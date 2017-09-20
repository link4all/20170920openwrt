
var UI = {};
UI.SaveChanges="Save Changes";
UI.Reset="Reset";
UI.Clear="Clear History";
UI.Delete="Delete Data";
UI.DNow="Download Now";
UI.Visited="Visited Sites";
UI.Requests="Search Requests";
UI.Add="Add";
UI.Remove="Remove";
UI.DDNSService="DDNS Service";
UI.WakeUp="Wake Up";
UI.NewRule="Add New Rule";
UI.NewQuota="Add New Quota";
UI.AddRule="Add Rule";
UI.AddSvcCls="Add Service Class";
UI.Edit="Edit";
UI.Select="Select";
UI.ChPRoot="Change Plugin Root";
UI.AddPSource="Add Plugin Source";
UI.Uninstall="Uninstall";
UI.Install="Install";
UI.RefreshPlugins="Refresh Plugins";
UI.GetBackup="Get Backup Now";
UI.RestoreConfig="Restore Configuration Now";
UI.RestoreDefault="Restore Default Configuration Now";
UI.Upgrade="Upgrade Now";
UI.Reboot="Reboot Now";
UI.MoreInfo="More Info";
UI.Hide="Hide Text";
UI.WaitSettings="Please wait while new settings are applied. . .";
UI.Wait="Please wait. . .";
UI.ErrChanges="Changes could not be applied";
UI.Always="Always";
UI.Disabled="Disabled";
UI.Enabled="Enabled";
UI.Sunday="Sunday";
UI.Monday="Monday";
UI.Tuesday="Tuesday";
UI.Wednesday="Wednesday";
UI.Thursday="Thursday";
UI.Friday="Friday";
UI.Saturday="Saturday";
UI.Sun="Sun";
UI.Mon="Mon";
UI.Tue="Tue";
UI.Wed="Wed";
UI.Thu="Thu";
UI.Fri="Fri";
UI.Sat="Sat";
UI.unk="unknown";
UI.HsNm="Hostname";
UI.HDsp="Host Display";
UI.DspHn="Display Hostnames";
UI.DspHIP="Display Host IPs";

UI.never="never";
UI.disabled="disabled";
UI.both="both";
UI.seconds="seconds";
UI.minutes="minutes";
UI.hours="hours";
UI.days="days";
UI.second="second";
UI.minute="minute";
UI.hour="hour";
UI.day="day";
UI.month="month";
UI.year="year";
UI.sc="s"; //abbr for second
UI.hr="hr"; //abbr for hour
UI.pAM="";
UI.pPM="";
UI.hAM="AM";
UI.hPM="PM";

UI.EMonths=["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

UI.byt="bytes";
UI.Bu="B";
UI.KB="kB";
UI.MB="MB";
UI.GB="GB";
UI.TB="TB";
UI.KB1="kByte";
UI.MB1="MByte";
UI.GB1="GByte";
UI.TB1="TByte";
UI.KBy="kBytes";
UI.MBy="MBytes";
UI.GBy="GBytes";
UI.TBy="TBytes";
UI.Kbs="kbits/s";
UI.KBs="kBytes/s";
UI.MBs="MBytes/s";

UI.CApplyChanges="Close and Apply Changes";
UI.CDiscardChanges="Close and Discard Changes";
UI.waitText="Please Wait While Settings Are Applied";
UI.Cancel="Cancel";

UI.Err="ERROR";
UI.prfErr="There is an error in";
UI.nex="does not exist";
UI.InvAdd="ERROR: Invalid Address";

UI.CPass="Confirm Password";
UI.OK="OK";
UI.VPass="Verifying Password...";
UI.sprt="SSH port";
UI.wsprt="web server port";
UI.prdr="port redirected to router";
UI.puse="port in use by router";
UI.pfwd="port forwarded to";
UI.conn="connected";

UI.AJAX="AJAX Browser Support Needed";
UI.AJAXUpg="Please upgrade to an AJAX compatible browser and try again. Such browsers include Firefox 2.0+, Safari and IE 6+.";

var connTS=new Object();
connTS.CCSect="Current Connections";
connTS.RRate="Refresh Rate";
connTS.BUnt="Bandwidth Units";
connTS.AtMxd="Auto (Mixed)";
connTS.CnWarn="Connections between local hosts and the router are not displayed.";
connTS.PrNm="Proto";
connTS.WLNm="WAN Host/LAN Host";
connTS.UDNm="Bytes Up/Down";
connTS.QSNm="QoS Up/Down";
connTS.LPNm="L7 Proto";

// var TSort_Data = new Array('connection_table', 's', 's', 'm', 's', 's');

var updateInProgress;
var timeSinceUpdate;

var httpsPort ="";
var httpPort = "";
var remoteHttpsPort = "";
var remoteHttpPort = "";

var qosUpMask = "";
var qosDownMask = "";
var markToQosClass = [];

function initializeConnectionTable()
{
	httpsPort = getHttpsPort()
	httpPort  = getHttpPort()

	setSelectedValue("host_display", "hostname");

	remoteHttpsPort = "";
	remoteHttpPort = "";
	var remoteAcceptSections = uciOriginal.getAllSectionsOfType("firewall", "remote_accept");
	var acceptIndex=0;
	for(acceptIndex = 0; acceptIndex < remoteAcceptSections.length; acceptIndex++)
	{
		var section = remoteAcceptSections[acceptIndex];
		var localPort = uciOriginal.get("firewall", section, "local_port");
		var remotePort = uciOriginal.get("firewall", section, "remote_port");
		var proto = uciOriginal.get("firewall", section, "proto").toLowerCase();
		var zone = uciOriginal.get("firewall", section, "zone").toLowerCase();
		if((zone == "wan" || zone == "") && (proto == "tcp" || proto == ""))
		{
			remotePort = remotePort == "" ? localPort : remotePort;
			if(localPort == httpsPort && localPort != "")
			{
				remoteHttpsPort = remotePort;
			}
			else if(localPort == httpPort && localPort != "")
			{
				remoteHttpPort = remotePort;
			}
		}
	}

	var qmIndex=0;
	for(qmIndex=0; qmIndex < qosMarkList.length; qmIndex++)
	{
		var mask=  parseInt((qosMarkList[qmIndex][3]).toLowerCase());
		qosUpMask   = qosMarkList[qmIndex][0] == "upload"   ? mask: qosUpMask;
		qosDownMask = qosMarkList[qmIndex][0] == "download" ? mask : qosDownMask;
		markToQosClass[ parseInt(qosMarkList[qmIndex][2]) ] = qosMarkList[qmIndex][1];
	}

	updateInProgress = false;
	timeSinceUpdate = -5000;
	setInterval("checkForRefresh()", 500);
}


function checkForRefresh()
{
	timeSinceUpdate = timeSinceUpdate + 500;
	refreshRate = getSelectedValue("refresh_rate");
	refreshRate = refreshRate == "never" ? timeSinceUpdate+500 : refreshRate;
	if(timeSinceUpdate < 0 || timeSinceUpdate >= refreshRate)
	{
		timeSinceUpdate = 0;
		updateConnectionTable();
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


function updateConnectionTable()
{

	if(!updateInProgress)
	{
		updateInProgress = true;

		var stateChangeFunction = function(req)
		{
			// if(req.readyState == 4)
			// {
				var bwUnits = getSelectedValue("bw_units");
				var conntrackLines = req.split(/[\n\r]+/);
				// var conntrackLines = req.responseText.split(/[\n\r]+/);
				var tableData = new Array();
				var conntrackIndex;
				for(conntrackIndex=0; conntrackLines[conntrackIndex].match(/^Success/) == null ; conntrackIndex++)
				{
					var line = conntrackLines[conntrackIndex];

					try
					{
						var protocol= (line.split(/[\t ]+/))[2];
						var srcIp   = (line.match(/src=([^ \t]*)[\t ]+/))[1];
						var srcPort = (line.match(/sport=([^ \t]*)[\t ]+/))[1];
						var dstIp   = (line.match(/dst=([^ \t]*)[\t ]+/))[1];
						var dstPort = (line.match(/dport=([^ \t]*)[\t ]+/))[1];
						var bytes = (line.match(/bytes=([^ \t]*)[\t ]+/))[1];
						var connmark    = line.match(/mark=/) ? parseInt((line.match(/mark=([^ \t]*)[\t ]+/))[1]) : "";
						var l7proto = line.match(/l7proto=/) ? (line.match(/l7proto=([^ \t]*)[\t ]+/))[1] : "";
						var srcIp2   = (line.match(/src=([^ \t]*)[\t ]+.*src=([^ \t]*)[\t ]+/))[2];
						var srcPort2 = (line.match(/sport=([^ \t]*)[\t ]+.*sport=([^ \t]*)[\t ]+/))[2];
						var dstIp2   = (line.match(/dst=([^ \t]*)[\t ]+.*dst=([^ \t]*)[\t ]+/))[2];
						var dstPort2 = (line.match(/dport=([^ \t]*)[\t ]+.*dport=([^ \t]*)[\t ]+/))[2];
						var bytes2 = (line.match(/bytes=([^ \t]*)[\t ]+.*bytes=([^ \t]*)[\t ]+/))[2];

						var wan_connection = true;

						if (dstIp2 == currentWanIp) {
							downloadBytes = bytes2;
							uploadBytes = bytes;
							localIp = srcIp;
							localPort = srcPort;
							WanIp = srcIp2;
							WanPort = srcPort2;
						} else if (dstIp == currentWanIp) {
							downloadBytes = bytes;
							uploadBytes = bytes2;
							localIp = srcIp2;
							localPort = srcPort2;
							WanIp = dstIp2;
							WanPort = dstPort2;
						} else {	// filter out LAN-LAN connections
							wan_connection = false;
						}

						if (wan_connection)
						{
							var tableRow =[parseInt(uploadBytes) + parseInt(downloadBytes),
								protocol,
								getHostDisplay(WanIp) + ":" + WanPort + '<br>' +getHostDisplay(localIp) + ":" + localPort,
								'<span class="glyphicon glyphicon-arrow-up"></span>' + parseBytes(uploadBytes, bwUnits) + '<br><span class="glyphicon glyphicon-arrow-down"></span>' + parseBytes(downloadBytes, bwUnits)
							];
							if(qosEnabled)
							{
								var getQosName = function(mask, mark)
								{
									var section = mask == "" ? "" : markToQosClass[ (mask & mark) ];
									var name = uciOriginal.get("qos_shellgui", section, "name");
									return name == "" ? "NA" : name;
								}
								tableRow.push( '<span class="glyphicon glyphicon-arrow-up"></span>' + getQosName(qosUpMask, connmark) + '<br><span class="glyphicon glyphicon-arrow-down"></span>' + getQosName(qosDownMask, connmark) );
							}
							tableRow.push(l7proto);
							tableData.push(tableRow);
						}
					}
					catch(e){}
				}

				//Sort on the total of up bytes + down bytes
				var tableSortFun = function(a,b){ return parseInt(b[0]) - parseInt(a[0]); }
				tableData.sort(tableSortFun);

				//remove integer totals we used to sort
				var rowIndex;
				for(rowIndex=0; rowIndex < tableData.length; rowIndex++)
				{
					(tableData[rowIndex]).shift();
				}


				var columnNames= [connTS.PrNm, connTS.WLNm, connTS.UDNm ];
				if(qosEnabled) { columnNames.push(connTS.QSNm); };
				columnNames.push(connTS.LPNm);

				var trs = createTr(tableData);
				$('#links_container').empty();
				$('#links_container').parent().find('thead').removeClass('hidden');
				$('#links_container').append(trs);
				Ha.setFooterPosition();
				$('.loading').addClass('hidden');

				updateInProgress = false;
			// }
		}
		// runAjax("POST", "/", 'app=conntrack&action=get_nf_conntrack', stateChangeFunction);
		$.post("/", 'app=conntrack&action=get_nf_conntrack', stateChangeFunction);
	}
}

function createTr(data){
	var doms = '';
	for(var i=0; i<data.length; i++){
		var dom = '<tr class="text-left">'
				+ 	'<td>' + data[i][0] + '</td>'
				+ 	'<td>' + data[i][1] + '</td>'
				+ 	'<td>' + data[i][2] + '</td>'
				+ 	'<td>' + data[i][3] + '</td>'
				+ 	'<td>' + data[i][4] + '</td>'
				+ '</tr>';
		doms += dom;
	}
	return doms;
}


setBrowserTimeCookie();


initializeConnectionTable();

function getHttpsPort(uciData){
	return getUhttpServerPort(true, "main", uciData);
}

function getHttpPort(uciData){
	return getUhttpServerPort(false, "main", uciData);
}

function getUhttpServerPort(isHttps, serverName, uciData){
	uciData = uciData == null ? uciOriginal : uciData;
	var portList = uciData.get("uhttpd", serverName, isHttps ? "listen_https" : "listen_http");
	var port = ""
	var portIndex;
	for(portIndex=0 ; portIndex < portList.length ; portIndex++)
	{
		var listenDef = portList[portIndex];
		if(listenDef.match(/^0\.0\.0\.0:/))
		{
			port = listenDef.replace(/^.*:/, "");
		}
	}
	return port;
}

function setBrowserTimeCookie(){
	var browserSecondsUtc = Math.floor( ( new Date() ).getTime() / 1000 );
	document.cookie="browser_time=" +browserSecondsUtc + "; path=/"; //don't bother with expiration -- who cares when the cookie was set? It just contains the current time, which the browser already knows
}

function setSelectedValue(selectId, selection, controlDocument)
{
	var controlDocument = controlDocument == null ? document : controlDocument;

	var selectElement = controlDocument.getElementById(selectId);
	if(selectElement == null){ 
		// alert(UI.Err+": " + selectId + " "+UI.nex); 
		console.log('Error.')
	}

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

function getSelectedValue(selectId, controlDocument){

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

function getParameterDefinition(parameter, definition)
{
	return(encodeURIComponent(parameter) + "=" + encodeURIComponent(definition));
}

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
