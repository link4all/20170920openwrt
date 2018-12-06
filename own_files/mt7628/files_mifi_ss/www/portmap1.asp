<%
eval $( gargoyle_session_validator -c "$COOKIE_hash" -e "$COOKIE_exp" -a "$HTTP_USER_AGENT" -i "$REMOTE_ADDR" -r "login1.asp" -t $(uci get gargoyle.global.session_timeout) -b "$COOKIE_browser_time"  )
#echo ""
lang=`uci get gargoyle.global.lang`
. /www/data/lang/$lang/portmap.po
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AP client</title>
    <link rel="stylesheet" type="text/css" href="css/layout.css" />
    <link rel="stylesheet" type="text/css" href="css/table.css" />
    <link rel="stylesheet" type="text/css" href="css/main.css" />
    <script type="text/javascript" src="jjs/jquery.js"></script>
<link rel="stylesheet" type="text/css" href="css/form.css" />
  <script type="text/javascript">
  function setlan(){
var tab=document.getElementById("table");
var num = tab.rows.length-1
var input = document.createElement('input');  //创建input节点
input.setAttribute('type', 'hidden');  //定义类型是文本输入
input.setAttribute('name', 'num');
input.setAttribute('value', num);
document.getElementById('form0').appendChild(input ); //添加到form中显示
        $("#status").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form0"));
           $.ajax({
          url: "/cgi-bin/portmap.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.status==undefined){
             $("#status").html("<%= $port_error%>");
             }else{
                $("#status").html("<%= $finish_port%>");
             }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
  }
  // 编写一个函数，供添加按钮调用，动态在表格的最后一行添加子节点；

function add(){
var tab=document.getElementById("table");
var num = tab.rows.length-1
num++;
var tr=document.createElement("tr");
var name=document.createElement("td");
var src_po=document.createElement("td");
var dest_ip=document.createElement("td");
var dest_po=document.createElement("td");
var proto=document.createElement("td");
name.innerHTML=num;
src_po.innerHTML="<input style='width:100%'  name='sport_" + num + "'" + " type='text' placeholder='1-65535' />";
dest_ip.innerHTML="<input style='width:100%' name='dip_" + num +"'" + "  type='text' placeholder='192.168.8.2' />";
dest_po.innerHTML="<input style='width:100%px' name='dport_" + num +"'" + "  type='text' placeholder='1-65536' />";
proto.innerHTML="<input style='width:100%' name='proto_" + num + "'" +"  type='text' placeholder='tcp udp' />";
var del=document.createElement("td");
del.innerHTML="<a href='javascript:;' onclick='del(this)' >删除</a>";

tab.appendChild(tr);
tr.appendChild(name);
tr.appendChild(src_po);
tr.appendChild(dest_ip);
tr.appendChild(dest_po);
tr.appendChild(proto);
tr.appendChild(del);
var tr = document.getElementsByTagName("tr");

}


// 创建删除函数
function del(obj)
{
var tr=obj.parentNode.parentNode;
tr.parentNode.removeChild(tr);
}

function getportmap(){
           $.ajax({
          type: "GET", 
          url: "/cgi-bin/getportmap.sh",
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          success: function(json) {
                  for (var key in json ) {
                    var tbody=""
              tbody += '<tr><td>'+ key
                 + '</td><td>' + '<input style="width:100%"  name="sport_' + key + '"' + ' type="text" ' + 'value="' +json[key].src_port + '"/>'
                 + '</td><td>' +'<input style="width:100%"  name="dip_' + key + '"' + ' type="text" ' + 'value="' + json[key].dest_ip + '"/>'
                 + '</td><td>' +'<input style="width:100%"  name="dport_' + key + '"' + ' type="text" ' + 'value="' + json[key].dest_port + '"/>'
                 + '</td><td>' + '<input style="width:100%"  name="proto_' + key + '"' + ' type="text" ' + 'value="' + json[key].proto + '"/>'
                 + '</td><td><a href="javascript:;" onclick="del(this);">删除</a></td></tr>'
                 $("#tab_data").append(tbody);
            }

          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
   }
	  $(window).on('load', function () {
      getportmap()
      });
  </script>
</head>
<body>
    <div class="current"><%= $location%></div>
     <div class="wrap-main" style="position: relative;min-height: 100%;">
        <div class="wrap">
            <div class="title"><%= $page%><p style="display:inline;color:#e81717;font-size:x-large;margin-left: 100px;" id="status"></p></div>
            <div class="wrap-form">
             <form class="form-info" id="form0">

                    <label class="">
                         <table border="0" width="40%" id="table">
                            <tr>
                            <th><%= $name%></th>
                            <th><%= $src_port%></th>
                            <th><%= $dest_ip%></th>
                            <th><%= $dest_port%></th>
                            <th><%= $proto%></th>
                            <th><%= $operate%></th>
                            </tr>
                            <tbody id="tab_data"></tbody>
                            </table>
                        </label>
                  </form>
                  <div class="btn-wrap">
					<div class="save-btn " margin="0 0"><a href="javascript:add()"><%= $add%></a></div>
					</div>
				  <div class="btn-wrap">
					<div class="save-btn fr"><a href="javascript:setlan()"><%= $save%></a></div>
					</div>
            </div>
        </div>
    </div>
</body>
</html>
