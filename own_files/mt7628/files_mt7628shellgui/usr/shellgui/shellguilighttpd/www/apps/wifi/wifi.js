(function(){
	//初始化页面
	var init_id = [];
	$('[name="nic-switch"]').each(function(){
		var id = $(this).prop('id').split('_').pop();
		init_id.push(id);
	});
	for(var i in init_id){
		if(!$('#switch_' + init_id[i]).prop('checked')){
			Ha.disableForm('wifi_set_' + init_id[i]);
			$('#ssid_item_' + init_id[i]).addClass('hidden');
			$('#switch_' + init_id[i]).parent().removeAttr('data-toggle');
			$('#wifi_set_' + init_id[i]).parent().css('border-bottom-width','0px');
		}
	}
	var init_ssid = [];
	$('[name="ssid-switch"]').each(function(){
	  var id = $(this).prop('id').replace('switch_','');
	  init_ssid.push(id);
	});
	for(var i in init_ssid){
	  if(!$('#switch_' + init_ssid[i]).prop('checked')){
	    Ha.disableForm('ssid_set_' + init_ssid[i]);
	    $('#switch_' + init_ssid[i]).parent().removeAttr('data-toggle');
	  }
	}
	var form5 = $('[data-form="5g_form"]').find('[name="channel"]').attr('data-channel');
	if(form5){
		resetChannel(true);
		$('[data-form="5g_form"]').find('[name="htmode"]').change(function(){
			resetChannel(false);
		});		
	}
	function resetChannel(init){
		var ht = $('[data-form="5g_form"]').find('[name="htmode"]').val();
		console.log(ht);
		var nic = $('[data-form="5g_form"]').find('[name="htmode"]').prop('id').replace('ht_','');
		var channels = {
			'HT20': [36,40,44,48,149,153,157,161,165],
			'HT40+': [36,40,44,48,52,56,60,64,100,104,108,112,116,120,124,128,132,136,149,153,157,161],
			'VHT80': [36,40,44,48,52,56,60,64,100,104,108,112,116,120,124,128,132,136,149,153,157,161]
		}
		var dom = getOptionsDom(channels[ht]);
		$('#channel_' + nic).empty().append(dom);
		if(init){
			var curVal = $('#channel_' + nic).attr('data-channel');
			$('#channel_' + nic).val(curVal);
		}

	}
	function getOptionsDom(arr){
		var dom = '';
		for(var i=0; i<arr.length; i++){
			dom += '<option value="' + arr[i] + '">' + arr[i] + '</option>'
		}
		return dom;
	}

	//key字段隐现
	$('[name="encryption"]').each(function(){
		var id = $(this).prop('id').replace('encryption_','');
		setKeyDisplay(true,id);
	});
	$('[name="encryption"]').change(function(){
		var id = $(this).prop('id').replace('encryption_','');
		setKeyDisplay(false,id);
	});
	
	function setKeyDisplay(init,id){
		if($('#encryption_' + id).val() != 'none'){
			$('#' + id + '_key').removeClass('hidden').removeClass('has-error');
			if(!init){
				$('#' + id + '_key').find('input').focus().val('');
			}
		}else{
			$('#' + id + '_key').addClass('hidden');
			$('#' + id + '_key').next('.help-block').addClass('hidden');
		}
		$('#' + id + '_key').find('.help-block').addClass('hidden');
		disableBtn('ssid_set_' + id);
		Ha.setFooterPosition();
	}

	//uci&ap 开关状态switch
	var switch_id,type,data;

	$('[name="nic-switch"],[name="ssid-switch"]').click(function(){
		var checked = $(this).prop('checked');
		var switchBtn = $(this).parent();
		switch_id = $(this).prop('id').split('_').pop();
		type = $(this).prop('name').split('-').shift();
		if(type == 'nic'){
			$('#modal_ensure_text').html(UI.Do_you_want_disable_this_nic);
			$('#modal_result_text').html(UI.This_will_disable_the_APs);
		}else{
			type = 'ap';
			$('#modal_ensure_text').html(UI.Do_you_want_disable_this_ap);
			$('#modal_result_text').html(UI.This_will_make_all_client_lost_connection);
		}
		data = 'app=wifi&action=disabled_' + type + '&' + type + '=' + switch_id + '&disabled=';
		//判断动作类型
		if(!checked){
			return false;
		}else{
			//开启
			var data_enable = data + 0;
			$.post('/',data_enable,Ha.showNotify,'json');

			if(type == 'nic'){
				setTimeout(function(){
					switchBtn.attr('data-toggle','modal');
				},5);
				Ha.reableForm('wifi_set_' + switch_id);
				$('#ssid_item_' + switch_id).removeClass('hidden');
				$('#wifi_set_' + switch_id).parent().css('border-bottom-width','3px');
			}else{
				Ha.reableForm('ssid_set_' + switch_id);
				setTimeout(function(){
					switchBtn.attr('data-toggle','modal');
				},5);
			}
		}
	});

	$('#disable_btn').click(function(){//关闭
		$('.switch-ctrl').find('#switch_' + switch_id).prop('checked',false);
		var data_disable = data + 1;
		$.post('/',data_disable,Ha.showNotify,'json');

		if(type == 'nic'){
			Ha.disableForm('wifi_set_' + switch_id);
			$('#ssid_item_' + switch_id).addClass('hidden');
			$('#switch_' + switch_id).parent().removeAttr('data-toggle');
			$('#wifi_set_' + switch_id).parent().css('border-bottom-width','0px');

		}else{
			Ha.disableForm('ssid_set_' + switch_id);
			$('#switch_ctrl_' + switch_id).removeAttr('data-toggle');
		}
	});

	//表单提交
	
    $('[name="wifi_set"]').submit(function(){
      var data = 'app=wifi&action=save_nic&' + $(this).serialize();
      var formId = $(this).prop('id');
      Ha.ajax('/','json',data,'post',formId,Ha.showNotify,1);
      return false;
    });

    $('[name="ssid_set"]').submit(function(){
    	var id = $(this).prop('id').replace('ssid_set_','');
    	var name = $.trim($(this).find('[name="ssid"]').val());
    	var encType = $(this).find('[name="encryption"]').val();
    	var key = $(this).find('[name="key"]').val();
    	if(name.length<2){
    		return false;
    	}else if(encType != 'none' && key.length < 8){
    		return false;
    	}else{
	      var formId = $(this).prop('id');
	      var id = formId.split('_').pop();
	      var data = 'app=wifi&action=save_ap&ap=' + id + '&' + $(this).serialize();
	      Ha.ajax('/','json',data,'post',formId,Ha.showNotify,1);
	      return false;
    	}
    });

    $('[name="ssid"]').bind('blur keyup',function(){
    	var target = $(this);
    	var condation = ($.trim($(this).val()).length < 2);
  		validateFuc(target,condation);
    });

    $('[name="key"]').bind('blur keyup',function(){
    	var target = $(this);
    	var condation = ($(this).val().length < 8);
    	validateFuc(target,condation);
    });
    
    function validateFuc(target,condation){
    	if(condation){
    		target.parent().parent().addClass('has-error');
  			target.next('.help-block').removeClass('hidden');
  		}else{
  			target.parent().parent().removeClass('has-error');
  			target.next('.help-block').addClass('hidden');
  		}
  		var id = target.prop('form').id;
  		disableBtn(id);
    }

    function disableBtn(id){
    	console.log(id);
    	var sum = 0;
    	$('#' + id).find('.help-block').each(function(){
    		if(!$(this).hasClass('hidden')){
    			sum += 1;
    		}
    	});
    	if(sum){
    		$('#' + id).find('button').prop('disabled',true);
    	}else{
    		$('#' + id).find('button').prop('disabled',false);
    	}
    }
})();