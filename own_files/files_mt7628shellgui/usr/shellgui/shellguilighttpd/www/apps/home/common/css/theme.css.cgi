#!/usr/bin/haserl
Content-type: text/css

<%
case $COOKIE_theme in
alizarin)
color_main="E74C3C"
color_a="C0392B"
;;
amethyst)
color_main="9B59B6"
color_a="8E44AD"
;;
carrot)
color_main="E67E22"
color_a="D35400"
;;
concrete)
color_main="95A5A6"
color_a="7F8C8D"
;;
emerland)
color_main="2ECC71"
color_a="27AE60"
;;
orange)
color_main="F39C12"
color_a="F1C40F"
;;
peter-river)
color_main="3498DB"
color_a="2980B9"
;;
turquoise)
color_main="1ABC9C"
color_a="16A085"
;;
wet-asphalt)
color_main="34495E"
color_a="2C3E50"
;;
*)
color_main="34495E"
color_a="2C3E50"
;;
esac
%>
/*wet-asphalt*/
/*页头*/
/*背景色*/
.header-block,.navbar-default{
  background-color: #<%= ${color_main} %>;
}
/*字体颜色*/
.header-block a:hover,
.header-block .dropdown-toggle:hover,
.header-block .dropdown-toggle span:hover{
  color: #fff;
}
/*字体颜色*/
.navbar-default a>span{
  color: #eee;
}

a{
  color: #<%= ${color_main} %>;
}
a:hover{
  color: #<%= ${color_a} %>;
}

/*collapsed按钮颜色*/
.navbar-default .navbar-toggle .icon-bar {
  background-color: #fff;
}
.navbar-default .navbar-toggle.collapsed{
  background-color: transparent;
}
.navbar-default .navbar-toggle:hover,
.navbar-default .navbar-toggle:focus
{
  background-color: #fff;
}
.navbar-default .navbar-toggle:hover .icon-bar,
.navbar-default .navbar-toggle:focus .icon-bar
{
  background-color: #<%= ${color_main} %>;
}

.switch-ctrl input[type=checkbox]:checked + label {
	background: #<%= ${color_main} %>;
}
.switch-ctrl.disabled input[type=checkbox]:checked + label {
  background: #ccc;
}

/*语言下拉菜单文字颜色*/
.language .dropdown-menu{
  color: #<%= ${color_main} %>;
}
.header,
.app-item{
  border-bottom-color: #<%= ${color_main} %>;
}


.nav-tabs > li.active > a,
.nav-tabs > li.active > a:hover,
.nav-tabs > li.active > a:focus{
  border-color: #<%= ${color_main} %>;
  border-bottom-color: transparent;
}
.nav-tabs{
  border-color: #<%= ${color_main} %>;
}
.btn-default{
  background-color: #<%= ${color_main} %>;
  color: #eee;
}
.btn-default:focus{
  background-color: #<%= ${color_a} %>;
  color: #fff;
  outline: none;
}
.btn.active{
  background-color: #fff;
}
.btn-default:hover{
  background-color: #<%= ${color_a} %>;
  color: #fff;
}
.btn-default:active:hover,
.btn-default.active:hover{
  background-color: #fff;
  color: #<%= ${color_a} %>;
  border-color: #<%= ${color_a} %>;
  outline: none;
}
.logo h1{
  color: #<%= ${color_main} %>;
}
.navbar-default .navbar-nav > .active > a,
.navbar-default .navbar-nav > .active > a:hover,
.navbar-default .navbar-nav > .active > a:focus{
  background-color: #fff;
}
.navbar-default .navbar-nav > .active > a > span,
.navbar-default .navbar-nav > .active > a:hover > span,
.navbar-default .navbar-nav > .active > a:focus > span{
  color: #<%= ${color_main} %>;
}

.navbar-default a:hover span{
  color: #fff;
}

.gotop-widget{
  color: #fff;
}
.gotop-widget button:hover{
  background-color: #fff;
  color: #<%= ${color_main} %>;
}
.menu-widget .nav-pills > li.active > a,
.menu-widget .nav-pills > li.active > a:hover,
.menu-widget .nav-pills > li.active > a:focus{
  background-color: #<%= ${color_main} %>;
  color: #fff;
  border-radius: 0;
}
.badge{
  color: #<%= ${color_main} %>;
}
.svg_fill{
  fill: #<%= ${color_main} %>;
}
.svg_stroke{
  stroke: #<%= ${color_main} %>;
}
.active .dis-theme-fill{
  fill: #<%= ${color_main} %>;
}
.active .dis-theme-stroke{
  stroke: #<%= ${color_main} %>;
}
.active .svg_fill{
  fill: #fff;
}
.active .svg_stroke{
  stroke: #fff;
}
.dis-theme-fill{
  fill: #fff;
}
.dis-theme-stroke{
  stroke: #fff;
}
.btn .dis-theme-fill:hover{
  fill: #<%= ${color_main} %>;
}
.gotop-widget .btn:hover .dis-theme-fill{
  fill: #<%= ${color_main} %>;
}
.btn .dis-theme-stroke:hover{
  stroke: #<%= ${color_main} %>;
}
.gotop-widget .btn:hover .dis-theme-stroke{
  stroke: #<%= ${color_main} %>;
}
#quickModal .svg_fill{
  fill: #<%= ${color_main} %>;
  opacity: 0.8;
}
#quickModal .svg_fill:hover{
  fill: #<%= ${color_a} %>;
  opacity: 1;
}
#quickModal .active .svg_fill{
  fill: #<%= ${color_a} %>;
  opacity: 1;
}
#quickModal .like-a-link p{
  color: #555;
}
#quickModal .active p{
  color: #555;
  text-decoration: underline;
}
