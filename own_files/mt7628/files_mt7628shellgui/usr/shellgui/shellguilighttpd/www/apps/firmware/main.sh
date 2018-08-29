#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
# 子页面头
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
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app=firmware"}, "3": {"title": "'${_LANG_page}'"}}'
if [ -n "${FORM_file}" ]; then
	. /lib/functions.sh;
	include /lib/upgrade;
	platform_check_image /tmp/firmware.img >/dev/null 2>&1 ;
	if [ $? -eq 0 ]; then
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
<% else %>
<div class="bd">
  <div>
    <h4><%= ${_LANG_Form_Firmware_is_unflashable} %>.</h4>
    <a href="/?app=firmware"><button type="button" class="btn btn-primary btn-sm cancle-all"><%= ${_LANG_Form_Back} %></button></a>
  </div>
</div>
<%
	return
	fi
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
echo "$result" | awk 'BEGIN{
	FS="[|]{3}";
}
{
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
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
  <div class="container">
<%
if [ "$FORM_action" = "prerestore" ]; then
  save_file_and_do
elif [ "$FORM_action" = "preflash" ]; then
  save_file_and_do
else
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
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
          <form class="form" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="/apps/firmware/upload.cgi">
            <div class="form-group upload-ctrl">
              <p><%= ${_LANG_Form_upload_firmware} %>:</p>
              <label for="upload-fw" class="">
                <p class="btn btn-info"><%= ${_LANG_Form_Browse} %></p>
                <p class="file-name" id="file_name"><%= ${_LANG_Form_upload_firmware} %></p>
              </label>
              <input type="file" id="upload-fw" name="file" class="form-control fw-file">
            </div>
            <div class="form-group">
              <button type="submit" class="btn btn-default"><%= ${_LANG_Form_Upload} %></button>
              <span class="upload-progress-bar hidden"><span></span></span>
            </div>
          </form>
          <div id="file_info" class="hidden">
            <!-- <label for="">文件名：</label>
            <span id="file_name"></span>
            <br> -->
            <label for="">文件尺寸：</label>
            <span id="file_size"></span>
            <br>
            <label for="">文件格式：</label>
            <span id="file_type"></span>
            <br>
            <label for="">上传进度：</label>
            <span id="progress-text">0%</span>
          </div>
        </div>
      </div>
    </div>
<%
fi
%>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end
%>
<script>
  (function(){
    var name;
    $('#upload-fw').change(function(){
      $('[type="submit"]').one('click',function(){
        $('#uploader').submit();
      });
      var file = $(this).val();
      var file_name = file.split('\\').pop();
      $('#file_name').html(file_name);
      var firmware = $(this).get(0).files[0];
      if (firmware) {
        $('#file_info').removeClass('hidden');
        var fileSize = 0;
        if (firmware.size > 1024 * 1024)
          fileSize = (Math.round(firmware.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
        else
          fileSize = (Math.round(firmware.size * 100 / 1024) / 100).toString() + 'KB';

        // $('#file_name').html(firmware.name || '');
        $('#file_size').html(fileSize || '');
        $('#file_type').html(firmware.type || '');
      }
    });
    $('#uploader').submit(function(){
      uploadFile('upload-fw','/apps/firmware/upload.cgi');
      setProgressLength();
      $('[type="submit"]').click(function(){
        return false;
      });
      //return false;
    })
    $('#sysupgrade').submit(function(e){
      e.preventDefault();
      var data = "app=firmware&"+$(this).serialize();
      Ha.disableForm('sysupgrade');
      Ha.ajax('/','json',data,'post','sysupgrade',Ha.showNotify,1);

    });
    $('#select_all').click(function(){
      $('tbody :checkbox').prop('checked',$('#select_all').prop('checked'));
    });
    function setProgressLength(){
      var length = $('#file_name').width();
      if(length < 208){
        length = 208;
      }
      $('.upload-progress-bar').css('width',length).removeClass('hidden');
    }
  })();
</script>
</body>
</html>