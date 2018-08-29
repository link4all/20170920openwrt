<%
html_main() {
ac_overview_str=$(shellgui '{"action":"ac_overview"}')
shellgui_str=$(jshon -F /usr/shellgui/shellgui.conf)
username=$(echo "$shellgui_str" | jshon -e "mqtt" -e "username" -u)
password=$(echo "$shellgui_str" | jshon -e "mqtt" -e "password" -u)
mqtt_port=$(echo "$shellgui_str" | jshon -e "mqtt" -e "server_port" -u)
mqttsn_port=$(echo "$shellgui_str" | jshon -e "mqtt" -e "server_port" -u)
%>
<div class="content">
	<div class="app row app-item">
		<h2 class="app-sub-title col-sm-12">AC 设置</h2>
		<div class="col-sm-offset-1 col-sm-6 text-left">
		<form class="form-horizontal text-left" id="set_ac">
			<fieldset id="set_dnscdn_form">
				<div class="form-group">
					<label class="col-sm-4 control-label">AC 服务</label>
					<div class="col-sm-8">
					  <div class="switch-ctrl head-switch">
						  <input type="checkbox" name="enable_ac_service" id="switch_enable_ac_service" value="1" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/ac-set/ac.enabled ] && printf 'checked' %>>
						  <label for="switch_enable_ac_service"><span></span></label>
					  </div>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-4 control-label">是否网关</label>
					<div class="col-sm-8">
					  <div class="switch-ctrl head-switch">
						  <input type="checkbox" name="is_gateway" id="switch_is_gateway" value="1" <% [ -f /usr/shellgui/shellguilighttpd/www/apps/ac-set/ac.is_gateway ] && printf 'checked' %>>
						  <label for="switch_is_gateway"><span></span></label>
					  </div>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-4 control-label">mqtt Port</label>
					<div class="col-sm-8">
						<input type="text" class="form-control" id="mqtt_port" name="mqtt_port" value="<%= $mqtt_port %>" placeholder="1883">
						<span class="help-block hidden">mqtt Port</span>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-4 control-label">mqtt-sn Port</label>
					<div class="col-sm-8">
						<input type="text" class="form-control" id="mqttsn_port" name="mqttsn_port" value="<%= $mqttsn_port %>" placeholder="1883">
						<span class="help-block hidden">mqtt-sn Port</span>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-4 control-label">mqtt通信用户名</label>
					<div class="col-sm-8">
						<input type="text" class="form-control" id="username" name="username" value="<%= $username %>" placeholder="apuser">
						<span class="help-block hidden">mqtt通信用户名</span>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-4 control-label">mqtt通信密码</label>
					<div class="col-sm-8">
						<input type="text" class="form-control" id="password" name="password" value="<%= $password %>" placeholder="apuserpassword1">
						<span class="help-block hidden">mqtt通信密码</span>
					</div>
				</div>

				<div class="form-group">
					<div class="col-sm-offset-4 col-sm-8">
						<button type="submit" id="submit_btn" class="btn btn-default">应用</button>
					</div>
				</div>
			</fieldset>
		</form>
		</div>
	</div>
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12">数量/流量</h2>
          <div class="col-sm-offset-2 col-sm-10">
            <table class="table table-hover text-left">
              <tbody>
                <tr>
                  <td>总AP数量:</td>
                  <td><% echo "$ac_overview_str" | jshon -e "ap_total_cnt" -u %></td>
                </tr>
                <tr>
                  <td>启用AP数量:</td>
                  <td><% echo "$ac_overview_str" | jshon -e "ap_enabled_cnt" -u %></td>
                </tr>
                <tr>
                  <td>在线AP数量:</td>
                  <td><% echo "$ac_overview_str" | jshon -e "ap_online_cnt" -u %></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <hr>
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12">上网记录设置</h2>
          <div class="col-sm-offset-2 col-sm-10">
            <table class="table table-hover text-left">
              <tbody>
                <tr>
                  <td>历史客户端数量</td>
                  <td><% echo "$ac_overview_str" | jshon -e "clients_cnt" -u %></td>
                </tr>
                <tr>
                  <td>当前客户端数量</td>
                  <td><% echo "$ac_overview_str" | jshon -e "clients_online_cnt" -u %></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <hr>
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12">上网记录查看</h2>
          <div class="col-sm-offset-2 col-sm-10">
            <div class="text-left">
              <strong>进入查看上网记录:&nbsp;&nbsp;</strong>
              <a href="/?app=lan-net-record">
              <button type="button" class="btn btn-default btn-xs">进入&gt;</button>
              </a>
            </div>
          </div>
        </div>
        <hr>
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12">AP 列表设置</h2>
          <div class="col-sm-offset-2 col-sm-10">
            <div class="text-left">
              <strong>进入AP列表并管理所有AP:&nbsp;&nbsp;</strong>
              <a href="/?app=ac-set&action=aplist_cp">
              <button type="button" class="btn btn-default btn-xs">进入&gt;</button>
              </a>
            </div>
          </div>
        </div>
      </div>
      <hr>
<%
}
aplist_cp() {
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'","url":"/?app=ac-set"},"3":{"title":"'${_LANG_Form_AP_list_control}'"}}'
%>
<div class="row">
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="icon-running text-success"></span></label>
      正常运行
  </div>
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="icon-available text-info"></span></label>
      可使用
  </div>
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="icon-forbidden text-danger"></span></label>
      已禁用
  </div>
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="icon-offline text-warning"></span></label>
      已离线
  </div>
</div>
<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th></th>
                <th colspan="2">Status</th>
                <th>Desc/Edit</th>
                <th>MAC/IP</th>
                <th>SSID</th>
                <th>ENC/KEY</th>
                <th>Brandwidth</th>
                <th>quota</th>
				<th>版本/其他</th>
            </tr>
        </thead>
        <tbody id="ac_container"></tbody>
        <tfoot>
            <tr id="operate_btn">
                <td colspan="10">
                    <label>
                        <input type="checkbox" id="selectAll">
                        全选
                    </label>&nbsp;&nbsp;&nbsp;&nbsp;
                    <div class="btn-group">
                        <button id="reboot_btn" type="button" class="btn btn-danger btn-sm" disabled>重启</button>
                        <button id="disable_btn" type="button" class="btn btn-default btn-sm" disabled>禁用</button>
                        <button id="enable_btn" type="button" class="btn btn-default btn-sm" disabled>启用</button>
                    </div>
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-sm" data-toggle="modal" data-target="#restoreModal" disabled>恢复出厂设置</button>
                        <button type="button" id="upload_fw_btn" class="btn btn-default btn-sm" data-toggle="modal" data-target="#uploadFWModal" disabled>上传固件</button>
                    </div>
                    <button type="button" class="btn btn-default btn-sm" data-toggle="modal" data-target="#ssidSetModal" disabled>SSID设置</button>
                    <button type="button" class="btn btn-default btn-sm"  data-toggle="modal" data-target="#bwModal" disabled>带宽配额</button>
                </td>
            </tr>
        </tfoot>
    </table>
</div>
<!-- 编辑ac弹窗 -->
<div class="modal fade" id="editAcModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">Modal title</h4>
      </div>
      <div class="modal-body">
        Loading...
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="submit_edit_ac_btn">Save changes</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- 管理弹窗 -->
<div class="modal fade" id="clientModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">Client Management</h4>
      </div>
      <div class="modal-body" id="client_container">
        Loading...
      </div>
      <div class="modal-footer">
        <label for="select_all_client" class="pull-left" id="client_select">
          <input type="checkbox" id="select_all_client">
          <span>全选</span>
        </label>
        <button type="button" id="kick_out_clients_btn" class="btn btn-danger">Kick OUT</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- 恢复出厂设置 --><!-- TODO合并到固件上传中 -->
<div class="modal fade" id="restoreModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">恢复出厂设置</h4>
      </div>
      <div class="modal-body">
          <table class="table table-hover" id="restore_file_list">
            <thead>
              <tr>
                <th></th>
                <th>文件</th>
                <th>备注</th>
              </tr>
            </thead>
            <tbody class="file-list">
            <form id="restore_form">
              <tr>
                <td><input type="checkbox" name="bak_file_1" value="/etc/config/network" checked="checked"></td>
                <td>/etc/config/network</td>
                <td>网络设置文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_2" value="/etc/config/wireless" checked="checked"></td>
                <td>/etc/config/wireless</td>
                <td>无线配置文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_3" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap.enabled" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap.enabled</td>
                <td>ap启动文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_4" value="/usr/shellgui/shellgui.conf" checked="checked"></td>
                <td>/usr/shellgui/shellgui.conf</td>
                <td>ap 配置</td>
              </tr>
            </form>
            </tbody>
          </table>
      </div>
      <div class="modal-footer">
        <label for="select_all_restore" class="pull-left" id="restore_select">
          <input type="checkbox" id="select_all_restore" checked="">
          <span>全选</span>
        </label>
        <button type="button" id="submit_restore" class="btn btn-default">刷机</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- 上传固件 -->
<div class="modal fade" id="uploadFWModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">Modal title</h4>
      </div>
	  <form class="form" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="/apps/ac-set/upload.cgi">
		<div class="modal-body">
			<div class="form-group uploader-ctrl">
				<label for="upload-fw" class="">
					<p class="btn btn-info">浏览</p>
					<p class="file-name" id="file_name">上传文件</p>
				</label>
				<input type="file" id="upload-fw" name="file" class="form-control uploader_input">
			</div>
			<div class="form-group">
				<span class="upload-progress-bar hidden"><span></span></span>
			</div>
			<div id="file_info" class="hidden">
				<label for="">尺寸:</label>
				<span id="file_size"></span>
				<br>
				<label for="">类型:</label>
				<span id="file_type"></span>
				<br>
				<label for="">进度:</label>
				<span id="progress-text">0%</span>
			</div>
		 </div>
		 <div class="modal-footer">
			<button type="submit" class="btn btn-default" id="submit-file-btn" disabled>上传</button>
			<button type="button" class="btn btn-warning" data-dismiss="modal">取消</button>
		 </div>
	  </form>
	  <form id="flash_fw_form" class="hidden">
		<div class="modal-body">
			<div id="file_desc"></div>
          <table class="table table-hover" id="fw_list">
            <thead>
              <tr>
                <th></th>
                <th>文件</th>
                <th>备注</th>
              </tr>
            </thead>
            <tbody class="file-list">
              <tr>
                <td><input type="checkbox" name="bak_file_1" value="/etc/config/network" checked="checked"></td>
                <td>/etc/config/network</td>
                <td>网络设置文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_2" value="/etc/config/wireless" checked="checked"></td>
                <td>/etc/config/wireless</td>
                <td>无线配置文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_3" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap.enabled" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap.enabled</td>
                <td>ap启动文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_4" value="/usr/shellgui/shellgui.conf" checked="checked"></td>
                <td>/usr/shellgui/shellgui.conf</td>
                <td>ap 配置</td>
              </tr>
            </tbody>
          </table>
		 </div>
		 <div class="modal-footer">
			<label for="select_all_fw" class="pull-left" id="fw_select">
			  <input type="checkbox" id="select_all_fw" checked="">
			  <span>全选</span>
			</label>
			<button type="submit" id="submit_flash" class="btn btn-default">刷机</button>
			<button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
		 </div>
	  </form>
    </div>
  </div>
</div>
<!-- SSID设置 -->
<div class="modal fade" id="ssidSetModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">SSID 设置</h4>
      </div>
      <div class="modal-body">
        <form id="set_ssid_form" class="form form-horizontal">
          <div class="form-group">
            <label for="" class="control-label col-sm-2">2.4G SSID</label>
            <div class="col-sm-10">
              <input type="text" class="form-control" name="ssid_24g" value="" id="">
            </div>
          </div>
          <div class="form-group">
            <label for="" class="control-label col-sm-2">5.8G SSID</label>
            <div class="col-sm-10">
              <input type="text" class="form-control" name="ssid_58g" value="" id="">
            </div>
          </div>
          <div class="form-group">
            <label for="" class="control-label col-sm-2">Enc</label>
            <div class="col-sm-10">
              <select class="form-control" name="" value="" id="enc_types">
                <option value="none">None</option>
                <option value="psk2">PSK2</option>
                <option value="mixed-psk">Mixed</option>
              </select>
            </div>
          </div>
          <div class="form-group hidden">
            <label for="" class="control-label col-sm-2">Key</label>
            <div class="col-sm-10">
              <input type="text" class="form-control" name="" value="" id="enc_keys">
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="submit_ssid">Apply</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- 宽带配额 -->
<div class="modal fade" id="bwModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">Modal title</h4>
      </div>
      <div class="modal-body">
        <form id="bw_set_form" class="form form-horizontal">
          <div class="form-group">
            <label for="" class="control-label col-sm-2">Total</label>
            <div class="col-sm-10">
				<div class="input-group">
					<input type="text" class="form-control" id="" name="total" value="">
					<div class="input-group-addon">Gigabyte</div>
				</div>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="submit_bw" data-dismiss="modal">Apply</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- envs -->
<div class="modal fade" id="envModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">Modal title</h4>
      </div>
      <div class="modal-body">
		<div>
			<div class="btn-group hidden-xs hidden" id="sm-range">
				<button type="button" class="btn btn-default active" id="5g_1_btn">5170-5330 <span class="badge"></span></button>
				<button type="button" class="btn btn-default" id="5g_2_btn">5490-5710 <span class="badge"></span></button>
				<button type="button" class="btn btn-default" id="5g_3_btn">5735-5835 <span class="badge"></span></button>
			</div>
			<span id="xs-range" class="hidden">
				<select class="form-control visible-xs-inline">
					<option value="5g_1">5170-5330</option>
					<option value="5g_2">5490-5710</option>
					<option value="5g_3">5735-5835</option>
				</select>
			</span>
		</div>
        <div id="line_container"></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="flash-env-btn">刷新</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<%
}
%>
