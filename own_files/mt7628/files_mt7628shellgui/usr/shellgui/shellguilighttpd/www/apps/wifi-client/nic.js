(function(){
  Ha.mask.show();
  var id = $('#stas_container').attr('data-dev');
  getStas(id);

  $('#refresh').click(function(){
    getStas(id);
  });

  function getStas(id){
    Ha.mask.show();

    $.post('/','app=wifi-client&action=get_nics_scan&dev=' + id,function(data){
      if(data.status){
        Ha.showNotify(data);
      }
      $('#sta_container').empty();
      var lastone = false;
      if(data.length === 0){
        var none_dom = "<tr><td><h3>"+UI.There_is_no_AP_avaible+"</h3></td></tr>";
        $('#sta_container').append(none_dom);
        Ha.mask.hide();
      }
      for(var i=0; i<data.length; i++){
        var ssid = data[i].ssid;
        var prt = data[i].sig_p;
        ssid = ssid.replace(/[^0-9a-zA-Z_\-]/g,'');

        var sta_item_dom =  '<tr id="sta-item-' + ssid + '">'
                         +    '<td class="row">'
                         +      '<div class="media col-sm-8">'
                         +        '<div class="media-left">'
                         +          '<div class="rssi-icon">'
                         +            '<span></span><span></span><span></span><span></span>'
                         +          '</div>'
                         +          '<span class="rssi-text"></span>'
                         +        '</div>'
                         +        '<div class="media-body row wireless-content">'
                         +          '<h4 class="media-heading col-xs-12">' + data[i].ssid + '</h4>'
                         +          '<p class="col-xs-12 col-sm-6 col-md-4">Channel:&nbsp;' + data[i].channel + '</p>'
                         +          '<p class="col-xs-12 col-sm-6 col-md-4">BSSID:&nbsp;' + data[i].bssid + '</p>'
                         +          '<p class="col-xs-12 col-sm-12 col-md-4">Encryption:&nbsp;' + data[i].enc + '</p>'
                         +        '</div>'
                         +      '</div>'
                         +      '<div class="col-sm-4">'
                         +        '<div class="hidden join_form" id="join_form_' + ssid + '_' + i + '">'
                         +          '<div class="form-group" id="password_input_' + i + '">'
                         +            '<input type="password" class="form-control" id="password_' + ssid + '_' + i + '" placeholder="'+UI.Enter_the_password_here+'">'
                         +          '</div>'
                         +          '<div class="row">'
                         +            '<div class="col-xs-6">'
                         +              '<button type="submit" class="btn btn-default btn-block submit_join" id="submit_join_' + ssid + '_' + i + '">'+UI.Save+'</button>'
                         +            '</div>'
                         +            '<div class="col-xs-6">'
                         +              '<button class="btn btn-warning btn-block cancle_join" id="cancle_join_' + ssid + '_' + i + '">'+UI.Cancel+'</button>'
                         +            '</div>'
                         +          '</div>'
                         +        '</div>'
                         +       '<div class=" pull-right"><button class="btn btn-success join_btn" id="join_btn_' + ssid + '_' + i + '"><span class="glyphicon glyphicon-plus"></span>&nbsp;&nbsp;&nbsp;&nbsp;'+UI.Join+'</button></div>'
                         +      '</div>'
                         +    '</td>'
                         +  '</tr>'
        $('#sta_container').append(sta_item_dom);
        if(i == data.length-1){
          lastone = true;
        }
        if(data[i].enc == 'none'){
          $('#password_input_' + i).addClass('hidden');
        }
        Ha.setRssiIcon(ssid,prt);

      }

      $('.join_btn').click(function(){
        var id = $(this).prop('id').replace('join_btn_','');
        $('.join_btn').removeClass('hidden');
        $(this).addClass('hidden');
        $('.join_form').addClass('hidden');
        $('#join_form_' + id).removeClass('hidden');
      });

      $('.cancle_join').click(function(){
        var id = $(this).prop('id').replace('cancle_join_','');
        $('#join_btn_' + id).removeClass('hidden');
        $('.join_form').addClass('hidden');
      });

      $('.submit_join').click(function(){
        var index = $(this).prop('id').split('_').pop();
        var indi = $(this).prop('id').replace('submit_join_','');
        var key = $('#password_' + indi).val();
        var formdata = {
          action: 'set_sta',
          app: 'wifi-client',
          dev: id,
          ssid: data[index].ssid,
          channel: data[index].channel,
          bssid: data[index].bssid,
          key: key,
          enc: data[index].enc
        };
        $('#password_' + indi).prop('disabled','disabled');
        $('.btn').prop('disabled','disabled');
        Ha.ajax('/','json',formdata,'post','',function(data){
          if(data.status){
            $('#password_' + indi).prop('disabled',false);
            $('.btn').prop('disabled',false);
          }
        });
      });

      (function(){
        Ha.setFooterPosition();
        var checkLast = setInterval(function(){
          if(lastone){
            Ha.mask.hide();
            clearInterval(checkLast);
          }
        },500);
      })();
    },'json');
  }
})();