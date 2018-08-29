#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
    <% /usr/shellgui/progs/main.sbin h_sf %>
    <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
    	<div class="row">
    		<div class="col-sm-12">
	    		<form class="form-inline" id="path-submit-form" style="display: inline-block">
					<input type="text" id="path-search-input" class="form-control input-sm" value="/">
					<button type="submit" class="btn btn-default btn-sm" id="path-search-btn">enter</button>
					<span class="help-block hidden">请输入正确的路径</span>
				</form>
				<button class="btn btn-default btn-sm" id="uplevel-btn">向上</button>
				<button class="btn btn-default btn-sm" id="upload-btn" data-toggle="modal" data-target="#uploadModal">上传</button>
    		</div>
    		<div class="col-sm-12 table-responsive">
				<table class="table">
					<thead>
						<th>文件描述</th>
						<th>文件名</th>
						<th>操作</th>
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
        <h4 class="modal-title">上传文件</h4>
      </div>
      <form>
	      <div class="modal-body">
	        <p class="text-danger confirm-text">目标路径：</p>
	        <form class="form" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="apps/filebrowser/uplod.cgi">
	        	<input type="hidden" name="path" id="upload_target">
				<div class="form-group upload-ctrl">
					<label for="upload-fw" class="">
						<p class="btn btn-info">浏览</p>
						<p class="file-name" id="file_name">上传文件</p>
					</label>
					<input type="file" id="upload-fw" name="file" class="form-control fw-file">
				</div>
				<div class="form-group">
					<button type="submit" class="btn btn-default">上传</button>
					<span class="upload-progress-bar hidden"><span></span></span>
				</div>
			</form>
			<div id="file_info" class="hidden">
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
	      <div class="modal-footer">
	        <button type="button" class="btn btn-default" id="upload_btn">确定</button>
	        <button type="button" class="btn btn-warning" data-dismiss="modal">取消</button>
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
        <h4 class="modal-title">确认框</h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text">确定删除文件？</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_btn">确定</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">取消</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="authModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">权限修改</h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text">文件:</p>
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
        <button type="button" class="btn btn-default" id="auth_btn">确定</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">取消</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="editModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">文件编辑</h4>
      </div>
      <div class="modal-body">
        <p class="text-center text-danger confirm-text">文件:</p>
        <div>
        	<textarea id="file-data-container" class="form-control" rows="6"></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="edit_file_btn">确定</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">取消</button>
      </div>
    </div>
  </div>
</div>

<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
	var old_path='<%= ${FORM_old_path:-/tmp} %>';
</script>
<script src="/apps/filebrowser/filebrowser.js"></script>
</body>
</html>