#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
if [ "${FORM_action}" = "dl_cert" ] &>/dev/null; then
	cat /usr/shellgui/shellguilighttpd/www/apps/port-remote/certs/$FORM_cert_file | /usr/shellgui/progs/main.sbin http_download remote-port-$FORM_cert_file
	exit
fi
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
				<h4><%= ${_LANG_Form_Enabled} %></h4>
				<div class="row">
					<div class="col-sm-offset-1 col-sm-11">
		    			<div class="switch-ctrl head-switch" id="page-enabled"style="margin: 0;">
		                    <input type="checkbox" id="switch_port_remote" checked="">
		                    <label for="switch_port_remote"><span></span></label>
		                </div>
					</div>
				</div>
    		</div>
    		<hr>
    		<div class="col-sm-12 table-responsive">
				<table class="table">
					<h4><%= ${_LANG_Form_Server} %></h4>
					<thead>
						<tr>
							<th><%= ${_LANG_Form_Communication_Port} %></th>
							<th><%= ${_LANG_Form_Bind_Port} %></th>
							<th><%= ${_LANG_Form_Match_Code} %></th>
							<th><%= ${_LANG_Form_Certificate_File} %></th>
							<th><%= ${_LANG_Form_Enabled} %></th>
							<th><%= ${_LANG_Form_Option} %></th>
						</tr>
					</thead>
					<tbody id="server-container"></tbody>
					<tfoot>
						<tr>
							<td colspan="6">
								<button class="btn btn-success" id="add-server-btn" data-toggle="modal" data-target="#serverModal"><%= ${_LANG_Form_Add} %></button>
							</td>
						</tr>
					</tfoot>
				</table>
    		</div>
    		<hr>
       		<div class="col-sm-12 table-responsive">
				<table class="table">
					<h4><%= ${_LANG_Form_Client} %></h4>
					<thead>
						<tr>
							<th><%= ${_LANG_Form_Communication_Port} %></th>
							<th><%= ${_LANG_Form_Port_Preforward} %></th>
							<th><%= ${_LANG_Form_Local_Host} %></th>
							<th><%= ${_LANG_Form_Remote_Host} %></th>
							<th><%= ${_LANG_Form_Match_Code} %></th>
							<th><%= ${_LANG_Form_Certificate_File} %></th>
							<th><%= ${_LANG_Form_Enabled} %></th>
							<th><%= ${_LANG_Form_Option} %></th>
						</tr>
					</thead>
					<tbody id="client-container"></tbody>
					<tfoot>
						<tr>
							<td colspan="8">
								<button class="btn btn-success" id="add-client-btn" data-toggle="modal" data-target="#clientModal"><%= ${_LANG_Form_Add} %></button>
							</td>
						</tr>
					</tfoot>
				</table>
    		</div>
    		<div class="col-sm-12 table-responsive">
				<table class="table">
					<h4><%= ${_LANG_Form_Certificate_File} %></h4>
					<thead>
						<tr>
							<th><%= ${_LANG_Form_File_Name} %></th>
							<th><%= ${_LANG_Form_Download} %></th>
							<th><%= ${_LANG_Form_Del} %></th>
						</tr>
					</thead>
					<tbody id="certs-container"></tbody>
					<tfoot>
						<tr>
							<td colspan="3">
								<button class="btn btn-success" id="add-cert-btn" data-toggle="modal" data-target="#certModal"><%= ${_LANG_Form_Generate} %></button>
								<button class="btn btn-primary" id="upload-cert-btn" data-toggle="modal" data-target="#uploadModal"><%= ${_LANG_Form_Upload_File} %></button>
							</td>
						</tr>
					</tfoot>
				</table>
    		</div>
    		<hr>
    		<div class="col-sm-12 ">
    			<button class="btn btn-lg btn-warning pull-right" id="resetPage-btn"><%= ${_LANG_Form_Reset} %></button>
    			<button class="btn btn-lg btn-default pull-right" id="savePage-btn" data-toggle="modal" data-target="#confirmModal"><%= ${_LANG_Form_Apply} %></button>
    		</div>
    	</div>
	</div> 
</div>

<div class="modal fade" id="certModal" tabindex="-1">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id="">Certs</h4>
			</div>
			<form id="cert-form" class="form-horizontal">
			<div class="modal-body">
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Certificate_Name} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="name" data-validate="vaLength-vaCCode" id="SSL_name">
						<span class="help-block hidden"><%= ${_LANG_Form_File_Name} %><%= ${_LANG_Form_Can_not_be_empty} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Size} %></label>
					<div class="col-sm-8">
						<select type="number" class="form-control" name="SSL_Size">
							<option value="1024">1024bit</option>
							<option value="2048">2048bit</option>
							<option value="4096">4096bit</option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Expiration} %></label>
					<div class="col-sm-8">
					<div class="input-group">
						<input type="number" class="form-control" name="SSL_Expired_Time" data-validate="vaInt" id="SSL_Expired_Time">
						<span class="input-group-addon"><%= ${_LANG_Form_Days} %></span>
					</div>
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid} %> <%= ${_LANG_Form_Positive_Integer} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Country_Code} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="SSL_C" data-validate="vaCCode-vaLength_0_2" id="SSL_C">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid} %> <%= ${_LANG_Form_Country_Code} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Province} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="SSL_ST">
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Address} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="SSL_L">
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_OrganizationName} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="SSL_O">
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_OrganizationalUnitName} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="SSL_OU">
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_CommonName} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="SSL_CN">
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="submit" class="btn btn-default submit-cert"><%= ${_LANG_Form_Add} %></button>
				<button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
			</div>
			</form>
		</div>
	</div>
</div>

<div class="modal fade" id="serverModal" tabindex="-1">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id="">Server</h4>
			</div>
			<form id="server-form" class="form-horizontal">
			<div class="modal-body">
				<input type="hidden" name="enabled">
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Communication_Port} %></label>
					<div class="col-sm-8">
						<input type="number" class="form-control" name="comm_port" data-validate="vaPort-vaLength" id="server-comm_port">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid}  ${_LANG_Form_Port} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Bind_Port} %></label>
					<div class="col-sm-8">
						<input type="number" class="form-control" name="port" data-validate="vaPort-vaLength" id="server-port">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid}  ${_LANG_Form_Port} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Match_Code} %></label>
					<div class="col-sm-8">
						<input type="number" class="form-control" name="common_num" data-validate="vaInt_0_255-vaLength" id="server-common_num">
						<span class="help-block hidden">0~255</span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Certificate_File} %></label>
					<div class="col-sm-8">
						<select class="form-control cret-select" name="pem"></select>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="submit" class="btn btn-default submit-rule"><%= ${_LANG_Form_Save} %></button>
				<button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
			</div>
			</form>
		</div>
	</div>
</div>

<div class="modal fade" id="clientModal" tabindex="-1">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id="">Client</h4>
			</div>
			<form id="client-form" class="form-horizontal">
			<div class="modal-body">
				<input type="hidden" name="enabled">
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Communication_Port} %></label>
					<div class="col-sm-8">
						<input type="number" class="form-control" name="comm_port" data-validate="vaPort-vaLength" id="client-comm_port">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid}  ${_LANG_Form_Port} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Port_Preforward} %></label>
					<div class="col-sm-8">
						<input type="number" class="form-control" name="port"  data-validate="vaPort-vaLength" id="client-port">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid}  ${_LANG_Form_Port} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Local_Host} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="src_host"  data-validate="vaIPorDomain-vaLength" id="client-src_host">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid}  ${_LANG_Form_Local_Host} %>(127.0.0.1|192.168.1.100)</span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Remote_Host} %></label>
					<div class="col-sm-8">
						<input type="text" class="form-control" name="dest_host" data-validate="vaIPorDomain-vaLength" id="client-dest_host">
						<span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid}  ${_LANG_Form_Remote_Host} %></span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Match_Code} %></label>
					<div class="col-sm-8">
						<input type="number" class="form-control" name="common_num" data-validate="vaInt_0_255-vaLength" id="client-common_num">
						<span class="help-block hidden">0~255</span>
					</div>
				</div>
				<div class="form-group">
					<label class="control-label col-sm-4"><%= ${_LANG_Form_Certificate_File} %></label>
					<div class="col-sm-8">
						<select class="form-control cret-select" name="pem"></select>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="submit" class="btn btn-default submit-rule" id="submit_page"><%= ${_LANG_Form_Save} %></button>
				<button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
			</div>
			</form>
		</div>
	</div>
</div>
<div class="modal fade" id="confirmModal" tabindex="-1">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id=""><%= ${_LANG_Form_Confirm} %></h4>
			</div>
			<div class="modal-body">
				<p id="confirm-text" class="text-center">
					<%= ${_LANG_Form_Confirm_Apply_Setting} %>?
				</p>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" id="confirm-save-btn"><%= ${_LANG_Form_Confirm} %></button>
				<button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
			</div>
		</div>
	</div>
</div>
<div class="modal fade" id="uploadModal" tabindex="-1">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id=""><%= ${_LANG_Form_Upload_File} %></h4>
			</div>
			<form class="form" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="apps/port-remote/upload.cgi">
		        <div class="modal-body">
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
						<label for=""><%= ${_LANG_Form_Upload_Progress} %>:</label>
						<span id="progress-text">0%</span>
					</div>
			    </div>
			    <div class="modal-footer">
			        <button type="submit" class="btn btn-default" id="submit-file-btn" disabled=""><%= ${_LANG_Form_Confirm} %></button>
			        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
			    </div>
		    </form>
		</div>
	</div>
</div>
<% /usr/shellgui/progs/main.sbin h_f %>
<script>
var UI = {};
UI.Edit = '<%= ${_LANG_Form_Edit} %>';
UI.Download = '<%= ${_LANG_Form_Download} %>';
UI.Del = '<%= ${_LANG_Form_Del} %>';
UI.Upload_File = '<%= ${_LANG_Form_Upload_File} %>';
</script>
<% /usr/shellgui/progs/main.sbin h_end %>
<script type="text/javascript" src="/apps/home/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/apps/port-remote/port-remote.js"></script>
</body>
</html>
