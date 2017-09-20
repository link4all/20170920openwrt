
(function(){
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
UI.WaitSettings="Please wait while new settings are applied…";
UI.Wait="Please wait…";
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
UI.wakeUp = 'Wake Up';

$('#more_info_togger').click(function(){
	var isHidden = $('#info_container').hasClass('hidden');
	if(isHidden){
		$(this).html('Hide Text');
		$('#info_container').removeClass('hidden');
	}else{
		$(this).html('More Info');
		$('#info_container').addClass('hidden');
	}
	return false;
});



var wolS=new Object(); //part of i18n

var TSort_Data = new Array ('wol_table', 's', 'p', 's');

function initWolTable()
{
	var dataList = [];
	var ipToHostAndMac = [];

	// initializeDescriptionVisibility(uciOriginal, "wol_help"); // set description visibility
	// uciOriginal.removeSection("gargoyle", "help"); // necessary, or we overwrite the help settings when we save

	arpLines.shift(); // skip header
	var lineIndex = 0;
	for(lineIndex=0; lineIndex < arpLines.length; lineIndex++)
	{
		var nextLine = arpLines[lineIndex];
		var splitLine = nextLine.split(/[\t ]+/);
		var mac = splitLine[3].toUpperCase();
		var ip = splitLine[0];
		dataList.push( [ getHostname(ip), ip, mac, createWakeUpButton(mac) ] );
		ipToHostAndMac[ip] = 1;
	}

	for(lineIndex=0; lineIndex < dhcpLeaseLines.length; lineIndex++)
	{
		var leaseLine = dhcpLeaseLines[lineIndex];
		var splitLease = leaseLine.split(/[\t ]+/);
		var mac = splitLease[1].toUpperCase();
		var ip = splitLease[2];
		if(ipToHostAndMac[ip] == null)
		{
			dataList.push( [ getHostname(ip), ip, mac, createWakeUpButton(mac) ] );
			ipToHostAndMac[ip] = 1;
		}
	}

	for(lineIndex=0; lineIndex < etherData.length; lineIndex++)
	{
		var ether = etherData[lineIndex];
		var mac = ether[0].toUpperCase();
		var ip = ether[1];
		if(ipToHostAndMac[ip] == null)
		{
			dataList.push( [ getHostname(ip), ip, mac, createWakeUpButton(mac) ] );
			ipToHostAndMac[ip] = 1;
		}
	}

	sort2dStrArr(dataList, 1);
	var trs = createTr(dataList);
	$('#host_container').empty();
	$('#host_container').append(trs);
	$('.loading').addClass('hidden');
	$('.table-responsive').removeClass('hidden');
	Ha.setFooterPosition();
	$('.wakeup_btn').click(function(){
		var mac = $(this).attr('data-mac');
		$.post('/','app=wol&action=wakeup&mac=' + mac + '&bcastIp=' + bcastIp, Ha.showNotify,'json');
	});
}

function sort2dStrArr(arr, testIndex)
{
	var str2dSort = function(a,b){  return a[testIndex] == b[testIndex] ? 0 : (a[testIndex] < b[testIndex] ? -1 : 1);  }
	arr.sort(str2dSort);
}

function getHostname(ip)
{
	var hostname = ipToHostname[ip] == null ? "("+UI.unk+")" : ipToHostname[ip];
	hostname = hostname.length < 25 ? hostname : hostname.substr(0,22)+"...";
	return hostname;
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

function createWakeUpButton(mac)
{

	var WakeUpButton = '<button class="btn btn-success btn-xs wakeup_btn" data-mac="' + mac + '"><span class="glyphicon glyphicon-off"></span></button>';
	return WakeUpButton;
}



initWolTable();

function initializeDescriptionVisibility(testUci, descriptionId, defaultDisplay, displayText, hideText)
{
	defaultDisplay = (defaultDisplay == null) ? "inline" : defaultDisplay;
	displayText = (displayText == null) ? UI.MoreInfo : displayText;
	hideText = (hideText == null) ? UI.Hide : hideText;

	var descLinkText = displayText;
	var descDisplay = "none";
	if(testUci.get("gargoyle", "help", descriptionId) == "1")
	{
		descLinkText = hideText
		descDisplay = defaultDisplay;
	}
	document.getElementById(descriptionId + "_ref").firstChild.data = descLinkText;
	document.getElementById(descriptionId + "_txt").style.display = descDisplay;
}

function createInput(type, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;
	try
	{
		inp = controlDocument.createElement('input');
		inp.type = type;
	}
	catch(e)
	{
		inp = controlDocument.createElement('<input type="' + type + '" />');
	}
	return inp;
}
	
})();