
(function(){
    var init = function () {
        $('.menu .menuname').click(function () {
            clickMenuItem($(this));
        });
        $('.menu .menuname:eq(0)').click();
        $('.menu .menuname').bind('selectstart', function() {return false;});
        $('.menu .menuname').css('-moz-user-select', 'none');
    };

    var clickMenuItem = function (jDom) {
        var that = this;
        var $menuname = jDom;
        // 点中之前是否checked状态
        var beforChecked = $menuname.hasClass('checked');
        
        if (beforChecked) {
            // 该节点之前已经是checked，如果当前是展开状态则应该折叠、反之亦然
            if ($menuname.parent().parent().hasClass('menu')) {
                if ($menuname.next() != null && $menuname.next().length > 0 && $menuname.next().hasClass('children')) {
                    // 有子节点
                    var $next = $menuname.next();
                    if ($next.is(':hidden')) {
                        $next.show();
                    } else {
                        $next.hide();
                    }
                    
                }
            }            
            return;
        }

        if ($menuname.parent().parent().hasClass('menu')) {
            // 是一级菜单
            $('.menu>li>div.menuname').removeClass('checked');
            $('.menu .children').hide();
        } else {
            // 是二级菜单
            $ul = $menuname.parent().parent();
            $ul.find('.menuname').removeClass('checked');
        }
        
        if ($menuname.next() != null && $menuname.next().length > 0 && $menuname.next().hasClass('children')) {
            // 有子节点
            $menuname.next().show();

            if (!beforChecked) {
                // 新展开的子菜单，不应该有子菜单被选中
                $menuname.next().find('.menuname').removeClass('checked');
            }
        }

        jDom.addClass('checked');
    };
	
	init();
	
})();

