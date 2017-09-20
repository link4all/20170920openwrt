(function(){
  Ha.mask.show();

  var nic_items = [];
  Ha.ajax('/','json','app=wifi-client&action=get_nics_sta','post','',function(data){

    $('#nic_container').empty();
    for(nic in data){
      for(nic_item in data[nic]){
          var nic_title = data[nic][nic_item];
          var nic_status;
          nic_items.push(nic_item);
          if(!data[nic][nic_item].disabled){
            nic_status = UI.Available;
          }else{
            nic_status = UI.Unailable;
          }
        var nic_item_dom = '<div class="row nic_item" id="nic_item_' + nic_item + '">'
                         +    '<div class="col-sm-12" style="margin-bottom: 10px">'
                         +      '<h2 class="app-sub-title">' + nic_item + '<small>(' + nic_status + ')</small></h2>'
                         +      '<span>'+UI.Wireless_Channel+':&nbsp;&nbsp;' + data[nic][nic_item].channel + '</span>&nbsp;&nbsp;|&nbsp;&nbsp;'
                         +      '<span>'+UI.Hardware_Mode+':&nbsp;&nbsp;' + data[nic][nic_item].hwmode + '</span>'
                         +      '<div class="pull-right">'
                         +        '<a href="/?app=wifi-client&action=dev_scan&dev=' + nic_item + '"><button class="btn btn-default btn-sm">'+UI.Scan+'</button></a>'
                         +      '</div>'
                         +    '</div>'
                         + '</div>';
        $('#nic_container').append(nic_item_dom);
        var sta,sta_dom;
        if(data[nic][nic_item].sta){
          sta = data[nic][nic_item].sta;
        
          var ssid = sta.ssid;
          var prt = sta.sig_p;

          ssid = ssid.replace(/[^0-9a-zA-Z_\-]/g,'');

          sta_dom = '<div class="media col-sm-10 media_' + nic_item + '" id="sta-item-' + ssid + '">'
                  +   '<div class="media-left">'
                  +     '<div class="rssi-icon">'
                  +       '<span></span><span></span><span></span><span></span>'
                  +     '</div>'
                  +     '<span class="rssi-text"></span>'
                  +   '</div>'
                  +   '<div class="media-body row wireless-content">'
                  +     '<h4 class="media-heading col-xs-12">' + sta.ssid + '</h4>'
                  +     '<p class="col-xs-12 col-sm-4">BSSID:&nbsp;' + sta.bssid + '</p>'
                  +     '<p class="col-xs-12 col-sm-4">Encryption:&nbsp;' + sta.enc + '</p>'
                  +   '</div>'
                  + '</div>'
                  + '<div class="pull-right" id="disable_btn_' + nic_item + '">'
                  +   '<button class="btn btn-danger btn-sm disable_ssid_btn" id="disable_ssid_' + nic_item + '">'+UI.Drop+'</button>'
                  + '</div><hr class="col-sm-12">';

        }else{
          sta_dom = '<div>'+UI.There_is_no_AP_avaible+'</div><hr>';
        }
        $('#nic_container').append(sta_dom);

        Ha.setRssiIcon(ssid,prt);

      }
    }
    $('.disable_ssid_btn').click(function(){
      var id = $(this).prop('id').replace('disable_ssid_','');
      $.post('/','app=wifi-client&action=drop_client&dev=' + id,function(data){
        Ha.showNotify(data);
        $('.media_' + id).addClass('hidden');
        $('#disable_btn_' + id).addClass('hidden');
        $('#nic_item_' + id).after('<div>'+UI.There_is_no_AP_avaible+'</div>');
      },'json');
    });
    Ha.mask.hide();
	Ha.setFooterPosition();
  },1);
})();