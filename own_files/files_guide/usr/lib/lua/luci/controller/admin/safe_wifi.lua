module("luci.controller.admin.safe_wifi", package.seeall)

function index()
    entry({"admin", "network", "safe_wifi"}, cbi("safe_wifi/safe_wifi"), "Safe WIFI", 30).dependent=false
end
