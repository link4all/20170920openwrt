(function(){
	$('[name="netmask"]').change(function(){
		var form = $($(this).prop('form'));
		resetLan(form);
	});
	$('[name="ip"]').keyup(function(){
		var form = $($(this).prop('form'));
		var ip = $(this).val();
		var error = validateIP(ip);
		if(error){
			$(this).parent().parent().addClass('has-error');
			$(this).next('.help-block').removeClass('hidden');
			$(this).parent().parent().parent().find('[type="button"]').prop('disabled',true);
		}else{
			resetLan(form);
			$(this).parent().parent().removeClass('has-error');
			$(this).next('.help-block').addClass('hidden');
			$(this).parent().parent().parent().find('[type="button"]').prop('disabled',false);
		}
		Ha.setFooterPosition();
	});

	$('[name="start"]').bind('keyup blur',function(){
		var start = $(this).val();
		validateFuc((start.length<=0 || isNaN(parseInt(start)) || parseInt(start) <= 0 || parseInt(start) >=255),$(this).parent().parent().parent(),$(this).parent().next('.help-block'));
		var id = $(this).prop('id').replace('startip_','');
		disableBtn(id);
		Ha.setFooterPosition();
	});
	$('[name="limit"]').bind('keyup blur',function(){
		var max = $(this).val();
		validateFuc((max.length<=0 || isNaN(parseInt(max)) || parseInt(max) <= 0),$(this).parent().parent().parent(),$(this).parent().next('.help-block'))
		var id = $(this).prop('id').replace('allow_','');
		disableBtn(id);
		Ha.setFooterPosition();
	});
	$('[name="leasetime"]').bind('keyup blur',function(){
		var time = $(this).val();
		validateFuc((time.length<=0 || isNaN(parseInt(time)) || parseInt(time) <= 0),$(this).parent().parent(),$(this).next('.help-block'));
		var id = $(this).prop('id').replace('time_','');
		disableBtn(id);
		Ha.setFooterPosition();
	});
	function validateFuc(condation,errorCon,helpCon){
		if(condation){
			errorCon.addClass('has-error');
			helpCon.removeClass('hidden');
		}else{
			errorCon.removeClass('has-error');
			helpCon.addClass('hidden');
		}
	}
	function disableBtn(id){
		var sum=0;
		$('#dhcp_' + id).find('.help-block').each(function(){
			if(!$(this).hasClass('hidden')){
				sum = sum+1;
			}
		});
		if(sum){
			$('#submitbtn_' + id).prop('disabled',true);
		}else{
			$('#submitbtn_' + id).prop('disabled',false);
		}
	}

	$('[data-target="#confirmModal"]').click(function(){
		var lan = $(this).attr('data-order');
		$('#confirm_submit').attr('data-order',lan);
	});

	$('#confirm_submit').click(function(){
	//$('[name="lan_ip_mask"]').submit(function(){
		var id = $(this).attr('data-order');
		var form = $('#lan_ip_mask_' + id);
		var data = 'app=lan&action=lan_ip_mask&lan=' + id + '&' + form.serialize();
		var formId = form.prop('id');
		Ha.ajax('/','json',data,'post',formId,setLanMaskMsg,1);
	});

	$('[name="switch-lan"]').click(function(){
		var switchon = $(this).prop('checked');
		var id = $(this).attr('data-order');
		var formId = 'dhcp_' + id;
		if(!switchon){
			Ha.disableForm(formId);
			var data = 'app=lan&action=dhcp_server_switch&lanzone=' + id + '&enabled=' + 0;
			Ha.ajax('/','json',data,'post','',Ha.showNotify,1);
		}else{
			Ha.reableForm(formId);
			var data = 'app=lan&action=dhcp_server_switch&lanzone=' + id + '&enabled=' + 1;
			Ha.ajax('/','json',data,'post','',Ha.showNotify,1);
		}
	});
	$('[name="lan_ip_mask"]').submit(function(){
		return false;
	})
	$('[name="dhcp"]').submit(function(){
		var form = $(this);
		var lan = form.attr('data-order');
		var data = "app=lan&action=lan_dhcp_mask&lan=" + lan + "&" + form.serialize();
		var start = form.find('[name="start"]').val();
		var max = form.find('[name="limit"]').val();
		var time = form.find('[name="leasetime"]').val();
		if(time.length<=0 || isNaN(parseInt(time)) || parseInt(time) <= 0 || start.length<=0 || isNaN(parseInt(start)) || parseInt(start) <= 0 || parseInt(start) >=255 || max.length<=0 || isNaN(parseInt(max)) || parseInt(max) <= 0){
			return false;
		}else{
			Ha.ajax('/','json',data,'post',form.prop('id'),Ha.showNotify,1)
			return false;
		}

	});

	function resetLan(form){
		var lan = form.attr('data-order');
		var data = 'app=lan&action=ip_mask_tip&lan=' + lan + '&' + form.serialize();
		console.log(data);
		var formId = form.prop('id');
		$.post('/',data,function(data){
			Ha.reableForm('dhcp_' + lan);
			var form = $('#dhcp_' + lan);
			form.find('[name="start_ip_prefix"]').html(data.start_ip_prefix);
			form.find('[name="end_ip"]').val(data.end_ip);
			form.find('[name="max_ips"]').html(data.max_ips);
			if(data.status == 1){
				Ha.showNotify(data);
				Ha.disableForm('dhcp_' + lan);
			}
		},'json');
		return false;
	}

	function setLanMaskMsg(data){
		Ha.showNotify(data);
		if(data && data.status == 0){
			var id = $('#' + id).attr('data-order');
			var form = $('#dhcp_' + id);
			form.find('[name="start_ip_prefix"]').html(data.start_ip_prefix);
			form.find('[name="end_ip"]').val(data.end_ip);
			form.find('[name="max_ips"]').html(data.max_ips);
		}
	}

})();