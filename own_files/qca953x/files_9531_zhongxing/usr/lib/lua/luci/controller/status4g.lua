module("luci.controller.status4g", package.seeall)

function index()
	entry({"admin", "status", "4g1"}, template("4g1"), _("4g1 status"), 110)

end
