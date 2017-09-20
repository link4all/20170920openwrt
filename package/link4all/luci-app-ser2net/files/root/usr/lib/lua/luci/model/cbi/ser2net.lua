m = Map("ser2net", translate("Ser2net"))  
  
function m.on_after_commit(self)  
        luci.sys.call("/etc/init.d/ser2net enable 1\>/dev/null 2\>/dev/null")  
        luci.sys.call("/etc/init.d/ser2net restart 1\>/dev/null 2\>/dev/null")  
end  
  
s = m:section(TypedSection, "proxy", translate("代理"))  
  
s.anonymous = true  
s.addremove = true  
  
tcpport = s:option(Value, "tcpport", translate("TCP Port"))  
  
tcpport.rmempty = false  
tcpport.default = "127.0.0.1,8000"  
  
state = s:option(ListValue, "state", translate("Status"))  
-- state.rmempty = false  
state:value("raw", translate("Raw"))  
state:value("rawlp", translate("Rawlp"))  
state:value("telnet", translate("Telnet"))  
state:value("off", translate("Off"))  
state.default = "raw"  
  
  
timeout = s:option(Value, "timeout", translate("Timeout"))  
timeout.rmempty = false  
timeout.default = "30"  
  
device = s:option(Value, "device", translate("Device"))  
device.rmempty = false  
device.default = "/dev/ttyUSB0"  
  
  
baudrate = s:option(ListValue, "baudrate", translate("波特率"))  
-- baudrate.rmempty = false  
baudrate:value("110", translate("110"))  
baudrate:value("300", translate("300"))  
baudrate:value("600", translate("600"))  
baudrate:value("1200", translate("1200"))  
baudrate:value("2400", translate("2400"))  
baudrate:value("4800", translate("4800"))  
baudrate:value("9600", translate("9600"))  
baudrate:value("14400", translate("14400"))  
baudrate:value("19200", translate("19200"))  
baudrate:value("38400", translate("38400"))  
baudrate:value("57600", translate("57600"))  
baudrate:value("115200", translate("115200"))  
baudrate:value("128000", translate("128000"))  
baudrate.default = "57600"  
  
parity_check = s:option(ListValue, "parity_check", translate("奇偶校验"))  
-- parity_check.rmempty = false  
parity_check:value("NONE", translate("None"))  
parity_check:value("ODD", translate("Odd"))  
parity_check:value("EVEN", translate("Even"))  
parity_check.default = "NONE"  
  
stopbit = s:option(ListValue, "stopbit", translate("停止位"))  
-- stopbit.rmempty = false  
stopbit:value("1STOPBIT", translate("1STOPBIT"))  
stopbit:value("2STOPBITS", translate("2STOPBITS"))  
stopbit.default = "1STOPBIT"  
  
databit = s:option(ListValue, "databit", translate("数据位"))  
-- databit.rmempty = false  
databit:value("7DATABITS", translate("7DATABITS"))  
databit:value("8DATABITS", translate("8DATABITS"))  
databit.default = "8DATABITS"  
  
return m  
