--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: qos.lua 7362 2011-08-12 13:16:27Z jow $
]]--

module("luci.controller.admin.qos-emong", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qos-emong") then
		return
	end
	
	local page

	page = entry({"admin", "network", "qos-emong"}, cbi("qos-emong"), _("Senior Qos"))
	page.i18n = "qos-emong"
	page.dependent = true
end
