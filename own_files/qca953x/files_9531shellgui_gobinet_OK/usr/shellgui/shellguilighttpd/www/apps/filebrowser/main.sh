#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
    	<div class="row">
    		<div class="col-sm-12">
	    		<form class="form-inline" id="path-submit-form" style="display: inline-block">
					<input type="text" id="path-search-input" class="form-control input-sm" value="/">
					<button type="submit" class="btn btn-default btn-sm" id="path-search-btn"><%= ${_LANG_Form_Enter} %></button>
					<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Path} %></span>
				</form>
				<button class="btn btn-default btn-sm" id="uplevel-btn"><span class="icon-arrow-up"></span></button>
				<button class="btn btn-default btn-sm" id="upload-btn" data-toggle="modal" data-target="#uploadModal"><%= ${_LANG_Form_Upload} %></button>
    		</div>
    		<div class="col-sm-12 table-responsive">
				<table class="table">
					<thead>
						<th><%= ${_LANG_Form_File_Desc} %></th>
						<th><%= ${_LANG_Form_File_Name} %></th>
						<th><%= ${_LANG_Form_Operation} %></th>
					</thead>
					<tbody id="data-container"></tbody>
				</table>
    		</div>
    	</div>
	</div> 
</div>
<div class="modal fade" id="uploadModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><%= ${_LANG_Form_Upload_File} %></h4>
      </div>
      <form class="form" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="apps/filebrowser/uplod.cgi">
        <div class="modal-body">
          <p class="text-danger confirm-text"><%= ${_LANG_Form_Dest_Path} %>:</p>
	        	<input type="hidden" name="path" id="upload_target">
				<div class="form-group uploader-ctrl">
					<label for="upload-fw" class="">
						<p class="btn btn-info"><%= ${_LANG_Form_Browse} %></p>
						<p class="file-name" id="file_name"><%= ${_LANG_Form_Upload_File} %></p>
					</label>
					<input type="file" id="upload-fw" name="file" class="form-control uploader_input">
				</div>
				<div class="form-group">
					<span class="upload-progress-bar hidden"><span></span></span>
				</div>
			<div id="file_info" class="hidden">
				<label for=""><%= ${_LANG_Form_File_Size} %>:</label>
				<span id="file_size"></span>
				<br>
				<label for=""><%= ${_LANG_Form_File_Type} %>:</label>
				<span id="file_type"></span>
				<br>
				<label for=""><%= ${_LANG_Form_Upload_progress} %>:</label>
				<span id="progress-text">0%</span>
			</div>
	      </div>
	      <div class="modal-footer">
	        <button type="submit" class="btn btn-default" id="submit-file-btn" disabled><%= ${_LANG_Form_Apply} %></button>
	        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
	      </div>
      </form>
    </div>
  </div>
</div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><%= ${_LANG_Form_Del_file} %></h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text"><%= ${_LANG_Form_Confirm} ${_LANG_Form_Del_file} %>?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="authModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><%= ${_LANG_Form_Modify_Privilege} %></h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text"><%= ${_LANG_Form_File} %>:</p>
        <div class="text-center" id="auth-btn-group">
        	<div class="btn-group">
			  <button type="button" class="btn">r</button>
			  <button type="button" class="btn">w</button>
			  <button type="button" class="btn">x</button>
			</div>
			<div class="btn-group">
			  <button type="button" class="btn">r</button>
			  <button type="button" class="btn">w</button>
			  <button type="button" class="btn">x</button>
			</div>
			<div class="btn-group">
			  <button type="button" class="btn">r</button>
			  <button type="button" class="btn">w</button>
			  <button type="button" class="btn">x</button>
			</div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="auth_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="editModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title"><%= ${_LANG_Form_Edit_file} %></h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text"><%= ${_LANG_Form_File} %>:</p>
        <div>
        	<textarea id="file-data-container" class="form-control" rows="6"></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="edit_file_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
	var old_path='<%= ${FORM_old_path:-/tmp} %>';
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<script src="/apps/home/common/js/jquery.form.js"></script>
<script src="/apps/filebrowser/filebrowser.js"></script>
</body>
</html>
