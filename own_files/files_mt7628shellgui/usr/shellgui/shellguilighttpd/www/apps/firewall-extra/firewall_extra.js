  $('#set_firewall').submit(function(e){
    e.preventDefault();
    if(disableBtn()){
      return false;
    }else{
      var data = "app=firewall-extra&action=set_firewall&"+$(this).serialize();
      Ha.disableForm('set_firewall');
      Ha.ajax('/','json',data,'post','set_firewall',Ha.showNotify,1);
    }
  });
  $('#reload_geoip').submit(function(e){
    e.preventDefault();
    var data = "app=firewall-extra&action=reload_geoip";
    Ha.disableForm('reload_geoip');
    Ha.ajax('/','json',data,'post','reload_geoip',Ha.showNotify,1);
  });

(function(){
  $('#upload-geoip').change(function(){
    $('#submit_file_btn').one('click',function(){
      $('#uploader').submit();
    });
    var file = $(this).val();
    var file_name = file.split('\\').pop();
    $('#file_name').html(file_name);
    var filles = $(this).get(0).files[0];
    if (filles) {
      $('#file_info').removeClass('hidden');
      var fileSize = 0;
      if (filles.size > 1024 * 1024)
        fileSize = (Math.round(filles.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
      else
        fileSize = (Math.round(filles.size * 100 / 1024) / 100).toString() + 'KB';

      // $('#file_name').html(filles.name || '');
      $('#file_size').html(fileSize || '');
      $('#file_type').html(filles.type || '');
    }
  });

  $('#uploader').submit(function(){
    uploadFile('upload-geoip','/apps/firewall-extra/upload.cgi');
    setProgressLength();
    $('#submit_file_btn').click(function(){
      return false;
    });
    //return false;
  });
  function setProgressLength(){
    var length = $('#file_name').width();
    if(length < 208){
      length = 208;
    }
    $('.upload-progress-bar').css('width',length).removeClass('hidden');
  }
})();

$('#switch_syn_flood_radio0').click(function(){//switch开关示例，在类为switch-ctrl的div上调用
  var checked = $(this).find('[type="checkbox"]').prop('checked');
  var text = checked ? UI.switchOff_syn_flood : UI.switchOn_syn_flood;
	Ha.alterModal('confirmModal',UI.switch_syn_flood,text,submitModal,'switch_syn_flood_radio0');//参数一定要传入上面的id
});

function submitModal(switchId){//主要处理确认后的动作，每个按键可能都不同，参数一定要有
  var status = $('#' + switchId).find('[type="checkbox"]').prop('checked');
	$.post('/','app=firewall-extra&action=enabled_syn_flood&var=' + (status ? 0 : 1)+'&syn_flood_cfg='+UI.syn_flood_cfg,function(data){
		Ha.showNotify(data);
  	var result = data.status == 1 ? false : true;
  	var checked = status;
	  Ha.setSwitchBtn(switchId,result,checked);
	},'json');
}

$('#switch_geoipupdate_radio0').click(function(){
  var checked = $(this).find('[type="checkbox"]').prop('checked');
  var text = checked ? UI.switchOff_geoip : UI.switchOn_geoip;
Ha.alterModal('confirmModal',UI.switch_geoip,text,callbackFun,'switch_geoipupdate_radio0');
});
function callbackFun(switchId){
  var status = $('#' + switchId).find('[type="checkbox"]').prop('checked');
  var post_data = 'app=firewall-extra&action=' + (status ? 'disable' : 'enable') + '_geoip_update'
  $.post('/', post_data, function(data) {
      Ha.showNotify(data);
      var result = data.status == 1 ? false : true;
      var checked = status;
      Ha.setSwitchBtn(switchId,result,checked);
  }, 'json');
}

$('#allow_tcp_ports,#allow_udp_ports,#allow_tcpudp_ports').bind('blur keyup',function(){
  var val = $(this).val();
  if(validateMuliPorts(val)){
    $(this).parent().parent().addClass('has-error');
    $(this).next('.help-block').removeClass('hidden');
  }else{
    $(this).parent().parent().removeClass('has-error');
    $(this).next('.help-block').addClass('hidden');
  }
  disableBtn();
});

function disableBtn(){
  var sum = 0;
  $('.help-block').each(function(){
    if(!$(this).hasClass('hidden')){
      sum += 1;
    }
  });
  if(sum){
    $('#submit_btn').prop('disabled',true);
  }else{
    $('#submit_btn').prop('disabled',false);
  }
  return sum;
}

function validateMuliPorts(str){
  var errorCode = 0; 
  if(str.length<=0){
    errorCode = 0;
  }else{
    var arr = str.split(',');
    for(var i=0; i<arr.length; i++){
      if(arr[i].indexOf('-')>0){
        var range = arr[i].split('-');
        if(range.length>2){
          errorCode = 1;
        }else{
          if(va.validatePort(range[0]) || va.validatePort(range[1])){
            errorCode = 1;
          }else if(parseInt(range[0]) >= parseInt(range[1])){
            errorCode = 1;
          }
        }
      }else{
        errorCode = va.validatePort(arr[i]);
      }
    }
  }
  return errorCode;
}