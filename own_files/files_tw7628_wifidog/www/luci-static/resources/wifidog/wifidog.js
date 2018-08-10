function OnBtnLoginClick()
{
	var frm = document.getElementById("frmLogin");
	var obj = {};
	obj.user = frm.user.value;

	obj.pwd = frm.pwd.value;
	var xhr = new XHR();
	xhr.post(frm.action, obj, function(xhr){
		var json = null;
		if (xhr.getResponseHeader("Content-Type") == "application/json") {
			try {
				json = eval('(' + xhr.responseText + ')');
				if(json.url)
					window.location = json.url;
				else if(json.error)
					spanMsg.innerText = json.error;
			}
			catch(e) {
				json = null;
			}
		}
	});
	return true ;
}

function htmInit()
{
	var frm = document.getElementById("frmLogin");
	var q = location.href.indexOf("?");
	if(q != -1) frm.action += location.href.substring(q);
	else frm.action += "?error=1";
}


function closeWindow() {
    if (time > 0) {
        window.setTimeout('closeWindow()',1000);
        document.getElementById("show1").innerHTML = "Wait "+time;
        document.getElementById("commit").style.display="none"
        time--;
    } else {
        document.getElementById("commit").style.display="none"
        document.getElementById("commit").style.display="block"
    }
}
closeWindow();