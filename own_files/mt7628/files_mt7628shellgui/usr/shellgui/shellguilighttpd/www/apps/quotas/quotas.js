$('#applies_to_type').change(alterApplyto);
$('#max_up_type').change(function(){
	alterLimitInput('max_up_type','max_up','max_up_unit');
});
$('#max_down_type').change(function(){
	alterLimitInput('max_down_type','max_down','max_down_unit');
});
$('#max_combined_type').change(function(){
	alterLimitInput('max_combined_type','max_combined','max_combined_unit');
});
$('#quota_reset').change(alterQuoteaReset);

$('#quota_active').change(alterQuotaActive);

$('#quota_active_type').change(alterQuotaActiveType);

$('#quota_exceeded').change(function(){
	alterQuotaExceeded();
	// alterQuotaExceededClass();
	disableSaveBtn();
});
// $('#quota_qos_up,#quota_qos_down').blur(function(){
// 	alterQuotaExceededClass();
// });


$('#add_ip').focus(function(){
	$('#add_ip_help').removeClass('hidden').html(UI.Specify_an_IP_or_IP_range);
	$("#add_ip_input").removeClass('has-error');
});
$('#add_ip').bind('keyup blur',function(){
	checkIPs();
	disableSaveBtn();
});
function checkIPs(){
	var errorCode = 0;
	var ips = $('#add_ip').val();
	if(ips.length!=0 && validateMultipleIps(ips)){
		$("#add_ip_input").addClass('has-error');
		$('#add_ip_help').html('<span>'+UI.There_is_invalid_IP_or_IP_range_Exists+'.</span>');
		$('.add_ip_btn').prop('disabled',true);
		errorCode = 1;
	}else{
		$('#add_ip_help').removeClass('hidden').html(UI.Specify_an_IP_or_IP_range);
		$("#add_ip_input").removeClass('has-error');
		$('.add_ip_btn').prop('disabled',false);
	}
	return errorCode;
}
//添加ip到span_container
$('.add_ip_btn').click(function(){
	var valid = addAddressesToTable(document,"add_ip","ip_span_container","quota_ip_table",false, 3, false,true);
	if(!valid){
		$("#add_ip").focus();
		$("#add_ip_input").addClass('has-error');
		$('#add_ip_help').html('<span>'+UI.There_is_invalid_IP_or_IP_range_Exists+'.</span>');
	}
	return false;
});

$('#add_quota_btn').click(function(){
	$('#save_quota').html(UI.Add).attr('data-type','add');
	setDocumentFromUci(document, new UCIContainer(), "");//新建quota
	disableSaveBtn();
});

$('#save_quota').click(function(){
	var type = $(this).attr('data-type');
	if(type == 'edit'){
		var id = $(this).attr('data-id');
		saveEdited(id)//先获取id
	}else{
		addNewQuota();
	}
});

$('#max_up,#max_down,#max_combined').bind('blur keyup change',function(){
	checkMax($(this));
	disableSaveBtn();
});
$('#max_up_type,#max_down_type,#max_combined_type').bind('change',function(){
	validateMaxAll();
	disableSaveBtn();
});

$('#active_hours').bind('keyup blur',function(){
	checkHours();
	disableSaveBtn();
});

$('#active_weekly').bind('keyup blur',function(){
	checkWeekly();
	disableSaveBtn();
});

$('#quota_qos_up,#quota_qos_down').bind('keyup blur',function(){
	checkQos($(this));
	disableSaveBtn();
});

function checkQos(target){
	var errorCode = 0;
	var val = target.val();
	if(va.validateNum(val)){
		target.parent().addClass('has-error');
		target.next('.help-block').removeClass('hidden');
		errorCode = 1;
	}else{
		target.parent().removeClass('has-error');
		target.next('.help-block').addClass('hidden');
	}
	return errorCode;
}
function checkWeekly(){
	var errorCode = 0;
	var val = $('#active_weekly').val();
	if(validateWeeklyRange(val)){
		$('#active_weekly_container').addClass('has-error');
		$('#active_weekly_container').find('.warn_help').removeClass('hidden');
		errorCode = 1;
	}else{
		$('#active_weekly_container').removeClass('has-error');
		$('#active_weekly_container').find('.warn_help').addClass('hidden');
	}
	return errorCode;
}

function checkHours(){
	var errorCode = 0;
	var val = $('#active_hours').val();
	if(validateHours(val)){
		$('#active_hours_container').addClass('has-error');
		$('#active_hours_container').find('.warn_help').removeClass('hidden');
		errorCode = 1;
	}else{
		$('#active_hours_container').removeClass('has-error');
		$('#active_hours_container').find('.warn_help').addClass('hidden');
	}
	return errorCode;
}
function validateMaxAll(){
	var errorCode = 0;
	var up = $('#max_up_type').val();
	var down = $('#max_down_type').val();
	var combined = $('#max_combined_type').val();
	if(up=='unlimited' && down=="unlimited" && combined=="unlimited"){
		$('#max_up_form_group,#max_down_form_group,#max_combined_form_group').addClass('has-error');
		$('#max_all_help').removeClass('hidden');
		errorCode = 1;
	}else{
		$('#max_up_form_group,#max_down_form_group,#max_combined_form_group').removeClass('has-error');
		$('#max_all_help').addClass('hidden');
	}
	return errorCode;
}
function checkMax(target){
	var errorCode = 0;
	var val = target.val();
	var container = target.parent();
	if(va.validateNum(val)){
		if(parseInt(val) === 0){
			container.removeClass('has-error');
			container.find('.help-block').addClass('hidden');
		}else{
			container.addClass('has-error');
			container.find('.help-block').removeClass('hidden');
			errorCode = 1;
		}
	}else{
		container.removeClass('has-error');
		container.find('.help-block').addClass('hidden');
	}
	return errorCode;
}

function disableSaveBtn(){
	var sum = 0;
	if($('#max_up_type').val() == 'limited'){
		sum += checkMax($('#max_up'));
	}
	if($('#max_down_type').val() == 'limited'){
		sum += checkMax($('#max_down'));
	}
	if($('#max_combined_type').val() == 'limited'){
		sum += checkMax($('#max_combined'));
	}
	sum += validateMaxAll();
	if($('#applies_to_type').val() == 'only'){
		sum += checkIPs();
	}
	if(!$('#active_hours_container').hasClass('hidden')){
		sum += checkHours();
	}
	if(!$('#active_weekly_container').hasClass('hidden')){
		sum += checkWeekly();
	}
	if(!$('#quota_only_qos_container').hasClass('hidden')){
		sum += checkQos($('#quota_qos_up'));
		sum += checkQos($('#quota_qos_down'));
	}
	if(sum){
		$('#save_quota').prop('disabled',true);
	}else{
		$('#save_quota').prop('disabled',false);
	}
	return sum;
}

if(fullQosEnabled){
	$('#quota_exceeded').find('[value="combined"]').removeClass('hidden');
}else{
	$('#quota_exceeded').find('[value="combined"]').addClass('hidden');
}

// function alterQuotaExceededClass(){
// 	var up_limit = $('#quota_qos_up').val();
// 	var down_limit = $('#quota_qos_down').val();
// 	if(parseInt(up_limit) > 0 && !isNaN(up_limit)){
// 		// $('#quota_full_qos_up_class').prop('disabled',true).val('');
// 	}else{
// 		$('#quota_qos_up').val('')
// 		// Ha.showNotify({status: 1,msg:'请输入合法的数值。'})
// 		// $('#quota_full_qos_up_class').prop('disabled',false).find('option').first().prop('selected',true);
// 	}
// 	if(parseInt(down_limit) > 0 && !isNaN(down_limit)){
// 		// $('#quota_full_qos_down_class').prop('disabled',true).val('');
// 	}else{
// 		$('#quota_qos_down').val('');
// 		// Ha.showNotify({status: 1,msg:'请输入合法的数值。'})
// 		// $('#quota_full_qos_down_class').prop('disabled',false).find('option').first().prop('selected',true);
// 	}
// }

function alterQuotaExceeded(){
	var type = $('#quota_exceeded').val();
	if(type == 'throttle'){
		$('#quota_full_qos_container').addClass('hidden');
		$('#quota_full_qos_up_class,#quota_full_qos_down_class').prop('disabled',true).val('');
		$('#quota_only_qos_container').removeClass('hidden');
		$('#quota_qos_up,#quota_qos_down').val('').prop('disabled',false);
		$('#quota_qos_down_unit').prop('disabled',false).find('option').first().prop('selected',true);
		$('#quota_qos_up_unit').prop('disabled',false).find('option').first().prop('selected',true);
		return;
	}else if(type == 'combined'){
		$('#quota_full_qos_container').removeClass('hidden');
		$('#quota_full_qos_up_class').prop('disabled',false).find('option').first().prop('selected',true);
		$('#quota_full_qos_down_class').prop('disabled',false).find('option').first().prop('selected',true);
		$('#quota_only_qos_container').addClass('hidden');
		$('#quota_qos_up,#quota_qos_down').val('').prop('disabled',true);
		$('#quota_qos_down_unit').prop('disabled',true).val('');
		$('#quota_qos_up_unit').prop('disabled',true).val('');
		return;
	}else{
		$('#quota_full_qos_container').addClass('hidden');
		$('#quota_full_qos_up_class,#quota_full_qos_down_class').prop('disabled',true).val('');
		$('#quota_only_qos_container').addClass('hidden');
		$('#quota_qos_up,#quota_qos_down').val('').prop('disabled',true);
		$('#quota_qos_up_unit,#quota_qos_down_unit').prop('disabled',true).val('');
		return;
	}
}

function alterQuoteaReset(){
	var type = $('#quota_reset').val();
	if(type == 'hour'){
		$('#quota_day').prop('disabled',true).parent().parent().addClass('hidden');
		$('#quota_hour').prop('disabled',true).parent().parent().addClass('hidden');
	}else if(type == 'day'){
		$('#quota_day').prop('disabled',true).parent().parent().addClass('hidden');
		$('#quota_hour').prop('disabled',false).parent().parent().removeClass('hidden');
	}else if(type == 'week'){
		$('#quota_day').prop('disabled',false).parent().parent().removeClass('hidden');
		$('#quota_hour').prop('disabled',false).parent().parent().removeClass('hidden');
		var names = [UI.Sunday, UI.Monday, UI.Tuesday, UI.Wednesday, UI.Thursday, UI.Friday, UI.Saturday];
		var vals = [];
		var dayIndex;
		for(dayIndex=0; dayIndex < 7; dayIndex++)
		{
			vals.push( (dayIndex*60*60*24) + "")
		}
		setAllowableSelections("quota_day", vals, names, document);

	}else{
		$('#quota_day').prop('disabled',false).parent().parent().removeClass('hidden');
		$('#quota_hour').prop('disabled',false).parent().parent().removeClass('hidden');
		var vals = [];
		var names = [];
		var day=1;
		for(day=1; day <= 28; day++)
		{
			var dayStr = "" + day;
			var lastDigit = dayStr.substr( dayStr.length-1, 1);
			var suffix=quotasStr.Digs
			if( day % 100  != 11 && lastDigit == "1")
			{
				suffix=quotasStr.LD1s
			}
			if( day % 100 != 12 && lastDigit == "2")
			{
				suffix=quotasStr.LD2s
			}
			if( day %100 != 13 && lastDigit == "3")
			{
				suffix=quotasStr.LD3s
			}
			names.push(dayStr + suffix);
			vals.push( ((day-1)*60*60*24) + "" );
		}
		setAllowableSelections("quota_day", vals, names, document);
	}
}

function alterQuotaActive(){
	var type = $('#quota_active').val();
	if(type == 'always'){
		$('#quota_active').parent().addClass('col-sm-12').removeClass('col-sm-6');
		$('#quota_active_type').prop('disabled',true).parent().addClass('hidden');
		$('#active_hours').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_days_container').addClass('hidden');
	}else{
		$('#quota_active').parent().removeClass('col-sm-12').addClass('col-sm-6');
		$('#quota_active_type').prop('disabled',false).parent().removeClass('hidden');
		var active_type = $('#quota_active_type').val();
		if(active_type == 'hours'){
			$('#active_hours').prop('disabled',false).parent().parent().removeClass('hidden');
			$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
			$('#active_days_container').addClass('hidden');
		}else if(active_type == 'days'){
			$('#active_hours').prop('disabled',true).parent().parent().addClass('hidden');
			$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
			$('#active_days_container').removeClass('hidden');
		}else if(active_type == 'days_and_hours'){
			$('#active_hours').prop('disabled',false).parent().parent().removeClass('hidden');
			$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
			$('#active_days_container').removeClass('hidden');
		}else{
			$('#active_hours').prop('disabled',true).parent().parent().addClass('hidden');
			$('#active_weekly').prop('disabled',false).parent().parent().removeClass('hidden');
			$('#active_days_container').addClass('hidden');
		}
	}
	disableSaveBtn();
}

function alterQuotaActiveType(){
	var type = $('#quota_active_type').val();
	if(type == 'hours'){
		$('#active_hours').prop('disabled',false).parent().parent().removeClass('hidden');
		$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_days_container').addClass('hidden');
	}else if(type == 'days'){
		$('#active_hours').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_days_container').removeClass('hidden');
	}else if(type == 'days_and_hours'){
		$('#active_hours').prop('disabled',false).parent().parent().removeClass('hidden');
		$('#active_weekly').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_days_container').removeClass('hidden');
	}else{
		$('#active_hours').prop('disabled',true).parent().parent().addClass('hidden');
		$('#active_weekly').prop('disabled',false).parent().parent().removeClass('hidden');
		$('#active_days_container').addClass('hidden');
	}
	disableSaveBtn();
}


function alterLimitInput(typeId,inputId,unitId){
	var type = $('#' + typeId).val();
	if(type == 'limited'){
		$('#' + typeId).parent().removeClass('col-sm-12').addClass('col-sm-4');
		$('#' + inputId).prop('disabled',false).parent().removeClass('hidden');
		$('#' + inputId).focus();
		$('#' + unitId).prop('disabled',false).parent().removeClass('hidden');
	}else{
		$('#' + typeId).parent().addClass('col-sm-12').removeClass('col-sm-4');
		$('#' + inputId).prop('disabled',true).parent().addClass('hidden');
		$('#' + unitId).prop('disabled',true).parent().addClass('hidden');
	}
}

function alterApplyto(){
	var type = $('#applies_to_type').val();
	if(type == 'only'){
		$('#ip_span_container').parent().parent().removeClass('hidden');
		$('#add_ip_input').removeClass('hidden');
	}else{
		$('#ip_span_container').parent().parent().addClass('hidden');
		$('#add_ip_input').addClass('hidden');
	}
	disableSaveBtn();
}
//-----------------------------------------------------------------------------------------
UI.Reset="Reset";
UI.Clear="Clear History";
UI.Delete="Delete Data";
UI.DNow="Download Now";
UI.Visited="Visited Sites";
UI.Requests="Search Requests";
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
UI.WaitSettings="Please wait while new settings are applied…";
UI.Wait="Please wait…";
UI.ErrChanges="Changes could not be applied";
UI.Disabled="Disabled";
UI.Enabled="Enabled";
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
//-----------------------------------------------------------------------------------------------



//template
quotasStr.AppliesTo="Applies to";
quotasStr.QLocalNet="Entire Local Network";
quotasStr.QOnlyHosts="Only the following Host(s)";
quotasStr.HostsWithoutQuotas="All Individual Hosts Without Explicit Quotas";
quotasStr.ComboHostsWithoutQuotas="All Hosts Without Explicit Quotas (Combined)";
quotasStr.IPorRange="Specify an IP or IP range";
quotasStr.MaxUp="Max Upload";
quotasStr.MaxDown="Max Download";
quotasStr.MaxUpDown="Max Total Up+Down";
quotasStr.Unlimited="Unlimited";
quotasStr.Limited="Limit to";
quotasStr.QResets="Quota Resets";
quotasStr.EvHour="Every Hour";
quotasStr.EvDay="Every Day";
quotasStr.EvWeek="Every Week";
quotasStr.EvMonth="Every Month";
quotasStr.ResetDay="Reset Day";
quotasStr.ResetHour="Reset Hour";
quotasStr.QuotaActive="Quota Is Active";
quotasStr.TheseHours="These Hours";
quotasStr.TheseDays="These Days";
quotasStr.TheseDaysHours="These Days &amp; Hours";
quotasStr.TheseTimes="These Weekly Times";
quotasStr.Sample="e.g. Mon 00:30 - Thu 13:15, Fri 14:00 - Fri 15:00";
quotasStr.SSample="e.g.";
quotasStr.Exceed="When Exceeded";
quotasStr.ShutdownNet="Shut Down All Internet Access";
quotasStr.Throttle="Throttle Bandwidth";
quotasStr.UpLimit="Upload Limit";
quotasStr.DownLimit="Download Limit";
quotasStr.UpClass="Upload Class";
quotasStr.DownClass="Download Class";

//quota_edit.sh
quotasStr.ESection="Edit Quota";

//quota_usage.sh/js
quotasStr.USect="Bandwidth Quota Usage";
quotasStr.All="All";
quotasStr.Alws="Always";
quotasStr.ColNms=["Host(s)", "Active", "% Total Used", "% Down Used", "% Up Used" ];

//-------------------------------------------------------------------------------------------------------------

var TSort_Data = new Array ('quota_table', 's', 's', 'm', '');

var pkg = "quotas_uci";
var changedIds = [];
var rowCheckIndex = 3;

var downQosClasses = [];
var downQosMarks = [];
var upQosClasses = [];
var upQosMarks = [];

var table_data = [];
var form_data = [];

//---------------------------useage----------------------------------------
var updateInProgress = false;

var allQuotaIds;
var allQuotaIps;
var allQuotaUsed;
var allQuotaLimits;
var allQuotaPercents;


var idToSection = [];
var idToIpStr = [];
var idToTimeParams = [];


function getTableData(uci){
	var quotaSections = uci.getAllSectionsOfType(pkg, "quota");
	var quotaTableData = [];

	for(i = 0; i < quotaSections.length; i++)
	{
		var ip = uci.get(pkg, quotaSections[i], "ip").toUpperCase();//获取IP
		var id = uci.get(pkg, quotaSections[i], "id");//获取ID
		if(id == "")//如果ID为空
		{
			id = getIdFromIp(ip);//根据ip生成ID
			uci.set(pkg, quotaSections[i], "id", id);//将Id保存在uci
		}
		var timeParameters = getTimeParametersFromUci(uci, quotaSections[i], 1);
		var limitStr = getLimitStrFromUci(uci, quotaSections[i]);
		var enabled = uci.get(pkg, quotaSections[i], "enabled");
		enabled = enabled != "0" ? true : false;
		var enabledCheck = createEnabledCheckbox(enabled);
		quotaTableData.push([ipToTableSpan(ip), timeParamsToTableSpan(timeParameters), limitStr, enabledCheck, createBtn(UI.Edit,'primary'), createBtn(UI.Remove,'danger'),id]);
	}
	return quotaTableData;
}


function getFormData(uci){

}

function saveChanges()//提交修改
{
	Ha.mask.show();
	// setControlsEnabled(false, true);

	//remove old quotas
	var preCommands = [];
	var allOriginalQuotas = uciOriginal.getAllSectionsOfType(pkg, "quota");
	while(allOriginalQuotas.length > 0)
	{
		var section = allOriginalQuotas.shift();
		// uciOriginal.removeSection(pkg, section);
		preCommands.push("uci del " + pkg + "." + section);
	}

	preCommands.push("uci commit");

	var allNewQuotas = uci.getAllSectionsOfType(pkg, "quota");
	var quotaUseVisibleCommand = "\nuci del gargoyle.status.quotause ; uci commit ;\n"
	var idToNewSection = [];
	while(allNewQuotas.length > 0)
	{
		//if ip has changed, reset saved data
		var section = allNewQuotas.shift()
		var newId = uci.get(pkg,section,"id");
		idToNewSection[newId] = section;
		if( changedIds[ newId ] == 1 )
		{
			uci.set(pkg, section, "ignore_backup_at_next_restore", "1");
		}
	}

	var id = [];
	var checked = [];
	$('#quota_container').find('tr').each(function(){
		id.push($(this).prop('id'));
		checked.push($(this).find('input').prop('checked'));
	});

	// set enabled / disabled
	var qtIndex=0;
	for(qtIndex=0; qtIndex < id.length; qtIndex++)
	{
		var enabledSection = idToNewSection[id[qtIndex]];
		if(enabledSection != null)
		{
			uci.set(pkg, enabledSection, "enabled", (checked[qtIndex] ? "1" : "0") )
			if(checked[qtIndex])
			{
				quotaUseVisibleCommand = "\nuci set gargoyle.status.quotause=\"225\" ; uci commit ;\n"
			}
		}
	}

	var postCommands = [];
	postCommands.push("sh /usr/lib/gargoyle/restart_firewall.sh");
	postCommands.push("if [ -d \"/usr/data/quotas/\" ] ; then rm -rf /usr/data/quotas/* ; fi ;");
	postCommands.push("backup_quotas");
	var commands = preCommands.join("\n") + "\n" + uci.getScriptCommands(uciOriginal) + "\n" + quotaUseVisibleCommand + "\n" + postCommands.join("\n");


	var quotaData = [];
	for(var i=0; i<id.length; i++){

		var quotaSection = "";
		var sections = uci.getAllSectionsOfType(pkg, "quota");
		for(sectionIndex=0; sectionIndex < sections.length && quotaSection == ""; sectionIndex++)
		{
			if(uci.get(pkg, sections[sectionIndex], "id") == id[i] )
			{
				quotaSection = sections[sectionIndex];
			}
		}
		
		var data = {};
		data.id = id[i];
		data.quota_section = quotaSection;
		data.enabled = checked[i] ? 1 : 0;
		data.ip = uci.get(pkg, quotaSection, "ip");
		data.reset_interval = uci.get(pkg, quotaSection, "reset_interval");
		data.egress_limit = uci.get(pkg, quotaSection, "egress_limit");
		data.ingress_limit = uci.get(pkg, quotaSection, "ingress_limit");
		data.combined_limit = uci.get(pkg, quotaSection, "combined_limit");
		data.reset_time = uci.get(pkg, quotaSection, "reset_time");
		data.exceeded_up_speed = uci.get(pkg, quotaSection, "exceeded_up_speed");
		data.exceeded_down_speed = uci.get(pkg, quotaSection, "exceeded_down_speed");
		if(parseInt(data.exceeded_up_speed) < 1 || parseInt(data.exceeded_down_speed) < 1 || isNaN(data.exceeded_up_speed) || isNaN(data.exceeded_down_speed) ){
			data.exceeded_up_speed = '';
			data.exceeded_down_speed = '';
		}
		data.exceeded_up_class_mark = uci.get(pkg, quotaSection, "exceeded_up_class_mark");
		data.exceeded_down_class_mark = uci.get(pkg, quotaSection, "exceeded_down_class_mark");
		data.offpeak_hours = uci.get(pkg, quotaSection, "offpeak_hours");
		data.offpeak_weekdays = uci.get(pkg, quotaSection, "offpeak_weekdays");
		data.offpeak_weekly_ranges = uci.get(pkg, quotaSection, "offpeak_weekly_ranges");
		data.onpeak_hours = uci.get(pkg, quotaSection, "onpeak_hours");
		data.onpeak_weekdays = uci.get(pkg, quotaSection, "onpeak_weekdays");
		data.onpeak_weekly_ranges = uci.get(pkg, quotaSection, "onpeak_weekly_ranges");

		var curId = data.id.split('_')[0];
		var ipStuff = data.ip.split(',')[0];
		if(curId != ipStuff){
			data.id = getIdFromIp(data.ip);
		}

		quotaData.push(data);

	}

	var data = {
		app: 'quotas',
		action: 'quotas_save_change',
		quots: quotaData
	};

	$.post('/',data,function(data){
		Ha.mask.hide();
		Ha.showNotify(data);
		setTimeout(function(){
			window.location.href = window.location.href;
		},5000);
	},'json');
}

function resetData()//初始加载或复位按钮调用这个函数
{
	//quota_usage-resetData()
	allQuotaIds      = quotaIdList;
	allQuotaIps      = quotaIpLists;
	allQuotaUsed     = quotaUsed;
	allQuotaLimits   = quotaLimits;
	allQuotaPercents = quotaPercents;

	idToSection = [];
	idToIpStr = [];
	idToTimeParams = [];

	var quotaSections = uciOriginal.getAllSectionsOfType(pkg, "quota");
	var qIndex;
	for(qIndex=0; qIndex < quotaSections.length; qIndex++)
	{
		var ip = getIpFromUci(uciOriginal, quotaSections[qIndex]);
		var id = uciOriginal.get(pkg, quotaSections[qIndex], "id");
		id = id == "" ? getIdFromIp_usage(ip, uciOriginal) : id;

		idToSection[ id ] = quotaSections[qIndex];
		idToIpStr[ id ] = ip;
		idToTimeParams[ id ] = getTimeParametersFromUci(uciOriginal, quotaSections[qIndex]);
	}

	refreshTableData($("#data_display").val());
	setInterval(updateTableData, 1500);

//--------------------------------------------------------------------------------------------------

	//initialize qos mark lists, if full qos is active
	var qmIndex=0;
	upQosClasses = [];//上传下载的Qos的名字和value
	upQosMarks = [];
	downQosClasses = [];
	downQosMarks = [];
	for(qmIndex=0; qmIndex < qosMarkList.length; qmIndex++)
	{
		var className = qosMarkList[qmIndex][1];
		var classDisplay = uciOriginal.get("qos_shellgui", className, "name");
		className = classDisplay == "" ? className : classDisplay;
		if(qosMarkList[qmIndex][0] == "upload")
		{
			upQosClasses.push(className);
			upQosMarks.push(qosMarkList[qmIndex][2]);
		}
		else
		{
			downQosClasses.push(className);
			downQosMarks.push(qosMarkList[qmIndex][2]);
		}

	}

	//table columns: ip, percent upload used, percent download used, percent combined used, enabled, edit, remove
	var quotaSections = uciOriginal.getAllSectionsOfType(pkg, "quota");
	//有几个规则["quota_1", "quota_2"]
	var quotaTableData = [];//表格数据
	var checkElements = []; //because IE is a bitch and won't register that checkboxes are checked/unchecked unless they are part of document
	var areChecked = [];//针对IE的什么鬼毛病
	changedIds = [];
	for(sectionIndex = 0; sectionIndex < quotaSections.length; sectionIndex++)
	{
		var ip = uciOriginal.get(pkg, quotaSections[sectionIndex], "ip").toUpperCase();//获取IP
		var id = uciOriginal.get(pkg, quotaSections[sectionIndex], "id");//获取ID
		if(id == "")//如果ID为空
		{
			id = getIdFromIp(ip);//根据ip生成ID
			uci.set(pkg, quotaSections[sectionIndex], "id", id);//将Id保存在uci
		}



		var timeParameters = getTimeParametersFromUci(uci, quotaSections[sectionIndex], 1);
		//生效的时间["", "", "", "always"]
		var limitStr = getLimitStrFromUci(uci, quotaSections[sectionIndex]);
		//流量限制 NA/100MB/130MB
		var enabled = uciOriginal.get(pkg, quotaSections[sectionIndex], "enabled");
		//是否启用 1 || 0
		enabled = enabled != "0" ? true : false;//转换为布尔值
		

		var enabledCheck = createEnabledCheckbox(enabled);
		//根据是否开启创建复选框控件 <input type="checkbox" checked>
		checkElements.push(enabledCheck);//针对IE的什么鬼
		areChecked.push(enabled);

		quotaTableData.push([ipToTableSpan(ip), timeParamsToTableSpan(timeParameters), limitStr, enabledCheck, createBtn(UI.Edit,'primary'), createBtn(UI.Remove,'danger'),id]);
	}
	resetTable(quotaTableData);

	while(checkElements.length > 0)//???????什么鬼
	{
		var c = checkElements.shift();
		var b = areChecked.shift();
		c.checked = b;
	}
	uci = uciOriginal.clone();
	setDocumentFromUci(document, new UCIContainer(), "");//新建quota

}

function ipToTableSpan(ip)//为ip列表添加换行
{
	var ipStr = ip;
	if(ipStr == "ALL_OTHERS_INDIVIDUAL")
	{
		ipStr=quotasStr.OthersOne;
	}
	else if(ipStr == "ALL_OTHERS_COMBINED")
	{
		ipStr=quotasStr.OthersAll;
	}
	else if(ipStr == "ALL" || ipStr == "")
	{
		ipStr=quotasStr.All;
	}
	return textListToSpanElement(ipStr.split(/[\t ]*,[\t ]*/), true, document);
}

function createTrs(data){
	var tr = [];
	for(var i=0; i<data.length; i++){
		var td = '';
		for(var j=0; j<data[i].length-1; j++){
			td += '<td>' + data[i][j] + '</td>';
		}
		tr.push(td);
	}
	var trDom = '';
	for(var n=0; n<tr.length; n++){
		trDom += '<tr class="text-left" id="' + data[n][6] + '">' + tr[n] + '</tr>';
	}
	return trDom;
}

function createUsageTrs(data){
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

function createTr(id,ip,time,limit){
	var dom = '<tr class="text-left" id="' + id + '">'
			+ 	'<td>' + ipToTableSpan(ip) + '</td>'
			+	'<td>' + timeParamsToTableSpan(time) + '</td>'
			+	'<td>' + limit + '</td>'
			+	'<td>' + createEnabledCheckbox(true) + '</td>'
			+	'<td>' + createBtn(UI.Edit,'primary') + '</td>'
			+	'<td>' + createBtn(UI.Remove,'danger') + '</td>'
			+ '</tr>';

	return dom;
}

function timeParamsToTableSpan(timeParameters)//激活时间的参数转换为表格元素
{
	var hours = timeParameters[0];
	var days = timeParameters[1];
	var weekly = timeParameters[2];
	var active = timeParameters[3];


	var textList = [];
	if(active == "always")
	{
		textList.unshift(UI.Always);
	}
	else
	{
		if(weekly != "")
		{
			textList = weekly.match(",") ? weekly.split(/[\t ]*,[\t ]*/) : [ weekly ];
		}
		else
		{
			if(hours != ""){ textList = hours.match(",") ? hours.split(/[\t ]*,[\t ]*/) : [ hours ]; }
			if(days  != ""){ textList.unshift(days); }
		}
		textList.unshift( active == "only" ? quotasStr.Only+":" : quotasStr.AllExcept+":" );
	}
	return textListToSpanElement(textList, false, document);
}

function getLimitStrFromUci(srcUci, section)//获取流量限制的字符串20GB/NA/NA
{
	var totalLimit = uci.get(pkg, section, "combined_limit");
	var downLimit  = uci.get(pkg, section, "ingress_limit");
	var upLimit    = uci.get(pkg, section, "egress_limit");

	var parseLimit = function(limStr){ return limStr == "" ? quotasStr.NA : parseBytes(parsePaddedInt(limStr), null,true).replace(/\.[\d]+/,"").replace(/[\t ]+/, ""); }
	return parseLimit(totalLimit) + "/" + parseLimit(downLimit) + "/" + parseLimit(upLimit);
}

function getIdFromIp(ip)//根据ip生成ID
{
	id = ip == "" ? "ALL" : ip.replace(/[\t, ]+.*$/, "");
	id = id.replace(/\//, "_");

	var idPrefix = id;
	var found = true;
	var suffixCount = 0;

	var quotaSections = uci.getAllSectionsOfType(pkg, "quota");

	while(found)
	{
		found = false;
		var sectionIndex;
		for(sectionIndex=0; sectionIndex < quotaSections.length && (!found); sectionIndex++)
		{
			found = found || uci.get(pkg, quotaSections[sectionIndex], "id") == id;
		}
		if(found)
		{
			var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			var suffix = suffixCount < 26 ? "_" + letters.substr(suffixCount,1) : "_Z" + (suffixCount-25);
			id = idPrefix + suffix;
		}
		suffixCount++;
	}
	return id;

}


function getIpFromDocument(controlDocument)//从文档获取IP
{
	controlDocument = controlDocument == null ? document : controlDocument;
	var ip = "ALL";
	if(getSelectedValue("applies_to_type", controlDocument) == "all")
	{
		ip = "ALL";
	}
	else if(getSelectedValue("applies_to_type", controlDocument) == "others_combined")
	{
		ip = "ALL_OTHERS_COMBINED";
	}
	else if(getSelectedValue("applies_to_type", controlDocument) == "others_individual")
	{
		ip = "ALL_OTHERS_INDIVIDUAL";
	}
	else if(getSelectedValue("applies_to_type", controlDocument) == "only")
	{
		var ip_list = [];//新加的ip列表
		$('#ip_span_container').find('.ip_span').each(function(){
			ip_list.push($(this).html());
		});
		if(ip_list.length>0){
			ip = ip_list.join(",");//返回字符串
		}
	}
	return ip;
}


function setDocumentIp(ip, controlDocument)
{
	ip = ip== ""  ? "ALL" : ip;
	controlDocument = controlDocument == null ? document : controlDocument;
	// controlDocument.getElementById("add_ip").value = "";
	$('#add_ip').val('');

	//TODO
	$('#ip_span_container').html('');


	if(ip == "ALL")
	{
		setSelectedValue("applies_to_type", "all", controlDocument);
	}
	else if(ip == "ALL_OTHERS_COMBINED")
	{
		setSelectedValue("applies_to_type", "others_combined", controlDocument);
	}
	else if(ip == "ALL_OTHERS_INDIVIDUAL")
	{
		setSelectedValue("applies_to_type", "others_individual", controlDocument);
	}
	else
	{
		$("#applies_to_type").val("only");
		$('#ip_span_container').parent().parent().removeClass('hidden');
		$('#add_ip_input').removeClass('hidden');
		$("#add_ip").val(ip);
		//添加新地址到ip列表
		var valid = addAddressesToTable(controlDocument,"add_ip","ip_span_container","quota_ip_table",false, 3, false,false);
		if(!valid)//ip无效
		{
			$("#add_ip").val('');
		}
	}
}


function addNewQuota()//点击添加按钮之后执行
{
	var errors = validateQuota(document, "", "none");//验证新的规则是否有效
	
	if(errors.length > 0)//如果存在错误
	{
		Ha.showNotify({status: 1, msg: errors[0] + '<br>' + quotasStr.AddError})//弹出错误
	}
	else//否则
	{
		var quotaNum = 1;
		while( uci.get(pkg, "quota_" + quotaNum, "") != "") { quotaNum++; }//最大值加1，就是新建的quota的代码

		setUciFromDocument(document, "");//设置当前表单里的字段到uci对象


		var id = uci.get(pkg, "quota_" + quotaNum, "id");

		var ip = getIpFromDocument(document);//获取ip
		var timeParameters = getTimeParametersFromUci(uci, "quota_" + quotaNum);//获取时间
		var limitStr = getLimitStrFromUci(pkg, "quota_" + quotaNum);//获取流量限制值

		//把数据再添加到表格中
		var tableData = getTableData(uci);
		resetTable(tableData);
		$('#quotaModal').modal('hide');
		setDocumentFromUci(document, new UCIContainer(), "");//表单再初始化
	}
}

function setVisibility(controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	if(fullQosEnabled)
	{
		//设置class
		$("#quota_only_qos_container").addClass('hidden');
		$("#quota_only_qos_container").find('select').prop('disabled',true);
		$("#quota_only_qos_container").find('input').prop('disabled',true);
	}
	else
	{
		//设置limit
		$("#quota_full_qos_container").addClass('hidden');
		$("#quota_full_qos_container").find('select').prop('disabled',true);
		$("#quota_full_qos_container").find('input').prop('disabled',true);
	}
}

function getDaySeconds(offset)
{
	return ( Math.floor(offset/(60*60*24))*(60*60*24)) ;
}
function getHourSeconds(offset)
{
	return ( Math.floor((offset%(60*60*24))/(60*60)) * (60*60) );
}


function timeVariablesToWeeklyRanges(hours, days, weekly, invert)
{
	var hours = hours == null ? "" : hours;
	var days = days == null ? "" : days;
	var weekly = weekly == null ? "" : weekly;

	var dayToIndex = [];
	dayToIndex[UI.Sun.toUpperCase()] = 0;
	dayToIndex[UI.Mon.toUpperCase()] = 1;
	dayToIndex[UI.Tue.toUpperCase()] = 2;
	dayToIndex[UI.Wed.toUpperCase()] = 3;
	dayToIndex[UI.Thu.toUpperCase()] = 4;
	dayToIndex[UI.Fri.toUpperCase()] = 5;
	dayToIndex[UI.Sat.toUpperCase()] = 6;


	var splitRangesAtEnd = function(rangeList, max){
		var startEndPairs = [];
		var rangeIndex;
		for(rangeIndex=0;rangeIndex < rangeList.length; rangeIndex=rangeIndex+2)
		{
			if(rangeList[rangeIndex+1] < rangeList[rangeIndex])
			{
				var oldEnd = rangeList[rangeIndex+1];
				rangeList[rangeIndex+1] = max;
				rangeList.push(0);
				rangeList.push(oldEnd);
			}
			var s = rangeList[rangeIndex];
			var e = rangeList[rangeIndex+1];
			startEndPairs.push( [s,e] );
		}

		//sort based on starts
		var sortPairs = function(a,b){ return a[0] - b[0]; }
		var sortedPairs = startEndPairs.sort(sortPairs);
		var newRanges = [];
		for(rangeIndex=0;rangeIndex < sortedPairs.length; rangeIndex++)
		{
			newRanges.push( sortedPairs[rangeIndex][0] );
			newRanges.push( sortedPairs[rangeIndex][1] );
		}
		return newRanges;
	}


	var ranges = [];
	if(hours == "" && days == "" && weekly == "")
	{
		ranges = [0, 7*24*60*60];
		invert = false;
	}
	else if(weekly != "")
	{
		var parsePiece = function(piece)
		{
			var splitPiece = piece.split(/[:\t ]+/);
			var dayName = (splitPiece[0]).substr(0,3).toUpperCase();
			splitPiece[0] = dayToIndex[dayName] != null ? dayToIndex[dayName]*24*60*60 : 0;
			splitPiece[1] = parsePaddedInt(splitPiece[1]) + "" != "NaN" ? parsePaddedInt(splitPiece[1])*60*60 : 0;
			splitPiece[2] = parsePaddedInt(splitPiece[2]) + "" != "NaN" ? parsePaddedInt(splitPiece[2])*60 : 0;
			splitPiece[3] = splitPiece[3] != null ? ( parsePaddedInt(splitPiece[3]) + "" != "NaN" ? parsePaddedInt(splitPiece[3]) : 0) : 0;
			return splitPiece[0] + splitPiece[1] + splitPiece[2] + splitPiece[3];
		}
		var pairs = weekly.split(/[\t ]*,[\t ]*/);
		var pairIndex;
		for(pairIndex=0; pairIndex < pairs.length; pairIndex++)
		{

			var pieces = (pairs[pairIndex]).split(/[\t ]*\-[\t ]*/);
			ranges.push(parsePiece(pieces[0]));
			ranges.push(parsePiece(pieces[1]));
		}
		ranges = splitRangesAtEnd(ranges, 7*24*60*60);
	}
	else
	{
		var validDays= [1,1,1,1,1,1,1];
		var hourRanges = [];
		if(days != "")
		{
			validDays= [0,0,0,0,0,0,0];
			var splitDays = days.split(/[\t ]*,[\t ]*/);
			var dayIndex;
			for(dayIndex=0; dayIndex < splitDays.length; dayIndex++)
			{
				var dayName = (splitDays[dayIndex]).substr(0,3).toUpperCase();
				if(dayToIndex[dayName] != null)
				{
					validDays[ dayToIndex[dayName] ] = 1;
				}
			}
		}
		if(hours != "")
		{
			var parsePiece = function(piece)
			{
				var splitPiece = piece.split(/[:\t ]+/);
				splitPiece[0] = parsePaddedInt(splitPiece[0]) + "" != "NaN" ? parsePaddedInt(splitPiece[0])*60*60 : 0;
				splitPiece[1] = parsePaddedInt(splitPiece[1]) + "" != "NaN" ? parsePaddedInt(splitPiece[1])*60 : 0;
				splitPiece[2] = splitPiece[2] != null ? ( parsePaddedInt(splitPiece[2]) + "" != "NaN" ? parsePaddedInt(splitPiece[2]) : 0) : 0;


				return splitPiece[0] + splitPiece[1] + splitPiece[2];
			}
			var pairs = hours.split(/[\t ]*,[\t ]*/);
			var pairIndex;
			for(pairIndex=0; pairIndex < pairs.length; pairIndex++)
			{
				var pair = (pairs[pairIndex]).replace(/^[\t ]*/, "").replace(/[\t ]*$/, "");
				var pieces = pair.split(/[\t ]*\-[\t ]*/);
				hourRanges.push(parsePiece(pieces[0]));
				hourRanges.push(parsePiece(pieces[1]));
			}
			hourRanges = splitRangesAtEnd(hourRanges, 24*60*60);
		}
		hourRanges = hourRanges.length == 0 ? [0,24*60*60] : hourRanges;

		var dayIndex;
		for(dayIndex=0; dayIndex < validDays.length; dayIndex++)
		{
			if(validDays[dayIndex] != 0)
			{
				var hourIndex;
				for(hourIndex=0; hourIndex < hourRanges.length; hourIndex++)
				{
					ranges.push( (dayIndex*24*60*60) + hourRanges[hourIndex] )
				}
			}
		}
	}

	if(invert)
	{
		if(ranges[0] == 0)
		{
			ranges.shift();
		}
		else
		{
			ranges.unshift(0);
		}

		if(ranges[ ranges.length-1 ] == 7*24*60*60)
		{
			ranges.pop();
		}
		else
		{
			ranges.push(7*24*60*60);
		}
	}
	return ranges;
}


function rangesOverlap(t1, t2)
{
	//alert("testing overlap for:\n" + t1.join(",") + "\n" + t2.join(",") );
	var ranges1 = timeVariablesToWeeklyRanges(t1[0], t1[1], t1[2], t1[3]);
	var ranges2 = timeVariablesToWeeklyRanges(t2[0], t2[1], t2[2], t2[3]);

	var r1Index = 0;
	var r2Index = 0;
	var overlapFound = false;
	for(r1Index=0; r1Index < ranges1.length && (!overlapFound); r1Index=r1Index+2)
	{
		var r1Start = ranges1[r1Index];
		var r1End   = ranges1[r1Index+1];
		var r2Start = ranges2[r2Index];
		var r2End   = ranges2[r2Index+1];
		overlapFound = overlapFound || (r1End > r2Start && r1Start < r2End);

		while( (!overlapFound) && r2Start < r1Start && r2Index < ranges2.length)
		{
			r2Index = r2Index+2;
			if(r2Index < ranges2.length)
			{
				var r2Start = ranges2[r2Index];
				var r2End   = ranges2[r2Index+1];
				overlapFound = overlapFound || (r1End > r2Start && r1Start < r2End);
			}
		}
		/*
		if(overlapFound)
		{
			alert("overlapFound: r1=[" + r1Start + "," + r1End + "], r2=[" + r2Start + "," + r2End + "]");
		}
		*/
	}
	return overlapFound;
}



function validateQuota(controlDocument, originalQuotaId, originalQuotaIp)
{
	originalQuotaId = originalQuotaId == null ? "" : originalQuotaId;
	originalQuotaIp = originalQuotaIp == null ? "none" : originalQuotaIp; //null is not the same as "" -- the latter gets interpretted as "ALL"

	controlDocument = controlDocument == null ? document : controlDocument;


	var inputIds = ["max_up", "max_down", "max_combined", "active_hours", "active_weekly"];
	var labelIds = ["max_up_label", "max_down_label", "max_combined_label", "quota_active_label", "quota_active_label"];
	var functions = [validateDecimal, validateDecimal, validateDecimal, validateHours, validateWeeklyRange];
	var validReturnCodes = [0,0,0,0,0];
	var visibilityIds = ["max_up_container","max_down_container","max_combined_container", "active_hours_container", "active_weekly_container"];
	var errors = proofreadFields(inputIds, labelIds, functions, validReturnCodes, visibilityIds, controlDocument );
	//add any ips in add_ip box, if it is visible and isn't empty
	if(errors.length == 0 && $("#applies_to_type").val() == "only" && $("#add_ip").val() != "")
	{
		var valid = addAddressesToTable(controlDocument,"add_ip","ip_span_container","quota_ip_table",false, 3, false,false);
		if(!valid)
		{//这个 错误是不是在添加按钮那里已经处理过了
			errors.push(UI.There_is_invalid_IP_or_IP_range_Exists+'.');
		}
	}
	// check that ip is not empty (e.g. that we are matching based on IP(s) and no ips are defined)
	// thw getIpFromDocument function will always return ALL in the case where uci had no ip originallly,
	// so we don't have to worry about empty ip meaning ALL vs null here
	var ip = "";
	if(errors.length == 0)
	{
		ip = getIpFromDocument(controlDocument);
		if(ip == "")
		{
			errors.push(quotasStr.IPError);
		}
	}

	//check that up,down,total aren't all unlimited
	if(errors.length == 0)
	{
		if( getSelectedValue("max_up_type", controlDocument) == "unlimited" &&
			getSelectedValue("max_down_type", controlDocument) == "unlimited" &&
			getSelectedValue("max_combined_type", controlDocument) == "unlimited"
			)
		{
			errors.push(quotasStr.AllUnlimitedError);
		}
	}

	//check that any quota with overlapping ips with this one doesn't have overlapping time ranges
	if(errors.length == 0)
	{
		if(ip != originalQuotaIp)
		{
			var quotaSections = uci.getAllSectionsOfType(pkg, "quota");
			var sectionIndex;
			var overlapFound = false;
			for(sectionIndex=0; sectionIndex < quotaSections.length && (!overlapFound); sectionIndex++)
			{
				var sectionId = uci.get(pkg, quotaSections[sectionIndex], "id");
				if(sectionId != originalQuotaId)
				{
					var sectionIp = uci.get(pkg, quotaSections[sectionIndex], "ip");
					var ipOverlap = testAddrOverlap(sectionIp, ip);
					if(ipOverlap)
					{
						//test time range overlap
						var sectionTime = getTimeParametersFromDocument(controlDocument);
						var testTime = getTimeParametersFromUci(uci, quotaSections[sectionIndex]);
						sectionTime[3] = sectionTime[3] == "except" ? true : false;
						testTime[3] = testTime[3] == "except" ? true : false;
						overlapFound = rangesOverlap(sectionTime, testTime);
					}
				}
			}

			if(overlapFound)
			{
				if(!ip.match(/ALL/))
				{
					errors.push(quotasStr.DuplicateRange);
				}
				else if(ip.match(/OTHER/))
				{
					errors.push(quotasStr.OneTimeQuotaError);
				}
				else
				{
					errors.push(quotasStr.OneNetworkQuotaError);
				}
			}
		}
	}
	if(!$('#quota_only_qos_container').hasClass('hidden')){
		if(parseInt($('#quota_qos_down').val()) < 1 || isNaN(parseInt($('#quota_qos_down').val()))  || parseInt($('#quota_qos_up').val()) < 1 ||  isNaN(parseInt($('#quota_qos_up').val()))){
			errors.push('上传和下载的限制输入不合法！');
		}
	}
	return errors;
}


//TODO这个函数改一改 点击添加按钮执行这个函数
function addAddressesToTable(controlDocument, textId, tableContainerId, tableId, macsValid, ipValidType, alertOnError, isAddNew)
{

	var newAddrs = $('#' + textId).val();
	//验证有效性
	var valid = addAddressStringToTable(controlDocument, newAddrs, tableContainerId, tableId, macsValid, ipValidType, alertOnError, isAddNew)
	if(valid)
	{
		$('#' + textId).val('');
	}
	return valid;
}

function addAddressStringToTable(controlDocument, newAddrs, tableContainerId, tableId, macsValid, ipValidType, alertOnError, isAddNew)
{
	//ipValidType: 0=none, 1=ip only, 2=ip or ip subnet, 3>=ip, ip subnet or ip range
	macsValid = macsValid == null ? true : macsValid;
	ipValidType = ipValidType == null ? 3 : ipValidType;
	var ipValidFunction;
	if(ipValidType == 0)
	{
		ipValidFunction = function(){ return 1; };
	}
	else if(ipValidType == 1)
	{
		ipValidFunction = validateIP;
	}
	else if(ipValidType == 2)
	{
		ipValidFunction = validateIpRange;
	}
	else//type为3的时候基本上所有类型都可以验证了
	{
		ipValidFunction = validateMultipleIps;
	}

	var allCurrentMacs = [];
	var allCurrentIps = [];
	if($('#' + tableContainerId).html() != null)
	{
		var data = [];
		$('#' + tableContainerId).find('.ip_span').each(function(){
			data.push($(this).html());
		});
		var rowIndex;
		for(rowIndex=0; rowIndex < data.length; rowIndex++)
		{
			var addr = data[rowIndex];
			if(validateMac(addr) == 0)//如果是有效Mac
			{
				allCurrentMacs.push(addr);
			}
			else//如果是IP
			{
				allCurrentIps.push(addr);
			}
		}
	}
	controlDocument = controlDocument == null ? document : controlDocument;
	// alertOnError = alertOnError == null ? true : alertOnError;
	var valid = 0;
	var splitAddrs = newAddrs.split(/[\t ]*,[\t ]*/);
	valid = splitAddrs.length > 0 ? 0 : 1; //1=error, 0=valid
	var splitIndex;
	for(splitIndex=0; splitIndex < splitAddrs.length && valid == 0; splitIndex++)
	{
		var addr = splitAddrs[splitIndex];
		var macValid = (macsValid && validateMac(addr) == 0);//验证Mac
		var ipValid = (ipValidFunction(addr) == 0);//验证ip
		if(macValid || ipValid)
		{
			var currAddrs = macValid ? allCurrentMacs : allCurrentIps;
			valid = currAddrs.length == 0 || (!testAddrOverlap(addr, currAddrs.join(","))) ? 0 : 1;//查明重叠的ip
			if(valid == 0)
			{
				currAddrs.push(addr); //if we're adding multiple addrs and there's overlap, this will allow us to detect it
			}
		}
		else
		{
			valid = 1;
		}
	}

	if(valid == 0)
	{
		//设置表格
		newAddrs = newAddrs.replace(/^[\t ]*/, "");
		newAddrs = newAddrs.replace(/[\t ]*$/, "");
		var addrs = newAddrs.split(/[\t ]*,[\t ]*/);//ip数组
		makeIpTable(addrs,tableContainerId);
	}
	else if(alertOnError)
	{
		alert(UI.InvAdd+"\n");
	}
		
		

	// if(valid == 0)
	// {
	// 	//设置表格
	// 	newAddrs = newAddrs.replace(/^[\t ]*/, "");
	// 	newAddrs = newAddrs.replace(/[\t ]*$/, "");
	// 	var addrs = newAddrs.split(/[\t ]*,[\t ]*/);//ip数组
	// 	makeIpTable(addrs,tableContainerId);
	// }
	// else if(alertOnError)
	// {
	// 	alert(UI.InvAdd+"\n");
	// }

	return valid == 0 ? true : false;

}

function parseKbytesPerSecond(kbytes, units)
{
	var parsed;
	units = units != "bytes/s" && units != "KBytes/s" && units != "MBytes/s" ? "mixed" : units;

	if( (units == "mixed" && kbytes > 1024) || units == "MBytes/s")
	{
		parsed = (kbytes/(1024)).toFixed(3) + " "+UI.MBs;
	}
	else
	{
		parsed = kbytes + " "+UI.KBs;
	}
	return parsed;
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

function setDocumentFromUci(controlDocument, srcUci, id)//映射新建表单、编辑表单
{
	controlDocument = controlDocument == null ? document : controlDocument;


	var quotaSection = "";
	var sections = srcUci.getAllSectionsOfType(pkg, "quota");
	for(sectionIndex=0; sectionIndex < sections.length && quotaSection == ""; sectionIndex++)
	{
		if(srcUci.get(pkg, sections[sectionIndex], "id") == id )//10.10.11.100
		{
			quotaSection = sections[sectionIndex];
		}
	}

	$('#save_quota').attr('data-id',id);
	var ip = srcUci.get(pkg, quotaSection, "ip");
	ip = ip == "" ? "ALL" : ip;//apply_to的ip值

	var resetInterval = srcUci.get(pkg, quotaSection, "reset_interval");//week,month,day,hour
	var uploadLimit = srcUci.get(pkg, quotaSection, "egress_limit");//上传限制
	var downloadLimit = srcUci.get(pkg, quotaSection, "ingress_limit");//下载限制
	var combinedLimit = srcUci.get(pkg, quotaSection, "combined_limit");//总限制量

	resetInterval = resetInterval == "" || resetInterval == "minute" ? "day" : resetInterval;
	var offset = srcUci.get(pkg, quotaSection, "reset_time");
	offset = offset == "" ? 0 : parseInt(offset);
	var resetDay = getDaySeconds(offset);//quote_day 的 value
	var resetHour = getHourSeconds(offset);//quota_hour 的 value

	var exceededUpSpeed = srcUci.get(pkg, quotaSection, "exceeded_up_speed");//上传限制
	var exceededDownSpeed = srcUci.get(pkg, quotaSection, "exceeded_down_speed");//下载限制
	var upMark = srcUci.get(pkg, quotaSection, "exceeded_up_class_mark");//上传类的value
	var downMark = srcUci.get(pkg, quotaSection, "exceeded_down_class_mark");//下载类value


	setDocumentIp(ip, controlDocument);//设置ip到ip列表
	setSelectedValue("quota_reset", resetInterval, controlDocument);//设置reset选择框的值
	alterQuoteaReset();


	var timeParameters = getTimeParametersFromUci(srcUci, quotaSection);//["10:11-12:00", "mon,tue,wed,thu,fri", "", "except"]
	var days = timeParameters[1];//"mon,tue,wed,thu,fri"

	var allDays = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
	var dayList = [];
	if(days == "")
	{
		dayList = allDays;
	}
	else
	{
		dayList = days.split(/,/);
	}
	var dayIndex=0;
	for(dayIndex = 0; dayIndex < allDays.length; dayIndex++)
	{
		var nextDay = allDays[dayIndex];
		var dayFound = false;
		var testIndex=0;
		for(testIndex=0; testIndex < dayList.length && !dayFound; testIndex++)
		{
			dayFound = dayList[testIndex] == nextDay;
		}
		$("#quota_" + allDays[dayIndex]).prop('checked',dayFound);//设置复选框
	}

	$("#active_hours").val(timeParameters[0]);//设置这两个输入框的值
	$("#active_weekly").val(timeParameters[2]);//周一 00:30 - 周四 13:15

	var active = timeParameters[3];//always/only/except
	$("#quota_active").val(active);
	if(active != "always")
	{
		var activeTypes = [];
		activeTypes["000"] = "hours";
		activeTypes["100"] = "hours";
		activeTypes["010"] = "days";
		activeTypes["110"] = "days_and_hours";//判断当前是哪种quota_active_type
		var activeTypeId = (timeParameters[0] != "" ? "1" : "0") + (timeParameters[1] != "" ? "1" : "0") + (timeParameters[2] == "" ? "0" : "1");
		var activeType = activeTypes[activeTypeId] != null ? activeTypes[activeTypeId] : "weekly_range";
		$("#quota_active_type").val(activeType);
	}
	alterQuotaActiveType();
	alterQuotaActive();
	alterApplyto();



	$("#max_up_type").val(uploadLimit == "" ? "unlimited" : "limited");
	$("#max_down_type").val(downloadLimit == "" ? "unlimited" : "limited");
	$("#max_combined_type").val(combinedLimit == "" ? "unlimited" : "limited");

	alterLimitInput('max_up_type','max_up','max_up_unit');
	alterLimitInput('max_down_type','max_down','max_down_unit');
	alterLimitInput('max_combined_type','max_combined','max_combined_unit');


	setDocumentLimit(uploadLimit,   "max_up",       "max_up_unit", controlDocument);//设置三个限制的值和单位
	setDocumentLimit(downloadLimit, "max_down",     "max_down_unit", controlDocument);
	setDocumentLimit(combinedLimit, "max_combined", "max_combined_unit", controlDocument);

	var exceededType;
	if(exceededUpSpeed != "" && exceededDownSpeed != ""){
		exceededType = 'throttle';
	}else if(upMark != "" || downMark != ""){
		if(fullQosEnabled){
			exceededType = 'combined';
		}
	}else if(exceededUpSpeed == "" && exceededDownSpeed == "" && upMark == "" && downMark == ""){
			exceededType = 'hard_cutoff';
	}
	$("#quota_exceeded").val(exceededType);
	alterQuotaExceeded();

	setDocumentSpeed(exceededUpSpeed, "quota_qos_up",   "quota_qos_up_unit", controlDocument);//限制速度设置
	setDocumentSpeed(exceededDownSpeed, "quota_qos_down", "quota_qos_down_unit", controlDocument);

	// alterQuotaExceededClass();

	$("#quota_day").val(resetDay + "");
	$("#quota_hour").val(resetHour + "");

	if(fullQosEnabled)//设置上传下载类
	{
		setAllowableSelections("quota_full_qos_up_class", upQosMarks, upQosClasses, controlDocument);
		setAllowableSelections("quota_full_qos_down_class", downQosMarks, downQosClasses, controlDocument);
		if(upMark != "" && downMark != "")
		{
			$("#quota_full_qos_up_class").val(upMark);
			$("#quota_full_qos_down_class").val(downMark);
		}
	}
}

function setDocumentLimit(bytes, textId, unitSelectId, controlDocument)//根据bytes值设置单位及
{
	bytes = bytes == "" ? 0 : parseInt(bytes);
	var textEl = controlDocument.getElementById(textId);
	var defaultUnit = UI.MB;
	var defaultMultiple = 1024*1024;
	if(bytes <= 0)
	{
		setSelectedValue(unitSelectId, defaultUnit, controlDocument);
		textEl.value = "0";
	}
	else
	{
		var pb = parseBytes(bytes);
		var unit = defaultUnit;
		var multiple = defaultMultiple;
		if(pb.match(new RegExp(UI.GBy))) { unit = UI.GB; multiple = 1024*1024*1024; };
		if(pb.match(new RegExp(UI.TBy))) { unit = UI.TB; multiple = 1024*1024*1024*1024; };
		setSelectedValue(unitSelectId, unit, controlDocument);
		var adjustedVal = truncateDecimal(bytes/multiple);
		textEl.value = adjustedVal;
	}
}
function setDocumentSpeed(kbytes, textId, unitSelectId, controlDocument)//设置速度限制
{
	var defaultUnit = UI.KBs;
	var textEl = controlDocument.getElementById(textId);
	setSelectedValue(unitSelectId, defaultUnit, controlDocument);

	kbytes = kbytes == "" ? 0 : parseInt(kbytes);
	if(kbytes <= 0)
	{
		textEl.value = "0";
	}
	else
	{
		var pb = parseKbytesPerSecond(kbytes);
		var splitParsed = pb.split(/[\t ]+/);
		textEl.value = splitParsed[0];
		switch (splitParsed[1])
		{
		case UI.KBs:
			defaultUnit = 'KBytes/s'; break;
		case UI.MBs:
			defaultUnit = 'MBytes/s'; break;
		}
		setSelectedValue(unitSelectId, defaultUnit, controlDocument);
	}
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

function validateIpRange(range)
{
	var valid = 1; //initially invalid, 0=valid, 1=invalid
	if(range.indexOf("/") > 0)//验证/标识的IP范围
	{
		var split=range.split("/");
		if(split.length == 2)
		{
			var ipValid = validateIP(split[0]);
			var maskValid = validateNetMask(split[1]) == 0 || validateNumericRange(split[1],1,31) == 0 ? 0 : 1;
			valid = ipValid == 0 && maskValid == 0 ? 0 : 1;
		}
	}
	else//验证单个ip
	{
		valid = validateIP(range);
	}
	return valid;
}

function validateMultipleIps(ips)
{
	ips = ips.replace(/^[\t ]+/g, "");
	ips = ips.replace(/[\t ]+$/g, "");
	var splitIps = ips.split(/[\t ]*,[\t ]*/);
	var valid = splitIps.length > 0 ? 0 : 1; //1= error, 0=true
	while(valid == 0 && splitIps.length > 0)
	{
		var nextIp = splitIps.pop();
		if(nextIp.match(/-/))//如果是一个用短横线标识的ip范围
		{
			var nextSplit = nextIp.split(/[\t ]*-[\t ]*/);//转数组
			if( nextSplit.length==2 && validateIP(nextSplit[0]) == 0 && validateIP(nextSplit[1]) == 0)//如果是有效IP
			{
				var ipInt1 = getIpInteger(nextSplit[0]);
				var ipInt2 = getIpInteger(nextSplit[1]);
				valid = ipInt1 <= ipInt2 ? 0 : 1;//验证两个IP是否可构成range
			}
			else
			{
				valid = 1;
			}
		}
		else
		{
			valid = validateIpRange(nextIp);
		}
	}
	return valid;
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

function validateNetMask(mask)
{
	//return codes:
	//0 = valid mask
	//1 = invalid digit
	//2 = invalid field order
	//3 = fields > 255
	//4 = invalid format

	var errorCode = 0;
	var ipFields = mask.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
	if(ipFields == null)
	{
		errorCode = 4;
	}
	else
	{
		previousField = 255;
		for(field=1; field <= 4; field++)
		{
			if(ipFields[field] > 255)
			{
				errorCode = 3;
			}
			if(previousField < 255 && ipFields[field] != 0 && errorCode < 2)
			{
				errorCode = 2;
			}
			if(	ipFields[field] != 255 &&
				ipFields[field] != 254 &&
				ipFields[field] != 252 &&
				ipFields[field] != 248 &&
				ipFields[field] != 240 &&
				ipFields[field] != 224 &&
				ipFields[field] != 192 &&
				ipFields[field] != 128 &&
				ipFields[field] != 0 &&
				errorCode <  1
			)
			{
				errorCode = 1;
			}

			previousField = ipFields[field];
		}
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

function setUciFromDocument(controlDocument, id)//从表单上的输入新建或编辑的数据设置到uci
{
	controlDocument = controlDocument == null ? document : controlDocument;

	var ip = getIpFromDocument(controlDocument);//获取IP
	id = id == null ? "" : id;
	id = id == "" ? getIdFromIp(ip) : id;//获取id
	// id = getIdFromIp(ip);//获取id


	var quotaSection = "";
	var sections = uci.getAllSectionsOfType(pkg, "quota");
	for(sectionIndex=0; sectionIndex < sections.length; sectionIndex++)
	{
		if(uci.get(pkg, sections[sectionIndex], "id") == id)
		{
			quotaSection = sections[sectionIndex];
		}
	}//如果能找到这个id的数据那就是编辑
	if(quotaSection == "")//如果找不到那就是新建咯 
	{
		var quotaNum = 1;
		while( uci.get(pkg, "quota_" + quotaNum, "") != "") { quotaNum++; }//遍历出新建数据的id数字后缀
		quotaSection = "quota_" + quotaNum;
		uci.set(pkg, quotaSection, "", "quota");
	}

	var oldIp = uci.get(pkg, quotaSection, "ip");//获取旧的ip
	if(oldIp != ip)//如果旧ip不等于新ip。。。TODO 这个是啥子哦？？？
	{
		if(!testAddrOverlap(oldIp, ip))
		{
			changedIds[id] = 1;
		}
	}

	//三个限制设置
	uci.set(pkg, quotaSection, "ingress_limit",  getDocumentLimit("max_down", "max_down_type", "max_down_unit", controlDocument)  );
	uci.set(pkg, quotaSection, "egress_limit",   getDocumentLimit("max_up", "max_up_type", "max_up_unit", controlDocument) );
	uci.set(pkg, quotaSection, "combined_limit", getDocumentLimit("max_combined", "max_combined_type", "max_combined_unit", controlDocument) );

	//上传下载速度设置
	uci.set(pkg, quotaSection, "exceeded_up_speed", getDocumentSpeed("quota_only_qos_container", "quota_qos_up", "quota_qos_up_unit", controlDocument) );
	uci.set(pkg, quotaSection, "exceeded_down_speed", getDocumentSpeed("quota_only_qos_container", "quota_qos_down", "quota_qos_down_unit", controlDocument) );

	var up_speed = getDocumentSpeed("quota_only_qos_container", "quota_qos_up", "quota_qos_up_unit", controlDocument);
	var down_speed = getDocumentSpeed("quota_only_qos_container", "quota_qos_down", "quota_qos_down_unit", controlDocument);
	//设置上传下载类
	var up_class_mark;
	var down_class_mark;
	if(!up_speed){
		up_class_mark = getDocumentMark("quota_full_qos_container", "quota_full_qos_up_class", controlDocument);
	}else{
		up_class_mark = '';
	}
	if(!down_speed){
		down_class_mark = getDocumentMark("quota_full_qos_container", "quota_full_qos_down_class", controlDocument);
	}else{
		down_class_mark = '';
	}
	uci.set(pkg, quotaSection, "exceeded_up_class_mark", getDocumentMark("quota_full_qos_container", "quota_full_qos_up_class", controlDocument) );
	uci.set(pkg, quotaSection, "exceeded_down_class_mark", getDocumentMark("quota_full_qos_container", "quota_full_qos_down_class", controlDocument) );

	//设置interval
	uci.set(pkg, quotaSection, "reset_interval", getSelectedValue("quota_reset", controlDocument));
	//设置ip/id
	uci.set(pkg, quotaSection, "ip", ip);
	uci.set(pkg, quotaSection, "id", id);

	var qd = getSelectedValue("quota_day", controlDocument);//获取quota_day的值
	var qh = getSelectedValue("quota_hour", controlDocument);//获取quota_hour的值
	qd = qd == "" ? "0" : qd;
	qh = qh == "" ? "0" : qh;
	var resetTime= parseInt(qd) + parseInt(qh);
	if(resetTime > 0)//如果设置了quota_day或quota_hour
	{
		var resetTimeStr = resetTime + "";
		uci.set(pkg, quotaSection, "reset_time", resetTimeStr);//设置reset_time
	}
	else
	{
		uci.remove(pkg, quotaSection, "reset_time");//移除reset_time
	}

	var timeParameters = getTimeParametersFromDocument(controlDocument);//从文档获取时间参数
	var active = timeParameters[3];//type
	var onoff = ["offpeak", "onpeak"];
	var onoffIndex = 0;
	for(onoffIndex=0; onoffIndex < onoff.length; onoffIndex++)
	{
		var prefix = onoff[onoffIndex];
		var updateFun = function(prefixActive,option,val)
		{
			if(prefixActive)
			{
				uci.set(pkg,quotaSection,option,val);
			}
			else
			{
				uci.remove(pkg,quotaSection,option);
			}
		}
		var prefixActive = (prefix == "offpeak" && active == "except") || (prefix == "onpeak" && active == "only");
		updateFun(prefixActive, prefix + "_hours", timeParameters[0]);
		updateFun(prefixActive, prefix + "_weekdays", timeParameters[1]);
		updateFun(prefixActive, prefix + "_weekly_ranges", timeParameters[2]);
	}
}

function getTimeParametersFromDocument(controlDocument)//从表单中获取时间参数
{
	//如果显示了就获取input的值，否则就是''
	var hours = $('#active_hours').parent().parent().hasClass('hidden') ? '' : $('#active_hours').val();
	var weekly = $('#active_weekly').parent().parent().hasClass('hidden') ? '' : $('#active_weekly').val();

	var dayList = [];
	//如果复选框列表显示了
	if(!$("#active_days_container").hasClass('hidden'))
	{
		var allDays = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var dayIndex;
		for(dayIndex=0; dayIndex < allDays.length; dayIndex++)
		{
			if( $("#quota_" + allDays[dayIndex]).prop('checked') )//如果勾选了
			{
				dayList.push( allDays[dayIndex]);
			}
		}
	}
	var days = "" + dayList.join(",");
	var active = $("#quota_active").val();//active类型
	return [hours,days,weekly_i18n(weekly, "page"),active];//返回这个数组咯
}

function getTimeParametersFromUci(srcUci, quotaSection, i18ndays)//从uci中获取时间参数
{
	var hours = srcUci.get(pkg, quotaSection, "offpeak_hours");
	var days = srcUci.get(pkg, quotaSection, "offpeak_weekdays");
	var weekly = srcUci.get(pkg, quotaSection, "offpeak_weekly_ranges");
	var active = hours != "" || days != "" || weekly != "" ? "except" : "always";
	if(active == "always")
	{
		hours = srcUci.get(pkg, quotaSection, "onpeak_hours");
		days = srcUci.get(pkg, quotaSection, "onpeak_weekdays");
		weekly = srcUci.get(pkg, quotaSection, "onpeak_weekly_ranges");
		active = hours != "" || days != "" || weekly != "" ? "only" : "always";

	}
	return [hours,(i18ndays==1?dayToi18n(days):days),weekly_i18n(weekly, "uci"),active];
}


/* returns a number if there is a limit; "" if no limit defined 获取limit值 */
function getDocumentLimit(textId, unlimitedSelectId, unitSelectId, controlDocument)
{
	var ret = "";
	if(getSelectedValue(unlimitedSelectId, controlDocument) != "unlimited")
	{
		var unit = getSelectedValue(unitSelectId, controlDocument);
		var multiple = 1024*1024;
		if(unit == "MB") { multiple = 1024*1024; }
		if(unit == "GB") { multiple = 1024*1024*1024; }
		if(unit == "TB") { multiple = 1024*1024*1024*1024; }
		var bytes = Math.round(multiple * parseFloat(controlDocument.getElementById(textId).value));
		ret =  "" + bytes;
	}
	return ret;
}

function getDocumentSpeed(containerId, textId, unitSelectId, controlDocument)//获取speed值
{
	var ret = "";
	if(!$('#' + containerId).hasClass('hidden'))
	{
		var unit = getSelectedValue(unitSelectId, controlDocument);
		if(unit == "MBytes/s") { multiple = 1024; }
		if(unit == "KBytes/s") { multiple = 1; }
		var kbits = Math.round(multiple * parseFloat(controlDocument.getElementById(textId).value));
		ret = "" + kbits;
	}
	return ret;
}

function getDocumentMark(containerId, selectId, controlDocument)//获取上传下载类
{
	var ret = "";
	if(!$('#' + containerId).hasClass('hidden'))
	{
		ret = getSelectedValue(selectId, controlDocument);
	}
	return ret;
}


function createEnabledCheckbox(enabled)//创建复选框字符串
{
	// enabledCheckbox = createInput('checkbox');
	// enabledCheckbox.onclick = setRowEnabled;
	// enabledCheckbox.checked = enabled;
	var checked = enabled ? 'checked' : '';
	var checkbox = '<input type="checkbox" ' + checked + '>'
	return checkbox;
}

function createBtn(text,class_name)//创建btn字符串
{
	// editButton = createInput("button");
	// editButton.value = 'Edit';
	// editButton.className="default_button";
	// editButton.onclick = editQuota;

	// editButton.className = enabled ? "default_button" : "default_button_disabled" ;
	// editButton.disabled  = enabled ? false : true;
	var class_name = class_name ? class_name : 'default';
	var text = text ? text : '';
	var btn_dom = '<button class="btn btn-xs btn-' + class_name + '">' + text + '</button>'

	return btn_dom;
}

function setRowEnabled()//设置一个规则的启用与否
{
	enabled= this.checked ? "1" : "0";//获取这个复选框的checked值
	enabledRow=this.parentNode.parentNode;//获取行的引用

	//禁用之后编辑按钮disabled
	enabledRow.childNodes[rowCheckIndex+1].firstChild.disabled  = this.checked ? false : true;
	enabledRow.childNodes[rowCheckIndex+1].firstChild.className = this.checked ? "default_button" : "default_button_disabled" ;

	var idStr = this.id;
	var ids = idStr.split(/\./);//获取id
	if(uci.get(pkg, ids[0]) != "")//然后直接在uci中设置数据的enabled
	{
		uci.set(pkg, ids[0], "enabled", enabled);
	}
	if(uci.get(pkg, ids[1]) != "")
	{
		uci.set(pkg, ids[1], "enabled", enabled);
	}
}

function removeQuotaCallback(id){
	var sections = uci.getAllSectionsOfType(pkg, "quota");//全部的sections
	for(sectionIndex=0; sectionIndex < sections.length; sectionIndex++)
	{
		if(uci.get(pkg, sections[sectionIndex], "id") == id)//遍历出这个id的数据
		{
			uci.removeSection(pkg, sections[sectionIndex]);//移除
		}
	}
	changedIds [ id ] = 1;//依旧不知道这是什么鬼  TODO？？？
}

function resetTable(data){
	var trs = createTrs(data);
	$('#quota_container').empty().append(trs);
	$('#quota_container').find('.btn-primary')
						 .attr('data-toggle','modal')
						 .attr('data-target','#quotaModal')
						 .click(function(){
							var id = $(this).parent().parent().prop('id');
							$('#save_quota').html(UI.Save).attr('data-type','edit');
							setDocumentFromUci(document,uci,id);
							disableSaveBtn();
						});
	$('#quota_container').find('.btn-danger').click(function(){
		var id = $(this).parent().parent().prop('id');
		$(this).parent().parent().remove();
		removeQuotaCallback(id);
	});

	Ha.setFooterPosition();
}

function saveEdited(id){
	var editId = id;

	var editIp;

	var editSection = "";
	var sections = uci.getAllSectionsOfType(pkg, "quota");//遍历出数据 
	for(sectionIndex=0; sectionIndex < sections.length && editSection == ""; sectionIndex++)
	{
		if(uci.get(pkg, sections[sectionIndex], "id") == editId)
		{
			editSection = sections[sectionIndex];
			editIp = uci.get(pkg, editSection, "ip");
		}
	}
	var errors = validateQuota(document, editId, editIp);//做验证
	if(errors.length > 0)
	{
		Ha.showNotify({status: 1, msg: errors[0] + '<br>' + quotasStr.QuotaAddError});
	}
	else
	{
		var newIp = getIpFromDocument(document);//获取IP
		setUciFromDocument(document, editId);//根据id设置数据
		var tableData = getTableData(uci);
		$('#quotaModal').modal('hide');
		resetTable(tableData);
	}
}

function dayToi18n(daystrings) { //this is part of i18n; TODO: best to have an uci get language to see if absent to just return daystrings
	var days=daystrings.split(",");
	for (var i = 0; i < days.length; i++) {
		if (days[i] == "sun") { days[i] = UI.Sun; }
		if (days[i] == "mon") { days[i] = UI.Mon; }
		if (days[i] == "tue") { days[i] = UI.Tue; }
		if (days[i] == "wed") { days[i] = UI.Wed; }
		if (days[i] == "thu") { days[i] = UI.Thu; }
		if (days[i] == "fri") { days[i] = UI.Fri; }
		if (days[i] == "sat") { days[i] = UI.Sat; }
	}
	return days.join();
}

function weekly_i18n(weekly_schd, direction) { //this is part of i18n; TODO: best to have an uci get language to see if absent to just return daystrings
	if (weekly_schd.length < 6) return weekly_schd;
	var localdays=[UI.Sun, UI.Mon, UI.Tue, UI.Wed, UI.Thu, UI.Fri, UI.Sat];
	var fwdays=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	var indays, outdays, splits, idx;
	var joiner=[];

	if (direction == "uci") {
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


resetData();


//-----------------------------------------------------------

function validateDecimal(num)
{
	var errorCode = num.match(/^[\d]*\.?[\d]+$/) != null || num.match(/^[\d]+\.?[\d]*$/) != null ? 0 : 1;
	return errorCode;
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

function proofreadFields(inputIds, labelIds, functions, validReturnCodes, visibilityIds, fieldDocument )
{
	fieldDocument = fieldDocument == null ? document : fieldDocument;

	var errorArray= new Array();
	for (idIndex in inputIds)
	{
		isVisible = true;
		if(visibilityIds != null)
		{
			if(visibilityIds[idIndex] != null)
			{
				isVisible = $('#' + visibilityIds[idIndex]).hasClass('hidden') == true ? false : true;
			}
		}
		if(isVisible)
		{
			inputId = inputIds[idIndex];

			f = functions[idIndex];
			proofreadText(inputId, f, validReturnCodes[idIndex]);//输入的时候文本的颜色变化
			if(f($('#' + inputId).val()) != validReturnCodes[idIndex])
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
				errorArray.push(UI.prfErr+" " + labelStr);//There is An Error in ...
			}
		}
	}
	return errorArray;
}

function proofreadText(input, proofFunction, validReturnCode)
{
	if($('#' + input).prop('disabled') != true)
	{
		$('#' + input).css('color',(proofFunction($('#' + input).val()) == validReturnCode) ? "black" : "red");
	}
}

function setSelectedValue(selectId, selection, controlDocument)
{
	var controlDocument = controlDocument == null ? document : controlDocument;

	var selectElement = controlDocument.getElementById(selectId);
	if(selectElement == null){ console.error(UI.Err+": " + selectId + " "+UI.nex); }

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

function setInvisibleIfIdMatches(selectId, invisibleOptionValues, associatedElementId, defaultDisplayMode, controlDocument )
{
	//根据不同的select值设置子输入框的隐现
	controlDocument = controlDocument == null ? document : controlDocument;
	defaultDisplayMode = defaultDisplayMode == null ? "block" : defaultDisplayMode;
	var visElement = controlDocument.getElementById(associatedElementId);
	var matches = false;
	var matchIndex = 0;
	if(visElement != null)
	{
		for (matchIndex=0; matchIndex < invisibleOptionValues.length; matchIndex++)
		{
			matches = getSelectedValue(selectId, controlDocument) == invisibleOptionValues[matchIndex] ? true : matches;
		}
		if(matches)
		{
			visElement.style.display = "none";
		}
		else
		{
			visElement.style.display = defaultDisplayMode;
		}
	}
}

function getSelectedValue(selectId, controlDocument)
{
	controlDocument = controlDocument == null ? document : controlDocument;

	if(controlDocument.getElementById(selectId) == null)
	{
		console.error(UI.Err+": " + selectId + " "+UI.nex);
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

	//FUCK M$ IE, FUCK IT UP THE ASS WITH A BASEBALL BAT.  A BIG WOODEN ONE. WITH SPLINTERS.
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

function textListToSpanElement(textList, addCommas, controlDocument)//为文本列表添加换行
{
	addCommas = addCommas == null ? false : addCommas;
	controlDocument = controlDocument == null ? document : controlDocument;

	var spanEl = controlDocument.createElement("span");
	var tlIndex;
	for(tlIndex=0; tlIndex < textList.length ; tlIndex++)
	{
		if(tlIndex > 0)
		{
			spanEl.appendChild( controlDocument.createElement("br") );
		}

		spanEl.appendChild(controlDocument.createTextNode(  textList[tlIndex] + (tlIndex < textList.length-1 && addCommas ? "," : "")  ));
	}
	return spanEl.innerHTML;
}

function truncateDecimal(dec)
{
	result = "" + ((Math.floor(dec*1000))/1000);

	//make sure we have exactly three decimal places so
	//results line up properly in table presentation
	decMatch=result.match(/.*\.(.*)$/);
	if(decMatch == null)
	{
		result = result + ".000"
	}
	else
	{
		if(decMatch[1].length==1)
		{
			result = result + "00";
		}
		else if(decMatch[1].length==2)
		{
			result = result + "0";
		}
	}
	return result;
}


//--------------------------------------usage------------------------------------
function refreshTableData(scheme)
{
	scheme = scheme == null ? "pcts" : scheme;
	var quotaSections = uciOriginal.getAllSectionsOfType(pkg, "quota");
	var quotaTableData = [];

	var quotaData = [];
	if (scheme.localeCompare("usds") == 0)
	{
		quotaData = allQuotaUsed;
	}
	else if (scheme.localeCompare("lims") == 0)
	{
		quotaData = allQuotaLimits;
	}
	else if (scheme.localeCompare("pcts") == 0)
	{
		quotaData = allQuotaPercents;
	}

	var idIndex;
	for(idIndex=0; idIndex < allQuotaIds.length; idIndex++)
	{
		var ipIndex;
		var id =  allQuotaIds[idIndex];
		var quotaIpList = allQuotaIps[ id ];
		var timeParameters = idToTimeParams[ id ];
		var hide = false;
		for(ipIndex=0; ipIndex < quotaIpList.length; ipIndex++)
		{
			var ip       = quotaIpList[ipIndex];
			var up       = "N/A";
			var down     = "N/A";
			var total    = "N/A";
			if(quotaData[id] != null)
			{
				if(quotaData[id][ip] != null)
				{
					var data = quotaData[id][ip];
					var usedData = allQuotaUsed[id][ip]
					var noData = usedData[0]<=0 && usedData[1]<=0 && usedData[2]<=0 ;
					hide = noData && id.localeCompare("ALL_OTHERS_INDIVIDUAL") == 0;
					if (scheme.localeCompare("pcts") == 0)
					{
						total = data[0] >= 0 ? percentColorSpan(data[0]) : total;
						down = data[1] >= 0 ? percentColorSpan(data[1]) : down;
						up = data[2] >= 0 ? percentColorSpan(data[2]) : up;
					}
					else
					{
						total = data[0] >= 0 ? parseBytes(data[0]) : total;
						down = data[1] >= 0 ? parseBytes(data[1]) : down;
						up = data[2] >= 0 ? parseBytes(data[2]) : up;
					}
				}
			}
			ipList = ip.split(/[\t ]*,[\t ]*/);
			hostList = getHostList(ipList);
			if (!hide)
			{
				quotaTableData.push( [ textListToSpanElement(hostList, true, document), timeParamsToTableSpan(timeParameters), total, down, up ] );
			}
		}
	}
	var trs = createUsageTrs(quotaTableData);
	$('#active_quota_container').empty().append(trs);
	if(!trs){
		$('#active_quota_container').append('<tr><td colspan="5">'+UI.No_Active_Quota+'.</td></tr>');
	}
	Ha.setFooterPosition();
}

function updateTableData()
{
	if(!updateInProgress)
	{
		updateInProgress = true;

		var stateChangeFunction = function(data)
		{
			var text = data.split(/[\r\n]+/);
			
			var next = "";
			while(text.length > 0 && next != "Success")
			{
				next = text.pop();
			}
			eval(text.join("\n"));
			allQuotaIds      = quotaIdList;
			allQuotaIps      = quotaIpLists;
			allQuotaUsed     = quotaUsed;
			allQuotaLimits   = quotaLimits;
			allQuotaPercents = quotaPercents;
			refreshTableData($("#data_display").val());
			updateInProgress = false;
		}
		$.post('/','app=quotas&action=quotas_status',stateChangeFunction);
	}

}

function getIdFromIp_usage(ip, srcUci)//usage的
{
	id = ip == "" ? "ALL" : ip.replace(/[\t, ]+.*$/, "");
	id = id.replace(/\//, "_");

	var idPrefix = id;
	var found = true;
	var suffixCount = 0;

	var quotaSections = srcUci.getAllSectionsOfType(pkg, "quota");

	while(found)
	{
		found = false;
		var sectionIndex;
		for(sectionIndex=0; sectionIndex < quotaSections.length && (!found); sectionIndex++)
		{
			found = found || srcUci.get(pkg, quotaSections[sectionIndex], "id") == id;
		}
		if(found)
		{
			var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			var suffix = suffixCount < 26 ? "_" + letters.substr(suffixCount,1) : "_Z" + (suffixCount-25);
			id = idPrefix + suffix;
		}
		suffixCount++;
	}
	return id;
}

function getIpFromUci(srcUci, quotaSection)
{
	var ipStr = srcUci.get(pkg, quotaSection, "ip");
	if(ipStr == "ALL_OTHERS_INDIVIDUAL")
	{
		ipStr=quotasStr.OthersOne;
	}
	else if(ipStr == "ALL_OTHERS_COMBINED")
	{
		ipStr = quotasStr.OthersAll;
	}
	else if(ipStr == "ALL" || ipStr == "")
	{
		ipStr = quotasStr.All;
	}
	return ipStr;
}

function percentColorSpan(percent)
{
	span = document.createElement("span");
	text = null;
	color = 'black';
	if (percent != null)
	{
		text = document.createTextNode(percent + "%");

		var toHexTwo = function(num) { var ret = parseInt(num).toString(16).toUpperCase(); ret= ret.length < 2 ? "0" + ret : ret.substr(0,2); return ret; }

		color = percent >= 100  ? "#AA0000" : "";
		color = percent >= 50 && percent < 100 ? "#AA" + toHexTwo(170-(170*((percent-50)/50.0))) + "00" : color;
		color = percent >= 0 && percent < 50 ? "#" + toHexTwo(170*(percent)/50.0) + "AA00" : color;
		color = percent <= 0 ? "#00AA00" : color;
		span.style.color = color;
	}
	span.appendChild(text);
	return span.outerHTML;
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