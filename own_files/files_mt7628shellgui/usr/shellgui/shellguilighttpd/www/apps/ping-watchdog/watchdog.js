(function(){
	$(window).load(function(){
		var status = $('#watchdog_switch').prop('checked');
		if(status){
			$('#form_container').find('input,select').prop('disabled',false);
		}else{
			$('#form_container').find('input,select').prop('disabled',true);
		}
	});
	$('#watchdog_switch').click(function(){
		var status = $('#watchdog_switch').prop('checked');
		console.log(status);
		if(status){
			$('#form_container').find('input,select').prop('disabled',false);
		}else{
			$('#form_container').find('input,select').prop('disabled',true);
		}
	});

	$('#timeout_action').change(function(){
		var value = $(this).val();
		if(value == 'exec_custom'){
			$('#custom_script').removeClass('hidden');
			$('#script').prop('required',true).val('').focus();
		}else{
			$('#custom_script').addClass('hidden');
			$('#script').prop('required',false).val('');
		}
		$('#script').next('.help-block').addClass('hidden');
		$('#script').parent().parent().removeClass('has-error');
		disableBtn();
	})

	$('#form_container').submit(function(){
		var status = $('#watchdog_switch').prop('checked');
		var data = $('#form_container').serialize();
		if(status){
			data = 'app=ping-watchdog&action=ping_watchdog_setting&status=' + status + '&' + data;
		}else{
			data = 'app=ping-watchdog&action=ping_watchdog_setting&status=' + status;
		}
		var ip = $('#host').val();
		var interval = $('#exec_interval').val();
		var delay_time = $('#delay_time').val();
		var ping_count = $('#ping_count').val();
		var timeout_action = $('#timeout_action').val();
		var script = $('#script').val();
		if(ip.length <= 0 || (va.validateIP(ip) && va.validateDomain(ip)) || interval.length <= 0 || isNaN(parseInt(interval)) || 
			parseInt(interval) <=0 || parseInt(interval) > 59 || delay_time.length <= 0 || isNaN(parseInt(delay_time)) ||
			parseInt(delay_time) <= 0 || isNaN(parseInt(ping_count)) || 
			parseInt(ping_count) <= 0 || (timeout_action == 'exec_custom' && va.validatePath(script))){
			return false;
		}else{
			$.post('/',data,Ha.showNotify,'json');
		}
		return false;
	});

	$('#host').bind('keyup blur',function(){
		validateFuc($(this),va.validateIP($(this).val()) && va.validateDomain($(this).val()));
	});

	$('#exec_interval').bind('blur keyup',function(){
		var val = $(this).val();
		var num = parseInt(val);
		validateFuc($(this).parent(),val.length <= 0 || isNaN(num) || num <= 0 || num > 59);
	});

	$('#delay_time').bind('blur keyup',function(){
		var val = $(this).val();
		var num = parseInt(val);
		validateFuc($(this).parent(),val.length <= 0 || isNaN(num) || num <= 0);
	});

	$('#ping_count').bind('blur keyup',function(){
		var val = $(this).val();
		var num = parseInt(val);
		validateFuc($(this),val.length <= 0 || isNaN(num) || num <= 0);
	});

	$('#script').bind('blur keyup',function(){
		var val = $(this).val();
		validateFuc($(this),val.length <= 0 || va.validatePath(val));
	});
	function validateFuc(target,condation){
		if(condation){
			target.parent().parent().addClass('has-error');
			target.next('.help-block').removeClass('hidden');
		}else{
			target.parent().parent().removeClass('has-error');
			target.next('.help-block').addClass('hidden');
		}
		disableBtn();
	}
	function disableBtn(){
		var ip = $('#host').val();
		var interval = $('#exec_interval').val();
		var delay_time = $('#delay_time').val();
		var ping_count = $('#ping_count').val();
		var timeout_action = $('#timeout_action').val();
		var script = $('#script').val();
		if(ip.length <= 0 || (va.validateIP(ip) && va.validateDomain(ip)) || interval.length <= 0 || isNaN(parseInt(interval)) || 
			parseInt(interval) <=0 || parseInt(interval) > 59 || delay_time.length <= 0 || isNaN(parseInt(delay_time)) ||
			parseInt(delay_time) <= 0 || isNaN(parseInt(ping_count)) || 
			parseInt(ping_count) <= 0 || (timeout_action == 'exec_custom' && va.validatePath(script))){
			$('#submit_btn').prop('disabled',true);
		}else{
			$('#submit_btn').prop('disabled',false);
		}
		Ha.setFooterPosition();
	}
})();