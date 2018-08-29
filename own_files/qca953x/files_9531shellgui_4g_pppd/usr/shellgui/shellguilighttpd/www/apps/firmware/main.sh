#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
save_file_and_do() {
if [ "${FORM_action}" = "prerestore" ]; then
_LANG_page="$_LANG_Form_restore_factory"
_LANG_button="$_LANG_Form_restore_factory"
_action="restore"
else
_LANG_page="$_LANG_Form_flash_firmware"
_LANG_button="$_LANG_Form_flash_firmware"
_action="flash"
fi
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'","url":"/?app=firmware"},"3":{"title":"'${_LANG_page}'"}}'
if [ -n "${FORM_file}" ]; then
%>
    <div class="bd">
    <div style="padding: 20px 0 ">
    <h4><%= ${_LANG_Form_Firmware_is_flashable_whatever_flash} %></h4>
    <p>
    	<label><%= ${_LANG_Form_File_name} %>:</label>
    	<%= $FORM_file %>
    	<label style="padding-left: 5px"><%= ${_LANG_Form_File_size} %>:</label>
    	<font color="blue"><% du -sh /tmp/firmware.img | awk '{printf $1}' %></font>
    </p>
    <p>
    	<label>MD5:</label>
    	<font color="green"><% md5sum /tmp/firmware.img | cut -d ' ' -f1 %></font>
    </p>
    </div>
    </div>
<%
fi
%>
<div class="content">
  <form id="sysupgrade" name="sysupgrade" method="post" action="#" class="form">
    <table class="table table-condensed">
      <caption><%= ${_LANG_Form_Save_file} %></caption>
      <thead>
        <tr>
          <th></th>
          <th><%= ${_LANG_Form_File} %></th>
          <th><%= ${_LANG_Form_Note} %></th>
        </tr>
      </thead>
      <tbody class="file-list">
<%
cd /usr/shellgui/shellguilighttpd/www/apps
result=$(for app in $(find -type d -maxdepth 1 -mindepth 1 | sed 's#\.\/##g'); do
config_str=$(jshon -e "keep_files" -Q < ${app}/config.json)
files=$(echo "$config_str" | jshon  -l)
if [ ${files} -gt 0 ]; then
	for file in $(seq 0 $(expr ${files} - 1)); do
		file_name=$(echo "$config_str" | jshon -e ${file} -e "file" -u)
		echo "$file_list" | grep -q "^${file_name}$" && continue

		eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_Keep_' ${app} $COOKIE_lang)
		
		note=$(eval echo '$'$(echo "$config_str" | jshon -e ${file} -e "note" -u))
		# note=$(echo "$config_str" | jshon -e ${file} -e "note" -u)
		priority_keep=$(echo "$config_str" | jshon -e ${file} -e "priority_keep" -u)
		file_list="${file_list}
${file_name}"
		echo "${app}|||${file_name}|||${note}|||${priority_keep}"
	done
fi
done)
echo "$result" | awk 'BEGIN{ FS="[|]{3}"; } {
	printf "<tr><td><input type=\"checkbox\" name=\"bak_file_";
	printf int(rand()*100%7+1);
	printf "\" value=\""$2"\""; if ($4 > 0) {printf "checked=\"checked\"" };
	printf "></td><td>"$2"</td><td>"$3"</td></tr>\n";
}'
%>
        <tr>
          <td>
            <label for="select_all">
              <input type="checkbox" id="select_all" checked>
              <span><%= ${_LANG_Form_SelectAll} %></span>
            </label>
          </td>
          <td colspan="2">
            <button type="submit" class="btn btn-danger btn-sm"><%= $_LANG_button %></button>
          </td>
        </tr>
      </tbody>
    </table>
    <input type="hidden" name="action" value="<%= $_action %>">
  </form>
</div>
<%
}
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
  <div class="container">
<%
if [ "$FORM_action" = "prerestore" ]; then
  save_file_and_do
elif [ "$FORM_action" = "preflash" ]; then
  save_file_and_do
else
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}'
echo 3 > /proc/sys/vm/drop_caches
rm -f /tmp/lighttpd-upload*
%>
    <div class="content">
      <div class="app row app-item">
        <h2 class="app-sub-title col-sm-12"><%= $_LANG_Form_restore_factory %></h2>
        <div class="col-sm-offset-2 col-sm-10 text-left">
          <p><%= $_LANG_Form_restore_device_to_factory %>:</p>
          <a href="/?app=firmware&action=prerestore"><button class="btn btn-default" type="button"><%= $_LANG_Form_apply %></button></a>
        </div>
      </div>
      <hr>
      <div class="app row app-item">
        <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_upgrade_firmware} %></h2>
        <div class="col-sm-offset-2 col-sm-10 text-left">
          <div id="uploader_container" data-label="<%= ${_LANG_Form_upload_firmware} %>" data-action="/apps/firmware/upload.cgi?lang=<%= $COOKIE_lang %>"></div>
        </div>
      </div>
    </div>
<%
fi
%>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.Upload_file = '<%= ${_LANG_Form_upload_firmware} %>';
UI.Browse = '<%= ${_LANG_Form_Browse} %>';
UI.Upload = '<%= ${_LANG_Form_Upload} %>';
UI.File_Size = '<%= ${_LANG_Form_File_Size} %>';
UI.File_Format = '<%= ${_LANG_Form_File_Format} %>';
UI.Upload_Progress = '<%= ${_LANG_Form_Upload_Progress} %>';
</script>
<% /usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/home/common/js/jquery.form.js"></script>
<script>
  var callback = function(xhr){
    console.log(xhr.responseText);
    var data = $.parseJSON(xhr.responseText);
    data.status = parseInt(data.status);
    data.seconds = parseInt(data.seconds);
    Ha.showNotify(data);
    setTimeout(function(){
      window.location.href = data.jump_url;
    },data.seconds);
  };
  Components.makeUploader($('#uploader_container'),callback);
  (function(){
    $('#sysupgrade').submit(function(e){
      e.preventDefault();
      var data = "app=firmware&"+$(this).serialize();
      Ha.disableForm('sysupgrade');
      Ha.ajax('/','json',data,'post','sysupgrade',Ha.showNotify,1);

    });
    $('#select_all').click(function(){
      $('tbody :checkbox').prop('checked',$('#select_all').prop('checked'));
    });
  })();
</script>
</body>
</html>
