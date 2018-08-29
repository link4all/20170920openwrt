(function(){
    Ha.mask.show();
    var visit_info,visit_recs,per_page_records = 10,page = 1;

    initVisitRecs();

    function initVisitRecs(page,per_page_records){
      var page = page || 1;
      var per_page_records = per_page_records || 10;
      $.post('/','app=lan-net-record&action=net_record_server_visit_count&per_page_records=' + per_page_records,function(data){
          visit_info = data;
          makePagerDom(data,page);
          Ha.setFooterPosition();
      },'json');

      $.post('/','app=lan-net-record&action=net_record_server_visit_get_page&page=' + page + '&per_page_records=' + per_page_records,function(data){
          visit_recs = data.result;
          makeVisitDom(visit_recs,page);
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
              initVisitRecs(current_page-1);
              current_page -= 1;
          }
      });
      $('#next_btn').click(function(){
         if(current_page === data.pages){
          return false;
         }else{
              initVisitRecs(current_page+1);
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

        var pager_dom = '<li class="' + active_class + ' page_item"><a href="" id="pager_num_' + i + '">' + i + '</a></li>';
        $('#next_btn').before($(pager_dom));

        (function(n){
          $('#pager_num_' + n).click(function(){
            if(n === current_page){
                return false;
            }
            if($(this).html() != '...'){
              initVisitRecs(n);
            }
            return false;
          });    
        })(i);
      }

        if(data.pages >=11){
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

    function makeVisitDom(data,current_page){
        var current_page = current_page || 1;
        $('#visits_container').empty();//先清空再重绘
        if(!data){//没有消息的情况
            var no_visit_dom = '<tr><td colspan="4">没有访问记录</td><tr>';
            $(no_visit_dom).appendTo($('#visits_container'));
            Ha.mask.hide();
        }else{//有消息

            page = current_page;

            $('#pager').removeClass('hidden');

            for(var i=0; i<data.length; i++){
                var visit = data[i];
                var date_time = formatTime(new Date(visit.Time * 1000),"yyyy-MM-dd hh:mm");//格式化时间
                var visit_dom = '<tr>'
                                +   '<td class="text-left">' + visit.DestServer + '</td>'
                                +   '<td class="text-left">' + visit.FromAP + '</td>'
                                +   '<td class="text-left">' + visit.LanIP + '</td>'
                                +   '<td class="text-left">' + visit.Mac + '</td>'
                                +   '<td class="text-left">' + date_time + '</td>'
                                + '</tr>';
                $(visit_dom).appendTo($('#visits_container'));
            }
            Ha.mask.hide();
        }
    }
  })();