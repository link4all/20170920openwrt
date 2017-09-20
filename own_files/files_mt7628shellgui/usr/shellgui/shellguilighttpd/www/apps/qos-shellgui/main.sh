#!/usr/bin/haserl
<%
shellgui '{"action": "check_session", "session_type": "http-session", "session": "'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && return 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
download_class() {
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "'"${_LANG_Form_Download}"'"}}'
%>
<div class="container">
  <div class="content">
    <div class="app row app-item" style="text-align: left;">
      <div class="switch-ctrl" style="margin-left: 10%">
        <input type="checkbox" name="" id="page_switch" value="" checked>
        <label for="page_switch"><span></span></label>
      </div>
      <h2 style="display: inline-block;margin-left: 10%"><%= ${_LANG_Form_Enable_Quality_of_Service} %> (<%= ${_LANG_Form_Download} %>)</h2>
      <p style="margin-left: 10%"><%= ${_LANG_Form_QoSAbout} %></p>
      <div class="form-inline" style="margin-left: 10%">
        <label for="total_bw" class="control-label"><%= ${_LANG_Form_Total_Download_Bandwidth} %>:</label>
        <div class="input-group">
          <input type="number" id="total_bw" class="form-control" size="6">
          <span class="input-group-addon">kbits/s</span>
        </div>
        <span id="total_bw_help" class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %>,<%= ${_LANG_Form_Empty_or_use_0_will_disabled} %></span>
      </div>
    </div>
    <div class="header">
      <ol class="breadcrumb">
        <li class="active"><h1><%= ${_LANG_Form_Total_Classification_Rules} %></h1></li>
      </ol>
    </div>
    <div class="app row app-item">
      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr class="text-left">
              <th><%= ${_LANG_Form_Total_Match_Criteria} %></th>
              <th><%= ${_LANG_Form_Classification} %></th>
              <th><%= ${_LANG_Form_Eidt} %></th>
              <th><%= ${_LANG_Form_Remove} %></th>
              <th><%= ${_LANG_Form_Move_Up} %></th>
              <th><%= ${_LANG_Form_Move_Down} %></th>
            </tr>
          </thead>
          <tbody id="cl_roles_container">
          </tbody>
          <tfoot>
            <tr class="text-left">
              <td colspan="6">
                <div class="form-group form-inline">
                  <label for="default_class" class="control-label"><%= ${_LANG_Form_Default_Service_Class} %>:</label>
                  <select name="" id="default_class" class="form-control">
                  </select>
                </div>
              </td>
            </tr>
            <tr class="text-left">
              <td colspan="6">
                <button class="btn btn-success" id="add_rule_btn" data-toggle="modal" data-target="#ruleModal"><%= ${_LANG_Form_Add_New_Classification_Rule} %></button>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</div>
<hr>
<div class="container">
  <div class="header">
    <ol class="breadcrumb">
      <li class="active"><h1><%= ${_LANG_Form_Service_Classes} %></h1></li>
    </ol>
  </div>
  <hr>
  <div class="content">
    <div class="app row app-item">
      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr class="text-left">
              <th><%= ${_LANG_Form_Service_Classes_Name} %></th>
              <th><%= ${_LANG_Form_Percent_BW} %></th>
              <th><%= ${_LANG_Form_Min_BW} %> (kbps)</th>
              <th><%= ${_LANG_Form_Max_BW} %> (kbps)</th>
              <th>Min RTT</th>
              <th><%= ${_LANG_Form_Load} %> (kbps)</th>
              <th></th>
              <th></th>
            </tr>
          </thead>
          <tbody id="service_class_container">
          </tbody>
          <tfoot>
            <tr class="text-left">
              <td colspan="7">
                <button class="btn btn-success" id="add_class_btn" data-toggle="modal" data-target="#classModal"><%= ${_LANG_Form_Add_New_Service_Class} %></button>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</div>
<hr>
<div class="container">
  <div class="header">
    <ol class="breadcrumb">
      <li class="active"><h1><%= ${_LANG_Form_Active_Congestion_Control} %></h1></li>
    </ol>
  </div>
  <div class="content">
    <div class="app row app-item">
      <div class="col-sm-8 text-left">
        <form id="congestion_control_form" class="form-horizontal">
          <div class="form-group">
            <div class="col-md-12">
              <input type="checkbox" id="enable_cc">
              <label for="enable_cc" class=""><%= ${_LANG_Form_Enable_active_congestions_control} %></label>
            </div>
          </div>
          <div class="form-group">
            <div class="col-md-offset-1 col-md-6">
              <input type="checkbox" id="has_target_ip">
              <label for="target_ip" id="target_ip_label"><%= ${_LANG_Form_Use_non__standard_ping_target} %></label>
            </div>
            <div class="col-md-5">
              <input type="text" class="form-control" id="target_ip" name="target_ip" disabled required>
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
            </div>
          </div>
          <div class="form-group">
            <div class="col-md-offset-1 col-md-6">
              <input type="checkbox" id="has_ping_limit">
              <label for="ping_limit" id="ping_limit_label"><%= ${_LANG_Form_Manually_control_target_ping_time} %></label>
            </div>
            <div class="col-md-5">
              <div class="input-group">
                <input type="text" class="form-control" id="ping_limit" name="ping_limit" disabled required>
                <span class="input-group-addon">seconds</span>
              </div>
              <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<hr>
<div class="container">
  <div class="row">
    <div class="pull-right">
      <button class="btn btn-default btn-lg" id="page_submit"><%= ${_LANG_Form_Apply} %></button>
      <button class="btn btn-warning btn-lg" id="page_reset"><%= ${_LANG_Form_Reset} %></button>
    </div>
  </div>
</div>
<!-- rule弹窗 -->
<div class="modal fade" id="ruleModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id=""></h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal" id="rule_form">
          <fieldset>
            <input type="hidden" value="" name="order">
            <div class="form-group">
              <div class="col-sm-5">
                <input type="checkbox" class="has_field">
                <label for="source_ip" class="control-label has_switch"><%= ${_LANG_Form_Source_IP} %><label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" class="form-control" data-validate="validateIP" id="source_ip" name="Source_IP" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="source_port" class="control-label has_switch"><%= ${_LANG_Form_Source_Ports} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" class="form-control" data-validate="validatePort" id="source_port" name="Source_Ports" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="destination_ip" class="control-label has_switch"><%= ${_LANG_Form_Destination_IP} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" class="form-control" data-validate="validateIP" id="destination_ip" name="Destination_IP" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="destination_port" class="control-label has_switch"><%= ${_LANG_Form_Destination_Ports} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" class="form-control" data-validate="validatePort" id="destination_port" name="Destination_Ports" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox"  class="has_field">
                  <label for="max_packet_length" class="control-label has_switch"><%= ${_LANG_Form_Maximum_Packet_Length} %></label>
                </div>
                <div class="col-sm-7 has-feedback">
                  <div class="input-group">
                    <input type="text" class="form-control" data-validate="validatePort" id="max_packet_length" name="Maximum_Packet_Length" disabled required>
                    <span class="input-group-addon">bytes</span>
                  </div>
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Packet_length} %></span>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="min_packet_length" class="control-label has_switch"><%= ${_LANG_Form_Minimum_Packet_Length} %></label>
                </div>
                <div class="col-sm-7 has-feedback">
                  <div class="input-group">
                    <input type="text" class="form-control" data-validate="validatePort" id="min_packet_length" name="Minimum_Packet_Length" disabled required>
                    <span class="input-group-addon">bytes</span>
                  </div>
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Packet_length} %></span>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox"  class="has_field">
                  <label for="transport_prot" class="control-label has_switch"><%= ${_LANG_Form_Transport_Protocol} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <select class="form-control" id="transport_prot" name="Transport_Protocol" disabled>
                      <option value="TCP">TCP</option>
                      <option value="UDP">UDP</option>
                      <option value="ICMP">ICMP</option>
                      <option value="GRE">GRE</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="bytes_reach" class="control-label has_switch"><%= ${_LANG_Form_Connection_bytes_reach} %></label>
                </div>
                <div class="col-sm-7 has-feedback">
                  <div class="input-group">
                    <input type="text" class="form-control" id="bytes_reach" data-validate="validateNum" name="Connection_bytes_reach" disabled required>
                    <span class="input-group-addon">kBytes</span>
                  </div>
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="app_prot" class="control-label has_switch"><%= ${_LANG_Form_Application__Layer7__Protocol} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <select class="form-control" id="app_prot" name="Application_Layer7_Protocol" disabled>
                      <option value="aim">AIM</option>
                      <option value="bittorrent">BitTorrent</option>
                      <option value="dns">DNS</option>
                      <option value="edonkey">eDonkey</option>
                      <option value="fasttrack">FastTrack</option>
                      <option value="ftp">FTP</option>
                      <option value="gnutella">Gnutella</option>
                      <option value="http">HTTP</option>
                      <option value="httpvideo">HTTP Video</option>
                      <option value="httpaudio">HTTP Audio</option>
                      <option value="ident">Ident</option>
                      <option value="imapemail">IMAP E-mail</option>
                      <option value="irc">IRC</option>
                      <option value="jabber">Jabber</option>
                      <option value="msnmessenger">MSN Messenger</option>
                      <option value="ntp">NTP</option>
                      <option value="pop3">POP3</option>
                      <option value="skypeoutcalls">Skype Out Calls</option>
                      <option value="skypetoskype">Skype To Skype</option>
                      <option value="smtpemail">SMTP E-mail</option>
                      <option value="sshsecureshell">SSH Secure Shell</option>
                      <option value="sshsecuresocket">SSH Secure Socket</option>
                      <option value="vnc">VNC</option>
                      <option value="voipaudio">VoIP Audio</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <label for="" class="control-label"><%= ${_LANG_Form_Set_Service_Class_To} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <select class="form-control" id="service_class_down" name="Set_Service_Class_To">
                    </select>
                  </div>
                </div>
              </div>
          </fieldset>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="submit_rule_btn" data-type="submit_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<!-- class弹窗 -->
<div class="modal fade" id="classModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id=""></h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal" id="class_form">
          <fieldset>
            <div class="form-group">
              <div class="col-sm-5">
                <label for="service_class_name" class="control-label"><%= ${_LANG_Form_Service_Classes_Name} %></label>
              </div>
              <div class="col-sm-7">
                <div>
                  <input type="text" class="form-control" data-validate="validateReq" required id="service_class_name" name="name">
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Service_Classes_Name} %></span>
                </div>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <label for="percent_bandwidth" class="control-label"><%= ${_LANG_Form_Percent_Bandwidth_At_Capacity} %></label>
              </div>
              <div class="col-sm-7 has-feedback">
                <div class="input-group">
                  <input type="text" class="form-control" data-validate="validatePctNum" required id="percent_bandwidth" name="percent">
                  <span class="input-group-addon">%</span>
                </div>
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %>(1-100)</span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <input type="checkbox" class="has_field">
                <label for="bandwidth_min" class="control-label has_switch"><%= ${_LANG_Form_Percent_Bandwidth_Minimum} %></label>
              </div>
              <div class="col-sm-7 has-feedback">
                <div class="input-group">
                  <input type="text" class="form-control" data-validate="validateNum" id="bandwidth_min" name="min_bw" disabled>
                  <span class="input-group-addon">kbits/s</span>
                </div>
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <input type="checkbox" class="has_field">
                <label for="bandwidth_max" class="control-label has_switch"><%= ${_LANG_Form_Percent_Bandwidth_Maximum} %></label>
              </div>
              <div class="col-sm-7 has-feedback">
                <div class="input-group">
                  <input type="text" class="form-control"  data-validate="validateNum" id="bandwidth_max" name="max_bw" disabled>
                  <span class="input-group-addon">kbits/s</span>
                </div>
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <label for="" class="control-label"><%= ${_LANG_Form_Minimize_Round_Trip_Times} %></label>
              </div>
              <div class="col-sm-7">
                <div class="input-group">
                  <input type="radio" class="" id="rtt_yes" name="minRTT" data-value="Yes">
                  <label for="rtt_yes"><%= ${_LANG_Form_Minimize_RTT__ping_times__when_active} %></label>
                  <br>
                  <input type="radio" class="" id="rtt_no" name="minRTT" data-value="">
                  <label for="rtt_no"><%= ${_LANG_Form_Optimize_WAN_utilization} %></label>
                </div>
              </div>
            </div>
          </fieldset>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="submit_class_btn" data-type="submit_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<%
}
upload_class()
{
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'", "url": "/?app='${FORM_app}'"}, "3": {"title": "'"${_LANG_Form_Upload}"'"}}'
%>
<div class="container">
  <div class="content">
    <div class="app row app-item" style="text-align: left;">
      <div class="switch-ctrl" style="margin-left: 10%">
        <input type="checkbox" name="" id="page_switch" value="" checked>
        <label for="page_switch"><span></span></label>
      </div>
      <h2 style="display: inline-block;margin-left: 10%"><%= ${_LANG_Form_Enable_Quality_of_Service} %> (<%= ${_LANG_Form_Upload} %>)</h2>
      <p style="margin-left: 10%"><%= ${_LANG_Form_QoSAbout} %></p>
      <div class="form-inline" style="margin-left: 10%">
        <label for="total_bw" class="control-label"><%= ${_LANG_Form_Total_Upload_Bandwidth} %>:</label>
        <div class="input-group">
          <input type="number" min="1" id="total_bw" class="form-control" size="6">
          <span class="input-group-addon">kbits/s</span>
        </div>
        <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %>,<%= ${_LANG_Form_Empty_or_use_0_will_disabled} %></span>
      </div>
    </div>
  </div>
</div>
<div class="container">
  <div class="header">
    <ol class="breadcrumb">
      <li class="active"><h1><%= ${_LANG_Form_Total_Classification_Rules} %></h1></li>
    </ol>
  </div>
  <div class="content">
    <div class="app row app-item">
      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr class="text-left">
              <th><%= ${_LANG_Form_Total_Match_Criteria} %></th>
              <th><%= ${_LANG_Form_Classification} %></th>
              <th><%= ${_LANG_Form_Eidt} %></th>
              <th><%= ${_LANG_Form_Remove} %></th>
              <th><%= ${_LANG_Form_Move_Up} %></th>
              <th><%= ${_LANG_Form_Move_Down} %></th>
            </tr>
          </thead>
          <tbody id="cl_roles_container">
          </tbody>
          <tfoot>
            <tr class="text-left">
              <td colspan="6">
                <div class="form-group form-inline">
                  <label for="default_class" class="control-label"><%= ${_LANG_Form_Default_Service_Class} %>:</label>
                  <select name="" id="default_class" class="form-control">
                  </select>
                </div>
              </td>
            </tr>
            <tr class="text-left">
              <td colspan="6">
                <button class="btn btn-success" id="add_rule_btn" data-toggle="modal" data-target="#ruleModal"><%= ${_LANG_Form_Add_New_Classification_Rule} %></button>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</div>
<hr>
<div class="container">
  <div class="header">
    <ol class="breadcrumb">
      <li class="active"><h1><%= ${_LANG_Form_Service_Classes} %></h1></li>
    </ol>
  </div>
  <div class="content">
        <div class="app row app-item">
          <div class="table-responsive">
            <table class="table">
              <thead>
                <tr class="text-left">
                  <th><%= ${_LANG_Form_Service_Classes_Name} %></th>
                  <th><%= ${_LANG_Form_Percent_BW} %></th>
                  <th><%= ${_LANG_Form_Min_BW} %> (kbps)</th>
                  <th><%= ${_LANG_Form_Max_BW} %> (kbps)</th>
                  <th><%= ${_LANG_Form_Load} %> (kbps)</th>
                  <th></th>
                  <th></th>
                </tr>
              </thead>
              <tbody id="service_class_container">
              </tbody>
              <tfoot>
                <tr class="text-left">
                  <td colspan="7">
                    <button class="btn btn-success" id="add_class_btn" data-toggle="modal" data-target="#classModal"><%= ${_LANG_Form_Add_New_Service_Class} %></button>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
  </div>
</div>
<hr>
<div class="container">
  <div class="row">
    <div class="pull-right">
      <button class="btn btn-default btn-lg" id="page_submit"><%= ${_LANG_Form_Apply} %></button>
      <button class="btn btn-warning btn-lg" id="page_reset"><%= ${_LANG_Form_Reset} %></button>
    </div>
  </div>
</div>
<!-- rule弹窗 -->
<div class="modal fade" id="ruleModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span>&times;</span></button>
        <h4 class="modal-title" id=""></h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal" id="rule_form">
          <fieldset>
            <input type="hidden" value="" name="order">
            <div class="form-group">
              <div class="col-sm-5">
                <input type="checkbox" class="has_field">
                <label for="source_ip" class="control-label has_switch"><%= ${_LANG_Form_Source_IP} %><label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" data-validate="validateIP" class="form-control" id="source_ip" name="Source_IP" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="source_port" class="control-label has_switch"><%= ${_LANG_Form_Source_Ports} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" data-validate="validatePort" class="form-control" id="source_port" name="Source_Ports" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="destination_ip" class="control-label has_switch"><%= ${_LANG_Form_Destination_IP} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" data-validate="validateIP" class="form-control" id="destination_ip" name="Destination_IP" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_IP_Address} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="destination_port" class="control-label has_switch"><%= ${_LANG_Form_Destination_Ports} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <input type="text" data-validate="validatePort" class="form-control" id="destination_port" name="Destination_Ports" disabled required>
                    <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Port} %></span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox"  class="has_field">
                  <label for="max_packet_length" class="control-label has_switch"><%= ${_LANG_Form_Maximum_Packet_Length} %></label>
                </div>
                <div class="col-sm-7 has-feedback">
                  <div class="input-group">
                    <input type="text" data-validate="validatePort" class="form-control" id="max_packet_length" name="Maximum_Packet_Length" disabled required>
                    <span class="input-group-addon">bytes</span>
                  </div>
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Packet_length} %></span>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="min_packet_length" class="control-label has_switch"><%= ${_LANG_Form_Minimum_Packet_Length} %></label>
                </div>
                <div class="col-sm-7 has-feedback">
                  <div class="input-group">
                    <input type="text" data-validate="validatePort" class="form-control" id="min_packet_length" name="Minimum_Packet_Length" disabled required>
                    <span class="input-group-addon">bytes</span>
                  </div>
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form__Packet_length} %></span>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox"  class="has_field">
                  <label for="transport_prot" class="control-label has_switch"><%= ${_LANG_Form_Transport_Protocol} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <select class="form-control" id="transport_prot" name="Transport_Protocol" disabled>
                      <option value="TCP">TCP</option>
                      <option value="UDP">UDP</option>
                      <option value="ICMP">ICMP</option>
                      <option value="GRE">GRE</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="bytes_reach" class="control-label has_switch"><%= ${_LANG_Form_Connection_bytes_reach} %></label>
                </div>
                <div class="col-sm-7 has-feedback">
                  <div class="input-group">
                    <input type="text" data-validate="validateNum" class="form-control" id="bytes_reach" name="Connection_bytes_reach" disabled required>
                    <span class="input-group-addon">kBytes</span>
                  </div>
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <input type="checkbox" class="has_field">
                  <label for="app_prot" class="control-label has_switch"><%= ${_LANG_Form_Application__Layer7__Protocol} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <select class="form-control" id="app_prot" name="Application__Layer7__Protocol" disabled>
                      <option value="aim">AIM</option>
                      <option value="bittorrent">BitTorrent</option>
                      <option value="dns">DNS</option>
                      <option value="edonkey">eDonkey</option>
                      <option value="fasttrack">FastTrack</option>
                      <option value="ftp">FTP</option>
                      <option value="gnutella">Gnutella</option>
                      <option value="http">HTTP</option>
                      <option value="httpvideo">HTTP Video</option>
                      <option value="httpaudio">HTTP Audio</option>
                      <option value="ident">Ident</option>
                      <option value="imapemail">IMAP E-mail</option>
                      <option value="irc">IRC</option>
                      <option value="jabber">Jabber</option>
                      <option value="msnmessenger">MSN Messenger</option>
                      <option value="ntp">NTP</option>
                      <option value="pop3">POP3</option>
                      <option value="skypeoutcalls">Skype Out Calls</option>
                      <option value="skypetoskype">Skype To Skype</option>
                      <option value="smtpemail">SMTP E-mail</option>
                      <option value="sshsecureshell">SSH Secure Shell</option>
                      <option value="sshsecuresocket">SSH Secure Socket</option>
                      <option value="vnc">VNC</option>
                      <option value="voipaudio">VoIP Audio</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-5">
                  <label for="" class="control-label"><%= ${_LANG_Form_Set_Service_Class_To} %></label>
                </div>
                <div class="col-sm-7">
                  <div>
                    <select class="form-control" id="service_class_up" name="Set_Service_Class_To">
                    </select>
                  </div>
                </div>
              </div>
          </fieldset>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-type="submit_btn" id="submit_rule_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<!-- class弹窗 -->
<div class="modal fade" id="classModal" tabindex="-1">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span>&times;</span></button>
        <h4 class="modal-title" id=""></h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal" id="class_form">
          <fieldset>
            <div class="form-group">
              <div class="col-sm-5">
                <label for="service_class_name" class="control-label"><%= ${_LANG_Form_Service_Classes_Name} %></label>
              </div>
              <div class="col-sm-7">
                <div>
                  <input type="text" data-validate="validateReq" class="form-control" id="service_class_name" name="name">
                  <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Service_Classes_Name} %></span>
                </div>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <label for="percent_bandwidth" class="control-label"><%= ${_LANG_Form_Percent_Bandwidth_At_Capacity} %></label>
              </div>
              <div class="col-sm-7 has-feedback">
                <div class="input-group">
                  <input type="text" data-validate="validatePctNum" class="form-control" id="percent_bandwidth" name="percent">
                  <span class="input-group-addon">%</span>
                </div>
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %>(1-100)</span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <input type="checkbox" class="has_field">
                <label for="bandwidth_min" class="control-label has_switch"><%= ${_LANG_Form_Percent_Bandwidth_Minimum} %></label>
              </div>
              <div class="col-sm-7 has-feedback">
                <div class="input-group">
                  <input type="text" data-validate="validateNum" class="form-control" id="bandwidth_min" name="min_bw" disabled>
                  <span class="input-group-addon">kbits/s</span>
                </div>
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-5">
                <input type="checkbox" class="has_field">
                <label for="bandwidth_max" class="control-label has_switch"><%= ${_LANG_Form_Percent_Bandwidth_Maximum} %></label>
              </div>
              <div class="col-sm-7 has-feedback">
                <div class="input-group">
                  <input type="text" data-validate="validateNum" class="form-control" id="bandwidth_max" name="max_bw" disabled>
                  <span class="input-group-addon">kbits/s</span>
                </div>
                <span class="help-block hidden"><%= ${_LANG_Form_Please_enter_a_valid_} ${_LANG_Form_Positive_integer} %></span>
              </div>
            </div>
          </fieldset>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-type="submit_btn" id="submit_class_btn"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
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
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active": "home"}' %>
</div>
<div id="main">
    <div class="container">
<%
if [ "$FORM_action" = "upload_class" ]; then
upload_class
elif [ "$FORM_action" = "download_class" ]; then
download_class
else
/usr/shellgui/progs/main.sbin hm '{"1": {"title": "'${_LANG_App_type}'", "url": "/?app=home#'${_LANG_App_type}'"}, "2": {"title": "'${_LANG_App_name}'"}}' %>
<div class="content row">
  <div class="col-sm-6 col-md-8 app app-item" style="border: 0;">
    <h2 class="app-sub-title"><%= ${_LANG_Form_Upload_Setting} %></h2>
    <div class="pie-title form-horizontal col-md-7 col-sm-12">
      <div class="form-group">
        <label for="" class="col-xs-6 control-label"><%= ${_LANG_Form_Set_Upload_Rules} %>:</label>
        <a href="/?app=qos-shellgui&action=upload_class"><button class="btn btn-default col-xs-4" type="button"><%= ${_LANG_Form_Enter} %></button></a>
      </div>
      <div class="form-group">
        <label for="" class="col-xs-6 control-label"><%= ${_LANG_Form_Upload_Time_Frame} %>:</label>
        <div class="input-group col-xs-4">
          <select name="" id="up_timeframe" class="form-control">
            <option value="1" selected><%= ${_LANG_Form_minutes} %></option>
            <option value="2"><%= ${_LANG_Form_quarter_hours} %></option>
            <option value="3"><%= ${_LANG_Form_hours} %></option>
            <option value="4"><%= ${_LANG_Form_days} %></option>
            <option value="5"><%= ${_LANG_Form_months} %></option>
          </select>
        </div>
      </div>
    </div>
    <div class="legend_container col-md-5 col-sm-12" id="up_legend_container"></div>
  </div>
  <div class="col-sm-6 col-md-4 pie-body text-center"  style="margin-bottom: 20px">
    <canvas id="uploadChart" height="300px" width="300px"></canvas>
  </div>
  <hr class="col-sm-12">
  <div class="col-sm-6 col-md-8 app app-item" style="border: 0;">
    <h2 class="app-sub-title"><%= ${_LANG_Form_Download_Setting} %></h2>
    <div class="pie-title form-horizontal col-md-7 col-sm-12">
      <div class="form-group">
	  <label for="" class="col-xs-6 control-label"><%= ${_LANG_Form_Set_Download_Rules} %>:</label>
        <a href="/?app=qos-shellgui&action=download_class"><button class="btn btn-default col-xs-4" type="button"><%= ${_LANG_Form_Enter} %></button></a>
      </div>
      <div class="form-group">
	  <label for="" class="col-xs-6 control-label"><%= ${_LANG_Form_Download_Time_Frame} %>:</label>
        <div class="input-group col-xs-4">
          <select name="" id="down_timeframe" class="form-control">
            <option value="1" selected><%= ${_LANG_Form_minutes} %></option>
            <option value="2"><%= ${_LANG_Form_quarter_hours} %></option>
            <option value="3"><%= ${_LANG_Form_hours} %></option>
            <option value="4"><%= ${_LANG_Form_days} %></option>
            <option value="5"><%= ${_LANG_Form_months} %></option>
          </select>
        </div>
      </div>
    </div>
    <div class="legend_container col-md-5 col-sm-12" id="down_legend_container"></div>
  </div>
  <div class="col-sm-6 col-md-4 pie-body text-center">
    <canvas id="downloadChart" height="300px" width="300px"></canvas>
  </div>
</div>
<hr>
<div class="app row app-item">
  <h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_QoS_Base_setting} %></h2>
  <div class="col-sm-offset-1 col-sm-11 text-left">
      <p><%= ${_LANG_Form_QoS_Enable} %></p>
      <div class="row">
          <div class="col-xs-3 col-sm-2 col-md-1">
              <label for="" class=""><%= ${_LANG_Form_Status} %>:</label>
          </div>
          <div class="col-xs-9 col-sm-10 col-md-11">
              <div class="switch-ctrl head-switch" id="switch_qos_radio0" data-toggle="modal" data-target="#confirmModal">
                  <input type="checkbox" name="nic-switch" id="switch_qos" value="" <% uci get qos_shellgui.upload.total_bandwidth &>/dev/null && uci get qos_shellgui.download.total_bandwidth &>/dev/null && printf 'checked' %>>
                  <label for="switch_qos"><span></span></label>
              </div>
          </div>
      </div>
  </div>
  <!-- <div class="col-sm-offset-1 col-sm-11 text-left">
    <p><%= ${_LANG_Form_Extranet_network} %></p>
    <div class="row">
      <div class="col-xs-3 col-sm-2 col-md-1">
          <label for="" class=""><%= ${_LANG_Form_Network} %>:</label>
      </div>
      <div class="col-xs-9 col-sm-10 col-md-11">
<%
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
type=;ifname=
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
[ -z "$type" ] && [ "$ifname" != "lo" ] && wans="$wans ${ifce}"
done
used_wan=$(uci get qos_shellgui.global.network | tr -d '\n')
%>
        <form class="form-inline" name="use_wan" id="use_wan">
            <div class="form-group">
              <select type="text" class="form-control" name="network">
<%
for wan in $wans; do
[ "$used_wan" = "${wan}" ] && echo "<option value=\"${wan}\" selected=\"selected\">${wan}</option>" || echo "<option value=\"${wan}\">${wan}</option>"
done
%>
        		  </select>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-default btn-block"><%= ${_LANG_Form_Apply} %></button>
            </div>
        </form>
      </div>
    </div>
  </div> --!>
</div>
<% fi %>
  </div>
</div>
<div class="modal fade" id="confirmModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title">QoS <%= ${_LANG_Form_Status} %></h4>
      </div>
      <div class="modal-body">
        <p id="confirm-text" class="text-center text-danger"></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="confirm_switch"><%= ${_LANG_Form_Apply} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Cancel} %></button>
      </div>
    </div>
  </div>
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end
wan_detect() {
wanzone=$(uci get qos_shellgui.global.network)
status_str=$(ubus call network.interface.${wanzone} status)
currentWanIf=$(echo "$status_str" | jshon -e "l3_device" -u)
}
if [ "$FORM_action" = "upload_class" ]; then
wan_detect
%>
<script>
var currentWanIf = "<%= ${currentWanIf} %>";
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
/usr/shellgui/progs/main.sbin l_p_J '_LANG_Form_' ${FORM_app} $COOKIE_lang %>
</script>
<script src="/apps/qos-shellgui/set_qos.js"></script>
<script src="/apps/qos-shellgui/set_qos_up.js"></script>
<%
elif [ "$FORM_action" = "download_class" ]; then
wan_detect
%>
<script>
var currentWanIf = "<%= ${currentWanIf} %>";
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang
/usr/shellgui/progs/main.sbin l_p_J '_LANG_Form_' ${FORM_app} $COOKIE_lang %>
</script>
<script src="/apps/qos-shellgui/set_qos.js"></script>
<script src="/apps/qos-shellgui/set_qos_down.js"></script>
<% else %>
<script>
var UI = {};
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
var monitorNames = new Array();
<% iptables-save |grep  "bandwidth--id" | awk -F "bandwidth--id " '{split($2,a," " ); print "monitorNames.push(\""a[1]"\");"}' | sort -n | uniq %>
var uciOriginal = new UCIContainer();
<%
uci show -X qos_shellgui | grep -E 'class_|upload|download|_rule_' | tr -d "'"| awk '{
	split($0,s,"=" );
	split(s[1],k,"." );
	printf("uciOriginal.set(\x27%s\x27, \x27%s\x27, \x27%s\x27, \"%s\");\n", k[1],k[2],k[3], s[2]);
}'
%>
  UI.switchOn = '<%= ${_LANG_Form_QoS_Enable} %>?';
  UI.switchOff = '<%= ${_LANG_Form_Disabled} %>?';
  $('#switch_qos').click(function(){
    var status = $('#switch_qos').prop('checked');
    if(status){
      $('#confirm-text').html(UI.switchOn);
    }else{
      $('#confirm-text').html(UI.switchOff);
    }
    return false;
  });
	$('#confirm_switch').click(function(){
		var status = $('#switch_qos').prop('checked');
		if(status){
      $.post('/','app=qos-shellgui&action=total_bandwidth&up_down=all&total_bw=0',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_qos').prop('checked',false);
      },'json');
		}else{
      $.post('/','app=qos-shellgui&action=total_bandwidth&up_down=all&total_bw=1',function(data){
        $('#confirmModal').modal('hide');
        Ha.showNotify(data);
        $('#switch_qos').prop('checked',true);
      },'json');
		}
	});
    $('#use_wan').submit(function(e){
      e.preventDefault();
      var data = "app=qos-shellgui&action=use_wan&"+$(this).serialize();
      Ha.disableForm('use_wan');
      Ha.ajax('/','json',data,'post','use_wan',Ha.showNotify,1);
    });
</script>
<script src="/apps/home/common/js/Chart.js"></script>
<script src="/apps/qos-shellgui/show_qos.js"></script>
<% fi %>
</body>
</html>