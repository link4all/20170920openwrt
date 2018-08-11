
iPath.validate = function (jdom) {
    var rel = true;
    jdom.find('.check-error-message').remove();
    jdom.find('input:visible').each(function () {
        
        var obj = $(this);
        var data_validate = obj.attr('data_validate');
        if (data_validate != undefined && data_validate != '') {
            var validate_rules = data_validate.split(',');
            if (validate_rules.length > 0) {
                for (var i in validate_rules) {
                    var item = validate_rules[i];
                    var _item_arr = item.split(':');
                    var rulename = _item_arr[0];
                    var message = _item_arr[1];

                    obj.removeClass('check-error');
                    if (!iPath.validate_checkrule(rulename, obj.val())) {
                        obj.addClass('check-error');
                        var $span = $('<span><cite class="sys-icon error-ico"></cite>' + message + '</span>');
                        $span.addClass('check-error-message');
                        //$span.text(message);
                        obj.after($span);
                        rel = false;
                    }
                }
            }
        }
    });
    return rel;
}


iPath.validate_checkrule = function (rulename, val) {

    switch(rulename)
    {
        case 'ip':
            return isIPv4(val);
        case 'required':
            return val != '' && val != undefined && val != null;
        case 'mac':
            return isMAC(val);
    }

    if (rulename.indexOf('num(') == 0) {
        var range = rulename.substring(4, rulename.length - 1);
        var ranges = range.split('~');
        for (var i in ranges) {
            var _val = Number(ranges[i]);
            ranges[i] = _val;
        }
        return ranges[0] <= val && val <= ranges[1];
    }

    if (rulename.indexOf('len(') == 0) {
        var range = rulename.substring(4, rulename.length - 1);
        var ranges = range.split('~');
        for (var i in ranges) {
            var _val = Number(ranges[i]);
            ranges[i] = _val;
        }
        return ranges[0] <= val.length && val.length <= ranges[1];
    }

}


function isIPv4(ip) {
    var re = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
    return re.test(ip);
}

function isMAC(mac) {
    var re = /[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}/;
    return re.test(mac);
}
