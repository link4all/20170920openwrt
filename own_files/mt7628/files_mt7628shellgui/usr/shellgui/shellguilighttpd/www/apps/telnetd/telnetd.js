(function(){
  $('#switch_telnetd').click(function(){
    var status = $('#switch_telnetd').prop('checked');
    if(status){
      $('#confirm-text').html(UI.switchOn);
    }else{
      $('#confirm-text').html(UI.switchOff);
    }
    return false;
  });
  setPortDisabled();
  function setPortDisabled(){
    var status = $('#switch_telnetd').prop('checked');
    if(status){
      $('[name="port"]').prop('disabled',false);
      $('#submit_port').prop('disabled',false);
    }else{
      $('[name="port"]').prop('disabled',true);
      $('#submit_port').prop('disabled',true);
    }
  }

  $('#confirm_switch').click(function(){
    var status = $('#switch_telnetd').prop('checked');
    if(status){
      $.post('/','app=telnetd&action=telnetd_switch&enabled=0',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_telnetd').prop('checked',false);
        setPortDisabled();
      },'json');
    }else{
      $.post('/','app=telnetd&action=telnetd_switch&enabled=1',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_telnetd').prop('checked',true);
        setPortDisabled();
      },'json');
    }
  });
  $('#use_port').submit(function(e){
    e.preventDefault();
    var port = $('[name="port"]').val();
    if(port.length <= 0){
      $('#port_container').addClass('has-error');
      $('.help-block').removeClass('hidden');
      return;
    }else{
      var data = "app=telnetd&action=use_port&"+$(this).serialize();
      Ha.disableForm('use_port');
      Ha.ajax('/','json',data,'post','use_port',Ha.showNotify,1);
    }
  });
  $('[name="port"]').bind('blur keyup',function(){
    var port = $('[name="port"]').val();
    if(port.length <= 0 || parseInt(port) <= 0 || parseInt(port) > 65535){
      $('#port_container').addClass('has-error');
      $('.help-block').removeClass('hidden');
      $('#submit_port').prop('disabled',true);
    }else{
      $('#port_container').removeClass('has-error');
      $('.help-block').addClass('hidden');
      $('#submit_port').prop('disabled',false);
    }
  });

})();