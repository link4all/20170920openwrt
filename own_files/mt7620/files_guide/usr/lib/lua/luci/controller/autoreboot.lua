module("luci.controller.autoreboot", package.seeall)

function index()
        entry({"admin", "network", "autoreboot"}, cbi("autoreboot"), _("Autoreboot"), 100)
        end
