<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/vpn.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>
    <script type="text/javascript" src="/jjs/jquery.js"></script>
    <link rel="stylesheet" href="/jjs/plugin/pintuer/pintuer.css" />
    <script type="text/javascript" src="/jjs/plugin/pintuer/pintuer.js"></script>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/form.css" />
    <script type="text/javascript" ><%in jjs/vpn.js %></script>

    <style type="text/css">
    .current{
    height:50px;width:100%;background:#fff;color:#000;border-bottom:solid #e3e9ed 1px;font-size:14px;line-height:50px;text-indent:20px;
     }
    </style>
</head>
<body>
  <div class="current"><%= $location%></div>
    <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $page%><p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
                <div class="tab">
                    <div class="tab-head">
                        <ul id="tabpanel1" class="tab-nav">
                            <li class="active">
                                <a href="#tab-1"><%= $openvpn%></a>
                            </li>
                            <li>
                                <a href="#tab-2"><%= $pptp%></a>
                            </li>
                        </ul>
                    </div>
                    <div class="tab-body ">
                      <div class="tab-panel active" id="tab-1" style="padding: 15px;">
             <form class="form-info" id="form0">
               <fieldset>
                 <legend>OpenVPN<%= $client %></legend>
               <label>
                   <div class="name"><%= $enable %>OpenVPN <%= $client %>:</div>
                   <div>
                       <input type="checkbox" value="1" name="enable_client" <% [ `uci get openvpn.sample_client.enabled` = '1' ] && echo checked %>/>
                   </div>
               </label>
               <label>
                   <div class="name"><%= $remote%></div>
                   <div>
                       <input type="text"  name="client_remote" value="<% uci get openvpn.sample_client.remote %>" placeholder="remotehost 1194" />
                   </div>
               </label>
               <label>
                   <div class="name"><%= $proto%></div>
                   <div>
                       <select name="proto"  >
                           <option value="udp" <% [ `uci get openvpn.sample_client.proto |grep udp` ] && echo 'selected="true"' %> >udp</option>
                           <option value="tcp" <% [ `uci get openvpn.sample_client.proto|grep tcp` ] && echo 'selected="true"' %> >tcp</option>
                       </select>
                   </div>
               </label>
               <label>
                   <div class="name"><%= $comp_lzo%></div>
                   <div>
                       <select name="comp_lzo"  >
                           <option value="yes" <% [ `uci get openvpn.sample_client.comp_lzo |grep yes` ] && echo 'selected="true"' %> >yes</option>
                           <option value="no" <% [ `uci get openvpn.sample_client.comp_lzo|grep no` ] && echo 'selected="true"' %> >no</option>
                           <option value="adaptive" <% [ `uci get openvpn.sample_client.comp_lzo|grep adaptive` ] && echo 'selected="true"' %> >adaptive</option>
                       </select>
                   </div>
               </label>
               <label>
                   <div class="name">CA</div>
                   <div>
                       <input type="file"  name="client_ca"  />
                   </div>
               </label>
               <label>
                   <div class="name">Cert</div>
                   <div>
                       <input type="file"  name="client_cert"  />
                   </div>
               </label>
               <label>
                   <div class="name">Key</div>
                   <div>
                       <input type="file"  name="client_key"  />
                   </div>
                  <input type="text"  value="1" name="setclient" hidden  />
               </label>
              <div class="btn-wrap">
               <div class="save-btn fr"><a href="javascript:set_openvpn_client()"><%= $save%></a></div>
               </div>
             </fieldset>
              </form>
              <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status1"></p>
             <form class="form-info" id="form1">
             <fieldset>
              <legend>OpenVPN<%= $server %></legend>
               <label>
                   <div class="name"><%= $enable %>OpenVPN <%= $server %>:</div>
                   <div>
                       <input type="checkbox" value="1" name="enable_server" <%  [ `uci get openvpn.sample_server.enabled` = '1' ] && echo checked %>/>
                   </div>
               </label>
               <label>
                   <div class="name"><%= $server_ip%>：</div>
                   <div>
                       <input type="text"  name="ip_server" value="<% uci get openvpn.sample_server.server %>" placeholder="10.8.0.0 255.255.255.0" />
                   </div>
               </label>
               <label>
                   <div class="name"><%= $port%>：</div>
                   <div>
                       <input type="text"  name="port" value="<% uci get openvpn.sample_server.port %>" placeholder="1194" />
                   </div>
               </label>
                    <label>
                      <div class="name"><%= $proto %>:</div>
                       <div>
                         <select name="proto"  >
                             <option value="udp" <% [ `uci get openvpn.sample_server.proto |grep udp` ] && echo 'selected="true"' %> >udp</option>
                             <option value="tcp" <% [ `uci get openvpn.sample_server.proto|grep tcp` ] && echo 'selected="true"' %> >tcp</option>
                         </select>
                        </div>
                </label>
                <label>
                    <div class="name"><%= $comp_lzo%></div>
                    <div>
                        <select name="comp_lzo"  >
                            <option value="yes" <% [ `uci get openvpn.sample_server.comp_lzo |grep yes` ] && echo 'selected="true"' %> >yes</option>
                            <option value="no" <% [ `uci get openvpn.sample_server.comp_lzo|grep no` ] && echo 'selected="true"' %> >no</option>
                            <option value="adaptive" <% [ `uci get openvpn.sample_server.comp_lzo|grep adaptive` ] && echo 'selected="true"' %> >adaptive</option>
                        </select>
                    </div>
                    <input type="text"  value="1" name="setserver" hidden  />
                </label>
          </form>
										  <div class="btn-wrap">
					            <div class="save-btn fr"><a href="javascript:download_ca()"><%= $ca_download%></a></div>
					            </div>
                      <div class="btn-wrap">
                      <div class="save-btn fr"><a href="javascript:set_openvpn_server()"><%= $save%></a></div>
                      </div>
              </fieldset>
                    </div>
                        <div class="tab-panel" id="tab-2">
                          <form class="form-info" id="form2">
                            <fieldset>
                              <legend>PPTP<%= $client %></legend>
                            <label>
                                <div class="name">PPTP<%= $server%>:</div>
                                <div>
                                    <input type="text"  name="server_ip" value="<% uci get network.pptp.server %>" placeholder="120.120.120.120" />
                                </div>
                            </label>
                            <label>
                                <div class="name"><%= $username %>:</div>
                                <div>
                                    <input type="text"   name="username" value="<% uci get network.pptp.username %>" placeholder="test"  />
                                </div>
                            </label>
                            <label>
                                <div class="name"><%= $passwd %>:</div>
                                <div>
                                    <input type="text"   name="password" value="<% uci get network.pptp.password %>" placeholder="test"  />
                                </div>
                            </label>
                            <input type="text"  value="1" name="setclient" hidden  />
                           <div class="btn-wrap">
                            <div class="save-btn fr"><a href="javascript:set_pptp_client()"><%= $save%></a></div>
                            </div>
                          </fieldset>
                           </form>
                           <p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status2"></p>
                          <form class="form-info" id="form3">
                            <fieldset>
                              <legend>PPTP<%= $server %></legend>
                              <label>
                                  <div class="name"><%= $enable %>PPTP <%= $server %>:</div>
                                  <div>
                                      <input type="checkbox" value="1" name="enable_server" <%  [ `uci get pptpd.pptpd.enabled` = '1' ] && echo checked %>/>
                                  </div>
                              </label>
                            <label>
                                <div class="name"><%= $localip%>:</div>
                                <div>
                                    <input type="text"  name="local_ip" value="<% uci get pptpd.pptpd.localip %>" placeholder="192.168.0.1" />
                                </div>
                            </label>
                            <label>
                                <div class="name"><%= $remoteip%>:</div>
                                <div>
                                    <input type="text"  name="remote_ip" value="<% uci get pptpd.pptpd.remoteip %>" placeholder="192.168.0.20-30" />
                                </div>
                            </label>
                            <label>
                                <div class="name"><%= $username %>:</div>
                                <div>
                                    <input type="text"   name="username" value="<% uci get pptpd.@login[0].username %>" placeholder="test"  />
                                </div>
                            </label>
                            <label>
                                <div class="name"><%= $passwd %>:</div>
                                <div>
                                    <input type="text"   name="password" value="<% uci get pptpd.@login[0].password %>" placeholder="test"  />
                                </div>
                            </label>
                            <input type="text"  value="1" name="setserver" hidden  />
                           <div class="btn-wrap">
                            <div class="save-btn fr"><a href="javascript:set_pptp_server()"><%= $save%></a></div>
                            </div>
                          </fieldset>
                        </div>
                    </div>
                </div>
           </div>
        </div>
    </div>
</body>
</html>
