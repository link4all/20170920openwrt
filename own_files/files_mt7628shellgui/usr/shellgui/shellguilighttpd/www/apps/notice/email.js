$('#doemail_main_setting').submit(function(e){
  e.preventDefault();
  var sum = 0;
  $(this).find('.help-block').each(function(){
    if(!$(this).hasClass('hidden')){
      sum += 1;
    }
  });
  if(sum){
    return false;
  }else{
    var data = "app=notice&action=doemail_main_setting&" + $(this).serialize();
    $.post('/',data,Ha.showNotify,'json');
  }
});
$('#email_extra_setting').submit(function(e){
  e.preventDefault();
  var sum = 0;
  $(this).find('.help-block').each(function(){
    if(!$(this).hasClass('hidden')){
      sum += 1;
    }
  });
  if(sum){
    return false;
  }else{
    var data = "app=notice&action=email_extra_setting&" + $(this).serialize();
    $.post('/',data,Ha.showNotify,'json');
  }

});
$('#email_test').submit(function(e){
  e.preventDefault();
   var sum = 0;
  $(this).find('.help-block').each(function(){
    if(!$(this).hasClass('hidden')){
      sum += 1;
    }
  });
  if(sum){
    return false;
  }else{
    var data = "app=notice&action=email_test&" + $(this).serialize();
    $.post('/',data,Ha.showNotify,'json');
  }
});

function validateFuc(target,condation,id){
  if(condation){
    target.parent().parent().addClass('has-error');
    target.next('.help-block').removeClass('hidden');
  }else{
    target.parent().parent().removeClass('has-error');
    target.next('.help-block').addClass('hidden');
  }
  disableBtn(id);
}

$('input').each(function(){
  var required = $(this).prop('required');
  var id = $(this).prop('id');
  var formid = $(this).prop('form').id;
  var type = $(this).prop('type');
  if(required){
    if(id !== 'TIMEOUT'){
      $(this).bind('keyup blur',function(){
        var val = $.trim($(this).val());
        validateFuc($(this),val.length <= 0,formid);
      });
    }else{
      $(this).bind('keyup blur',function(){
        var val = $.trim($(this).val());
        validateFuc($(this).parent(),val.length <= 0 || isNaN(parseInt(val)) || parseInt(val) <= 0,formid);
      });
    }
    if(type == 'email'){
      $(this).bind('keyup blur',function(){
        var val = $.trim($(this).val());
        validateFuc($(this),validateEmail(val),formid);
      });
    }
  }else{
    if(type == 'email'){
      $(this).bind('keyup blur',function(){
        var val = $(this).val();
        if(val.length > 0 && validateEmail(val)){
          $(this).parent().parent().addClass('has-error');
          $(this).next('.help-block').removeClass('hidden');
        }else if(val.length <= 0 || !validateEmail(val)){
          $(this).parent().parent().removeClass('has-error');
          $(this).next('.help-block').addClass('hidden');
        }
  disableBtn(id);
      });
    }
  }

  if(id == 'SMTP_PORT'){
    $(this).bind('keyup blur',function(){
      var val = $.trim($(this).val());
      validateFuc($(this),validatePort(val),formid);
    });
  }
});

$('textarea').each(function(){
  $(this).bind('blur keyup',function(){
    var formid = $(this).prop('form').id;
    var val = $.trim($(this).val());
    validateFuc($(this),val.length <= 0,formid);
  });
});

function disableBtn(id){
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