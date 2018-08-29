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

var hostsStr=new Object(); //part of i18n
hostsStr.RefreshR="刷新频率";
hostsStr.RInfo="该参数指定该页面上的数据重新加载的频率";
hostsStr.CurrLeases="当前DHCP租约";
hostsStr.ConWifiHosts="已连接的无线主机";
hostsStr.ActiveHosts="主机活动连接数";
hostsStr.HostIP="主机IP";
hostsStr.HostMAC="主机的MAC";
hostsStr.LeaseExp="租约期限";
hostsStr.Bitrate="比特率";
hostsStr.Signal="信号";
hostsStr.ActiveConx="活动的TCP连接";
hostsStr.RecentConx="最近的TCP连接";
hostsStr.UDPConx="UDP连接";

// var TSort_Data = new Array ('lease_table', 's', 'p', 's', 's');
// tsRegister();
// TSort_Data = new Array ('wifi_table', 's', 'p', 's', 's', 's');
// tsRegister();
// TSort_Data = new Array ('active_table', 's', 'p', 's', 'i', 'i', 'i');
// tsRegister();

var updateInProgress = false;
var timeSinceUpdate = -5000;

function resetData()
{
	setSelectedValue("refresh_rate", "10000");
	resetVariables();
	setInterval(checkForRefresh, 500);
}

function checkForRefresh()
{
	timeSinceUpdate = timeSinceUpdate + 500;

	var refreshRate = getSelectedValue("refresh_rate");
	var refreshRate = refreshRate == "never" ? timeSinceUpdate+500 : refreshRate;
	if(timeSinceUpdate < 0 || timeSinceUpdate >= refreshRate)
	{
		timeSinceUpdate = 0;
		reloadVariables();
	}
}


function reloadVariables()
{
	if(!updateInProgress)
	{
		updateInProgress = true;
		// var param = getParameterDefinition("commands", "sh /usr/lib/gargoyle/define_host_vars.sh") + "&" + getParameterDefinition("hash", document.cookie.replace(/^.*hash=/,"").replace(/[\t ;]+.*$/, ""));

		var stateChangeFunction = function(req)
		{
			var jsHostVars = req.replace(/Success/, "");
			eval(jsHostVars);
			resetVariables();
			updateInProgress = false;
		}
		$.post('/','app=hosts&action=define_host_vars',stateChangeFunction);
	}
}
function resetVariables()
{
	if(uciOriginal.get("dhcp", "lan", "ignore") != "1")
	{
		$("#dhcp_data").removeClass('hidden');
		var columnNames=[UI.HsNm, hostsStr.HostIP, hostsStr.HostMAC, hostsStr.LeaseExp];
		var trs = createTr(parseDhcp(dhcpLeaseLines));
		$('#dhcp_container').empty();
		$('#dhcp_container').append(trs);
		Ha.setFooterPosition();

		// var table = createTable(columnNames, parseDhcp(dhcpLeaseLines), "lease_table", false, false);
		// var tableContainer = document.getElementById('lease_table_container');
		// if(tableContainer.firstChild != null)
		// {
		// 	tableContainer.removeChild(tableContainer.firstChild);
		// }
		// tableContainer.appendChild(table);
  //       reregisterTableSort('lease_table', 's', 'p', 's', 's');
	}
	else
	{
		$("#dhcp_data").addClass('hidden');
	}

	var arpHash = parseArp(arpLines, dhcpLeaseLines);

	var apFound = false;
	var wifiIfs = uciOriginal.getAllSectionsOfType("wireless", "wifi-iface");
	var ifIndex = 0;
	for(ifIndex = 0; ifIndex < wifiIfs.length; ifIndex++)
	{
		apFound = uciOriginal.get("wireless", wifiIfs[ifIndex], "mode") == "ap" ? true : apFound;
	}
	var wifiDevs = uciOriginal.getAllSectionsOfType("wireless", "wifi-device");
	apFound = apFound && (uciOriginal.get("wireless", wifiDevs[0], "disabled") != "1");

	if(apFound)
	{
		$("#wifi_data").removeClass('hidden');
		var columnNames=[UI.HsNm, hostsStr.HostIP, hostsStr.HostMAC, hostsStr.Band, "TX "+hostsStr.Bitrate, "RX "+hostsStr.Bitrate, hostsStr.Signal ];
		// console.log( parseWifi(arpHash, wirelessDriver, wifiLines) );
		var trs = createTr( parseWifi(arpHash, wirelessDriver, wifiLines) );
		$('#wifi_container').empty();
		$('#wifi_container').append(trs);
		Ha.setFooterPosition();
		// var table = createTable(columnNames, parseWifi(arpHash, wirelessDriver, wifiLines), "wifi_table", false, false);
		// var tableContainer = document.getElementById('wifi_table_container');
		// if(tableContainer.firstChild != null)
		// {
		// 	tableContainer.removeChild(tableContainer.firstChild);
		// }
		// tableContainer.appendChild(table);
  //       reregisterTableSort('wifi_table', 's', 'p', 's', 's');
	}
	else
	{
		$("#wifi_data").addClass('hidden');
	}

	var columnNames=[UI.HsNm, hostsStr.HostIP, hostsStr.HostMAC, hostsStr.ActiveConx, hostsStr.RecentConx, hostsStr.UDPConx];
	var trs = createTr(parseConntrack(arpHash, currentWanIp, conntrackLines));
	$('#active_container').empty();
	$('#active_container').append(trs);
	Ha.setFooterPosition();
	$('.loading').addClass('hidden');
	// var table = createTable(columnNames, parseConntrack(arpHash, currentWanIp, conntrackLines), "active_table", false, false);
	// var tableContainer = document.getElementById('active_table_container');
	// if(tableContainer.firstChild != null)
	// {
	// 	tableContainer.removeChild(tableContainer.firstChild);
	// }
	// tableContainer.appendChild(table);
 //    reregisterTableSort('active_table', 's', 'p', 's', 'i', 'i', 'i');
}


function getHostname(ip)
{
	var hostname = ipToHostname[ip] == null ? "("+UI.unk+")" : ipToHostname[ip];
	hostname = hostname.length < 25 ? hostname : hostname.substr(0,22)+"...";
	return hostname;
}

function parseDhcp(leases)
{
	//HostName, Host IP, Host MAC, Time Before Expiration
	var dhcpTableData = [];
	var lineIndex=0;
	for(lineIndex=0; lineIndex < leases.length; lineIndex++)
	{
		var leaseLine = leases[lineIndex];
		var splitLease = leaseLine.split(/[\t ]+/);
		var expTime = splitLease[0];
		var mac = splitLease[1].toUpperCase();
		var ip = splitLease[2];

		var hostname = getHostname(ip);

		var seconds = expTime - currentTime;
		var expHours = Math.floor(seconds/(60*60));
		var expMinutes = Math.floor((seconds-(expHours*60*60))/(60));
		if(expMinutes < 10)
		{
			expMinutes = "0" + expMinutes;
		}
		var exp = expHours + "h " + expMinutes + "m";

		dhcpTableData.push( [hostname, ip, mac, exp ] );
	}
	sort2dStrArr(dhcpTableData, 1);
	return dhcpTableData;
}

function parseArp(arpLines, leaseLines)
{
	var arpHash = [];

	arpLines.shift(); //skip header
	var lineIndex = 0;
	for(lineIndex=0; lineIndex < arpLines.length; lineIndex++)
	{
		var nextLine = arpLines[lineIndex];
		var splitLine = nextLine.split(/[\t ]+/);
		var mac = splitLine[3].toUpperCase();
		var ip = splitLine[0];
		arpHash[ mac ] = ip;
		arpHash[ ip  ] = mac;
	}


	for(lineIndex=0; lineIndex < leaseLines.length; lineIndex++)
	{
		var leaseLine = leaseLines[lineIndex];
		var splitLease = leaseLine.split(/[\t ]+/);
		var mac = splitLease[1].toUpperCase();
		var ip = splitLease[2];
		arpHash[ mac ] = ip;
		arpHash[ ip  ] = mac;
	}

	return arpHash;
}

function sort2dStrArr(arr, testIndex)
{
	var str2dSort = function(a,b){  return a[testIndex] == b[testIndex] ? 0 : (a[testIndex] < b[testIndex] ? -1 : 1);  }
	arr.sort(str2dSort);
}

function parseWifi(arpHash, wirelessDriver, lines)
{
	if(wirelessDriver == "" || lines.length == 0) { return []; }

	//Host IP, Host MAC
	var wifiTableData = [];
	var lineIndex = 0;
	if(wirelessDriver == "atheros")
	{
		lines.shift();
	}
	for(lineIndex=0; lineIndex < lines.length; lineIndex++)
	{
		var nextLine = lines[lineIndex];
		var whost = nextLine.split(/[\t ]+/);
		//bcm=1, madwifi=2, mac80211=3
		var macBitSig =	[
				[whost[1], "0", "0"],
		    	[whost[0], whost[3], whost[5]],
				[whost[0], whost[2], whost[1], whost[3], whost[4]]
		];
		// console.log(macBitSig);
		var mbs = wirelessDriver == "broadcom" ? macBitSig[0] : ( wirelessDriver == "atheros" ? macBitSig[1] : macBitSig[2] );
		mbs[0] = (mbs[0]).toUpperCase();
		mbs[1] = mbs[1] + " Mbps";
		// console.log(mbs);

		var toHexTwo = function(num) { var ret = parseInt(num).toString(16).toUpperCase(); ret= ret.length < 2 ? "0" + ret : ret.substr(0,2); return ret; }

		var sig = parseInt(mbs[2]);
		var color = sig < -80  ? "#AA0000" : "";
			color = sig >= -80 && sig < -70 ? "#AA" + toHexTwo(170*((sig+80)/10.0)) + "00" : color;
			color = sig >= -70 && sig < -60 ? "#" + toHexTwo(170-(170*(sig+70)/10.0)) + "AA00" : color;
			color = sig >= -60 ? "#00AA00" : color;
		
		var sigSpan = '<span style="color: ' + color + ';">' + mbs[2] + ' dBm</span>';
		mbs[2] = sigSpan;


		var ip = arpHash[ mbs[0] ] == null ? UI.unk : arpHash[ mbs[0] ] ;
		var hostname = getHostname(ip);
		if(mbs.length > 3)
		{
			mbs[3] = mbs[3] + " Mbps";
			wifiTableData.push( [ hostname, ip, mbs[0], mbs[4], mbs[1], mbs[3], mbs[2] ] );
		}
		else
		{
			wifiTableData.push( [ hostname, ip, mbs[0], "-", mbs[1], "-", mbs[2] ] );
		}
	}
	sort2dStrArr(wifiTableData, 1);
	return wifiTableData;
}

function parseConntrack(arpHash, currentWanIp, lines)
{
	var activeTableData = [];
	var ipHash = [];
	var protoHash = [];
	var ipList = [];
	var lineIndex = 0;
	for(lineIndex=0; lineIndex < lines.length; lineIndex++)
	{
		var nextLine = lines[lineIndex];

		var splitLine = nextLine.split(/src=/); //we want FIRST src definition
		var srcIpPart = splitLine[1];
		var splitSrcIp = srcIpPart.split(/[\t ]+/);
		var srcIp = splitSrcIp[0];

		splitLine = nextLine.split(/dst=/); //we want FIRST dst definition
		var dstIpPart = splitLine[1];
		var splitDstIp = dstIpPart.split(/[\t ]+/);
		var dstIp = splitDstIp[0];



		splitLine=nextLine.split(/[\t ]+/);
		var proto = splitLine[0].toLowerCase();
		if(proto == "tcp")
		{
			var state = splitLine[3].toUpperCase();
			var stateStr = state == "TIME_WAIT" || state == "CLOSE" ? "closed" : "open";
			proto = proto + "-" + stateStr;
		}
		protoHash[ srcIp + "-" + proto ] =  protoHash[ srcIp + "-" + proto ] == null ? 1 : protoHash[ srcIp + "-" + proto ] + 1;
		if(proto == "udp")
		{
			var num = protoHash[ srcIp + "-" + proto ];
		}

		if(ipHash[srcIp] == null && srcIp != currentWanIp && srcIp != currentLanIp && dstIp != currentWanIp && srcIp != "0.0.0.0")
		{
			ipList.push(srcIp);
			ipHash[srcIp] = 1;
		}
	}


	var ipIndex = 0;
	for(ipIndex = 0; ipIndex < ipList.length; ipIndex++)
	{
		var ip        = ipList[ipIndex];
		var mac       = arpHash[ip] == null ? UI.unk : arpHash[ip];
		var tcpOpen   = protoHash[ ip + "-tcp-open" ] == null   ? 0 : protoHash[ ip + "-tcp-open" ];
		var tcpClosed = protoHash[ ip + "-tcp-closed" ] == null  ? 0 : protoHash[ ip + "-tcp-closed" ];
		var udp       = protoHash[ ip + "-udp" ] == null ? 0 : protoHash[ ip + "-udp" ];
		var hostname  = getHostname(ip);
		activeTableData.push( [ hostname, ip, mac, ""+tcpOpen, ""+tcpClosed, ""+udp ] );
	}
	sort2dStrArr(activeTableData, 1);
	return activeTableData;
}

function createTr(data){
	var tr = [];
	for(var i=0; i<data.length; i++){
		var td = '';
		for(var j=0; j<data[i].length; j++){
			td += '<td>' + data[i][j] + '</td>';
		}
		tr.push(td);
	}
	var trDom = '';
	for(var n=0; n<tr.length; n++){
		trDom += '<tr class="text-left">' + tr[n] + '</tr>';
	}
	return trDom;
}

resetData();

function setSelectedValue(selectId, selection, controlDocument)
{
	var controlDocument = controlDocument == null ? document : controlDocument;

	var selectElement = controlDocument.getElementById(selectId);
	if(selectElement == null){ console.log(UI.Err+": " + selectId + " "+UI.nex); }

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

function getParameterDefinition(parameter, definition)
{
	return(encodeURIComponent(parameter) + "=" + encodeURIComponent(definition));
}
