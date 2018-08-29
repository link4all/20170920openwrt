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
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<% /usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
<%in /usr/shellgui/shellguilighttpd/www/apps/disk/html_lib.sh %>
<% which fdisk &>/dev/null && disk_part_edit %>
    	<div class="row">
    		<div class="app app-item col-lg-12">
		        <div class="row">
		            <div class="col-sm-12">
		                <h2 class="app-sub-title"><%= ${_LANG_App_name} %></h2>
		            </div>
		            <div class="col-sm-offset-1 col-sm-11">
		            	<div class="table-responsive">
		            		<table class="table">
		            			<thead class="hidden">
		            				<tr>
		            					<th><%= ${_LANG_Form_Device_info} %></th>
		            					<th><%= ${_LANG_Form_Device} %></th>
		            					<th><%= ${_LANG_Form_Type} %></th>
		            					<th><%= ${_LANG_Form_Mount_Point} %></th>
		            					<th><%= ${_LANG_Form_Enabled} %></th>
		            					<th><%= ${_LANG_Form_Detail} %></th>
		            				</tr>
		            			</thead>
		            			<tbody id="disk_container"></tbody>
		            		</table>
		            	</div>
	                </div>
	            </div>
	        </div>
    	</div>
    	<hr>
    	<div class="row">
    		<button class="btn btn-warning btn-lg pull-right" id="reset_page_btn"><%= ${_LANG_Form_Reset} %></button>
    		<button class="btn btn-default btn-lg pull-right" id="save_page_btn"><%= ${_LANG_Form_Apply} %></button>
    	</div>
	</div> 
</div>
<div class="modal  fade in" id="add_new_partition_modal">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">×</span></button>
				<h4 class="modal-title">新建分区</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal">
					<div class="form-group">
						<label for="size" class="control-label col-sm-3">容量</label>
						<div class="col-sm-9">
							<input type="text" class="form-control" name="size" id="size" >
							<span class="help-block">+512M 或者 为空</span>
						</div>
					</div>
					<div class="form-group">
						<label for="partition_number" class="control-label col-sm-3">序号</label>
						<div class="col-sm-9">
							<input type="text" class="form-control" name="partition_number" id="partition_number" >
							<span class="help-block">用于标定分区序号,如:/dev/sda[1]</span>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" id="add_submit" data-dev="">Sure</button>
				<button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>
<div class="modal  fade in" id="format_partition_modal">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">×</span></button>
				<h4 class="modal-title">格式化</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal">
					<div class="form-group">
						<label for="type" class="control-label col-sm-3">格式</label>
						<div class="col-sm-9">
							<select id="type" name="type" class="form-control">
								<% for format in $(find /usr/sbin/ /sbin -name 'mkfs\.*' -maxdepth 1 | cut -d '.' -f2); do %>
								<option value="<%= ${format} %>"><%= ${format} %></option>
								<% done %>
								<option value="swap">swap</option>
							</select>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" id="format_submit" data-part="">Sure</button>
				<button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>
<%	/usr/shellgui/progs/main.sbin h_f
	/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/disk/disk.js"></script>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
</body>
</html>
