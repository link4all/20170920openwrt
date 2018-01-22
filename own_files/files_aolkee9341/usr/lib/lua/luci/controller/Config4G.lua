module("luci.controller.Config4G", package.seeall)
function index()
        entry({"admin", "network", "Config4G"}, cbi("Config4G"), _("4G Config"), 100)
        end