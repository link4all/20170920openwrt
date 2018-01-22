$(function() {
			$('#usr').keypress(function(e) {
				var curKey = e.which;
				if(curKey == 13){
					$('#pwd').focus();
					return false;
				}
			});

			$('#pwd').keypress(function(e) {
				var curKey = e.which;
				if(curKey == 13){
					doLogin();
					return false;
				}
			});
		});
		
	
  function doLogin()
{
	var password = document.getElementById("pwd").value;
	if(password.length == 0)
	{
		$('.error-message').css('display','block');
	}
	else
	{
		sessionExpired=false;
		passInvalid=false;
		loggedOut=false;

		var param = getParameterDefinition("password", password);
		var stateChangeFunction = function(req)
		{
			if(req.readyState == 4)
			{
				if(req.responseText.match(/^invalid/))
				{
					passInvalid = true;
					$('.error-message').css('display','block');
				}
				else
				{
					var cookieLines=req.responseText.split(/[\n\r]+/);
					var cIndex=0;
					for(cIndex=0; cIndex < cookieLines.length; cIndex++)
					{
						var cookie = cookieLines[cIndex].replace(/^.*ookie:/, "").replace(/\";.*$/, "");
						if(cookie.match(/=/))
						{
							document.cookie=cookie;
						}
					}
					window.location.href = window.location.href;
				}
				//setControlsEnabled(true);

			}
		}
		runAjax("POST", "/cgi-bin/get_password_cookie.sh", param, stateChangeFunction);
	}
}

