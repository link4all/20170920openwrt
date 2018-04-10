require("luci.sys")

m = Map("config4g", translate("4G/3G Config"), translate("Configure 4G/3G Parameter"))

s = m:section(TypedSection, "4G", "")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable"), translate("Enable 4G"))
apn = s:option(Value, "apn", translate("APN"))
user = s:option(Value, "user", translate("Username"))
pass = s:option(Value, "password", translate("Password"))
pass.password = true
pincode = s:option(Value, "pincode", translate("PIN Code"), translate("Verify sim card pin if sim card is locked"))

auth = s:option(ListValue, "auth", translate("Authentication type"))
auth.default=0
auth.datatype="uinteger"
auth:value(0, "None")
auth:value(1, "Pap")
auth:value(2, "Chap")
auth:value(3, "MsChapV2")

networktype = s:option(ListValue, "networktype", translate("Network type"))
networktype.default=0
networktype.datatype="uinteger"
networktype:value(0, translate("auto"))

enable_dns = s:option(Flag, "enable_dns", translate("DNS server address"), translate("Default: Obtain DNS server address  automatically"))

pri_nameserver = s:option(Value, "pri_nameserver", translate("Primary DNS"))
pri_nameserver:depends("enable_dns", "1")
sec_nameserver = s:option(Value, "sec_nameserver", translate("Secondary DNS"))
sec_nameserver:depends("enable_dns", "1")


local apply = luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/config4g restart")
end

return m
