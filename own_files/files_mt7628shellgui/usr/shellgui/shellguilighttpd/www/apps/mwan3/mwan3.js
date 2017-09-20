/* switch */
$('#switch_mwan_radio0').click(function(){
	var checked = $(this).find('[type="checkbox"]').prop('checked');
	var text = checked ? '关闭？' : '开启？';
	Ha.alterModal('confirmModal','Mwan3',text,submitMwan,'switch_mwan_radio0');
});

function submitMwan(switchId){
  	var status = $('#' + switchId).find('[type="checkbox"]').prop('checked');
  	var enable = status ? 0 : 1;
  	console.log(enable);
  	var post_data = 'app=mwan3&action=enable_mwan3&enabled=' + enable;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
	  	var result = data.status == 1 ? false : true;
	  	var checked = status;
	  	Ha.setSwitchBtn(switchId,result,checked);
	  	console.log($('#' + switchId).find('[type="checkbox"]').prop('checked'));
	},'json');
}

$('[data-switch="wan"]').click(function(){
	var checked = $(this).find('[type="checkbox"]').prop('checked');
	var switchId = $(this).prop('id');
	var text = checked ? '关闭？' : '开启？';
	Ha.alterModal('confirmModal','Wan',text,submitWan,switchId);
});

function submitWan(switchId){
  	var status = $('#' + switchId).find('[type="checkbox"]').prop('checked');
  	var enable = status ? 0 : 1;
  	var wan = $('#' + switchId).find('[type="checkbox"]').prop('id').replace('switch_','');
  	var post_data = 'app=mwan3&action=enable_wan&wan=' + wan + '&enabled=' + enable;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
	  	var result = data.status == 1 ? false : true;
	  	var checked = status;
	  	Ha.setSwitchBtn(switchId,result,checked);
	},'json');
}

$('#wan_table').find('[data-validate="num"]').bind('keyup blur',function(){
	var val = $(this).val();
	if(va.validateNum(val)){
		$(this).next('.btn').prop('disabled',true);
		$(this).parent().find('.help-block').removeClass('hidden');
	}else{
		$(this).next('.btn').prop('disabled',false);
		$(this).parent().find('.help-block').addClass('hidden');
	}
});
$('#wan_table').find('[data-validate="num"]').each(function(){
	var val = $(this).val();
	if(va.validateNum(val)){
		$(this).next('.btn').prop('disabled',true);
		$(this).parent().find('.help-block').removeClass('hidden');
	}else{
		$(this).next('.btn').prop('disabled',false);
		$(this).parent().find('.help-block').addClass('hidden');
	}
});

$('.metric_btn').click(function(){
	var val = $(this).parent().find('input').val();
	var wan = $(this).prop('id').replace('submit_','');
	if(va.validateNum(val)){
		$(this).next('.help-block').removeClass('hidden');
		$(this).prop('disabled',true);
		return false;
	}else{
		var post_data = 'app=mwan3&action=edit_wan_metric&wan=' + wan + '&metric=' + val;
		$.post('/',post_data,function(data){
			Ha.showNotify(data);
			//

		},'json');
	}
})

/* remove btn */
$('[data-switch="remove-wan"]').click(function(){
	var wan = $(this).attr('data-wan');
	Ha.alterModal('confirmModal','Wan-remove','R U Sure to remove this wan?',removeWan,wan);
});
function removeWan(id){
	var post_data = 'app=mwan3&action=rm_wan&wan=' + id;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
		if(!data.status){
			$('#wan_list_' + id).remove();
		}else{

		}
	},'json');
}

$('[data-switch="remove-member"]').click(function(){
	var member = $(this).attr('data-member');
	Ha.alterModal('confirmModal','Member-remove','R U Sure to remove this Member?',removeMember,member);
});
function removeMember(id){
	var post_data = 'app=mwan3&action=rm_member&member=' + id;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
		if(!data.status){
			$('#member_list_' + id).remove();
		}else{

		}
	},'json');
}

$('[data-switch="remove-policy"]').click(function(){
	var policy = $(this).attr('data-policy');
	Ha.alterModal('confirmModal','policy-remove','R U Sure to remove this policy?',removePolicy,policy);
});
function removePolicy(id){
	var post_data = 'app=mwan3&action=rm_policy&policy=' + id;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
		if(!data.status){
			$('#policy_list_' + id).remove();
		}else{

		}
	},'json');
}

$('[data-switch="remove-rule"]').click(function(){
	var rule = $(this).attr('data-rule');
	Ha.alterModal('confirmModal','policy-rule','R U Sure to remove this rule?',removeRule,rule);
});
function removeRule(id){
	var post_data = 'app=mwan3&action=rm_rule&rule=' + id;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
		if(!data.status){
			$('#policy_list_' + id).remove();
		}else{

		}
	},'json');
}

/* edit_wan */
$('#set_wan').find('[data-validate]').bind('blur keyup',function(){
	var validate_type = $(this).attr('data-validate');
	var val = $(this).val();
	if(validate_type == 'ip'){
		if(checkIPs(val)){
			$(this).parent().parent().addClass('has-error');
			$(this).next('.help-block').removeClass('hidden');
		}else{
			$(this).parent().parent().removeClass('has-error');
			$(this).next('.help-block').addClass('hidden');
		}
	}else if(validate_type == 'num'){
		if(va.validateNum(val)){
			$(this).parent().parent().parent().addClass('has-error');
			$(this).parent().next('.help-block').removeClass('hidden');
		}else{
			$(this).parent().parent().parent().removeClass('has-error');
			$(this).parent().next('.help-block').addClass('hidden');
		}
	}
	disableWanBtn();
});

function checkIPs(val){
	var errorCode = 0;
	var ip = val.split(',');
	for(var i=0; i<ip.length; i++){
		if(va.validateIP(ip[i])){
			errorCode += 1;
		}
	}
	return errorCode;
}
function disableWanBtn(){
	var sum = 0;
	$('#set_wan').find('.help-block').each(function(){
		if(!$(this).hasClass('hidden')){
			sum += 1;
		}
	});

	if(sum){
		$('#submit_wan_btn').prop('disabled',true);
	}else{
		$('#submit_wan_btn').prop('disabled',false);
	}
	return sum;
}

$('#set_wan').submit(function(){
	var error = disableWanBtn();
	if(error){
		return false;
	}else{
		var form_data = $('#set_wan').serialize();
		var post_data = 'app=mwan3&action=do_edit_wan&' + form_data;
		$.post('/',post_data,function(data){
			Ha.showNotify(data);
			//...

		},'json');
		return false;
	}

});

/* edit member */
$('#set_member').find('[data-validate]').bind('blur keyup',function(){
	var val = $(this).val();
	if(va.validateNum(val) || parseInt(val) > 1000){
		$(this).parent().parent().parent().addClass('has-error');
		$(this).parent().next('.help-block').removeClass('hidden');
	}else{
		$(this).parent().parent().parent().removeClass('has-error');
		$(this).parent().next('.help-block').addClass('hidden');
	}
	disableMemberBtn();
});

function disableMemberBtn(){
	var sum = 0;
	$('#set_member').find('.help-block').each(function(){
		if(!$(this).hasClass('hidden')){
			sum += 1;
		}
	});

	if(sum){
		$('#submit_member_btn').prop('disabled',true);
	}else{
		$('#submit_member_btn').prop('disabled',false);
	}
	return sum;
}

$('#set_member').submit(function(){
	var error = disableMemberBtn();
	if(error){
		return false;
	}else{
		var form_data = $('#set_member').serialize();
		var post_data = 'app=mwan3&action=do_edit_member&' + form_data;
		$.post('/',post_data,function(data){
			Ha.showNotify(data);
			//...

		},'json');
		return false;
	}
});

/* set policy */
$('#set_policy').submit(function(){
	var form_data = $(this).serialize();
	var post_data = 'app=mwan3&action=do_edit_policy&' + form_data;
	$.post('/',post_data,function(data){
		Ha.showNotify(data);
		//...

	},'json');
	return false;
});


/* set rule */
$('#set_rule').find('[data-validate]').bind('keyup blur',function(){
	var validate_type = $(this).attr('data-validate');
	var val = $(this).val();
	if(validate_type == 'ips'){
		if(val.length > 0 && validateMultipleIps(val)){
			$(this).parent().parent().addClass('has-error');
			$(this).next('.help-block').removeClass('hidden');
		}else{
			$(this).parent().parent().removeClass('has-error');
			$(this).next('.help-block').addClass('hidden');
		}
	}else if(validate_type == 'port'){
		if(val.length > 0 && checkPorts(val)){
			$(this).parent().parent().addClass('has-error');
			$(this).next('.help-block').removeClass('hidden');
		}else{
			$(this).parent().parent().removeClass('has-error');
			$(this).next('.help-block').addClass('hidden');
		}
	}else if(validate_type == 'num'){
		if(val.length > 0 && va.validateNum(val)){
			$(this).parent().parent().addClass('has-error');
			$(this).next('.help-block').removeClass('hidden');
		}else{
			$(this).parent().parent().removeClass('has-error');
			$(this).next('.help-block').addClass('hidden');
		}
	}
	disableRuleBtn();
});

function checkPorts(val){
	var errorCode = 0;
	var ports = val.split(',');
	for(var i=0; i<ports.length; i++){
		if(va.validatePort(ports[i])){
			errorCode += 1;
		}
	}
	return errorCode;
}

function disableRuleBtn(){
	var sum = 0;
	$('#set_rule').find('.help-block').each(function(){
		if(!$(this).hasClass('hidden')){
			sum += 1;
		}
	});

	if(sum){
		$('#submit_rule_btn').prop('disabled',true);
	}else{
		$('#submit_rule_btn').prop('disabled',false);
	}
	return sum;
}

$('#set_rule').submit(function(){
	var error = disableRuleBtn();
	if(error){
		return false;
	}else{
		var form_data = $('#set_rule').serialize();
		var post_data = 'app=mwan3&action=do_edit_rule&' + form_data;
		$.post('/',post_data,function(data){
			Ha.showNotify(data);
			//...

		},'json');
		return false;
	}
});


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
