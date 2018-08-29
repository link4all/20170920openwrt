#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
server_visit_log() {
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'","url":"/?app='${FORM_app}'"},"3":{"title":"'"${_LANG_Form_Servers_visited}"'"}}' %>
    <div class="row">
      <div class="app app-item col-lg-12">
        <h2 class="app-sub-title"><%= ${_LANG_Form_Servers_visited} %></h2>
        <div class="table-responsive">
          <table class="table">
            <thead>
              <tr>
                <th><%= ${_LANG_Form_DestServer} %></th>
                <th><%= ${_LANG_Form_FromAP} %></th>
                <th><%= ${_LANG_Form_LanIP} %></th>
                <th><%= ${_LANG_Form_Mac} %></th>
                <th><%= ${_LANG_Form_Time} %></th>
              </tr>
            </thead>
            <tbody id="visits_container">
            </tbody>
            <tfoot>
            </tfoot>
          </table>
        </div>
        <div id="pager">
        </div>
      </div>
    </div>
<%
}
search_keyword_log() {
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'","url":"/?app='${FORM_app}'"},"3":{"title":"'"${_LANG_Form_Search_Keyword_record}"'"}}' %>
    <div class="row">
      <div class="app app-item col-lg-12">
        <h2 class="app-sub-title"><%= ${_LANG_Form_Search_record} %></h2>
        <div class="table-responsive">
          <table class="table">
            <thead>
              <tr>
                <th><%= ${_LANG_Form_Keyword} %></th>
                <th><%= ${_LANG_Form_FromAP} %></th>
                <th><%= ${_LANG_Form_LanIP} %></th>
                <th><%= ${_LANG_Form_Mac} %></th>
                <th><%= ${_LANG_Form_Time} %></th>
              </tr>
            </thead>
            <tbody id="keywords_container">
            </tbody>
            <tfoot>
            </tfoot>
          </table>
        </div>
        <div id="pager">
        </div>
      </div>
    </div>
<%
}
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"]}'
%>
<body>
<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
  <div id="main">
    <div class="container">
<%
if [ "$FORM_action" = "server_visit_log" ]; then
server_visit_log
elif [ "$FORM_action" = "search_keyword_log" ]; then
search_keyword_log
else
overview=$(shellgui '{"action":"net_record_overview"}')
server_visits=$(echo "$overview" | jshon -e "server_visit_count")
history_clients=$(echo "$overview" | jshon -e "client_count")
search_keywords=$(echo "$overview" | jshon -e "search_keyword")
[ -f /usr/shellgui/shellguilighttpd/www/apps/lan-net-record/F995-net-record.fw.enabled ] && lan_net_record_enabled="checked"
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
      <div class="content">
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Lan_net_record_overview} %></h2>
          <div class="col-sm-offset-2 col-sm-10">
            <table class="table table-hover">
              <tbody>
                <tr>
                  <th><%= ${_LANG_Form_Total_number_of_online_clinet} %>:</th>
                  <td><% grep '0x2.*br-lan$' /proc/net/arp | awk '{print $4}' | sort -n | uniq | wc -l %></td>
                  <th><%= ${_LANG_Form_History_total_number_of_online_clinet} %>:</th>
                  <td><%= ${history_clients} %></td>
                </tr>
                <tr>
                  <th><%= ${_LANG_Form_Total_number_of_servers_visited} %>:</th>
                  <td><%= ${server_visits} %></td>
                  <th><%= ${_LANG_Form_Total_number_of_search_keywords} %>:</th>
                  <td><%= ${search_keywords} %></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <hr>
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Lan_net_record_setting} %></h2>
          <div class="col-sm-offset-2 col-sm-10" style="text-align: left;">
            <div>
              <strong class="pull-left"><%= ${_LANG_Form_Enable_Lan_net_record_setting} %>:&nbsp;&nbsp;</strong>
              <div class="switch-ctrl switch-sm">
                <input type="checkbox" name="" id="switch-log" value="" <%= ${lan_net_record_enabled} %>>
                <label for="switch-log"><span></span></label>
              </div>
            </div>
          </div>
        </div>
        <hr>
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_View_Lan_net_record} %></h2>
          <div class="col-sm-offset-2 col-sm-10"  style="text-align: left;">
            <div>
              <strong class="pull-left"><%= ${_LANG_Form_View_all_Lan_net_record} %>:&nbsp;&nbsp;</strong>
              <a href="/?app=lan-net-record&action=server_visit_log"><%= ${_LANG_Form_Enter} %>&gt;</a>
            </div>
            <div>
			  <strong class="pull-left"><%= ${_LANG_Form_View_all_search_keywords} %>:&nbsp;&nbsp;</strong>
              <a href="/?app=lan-net-record&action=search_keyword_log"><%= ${_LANG_Form_Enter} %>&gt;</a>
            </div>
            <div>
            </div>
          </div>
        </div>
      </div>
<% fi %>
  </div>
</div>	<!-- id="main" -->
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end
if [ "$FORM_action" = "server_visit_log" ]; then %>
<script src="/apps/lan-net-record/net_record.js"></script>
<% elif [ "$FORM_action" = "search_keyword_log" ]; then %>
<script src="/apps/lan-net-record/keywords_record.js"></script>
<% else %>
<script>
  (function(){
    $('#switch-log').click(function(){
      var checked = $(this).prop('checked');
      var enable;
      if(checked){
        enable = 1;
      }else{
        enable = 0;
      }
      $.post('/','app=lan-net-record&action=net_record_enable&enabled=' + enable,Ha.showNotify,'json');
    });
  })();
</script>
<% fi %>
</body>

</html>
