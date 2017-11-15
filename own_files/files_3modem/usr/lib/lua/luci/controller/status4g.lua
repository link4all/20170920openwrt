module("luci.controller.status4g", package.seeall)

function index()
	entry({"admin", "status", "4g1"}, template("4g1"), _("4g1 status"), 1)
	entry({"admin", "status", "4g2"}, template("4g2"), _("4g2 status"), 2)
	entry({"admin", "status", "4g3"}, template("4g3"), _("4g3 status"), 3)
end
