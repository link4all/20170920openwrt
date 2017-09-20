//设置上传页面
(function(){
	//定义三个大数据
	// var origin_data,rule_data,service_class_data,classes,default_class,total_bw,load,updateLoadInterval,ccstatus,target_ip,ping_limit;

	// var d=new Date();
	// var lasttime=d.getTime();

	initPage();
	updateLoadInterval = setInterval(function(){
    updateLoadData('down');
  },1000);

	// 提交整个修改
 	$('#page_submit').click(function(){
 		Ha.mask.show();
	    var data = {
	      app: 'qos-shellgui',
	      action: 'set_download',
	      rule_data: unmapRuleData(rule_data),
	      class_data: service_class_data,
        download_total_bandwidth: $('#total_bw').val(),
        download_default_class: $('#default_class').val(),
        pinglimit: ccstatus ? $('#ping_limit').val() : '',
        ptarget_ip: ccstatus ? $('#target_ip').val() : '',
        qos_monenabled: ccstatus
	    };
      var total_pct=0;
      for(var i=0; i<data.class_data.length; i++){
        total_pct += parseInt(data.class_data[i].percent)

      }
      if(total_pct != 100){
        Ha.mask.hide();
        Ha.showNotify({status:1,msg:UI.total_pct_warning});
        return;
      }
	  	clearInterval(updateLoadInterval);
    	$.post('/',data,function(data){
    		Ha.showNotify(data);
    		(function(){
    			Ha.mask.hide();
    		})()
    		initPage();
  			updateLoadInterval = setInterval(function(){
          updateLoadData('down');
        },1000);
    	},'json');
  	});

 	// 开启或关闭防火墙

	$('#page_switch').click(function(){
	    var checked = $(this).prop('checked');
	    if(!checked){
			$('input,button,select').prop('disabled',true);
			$('.gotop-widget').find('button').prop('disabled',false);
			total_bw = 0;
			$('#total_bw').val(total_bw);
  			$.post('/','app=qos-shellgui&action=total_bandwidth&up_down=download&total_bw=0',Ha.showNotify,'json');
  			clearInterval(updateLoadInterval);
	    }else{
		    $('input,button,select').prop('disabled',false);
		    total_bw = 3200;
			$('#total_bw').val(total_bw);
  			$.post('/','app=qos-shellgui&action=total_bandwidth&up_down=download&total_bw=3200',Ha.showNotify,'json');
  			makeClRoleDom(rule_data);
		    makeDefaultClass(classes,'down');
		    makeServiceClassDom(service_class_data);
		    updateLoadInterval = setInterval(function(){
          updateLoadData('down');
        },1000);
	    }
    	$('#page_switch').prop('disabled',false);
	});

	// 重置页面数据
	$('#page_reset').click(function(){
    $('.help-block').addClass('hidden');
    $('.has-error').removeClass('has-error');
    $('#page_submit').prop('disabled',false);
		initPage();
	});

  //开关CC
  $('#enable_cc').click(function(){
    if(ccstatus){
      disableCC();
    }else{
      enableCC();
    }
    ccstatus = !ccstatus;
  })


  //字段禁用和开启
  $('.has_switch').click(function(){
    var has_field = $(this).parent().find('.has_field').prop('checked');
    $(this).parent().find('.has_field').prop('checked',!has_field);
    var id = $(this).prop('for');
    $('#' + id).prop('disabled',has_field);
    var modalid = $('#' + id).prop('form').id.replace('_form','Modal');
    var type = $('#' + id).attr('data-validate');
    if(type){
      var callbc = va[type];
      switchInputError(has_field,id,callbc);
      disableApplyBtn(modalid);
    }
  });
  $('.has_field').change(function(){
    var has_field = $(this).prop('checked');
    var id = $(this).parent().find('.has_switch').prop('for');
    $('#' + id).prop('disabled',!has_field).focus();
    var modalid = $('#' + id).prop('form').id.replace('_form','Modal');
    var type = $('#' + id).attr('data-validate');
    if(type){
      var callbc = va[type];
      switchInputError(has_field,id,callbc);
      disableApplyBtn(modalid);
    }
  });

  function switchInputError(checked,id,callback){
    if(checked){
      $('#' + id).parent().parent().parent().removeClass('has-error');
      $('#' + id).parent().parent().parent().find('.help-block').addClass('hidden');
    }else{
      val = $('#' + id).val();
      validateFuc($('#' + id), callback(val));
    }
  }

  //添加rule
  $('#add_rule_btn').click(function(){
    $('#ruleModal').find('.modal-title').html(UI.Add_New_Classification_Rule);
    $('#ruleModal').find('.help-block').addClass('hidden');
    $('#ruleModal').find('.has-error').removeClass('has-error');
    $('#rule_form').prop('name','addRuleForm');
    resetForm('rule_form');
    $('#service_class_down').val(default_class);
    $('#submit_rule_btn').prop('disabled',false);
  });
  //提交rule添加或修改
  $('#submit_rule_btn').click(function(){
    var sum = 0;
    $('#ruleModal').find('.help-block').each(function(){
      if(!$(this).hasClass('hidden')){
        sum += 1;
      }
    });
    if(sum){
      $('#submit_rule_btn').prop('disabled',true);
      return false;
    }else{
      if($('#rule_form').prop('name') == 'addRuleForm'){
        addRule();
      }else{
        editRule();
      }
      $('#ruleModal').modal('hide');
    }
  });
  //添加class
  $('#add_class_btn').click(function(){
    $('#classModal').find('.modal-title').html(UI.Add_New_Service_Class);
    $('#classModal').find('.help-block').addClass('hidden');
    $('#classModal').find('.has-error').removeClass('has-error');
    $('#class_form').attr('data-name','addClassForm');
    resetForm('class_form');
    $('#class_form').find('[name="name"],[name="percent"],[name="minRTT"]').prop('disabled',false);
    $('#submit_class_btn').prop('disabled',true);
    $('#service_class_name').parent().parent().parent().addClass('has-error');
    $('#service_class_name').next('.help-block').removeClass('hidden');
    $('#percent_bandwidth').parent().parent().parent().addClass('has-error');
    $('#percent_bandwidth').parent().next('.help-block').removeClass('hidden');
    $('#rtt_no').prop('checked',true);
  });
  //提交class添加或编辑
  $('#submit_class_btn').click(function(){
    var sum = 0;
    $('#classModal').find('.help-block').each(function(){
      if(!$(this).hasClass('hidden')){
        sum += 1;
      }
    });
    if($('#service_class_name').val().length <= 0 || $('#percent_bandwidth').val().length <= 0){
      sum += 1;
    }
    if(sum){
      $('#submit_rule_btn').prop('disabled',true);
      return false;
    }else{
      if($('#class_form').attr('data-name') == 'addClassForm'){
        addSerClass();
      }else{
        editSerClass();
      }
      $('#classModal').modal('hide');
    }
  });

  //根据数据初始化clrole
  function makeClRoleDom(data){
    console.log(data);
    $('#cl_roles_container').empty();
    for(var i=0; i<data.length; i++){
      var roles = [];
      for(var role in data[i]){
        if(role != 'Set_Service_Class_To' && role != 'order'){
          var role_name = UI[role] ? UI[role] : role.replace(/_/g,' ');
          roles.push('<p>' + role_name + ': ' + data[i][role] + '</p>');
        }
      }
      roles.sort();
      var rolesDom = roles.join('');
      var class_name = getClassName(data[i]['Set_Service_Class_To'],classes);

      var roleDom = '<tr class="text-left" id="rule_num_' + data[i]['order'] + '">'
                  +   '<td>' + rolesDom + '</td>'
                  +   '<td>' + class_name + '</td>'
                  +   '<td><button class="btn btn-info btn-xs edit_rule_btn" data-data=\'' + JSON.stringify(data[i]) + '\' data-toggle="modal" data-target="#ruleModal">'+UI.Edit+'</button></td>'
                  +   '<td><button class="btn btn-danger btn-xs remove_rule_btn" data-order="order_' + data[i]["order"] + '">'+UI.Remove+'</button></td>'
                  +   '<td><button class="btn btn-info btn-xs move_up_btn" data-order="order_' + data[i]["order"] + '"><span class="glyphicon glyphicon-arrow-up"></span></button></td>'
                  +   '<td><button class="btn btn-info btn-xs move_down_btn" data-order="order_' + data[i]["order"] + '"><span class="glyphicon glyphicon-arrow-down"></span></button></td>'
                  + '</tr>';
      $('#cl_roles_container').append(roleDom);
    }
    //编辑
    $('.edit_rule_btn').click(function(){
      $('#ruleModal').find('.modal-title').html(UI.Edit_QoS_Classification_Rule);
      $('#ruleModal').find('.has-error').removeClass('has-error');
      $('#ruleModal').find('.help-block').addClass('hidden');
      $('#rule_form').prop('name','editRuleForm');
      $('#submit_rule_btn').prop('disabled',false);
      resetForm('rule_form');
      var data = $(this).attr('data-data');
      var data = JSON.parse(data);
      for(var key in data){
        var field = $('#rule_form').find('[name="' + key + '"]');
        field.prop('disabled',false);
        if(key != 'order'){
          field.parent().parent().parent().find('[type="checkbox"]').prop('checked',true);
        }
        if(field.prop('type') == 'text' || field.prop('type') == 'hidden'){
          field.val(data[key]);
        }else{
          field.find('option').prop('selected',false);
          field.find('[value="' + data[key] + '"]').prop('selected',true);
        }
      }
    });
    //删除
    $('.remove_rule_btn').click(function(){
      var id = $(this).attr('data-order').replace('order_','');
      rule_data = removeRule(id,rule_data);
      makeClRoleDom(rule_data);
    });
    //上移
    $('.move_up_btn').click(function(){
      var id = parseInt($(this).attr('data-order').replace('order_',''));
      rule_data = moveRuleUp(id,rule_data);
      makeClRoleDom(rule_data);
    });

    //下移
    $('.move_down_btn').click(function(){
      var id = parseInt($(this).attr('data-order').replace('order_',''));
      rule_data = moveRuleDown(id,rule_data);
      makeClRoleDom(rule_data);
    });
  }

  //根据数据初始化serviceClass
  function makeServiceClassDom(data){
    $('#service_class_container').empty();
    for(var j=0; j<data.length; j++){
      var min_bw,max_bw;
      if(!data[j].min_bw){
        min_bw = 'zero';
      }else{
        min_bw = data[j].min_bw;
      }
      if(!data[j].max_bw){
        max_bw = 'nolimit';
      }else{
        max_bw = data[j].max_bw;
      }
      var service_class_dom = '<tr class="text-left">'
                            +   '<td>' + data[j].name + '</td>'
                            +   '<td>' + data[j].percent + '%</td>'
                            +   '<td>' + min_bw + '</td>'
                            +   '<td>' + max_bw + '</td>'
                            +   '<td>' + data[j].minRTT + '</td>'
                            +   '<td class="load_container" data-class="' + data[j].class + '"></td>'
                            +   '<td><button class="btn btn-info btn-xs edit_class_btn" data-data=\'' + JSON.stringify(data[j]) + '\' data-toggle="modal" data-target="#classModal">'+UI.Edit+'</button></td>'
                            +   '<td><button class="btn btn-danger btn-xs remove_class_btn" data-name="' + data[j]['name'] + '">'+UI.Remove+'</button></td>'
                            + '</tr>';
      $('#service_class_container').append(service_class_dom);
    }
    $('.load_container').each(function(index){
    	var id = $(this).attr('data-class');
    	for(var i=0; i<load.bps.length; i++){
    		if(id-1 == i){
    			$(this).html(bpsToKbpsString(load.bps[id-1]))
    		}
    	}
    });
    $('.edit_class_btn').click(function(){
      $('#classModal').find('.modal-title').html(UI.Edit_QoS_Service_Class);
      $('#classModal').find('.help-block').addClass('hidden');
      $('#classModal').find('.has-error').removeClass('has-error');
      $('#class_form').attr('data-name','EditClassForm');
      $('#submit_class_btn').prop('disabled',false);
      resetForm('class_form');
      var data = $(this).attr('data-data');
      var data = JSON.parse(data);
      for(var key in data){
        var field = $('#class_form').find('[name="' + key + '"]');
        if(data[key]){
          field.val(data[key]);
          field.prop('disabled',false);
          field.parent().parent().parent().find('.has_field').prop('checked',true);
        }
        if(field.prop('type') == 'radio'){
          field.prop('disabled',false);
          if(data[key]){
            $('#rtt_yes').prop('checked',true);
            $('#rtt_no').prop('checked',false);
          }else{
            $('#rtt_yes').prop('checked',false);
            $('#rtt_no').prop('checked',true);
          }
        }
      }
    });
    //删除
    $('.remove_class_btn').click(function(){
      var id = $(this).attr('data-name');
      service_class_data = removeSerClass(id,service_class_data);
      makeServiceClassDom(service_class_data);
    });
  };
  
  function editRule(){
    var data = $('#rule_form').serializeArray();
    data = formatData(data);
    for(var i=0; i<rule_data.length; i++){
      if(rule_data[i]['order'] == data['order']){
        rule_data[i] = data;
      }
    }
    makeClRoleDom(rule_data);
  }

  function addRule(){
    var data = $('#rule_form').serializeArray();
    var format_data = formatData(data);
    format_data['order'] = rule_data.length + 1;
    rule_data.push(format_data);
    makeClRoleDom(rule_data);

    return false;
  };

  function addSerClass(){
    var data = $('#class_form').serializeArray();
    var rtt;
    $('#class_form').find('[type="radio"]').each(function(){
      if($(this).prop('checked')){
        rtt = $(this).attr('data-value');
      }
    });
    var format_data = formatData(data);
    if(!format_data['max_bw']){
      format_data['max_bw'] = 0;
    }
    if(!format_data['min_bw']){
      format_data['min_bw'] = 0;
    }
    format_data['minRTT'] = rtt || '';
    service_class_data.push(format_data);
    makeServiceClassDom(service_class_data);
    return false;
  }

  function editSerClass(){
    var data = $('#class_form').serializeArray();
    var rtt;
    $('#class_form').find('[type="radio"]').each(function(){
      if($(this).prop('checked')){
        rtt = $(this).attr('data-value');
      }
    });
    data = formatData(data);
    if(!data['max_bw']){
      data['max_bw'] = false;
    }
    if(!data['min_bw']){
      data['min_bw'] = false;
    }
    data['minRTT'] = rtt;
    for(var i=0; i<service_class_data.length; i++){
      if(service_class_data[i]['name'] === data['name']){
        var ori_class = service_class_data[i].class;
        service_class_data[i] = data;
        service_class_data[i].class = ori_class;
      }
    }
    makeServiceClassDom(service_class_data);
    return false;
  }

  function initPage(){
    $.post('/','app=qos-shellgui&action=get_qos_download',function(data){
      console.log();
      origin_data = data.rule_data;
      rule_data = mapRuleData(origin_data);
      service_class_data = data.class_data;
      load = initLoadPbs(service_class_data);
      classes = getClassId(service_class_data);
      default_class = data.download_default_class;
      total_bw = data.download_total_bandwidth;
      ccstatus = data.qos_monenabled == 'true';
      target_ip = data.ptarget_ip || '';
      ping_limit = data.pinglimit || '';
      makeClRoleDom(rule_data);
      makeDefaultClass(classes,'down');
      makeServiceClassDom(service_class_data);
      if(total_bw == 0){
        $('#page_switch').prop('checked',false);
          $('input,button,select').prop('disabled',true);
		  $('.gotop-widget').find('button').prop('disabled',false);
        $('#page_switch').prop('disabled',false);
        clearInterval(updateLoadInterval);
      }
      if(ccstatus){
        enableCC();
      }else{
        disableCC();
      }
      $('#default_class').find('option').each(function(){
        if($(this).val() == default_class){
          $(this).prop('selected',true);
        }else{
          $(this).prop('selected',false);
        }
      });
      $('#total_bw').val(total_bw);
    },'json');
  }

  function enableCC(){
    $('#enable_cc').prop('checked',true);
    $('#has_target_ip').prop('disabled',false);
    $('#has_ping_limit').prop('disabled',false);
    if(target_ip){
      $('#has_target_ip').prop('checked',true);
      $('#target_ip').prop('disabled',false).val(target_ip);
    }else{
      $('#has_target_ip').prop('checked',false);
      $('#target_ip').prop('disabled',true).val('');
    }
    if(ping_limit){
      $('#has_ping_limit').prop('checked',true);
      $('#ping_limit').prop('disabled',false).val(ping_limit);
    }else{
      $('#has_ping_limit').prop('checked',false);
      $('#ping_limit').prop('disabled',true).val('');
    }
    disablePageBtn();
  }

  function disableCC(){
    $('#enable_cc').prop('checked',false);
    $('#has_ping_limit').prop('checked',false).prop('disabled',true);
    $('#has_target_ip').prop('checked',false).prop('disabled',true);
    $('#congestion_control_form').find('.help-block').addClass('hidden');
    $('#congestion_control_form').find('.has-error').removeClass('has-error');
    $('#target_ip').prop('disabled',true).val(target_ip);
    $('#ping_limit').prop('disabled',true).val(ping_limit);
    disablePageBtn();
  }

  $('#target_ip_label').click(function(){
    ableTargetIP(false);
    disablePageBtn();
  });
  $('#has_target_ip').click(function(){
    ableTargetIP(true);
    disablePageBtn();
  });
  $('#ping_limit_label').click(function(){
    ablePingLimit(false);
    disablePageBtn();
  });
  $('#has_ping_limit').click(function(){
    ablePingLimit(true);
    disablePageBtn();
  })
  function ableTargetIP(isCheckbox){
    var ccChecked = $('#enable_cc').prop('checked');
    if(ccChecked){
      var checked;
      if(isCheckbox){
        checked = !$('#has_target_ip').prop('checked');
      }else{
        checked = $('#has_target_ip').prop('checked');
      }
      if(checked){
        $('#has_target_ip').prop('checked',false);
        $('#target_ip').prop('disabled',true).val(target_ip || '');
        $('#target_ip').next('.help-block').addClass('hidden');
        $('#target_ip').parent().parent().removeClass('has-error');
      }else{
        $('#has_target_ip').prop('checked',true);
        $('#target_ip').prop('disabled',false).focus().val(target_ip || '');
        if(!target_ip){
          $('#target_ip').parent().parent().addClass('has-error');
          $('#target_ip').next('.help-block').removeClass('hidden');
        }
      }
    }else{
      return false;
    }
  }

  function ablePingLimit(isCheckbox){
    var ccChecked = $('#enable_cc').prop('checked');
    if(ccChecked){
      var checked;
      if(isCheckbox){
        checked = !$('#has_ping_limit').prop('checked');
      }else{
        checked = $('#has_ping_limit').prop('checked');
      }
      if(checked){
        $('#has_ping_limit').prop('checked',false);
        $('#ping_limit').prop('disabled',true).val(ping_limit || '');
        $('#ping_limit').parent().next('.help-block').addClass('hidden');
        $('#ping_limit').parent().parent().removeClass('has-error');
      }else{
        $('#has_ping_limit').prop('checked',true);
        $('#ping_limit').prop('disabled',false).focus().val(ping_limit || '');
        if(!ping_limit){
          $('#ping_limit').parent().parent().addClass('has-error');
          $('#ping_limit').parent().next('.help-block').removeClass('hidden');
        }
      }
    }else{
      return false;
    }
  }

  $('[data-validate]').bind('blur keyup',function(){
    var type = $(this).attr('data-validate');
    var val =$(this).val();
    var callbc = va[type];
    validateFuc($(this),callbc(val));
    var id = $(this).prop('form').id.replace('_form','Modal');
    disableApplyBtn(id);
  });

  function validateFuc(target,condation){
    if(condation){
      target.parent().parent().parent().addClass('has-error');
      target.parent().parent().parent().find('.help-block').removeClass('hidden');
    }else{
      target.parent().parent().parent().removeClass('has-error');
      target.parent().parent().parent().find('.help-block').addClass('hidden');
    }
  }

  function disableApplyBtn(id){
    var sum = 0;
    $('#' + id).find('.help-block').each(function(){
      if(!$(this).hasClass('hidden')){
        sum += 1;
      }
    });
    if(sum){
      $('#' + id).find('[data-type="submit_btn"]').prop('disabled',true);
    }else{
      $('#' + id).find('[data-type="submit_btn"]').prop('disabled',false);
    }
  }

  $('#total_bw').bind('keyup blur',function(){
    var val = $(this).val();
    if(va.validateNum(val)){
      $(this).parent().parent().parent().addClass('has-error');
      $(this).parent().parent().parent().find('.help-block').removeClass('hidden');
    }else{
      $(this).parent().parent().parent().removeClass('has-error');
      $(this).parent().parent().parent().find('.help-block').addClass('hidden');
    }
    disablePageBtn();
  });

  $('#ping_limit').bind('keyup blur',function(){
    var val = $(this).val();
    if(validateNum(val)){
      $(this).parent().parent().addClass('has-error');
      $(this).parent().next('.help-block').removeClass('hidden');
    }else{
      $(this).parent().parent().removeClass('has-error');
      $(this).parent().next('.help-block').addClass('hidden');
    }
    disablePageBtn();
  });
  $('#target_ip').bind('keyup blur',function(){
    var val = $(this).val();
    if(validateIP(val)){
      $(this).parent().parent().addClass('has-error');
      $(this).next('.help-block').removeClass('hidden');
    }else{
      $(this).parent().parent().removeClass('has-error');
      $(this).next('.help-block').addClass('hidden');
    }
    disablePageBtn();
  });

  function disablePageBtn(){
    var sum = 0;
    $('#congestion_control_form').find('.help-block').each(function(){
      if(!$(this).hasClass('hidden')){
        sum += 1;
      }
    });
    if(!$('#total_bw_help').hasClass('hidden')){
      sum += 1;
    }
    if(sum){
      $('#page_submit').prop('disabled',true);
    }else{
      $('#page_submit').prop('disabled',false);
    }
  }
})();