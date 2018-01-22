function set_openvpn_client()
{
      $("#status").html("<%= $processing%>");
       var form = new FormData(document.getElementById("form0"));
        $.ajax({
        url: "/cgi-bin/openvpn.sh",
        type: "POST",
        data:form, 
        processData:false,
        contentType:false,
       // contentType: "application/json; charset=utf-8",
        success: function(json) {
           if (json.stat==undefined){
           $("#status").html("<%= $error%>");
           }else{
              $("#status").html("<%= $finish%>");
           }
        },
        error: function(error) {
          //alert("调用出错" + error.responseText);
        }
      });
  }

  function set_openvpn_server()
  {
        $("#status1").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form1"));
          $.ajax({
          url: "/cgi-bin/openvpn.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status1").html("<%= $error%>");
             }else{
                $("#status1").html("<%= $finish%>");
             }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    }

function download_ca(){
window.location="/cgi-bin/dump_ca_tarball.sh"
}

function set_pptp_client()
{
      $("#status").html("<%= $processing%>");
       var form = new FormData(document.getElementById("form2"));
        $.ajax({
        url: "/cgi-bin/pptp.sh",
        type: "POST",
        data:form, 
        processData:false,
        contentType:false,
       // contentType: "application/json; charset=utf-8",
        success: function(json) {
           if (json.stat==undefined){
           $("#status").html("<%= $error%>");
           }else{
              $("#status").html("<%= $finish%>");
           }
        },
        error: function(error) {
          //alert("调用出错" + error.responseText);
        }
      });
  }

  function set_pptp_server()
  {
        $("#status2").html("<%= $processing%>");
         var form = new FormData(document.getElementById("form3"));
          $.ajax({
          url: "/cgi-bin/pptp.sh",
          type: "POST",
          data:form, 
          processData:false,
          contentType:false,
         // contentType: "application/json; charset=utf-8",
          success: function(json) {
             if (json.stat==undefined){
             $("#status2").html("<%= $error%>");
             }else{
                $("#status2").html("<%= $finish%>");
             }
          },
          error: function(error) {
            //alert("调用出错" + error.responseText);
          }
        });
    }
