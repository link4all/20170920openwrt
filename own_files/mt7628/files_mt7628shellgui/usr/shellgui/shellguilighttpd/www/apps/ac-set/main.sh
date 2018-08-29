#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
aplist_cp() {
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app=ac-set"}, "3": {"title": "'${_LANG_Form_AP_list_control}'"}}'
%>

<div class="row">
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="glyphicon glyphicon-asterisk alert-success">:</span></label>
      正常运行
  </div>
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="glyphicon glyphicon-asterisk alert-warning">:</span></label>
      可使用
  </div>
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="glyphicon glyphicon-asterisk alert-danger">:</span></label>
      已禁用
  </div>
  <div class="col-sm-4 col-lg-2 col-md-3 col-xs-6">
    <label ><span class="glyphicon glyphicon-asterisk alert-default">:</span></label>
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
            </tr>
        </thead>
        <tbody id="ac_container"></tbody>
        <tfoot>
            <tr id="operate_btn">
                <td colspan="9">
                    <label>
                        <input type="checkbox" id="selectAll">
                        全选
                    </label>&nbsp;&nbsp;&nbsp;&nbsp;
                    <div class="btn-group">
                        <button id="reboot_btn" type="button" class="btn btn-danger btn-sm" disabled>重启</button>
                        <button id="disable_btn" type="button" class="btn btn-primary btn-sm" disabled>禁用</button>
                        <button id="enable_btn" type="button" class="btn btn-primary btn-sm" disabled>启用</button>
                    </div>

                    <div class="btn-group">
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#restoreModal" disabled>恢复出厂设置</button>
                        <button type="button" id="upload_fw_btn" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#uploadFWModal" disabled>上传固件</button>
                    </div>

                    <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#ssidSetModal" disabled>SSID设置</button>
                    <button type="button" class="btn btn-primary btn-sm"  data-toggle="modal" data-target="#bwModal" disabled>带宽配额</button>

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
                <td><input type="checkbox" name="bak_file_3" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/root.cron" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/root.cron</td>
                <td>ap计划任务</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_4" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init.enabled" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init.enabled</td>
                <td>ap启动文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_5" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/apip.txt" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/apip.txt</td>
                <td>ap IP配置</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_6" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap_set.txt" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap_set.txt</td>
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
      <div class="modal-body">
        <form class="form" id="uploader" name="uploader" method="POST" enctype="multipart/form-data" action="/apps/ac-set/upload.cgi">
          <div class="form-group upload-ctrl">
            <label for="upload-fw" class="">
              <p class="btn btn-info">浏览</p>
              <p class="file-name" id="file_name">上传固件</p>
            </label>
            <input type="file" id="upload-fw" name="file" class="form-control fw-file">
          </div>
          <div id="file_desc"></div>
        </form>
          <table class="table table-hover hidden" id="fw_list">
            <thead>
              <tr>
                <th></th>
                <th>文件</th>
                <th>备注</th>
              </tr>
            </thead>
            <tbody class="file-list">
            <form id="flash_fw_form">
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
                <td><input type="checkbox" name="bak_file_3" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/root.cron" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/root.cron</td>
                <td>ap计划任务</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_4" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init.enabled" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/S1100-wire-ap.init.enabled</td>
                <td>ap启动文件</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_5" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/apip.txt" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/apip.txt</td>
                <td>ap IP配置</td>
              </tr>
              <tr>
                <td><input type="checkbox" name="bak_file_6" value="/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap_set.txt" checked="checked"></td>
                <td>/usr/shellgui/shellguilighttpd/www/apps/wire-ap/ap_set.txt</td>
                <td>ap 配置</td>
              </tr>
            </form>
            </tbody>
          </table>
      </div>
      <div class="modal-footer">
        <label for="select_all_fw" class="pull-left hidden" id="fw_select">
          <input type="checkbox" id="select_all_fw" checked="">
          <span>全选</span>
        </label>
        <button type="button" id="submit_upload" class="btn btn-default">Upload</button>
        <button type="button" id="submit_flash" class="btn btn-default hidden">刷机</button>
        <button type="button" class="btn btn-warning" data-dismiss="modal">Close</button>
      </div>
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


<%
}
%>

<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title": "'"${_LANG_Form_Shellgui_Web_Control}"'"}'
# '{"title": "路由器用户管理界面", "js":["\/apps\/home\/common\/js\/lan.js"]}'
%>
<body>
<div id="header">
  <% /usr/shellgui/progs/main.sbin h_sf %>
  <% /usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>


<div id="main">
  <div class="container">

<%
if [ "$FORM_action" = "aplist_cp" ]; then
  aplist_cp
elif [ "$FORM_action" = "preflash" ]; then
  save_file_and_do
else
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}'
bw_total_str=$(cat /usr/shellgui/bw_total.json)
ac_overview_str=$(shellgui '{"action": "ac_overview"}')
total_tx_pre=$(echo "${bw_total_str}" | jshon -e "total_tx")
total_tx=$(shellgui '{"action": "bit_conver", "bit": '${total_tx_pre}'}' | jshon -e "result" -u)
total_rx_pre=$(echo "${bw_total_str}" | jshon -e "total_rx")
total_rx=$(shellgui '{"action": "bit_conver", "bit": '${total_rx_pre}'}' | jshon -e "result" -u)
total_x=$(shellgui '{"action": "bit_conver", "bit": '$(expr ${total_tx_pre} + ${total_rx_pre})'}' | jshon -e "result" -u)
%>

<div class="content">
        <div class="app row app-item">
          <h2 class="app-sub-title col-sm-12">数量/流量</h2>
          <div class="col-sm-offset-2 col-sm-10">
            <table class="table table-hover text-left">
              <tbody>
                <tr>
                  <td>总AP数量:</td>
                  <td><% echo "$ac_overview_str" | jshon -e "ap_total_cnt" -u %></td>
                  <td>全部流量:</td>
                  <td><%= ${total_x} %></td>
                </tr>
                <tr>
                  <td>启用AP数量:</td>
                  <td><% echo "$ac_overview_str" | jshon -e "ap_enabled_cnt" -u %></td>
                  <td>下行流量:</td>
                  <td><%= ${total_rx} %></td>
                </tr>
                <tr>
                  <td>在线AP数量:</td>
                  <td><% echo "$ac_overview_str" | jshon -e "ap_online_cnt" -u %></td>
                  <td>上行流量:</td>
                  <td><%= ${total_tx} %></td>
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
                  <td>
                    <button class="btn btn-primary btn-xs">查看详细记录</button>
                  </td>
                </tr>
                <tr>
                  <td>当前客户端数量</td>
                  <td><% echo "$ac_overview_str" | jshon -e "clients_online_cnt" -u %></td>
                  <td>
                    <button class="btn btn-primary btn-xs">直接管理记录</button>
                  </td>
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
              <button type="button" class="btn btn-primary btn-xs">进入&gt;</button>
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
              <button type="button" class="btn btn-primary btn-xs">进入&gt;</button>
              </a>
            </div>
          </div>
        </div>
      </div>
      <hr>

<% fi %>

  </div>
</div>

<% /usr/shellgui/progs/main.sbin h_f%>

<% /usr/shellgui/progs/main.sbin h_end
if [ "$FORM_action" = "aplist_cp" ]; then
%>
<script src="/apps/ac-set/ac_set.js"></script>
<% fi %>
<script>
  Ha.setFooterPosition()
</script>
</body>
</html>