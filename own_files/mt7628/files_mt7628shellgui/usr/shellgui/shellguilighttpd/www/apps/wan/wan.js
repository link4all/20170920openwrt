(function(){
    $('form,input,[type="submit"]').prop('disabled',true);
    $.post('/',{'app':'wan','action': 'wan_check_net'},function(data){
        for(var key in data){
            if(!data[key].status){
                $('#wanType_' + key).html(UI.Connecting_Internet_Successfull);
                $('#wanSet_' + key).addClass('hidden');
                $('#' + key + '_info').removeClass('hidden');
                $('#' + key + '_info_ip').html(data[key].ip);
                $('#' + key + '_info_mask').html(data[key].mask);
                $('#' + key + '_info_gateway').html(data[key].gateway);
                $('#' + key + '_info_dns').html(data[key].dns);
            }else{
                $('#wanType_' + key).html('<span class=\'text-danger\'>'+UI.Connecting_Internet_Fail+'</span>');
                $('#wanSet_' + key).find('form,input,[type="submit"]').prop('disabled',false);
            }
        }
    },'json');

    $('.show-set-btn').on('click',function(){
            var wan_id = $(this).attr('id');
            var name = wan_id.replace('_set_btn','');
            $('#' + name + '_info').addClass('hidden');
            $('#wanSet_' + name).removeClass('hidden');
            $('#wanSet_' + name).find('form,input,[type="submit"]').prop('disabled',false);
    });

    $('form').on('submit',function(){
        var form = $(this),
            data_order = form.find('[type="submit"]').attr('data-order'),
            data = 'app=wan&action=wan_' + form.attr('name') + '&wan=' + data_order + '&' + form.serialize();
        var errors = [];
        $(this).find('input').each(function(){
            var type = $(this).attr('data-type');
            var val = $(this).val();
            if(val.length > 0 && type=="ip"){
                var error = validateIP(val);
                if(error){
                    errors.push(1);
                }
            }else if(type=="required"){
                if(val.length <= 0){
                    errors.push(1);
                }
            }else if(type=="requiredip"){
                if(val.length <= 0){
                    errors.push(1);
                }else{
                    var error = validateIP(val);
                    if(error){
                        errors.push(1);
                    }
                }
            }else if(type=="number"){
                if(val.length <= 0){
                    
                }else{
                    val = parseInt(val);
                    if(isNaN(val) || val<0 || val > 1500){
                        errors.push(1);
                    }
                }
            }else if(type == 'metric'){
                if(val.length <= 0){
                    
                }else{
                    val = parseInt(val);
                    if(isNaN(val) || val<0 || val > 255){
                        errors.push(1);
                    }
                }
            }
        });
        if(errors.length){
            return false;
        }else{
            // console.log(123);
            Ha.ajax('/','json',data,'post');
        }

        return false;
    });
    
    $('form').find('input').bind('blur keyup',function(){
        var thisinput = $(this);
        validateInput(thisinput);
    });

    $('.adv_btn').click(function(){
        var id = $(this).attr('data-for');
        var type = $(this).find('span').hasClass('glyphicon-plus');
        if(type){
            $('#' + id).removeClass('hidden');
            $(this).find('span').removeClass('glyphicon-plus').addClass('glyphicon-minus');
        }else{
            $('#' + id).addClass('hidden');
            $(this).find('span').removeClass('glyphicon-minus').addClass('glyphicon-plus');
        }
        Ha.setFooterPosition();
    });

    $('.submit_clone').click(function(){
        var wan = $(this).attr('data-wan');
        var proto_config = $('#switch_' + wan + '_clone').prop('checked') ? 1 : 0;
        var post_data = 'app=wan&action=clone_nic&wan=' + wan + '&proto_config=' + proto_config;
        Ha.ajax('/','json',post_data,'post');
    });

    function validateInput(thisinput){
        var type = thisinput.attr('data-type');
        var val = $.trim(thisinput.val());
        if(val.length > 0 && type=="ip"){
            var error = validateIP(val);
            validateFuc(error,thisinput.parent().parent(),thisinput.next('.help-block'));
        }else if(type=="required"){
            validateFuc((val.length <= 0),thisinput.parent().parent(),thisinput.next('.help-block'));
        }else if(type=="requiredip"){
            validateFuc((val.length <= 0 || validateIP(val)),thisinput.parent().parent(),thisinput.next('.help-block'));
        }else if(val.length > 0 && type=="number"){
            validateFuc((isNaN(parseInt(val)) || parseInt(val)<=0 || parseInt(val) > 1500),thisinput.parent().parent(),thisinput.next('.help-block'))
        }else if(val.length > 0 && type=="metric"){
            validateFuc((isNaN(parseInt(val)) || parseInt(val)<0 || parseInt(val) > 255),thisinput.parent().parent(),thisinput.next('.help-block'))
        }else{
            thisinput.parent().parent().removeClass('has-error');
            thisinput.next('.help-block').addClass('hidden');
        }
        var id = thisinput.prop('form').id;
        disableBtn(id);
    }
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

    //confirm modal
    $('.remove_vwan_btn').click(function(){
        var id = $(this).prop('id');
        var wan = id.replace('remove_btn_','');
        var text = UI.Are_you_sure_to_remove + wan + '?';
        Ha.alterModal('confirmModal',UI.Remove_wan,text,removeVwan,id);
    });
    function removeVwan(id){
        var wan = id.replace('remove_btn_','');
        var post_data = 'app=wan&action=rm_vwan&wan=' + wan;
        $.post('/',post_data,function(data){
            Ha.showNotify(data);
            if(!data.status){
                $('#' + wan + '_container').remove();
            }else{
                //删除失败
            }
        },'json');
    }

    //submit mac
    $('.submit_mac').click(function(){
        var wan = $(this).attr('data-wan');
        var mac = $('#macaddr_' + wan).val();
        var post_data = 'app=wan&action=set_macaddr&wan=' + wan + '&mac=' + mac;
        if(va.validateMac(mac)){
            $(this).prop('disabled',true);
            $('#macaddr_' + wan).parent().addClass('has-error');
            $(this).next('.help-block').removeClass('hidden');
        }else{
            $.post('/',post_data,function(data){
                Ha.showNotify(data);

            },'json');
        }
    });
    $('.mac_input').bind('keyup blur',function(){
        var mac = $(this).val();
        var wan =$(this).attr('data-wan');
        if(va.validateMac(mac)){
            $(this).next('.submit_mac').prop('disabled',true);
            $(this).parent().addClass('has-error');
            $(this).next('.submit_mac').next('.help-block').removeClass('hidden');
        }else{
            $(this).next('.submit_mac').prop('disabled',false);
            $(this).parent().removeClass('has-error');
            $(this).next('.submit_mac').next('.help-block').addClass('hidden');
        }
    });
})();
