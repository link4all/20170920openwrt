var askStatus = function(){

    $.get('/','app=status&action=hw_status',function(data){
        Ha.mask.hide();
        //time
        var time = data.uptime.days + '&nbsp;'+UI.Days+'&nbsp;' 
                 + data.uptime.hours + '&nbsp;'+UI.hours+'&nbsp;' 
                 + data.uptime.mins + '&nbsp;'+UI.mins+'&nbsp;' 
                 + data.uptime.secs + '&nbsp;'+UI.secs+'&nbsp;';
        $('#running-time').html(time);

        //cpu
        for(var key in data.cpu){
            var cpu_item = '<div class="col-xs-12 col-sm-6 col-md-3 cpu-status">' 
                         +  '<div class="media">' 
                         +      '<div class="media-left">'
                         +          '<span class="circle"></span>'
                         +      '</div>'
                         +      '<div class="media-body">'
                         +          '<h4 class="media-heading">'
                         +              '<span id="cpu-name">' + key + '</span>'
                         +              ':'
                         +              '<span id="cpu-useage">&nbsp;&nbsp;' + data.cpu[key] + '</span>'
                         +          '</h4>'
                         +      '</div>'
                         +  '</div>'
                         +'</div>';
            $('#cpu-container').empty();
            $(cpu_item).appendTo('#cpu-container');
        }
        //mem
        $('#mem-usage').html(data.mem.usage);
        $('#mem-total').html(data.mem.total);
        $('#mem-used').html(data.mem.used);
        //swap
        $('#swap-usage').html(data.swap.usage);
        $('#swap-total').html(data.swap.total);
        $('#swap-used').html(data.swap.used);

    },'json');


    $.get('/','app=status&action=bw_status',function(data){
        var eths = [];
        for(var key in data){
            eths.push(key);
        }
        eths = eths.sort();
        
        

        $('#eths-container').empty();

        for(var i=0; i<eths.length; i++){
            var eth_ip,
                eth_status,
                eth_circle_class,
                progress_id;
            if(data[eths[i]].ip === 'null'){
                eth_ip = '';
            }else{
                eth_ip = '(' + data[eths[i]].ip + ')';
            }

            if(data[eths[i]].up){
                eth_status = UI.Inused;
                eth_circle_class = '';
            }else{
                eth_status = UI.Standby;
                eth_circle_class = ' nouse';
            }

            if(eths[i].indexOf(".") > 0){
                progress_id = eths[i].replace('.','_');
            }else{
                progress_id = eths[i];
            }


            var eth_item = '<div class="row net-status-item">'
                         +  '<div class="media col-md-4 col-sm-6">'
                         +      '<div class="media-left">'
                         +          '<span class="circle' + eth_circle_class +'"></span>'
                         +      '</div>'
                         +      '<div class="media-body">'
                         +          '<h4 class="media-heading">'+ eths[i] + eth_ip + '</h4>'
                         +          '<p>' + eth_status + '</p>'
                         +      '</div>'
                         +  '</div>'
                         +  '<div class="col-md-4 col-sm-6">'
                         +      '<div class="row cpu-progress">'
                         +          '<span class=""></span>'
                         +          '<span class="cpu-progress-bar" id="' + progress_id + '_progress_pct"></span>'
                         +          '<div class="cpu-progress-text col-xs-offset-3 col-xs-9">' + data[eths[i]].bw + ' ' + UI.Bandwidth_used + ': ' + data[eths[i]].s_pct + '</div>'
                         +      '</div>'
                         +  '</div>'
                         +  '<div class="col-md-4 col-sm-12">'
                         +      '<div class="row">'
                         +          '<div class="col-xs-6"><span class="glyphicon glyphicon-arrow-up"></span>&nbsp;<span class="">' + data[eths[i]].s_tx + ' - ' + data[eths[i]].t_tx + '</span></div>'
                         +          '<div class="col-xs-6"><span class="glyphicon glyphicon-arrow-down"></span>&nbsp;<span class="">' + data[eths[i]].s_rx + ' - ' + data[eths[i]].t_rx + '</span></div>'
                         +      '</div>'
                         +  '</div>'
                         + '</div>';
           
            $(eth_item).appendTo('#eths-container');

            $('#' + progress_id + '_progress_pct').css('width',data[eths[i]].s_pct);
            var use_pct = parseInt(data[eths[i]].s_pct);
            if(use_pct > 70){
                $('#' + progress_id + '_progress_pct').css('background-color','red');
            }
            
            Ha.setFooterPosition();
        }
        var height_holder = $('body').height();
        $('body').css('height',height_holder);
    },'json');
}


  $('#bw_set').submit(function(){
    var sum = disableBtn();
    if(sum){

    }else{
      var post_data = $(this).serialize();
      post_data = 'app=status&action=bw_set&' + post_data;
      // $.post('/',post_data,function(data){
      //   Ha.showNotify(data);
      // },'josn');
      Ha.ajax('/','json',post_data,'post');
    }
    return false;
  });

  $('[data-validate="num"]').bind('keyup blur',function(){
    var val = $(this).val();
    if(va.validateNum(val)){
      $(this).parent().parent().parent().addClass('has-error');
      $(this).parent().next('.help-block').removeClass('hidden');
    }else{
      $(this).parent().parent().parent().removeClass('has-error');
      $(this).parent().next('.help-block').addClass('hidden');
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
  