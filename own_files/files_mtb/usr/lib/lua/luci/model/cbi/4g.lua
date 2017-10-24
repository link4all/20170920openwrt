require("luci.sys")  

m = Map("4g", translate("4g status :"),translate("4g modem status: sim card status, signal display,imsi etc."))
s = m:section(NamedSection, "modem", translate("4g modem"))  

sim_status=s:option(DummyValue, "sim_status", translate("Sim card status :"))
rssi=s:option(DummyValue, "rssi", translate("Signal Strength:"))
reg_net=s:option(DummyValue, "reg_net", translate("Register Network:"))
model=s:option(DummyValue, "model", translate("Model:"))
byte_4g=s:option(DummyValue, "4g_byte", translate("4G used bytes:"))
rev=s:option(DummyValue, "rev", translate("Modem Revision:"))
imei=s:option(DummyValue, "imei", translate("Modem IMEI:"))
imsi=s:option(DummyValue, "imsi", translate("Modem IMSI:"))
iccid=s:option(DummyValue, "iccid", translate("Modem ICCID:"))
roam=s:option(DummyValue, "roam", translate("Home Or Roam:"))
lac=s:option(DummyValue, "lac", translate("Cell LAC:"))


return m


