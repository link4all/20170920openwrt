$('#applies_to_type').change(alterApplyTo);
$('#all_access').click(alterAllAccess);
$('#remote_ip_type').change(alterRemoteIpType);
$('#url_type').change(alterUrlType);
$('#remote_port_type').change(function(){
	alterPortInput('remote_port');
	disableSaveBtn();
});
$('#local_port_type').change(function(){
	alterPortInput('local_port');
	disableSaveBtn();
});
$('#app_protocol_type').change(function(){
	alterPortInput('app_protocol')
	disableSaveBtn();
});
$('#all_day').click(alterSchedule);
$('#every_day').click(alterSchedule);
$('#schedule_repeats').change(alterSchedule);
$('#add_new_restrictions_btn').click(alterToRestrictionsAdd);
$('#add_new_exceptions_btn').click(alterToExceptionsAdd);
$('#form_submit_btn').click(function(){
	var type = $('#form_submit_btn').attr('data-type');
	var action_type = type.split('-')[0];
	var rule_type = type.split('-')[1];
	if(action_type == 'edit'){
		editRule(rule_type);
		Ha.setFooterPosition();
	}else{
		addNewRule(rule_type);
		Ha.setFooterPosition();
	}
});

function disableSaveBtn(){
	var sum = 0;
	if(!$('#hours_active_container').hasClass('hidden')){
		sum += checkActiveHours();
	}
	if(!$('#days_and_hours_active_container').hasClass('hidden')){
		sum += checkActiveWeek();
	}

	if(!$('#add_local_ip_form_group').hasClass('hidden')){
		sum += checkLocalIPs();
	}
	if(!$('#resources_container').hasClass('hidden')){
		if(!$('#add_remote_ip_form_group').hasClass('hidden')){
			sum += checkRemoteIPs();
		}
		if(!$('#local_port_container').hasClass('hidden')){
			sum += checkPort('local_port');
		}
		if(!$('#remote_port_container').hasClass('hidden')){
			sum += checkPort('remote_port');
		}		
	}

	if(sum){
		$('#form_submit_btn').prop('disabled',true);
	}else{
		$('#form_submit_btn').prop('disabled',false);
	}
}
$('#applies_to_addr').focus(function(){
	$('#add_local_ip_form_group').find('.help-block').html(UI.Specify_an_IP__IP_range_or_MAC_address);
});
$('#applies_to_addr').bind('keyup blur',function(){
	checkLocalIPs();
	disableSaveBtn();
});
function checkLocalIPs(){
	var errorCode = 0;
	var val = $('#applies_to_addr').val();
	if(val.length!=0 && validateMultipleIps(val) && validateMac(val)){
		$('#add_local_ip_form_group').addClass('has-error');
		$('#add_local_ip_form_group').find('.help-block').html(UI.There_is_invalid_IP_or_IP_range_Exists);
		$('#add_local_ip_btn').prop('disabled',true);
		errorCode = 1;
	}else{
		$('#add_local_ip_form_group').removeClass('has-error');
		$('#add_local_ip_form_group').find('.help-block').html(UI.Specify_an_IP__IP_range_or_MAC_address);
		$('#add_local_ip_btn').prop('disabled',false);
	}
	return errorCode;
}
$('#add_local_ip_btn').click(function(){
	var valid = addAddressesToTable("applies_to_addr","ip_span_container",true);
	if(valid){
		$('#add_local_ip_form_group').find('.help-block').html(UI.There_is_invalid_IP_or_IP_range_Exists);
		$("#applies_to_addr").focus();
	}
	return false;
});



$('#hours_active').bind('keyup blur',function(){
	checkActiveHours();
	disableSaveBtn();
});

function checkActiveHours(){
	var errorCode = 0;
	var val = $('#hours_active').val();
	if(validateHours(val)){
		$('#hours_active_container').addClass('has-error');
		$('#hours_active_container').find('.warn-help').removeClass('hidden');
		errorCode = 1;
	}else{
		$('#hours_active_container').removeClass('has-error');
		$('#hours_active_container').find('.warn-help').addClass('hidden');
	}
	return errorCode;
}


$('#days_and_hours_active').bind('keyup blur',function(){
	checkActiveWeek();
	disableSaveBtn();
});

function checkActiveWeek(){
	var errorCode = 0;
	var val = $('#days_and_hours_active').val();
	if(validateWeeklyRange(val)){
		$('#days_and_hours_active_container').addClass('has-error');
		$('#days_and_hours_active_container').find('.warn-help').removeClass('hidden');
		errorCode = 1;
	}else{
		$('#days_and_hours_active_container').removeClass('has-error');
		$('#days_and_hours_active_container').find('.warn-help').addClass('hidden');
	}
	return errorCode;
}


$('#remote_ip').focus(function(){
	$('#add_remote_ip_form_group').find('.help-block').html(UI.Specify_an_IP__IP_range_or_MAC_address);
});
$('#remote_ip').bind('keyup blur',function(){
	checkRemoteIPs();
	disableSaveBtn();
});
function checkRemoteIPs(){
	var val = $('#remote_ip').val();
	var errorCode = 0;
	if(val.length!=0 && validateMultipleIps(val) && validateMac(val)){
		$('#add_remote_ip_form_group').addClass('has-error');
		$('#add_remote_ip_form_group').find('.help-block').html(UI.There_is_invalid_IP_or_IP_range_Exists);
		$('#add_remote_ip_btn').prop('disabled',true);
		errorCode = 1;
	}else{
		$('#add_remote_ip_form_group').removeClass('has-error');
		$('#add_remote_ip_form_group').find('.help-block').html(UI.Specify_an_IP__IP_range_or_MAC_address);
		$('#add_remote_ip_btn').prop('disabled',false);
	}
	return errorCode;
}
$('#add_remote_ip_btn').click(function(){
	var valid = addAddressesToTable("remote_ip","remote_ip_span_container",true);
	if(valid){
		$('#add_remote_ip_form_group').find('.help-block').html(UI.There_is_invalid_IP_or_IP_range_Exists);
		$("#remote_ip").focus();
	}
	return false;
});

$('#local_port').bind('blur keyup',function(){
	checkPort('local_port');
	disableSaveBtn();
});
$('#remote_port').bind('blur keyup',function(){
	checkPort('remote_port');
	disableSaveBtn();
});
function checkPort(id){
	var errorCode = 0;
	var val = $('#' + id).val();
	if(va.validateNum(val)){
		$('#' + id).parent().addClass('has-error');
		$('#' + id).next('.help-block').removeClass('hidden');
		errorCode = 1;
	}else{
		$('#' + id).parent().removeClass('has-error');
		$('#' + id).next('.help-block').addClass('hidden');
	}
	return errorCode;
}
$('#url_match').bind('blur keyup',function(){
	checkURL();
	// disableSaveBtn();
});
function checkURL(){
	var errorCode = 0;
	var url = $('#url_match').val();
	if(va.validateReq(url)){
		$('#url_input_container').addClass('has-error');
		$('#url-help').removeClass('hidden');
		errorCode = 1;
		$('#add_url_btn').prop('disabled',true);
	}else{
		$('#url_input_container').removeClass('has-error');
		$('#add_url_btn').prop('disabled',false);
		$('#url-help').addClass('hidden');
	}
	return errorCode;
}

$('#add_url_btn').click(function(){
	addUrlToTable('url_match', 'url_match_type', 'url_container');
});



function alterPortInput(id){
	var type = $('#' + id + '_type').val();
	if(type == 'all'){
		$('#' + id + '_type').parent().addClass('col-sm-12').removeClass('col-sm-6');
		$('#' + id).val('').parent().addClass('hidden');
	}else{
		$('#' + id + '_type').parent().removeClass('col-sm-12').addClass('col-sm-6');
		$('#' + id).focus().val('').parent().removeClass('hidden');
	}

	if(id == 'app_protocol'){
		$('#' + id).find('option').first().prop('selected',true);
	}
}

function alterApplyTo(){
	var type = $('#applies_to_type').val();
	if(type == 'all'){
		$('#ip_span_container').empty().parent().parent().addClass('hidden');
		$('#add_local_ip_form_group').addClass('hidden');
	}else{
		$('#ip_span_container').parent().parent().removeClass('hidden');
		$('#add_local_ip_form_group').removeClass('hidden');
	}
	disableSaveBtn();
}

function alterAllAccess(){
	var status = $('#all_access').prop('checked');
	if(status){
		$('#resources_container').addClass('hidden').find('select,input').val('');
	}else{
		$('#resources_container').removeClass('hidden').find('select').each(function(){
			$(this).find('option').first().prop('selected',true);
		});
	}
	$('#remote_ip_span_container,#url_container').empty();
	$('#url_container').parent().find('thead').addClass('hidden');

	alterRemoteIpType();
	alterUrlType();
	alterPortInput('remote_port');
	alterPortInput('local_port');
	alterPortInput('app_protocol')
	disableSaveBtn();

}

function alterRemoteIpType(){
	var type = $('#remote_ip_type').val();
	if(type == 'all'){
		$('#remote_ip_span_container').empty().parent().parent().addClass('hidden');
		$('#add_remote_ip_form_group').addClass('hidden');
	}else{
		$('#remote_ip_span_container').empty().parent().parent().removeClass('hidden');
		$('#add_remote_ip_form_group').removeClass('hidden');
	}
	disableSaveBtn();

}

function alterUrlType(){
	var type = $('#url_type').val();
	if(type == 'all'){
		$('#url_container').empty().parent().parent().addClass('hidden');
		$('#url_match_type').parent().parent().addClass('hidden');
	}else{
		$('#url_container').empty().parent().parent().removeClass('hidden');
		$('#url_match_type').parent().parent().removeClass('hidden');
	}
	disableSaveBtn();
}

function alterSchedule(){
	var allDay = $('#all_day').prop('checked');
	var everyDay = $('#every_day').prop('checked');
	if( allDay && everyDay ){
		$('#schedule_repeats').parent().addClass('hidden');
		$('#days_container').addClass('hidden');
		$('#hours_active,#days_and_hours_active').parent().parent().addClass('hidden');
	}else if( allDay && !everyDay ){
		$('#schedule_repeats').parent().addClass('hidden');
		$('#days_container').removeClass('hidden');
		$('#hours_active,#days_and_hours_active').parent().parent().addClass('hidden');
	}else if( !allDay && everyDay ){
		$('#schedule_repeats').parent().addClass('hidden');
		$('#days_container').addClass('hidden');
		$('#hours_active').parent().parent().removeClass('hidden');
		$('#days_and_hours_active').parent().parent().addClass('hidden');
	}else if( !allDay && !everyDay ){
		$('#schedule_repeats').parent().removeClass('hidden');
		var type = $('#schedule_repeats').val();
		if(type == 'daily'){
			$('#days_container').removeClass('hidden');
			$('#hours_active').parent().parent().removeClass('hidden');
			$('#days_and_hours_active').parent().parent().addClass('hidden');
		}else if(type == 'weekly'){
			$('#days_container').addClass('hidden');
			$('#hours_active').parent().parent().addClass('hidden');
			$('#days_and_hours_active').parent().parent().removeClass('hidden');
		}
	}
	disableSaveBtn();
}

//-----------------------------------------------------------------------------------------------------------
UI.SaveChanges="Save Changes";
UI.Reset="Reset";
UI.Clear="Clear History";
UI.Delete="Delete Data";
UI.DNow="Download Now";
UI.Visited="Visited Sites";
UI.Requests="Search Requests";
UI.Add="Add";
UI.DDNSService="DDNS Service";
UI.WakeUp="Wake Up";
UI.NewRule="Add New Rule";
UI.NewQuota="Add New Quota";
UI.AddRule="Add Rule";
UI.AddSvcCls="Add Service Class";
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

var restStr=new Object(); //part of i18n

restStr.ARSect="Access Restrictions";
restStr.NRRule="New Restriction Rule";
restStr.ANRule="Add New Rule";
restStr.CRestr="Current Restrictions";
restStr.EWSect="Exceptions (White List)";
restStr.NExcp="New Exception";
restStr.CExcp="Current Exceptions";

restStr.ERSect="Edit Restriction Rule";
restStr.EESect="Edit Exception Rule";

//templates
restStr.RDesc="Rule Description";
restStr.RAppl="Rule Applies To";
restStr.AHsts="All Hosts";
restStr.EHsts="All Hosts Except";
restStr.OHsts="Only The Following Hosts";
restStr.Schd="Schedule";
restStr.ADay="All Day";
restStr.EDay="Every Day";
restStr.DSchd="Schedule Repeats Daily";
restStr.WSchd="Schedule Repeats Weekly";
restStr.DActv="Days Active";
restStr.HActv="Hours Active";
restStr.DHActv="Days And Hours Active";
restStr.Sample="e.g. Mon 00:30 - Thu 13:15, Fri 14:00 - Fri 15:00";
restStr.SSample="e.g.";
restStr.RRsrc="Restricted Resources";
restStr.NetAcc="All Network Access";
restStr.RemIP="Remote IP(s)";
restStr.RemPrt="Remote Port(s)";
restStr.LclPrt="Local Port(s)";
restStr.TrProto="Transport Protocol";
restStr.ApProto="Application Protocol";
restStr.WebURL="Website URL(s)";
restStr.BlAll="Block All";
restStr.BlOny="Block Only";
restStr.BlExc="Block All Except";
restStr.BlTCP="Block TCP";
restStr.BlUDP="Block UDP";
restStr.FUExt="Full URL matches exactly";
restStr.FUCnt="Full URL contains";
restStr.FURgx="Full URL matches Regex";
restStr.DmExt="Domain matches exactly";
restStr.DmCon="Domain contains";
restStr.DmRgx="Domain matches Regex";
restStr.ESect="Exception Description";
restStr.EAppl="Exception Applies To";
restStr.PRsrc="Permitted Resources";
restStr.PmAll="Permit All";
restStr.PmOny="Permit Only";
restStr.PmExc="Permit All Except";
restStr.PmTCP="Permit TCP";
restStr.PmUDP="Permit UDP";

//javascript
restStr.ARErr="Could not add rule.";
restStr.IAErr="ERROR: Invalid Address";
restStr.UPrt="URL Part";
restStr.MTyp="Match Type";
restStr.MTExp="Match Text / Expression";
restStr.UMZErr="ERROR: URL match length must be greater than zero";
restStr.UChErr="ERROR: URL match cannot contain quote or newline characters";




var pkg = "restriction_uci";

resetData();

var emptyUci = {
	description: '',

	local_addr_type: 'all',
	local_addr_option: '',

	allDay: true,
	everyDay: true,
	scheduleRepeats: '',
	days: '',
	hours: '',
	daysAndHours: '',
	
	all_resources_blocked: true,
	app_protocol_type: '',
	app_protocol: '',
	local_port_option: '',
	local_port_type: '',
	remote_ip_option: '',
	remote_ip_type: '',
	remote_port_option: '',
	remote_port_type: '',
	transport_protocol: '',
	url_data: '',
	url_type: ''
}
$('#save_page_btn').click(saveChanges);
$('#reset_page_btn').click(resetData);

function saveChanges()
{
	// setControlsEnabled(false, true);
	
	// var enabledRuleFound = false;
	// var runCommands = [];


	var ruleTypes = [ "restriction_rule", "whitelist_rule" ];
	var rulePrefixes   = [ "rule_", "exception_" ];
	var typeIndex=0;
	// var deleteSectionCommands = [];
	// var createSectionCommands = [];
	for(typeIndex=0; typeIndex < ruleTypes.length; typeIndex++)
	{
		//set enabled status to corrospond with checked in table
		// var ruleTableContainer = document.getElementById(rulePrefixes[typeIndex] + 'table_container');
		// var ruleTable = ruleTableContainer.firstChild;
		// var ruleData = getTableDataArray(ruleTable);
		// for(ruleIndex =0; ruleIndex < ruleData.length; ruleIndex++)
		// {
		// 	var check = ruleData[ruleIndex][1];
		// 	enabledRuleFound = enabledRuleFound || check.checked; 
		// 	uci.set(pkg, check.id, "enabled", check.checked ? "1" : "0");
		// }

		
		//delete all sections of type in uciOriginal & remove them from uciOriginal
		var originalSections = uciOriginal.getAllSectionsOfType(pkg, ruleTypes[typeIndex]);
		var sectionIndex = 0;
		for(sectionIndex=0; sectionIndex < originalSections.length; sectionIndex++)
		{
			var isIngress = uciOriginal.get(pkg, originalSections[sectionIndex], "is_ingress");
			if(isIngress != "1")
			{
				uciOriginal.removeSection(pkg, originalSections[sectionIndex]);
			}
		}
	
		//create/initialize  sections in uci
	// 	var newSections = uci.getAllSectionsOfType(pkg, ruleTypes[typeIndex]);
	// 	for(sectionIndex=0; sectionIndex < newSections.length; sectionIndex++)
	// 	{
	// 		createSectionCommands.push("uci set " + pkg + "." + newSections[sectionIndex] + "='" + ruleTypes[typeIndex] + "'");
	// 	}
	}
	// deleteSectionCommands.push("uci commit");
	// createSectionCommands.push("uci commit");
	

	// var commands = deleteSectionCommands.join("\n") + "\n" + createSectionCommands.join("\n") + "\n" + uci.getScriptCommands(uciOriginal) + "\n" + runCommands.join("\n") + "\n" + "sh /usr/lib/gargoyle/restart_firewall.sh";

	// var param = getParameterDefinition("commands", commands) +  "&" + getParameterDefinition("hash", document.cookie.replace(/^.*hash=/,"").replace(/[\t ;]+.*$/, ""));

	var stateChangeFunction = function(data)
	{
		Ha.showNotify(data);
		uciOriginal = uci.clone();
		resetData();
	}

	var restrictionIds = [];
	var restriction_rule = [];
	$('#rule_table_container').find('tr').each(function(){
		var id = $(this).prop('id');
		restrictionIds.push(id);
	});
	for(var i=0; i<restrictionIds.length; i++){
		var restriction_data = getDocumentDataFromUci(uci,restrictionIds[i],true);
		restriction_data.id = restrictionIds[i];
		restriction_data.enabled = $('#' + restrictionIds[i]).find('[type="checkbox"]').prop('checked') ? 1 : 0;

		restriction_rule.push(restriction_data);
	}
	var whitelist_rule = [];
	var whitelistIds = [];
	$('#exception_table_container').find('tr').each(function(){
		var id = $(this).prop('id');
		whitelistIds.push(id);
	});
	for(var i=0; i<whitelistIds.length; i++){
		var whitelist_data = getDocumentDataFromUci(uci,whitelistIds[i],true);
		whitelist_data.id = whitelistIds[i];
		whitelist_data.enabled = $('#' + whitelistIds[i]).find('[type="checkbox"]').prop('checked') ? 1 : 0;
		whitelist_rule.push(whitelist_data);
	}

	var data = {
		app: 'restriction',
		action: 'restriction_save_change',
		restriction_rule: restriction_rule,
		whitelist_rule: whitelist_rule
	}
	console.log(data);
	$.post('/',data,stateChangeFunction,'json');

}

function resetData()
{
	var ruleTypes = [ "restriction_rule", "whitelist_rule" ];
	var rulePrefixes   = [ "rule_", "exception_" ];
	var typeIndex=0;
	for(typeIndex=0; typeIndex < ruleTypes.length; typeIndex++)
	{
		var ruleType = ruleTypes[typeIndex];
		var rulePrefix = rulePrefixes[typeIndex];

		var sections = uciOriginal.getAllSectionsOfType(pkg, ruleType);
		var ruleTableData = new Array();
		for(sectionIndex=0; sectionIndex < sections.length; sectionIndex++)
		{
			var isIngress = uciOriginal.get(pkg, sections[sectionIndex], "is_ingress");
			if(isIngress != "1")
			{
				var description = uciOriginal.get(pkg, sections[sectionIndex], "description");
				description = description == "" ? sections[sectionIndex] : description;
				
				var enabledStr =   uciOriginal.get(pkg, sections[sectionIndex], "enabled");
				var enabledBool =  (enabledStr == "" || enabledStr == "1" || enabledStr == "true") ;
				var enabledCheck = createEnabledCheckbox(enabledBool);
				var id = sections[sectionIndex];
	
				ruleTableData.push([description, enabledCheck, createEditButton(enabledBool), createRemoveButton(id), id]);
			}
		}
		tableContainerId = rulePrefix + 'table_container';

		var trs = createTrs(ruleTableData);
		$('#' + tableContainerId).empty().append(trs);
	}
	setTableBtnAction();
	Ha.setFooterPosition()

}

function alterToRestrictionsEdit(id){
	$('#formModalLabel').html(UI.Edit_Restriction_Rule);
	$('#form_submit_btn').html(UI.Save).attr('data-type','edit-restriction').attr('data-target-id',id);
	var data = getDocumentDataFromUci(uci,id);
	console.log(data);
	setDocumentData(data);
	$('.del_ip_span').click(function(){
		$(this).parent().remove();
	});
}

function alterToRestrictionsAdd(){
	$('#formModalLabel').html(UI.Add_New_Restriction_Rule);
	$('#form_submit_btn').html(UI.Save).attr('data-type','add-restriction').attr('data-target-id','');
	var nextRows = $('#rule_table_container').find('tr').length + 1;
	emptyUci.description = 'rule_' + nextRows;
	setDocumentData(emptyUci);
	disableSaveBtn();
}

function alterToExceptionsEdit(id){
	$('#formModalLabel').html(UI.Edit_Exception_Rule);
	$('#form_submit_btn').html(UI.Save).attr('data-type','edit-exception').attr('data-target-id',id);
	var data = getDocumentDataFromUci(uci,id);
	setDocumentData(data);
	$('.del_ip_span').click(function(){
		$(this).parent().remove();
	});
}

function alterToExceptionsAdd(){
	$('#formModalLabel').html(UI.Add_New_Exception_Rule);
	$('#form_submit_btn').html(UI.Save).attr('data-type','add-exception').attr('data-target-id','');
	var nextRows = $('#exception_table_container').find('tr').length + 1;
	emptyUci.description = 'exception_' + nextRows;
	setDocumentData(emptyUci);
	disableSaveBtn();
}

function createTrs(data){
	var trs = [];
	for(var i=0; i<data.length; i++){
		var tr = '<tr id="' + data[i][4] + '">'
			   + 	'<td>' + data[i][0] + '</td>'
			   +	'<td>' + data[i][1] + '</td>'
			   +	'<td>' + data[i][2] + '</td>'
			   +	'<td>' + data[i][3] + '</td>'
			   + '</tr>';
		trs.push(tr);
	}
	return trs.join('');
}

function addNewRule(type)//restriction/exception/("restriction_rule", "rule_")/("whitelist_rule", "exception_")
{
	var rulePrefix = type == 'restriction' ? 'rule_' : 'exception_';
	var ruleType = type == 'restriction' ? 'restriction_rule' : 'whitelist_rule';
	var errors = validateRule();
	if(errors.length > 0)
	{
		var data = {
			status: 1,
			msg: errors[0] + '<br>' +restStr.ARErr
		}
		Ha.showNotify(data);
	}
	else
	{
		//获取新数据的id
		
		var newIndex = $('#' + rulePrefix + 'table_container').find('tr').length+1;
		var newId = rulePrefix + "" + newIndex;
		while( uci.get(pkg, newId, "") != "" )
		{
			newIndex++;
			newId = rulePrefix + "" + newIndex;
		}

		//uci数据更新
		setUciFromDocument(newId, ruleType, rulePrefix);

		//表格dom更新
		var description = uci.get(pkg, newId, "description");
		description = description == "" ? newId : description;//名称

		var enabledCheck = createEnabledCheckbox(true);//启用
		// enabledCheck.id = newId; //id就用不着了 save section id as checkbox name (yeah, it's kind of sneaky...)
		
		// addTableRow(table, [description, enabledCheck, createEditButton(true)], true, false, removeRule);//添加tableRow	
		var tr = createTrs([[ description,  enabledCheck, createEditButton(true), createRemoveButton(newId), newId]]);
		$('#' + rulePrefix + 'table_container').append(tr);
									// .find('input').click(function(){//启用按钮
		// 						 	var id = $(this).parent().parent().prop('id');
		// 						 	var enabled = $(this).prop('checked');
		// 						 	setRowEnabled(id,enabled);
		// 						 });
		// $('#' + rulePrefix + 'table_container').find('.btn-danger').click(function(){//删除按钮
		// 						 	var id = $(this).attr('data-del-target');
		// 						 	removeRule(id);
		// 						 });

		// $('#rule_table_container').find('.btn-primary').click(function(){
		// 	var id = $(this).parent().parent().prop('id');
		// 	alterToRestrictionsEdit(id);
		// });
		// $('#exception_table_container').find('.btn-primary').click(function(){
		// 	var id = $(this).parent().parent().prop('id');
		// 	alterToExceptionsEdit(id);
		// });
		setTableBtnAction();


		$('#formModal').modal('hide');
		// 重置表单
		// setDocumentFromUci(document, new UCIContainer(), "", ruleType, rulePrefix);
		setDocumentData(emptyUci);

		//再次确认刚添加的一条规则是启用的
		// enabledCheck.checked = true;
	}
}

function getTableDataArray(id){
	var data = [];
	$('#' + id).find('tr').each(function(){
		var rule = {};
		rule.id = $(this).prop('id');
		rule.description = $(this).find('td').first().html();
		rule.enabled = $(this).find('[type="checkbox"]').prop('checked');
		data.push(rule);
	});
	return data;
}

function setVisibility(controlDocument, rulePrefix)
{
	controlDocument = controlDocument == null ? document : controlDocument;
	
	
	setInvisibleIfAnyChecked([rulePrefix + "all_access"], rulePrefix + "resources", "block", controlDocument);
	setInvisibleIfAnyChecked([rulePrefix + "all_day"], rulePrefix + "hours_active_container", "block", controlDocument);
	setInvisibleIfAnyChecked([rulePrefix + "every_day"], rulePrefix + "days_active", "block", controlDocument);
	setInvisibleIfAnyChecked([rulePrefix + "all_day", rulePrefix + "every_day"], rulePrefix + "days_and_hours_active_container", "block", controlDocument);
	setInvisibleIfAnyChecked([rulePrefix + "all_day", rulePrefix + "every_day"], rulePrefix + "schedule_repeats", "inline", controlDocument);


	var scheduleRepeats = controlDocument.getElementById(rulePrefix + "schedule_repeats");
	if(scheduleRepeats.style.display != "none")
	{
		setInvisibleIfIdMatches(rulePrefix + "schedule_repeats", "daily", rulePrefix + "days_and_hours_active_container", "block", controlDocument);
		setInvisibleIfIdMatches(rulePrefix + "schedule_repeats", "weekly", rulePrefix + "days_active", "block", controlDocument);
		setInvisibleIfIdMatches(rulePrefix + "schedule_repeats", "weekly", rulePrefix + "hours_active_container", "block", controlDocument);
	}


	setInvisibleIfIdMatches(rulePrefix + "applies_to", "all", rulePrefix + "applies_to_container", "block", controlDocument);
	setInvisibleIfIdMatches(rulePrefix + "remote_ip_type", "all", rulePrefix + "remote_ip_container", "block", controlDocument);
	setInvisibleIfIdMatches(rulePrefix + "remote_port_type", "all", rulePrefix + "remote_port", "inline", controlDocument);
	setInvisibleIfIdMatches(rulePrefix + "local_port_type", "all", rulePrefix + "local_port", "inline", controlDocument);
	setInvisibleIfIdMatches(rulePrefix + "app_protocol_type", "all", rulePrefix + "app_protocol", "inline", controlDocument);
	setInvisibleIfIdMatches(rulePrefix + "url_type", "all", rulePrefix + "url_match_list", "block", controlDocument);
}

function setInvisibleIfAnyChecked(checkIds, associatedElementId, defaultDisplayMode, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;
	defaultDisplayMode = defaultDisplayMode == null ? "block" : defaultDisplayMode;
	var visElement = controlDocument.getElementById(associatedElementId);

	var isChecked = false;
	for(checkIndex = 0; checkIndex < checkIds.length ; checkIndex++)
	{
		var checkElement = controlDocument.getElementById( checkIds[checkIndex] );
		if(checkElement != null)
		{
			isChecked = isChecked || checkElement.checked;
		}
	}

	if(isChecked && visElement != null)
	{
		visElement.style.display = "none";
	}
	else if(visElement != null)
	{
		visElement.style.display = defaultDisplayMode;
	}

}

function setInvisibleIfIdMatches(selectId, invisibleOptionValue, associatedElementId, defaultDisplayMode, controlDocument )
{
	controlDocument = controlDocument == null ? document : controlDocument;
	defaultDisplayMode = defaultDisplayMode == null ? "restriction_rule" : defaultDisplayMode;
	var visElement = controlDocument.getElementById(associatedElementId);
	
	if(getSelectedValue(selectId, controlDocument) == invisibleOptionValue && visElement != null)
	{
		visElement.style.display = "none";
	}
	else if(visElement != null)
	{
		visElement.style.display = defaultDisplayMode;
	}
}



function createEnabledCheckbox(enabled)
{
	var checked = 'checked';
	if(!enabled){
		checked = '';
	}
	var checkbox = '<input type="checkbox" ' + checked + '>';
	return checkbox;
}

function createEditButton(enabled){
	var disabled = 'disabled';
	if(enabled){
		disabled = '';
	}

	return '<button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#formModal"' + disabled + '>'+UI.Edit+'</button>';
}

function createRemoveButton(id){
	return '<button class="btn btn-danger btn-sm" data-del-target="' + id + '">'+UI.Remove+'</button>';
}

function setRowEnabled(id,enabled){
	uciEnabled= enabled ? "1" : "0";
	uci.set(pkg, id, "enabled", uciEnabled);
	$('#' + id).find('.btn-primary').prop('disabled',!enabled);
}

function removeRule(id)
{
	$('#' + id).remove();
	uci.removeSection(pkg, id);
}

function editRule(type)
{

	var rulePrefix = type == 'restriction' ? 'rule_' : 'exception_';
	var ruleType = type == 'restriction' ? 'restriction_rule' : 'whitelist_rule';
	var errors = validateRule();
	if(errors.length > 0)
	{
		var data = {
			status: 1,
			msg: errors[0] + '<br>' +restStr.ARErr
		}
		Ha.showNotify(data);
	}
	else
	{
		var id = $('#form_submit_btn').attr('data-target-id');
		//uci数据更新
		setUciFromDocument(id, ruleType, rulePrefix);

		//表格dom更新
		var description = uci.get(pkg, id, "description");
		description = description == "" ? id : description;//名称

		var enabledCheck = createEnabledCheckbox(true);//启用

		var tr = createTrs([[ description,  enabledCheck, createEditButton(true), createRemoveButton(id), id]]);
		$(tr).insertAfter($('#' + id));
		$('#' + id).remove();

		setTableBtnAction();

		$('#formModal').modal('hide');
		// 重置表单
		setDocumentData(emptyUci);
	}
}

function setTableBtnAction(){
	$('#rule_table_container').find('input').click(function(){//启用按钮
							 	var id = $(this).parent().parent().prop('id');
							 	var enabled = $(this).prop('checked');
							 	setRowEnabled(id,enabled);
							 });
	$('#exception_table_container').find('input').click(function(){//启用按钮
							 	var id = $(this).parent().parent().prop('id');
							 	var enabled = $(this).prop('checked');
							 	setRowEnabled(id,enabled);
							 });
	$('#rule_table_container').find('.btn-danger').click(function(){//删除按钮
							 	var id = $(this).attr('data-del-target');
							 	removeRule(id);
							 });
	$('#exception_table_container').find('.btn-danger').click(function(){//删除按钮
							 	var id = $(this).attr('data-del-target');
							 	removeRule(id);
							 });

	$('#rule_table_container').find('.btn-primary').click(function(){
								var id = $(this).parent().parent().prop('id');
								alterToRestrictionsEdit(id);
							});
	$('#exception_table_container').find('.btn-primary').click(function(){
										var id = $(this).parent().parent().prop('id');
										alterToExceptionsEdit(id);
									});

}

function addAddressesToTable(textId, tableContainerId, macsValid)
{
	var newAddrs = $('#' + textId).val();
	var valid = macsValid ?  validateMultipleIpsOrMacs(newAddrs) : validateMultipleIps(newAddrs);
	if(valid == 0)
	{
		var currAddrs = [];
		$('#' + tableContainerId).find('.ip_span').each(function(){
			currAddrs.push($(this).html());
		});
		valid = currAddrs.length == 0 || (!testAddrOverlap(newAddrs, currAddrs.join(","))) ? 0 : 1;
		if(valid == 0){

			newAddrs = newAddrs.replace(/^[\t ]*/, "");
			newAddrs = newAddrs.replace(/[\t ]*$/, "");
			var addrs = newAddrs.split(/[\t ]*,[\t ]*/);

			if(addrs.length > 0)
			{
				makeIpTable(addrs,tableContainerId);
			}
			$('#' + textId).val('');
		}
	}

	return valid;
}

function testAddrOverlap(addrStr1, addrStr2)
{
	addrStr1 = addrStr1.replace(/^[\t ]+/, "");
	addrStr1 = addrStr1.replace(/[\t ]+$/, "");
	addrStr2 = addrStr2.replace(/^[\t ]+/, "");
	addrStr2 = addrStr2.replace(/[\t ]+$/, "");

	var split1 = addrStr1.split(/[,\t ]+/);
	var split2 = addrStr2.split(/[,\t ]+/);
	var index1;
	var overlapFound = false;
	for(index1=0; index1 < split1.length && (!overlapFound); index1++)
	{
		var index2;
		for(index2=0; index2 <split2.length && (!overlapFound); index2++)
		{
			overlapFound = overlapFound || testSingleAddrOverlap(split1[index1], split2[index2]);
		}
	}
	return overlapFound;
}

function testSingleAddrOverlap(addrStr1, addrStr2)
{
	/*
	 * this adjustment is useful in multiple places, particularly quotas
	 * if you don't want these conversions, just validate quota BEFORE you
	 * try calling this function
	 */
	var adj = function(addrStr)
	{
		addrStr = addrStr == "" ? "ALL" : addrStr.toUpperCase();
		if(addrStr == "ALL_OTHERS_COMBINED" || addrStr == "ALL_OTHERS_INDIVIDUAL")
		{
			addrStr = "ALL_OTHERS_COMBINED";
		}
		return addrStr;
	}
	addrStr1 = adj(addrStr1);
	addrStr2 = adj(addrStr2);

	var matches = false;
	if(addrStr1 == addrStr2) //can test MAC addr equality as well as ALL/OTHER variables we use sometimes
	{
		matches = true;
	}
	else //assume we're dealing with an actual IP / IP subnet / IP Range
	{
		if(validateMultipleIps(addrStr1) > 0 || validateMultipleIps(addrStr2) > 0 || addrStr1.match(",") || addrStr2.match(",") )
		{
			matches = false;
		}
		else
		{
			var parsed1 = getIpRangeIntegers(addrStr1);
			var parsed2 = getIpRangeIntegers(addrStr2);
			matches = parsed1[0] <= parsed2[1] && parsed1[1] >= parsed2[0]; //test range overlap, inclusive
		}
	}
	return matches;
}

function getIpRangeIntegers(ipStr)
{
	var startInt = 0;
	var endInt = 0;
	if(ipStr.match(/\//))
	{
		var split = ipStr.split(/[\t ]*\/[\t ]*/);
		var ipInt = getIpInteger(split[0]);
		var ipMaskInt = (split[1]).match(/\./) ? getIpInteger(split[1]) : getMaskInteger(split[1]);
		startInt = ipInt & ipMaskInt;
		endInt = startInt | ( ~ipMaskInt );
	}
	else if(ipStr.match(/-/))
	{
		var split = ipStr.split(/[\t ]*\-[\t ]*/);
		startInt = getIpInteger(split[0]);
		endInt = getIpInteger(split[1]);
	}
	else
	{
		startInt = getIpInteger(ipStr);
		endInt = startInt;
	}
	return [startInt, endInt];

}

function getIpInteger(ipStr)
{
	ipStr = ipStr == null ? "" : ipStr;
	var ip = ipStr.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/);
	if(ip)
	{
		return (+parsePaddedInt(ip[1])<<24) + (+parsePaddedInt(ip[2])<<16) + (+parsePaddedInt(ip[3])<<8) + (+parsePaddedInt(ip[4]));
	}
	return parseInt(""); //will return NaN
}

function parsePaddedInt(intStr)
{
	intStr = intStr == null ? "" : intStr;
	intStr = intStr.replace(/[\t ]+/, "");
	while( (intStr.length > 1 && intStr.match(/^0/)) || (intStr.length > 2 && intStr.match(/^\-0/)) )
	{
		intStr = intStr.replace(/^0/, "");
		intStr = intStr.replace(/^\-0/, "-");
	}
	return parseInt(intStr);
}

function makeIpTable(addrs,id){
	for(var i=0; i<addrs.length; i++){
		var ip_dom = '<span class="ip_spans"><span class="ip_span">' + addrs[i] + '</span>&nbsp;<span class="del_ip_span" title="delete this ip(s)">&times;</span>&nbsp;&nbsp;&nbsp;&nbsp;</span><wbr>';
		$('#' + id).append(ip_dom);

		$('.del_ip_span').click(function(){
			$(this).parent().remove();
		});
	}
}

function validateMac(mac)
{
	var errorCode = 0;
	var macFields = mac.split(/:/);
	if(macFields.length != 6)
	{
		errorCode = 2;
	}
	else
	{
		for(fieldIndex=0; fieldIndex < 6 && errorCode == 0; fieldIndex++)
		{
			field = macFields[fieldIndex];
			if(field.match(/^[0123456789ABCDEFabcdef]{2}$/) == null)
			{
				errorCode = 1;
			}
		}
	}
	return errorCode;
}

function addUrlToTable( textId, selectId, tableContainerId )
{
	
	var newUrl = $('#' + textId).val();
	var urlType = $('#' + selectId).val();
	var valid = validateUrl(newUrl, selectId);
	if(valid == 0)
	{
		var urlSpan = createUrlSpan(newUrl);
		console.log(urlSpan);

		var part = urlType.match("domain") ? "domain" : "full";
		var type = urlType.substring(urlType.lastIndexOf("_")+1);
		var del_btn = '<button class="btn btn-danger btn-sm del_url_btn"></button>';
		var tr = '<tr><td>' + part + '</td><td>' + type + '</td><td>' + urlSpan + '</td><td><button class="btn btn-danger btn-sm del_url_btn">Remove</button></td></tr>';

		$('#' + tableContainerId).append(tr).parent().find('thead').removeClass('hidden');
		$('#' + textId).val('');
		$('#' + selectId).find('option').first().prop('selected',true);
		$('.del_url_btn').click(function(){
			$(this).parent().parent().remove();
			if(!$('#' + tableContainerId).find('tr').length){
				$('#' + tableContainerId).parent().find('thead').addClass('hidden');
			}
			return false;
		});
	}
	else
	{
		if( newUrl.length == 0)
		{
			alert(restStr.UMZErr);
		}
		else
		{
			alert(restStr.UChErr+"\n");
		}
	}
}

// function validateRule(controlDocument, rulePrefix)
function validateRule()
{
	// controlDocument = controlDocument == null ? document : controlDocument;
	var inputIds = ["hours_active", "days_and_hours_active", "remote_port", "local_port"];
	var labelIds = ["hours_active_label","days_and_hours_active_label","remote_port_label","local_port_label"];
	var functions = [validateHours, validateWeeklyRange, validateMultiplePorts, validateMultiplePorts];
	var validReturnCodes = [0,0,0,0];
	var visibilityIds = ["hours_active_container", "days_and_hours_active_container", "remote_port_container", "local_port_container"];
	if($("#all_access").prop('checked'))
	{
		visibilityIds[2] = "resources_container";
		visibilityIds[3] = "resources_container";
	}

	return proofreadFields(inputIds, labelIds, functions, validReturnCodes, visibilityIds);
}

function validateHours(hoursStr)
{
	var commaSplit = hoursStr.match(/,/) ? hoursStr.split(/,/) : [ hoursStr ] ;
	var valid = true;
	for(commaIndex = 0; commaIndex < commaSplit.length && valid; commaIndex++)
	{
		var splitStr = commaSplit[commaIndex].split(/-/);
		var nextValid = splitStr.length == 2;
		if(nextValid)
		{
			nextValid = nextValid && splitStr[0].match(/^[\t ]*([0-1]?[0-9]|2[0-3])(:[0-5][0-9])?[\t ]*$/)
			nextValid = nextValid && splitStr[1].match(/^[\t ]*([0-1]?[0-9]|2[0-3])(:[0-5][0-9])?[\t ]*$/)
		}
		valid = valid && nextValid;
	}
	return valid ? 0 : 1;
}

function validateWeeklyRange(weeklyStr)
{
	var commaSplit = weeklyStr.match(/,/) ? weeklyStr.split(/,/) : [ weeklyStr ] ;
	var valid = true;
	for(commaIndex = 0; commaIndex < commaSplit.length && valid; commaIndex++)
	{
		var splitStr = commaSplit[commaIndex].split(/-/);
		var nextValid = splitStr.length == 2;
		if(nextValid)
		{
			var dayReg=new RegExp("^[\\t ]*("+UI.Sun+"|"+UI.Mon+"|"+UI.Tue+"|"+UI.Wed+"|"+UI.Thu+"|"+UI.Fri+"|"+UI.Sat+")[\\t ]*([0-1]?[0-9]|2[0-3])(:[0-5]?[0-9])?(:[0-5]?[0-9])?[\\t ]*$");
			nextValid = nextValid && splitStr[0].match(dayReg);
			nextValid = nextValid && splitStr[1].match(dayReg);
		}
		valid = valid && nextValid;
	}
	return valid ? 0 : 1;
}

function proofreadFields(inputIds, labelIds, functions, validReturnCodes, visibilityIds )
{
	// fieldDocument = fieldDocument == null ? document : fieldDocument;

	var errorArray= new Array();
	for (idIndex in inputIds)
	{
		isVisible = true;
		if(visibilityIds != null)
		{
			if(visibilityIds[idIndex] != null)
			{
				// visibilityElement = $('#' + visibilityIds[idIndex]);
				isVisible = !$('#' + visibilityIds[idIndex]).hasClass('hidden');
			}
		}
		if(isVisible)
		{
			f = functions[idIndex];
			proofreadText(inputIds[idIndex], f, validReturnCodes[idIndex]);//输入过程中颜色验证

			if(f($('#' + inputIds[idIndex]).val()) != validReturnCodes[idIndex])
			{
				labelStr = labelIds[idIndex] + "";
				if( $('#' + labelIds[idIndex]) != null)
				{
					labelStr = $('#' + labelIds[idIndex]).html();
				}
				else
				{
					alert("error in proofread: label with id " +  labelIds[idIndex] + " is not defined");
				}
				errorArray.push(UI.prfErr+" " + labelStr);
			}
		}
	}
	return errorArray;
}

function proofreadText(input, proofFunction, validReturnCode)//主要是输入过程中颜色变化
{
	// if(input.disabled != true)
	// {
	// 	input.style.color = (proofFunction(input.value) == validReturnCode) ? "black" : "red";
	// }
	$('#' + input).css('color',(proofFunction($('#' + input).val()) == validReturnCode) ? "black" : "red")
}

function validateMultipleIps(ips)
{
	ips = ips.replace(/^[\t ]+/g, "");
	ips = ips.replace(/[\t ]+$/g, "");
	var splitIps = ips.split(/[\t ]*,[\t ]*/);
	var valid = splitIps.length > 0 ? 0 : 1;
	while(valid == 0 && splitIps.length > 0)
	{
		var nextIp = splitIps.pop();
		if(nextIp.match(/-/))
		{
			var nextSplit = nextIp.split(/[\t ]*-[\t ]*/);
			valid = nextSplit.length==2 && validateIP(nextSplit[0]) == 0 && validateIP(nextSplit[1]) == 0 ? 0 : 1;
		}
		else
		{
			valid = validateIpRange(nextIp);
		}
	}
	return valid;
}
function proofreadMultipleIps(input)
{
	proofreadText(input, validateMultipleIps, 0);
}
function proofreadMultipleIpsOrMacs(input)
{
	proofreadText(input, validateMultipleIpsOrMacs, 0);
}

function validateIpRange(range)
{
	var valid = 1; //initially invalid, 0=valid, 1=invalid
	if(range.indexOf("/") > 0)
	{
		var split=range.split("/");
		if(split.length == 2)
		{
			var ipValid = validateIP(split[0]);
			var maskValid = validateNetMask(split[1]) == 0 || validateNumericRange(split[1],1,31) == 0 ? 0 : 1;
			valid = ipValid == 0 && maskValid == 0 ? 0 : 1;
		}
	}
	else
	{
		valid = validateIP(range);
	}
	return valid;
}

function validateMultipleIpsOrMacs(addresses)
{
	var addr = addresses.replace(/^[\t ]+/g, "");
	addr = addr.replace(/[\t ]+$/g, "");
	var splitAddr = addr.split(/[\t ]*,[\t ]*/);
	var valid = splitAddr.length > 0 ? 0 : 1;
	while(valid == 0 && splitAddr.length > 0)
	{
		var nextAddr = splitAddr.pop();
		if(nextAddr.match(/-/))
		{
			var nextSplit = nextAddr.split(/[\t ]*-[\t ]*/);
			valid = nextSplit.length==2 && validateIP(nextSplit[0]) == 0 && validateIP(nextSplit[1]) == 0 ? 0 : 1;
		}
		else if(nextAddr.match(/:/))
		{
			valid = validateMac(nextAddr);
		}
		else
		{
			valid = validateIpRange(nextAddr);
		}
	}
	return valid;

}

function validateMultiplePorts(portStr)
{
	portStr = portStr.replace(/^[\t ]+/g, "");
	portStr = portStr.replace(/[\t ]+$/g, "");
	var splitStr = portStr.match(/,/) ?  portStr.split(/[\t ]*,[\t ]*/) : [portStr];
	var valid = true;
	for(splitIndex = 0; splitIndex < splitStr.length; splitIndex++)
	{
		splitStr[splitIndex].replace(/^[\t ]+/g, "");
		splitStr[splitIndex].replace(/[\t ]+$/g, "");
		valid = valid && (validatePortOrPortRange(splitStr[splitIndex]) == 0);
	}
	return valid ? 0 : 1;
}

function validateIP(address){//验证ip是否有效
	var errorCode = 0;
	if(address == "0.0.0.0")
	{
		errorCode = 1;
	}
	else if(address == "255.255.255.255")
	{
		errorCode = 2;
	}
	else
	{
		var ipFields = address.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
		if(ipFields == null)
		{
			errorCode = 5;
		}
		else
		{
			for(field=1; field <= 4; field++)
			{
				if(ipFields[field] > 255)
				{
					errorCode = 4;
				}
				if(ipFields[field] == 255 && field==4)
				{
					errorCode = 3;
				}
			}
		}
	}
	return errorCode;
}

function proofreadMultiplePorts(input)
{
	proofreadText(input, validateMultiplePorts, 0);
}

function validatePortOrPortRange(ports)
{
	var errorCode = 0;
	if(ports.match(/-/) != null)
	{
		var splitPorts=ports.split(/-/);

		if(splitPorts.length > 2)
		{
			errorCode =  5;
		}
		else
		{
			error1 = validateNumericRange(splitPorts[0], 1, 65535);
			error2 = validateNumericRange(splitPorts[1], 1, 65535);
			errorCode = error1 + (10*error2);
			if(errorCode == 0)
			{
				errorCode = splitPorts[1] - splitPorts[0] >= 0 ? 0 : 4;
			}
		}
	}
	else
	{
		errorCode = validateNumericRange(ports, 1, 65535);
	}
	return errorCode;
}

function validateNumericRange(num, min, max)
{
	var errorCode = num.match(/^[\d]+$/) == null ? 1 : 0;
	if(errorCode == 0)
	{
		errorCode = num < min ? 2 : 0;
	}
	if(errorCode == 0)
	{
		errorCode = num > max ? 3 : 0;
	}
	return errorCode;
}

function validateUrl(url, selectId)
{
	var urlType = $('#' + selectId);
	var valid = url.match(/[\n\r\"\']/) || url.length == 0 ? 1 : 0;
	return valid;
}

function proofreadUrl(input)
{
	proofreadText(input, validateUrl, 0);
}

function createUrlSpan(urlStr)
{
	
	var splitUrl = [];
	while(urlStr.length > 0)
	{
		var next = urlStr.substr(0, 30);
		urlStr = urlStr.substr(30);
		splitUrl.push(urlStr.length > 0 ? next + "-" : next);
	}
	
	var urlSpan = '';
	while(splitUrl.length > 0)
	{
		urlSpan += splitUrl.shift();
		if(splitUrl.length > 0)
		{
			urlSpan += '<br>';
		}
	}
	return urlSpan;
}
function parseUrlSpan(urlSpan)
{
	var children = urlSpan.childNodes;
	var parsedUrl = "";
	for(childIndex=0; childIndex < children.length; childIndex++)
	{
		if(childIndex %2 == 0)
		{
			var nextStr = children[childIndex].data;
			if(childIndex < children.length-1)
			{
				nextStr = nextStr.substr(0, nextStr.length-1);
			}
			parsedUrl = parsedUrl + nextStr;
		}
	}
	return parsedUrl;
}

function getDocumentDataFromUci(sourceUci, sectionId, isSave){
	var data = {};
	var description = sourceUci.get(pkg, sectionId, "description");//获取描述或名称
	data.description = description == "" ? sectionId : description;

	
	var localAddr = getOptionsAndTypeFromUci(sourceUci, pkg, sectionId, 'local_addr');
	data.local_addr_type = localAddr.type;
	data.local_addr_option = localAddr.optionValue;

	var daysAndHours = sourceUci.get(pkg, sectionId, "active_weekly_ranges");//日程规划
	console.log(daysAndHours);
	data.daysAndHours = weekly_i18n(daysAndHours,"uci");
	var hours = sourceUci.get(pkg, sectionId, "active_hours");
	var allDay = (daysAndHours == "" && hours == "");
	data.hours = hours;
	data.allDay = allDay;
	data.scheduleRepeats = daysAndHours == "" ? "daily" : "weekly";

	var allDays = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
	var dayStr =  sourceUci.get(pkg, sectionId, "active_weekdays");
	var days = [];
	if(dayStr == "")
	{
		days = allDays;
	}
	else
	{
		days = dayStr.split(/,/);
	}
	data.days = days;

	var everyDay = (daysAndHours == "");
	var dayIndex=0;
	for(dayIndex = 0; dayIndex < allDays.length; dayIndex++)
	{
		var nextDay = allDays[dayIndex];
		var dayFound = false;
		var testIndex=0;
		for(testIndex=0; testIndex < days.length && !dayFound; testIndex++)
		{
			dayFound = days[testIndex] == nextDay;
		}
		everyDay = everyDay && dayFound;
	}
	data.everyDay = everyDay;

	var remoteAddr = getOptionsAndTypeFromUci(sourceUci, pkg, sectionId, 'remote_addr');
	data.remote_ip_type = remoteAddr.type;
	data.remote_ip_option = remoteAddr.optionValue;

	var localPort = getOptionsAndTypeFromUci(sourceUci, pkg, sectionId, 'local_port');
	data.local_port_type = localPort.type;
	data.local_port_option = localPort.optionValue;

	var remotePort = getOptionsAndTypeFromUci(sourceUci, pkg, sectionId, 'remote_port');
	data.remote_port_type = remotePort.type;
	data.remote_port_option = remotePort.optionValue;

	var proto = sourceUci.get(pkg, sectionId, "proto");
	data.transport_protocol = proto != "tcp" && proto != "udp" ? "both" : proto;

	var app_proto = sourceUci.get(pkg, sectionId, "app_proto");
	var app_proto_type = app_proto == "" ? "except" : "only";
	data.app_protocol = app_proto == "" ? sourceUci.get(pkg, sectionId, "not_app_proto") : app_proto;
	data.app_protocol_type = app_proto == "" ? "all" : app_proto_type;

	var urlTypes = [ "url_contains", "url_regex", "url_exact", "url_domain_contains", "url_domain_regex", "url_domain_exact" ];
	var urlExprTypes = [ "contains", "regex", "exact", "contains", "regex", "exact" ];
	var urlPartTypes = [ "full", "full", "full", "domain", "domain", "domain" ];
	var urlPrefix = "";
	var urlDefinitions = [];
	var urlDefFound = false;
	var urlTypeIndex = 0;
	var urlMatchType = "all";
	for(urlTypeIndex=0; urlTypeIndex < urlTypes.length; urlTypeIndex++)
	{
		urlDefinitions[urlTypeIndex] = sourceUci.get(pkg, sectionId, urlTypes[urlTypeIndex]);
		urlDefFound = urlDefinitions[urlTypeIndex] != "" ? true : urlDefFound;
		urlMatchType = urlDefinitions[urlTypeIndex] != "" ? "only" : urlMatchType;
	}
	if(!urlDefFound)
	{
		urlPrefix = "not_";
		for(urlTypeIndex=0; urlTypeIndex < urlTypes.length; urlTypeIndex++)
		{
			urlDefinitions[urlTypeIndex] = sourceUci.get(pkg, sectionId, urlPrefix + urlTypes[urlTypeIndex]);
			urlDefFound = urlDefinitions[urlTypeIndex] != "" ? true : urlDefFound;
			urlMatchType = urlDefinitions[urlTypeIndex] != "" ? "except" : urlMatchType;
		}
	}

	if(urlDefFound)
	{
		var url_data = [];
		for(urlTypeIndex=0; urlTypeIndex < urlTypes.length; urlTypeIndex++)
		{
			var defStr = urlDefinitions[urlTypeIndex];
			if(defStr != "")
			{
				defStr = defStr.replace(/^[\t ]*\"/, "");
				defStr = defStr.replace(/\"[\t ]*$/, "");
				def = defStr.match(/\".*\"/) ? defStr.split(/\"[\t, ]*\"/) : [ defStr ];
				var defIndex=0;
				for(defIndex=0; defIndex < def.length; defIndex++)
				{
					url_data.push([ urlPartTypes[urlTypeIndex], urlExprTypes[urlTypeIndex], def[defIndex], '<button class="btn btn-danger btn-sm del_url_btn">Remove</button>', def[defIndex] ]);
				}
			}
		}
	}
	data.url_type = urlMatchType;
	data.url_data = typeof(url_data) != 'undefined' ? url_data : '';

	var allResourcesBlocked = true;
	var resourceTypeIds = ["remote_ip_type", "remote_port_type", "local_port_type", "transport_protocol", "app_protocol_type", "url_type" ];
	for(typeIndex=0; typeIndex < resourceTypeIds.length; typeIndex++)
	{
		var type = data[resourceTypeIds[typeIndex]];
		allResourcesBlocked = allResourcesBlocked && (type == "all" || type == "both");
	}
	data.all_resources_blocked = allResourcesBlocked;

	if(isSave){
		var dataForSave = {};
		dataForSave.description = data.description;
		dataForSave.not_local_addr = sourceUci.get(pkg, sectionId, 'not_local_addr');
		dataForSave.local_addr = sourceUci.get(pkg, sectionId, 'local_addr');
		dataForSave.active_weekly_ranges = sourceUci.get(pkg, sectionId, "active_weekly_ranges");
		dataForSave.active_hours = data.hours;
		dataForSave.active_weekdays = dayStr;
		dataForSave.remote_addr = sourceUci.get(pkg, sectionId, 'remote_addr');
		dataForSave.not_remote_addr = sourceUci.get(pkg, sectionId, 'not_remote_addr');
		dataForSave.local_port = sourceUci.get(pkg, sectionId, 'local_port');
		dataForSave.not_local_port = sourceUci.get(pkg, sectionId, 'not_local_port');
		dataForSave.remote_port = sourceUci.get(pkg, sectionId, 'remote_port');
		dataForSave.not_remote_port = sourceUci.get(pkg, sectionId, 'not_remote_port');
		dataForSave.proto = sourceUci.get(pkg, sectionId, "proto");
		dataForSave.app_proto = sourceUci.get(pkg, sectionId, "app_proto");
		dataForSave.not_app_proto = sourceUci.get(pkg, sectionId, "not_app_proto");
		for(i=0; i < urlTypes.length; i++)
		{
			dataForSave[urlTypes[i]] = sourceUci.get(pkg, sectionId, urlTypes[i]);
			dataForSave['not_' + urlTypes[i]] = sourceUci.get(pkg, sectionId, 'not_' + urlTypes[i]);
		}

		return dataForSave;

	}

	return data;
}

function setDocumentData(data){

	$('#name').val(data.description);
	$('#applies_to_type').val(data.local_addr_type);
	alterApplyTo();
	if(data.local_addr_option){
		var ips = data.local_addr_option.split(',');
		var doms = setIpTable(ips);
		$('#ip_span_container').empty().append(doms);
	}

	$('#all_day').prop('checked',data.allDay);
	$('#every_day').prop('checked',data.everyDay);
	$('#schedule_repeats').val(data.scheduleRepeats || 'daily');
	alterSchedule();
	if(data.daysAndHours){
		$('#days_and_hours_active').val(data.daysAndHours);
	}
	if(data.hours){
		$('#hours_active').val(data.hours);
	}

	$('#all_access').prop('checked',data.all_resources_blocked);

	alterAllAccess();
	$('#remote_ip_type').val(data.remote_ip_type);
	alterRemoteIpType();
	if(data.remote_ip_option){
		var ips = data.remote_ip_option.split(',');
		var doms = setIpTable(ips);
		$('#remote_ip_span_container').empty().append(doms);
		//TODO按钮的click操作

	}

	$('#remote_port_type').val(data.remote_port_type);
	alterPortInput('remote_port');
	$('#remote_port').val(data.remote_port_option);

	$('#local_port_type').val(data.local_port_type);
	alterPortInput('local_port');
	$('#local_port').val(data.local_port_option);

	$('#transport_protocol').val(data.transport_protocol);

	$('#app_protocol_type').val(data.app_protocol_type);
	alterPortInput('app_protocol');
	$('#app_protocol').val(data.app_protocol);

	$('#url_type').val(data.url_type);
	alterUrlType();
	if(data.url_data && data.url_data.length>0){
		var trs = createTrs(data.url_data);
		$('#url_container').empty().append(trs).parent().find('thead').removeClass('hidden');
		$('.del_url_btn').click(function(){
			$(this).parent().parent().remove();
			if(!$('#url_container').find('tr').length){
				$('#url_container').parent().find('thead').addClass('hidden');
			}
			return false;
		});
	}
}

function setIpTable(ips){
	var doms = [];
	for(var i=0; i<ips.length; i++){
		doms.push('<span class="ip_spans"><span class="ip_span">' + ips[i] + '</span><span class="del_ip_span">&times;</span>&nbsp;&nbsp;&nbsp;&nbsp;</span>');
	}

	return doms.join('');
}

function getOptionsAndTypeFromUci(sourceUci,pkg,sectionId,optionId){//改造自setIpTableAndSelectFromUci
	var optionValue = sourceUci.get(pkg, sectionId, optionId);
	var type = "only";
	if(optionValue == "")
	{
		optionValue = sourceUci.get(pkg, sectionId, "not_" + optionId)
		type = optionValue != "" ? "except" : "all";
	}
	var data = {
		optionValue: optionValue,
		type: type
	};

	return data;
}

function setUciFromDocument(sectionId, ruleType, rulePrefix)
{
	// note: we assume error checking has already been done 
	uci.removeSection(pkg, sectionId);
	uci.set(pkg, sectionId, "", ruleType);//restriction_rule
	uci.set(pkg, sectionId, "is_ingress", "0");


	uci.set(pkg, sectionId, "", ruleType);
	uci.set(pkg, sectionId, "description", $('#name').val());

	//设置local_ip
	setFromIpTable(pkg, sectionId, "local_addr", 'ip_span_container');

	// var daysActive = controlDocument.getElementById(rulePrefix + "days_active");
	if( !$('#days_container').hasClass('hidden') ){
		var daysActive = [];
		var dayIds = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		
		for(dayIndex =0; dayIndex < dayIds.length; dayIndex++)
		{
			if($('#rule_' + dayIds[dayIndex]).prop('checked'))
			{
				daysActive.push(dayIds[dayIndex]);
			}
		}
		var daysActiveStr = daysActive.join(",");
		uci.set(pkg, sectionId, "active_weekdays", daysActiveStr);
	}
	setIfVisible(pkg, sectionId, "active_hours", "hours_active", "hours_active_container" );
	// var weekly_ranges=controlDocument.getElementById(rulePrefix + "days_and_hours_active");
	var weekly_ranges=$('#days_and_hours_active');
	weekly_ranges.val(weekly_i18n(weekly_ranges.val(), "table"));
	// var weekly_ranges=$('#rule_days_and_hours_active');
	// weekly_ranges.val(weekly_i18n(weekly_ranges.val(), "table"));
	setIfVisible( pkg, sectionId, "active_weekly_ranges", "days_and_hours_active", "days_and_hours_active_container" );

	if(!$('#all_access').prop('checked'))
	{
		setFromIpTable(pkg, sectionId, "remote_addr", 'remote_ip_span_container');
		setIfVisible( pkg, sectionId, "remote_port", "remote_port", "remote_port", "remote_port_type");
		setIfVisible( pkg, sectionId, "local_port", "local_port", "local_port", "local_port_type");
		
		uci.set(pkg, sectionId, "proto", $('#transport_protocol').val());

		var appProtocolType = $('#app_protocol_type').val();
		if(appProtocolType != "all")
		{
			var prefix = appProtocolType == "except" ? "not_" : "";
			uci.set(pkg, sectionId, prefix + "app_proto", $('#app_protocol').val());
		}

		var urlMatchType = $('#url_type').val();
		if(urlMatchType != "all" && $('#url_container').html() != '')
		{
			// var urlData = getTableDataArray(urlTable, true, false);
			var urlData = getUrlFromTable();
			var urlPrefix = urlMatchType == "except" ? "not_" : "";
			var urlDefStrings = [];
			var urlIndex;
			for(urlIndex = 0; urlIndex < urlData.length; urlIndex++)
			{
				var urlId = urlData[urlIndex][0];
				urlId = (urlId.match("domain") ? "url_domain_" : "url_") + urlData[urlIndex][1];
				// urlStr = parseUrlSpan(urlData[urlIndex][2]);
				urlStr = urlData[urlIndex][2];
				if(urlDefStrings[urlId] != null)
				{
					urlDefStrings[urlId] = urlDefStrings[urlId] + ",\"" + urlStr + "\"";
				}
				else
				{
					urlDefStrings[urlId] = "\"" + urlStr + "\""
				}
			}

			var parts = ["url_", "url_domain_"];
			var exprs = ["exact", "contains", "regex"];
			var partIndex=0;
			var exprIndex=0;
			for(partIndex=0; partIndex < 2; partIndex++)
			{
				for(exprIndex=0; exprIndex < 3; exprIndex++)
				{
					var id = parts[partIndex] + exprs[exprIndex];
					if(urlDefStrings[id] != null)
					{
						uci.set(pkg, sectionId, urlPrefix + id, urlDefStrings[id]);
					}
				}
			}
		}
	}
}


function setDocumentFromUci(controlDocument, sourceUci, sectionId, ruleType, rulePrefix)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	var description = sourceUci.get(pkg, sectionId, "description");//获取描述或名称
	description = description == "" ? sectionId : description;
	$('#' + rulePrefix + "name").val(description);

	// setIpTableAndSelectFromUci(controlDocument, sourceUci, pkg, sectionId, "local_addr", rulePrefix + "applies_to_table_container", rulePrefix + "applies_to_table", rulePrefix + "applies_to", rulePrefix + "applies_to_addr");


	var daysAndHours = sourceUci.get(pkg, sectionId, "active_weekly_ranges");
	var hours = sourceUci.get(pkg, sectionId, "active_hours");
	var allDay = (daysAndHours == "" && hours == "");
	
	controlDocument.getElementById(rulePrefix + "hours_active").value = hours;
	controlDocument.getElementById(rulePrefix + "all_day").checked = allDay;
	controlDocument.getElementById(rulePrefix + "days_and_hours_active").value = weekly_i18n(daysAndHours,"uci");
	setSelectedValue(rulePrefix + "schedule_repeats", (daysAndHours == "" ? "daily" : "weekly"), controlDocument);

	var allDays = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
	var dayStr =  sourceUci.get(pkg, sectionId, "active_weekdays");
	var days = [];
	if(dayStr == "")
	{
		days = allDays;
	}
	else
	{
		days = dayStr.split(/,/);
	}
	
	var everyDay = (daysAndHours == "");
	var dayIndex=0;
	for(dayIndex = 0; dayIndex < allDays.length; dayIndex++)
	{
		var nextDay = allDays[dayIndex];
		var dayFound = false;
		var testIndex=0;
		for(testIndex=0; testIndex < days.length && !dayFound; testIndex++)
		{
			dayFound = days[testIndex] == nextDay;
		}
		everyDay = everyDay && dayFound;
		controlDocument.getElementById(rulePrefix + allDays[dayIndex]).checked = dayFound;
	}
	controlDocument.getElementById(rulePrefix + "every_day").checked = everyDay;


	setIpTableAndSelectFromUci(controlDocument, sourceUci, pkg, sectionId, "remote_addr", rulePrefix + "remote_ip_table_container", rulePrefix + "remote_ip_table", rulePrefix + "remote_ip_type", rulePrefix + "remote_ip");
	setTextAndSelectFromUci(controlDocument, sourceUci,  pkg, sectionId, "remote_port", rulePrefix + "remote_port", rulePrefix + "remote_port_type");
	setTextAndSelectFromUci(controlDocument, sourceUci, pkg, sectionId, "local_port", rulePrefix + "local_port", rulePrefix + "local_port_type");

	var proto = sourceUci.get(pkg, sectionId, "proto");
	proto = proto != "tcp" && proto != "udp" ? "both" : proto;
	setSelectedValue(rulePrefix + "transport_protocol", proto, controlDocument);

	var app_proto = sourceUci.get(pkg, sectionId, "app_proto");
	var app_proto_type = app_proto == "" ? "except" : "only";
	app_proto = app_proto == "" ? sourceUci.get(pkg, sectionId, "not_app_proto") : app_proto;
	app_proto_type = app_proto == "" ? "all" : app_proto_type;
	setSelectedValue(rulePrefix + "app_protocol_type", app_proto_type, controlDocument);
	setSelectedValue(rulePrefix + "app_protocol", app_proto, controlDocument);
	




	var urlTypes = [ "url_contains", "url_regex", "url_exact", "url_domain_contains", "url_domain_regex", "url_domain_exact" ];
	var urlExprTypes = [ "contains", "regex", "exact", "contains", "regex", "exact" ];
	var urlPartTypes = [ "full", "full", "full", "domain", "domain", "domain" ];
	var urlPrefix = "";
	var urlDefinitions = [];
	var urlDefFound = false;
	var urlTypeIndex = 0;
	var urlMatchType = "all";
	for(urlTypeIndex=0; urlTypeIndex < urlTypes.length; urlTypeIndex++)
	{
		urlDefinitions[urlTypeIndex] = sourceUci.get(pkg, sectionId, urlTypes[urlTypeIndex]);
		urlDefFound = urlDefinitions[urlTypeIndex] != "" ? true : urlDefFound;
		urlMatchType = urlDefinitions[urlTypeIndex] != "" ? "only" : urlMatchType;
	}
	if(!urlDefFound)
	{
		urlPrefix = "not_";
		for(urlTypeIndex=0; urlTypeIndex < urlTypes.length; urlTypeIndex++)
		{
			urlDefinitions[urlTypeIndex] = sourceUci.get(pkg, sectionId, urlPrefix + urlTypes[urlTypeIndex]);
			urlDefFound = urlDefinitions[urlTypeIndex] != "" ? true : urlDefFound;
			urlMatchType = urlDefinitions[urlTypeIndex] != "" ? "except" : urlMatchType;
		}
	}
	setSelectedValue(rulePrefix + "url_type", urlMatchType, controlDocument);
	
	var urlTableContainer = controlDocument.getElementById(rulePrefix + "url_match_table_container");
	if(urlTableContainer.childNodes.length > 0)
	{
		urlTableContainer.removeChild(urlTableContainer.firstChild);
	}


	if(urlDefFound)
	{
		var table = createTable([restStr.UPrt, restStr.MTyp, restStr.MTExp], [], rulePrefix + "url_match_table", true, false, null, null, controlDocument);
		for(urlTypeIndex=0; urlTypeIndex < urlTypes.length; urlTypeIndex++)
		{
			var defStr = urlDefinitions[urlTypeIndex];
			if(defStr != "")
			{
				defStr = defStr.replace(/^[\t ]*\"/, "");
				defStr = defStr.replace(/\"[\t ]*$/, "");
				def = defStr.match(/\".*\"/) ? defStr.split(/\"[\t, ]*\"/) : [ defStr ];
				var defIndex=0;
				for(defIndex=0; defIndex < def.length; defIndex++)
				{
					addTableRow(table, [ urlPartTypes[urlTypeIndex], urlExprTypes[urlTypeIndex], createUrlSpan(def[defIndex], controlDocument) ], true, false, null, null, controlDocument);
				}
			}
		}
		urlTableContainer.appendChild(table);
	}


	controlDocument.getElementById(rulePrefix + "url_match").value = "";
	
	var allResourcesBlocked = true;
	var resourceTypeIds = ["remote_ip_type", "remote_port_type", "local_port_type", "transport_protocol", "app_protocol_type", "url_type" ];
	for(typeIndex=0; typeIndex < resourceTypeIds.length; typeIndex++)
	{
		var type = getSelectedValue(rulePrefix + resourceTypeIds[typeIndex], controlDocument);
		allResourcesBlocked = allResourcesBlocked && (type == "all" || type == "both");
	}
	controlDocument.getElementById(rulePrefix + "all_access").checked = allResourcesBlocked;

	setVisibility(controlDocument, rulePrefix);
}
function setIpTableAndSelectFromUci(controlDocument, sourceUci, pkg, sectionId, optionId, tableContainerId, tableId, prefixSelectId, textId)
{
	controlDocument = controlDocument == null ? document : controlDocument;
	var optionValue = sourceUci.get(pkg, sectionId, optionId);
	var type = "only";
	if(optionValue == "")
	{
		optionValue = sourceUci.get(pkg, sectionId, "not_" + optionId)
		type = optionValue != "" ? "except" : "all";
	}
	
	setSelectedValue(prefixSelectId, type, controlDocument);


	var tableContainer = controlDocument.getElementById(tableContainerId);
	if(tableContainer.childNodes.length > 0)
	{
		tableContainer.removeChild(tableContainer.firstChild);
	}	
	if(optionValue != "")
	{
		optionValue = optionValue.replace(/^[\t ]*/, "");
		optionValue = optionValue.replace(/[\t ]*$/, "");
		var ips = optionValue.split(/[\t ]*,[\t ]*/);


		var table = createTable([""], [], tableId, true, false, null, null, controlDocument);
		while(ips.length > 0)
		{
			addTableRow(table, [ ips.shift() ], true, false, null, null, controlDocument);
		}
		tableContainer.appendChild(table);
		
		controlDocument.getElementById(textId).value = "";
	}
}
function setTextAndSelectFromUci(controlDocument, sourceUci, pkg, sectionId, optionId, textId, prefixSelectId)
{
	controlDocument = controlDocument == null ? document : controlDocument;
	var optionValue = sourceUci.get(pkg, sectionId, optionId);
	var type = "only";
	if(optionValue == "")
	{
		optionValue = sourceUci.get(pkg, sectionId, "not_" + optionId)
		type = optionValue != "" ? "except" : "all";
	}
	setSelectedValue(prefixSelectId, type, controlDocument);

	// if option is not defined, optionValue is empty string, so no need to check for this case
	controlDocument.getElementById(textId).value = optionValue;
}

function setIfVisible(pkg, sectionId, optionId, textId, visId, prefixSelectId)
// setIfVisible(pkg, sectionId, "active_hours", "hours_active", "hours_active_container" );
{
	// visElement = controlDocument.getElementById(visId);
	// if(visElement.style.display != "none")
	if(!$('#' + visId).hasClass('hidden'))
	{
		var value = $('#' + textId).val();
		if(prefixSelectId != null)
		{
			prefixValue = $('#' + prefixSelectId).val();
			optionId = prefixValue == "except" ? "not_" + optionId : optionId;
		}
		uci.set(pkg, sectionId, optionId, value);
	}
}

function setFromIpTable(pkg, sectionId, optionId, containerId)
{
	var addrType = $('[remote_ip="' + optionId + '"]').val();
	var table = $('#' + containerId).html();
	if(addrType != "all" && table != '')
	{
		var ipData = [];
		$('#' + containerId).find('.ip_span').each(function(){
			ipData.push($(this).html());
		});
		var ipStr = "";
		for(ipIndex=0; ipIndex < ipData.length ; ipIndex++)
		{
			ipStr = ipStr + ipData[ipIndex] + ",";
		}
		ipStr = ipStr.replace(/,$/, "");
		if(ipStr.length > 0)
		{
			var prefix = addrType == "except" ? "not_" : "";
			uci.set(pkg, sectionId, prefix + optionId, ipStr);
		}
	}
}

function getUrlFromTable(){
	var data = [];
	$('#url_container').find('tr').each(function(){
		var url = [];
		$(this).find('td').each(function(index){
			if(index < 3){
				url.push($(this).html());
			}
		});
		data.push(url);
	});
	return data;
}

function weekly_i18n(weekly_schd, source) { //this is part of i18n; TODO: best to have an uci get language to see if absent to just return daystrings
	if (weekly_schd.length < 6) return weekly_schd;
	var localdays=[UI.Sun, UI.Mon, UI.Tue, UI.Wed, UI.Thu, UI.Fri, UI.Sat];
	var fwdays=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	var indays, outdays, splits, idx;
	var joiner=[];

	if (source == "uci") {
		indays=fwdays;
		outdays=localdays;
	} else { // from the browser
		indays=localdays;
		outdays=fwdays;
	}

	splits=weekly_schd.split(" ");
	for (idx=0; idx < splits.length; idx++) {
		var pos= indays.indexOf(splits[idx]);
		if (pos >= 0) {
			joiner[idx]=outdays[pos];
		} else {
			joiner[idx]=splits[idx];
		}
	}
	return joiner.join(" ");
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
	return inp.outerHTML;
}

function setSelectedValue(selectId, selection, controlDocument)
{
	var controlDocument = controlDocument == null ? document : controlDocument;

	var selectElement = controlDocument.getElementById(selectId);
	if(selectElement == null){ alert(UI.Err+": " + selectId + " "+UI.nex); }

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