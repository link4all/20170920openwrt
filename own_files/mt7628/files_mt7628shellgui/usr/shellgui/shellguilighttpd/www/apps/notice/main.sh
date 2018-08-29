#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${GET_action}" = "notice_unread" ] &>/dev/null; then
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
	shellgui '{"action": "notice_count_unread"}' || printf '{"counts": 0}'
	return
fi
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
email_setting() {
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app=notice"}, "3": {"title": "'"${_LANG_Form_Email_Setting}"'"}}'
eval $(grep -v "#" /usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf | sed -e 's#[ ]*= [ ]*#=#g' -e 's/^/mail_/g' 2>/dev/null)
eval $(sed -e 's#^-x[ ]*#mail_TIMEOUT=#g' \
-e 's#^--bcc[ ]*#mail_BCC=#g' \
-e 's#^--cc[ ]*#mail_CC=#g' \
-e 's#^-s[ ]*#mail_subject=#g' /usr/shellgui/shellguilighttpd/www/apps/notice/email/email_extra.conf | grep "^mail_" ) %>
    <div class="row">
  		<div class="col-sm-6">
        <form class="form-horizontal" name="doemail_main_setting" id="doemail_main_setting">
          <div class="form-group">
        	<label for="nickname" class="col-sm-4 control-label"><%= ${_LANG_Form_NickName} %></label>
        	<div class="col-sm-8">
        	  <input type="text" required class="form-control" name="MY_NAME" id="nickname" value="<%= ${mail_MY_NAME} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_NickName} %></span>
        	</div>
          </div>
          <div class="form-group">
        	<label for="email" class="col-sm-4 control-label">Email</label>
        	<div class="col-sm-8">
        	  <input type="email" required class="form-control" name="MY_EMAIL" id="email" placeholder="Email" value="<%= ${mail_MY_EMAIL} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} %> Email</span>
        	</div>
          </div>
          <div class="form-group">
        	<label for="SMTP_AUTH_USER" class="col-sm-4 control-label"><%= ${_LANG_Form_Username} %></label>
        	<div class="col-sm-8">
        	  <input type="text" required class="form-control" name="SMTP_AUTH_USER" id="SMTP_AUTH_USER" placeholder="Username" value="<%= ${mail_SMTP_AUTH_USER} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Username} %></span>
        	</div>
          </div>
          <div class="form-group">
        	<label for="SMTP_AUTH_PASS" class="col-sm-4 control-label"><%= ${_LANG_Form_Password} %></label>
        	<div class="col-sm-8">
        	  <input type="password" required class="form-control" name="SMTP_AUTH_PASS" id="SMTP_AUTH_PASS" placeholder="Password" value="<%= ${mail_SMTP_AUTH_PASS} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Password} %></span>
        	</div>
          </div>
          <div class="form-group">
        	<label for="SMTP_SERVER" class="col-sm-4 control-label"><%= ${_LANG_Form_SMTP_server} %></label>
        	<div class="col-sm-8">
        	  <input type="text" required class="form-control" name="SMTP_SERVER" id="SMTP_SERVER" placeholder="SMTP Server IP" value="<%= ${mail_SMTP_SERVER} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_SMTP_server} %></span>
        	</div>
          </div>
          <div class="form-group">
        	<label for="SMTP_PORT" class="col-sm-4 control-label"><%= ${_LANG_Form_SMTP_server_port} %></label>
        	<div class="col-sm-8">
        	  <input type="number" required class="form-control" name="SMTP_PORT" id="SMTP_PORT" placeholder="SMTP Server Port" value="<%= ${mail_SMTP_PORT} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_SMTP_server_port} %></span>
        	</div>
          </div>
          <div class="form-group">
          <label for="SMTP_AUTH" class="col-sm-4 control-label"><%= ${_LANG_Form_SMTP_auth_methods} %></label>
        	<div class="col-sm-8">
        		<select name="SMTP_AUTH" class="form-control" id="SMTP_AUTH">
        			<option value="LOGIN" <% [ "${mail_SMTP_AUTH}" = "LOGIN" ] && printf 'selected=""' %>>LOGIN</option>
        			<option value="PLAIN" <% [ "${mail_SMTP_AUTH}" = "PLAIN" ] && printf 'selected=""' %>>PLAIN</option>
        		</select>
        	</div>
          </div>
          <div class="form-group">
        	<label for="USE_TLS" class="col-sm-4 control-label">SMTP TLS</label>
        	<div class="col-sm-8">
        		<select name="USE_TLS" class="form-control" id="USE_TLS">
        			<option value="true" <% [ "${mail_USE_TLS}" = "true" ] && printf 'selected=""' %>>true</option>
        			<option value="false" <% [ "${mail_USE_TLS}" != "true" ] && printf 'selected=""' %>>fails</option>
        		</select>
        	</div>
          </div>
          <div class="form-group">
        	<label for="sig" class="col-sm-4 control-label"><%= ${_LANG_Form_Signature} %></label>
        	<div class="col-sm-8">
        	  <textarea class="form-control" name="sig" id="sig" rows="5" placeholder="Signsture content"><% cat /usr/shellgui/shellguilighttpd/www/apps/notice/email/email.sig %></textarea>
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Signature} %></span>
        	</div>
          </div>
          <div class="form-group">
        	<label for="subject" class="col-sm-4 control-label"><%= ${_LANG_Form_Default_subject} %></label>
        	<div class="col-sm-8">
        	  <input type="text" required class="form-control" name="subject" id="subject" placeholder="Default subject" value="<%= ${mail_subject} %>">
            <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Default_subject} %></span>
        	</div>
          </div>
        	<div class="form-group">
        		<label for="TIMEOUT" class="col-sm-4 control-label"><%= ${_LANG_Form_Timeout} %></label>
        		<div class="col-sm-8">
        			<div class="input-group">
        				<input type="number" required class="form-control" id="TIMEOUT" name="TIMEOUT" placeholder="20" value=<%= ${mail_TIMEOUT} %>>
        				<div class="input-group-addon"><%= ${_LANG_Form_Secs} %></div>
        			</div>
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Timeout} %></span>
        		</div>
        	</div>
          <div class="form-group">
        	<div class="col-sm-offset-4 col-sm-8">
        	  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Save} %></button>
        	</div>
          </div>
        </form>
        <hr>
        <form class="form-horizontal" name="email_extra_setting" id="email_extra_setting">
          <caption><%= ${_LANG_Form_Advanced} %></caption>
          <div class="form-group">
          	<label for="CC" class="col-sm-4 control-label"><%= ${_LANG_Form_Copy_to} %></label>
          	<div class="col-sm-8">
          	  <input type="email" class="form-control" name="CC" id="CC" placeholder="example@example.com" value="<%= ${mail_CC} %>">
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Addressee} %></span>
          	</div>
          </div>
          <div class="form-group">
          	<label for="BCC" class="col-sm-4 control-label"><%= ${_LANG_Form_Secret_copy_to} %></label>
          	<div class="col-sm-8">
          	  <input type="email" class="form-control" name="BCC" id="BCC" placeholder="example@example.com" value="<%= ${mail_BCC} %>">
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Addressee} %></span>
          	</div>
          </div>
          <div class="form-group">
          	<div class="col-sm-offset-4 col-sm-8">
          	  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Save} %></button>
          	</div>
          </div>
        </form>
        <form class="form-horizontal" name="email_test" id="email_test">
          <caption><%= ${_LANG_Form_Mail_test} %></caption>
          <div class="form-group">
          	<label for="Addressee" class="col-sm-4 control-label"><%= ${_LANG_Form_Addressee} %></label>
          	<div class="col-sm-8">
          	  <input type="email" required class="form-control" name="Addressee" id="Addressee" placeholder="example@example.com" value="">
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Addressee} %></span>
          	</div>
          </div>
          <div class="form-group">
          	<label for="CC" class="col-sm-4 control-label"><%= ${_LANG_Form_Email_content} %></label>
          	<div class="col-sm-8">
          	  <textarea class="form-control" name="email_test_content" id="sig" rows="5" placeholder="Test Mail content"><%= ${_LANG_Form_Email_content} %></textarea>
             <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Email_content} %></span>
          	</div>
          </div>
          <div class="form-group">
        	<div class="col-sm-offset-4 col-sm-8">
        	  <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Save} %></button>
        	</div>
          </div>
        </form>
      </div>
    </div>
<%
}
	if [ "${GET_action}" = "del_notice" ] &>/dev/null; then
	(for id in $(echo $FORM_ids | grep -Eo [0-9]*); do
		shellgui '{"action": "notice_del_by_id", "id": '${id}'}' &>/dev/null
	done) &
	printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"status": 0, "msg": "${_LANG_Form_successfull_deled}"}
EOF
        exit
    elif [ "${GET_action}" = "mark_read_notice" ] &>/dev/null; then
	(for id in $(echo $FORM_ids | grep -Eo [0-9]*); do
		shellgui '{"action": "notice_mark_read", "id": '${id}'}' &>/dev/null
	done) &
printf "Content-Type: text/html; charset=utf-8\r\n\r\n"
        cat <<EOF
{"status": 0, "msg": "${_LANG_Form_successfull_marked}"}
EOF
        exit
    fi
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}' %>
<body>
<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
  <div class="container">
<%
if [ "$FORM_action" = "email_setting" ]; then
  email_setting
else
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
    <div class="row">
      <div class="app app-item col-lg-12">
          <h2 class="app-sub-title"><%= ${_LANG_Form_Email} %>:
<span><% eval $(grep '^MY_EMAIL' /usr/shellgui/shellguilighttpd/www/apps/notice/email/email.conf | tr -d ' ')
printf "$MY_EMAIL" %></span>
            <small>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <a href="/?app=notice&action=email_setting"><%= ${_LANG_Form_Setting} %>&gt;</a>
            </small>
          </h2>
      </div>
      <hr class="col-sm-12">
      <div class="app app-item col-lg-12">
        <h2 class="app-sub-title"><%= ${_LANG_Form_Notice_list} %></h2>
        <div class="table-responsive">
          <table class="table">
            <thead>
              <tr>
                <th></th>
                <th><%= ${_LANG_Form_Time} %></th>
                <th><%= ${_LANG_Form_Notice} %></th>
                <th><%= ${_LANG_Form_Option} %></th>
              </tr>
            </thead>
            <tbody id="notice_container">
            </tbody>
            <tfoot id="notice_footer" class="hidden">
              <tr>
                <td colspan="4">
                <div class="pull-left">
                  <label for="select_all_notice">
                    <input type="checkbox" id="select_all_notice">
                    <%= ${_LANG_Form_SelectAll} %>
                  </label>
                  <button class="btn btn-xs btn-danger" id="delete_notices_btn"><%= ${_LANG_Form_Delete} %></button>
                  <button class="btn btn-xs btn-info" id="markread_notices_btn"><%= ${_LANG_Form_MarkRead} %></button>
                  </div>
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
        <div class="" id="pager">
        </div>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="single_notice">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="single_notice" data-notice=""></h4>
      </div>
      <div class="modal-body" id="single_notice_content">
      </div>
      <div class="modal-footer">
        <a><button type="button" class="btn btn-info" id="modal_deal_btn"><%= ${_LANG_Form_Deal} %></button></a>
        <button type="button" class="btn btn-danger" data-dismiss="modal" id="modal_delete_btn"><%= ${_LANG_Form_Delete} %></button>
      </div>
    </div>
<% fi %>
  </div>
</div>
<%
/usr/shellgui/progs/main.sbin h_f
if [ "$FORM_action" != "email_setting" ]; then %>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<%
/usr/shellgui/progs/main.sbin h_end '{"js":["/apps/notice/notice.js"]}'
elif [ "$FORM_action" = "email_setting" ]; then
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/notice/email.js"></script>
<% fi %>
</body>
</html>