(function(){
    Ha.mask.show();
    var notices_info,
        notices,
        per_page_records = 8,
        page = 1;
    var test = true;

    initNotice();

    $('#modal_delete_btn').click(function(){
        var id = $('#single_notice').attr('data-notice');
        deleteNotice(id,page);
    });

    $('#select_all_notice').click(function(){
        $('tbody :checkbox').prop('checked',$('#select_all_notice').prop('checked'));
    });

    $('#delete_notices_btn').click(function(){
        var ids = getIds();
        if(ids){
            deleteNotice(ids,page);
        }else{
            return false;
        }
        $('#select_all_notice').removeAttr('checked');
    });

    $('#markread_notices_btn').click(function(){
        var ids = getIds();
        if(ids){
            $.get('/?app=notice&action=mark_read_notice&ids=' + ids,function(data){
                if(!data.status){
                    initNotice(page);
                }
            },'json');
        }else{
            return false;
        }
        $('#select_all_notice').removeAttr('checked');
    });



    function initNotice(page,per_page_records){
        var page = page || 1;
        var per_page_records = per_page_records || 8;
        $.post('/','app=notice&action=notice_count&per_page_records=' + per_page_records,function(data){
            notices_info = data;
            makePagerDom(data,page);
        },'json');

        $.post('/','app=notice&action=notice_get_page&page=' + page + '&per_page_records=' + per_page_records,function(data){
            notices = data.result;
            makeNoticeDom(notices,page);
            Ha.setFooterPosition();
        },'json');
    }

    function makePagerDom(data,current_page){

        var prev_class,next_class;

        $('#pager').empty();//清空pager容器
        if(!data.pages){//没有数据的情况
            return false;
        }

        //判断上一页下一页的特殊类
        if(current_page == 1){
            prev_class = 'disabled';
            if(data.pages == 1){
                next_class = 'disabled';
            }
        }else if(current_page == data.pages){
            next_class = 'disabled';
        }else{
            prev_class = '';
            next_class = '';
        }
        var prev_next = '<ul class="pagination">'//上一页下一页dom
                      +     '<li class="' + prev_class + '" id="prev_btn"><a href="#"><span>«</span></a></li>'
                      +     '<li class="' + next_class + '" id="next_btn"><a href="#"><span>»</span></a></li>'
                      + '</ul>';
        $('#pager').append(prev_next);

        $('#prev_btn').click(function(){
            if(current_page === 1){
                return false;
            }else{
                initNotice(current_page-1);
                current_page -= 1;
            }
        });
        $('#next_btn').click(function(){
           if(current_page === data.pages){
            return false;
           }else{
                initNotice(current_page+1);
                current_page += 1;
           }
        });

        for(var i=1; i<=data.pages; i++){//循环生成页码
            var active_class;//当前页的类
            if(i==current_page){
                active_class = 'active';
            }else{
                active_class = '';
            }
            var pager_dom = '<li class="' + active_class + ' page_item"><a href="" id="pager_num_' + i + '">' + i + '</a></li>';//页码dom
            $('#next_btn').before($(pager_dom));

            (function(n){
                $('#pager_num_' + n).click(function(){
                    if(n === current_page){
                        return false;
                    }
                    initNotice(n);
                    return false;
                });
                Ha.setFooterPosition();
            })(i);
        }

        if(data.pages >= 11){
            if(current_page <=6){
              $('.page_item').each(function(){
                var id = $(this).find('a').prop('id').split('_').pop();
                if(id >= 12 && id <= data.pages-2){
                  $(this).addClass('hidden');
                }
                if(id == data.pages-1){
                  $(this).find('a').html('...');
                  $(this).addClass('disabled'); 
                }
              });
            }else if(current_page >= data.pages-5){
              $('.page_item').each(function(){
                var id = $(this).find('a').prop('id').split('_').pop();
                if(id == 2){
                  $(this).find('a').html('...');
                  $(this).addClass('disabled');
                }
                if(id > 2 && id < data.pages-10){
                  $(this).addClass('hidden'); 
                }
              });
            }else{
              $('.page_item').each(function(){
                var id = $(this).find('a').prop('id').split('_').pop();
                if(id <= current_page-5 || id >= current_page+5){
                  if(id == 1 || id == data.pages){
                    
                  }else if(id == 2 || id == data.pages-1){
                    $(this).find('a').html('...');
                    $(this).addClass('disabled');
                  }else{
                    $(this).addClass('hidden');
                  }
                }
              });
            }
        }
    }

    function makeNoticeDom(data,current_page){
        var current_page = current_page || 1;
        $('#notice_container').empty();//先清空再重绘
        if(!data){//没有消息的情况
            var no_notice_dom = '<tr><td colspan="4">'+UI.Empty+'</td><tr>';
            $(no_notice_dom).appendTo($('#notice_container'));
            $('#notice_footer').addClass('hidden');
            Ha.mask.hide();
        }else{//有消息

            page = current_page;

            $('#notice_footer,#pager').removeClass('hidden');//显示批量操作的控件

            for(var i=0; i<data.length; i++){
                var notice = data[i];
                var date_time = formatTime(new Date(notice.Time * 1000),"yyyy-MM-dd hh:mm");//格式化时间

                var redirect_url;//处理信息的重定向url
                if(notice.Dest_type == 'app'){
                    redirect_url = '/?app=' + notice.Dest;
                }else{
                    redirect_url = notice.Dest;
                }
                
                var ergen_class;
                if(notice.Ergen == 0){
                    ergen_class = 'text-success';
                }else if(notice.Ergen == 1){
                    ergen_class = 'text-warning';
                }else if(notice.Ergen >=2){
                    ergen_class = 'text-danger';
                }

                var read_status_class;
                if(notice.Read == 0){
                    read_status_class = 'unread';
                }else{
                    read_status_class = '';
                }
                //消息dom
                var notice_dom = '<tr id="notice_' + notice.Id + '" class="' + read_status_class + '">'
                                +   '<td>'
                                +       '<div class="pull-left">'
                                +           '<input type="checkbox" data-checked="' + notice.Id + '">'
                                +           '&nbsp;&nbsp;<span class="glyphicon glyphicon-info-sign ' + ergen_class + '"></span>'
                                +       '</div>'
                                +   '</td>'
                                +   '<td class="text-left">' + date_time + '</td>'
                                +   '<td class="text-left read_notice" id="notice_desc_' + notice.Id + '" data-toggle="modal" data-target="#myModal">' + notice.Desc + '</td>'
                                +   '<td>'
                                +       '<div class="pull-left"><a href="' + redirect_url + '"><button id="deal_notice_' + notice.Id + '" class="btn btn-xs btn-info">'+UI.Deal+'</button></a>'//处理消息（a标签跳转）
                                +       '<button class="btn btn-xs btn-danger" id="delete_notice_' + notice.Id + '">'+UI.Delete+'</button></div>'//删除消息（dom点击事件）
                                +   '</td>'
                                + '</tr>';
                $(notice_dom).appendTo($('#notice_container'));

                (function(n,page,url){//闭包保留id
                    $('#delete_notice_' + n).click(function(){//删除消息
                        deleteNotice(n,page);
                    });

                    $('#notice_desc_' + n).click(function(){//获取消息内容
                        $('#single_notice').html('Loading...').attr('data-notice',n);
                        $('#single_notice_content').html('Loading...');
                        $('#modal_deal_btn').parent().prop('href',url);
                        $.post('/','app=notice&action=notice_get_a_notice&ids=' + n,function(data){
                            $('#single_notice').html(data.Desc).attr('data-notice',n);
                            $('#single_notice_content').html(data.Detail);
                            $.get('/?app=notice&action=mark_read_notice&ids=' + n,function(data){
                                if(!data.status){
                                    initNotice(page);
                                }
                            },'json');
                        },'json');
                    });

                    $('#modal_deal_btn,#deal_notice_' + n).click(function(){//从弹窗重定向
                        $.get('/?app=notice&action=mark_read_notice&ids=' + n,function(data){
                            if(!data.status){
                                initNotice(page);
                            }
                        },'json');
                    });

                })(notice.Id,current_page,redirect_url);
            }

            Ha.mask.hide();
        }
    }

    //考虑下在前端操作数据和dom先模拟删除效果，之后再发送请求??????
    function deleteNotice(ids,page){
        $.get('/?app=notice&action=del_notice&ids=' + ids, function(data){
            Ha.showNotify(data);
	        $.post('/','app=notice&action=notice_get_page&page=' + page + '&per_page_records=' + per_page_records,function(data){
			    if(data.status){
			        initNotice(page-1);
			    }else{
			        initNotice(page);
			    }
			},'json');
        },'json');
    }

    function getIds(){
        var ids = [];
        $('tbody :checkbox').each(function(){
            if($(this).prop('checked')){
                var id = $(this).attr('data-checked');
                ids.push(id);
            }
        });
        ids = ids.join(',');
        return ids;
    }
})();