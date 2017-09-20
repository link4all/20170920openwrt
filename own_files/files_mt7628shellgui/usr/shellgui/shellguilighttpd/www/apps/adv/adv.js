(function(){
    init();

    //upnp状态切换
    var upnp_status;
    setInterval(function(){
        if(upnp_status){
            initUpnp();
        }
    },10000);
    $('#upnp_switch').click(function(){
        if(upnp_status){//开启时点击，关闭
            $('#close_upnp_text').removeClass('hidden');
            switchUpnpStatus(0);//////////////////////返回数据是否该调用一下notify
            $(this).prop('disabled',true);
            setTimeout(initUpnp,1000);
        }else{//关闭时点击，开启
            $('#open_upnp_text').removeClass('hidden');
            switchUpnpStatus(1);
            $(this).prop('disabled',true);
            setTimeout(initUpnp,1000);
        }
    }); 

    //dmz状态切换
    var dmz_status;
    $('#dmz_switch').click(function(){
        if(!dmz_status){//已开启
            $('#dmz_help_text').addClass('hidden');
            $('#dmz_form_container').removeClass('hidden');
            dmz_status = !dmz_status;
            $('#dmz_status_text').html(UI.Uneffected);
            //$('#dmz_ip').val('');
        }else{//关闭状态
            $('#dmz_help_text').removeClass('hidden');
            $('#dmz_form_container').addClass('hidden');
            dmz_status = !dmz_status;
            $.post('/','app=adv&action=change_dmzStatus&switch_statusfalse=',Ha.showNotify,'json');
        }
    });

    //提交dmzip
    $('#dmz_form').submit(function(){
        var ip = $('#dmz_ip').val();
        if(ip.length<=0 || validateIP(ip)){
            return false;
        }else{
            var formData = 'app=adv&action=save_dmzStatus&' + $(this).serialize();
            $.post('/',formData,function(data){
                Ha.showNotify(data);
                $('#dmz_status_text').html(UI.Effected);
            },'json');
        }
        return false;
    });
    $('#dmz_ip').keyup(function(){
        var ip = $(this).val();
        var id = $(this).prop('form').id;
        if(ip.length<=0 || validateIP(ip)){
            $(this).parent().parent().addClass('has-error');
            $(this).next('.help-block').removeClass('hidden');
            $('#' + id).find('button').prop('disabled',true);
        }else{
            $(this).parent().parent().removeClass('has-error');
            $(this).next('.help-block').addClass('hidden');
            $('#' + id).find('button').prop('disabled',false);
        }
    });

    //确认后删除些东西
    var action_target,confirm_type;
    $('#confirm_submit').click(function(){
        $.post('/',action_target,function(data){
            Ha.showNotify(data);
            switch(confirm_type){
            case 'ddns':
              initDdns();
              break;
            case 'dhcp':
              initDhcp();
              break;
            case 'port':
              initPortForward();
              break;
            case 'range':
              initRangeForward();
              break;
            }
        },'json');
    });

    //添加dhcp
    $('#dhcp_btn').click(function(){
        $('#dev-name').val('');
        $('#ip-addr').val('');
        $('#mac-addr').val('');
        $('#dhcpModal').find('.help-block').addClass('hidden');
        $('#dhcpModal').find('.has-error').removeClass('has-error');
        $('#add_dhcp_btn').prop('disabled',false);
    });
    $('#add_dhcp_btn').click(function(){
        var formData = $('#add_dhcp_form').serialize();
        var data = 'app=adv&action=dhcp_combine&' + formData;
        var name = $.trim($('#dev-name').val());
        var ip = $('#ip-addr').val();
        var mac = $('#mac-addr').val();
        if(name.length <= 0 || validateHostName(name) || ip.length <= 0 || validateIP(ip) || mac.length <= 0 || validateMac(mac)){
            return false;
        }else{
            $('#dhcpModal').modal('hide');
            $.post('/',data,function(data){
                Ha.showNotify(data);
                initDhcp();
            },'json');
            $('#dev-name').val('');
            $('#ip-addr').val('');
            $('#mac-addr').val('');
            return false;
        }
    });

    $('#dev-name').bind('keyup blur',function(){
        var name = $.trim($(this).val());
        validateFuc($(this),name.length <= 0 || validateHostName(name))
        disableBtnDhcp();
    });

    $('#ip-addr').bind('keyup blur',function(){
        var ip = $(this).val();
        validateFuc($(this),ip.length <= 0 || validateIP(ip));
        disableBtnDhcp();
    });
    $('#mac-addr').bind('keyup blur',function(){
        var mac = $(this).val();
        validateFuc($(this),mac.length <= 0 || validateMac(mac));
        disableBtnDhcp();
    });
    function validateFuc(target,condation){
        if(condation){
            target.parent().addClass('has-error');
            target.next('.help-block').removeClass('hidden');
        }else{
            target.parent().removeClass('has-error');
            target.next('.help-block').addClass('hidden');
        }
    }

    function disableBtnDhcp(){
        var name = $.trim($('#dev-name').val());
        var ip = $('#ip-addr').val();
        var mac = $('#mac-addr').val();
        if(name.length <= 0 || validateHostName(name) || ip.length <= 0 || validateIP(ip) || mac.length <= 0 || validateMac(mac)){
            $('#add_dhcp_btn').prop('disabled',true);
        }else{
            $('#add_dhcp_btn').prop('disabled',false);
        }
    }

    //添加/编辑ddns
    $('#add_ddns_rec_btn').click(function(){
        $('#ddns-username').val('');
        $('#ddns-pwd').val('');
        $('#ddns-host').val('').prop('disabled',false);
        $('#ddns-check-interval').val(10);
        $('#ddns-force-update').val(0);
        $('#ddnsModalLabel').html(UI.Add_DDNS_record);
        $('#ddnsModal').find('.help-block').addClass('hidden');
        $('#ddnsModal').find('.has-error').removeClass('has-error');
        $('#submit_ddns_btn').prop('disabled',false);
    });
    $('#submit_ddns_btn').click(function(){
        $('#ddns-host').prop('disabled',false);
        var ddns_target;
        var formData = $('#add_ddns_form').serialize();
        if($(this).attr('data-submit-target') == 'add'){
            ddns_target = 'app=adv&action=add_ddns&';
        }else{
            ddns_target = 'app=adv&action=edit_a_ddns&';
        }
        data = ddns_target + formData;
        var name = $.trim($('#ddns-username').val());
        var pwd = $('#ddns-pwd').val();
        var domain = $('#ddns-host').val();
        var checkInterval = $('#ddns-check-interval').val();
        var forceUpdate = $('#ddns-force-update').val();
        if(forceUpdate.length <= 0 || isNaN(parseInt(forceUpdate)) || parseInt(forceUpdate)<0 || name.length <= 0 || pwd.length <= 0 || domain.length <= 0 || validateDomain(domain) || checkInterval.length <= 0 || isNaN(parseInt(checkInterval)) || parseInt(checkInterval)<=0){
            return; 
        }else{
            $('#ddnsModal').modal('hide');
            $.post('/',data,function(data){
                Ha.showNotify(data);
                initDdns();
                $('#submit_ddns_btn').attr('data-submit-target','add');
                $('#add_ddns_form').find('input').val('');
            },'json');
        }
        return false;
    });

    $('#ddns-username').bind('keyup blur',function(){
        var name = $.trim($(this).val());
        validateFuc($(this),name.length <= 0)
        disableBtnDdns();
    });
    $('#ddns-pwd').bind('keyup blur',function(){
        var pwd = $(this).val();
        validateFuc($(this),pwd.length <= 0);
        disableBtnDdns();
    });
    $('#ddns-host').bind('keyup blur',function(){
        var domain = $('#ddns-host').val();
        validateFuc($(this),domain.length <= 0 || validateDomain(domain));
        disableBtnDdns();
    });
    $('#ddns-check-interval').bind('keyup blur',function(){
        var checkInterval = $(this).val();
        validateFucWithUnknownCon((checkInterval.length <= 0 || isNaN(parseInt(checkInterval)) || parseInt(checkInterval)<=0),$(this).parent().parent(),$(this).parent().next('.help-block'));
        disableBtnDdns();
    });
    $('#ddns-force-update').bind('keyup blur',function(){
        var forceUpdate = $(this).val();
        validateFucWithUnknownCon((forceUpdate.length <= 0 || isNaN(parseInt(forceUpdate)) || parseInt(forceUpdate)<0),$(this).parent().parent(),$(this).parent().next('.help-block'));
        disableBtnDdns();
    });
    function validateFucWithUnknownCon(condation,errorCon,helpCon){
        if(condation){
            errorCon.addClass('has-error');
            helpCon.removeClass('hidden');
        }else{
            errorCon.removeClass('has-error');
            helpCon.addClass('hidden');
        }
    }
    function disableBtnDdns(){
        var name = $.trim($('#ddns-username').val());
        var pwd = $('#ddns-pwd').val();
        var domain = $('#ddns-host').val();
        var checkInterval = $('#ddns-check-interval').val();
        var forceUpdate = $('#ddns-force-update').val();
        if(forceUpdate.length <= 0 || isNaN(parseInt(forceUpdate)) || parseInt(forceUpdate)<0 || name.length <= 0 || pwd.length <= 0 || domain.length <= 0 || validateDomain(domain) || checkInterval.length <= 0 || isNaN(parseInt(checkInterval)) || parseInt(checkInterval)<=0){
            $('#submit_ddns_btn').prop('disabled',true);   
        }else{
            $('#submit_ddns_btn').prop('disabled',false);   
        }
    }

    //添加/编辑portfw
    $('#add_portfw_btn').click(function(){
        $('#port-fwd-name').val('');
        $('#outer-port').val('');
        $('#inner-ip-addr').val('');
        $('#inner-port').val('');
        $('#portForwardingModalLabel').html(UI.Add_Port_forward_record);
        $('#portForwardingModal').find('.help-block').addClass('hidden');
        $('#portForwardingModal').find('.has-error').removeClass('has-error');
        $('#submit_portfw_btn').prop('disabled',false);
    });
    $('#submit_portfw_btn').click(function(){
        var portfw_target;
        var formData = $('#add_portfw_form').serialize();
        if($(this).attr('data-submit-target') == 'add'){
            portfw_target = 'app=adv&action=new_portforward&';
        }else{
            portfw_target = 'app=adv&action=edit_portforward&';
        }
        var data = portfw_target + formData;
        var name = $.trim($('#port-fwd-name').val());
        var outerPort = $('#outer-port').val();
        var ip = $('#inner-ip-addr').val();
        var innerPort = $('#inner-port').val();
        if(innerPort.length<=0 || isNaN(parseInt(innerPort)) || parseInt(innerPort) <= 0 || parseInt(innerPort) > 65535 || ip.length<=0 || validateIP(ip) || name.length<=0 || outerPort.length<=0 || isNaN(parseInt(outerPort)) || parseInt(outerPort) <= 0 || parseInt(outerPort) > 65535){
           return;
        }else{
            $.post('/',data,function(data){
                $('#portForwardingModal').modal('hide');
                Ha.showNotify(data);
                initPortForward();
                $('#submit_portfw_btn').attr('data-submit-target','add');
                $('#add_portfw_form').find('input').val('');    
            },'json');
        }
    });
    $('#port-fwd-name').bind('keyup blur',function(){
        var name = $.trim($(this).val());
        validateFuc($(this),name.length<=0);
        disableBtnFwd();
    });
    $('#outer-port').bind('keyup blur',function(){
        var outerPort = $(this).val();
        validateFuc($(this),outerPort.length<=0 || isNaN(parseInt(outerPort)) || parseInt(outerPort) <= 0 || parseInt(outerPort) > 65535);
        disableBtnFwd();
    });
    $('#inner-ip-addr').bind('keyup blur',function(){
        var ip = $('#inner-ip-addr').val();
        validateFuc($(this),ip.length<=0 || validateIP(ip));
        disableBtnFwd();
    });
    $('#inner-port').bind('keyup blur',function(){
        var innerPort = $('#inner-port').val();
        validateFuc($(this),innerPort.length<=0 || isNaN(parseInt(innerPort)) || parseInt(innerPort) <= 0 || parseInt(innerPort) > 65535);
        disableBtnFwd();
    });

    function disableBtnFwd(){
        var name = $.trim($('#port-fwd-name').val());
        var outerPort = $('#outer-port').val();
        var ip = $('#inner-ip-addr').val();
        var innerPort = $('#inner-port').val();
        if(innerPort.length<=0 || isNaN(parseInt(innerPort)) || parseInt(innerPort) <= 0 || parseInt(innerPort) > 65535 || ip.length<=0 || validateIP(ip) || name.length<=0 || outerPort.length<=0 || isNaN(parseInt(outerPort)) || parseInt(outerPort) <= 0 || parseInt(outerPort) > 65535){
           $('#submit_portfw_btn').prop('disabled',true);
        }else{
           $('#submit_portfw_btn').prop('disabled',false);
        }
    }

    //添加/编辑rangefw
    $('#add_rangefw_btn').click(function(){
        $('#range-fwd-name').val('');
        $('#start-port').val('');
        $('#end-port').val('');
        $('#range-fwd-inner-ip-addr').val('');
        $('#rangeForwardingModalLabel').html(UI.Add_Range_forward_record);
        $('#rangeForwardingModal').find('.help-block').addClass('hidden');
        $('#rangeForwardingModal').find('.has-error').removeClass('has-error');
        $('#submit_rangefw_btn').prop('disabled',false);
    });
    $('#submit_rangefw_btn').click(function(){
        var rangefw_target;
        var formData = $('#add_rangefw_form').serialize();
        if($(this).attr('data-submit-target') == 'add'){
            rangefw_target = 'app=adv&action=new_rangeforward&';
        }else{
            rangefw_target = 'app=adv&action=edit_rangeforward&';
        }
        var data = rangefw_target + formData;
        var name = $.trim($('#range-fwd-name').val());
        var startPort = $('#start-port').val();
        var endPort = $('#end-port').val();
        var ip = $('#range-fwd-inner-ip-addr').val();
        if(name.length<=0 || startPort.length<=0 || isNaN(parseInt(startPort)) || parseInt(startPort) <= 0 || parseInt(startPort) > 65535 ||
            endPort.length<=0 || isNaN(parseInt(endPort)) || parseInt(endPort) <= 0 || parseInt(endPort) > 65535 || 
            ip.length<=0 || validateIP(ip)){
            return;
        }else{
            $('#rangeForwardingModal').modal('hide');
            $.post('/',data,function(data){
                Ha.showNotify(data);
                initRangeForward();
                $('#submit_rangefw_btn').attr('data-submit-target','add');
                $('#add_rangefw_form').find('input').val(''); 
            },'json');
        }
        return false;
    });
    $('#range-fwd-name').bind('keyup blur',function(){
        var name = $.trim($(this).val());
        validateFuc($(this),name.length<=0);
        disableRangeBtn();
    });
    $('#start-port').bind('keyup blur',function(){
        var startPort = $(this).val();
        validateFuc($(this),startPort.length<=0 || isNaN(parseInt(startPort)) || parseInt(startPort) <= 0 || parseInt(startPort) > 65535);
        disableRangeBtn();
    });
    $('#end-port').bind('keyup blur',function(){
        var endPort = $(this).val();
        validateFuc($(this),endPort.length<=0 || isNaN(parseInt(endPort)) || parseInt(endPort) <= 0 || parseInt(endPort) > 65535);
        disableRangeBtn();
    });
    $('#range-fwd-inner-ip-addr').bind('keyup blur',function(){
        var ip = $(this).val();
        validateFuc($(this),ip.length<=0 || validateIP(ip));
        disableRangeBtn();
    });
        
    function disableRangeBtn(){
        var name = $.trim($('#range-fwd-name').val());
        var startPort = $('#start-port').val();
        var endPort = $('#end-port').val();
        var ip = $('#range-fwd-inner-ip-addr').val();
        if(name.length<=0 || startPort.length<=0 || isNaN(parseInt(startPort)) || parseInt(startPort) <= 0 || parseInt(startPort) > 65535 ||
            endPort.length<=0 || isNaN(parseInt(endPort)) || parseInt(endPort) <= 0 || parseInt(endPort) > 65535 || 
            ip.length<=0 || validateIP(ip)){
            $('#submit_rangefw_btn').prop('disabled',true);
        }else{
            $('#submit_rangefw_btn').prop('disabled',false);
        }        
    }
    //upnp协议
    function initUpnp(){
        $.get('/?app=adv&action=upnp_config',function(data){
            if(!data.code){
                //开关状态
                $('#upnp_switch').prop('disabled',false);
                if(data.switch_status){//开启状态
                    $('#disabled_upnp_text').addClass('hidden');
                    $('#upnp_switch').prop('checked',true);
                    upnp_status = true;
                    if(data.list.length <= 0){//没有设备
                        $('#upnp_dev_list').addClass('hidden');
                        $('#none_upnp_text,#upnp_dev_list_header,#upnp_dev_list_title').removeClass('hidden');
                    }else{//有设备数据，遍历生成dom
                        $('#upnp_dev_list,#upnp_dev_list_header,#upnp_dev_list_title').removeClass('hidden');
                        $('#none_upnp_text').addClass('hidden');
                        $('#upnp_dev_list').empty();
                        for(var i=0; i<data.list.length; i++){
                            var cur_data = data.list[i];
                            var dev_dom = '<tr>'
                                        +   '<td>' + cur_data.proto + '</td>'
                                        +   '<td>' + cur_data.applet + '</td>'
                                        +   '<td>' + cur_data.lan_ip + '</td>'
                                        +   '<td>' + cur_data.lan_port + '</td>'
                                        +   '<td>' + cur_data.wan_port + '</td>'
                                        + '</tr>';
                            $('#upnp_dev_list').append(dev_dom);
                        }
                    }
                }else{//关闭状态
                    upnp_status = false;
                    $('#upnp_switch').prop('checked',false);
                    $('#disabled_upnp_text').removeClass('hidden');
                    $('#upnp_dev_list,#upnp_dev_list_header,#upnp_dev_list_title,#none_upnp_text').addClass('hidden');
                }
                $('.upnp_text').addClass('hidden');
            }
        },'json');
    }

    //动态域名解析
    function initDdns(){
        $.get('/?app=adv&action=get_ddns_list',function(data){
            if(!data.code){
                if(data.list.length <= 0){
                    $('#none_ddns_text').removeClass('hidden');
                    $('#ddns_rec_list').addClass('hidden');
                }else{
                    $('#none_ddns_text').addClass('hidden');
                    $('#ddns_rec_list').removeClass('hidden');
                    $('#ddns_rec_list').empty();
                    for(var i=0; i<data.list.length; i++){
                        var checked;
                        if(data.list[i].enabled){
                            checked = 'checked';
                        }else{
                            checked = '';
                        }
                        
                        var lastupdate = formatTime(new Date(data.list[i].lastupdate * 1000),"yyyy-MM-dd hh:mm");
                        var rec_dom = '<tr id="ddns_rec_' + data.list[i].config + '">'
                                    +   '<td>' + data.list[i].domain + '</td>'
                                    +   '<td>' + lastupdate + '<a href="" class="update_time" id="update_time_' + data.list[i].config + '">('+UI.Manual_update+')</a></td>'
                                    +   '<td>'
                                    +       '<div class="switch-ctrl switch-sm">'
                                    +           '<input type="checkbox" name="switch_ddns_status" id="switch_ddns_' + data.list[i].config + '" ' + checked + '>'
                                    +           '<label for="switch_ddns_' + data.list[i].config + '"><span></span></label>'
                                    +       '</div>'
                                    +   '</td>'
                                    +   '<td>'
                                    +       '<button class="btn btn-xs btn-info edit_rec_btn" id="ddns_edit_btn_' + data.list[i].config + '"  data-toggle="modal" data-target="#ddnsModal">'+UI.Edit+'</button>'
                                    +       '<button class="btn btn-xs btn-danger delete_rec_btn" id="ddns_delete_btn_' + data.list[i].config + '" data-toggle="modal" data-target="#confirmModal">'+UI.Delete+'</button>'
                                    +   '</td>'
                                    + '</tr>';
                        $('#ddns_rec_list').append(rec_dom);
                    }
                    //删除
                    $('.delete_rec_btn').click(function(){
                        var id = $(this).prop('id').replace('ddns_delete_btn_','');
                        $('#confirm_title').html(UI.delete_DDNS_record);
                        $('#confirm_text').html(UI.Do_you_want_delete_this_DDNS_record);
                        action_target = 'app=adv&action=del_a_ddns&config=' + id;
                        confirm_type = 'ddns';
                    });
                    //编辑
                    $('.edit_rec_btn').click(function(){
                        $('#ddnsModal').find('.has-error').removeClass('has-error');
                        $('#ddnsModal').find('.help-block').addClass('hidden');
                        $('#submit_ddns_btn').prop('disabled',false);
                        var id = $(this).prop('id').replace('ddns_edit_btn_','');
                        var cur_data;
                        $('#submit_ddns_btn').attr('data-submit-target','edit');
                        $.get('/?app=adv&action=edit_ddns&config=' + id,function(data){
                            cur_data = data;
                            $('#ddnsModalLabel').html(UI.Edit_DDNS_record);
                            $('#service_name').find('[value="' + cur_data.servicename + '"]').prop('selected','selected');
                            $('#ddns-username').val(cur_data.username);
                            $('#ddns-pwd').val(cur_data.password);
                            $('#ddns-host').val(cur_data.domain).prop('disabled',true);
                            $('#ddns-check-interval').val(cur_data.check_interval);
                            $('#ddns-force-update').val(cur_data.force_interval);
                        },'json');
                    });
                    //手动更新时间
                    $('.update_time').click(function(){
                        var id = $(this).prop('id').replace('update_time_','');
                        $.post('/','app=adv&action=update_ddns&config=' + id,function(data){
                            Ha.showNotify(data);
                            initDdns();
                        },'json');
                        return false;
                    });
                    //switch切换状态
                    $('[name="switch_ddns_status"]').click(function(){
                        var ddns_status = $(this).prop('checked');//点击后将要变成的值
                        var id = $(this).prop('id').replace('switch_ddns_','');
                        if(ddns_status){//点击后成真值，则发送开启请求
                            $.get('/?app=adv&action=ddns_switch&enabled=1&config=' + id,function(data){
                                if(!data.code){
                                    Ha.showNotify({status:0,msg:'已经开启了'})
                                }
                            },'json');
                        }else{//点击后成假值，则发送关闭请求
                            $.get('/?app=adv&action=ddns_switch&enabled=0&config=' + id,function(data){
                                if(!data.code){
                                    Ha.showNotify({status:0,msg:'已经关闭了'})
                                }
                            },'json');
                        }
                    });


                }
            }
        },'json');
    }

    //dhcp的静态IP分配
    function initDhcp(){
        $.get('/?app=adv&action=dhcp_query',function(data){
            if(!data.code){
                if(data.list.length <= 0){//没有设备ip
                    $('#none_dhcp_text').removeClass('hidden');
                    $('#dhcp_ip_list').addClass('hidden');
                }else{//循环遍历到表格
                    $('#none_dhcp_text').addClass('hidden');
                    $('#dhcp_ip_list').removeClass('hidden');
                    $('#dhcp_ip_list').empty();
                    for(var i=0; i<data.list.length; i++){
                        var ip_dom = '<tr id="dhcp_' + data.list[i].tag + '">'
                                   +    '<td>' + data.list[i].dname + '</td>'
                                   +    '<td>' + data.list[i].ip + '</td>'
                                   +    '<td>' + data.list[i].mac + '</td>'
                                   +    '<td>'
                                   +        '<button class="btn btn-danger btn-xs remove_dhcp_btn" id="confirm_' + data.list[i].tag + '" data-toggle="modal" data-target="#confirmModal">'+UI.Do_Uncombined+'</button>'
                                   +    '</td>'
                                   + '</tr>';
                        $('#dhcp_ip_list').append(ip_dom);
                    }
                    //解除绑定
                    $('.remove_dhcp_btn').click(function(){
                        var id = $(this).prop('id').split('_').pop();
                        $('#confirm_title').html(UI.Do_Uncombined);
                        $('#confirm_text').html(UI.Do_you_want_uncombined_this);
                        action_target = 'app=adv&action=dhcp_uncombine&tag=' + id;
                        confirm_type = 'dhcp';
                    });
                }
            }
        },'json');
    }

    //端口转发
    function initPortForward(){
        $.get('/?app=adv&action=get_portforward_list',function(data){
            if(!data.code){
                if(data.list.length <= 0){
                    $('#none_portfw_text').removeClass('hidden');
                    $('#port_forward_list').addClass('hidden');
                }else{
                    $('#none_portfw_text').addClass('hidden');
                    $('#port_forward_list').removeClass('hidden');
                    $('#port_forward_list').empty();
                    for(var i=0; i<data.list.length; i++){
                        var rec_dom = '<tr id="port_forward_' + data.list[i].config + '">'
                                    +   '<td>' + data.list[i].name + '</td>'
                                    +   '<td>' + data.list[i].proto + '</td>'
                                    +   '<td>' + data.list[i].src_dport + '</td>'
                                    +   '<td>' + data.list[i].dest_ip + '</td>'
                                    +   '<td>' + data.list[i].dest_port + '</td>'
                                    +   '<td>'
                                    +       '<button class="btn btn-xs btn-info edit_portfw_btn" id="eidt_portfw_' + data.list[i].config + '" data-toggle="modal" data-target="#portForwardingModal">'+UI.Edit+'</button>'
                                    +       '<button class="btn btn-xs btn-danger delete_portfw_btn" id="delete_portfw_' + data.list[i].config + '" data-toggle="modal" data-target="#confirmModal">'+UI.Delete+'</button>'
                                    +   '</td>'
                                    + '</tr>';
                        $('#port_forward_list').append(rec_dom);
                    }
                    //删除
                    $('.delete_portfw_btn').click(function(){
                        var id = $(this).prop('id').split('_').pop();
                        $('#confirm_title').html(UI.Delete_Port_forward_record);
                        $('#confirm_text').html(UI.Do_you_want_delete_this_Port_forward_record);
                        action_target = 'app=adv&action=del_a_portforward&config=' + id;
                        confirm_type = 'port';
                    });
                    //编辑
                    $('.edit_portfw_btn').click(function(){
                        var id = $(this).prop('id').split('_').pop();
                        var cur_data;
                        $('#portForwardingModal').find('.has-error').removeClass('has-error');
                        $('#portForwardingModal').find('.help-block').addClass('hidden');
                        $('#submit_portfw_btn').prop('disabled',false).attr('data-submit-target','edit');
                        $.get('/?app=adv&action=get_a_portforward&config=' + id,function(data){
                            cur_data = data.item;
                            $('#portfw_config').val(cur_data.config);
                            $('#portForwardingModalLabel').html(UI.Edit_Port_forward_record);
                            $('#port-fwd-protocol').find('[value="' + cur_data.proto + '"]').prop('selected','selected');
                            $('#port-fwd-name').val(cur_data.name);
                            $('#outer-port').val(cur_data.src_dport);
                            $('#inner-ip-addr').val(cur_data.dest_ip);
                            $('#inner-port').val(cur_data.dest_port);
                        },'json');
                    });
                }
            }
        },'json');
    }

    //范围转发
    function initRangeForward(){
        $.get('/?app=adv&action=get_rangeforward_list',function(data){
            if(!data.code){
                if(data.list.length <= 0){
                    $('#none_rangefw_text').removeClass('hidden');
                    $('#range_forward_list').addClass('hidden');
                }else{
                    $('#none_rangefw_text').addClass('hidden');
                    $('#range_forward_list').removeClass('hidden');
                    $('#range_forward_list').empty();
                    for(var i=0; i<data.list.length; i++){
                        var rec_dom = '<tr id="range_forward_' + data.list[i].config + '">'
                                    +   '<td>' + data.list[i].name + '</td>'
                                    +   '<td>' + data.list[i].proto + '</td>'
                                    +   '<td>' + data.list[i].start_port + '</td>'
                                    +   '<td>' + data.list[i].end_port + '</td>'
                                    +   '<td>' + data.list[i].dest_ip + '</td>'
                                    +   '<td>'
                                    +       '<button class="btn btn-xs btn-info edit_rangefw_btn" id="edit_rangefw_btn_' + data.list[i].config + '" data-toggle="modal" data-target="#rangeForwardingModal">'+UI.Edit+'</button>'
                                    +       '<button class="btn btn-xs btn-danger delete_rangefw_btn" id="delete_rangefw_btn_' + data.list[i].config + '" data-toggle="modal" data-target="#confirmModal">'+UI.Delete+'</button>'
                                    +   '</td>'
                                    + '</tr>';
                        $('#range_forward_list').append(rec_dom);
                    }
                    //删除
                    $('.delete_rangefw_btn').click(function(){
                        var id = $(this).prop('id').split('_').pop();
                        $('#confirm_title').html(UI.Delete_Range_forward_record);
                        $('#confirm_text').html(UI.Do_you_want_delete_this_Range_forward_record);
                        action_target = 'app=adv&action=del_a_rangeforward&config=' + id;
                        confirm_type = 'range';
                    });
                    //编辑
                    $('.edit_rangefw_btn').click(function(){
                        var id = $(this).prop('id').split('_').pop();
                        var cur_data;
                        $('#rangeForwardingModal').find('.help-block').addClass('hidden');
                        $('#rangeForwardingModal').find('.has-error').removeClass('has-error');
                        $('#submit_rangefw_btn').prop('disabled',false).attr('data-submit-target','edit');
                        $.get('/?app=adv&action=get_a_rangeforward&config=' + id,function(data){
                            cur_data = data.item;
                            $('#rangefw_config').val(cur_data.config);
                            $('#rangeForwardingModalLabel').html(UI.Edit_Range_forward_record);
                            $('#range-fwd-protocol').find('[value="' + cur_data.proto + '"]').prop('selected','selected');
                            $('#range-fwd-name').val(cur_data.name);
                            $('#start-port').val(cur_data.start_port);
                            $('#end-port').val(cur_data.end_port);
                            $('#range-fwd-inner-ip-addr').val(cur_data.dest_ip);
                        },'json');
                    });
                }
            }
        },'json');
    }

    //DMZ
    function initDmz(){
        $.get('/?app=adv&action=get_dmzStatus',function(data){
            if(!data.code){
                $('#dmz_ip').val(data.ip);
                if(data.switch_status){//开启状态
                    dmz_status = true;
                    $('#dmz_switch').prop('checked',true);
                    $('#dmz_help_text').addClass('hidden');
                    $('#dmz_form_container').removeClass('hidden');
                }else{//关闭状态
                    dmz_status = false;
                    $('#dmz_switch').prop('checked',false);
                    $('#dmz_help_text').removeClass('hidden');
                    $('#dmz_form_container').addClass('hidden');
                }
            }
        },'json');
    }

    function init(){
        initUpnp();
        initDdns();
        initDhcp();
        initPortForward();
        initRangeForward();
        initDmz();
    }

    //切换UPNP状态
    function switchUpnpStatus(status){
        $.get('/?app=adv&action=switch_status&switch=' + status,function(data){
            Ha.showNotify(data);
        },'json');
    }
})();