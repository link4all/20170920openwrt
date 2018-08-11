function getParameterDefinition(parameter, definition)
{
	return(encodeURIComponent(parameter) + "=" + encodeURIComponent(definition));
}

function setBrowserTimeCookie()
{
	var browserSecondsUtc = Math.floor( ( new Date() ).getTime() / 1000 );
	document.cookie="browser_time=" +browserSecondsUtc + "; path=/"; //don't bother with expiration -- who cares when the cookie was set? It just contains the current time, which the browser already knows
}

function getRequestObj()
{
	var req;
	try
	{

		// standards compliant browsers
		req = new XMLHttpRequest();
	}
	catch (ex)
	{
		// MicroShit Browsers
		try
		{
			req = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (ex)
		{
			try
			{
				req = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (ex)
			{
				// Browser is not Ajax compliant
				return false;
			}
		}
	}
	return req;
}

function runAjax(method, url, params, stateChangeFunction)
{

	//let's be sneaky -- instead of adding setBrowserTimeCookie() to the saveChanges() function on every page
	//add it to this function, which gets run on every ajax call.  This covers all instances not taken care of
	//by the setControlsEnabled() function
	setBrowserTimeCookie();
	var req = getRequestObj();
	if(req)
	{
		req.onreadystatechange = function()
		{
			stateChangeFunction(req);
		}

		if(method == "POST")
		{
			//for some reason we need at least one character of data, so use a space if params == null
			params = (params == null) ? " " : params;

			req.open("POST", url, true);
			req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			//req.setRequestHeader("Content-length", params.length);
			//req.setRequestHeader("Connection", "close");
			req.send(params);
		}
		else if(method == "GET")
		{
			req.open("GET", url + "?" + params, true);
			req.send(null);
		}
	}
	return req;
}