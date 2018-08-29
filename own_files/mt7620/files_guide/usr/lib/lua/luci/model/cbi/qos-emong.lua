--[[
from emong qos
 yanjiu <yanzjiu@gmail.com>


]]--

local wa = require "luci.tools.webadmin"
local fs = require "nixio.fs"

m = Map("qos-emong", translate("Qos"),
	translate("Quene performance ,connlimit,and ip speed limit"))

s = m:section(TypedSection, "qos-emong", translate("General Setting"), translate("Here you can set Upload and download speed"))
s.anonymous = true
e = s:option(Flag, "enable", translate("Enable"))
e.rmempty = false

s:option(Value, "down", translate("Download speed (kbit/s)"))

s:option(Value, "up", translate("Upload speed (kbit/s)"))

s = m:section(TypedSection, "ip-limit", translate("Speed filter per Ip"), translate("E.g:192.168.1.20,192.168.1.128/25,do not use 192.168.1.2-192.168.1.30"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable"))
enable.default = false
enable.optional = false
enable.rmempty = false

srch = s:option(Value, "ip", translate("Ip Address"))
srch.rmempty = true
wa.cbi_add_knownips(srch)

downc = s:option(Value, "downc", translate("Download Ceil"))
downc.default = "500"
downc.rmempty = true

downr = s:option(Value, "downr", translate("Download Rate"))
downr.default = "250"
downr.rmempty = true

upc = s:option(Value, "upc", translate("Upload Ceil"))
upc.default = "500"
upc.rmempty = true

upr = s:option(Value, "upr", translate("Upload Rate"))
upr.default = "250"
upr.rmempty = true

local apply = luci.http.formvalue("cbi.apply")
if apply then
	io.popen("/etc/init.d/qos-emong restart")
end

return m
