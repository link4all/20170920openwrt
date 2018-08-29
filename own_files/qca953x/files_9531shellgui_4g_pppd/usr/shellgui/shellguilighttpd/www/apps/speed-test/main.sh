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
		<div class="form-inline">
			<div class="form-group">
				<label for="dev_select" class="control-label"><%= ${_LANG_Form_Dev} %>:</label>
				<select name="" id="dev_select" class="form-control">
					<option value="default"><%= ${_LANG_Form_Default} %></option>
<%
network_str=$(uci show network -X)
ifces=$(echo "$network_str" | grep '=interface$' | cut -d  '=' -f1 | cut -d '.' -f2 | grep -v '6$')
for ifce in $ifces; do
type=;ifname=;wanip=
. /lib/functions/network.sh; network_get_ipaddr wanip ${ifce}; network_get_device realdev ${ifce}
[ -z "${wanip}" ] && continue
eval $(echo "$network_str" | grep 'network\.'${ifce}'\.' | cut -d '.' -f3-)
if [ -z "$type" ] && [ "$ifname" != "lo" ]; then
%>					<option value="<%= ${realdev} %>"><%= ${ifce}" : "${realdev}" : " ${wanip} %></option><%
fi
done %>
				</select>
			</div>
		</div>
		<div class="row" id="svg_container">
  		<svg id="dashbox" width="800" height="600" style="display: block; margin: 0 auto;">
		    <g id="dashboxContent" opacity="0">
		      <g id="points" stroke-width="3">
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#2ECC71" ></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#2ECC71" transform="rotate(-30)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#2ECC71" transform="rotate(30)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#3498DB" transform="rotate(60)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#3498DB" transform="rotate(90)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#3498DB" transform="rotate(120)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#E74C3C" transform="rotate(150)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#E74C3C" transform="rotate(180)"></line>
		        <line x1="-200" y1="0" x2="-170" y2="0" stroke="#E74C3C" transform="rotate(210)"></line>
		      </g>
		      <g id="cir-part">
		        <defs>
		          <mask id="circle-mask">
		            <circle cx="0" cy="0" r="200" fill="white"></circle>
		            <circle cx="0" cy="0" r="180" fill="black"></circle>
		          </mask>
		          <clipPath id="tri-clip">
		           <polygon points="0,0 -300,0 0,-300"></polygon>
		          </clipPath>
		        </defs>
		        <circle id="circle-green" cx="0" cy="0" r="200" fill="#2ECC71" clip-path="url(#tri-clip)" mask="url(#circle-mask)" transform="rotate(-30)"></circle>
		        <circle id="circle-red" cx="0" cy="0" r="200" fill="#E74C3C" clip-path="url(#tri-clip)" mask="url(#circle-mask)" transform="rotate(120)"></circle>
		        <g id="circle-blue" fill="#3498DB">
		          <circle cx="0" cy="0" r="200" clip-path="url(#tri-clip)" mask="url(#circle-mask)" transform="rotate(30)"></circle>
		          <circle cx="0" cy="0" r="200" clip-path="url(#tri-clip)" mask="url(#circle-mask)" transform="rotate(60)"></circle>
		        </g>
		        <g id="rect_btn" style="cursor: pointer;" transform="translate(0,-70)">
		        	<rect id="btn_rect" x="-50" y="-30" rx="10" height="60" width="100" fill="white" stroke="#34495E" stroke-width="4"></rect>
		        	<text id="btn_text" x="0" y="10" text-anchor="middle" stroke="none" fill="#34495E" font-size="24px" font-weight="bolder" font-family="Arial"><%= ${_LANG_Form_Begin} %>!</text>
		        	<circle id="inner-cir" cx="0" cy="0" r="20" fill="none" stroke="#34495E" stroke-width="4" opacity="0"></circle>
		        </g>
		        <text id="loading-text" x="0" y="-220" text-anchor="middle" stroke="none" fill="#34495E" font-size="24" font-weight="bold" font-family="Arial"></text>
		      </g>
		      <g>
		        <polygon id="arrow" points="-10,0 0,10 10,0 0,-120" fill="#34495E" transform="rotate(-120)"></polygon>
		      </g>
		      <g id="text" fill="#7F8C8D">
		        <g id="m_0" transform="rotate(-30)">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(-160,0) rotate(30)">0</text>
		          <text x="0" y="0" dy="20" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(-140,0) rotate(30)">M</text>
		        </g>
		        <g id="m_1">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(-160,0)">1</text>
		          <text x="0" y="0" dy="10" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(-140,0)">M</text>
		        </g>
		        <g id="m_5" transform="rotate(30)">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(-160,0) rotate(-30)">5</text>
		          <text x="0" y="0" dy="0" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(-140,0) rotate(-30)">M</text>
		        </g>
		        <g id="m_10" transform="rotate(55)">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(-160,0) rotate(-55)">10</text>
		          <text x="0" y="0" dx="16" dy="-6" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(-140,0) rotate(-55)">M</text>
		        </g>
		        <g id="m_20">
		          <text x="0" y="0" dx="-15" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(0,-140)">20</text>
		          <text x="0" y="0" dx="14" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(0,-140)">M</text>
		        </g>
		        <g id="m_30" transform="rotate(-65)">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(145,0) rotate(65)">30</text>
		          <text x="0" y="0" dx="28" dy="10" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(145,0) rotate(65)">M</text>
		        </g>
		        <g id="m_50" transform="rotate(-35)">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(135,0) rotate(35)">50</text>
		          <text x="0" y="0" dy="10" dx="30" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(135,0) rotate(35)">M</text>
		        </g>
		        <g id="m_75">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(130,0)">75</text>
		          <text x="0" y="0" dy="10" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(158,0)">M</text>
		        </g>
		        <g id="m_100" transform="rotate(35)">
		          <text x="0" y="0" dy="10" style="font-size:24px; font-weight: bold;font-family: Arial;" transform="translate(125,0) rotate(-35)">100</text>
		          <text x="0" y="0" dy="10" dx="40" style="font-size:14px; font-weight: bold;font-family: Arial;" transform="translate(125,0) rotate(-35)">M</text>
		        </g>
		      </g>
		      <g id="unit"  fill="#34495E">
		        <text id="num-unit" text-anchor="middle" style="font-size: 24px;font-family: Arial;"  transform="translate(0,70)">Mbps</text>
		        <text id="num" text-anchor="middle" style="font-size: 48px;font-family: Arial;" transform="translate(0,120)">00.00</text>
		      </g>
		      <g id="type">
		        <text id="downloadtext" text-anchor="middle" fill="#ccc" style="font-size: 18px;font-family: Arial;"  transform="translate(-150,130)"><%= ${_LANG_Form_DownLoad} %></text>
		        <text id="uploadtext" text-anchor="middle" fill="#ccc" style="font-size: 18px;font-family: Arial;" transform="translate(150,130)"><%= ${_LANG_Form_UpLoad} %></text>
		      </g>
		      <g id="" transform="scale(0.5,0.5) translate(-300,350)">
		        <g>
		        	<line id="dashbg" x1="3" y1="87" x2="590" y2="87" opacity="0" stroke="yellow" stroke-width="6" fill="none"></line>
			        <line id="transLine" class="" x1="3" y1="87" x2="590" y2="87" stroke-dasharray="60,20" stroke="#34495E" stroke-width="6" fill="none"></line>
			      </g>
		      	<g id="server" fill="#34495E">
			        <rect x="0" y="0" width="100" height="20" rx="8" stroke="none"></rect>
			        <rect x="0" y="25" width="100" height="20" rx="8" stroke="none"></rect>
			        <rect x="0" y="50" width="100" height="20" rx="8" stroke="none"></rect>
			        <line x1="20" y1="10" x2="20" y2="55" stroke-width="6" fill="none"></line>
			        <circle cx="20" cy="10" r="5" stroke="none" fill="white"></circle>
			        <circle cx="35" cy="10" r="5" stroke="none" fill="white"></circle>
			        <circle cx="50" cy="10" r="5" stroke="none" fill="white"></circle>
			        <circle cx="20" cy="35" r="5" stroke="none" fill="white"></circle>
			        <circle cx="35" cy="35" r="5" stroke="none" fill="white"></circle>
			        <circle cx="50" cy="35" r="5" stroke="none" fill="white"></circle>
			        <circle cx="20" cy="60" r="5" stroke="none" fill="white"></circle>
			        <circle cx="35" cy="60" r="5" stroke="none" fill="white"></circle>
			        <circle cx="50" cy="60" r="5" stroke="none" fill="white"></circle>
			        <path d="M47,72h6v10h10v10h-26v-10h10v10Z" stroke="none"></path>
			      </g>
			      <g id="user" transform="translate(500,0)" fill="#34495E">
			        <defs>
			          <clipPath id="circlemaskforuser">
			            <circle cx="50" cy="0" r="70"></circle>
			          </clipPath>
			        </defs>
			        <circle cx="50" cy="14" r="14" stroke="none"></circle>
			        <ellipse cx="50" cy="60" rx="25" ry="30" stroke="none" clip-path="url(#circlemaskforuser)"></ellipse>
			        <path d="M47,72h6v10h10v10h-26v-10h10v10Z" stroke="none"></path>
			      </g>

		      </g>
		    </g>
		  </svg>
		</div>
    <!-- 服务器和用户之间数据传输 -->
    <div class="row">
		  <div id="chart_container">
			  <svg id="chartbox"  width="400" height="120" style="display: block; margin: 0 auto">
			    <g id="chart" transform="translate(200,40)">
			      <g id="grads" stroke="#ccc">
			        <line y1="0" x1="-200" y2="0" x2="200"></line>
			        <line y1="-20" x1="-200" y2="-20" x2="200"></line>
			        <line y1="-40" x1="-200" y2="-40" x2="200"></line>
			        <line y1="20" x1="-200" y2="20" x2="200"></line>
			        <line y1="40" x1="-200" y2="40" x2="200"></line>
			        <line y1="-40" x1="-200" y2="40" x2="-200"></line>
			        <line y1="-40" x1="-160" y2="40" x2="-160"></line>
			        <line y1="-40" x1="-120" y2="40" x2="-120"></line>
			        <line y1="-40" x1="-80" y2="40" x2="-80"></line>
			        <line y1="-40" x1="-40" y2="40" x2="-40"></line>
			        <line y1="-40" x1="0" y2="40" x2="0"></line>
			        <line y1="-40" x1="40" y2="40" x2="40"></line>
			        <line y1="-40" x1="80" y2="40" x2="80"></line>
			        <line y1="-40" x1="160" y2="40" x2="160"></line>
			        <line y1="-40" x1="120" y2="40" x2="120"></line>
			        <line y1="-40" x1="200" y2="40" x2="200"></line>
				      <rect x="-190" y="50" width="14" height="14" fill="#3498DB" stroke="none"></rect>
				      <text x="-170" y="62" fill="#34495E" stroke="none"><%= ${_LANG_Form_Download_speed} %></text>
				      <rect x="10" y="50" width="14" height="14" fill="#2ECC71" stroke="none"></rect>
				      <text x="30" y="62" fill="#34495E" stroke="none"><%= ${_LANG_Form_Upload_speed} %></text>
			      </g>
			      <g id="downLoadPlot">
			        <path d="" stroke="#3498DB" stroke-width="1" fill="none"></path>
			        <polygon points="" stroke="none" fill="#3498DB" opacity="0.4"></path>
			      </g>
			      <g id="upLoadPlot">
			        <path d="" stroke="#2ECC71" stroke-width="1" fill="none"></path>
			        <polygon points="" stroke="none" fill="#2ECC71" opacity="0.4"></path>
			      </g>
			    </g>
			  </svg>
    	</div>
    </div>

    <div class="row" id="result_container">
			<div class="col-xs-12 col-sm-4" id="user_container">
    		<div id="user_info" class="">
				<h4><span class="glyphicon glyphicon-user" style="font-size: 20px;"></span>  <%= ${_LANG_Form_Local_info} %></h4>
				<ul style="list-style: none;padding-left: 20px">
					<li><span class="info-title">ISP: </span><span id="ips"></span></li>
					<li><span class="info-title">Position: </span><span id="user_position"></span></li>
					<li><span class="info-title">IP: </span><span id="ip"></span></li>
				</ul>
				</div>
    	</div>
    	

    	<div class="col-xs-12 col-sm-4" id="server_container">
				<div class="" id="server_info">
				<h4><span class="glyphicon glyphicon-cloud" style="font-size: 20px;"></span>  <%= ${_LANG_Form_Test_nodes_info} %></h4>
				<ul style="list-style: none;padding-left: 20px">
					<li><a id="best_server_url" href="" target="_blank"><span class="info-title"><%= ${_LANG_Form_Best_Server_URL} %></span></a></li>
					<li><span class="info-title"><%= ${_LANG_Form_Country__Name} %>: </span><span id="country_name"></span></li>
					<li><span class="info-title"><%= ${_LANG_Form_Dist} %>: </span><span id="dist"></span></li>
					<li><span class="info-title"><%= ${_LANG_Form_Position} %>: </span><span id="server_position"></span></li>
					<li><span class="info-title"><%= ${_LANG_Form_Sponsor} %>: </span><span id="sponsor"></span></li>
					<li><span class="info-title"><%= ${_LANG_Form_ServerCount} %>: </span><span id="servercount"></span></li>
				</ul>
				</div>
    	</div>
			
			<div class="col-xs-12 col-sm-4" id="speed_container">
    	
	    	<div id="ping_container" class="">
	    		<svg id="pingbox" height="80"">
				    <g id="ping" transform="translate(25,40) scale(0.6,0.6)">
				      <defs>
				        <clipPath id="half-circle-clip">
				          <rect x="-100" y="-100" width="200" height="100"></rect>
				        </clipPath>
				        <mask id="maskforiconcircleping">
				          <circle cx="0" cy="0" r="38" fill="white"></circle>
				          <circle cx="0" cy="0" r="34" fill="black" clip-path="url(#half-circle-clip)"></circle>
				        </mask>
				      </defs>
				      <circle cx="0" cy="0" r="38" fill="#34495E" mask="url(#maskforiconcircleping)"></circle>
				      <polygon id="right-arrow" points="0,0 0,8 30,8 26,14 32,14 40,4 32,-6 26,-6 30,0" stroke="none" fill="white" transform="translate(-20,8)"></polygon>
				      <polygon id="left-arrow" points="0,0 0,8 30,8 26,14 32,14 40,4 32,-6 26,-6 30,0" stroke="none" fill="#34495E" transform="rotate(180) translate(-20,8)"></polygon>
				    </g>
				    <g id="" transform="translate(60,35)">
							<text font-size="18">Ping</text>
							<text id="pingresult" transform="translate(0,25)" font-size="16"></text>
				    </g>
	    		</svg>
    		</div>
	    	<div id="download_container" class="">
	    		<svg id="downarrowbox" height="80"">
				    <g id="downloadarrow" transform="translate(25,40) scale(0.6,0.6)">
				      <defs>
				        <mask id="maskforiconcircle">
				          <circle cx="0" cy="0" r="38" fill="white"></circle>
				          <circle cx="0" cy="0" r="34" fill="black"></circle>
				        </mask>
				      </defs>
				      <circle cx="0" cy="0" r="38" fill="#34495E" mask="url(#maskforiconcircle)"></circle>
				      <polygon id="left-arrow" points="0,0 0,8 30,8 26,14 32,14 40,4 32,-6 26,-6 30,0" stroke="none" fill="#34495E" transform="rotate(-90) translate(-25,-5) scale(1.2,1.2)"></polygon>
				    </g>
				    <g id="" transform="translate(60,35)">
							<text font-size="18"><%= ${_LANG_Form_Download_speed} %></text>
							<text id="downloadresult" transform="translate(0,25)" font-size="16"></text>
						</g>
	    		</svg>
	    	</div>
	    	<div id="upload_container" class="">
	    		<svg id="uparrowbox" height="80"">
				    <g id="uploadarrow" transform="translate(25,40) scale(0.6,0.6)">
				      <circle cx="0" cy="0" r="38" fill="#34495E"></circle>
				      <polygon id="left-arrow" points="0,0 0,8 30,8 26,14 32,14 40,4 32,-6 26,-6 30,0" stroke="none" fill="white" transform="rotate(90) translate(-25,-5) scale(1.2,1.2)"></polygon>
				    </g>
				    <g id="" transform="translate(60,35)">
							<text font-size="18"><%= ${_LANG_Form_Upload_speed} %></text>
							<text id="uploadresult" transform="translate(0,25)" font-size="16"></text>
						</g>
	    		</svg>
	    	</div>
	    </div>

    </div>

	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script src="/apps/speed-test/speed_test.js"></script>
</body>
</html>
