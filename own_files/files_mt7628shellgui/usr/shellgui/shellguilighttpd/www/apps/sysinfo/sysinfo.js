$('#hostname_edit').submit(function(e){
  e.preventDefault();
  if($.trim($('#hostname').val()).length <= 0){
  	return;
  }else{
	  var data = "app=sysinfo&action=hostname_edit&" + $(this).serialize();
	  $.post('/',data,Ha.showNotify,'json');
  }
});
$('#timezone_edit').submit(function(e){
  e.preventDefault();
	var sum = 0;
	$('#timezone_edit').find('.help-block').each(function(){
		if(!$(this).hasClass('hidden')){
			sum += 1;
		}
	});
	if(sum){
		return;		
	}else{
	  var data = "app=sysinfo&action=timezone_edit&" + $(this).serialize();
	  $.post('/',data,Ha.showNotify,'json');
	}
});

$('#hostname').bind('blur keyup',function(){
	var val = $.trim($(this).val());
	if(val.length <= 0 || va.validateHostName(val)){
		$(this).parent().parent().addClass('has-error');
		$(this).parent().parent().find('.help-block').removeClass('hidden');
		$('#submit_hostname').prop('disabled',true);
	}else{
		$(this).parent().parent().removeClass('has-error');
		$(this).parent().parent().find('.help-block').addClass('hidden');
		$('#submit_hostname').prop('disabled',false);
	}
});

$('#web_ctl_port').bind('blur keyup',function(){
	var val = $(this).val();
	if(va.validatePort(val)){
		$(this).parent().parent().addClass('has-error');
		$(this).next('.help-block').removeClass('hidden');
	}else{
		$(this).parent().parent().removeClass('has-error');
		$(this).next('.help-block').addClass('hidden');
	}
	disableBtn();
});

$('.timezone_host_input').bind('blur keyup',function(){
	var val = $.trim($(this).val());
	if(val.length > 0 && va.validateDomain(val)){
		$(this).parent().addClass('has-error');
		$(this).parent().find('.help-block').removeClass('hidden');
	}else if(val.length <= 0 || !va.validateDomain(val)){
		$(this).parent().removeClass('has-error');
		$(this).parent().find('.help-block').addClass('hidden');
	}
	disableBtn();
});
$('.timezone_host_input:first').bind('blur keyup',function(){
	var val = $.trim($(this).val());
	if(val.length <= 0 || va.validateDomain(val)){
		$(this).parent().addClass('has-error');
		$(this).parent().find('.help-block').removeClass('hidden');
	}else{
		$(this).parent().removeClass('has-error');
		$(this).parent().find('.help-block').addClass('hidden');
	}
	disableBtn();
});

function disableBtn(){
	var sum = 0;
	$('#timezone_edit').find('.help-block').each(function(){
		if(!$(this).hasClass('hidden')){
			sum += 1;
		}
	});
	if(sum){
		$('#submit_timezone_btn').prop('disabled',true);
	}else{
		$('#submit_timezone_btn').prop('disabled',false);
	}
}