module("luci.controller.status4g", package.seeall)

function index()
	entry({"admin", "status", "4g"}, cbi("4g"), _("4g status"), 1)

end