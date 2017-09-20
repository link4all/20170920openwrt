var Ha = window.Ha || {};


/* 显示提示信息条 */
Ha.showNotify = function(data){
  var type = 'success';//信息种类
  var delay = 5000;//停留时间
  if(data.status){//根据后端数据判断信息种类，可添加其他返回值
    type = 'error';
  }

  if(data.jump_url && data.seconds){//如果页面需要跳转
    delay = data.seconds;//不设定停留时间
  }

  Lobibox.notify(type, {
    msg: data.msg,//信息内容
    img: data.img,//信息图像
    delay: delay,//停留时间
    size: 'mini',
    showClass: 'bounceInDown',
    hideClass: 'fadeOut',
    sound: false
  });
};

/* 加载中的遮罩层 */
Ha.mask = {
  show: function(){//显示遮罩
    $('.loading').removeClass('hidden');
    $('body').addClass('mask');
  },
  hide: function(){//隐藏遮罩
    $('body').removeClass('mask');
    $('.loading').addClass('hidden');
  }
};

/* 提交后禁用表单 */
Ha.disableForm = function(formId){
  var form = $('#' + formId);
  $(this).prop('disabled','disabled');
  form.find('.form-control,[type="submit"],[type="checkbox"]').prop('disabled',true);
};
Ha.reableForm = function(formId){
  var form = $('#' + formId);
  $(this).prop('disabled',false);
  form.find('.form-control,[type="submit"],[type="checkbox"]').prop('disabled',false);
}

/* Ajax方法封装 */
Ha.ajax = function(url,dataType,queryData,method,formId,callback,force){
  Ha.disableForm(formId);
	if(!force){
		Ha.mask.show();//遮罩页面
	}
  var formId = formId || '';
  var callback = callback || null;
  $.ajax({
    url: url || '',
    dataType: dataType || 'json',
    data: queryData || '',
    type: method || 'get',
    success: function(data){
      if(data.status){
        Ha.reableForm(formId);
      }
      if(!force){
        Ha.showNotify(data);
      }
      var redirectUrl = data.jump_url || false;
      if(redirectUrl && data.seconds){
        //请求成功且登录成功---！！！获取表单引用需要添加到函数的参数里
        Ha.disableForm(formId);
        setTimeout(function(){
          location.href = redirectUrl;
        },data.seconds);
      }else{
        Ha.reableForm(formId);
      }

      if(typeof(callback) == 'function'){
        callback(data,formId);
      }
    },
    complete: function(){
      Ha.mask.hide();
    },
    error: function(e){

    }
  });

};
//手机输入框遮盖问题*..*|||


/* 根据内容长度调整footer的位置 */
Ha.setFooterPosition = function(){
  var headHeight = $('#header').height(),
      mainHeight = $('#main').height(),
      winHeight = $(window).height(),
      footerHeight = $('#footer').height(),
      baseHeight = headHeight + mainHeight + footerHeight,
      diff = winHeight - baseHeight;
  if(diff > 0){
    $('#footer').addClass('absolute');
  }else if(diff < 0){
    $('#footer').removeClass('absolute');
  }
};
/* 检测布局变化并作出调整 */
// (function(){
  Ha.setFooterPosition();//页面加载完成后调用

  $('[data-toggle="tab"]').each(function(index){//tab切换可能会改变页面布局
    $(this).on('click',function(){
      setTimeout(function(){
        Ha.setFooterPosition();
      });
    });
  });

  $(window).resize(function(){//调整窗口尺寸页可能会改变页面布局
    Ha.setFooterPosition();
  });

  $('#collapsedBtn').click(function(){
    //collapsed的按钮点击会影响布局，并且包含bootstrap自带的动画，布局变化有一定的延迟
    //需要用到interval和timeout
    var positionDely = setInterval(function(){//不停查看布局变化，调整footer位置
      Ha.setFooterPosition();
    });
    setTimeout(function(){//与动画相同时长的定时器，用来清楚interval节省浏览器引擎资源
      clearInterval(positionDely);
    },500);
  });
// })();

Ha.setRssiIcon = function(id,prt){
  $('#sta-item-' + id).find('.rssi-text').html(prt + '%');
  var icon = $('#sta-item-' + id).find('.rssi-icon');
  if(prt <= 0){
    icon.find('span').each(function(index){
      $(this).css('background-color','transparent');
    });
  }else if(prt > 0 && prt <= 25){
    icon.find('span').each(function(index){
      if(index < 1){
        $(this).css('background-color','#0f0');
      }else{
        $(this).css('background-color','transparent');
      }
    });
  }else if(prt > 25 && prt <= 50){
    icon.find('span').each(function(index){
      if(index < 2){
        $(this).css('background-color','#0f0');
      }else{
        $(this).css('background-color','transparent');
      }
    });
  }else if(prt > 50 && prt <= 75){
    icon.find('span').each(function(index){
      if(index < 3){
        $(this).css('background-color','#0f0');
      }else{
        $(this).css('background-color','transparent');
      }
    });
  }else{
    icon.find('span').each(function(index){
      $(this).css('background-color','#0f0');
    });
  }
}

function change_lang(lang) {
	var data = "app=home&action=change_lang&lang=" + lang;
	var url = '/';
	Ha.ajax(url, 'json', data, 'post');
};

function change_theme(theme) {
	var data = "app=home&action=change_theme&theme=" + theme;
	var url = '/';
	Ha.ajax(url, 'json', data, 'post');
};

 function formatTime(date, fmt) {
     var o = {
         "M+": date.getMonth() + 1, //月份   
         "d+": date.getDate(), //日   
         "h+": date.getHours(), //小时   
         "m+": date.getMinutes(), //分   
         "s+": date.getSeconds(), //秒   
         "q+": Math.floor((date.getMonth() + 3) / 3), //季度   
         "S": date.getMilliseconds() //毫秒   
     };
     if (/(y+)/.test(fmt))
         fmt = fmt.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
     for (var k in o)
         if (new RegExp("(" + k + ")").test(fmt))
             fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
     return fmt;

 };

//返回顶部小部件
(function(){
  $(window).load(function(){
    var top = $(window).scrollTop()
    if(top > 100){
      $('.gotop-widget').removeClass('hidden');
    }else{
      $('.gotop-widget').addClass('hidden');
      $('.menu-widget').addClass('hidden')
    }
  });
  $(window).scroll(function(){
    var top = $(window).scrollTop()
    if(top > 100){
      $('.gotop-widget').removeClass('hidden');
    }else{
      $('.gotop-widget').addClass('hidden');
      $('.menu-widget').addClass('hidden')
    }
  });
  $('#menu-widget-btn').click(function(){
    if($('.menu-widget').hasClass('hidden')){
      $('.menu-widget').removeClass('hidden')
    }else{
      $('.menu-widget').addClass('hidden')
    }
  });
  $('.menu-widget').mouseleave(function(){
    $(this).addClass('hidden');
  });
})();

(function(){
  $('[data-target="#quickModal"]').click(function(){
    $('#response-container').empty();
  });
})();

function UCIContainer(){
  this.keys = new Array();
  this.values = new Array();
  this.listOptions = new Array();


  this.createListOption = function(pkg,section,option,destroy_existing_nonlist)
  {
    destroy_existing_nonlist = destroy_existing_nonlist == null ? true : false;
    var  list_key = pkg + "\." + section + "\." + option;
    if( this.listOptions[ list_key ] != null )
    {
      return;
    }

    this.listOptions[ list_key ] = 1;
    if( this.values[list_key] != null )
    {
      var old = this.values[list_key];
      this.values[list_key] = (!destroy_existing_nonlist) && old != null ? [old] : [] ;
    }
    else
    {
      this.keys.push(list_key);
      this.values[list_key] = [];
    }
  }
  this.set = function(pkg, section, option, value, preserveExistingListValues)
  {
    preserveExistingListValues = preserveExistingListValues == null ? false : preserveExistingListValues;
    var next_key = pkg + "\." + section;
          if(option != null && option != "" )
    {
      next_key = next_key + "\." + option;
    }
    if(this.values[next_key] != null)
    {
      if (this.listOptions[ next_key ] != null)
      {
        var set = this.values[next_key];
        while(set.length > 0 && (!preserveExistingListValues))
        {
          set.pop();
        }
        if( value instanceof Array )
        {
          var vi;
          for(vi=0; vi<value.length; vi++)
          {
            set.push( value[vi] );
          }
        }
        else
        {
          set.push(value);
        }
        this.values[next_key] = set;
      }
      else
      {
        this.values[next_key] = value;
      }
    }
    else
    {
      this.keys.push(next_key);
      if (this.listOptions[ next_key ] != null)
      {
        var set = [];
        if(value instanceof Array)
        {
          var setIndex;
          for(setIndex=0;setIndex < value.length; setIndex++)
          {
            set.push( value[setIndex] )
          }
        }
        else
        {
          set = [ value ]
        }
        this.values[next_key] = set
      }
      else
      {
        this.values[next_key] = value;
      }
    }
  }

  this.get = function(pkg, section, option)
  {

    var next_key = pkg + "\." + section;
    if(option != null && option != '')
    {
      next_key = next_key + "\." + option;
    }
    var value = this.values[next_key];
    return value != null ? value : '';
  }
  this.removeAllSectionsOfType = function(pkg, type)
  {
    var removeSections = this.getAllSectionsOfType(pkg, type);
    var rmIndex=0;
    for(rmIndex=0; rmIndex < removeSections.length; rmIndex++)
    {
      this.removeSection(pkg, removeSections[rmIndex]);
    }
  }
  this.getAllOptionsInSection = function(pkg, section, includeLists)
  {
    includeLists = includeLists == null ? false : includeLists;
    var matches = new Array();
    for (keyIndex in this.keys)
    {
      var key = this.keys[keyIndex];
      var test = pkg + "." + section;
      if(key.match(test) && key.match(/^[^\.]+\.[^\.]+\.[^\.]+/) && (includeLists || this.listOptions[key] == null) )
      {
        var option = key.match(/^[^\.]+\.[^\.]+\.([^\.]+)$/)[1];
        matches.push(option);
      }
    }
    return matches;
  }
  this.getAllSectionsOfType = function(pkg, type)
  {
    var matches = new Array();
    for (keyIndex in this.keys)
    {
      key = this.keys[keyIndex];
      if(key.match(pkg) && key.match(/^[^\.]+\.[^\.]+$/))
      {
        if(this.values[key] == type)
        {
          var section = key.match(/^[^\.]+\.([^\.]+)$/)[1];
          matches.push(section);
        }
      }
    }
    return matches;
  }
  this.getAllSections = function(pkg)
  {
    var matches = new Array();
    for (keyIndex in this.keys)
    {
      key = this.keys[keyIndex];
      if(key.match(pkg) && key.match(/^[^\.]+\.[^\.]+$/))
      {
        var section = key.match(/^[^\.]+\.([^\.]+)$/)[1];
        matches.push(section);
      }
    }
    return matches;
  }

  this.remove = function(pkg, section, option)
  {
    var removeKey = pkg + "\." + section;
          if(option != "")
    {
      removeKey = removeKey + "\." + option;
    }
    if( this.listOptions[ removeKey ] != null )
    {
      this.listOptions[ removeKey ] = null;
    }

    var value = this.values[removeKey];
    if(value != null)
    {
      this.values[removeKey] = null;
      var newKeys = [];
      while(this.keys.length > 0)
      {
        var nextKey = this.keys.shift();
        if(nextKey != removeKey){ newKeys.push(nextKey); }
      }
      this.keys = newKeys;
    }
    else
    {
      value = ''
    }
    return value;
  }
  this.removeSection = function(pkg, section)
  {
    removeKeys = new Array();
    sectionDefined = false;
    for (keyIndex in this.keys)
    {
      key = this.keys[keyIndex];
      testExp = new RegExp(pkg + "\\." + section + "\\.");
      if(key.match(testExp))
      {
        var splitKey = key.split("\.");
        removeKeys.push(splitKey[2]);
      }
      if(key == pkg + "." + section)
      {
        sectionDefined = true;
      }

    }
    for (rkIndex in removeKeys)
    {
      this.remove(pkg, section, removeKeys[rkIndex]);
    }
    if(sectionDefined)
    {
      this.remove(pkg, section, "");
    }
  }

  this.clone = function()
  {
    var copy = new UCIContainer();
    var keyIndex = 0;
    for(keyIndex = 0; keyIndex < this.keys.length; keyIndex++)
    {
      var key = this.keys[keyIndex];
      var val = this.values[key]
      if( this.listOptions[ key ] != null )
      {
        copy.listOptions[ key ] = 1;
      }

      var splitKey = key.match(/^([^\.]+)\.([^\.]+)\.([^\.]+)$/);
      if(splitKey == null)
      {
        splitKey = key.match(/^([^\.]+)\.([^\.]+)$/);
        if(splitKey != null)
        {
          splitKey.push("");
        }
        else
        {
          //should never get here -- if problems put debugging code here
                //val = val;    // good enough for a breakpoint to be set.
        }
      }
      copy.set(splitKey[1], splitKey[2], splitKey[3], val, true);
    }
    return copy;
  }

  this.print = function()
  {
    var str="";
    var keyIndex=0;
    for(keyIndex=0; keyIndex < this.keys.length; keyIndex++)
    {
      var key = this.keys[keyIndex]
      if(this.values[key] instanceof Array )
      {
        str=str+ "\n" + key + " = \"" + this.values[key].join(",") + "\"";
      }
      else
      {
        str=str+ "\n" + key + " = \"" + this.values[key] + "\"";
      }
    }
    return str;
  }

  // sections are printed in the same order they were added (with the set method)
  this.getScriptCommands = function(oldSettings)
  {
    var commandArray = new Array();

    var listsWithoutUpdates = [];

    var keyIndex=0;
    for(keyIndex=0; keyIndex < oldSettings.keys.length; keyIndex++)
    {
      var key = oldSettings.keys[keyIndex];
      var oldValue = oldSettings.values[key];
      var newValue = this.values[key];

      if( (oldValue instanceof Array && !(newValue instanceof Array)) || (newValue instanceof Array   && !(oldValue instanceof Array))  )
      {
        commandArray.push( "uci del " + key);
      }
      else if (oldValue instanceof Array && newValue instanceof Array)
      {
        var matches = oldValue.length == newValue.length;
        if(matches)
        {
          var sortedOld = oldValue.sort()
          var sortedNew = newValue.sort()
          var sortedIndex;
          for(sortedIndex=0; matches && sortedIndex <sortedOld.length; sortedIndex++)
          {
            matches = sortedOld[sortedIndex] == sortedNew[sortedIndex] ? true : false
          }
        }
        if(matches)
        {
          listsWithoutUpdates[key] = 1
        }
        else
        {
          commandArray.push( "uci del " + key);
        }

      }
      else if((newValue == null || newValue == '') && (oldValue != null && oldValue !=''))
      {
        commandArray.push( "uci del " + key);
      }
    }

    for(keyIndex=0; keyIndex < this.keys.length; keyIndex++)
    {
      var key = this.keys[keyIndex];
      var oldValue = oldSettings.values[key];
      var newValue = this.values[key];
      try
      {

        if( (oldValue instanceof Array) || (newValue instanceof Array) )
        {
          if(newValue instanceof Array)
          {
            if(listsWithoutUpdates[key] == null)
            {
              var vi;
              for(vi=0; vi< newValue.length ; vi++)
              {
                var nv = "" + newValue[vi] + "";
                commandArray.push( "uci add_list " + key + "=\'" + nv.replace(/'/, "'\\''") + "\'" );
              }
            }
          }
          else
          {
            newValue = "" + newValue + ""
            commandArray.push( "uci set " + key + "=\'" + newValue.replace(/'/, "'\\''") + "\'" );
          }
        }
        else if(oldValue != newValue && (newValue != null && newValue !=''))
        {
          newValue = "" + newValue + ""
          commandArray.push( "uci set " + key + "=\'" + newValue.replace(/'/, "'\\''") + "\'" );
        }
      }
      catch(e)
      {
        alert("bad key = " + key + "\n");
      }
    }

    commandArray.push("uci commit");

    return commandArray.join("\n");
  }
}


function quickSubmit(data){
  Ha.mask.show();
  var post_data = $.parseJSON(data);
  if(post_data.confirm){
    Ha.mask.hide();
    var isConfirmed = confirm(post_data.confirm);
    if(!isConfirmed){
      Ha.mask.hide();
      return false;
    }
    Ha.mask.show();
  }
  $.post('/',post_data,function(data){
    Ha.mask.hide();
    if(post_data.response == 'json'){
      $('#response-container').addClass('hidden');
      Ha.showNotify(data);
    }else{
      $('#response-container').removeClass('hidden').html(data);
    }
  },post_data.response);
}


/*
 *confirm通用方法
 *主要针对btn的confirm和switch开关的confirm，根据类型不同，传入不同数量参数
 *DOM节点要保证这几个类名ID名不变：.modal-title,.confirm-text,#confirm_btn
 *
*/

Ha.setConfirmModal = function(modalId,modalTitle,modalText,callback,switchId){
  //参数分别为modal的id，modal的标题文本，modal的内容文本，按下确认键后的回调函数，switch开关div的id
  $('#' + modalId).find('.modal-title').html(modalTitle);
  $('#' + modalId).find('.confirm-text').html(modalText);
  $('#' + modalId).find('#confirm_btn').unbind('click');
  $('#' + modalId).find('#confirm_btn').bind('click',function(){
    if((typeof switchId) != 'undefined'){
      callback(switchId);
    }else{
      callback();
    }
    $('#' + modalId).modal('hide');
    $('#' + modalId).find('#confirm_btn').unbind('click');
  });
};
Ha.alterModal = function(modalId,modalTitle,modalText,callback,switchId){
    if((typeof switchId) != 'undefined'){
      $('#' + switchId).find('[type="checkbox"]').prop('disabled',true);
      Ha.setConfirmModal(modalId,modalTitle,modalText,callback,switchId);
    }else{
      Ha.setConfirmModal(modalId,modalTitle,modalText,callback);
    }
};
Ha.setSwitchBtn = function(id,val,checked){//请求或动作完成后进行的操作，参数为switch开关的id，请求或动作的结果(true、false)，当前按钮的状态
  $('#' + id).find('[type="checkbox"]').prop('disabled',false);
    if(val){
      $('#' + id).find('[type="checkbox"]').prop('checked',!checked);
    }else{
      $('#' + id).find('[type="checkbox"]').prop('checked',checked);
    }
};

function validateIP(address){//验证ip是否有效
  var errorCode = 0;
  if(address == "0.0.0.0"){
    errorCode = 1;
  }
  else if(address == "255.255.255.255"){
    errorCode = 2;
  }
  else{
    var ipFields = address.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
    if(ipFields == null){
      errorCode = 5;
    }
    else{
      for(field=1; field <= 4; field++){
        if(ipFields[field] > 255){
          errorCode = 4;
        }
        if(ipFields[field] == 255 && field==4){
          errorCode = 3;
        }
      }
    }
  }
  return errorCode;
}

function validateMac(mac){
  var errorCode = 0;
  var macFields = mac.split(/:/);
  if(macFields.length != 6){
    errorCode = 2;
  }else{
    for(fieldIndex=0; fieldIndex < 6 && errorCode == 0; fieldIndex++){
      field = macFields[fieldIndex];
      if(field.match(/^[0123456789ABCDEFabcdef]{2}$/) == null){
        errorCode = 1;
      }
    }
  }
  return errorCode;
}

function validateDomain(str){
  var errorCode = 0;
  var strRegex = "^(([0-9a-z_!~*'()-]+\.)*" // 域名- www. 
                + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\." // 二级域名 
                + "[a-z]{2,6})" // first level domain- .com or .museum 
                + "(:[0-9]{1,4})?" // 端口- :80 
                + "((/?)|" // a slash isn't required if there is no file name 
                + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$"; 
  var re=new RegExp(strRegex);
  if(!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
}

function validateHostName(str){
  var errorCode = 0;
  var strRegex = "^(([0-9a-zA-Z-]+)*)$"; 
  var re=new RegExp(strRegex);
  if(!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
}

function validateURL(str){
  var errorCode = 0;
  var strRegex = "^((https|http|ftp|rtsp|mms)?://)" 
                + "?(([0-9a-z_!~*'().&=+$%-]+: )?[0-9a-z_!~*'().&=+$%-]+@)?" //ftp的user@ 
                + "(([0-9]{1,3}\.){3}[0-9]{1,3}" // IP形式的URL- 199.194.52.184 
                + "|" // 允许IP和DOMAIN（域名）
                + "([0-9a-z_!~*'()-]+\.)*" // 域名- www. 
                + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\." // 二级域名 
                + "[a-z]{2,6})" // first level domain- .com or .museum 
                + "(:[0-9]{1,4})?" // 端口- :80 
                + "((/?)|" // a slash isn't required if there is no file name 
                + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$"; 
  var re=new RegExp(strRegex); 
  if (!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
}

function validatePath(str){
  var errorCode = 0;
  var strRegex = "^\/"; 
  var re=new RegExp(strRegex); 
  if (!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
}

function validateEmail(str){
  var errorCode = 0;
  var strRegex = "^[0-9a-z][_.0-9a-z-]{0,31}@([0-9a-z][0-9a-z-]{0,30}[0-9a-z]\.){1,4}[a-z]{2,4}$"; 
  var re=new RegExp(strRegex); 
  if (!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
}

function validatePort(str){
  var errorCode = 0;
  if(str.length<=0){
    errorCode = 1;
  }else{
    for(var j=0; j<str.length; j++){//不是数字的
      if('0123456789'.indexOf(str[j]) < 0){
        errorCode = 1;
      }else if(str.length > 5){
        errorCode = 1;
      }else if(parseInt(str) > 65535 || parseInt(str) < 1){
        errorCode = 1;
      }
    }
  }
  return errorCode;
}

function validateNum(str){
  var errorCode = 0;
  if (str.length <= 0 || isNaN(parseInt(str)) || parseInt(str) <= 0){
    errorCode = 1;
  }
  return errorCode;
}

function validatePctNum(str){
  var errorCode = 0;
  if (str.length <= 0 || isNaN(parseInt(str)) || parseInt(str) <= 0 || parseInt(str) > 100){
    errorCode = 1;
  }
  return errorCode;
}

function validateReq(str){
  var errorCode = 0;
  if (str.length <= 0){
    errorCode = 1;
  }
  return errorCode;
}

var va = {};

va.validateIP = function(address){//验证ip是否有效
  var errorCode = 0;
  if(address == "0.0.0.0"){
    errorCode = 1;
  }
  else if(address == "255.255.255.255"){
    errorCode = 2;
  }
  else{
    var ipFields = address.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
    if(ipFields == null){
      errorCode = 5;
    }
    else{
      for(field=1; field <= 4; field++){
        if(ipFields[field] > 255){
          errorCode = 4;
        }
        if(ipFields[field] == 255 && field==4){
          errorCode = 3;
        }
      }
    }
  }
  return errorCode;
};

va.validateMac = function(mac){
  var errorCode = 0;
  var macFields = mac.split(/:/);
  if(macFields.length != 6){
    errorCode = 2;
  }else{
    for(fieldIndex=0; fieldIndex < 6 && errorCode == 0; fieldIndex++){
      field = macFields[fieldIndex];
      if(field.match(/^[0123456789ABCDEFabcdef]{2}$/) == null){
        errorCode = 1;
      }
    }
  }
  return errorCode;
};

va.validateDomain = function(str){
  var errorCode = 0;
  // var strRegex = "^(([0-9a-z_!~*'()-]+\.)*" // 域名- www. 
  //               + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\." // 二级域名 
  //               + "[a-z]{2,6})" // first level domain- .com or .museum 
  //               + "(:[0-9]{1,4})?" // 端口- :80 
  //               + "((/?)|" // a slash isn't required if there is no file name 
  //               + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$"; 
  var strRegex = '^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\.[a-zA-Z]{2,6}$';
  var re=new RegExp(strRegex);
  if(!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
};

va.validateHostName = function(str){
  var errorCode = 0;
  var strRegex = "^(([0-9a-zA-Z-]+)*)$"; 
  var re=new RegExp(strRegex);
  if(!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
};

va.validateURL = function(str){
  var errorCode = 0;
  var strRegex = "^((https|http|ftp|rtsp|mms)?://)" 
                + "?(([0-9a-z_!~*'().&=+$%-]+: )?[0-9a-z_!~*'().&=+$%-]+@)?" //ftp的user@ 
                + "(([0-9]{1,3}\.){3}[0-9]{1,3}" // IP形式的URL- 199.194.52.184 
                + "|" // 允许IP和DOMAIN（域名）
                + "([0-9a-z_!~*'()-]+\.)*" // 域名- www. 
                + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\." // 二级域名 
                + "[a-z]{2,6})" // first level domain- .com or .museum 
                + "(:[0-9]{1,4})?" // 端口- :80 
                + "((/?)|" // a slash isn't required if there is no file name 
                + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$"; 
  var re=new RegExp(strRegex); 
  if (!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
};

va.validatePath = function(str){
  var errorCode = 0;
  var strRegex = "^\/"; 
  var re=new RegExp(strRegex); 
  if (!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
};

va.validateEmail = function(str){
  var errorCode = 0;
  var strRegex = "^[0-9a-z][_.0-9a-z-]{0,31}@([0-9a-z][0-9a-z-]{0,30}[0-9a-z]\.){1,4}[a-z]{2,4}$"; 
  var re=new RegExp(strRegex); 
  if (!re.test(str)){
    errorCode = 1;
  }
  return errorCode;
};

va.validatePort = function(str){
  var errorCode = 0;
  if(str.length<=0){
    errorCode = 1;
  }else{
    for(var j=0; j<str.length; j++){//不是数字的
      if('0123456789'.indexOf(str[j]) < 0){
        errorCode = 1;
      }else if(str.length > 5){
        errorCode = 1;
      }else if(parseInt(str) > 65535 || parseInt(str) < 1){
        errorCode = 1;
      }
    }
  }
  return errorCode;
};

va.validateNum = function(str){
  var errorCode = 0;
  if (str.length <= 0 || isNaN(parseInt(str)) || parseInt(str) <= 0){
    errorCode = 1;
  }
  return errorCode;
};

va.validatePctNum = function(str){
  var errorCode = 0;
  if (str.length <= 0 || isNaN(parseInt(str)) || parseInt(str) <= 0 || parseInt(str) > 100){
    errorCode = 1;
  }
  return errorCode;
};

va.validateReq = function(str){
  var errorCode = 0;
  if (str.length <= 0){
    errorCode = 1;
  }
  return errorCode;
};

function uploadFile(id,action) {
  var fd = new FormData();
  fd.append("fileToUpload", document.getElementById(id).files[0]);
  var xhr = new XMLHttpRequest();
  xhr.upload.addEventListener("progress", uploadProgress, false);
  xhr.addEventListener("load", uploadComplete, false);
  xhr.addEventListener("error", uploadFailed, false);
  xhr.addEventListener("abort", uploadCanceled, false);
  xhr.open("POST", action);
  xhr.send(fd);
}

function uploadProgress(evt) {
  if (evt.lengthComputable) {
    var percentComplete = Math.round(evt.loaded * 100 / evt.total);
    $('.upload-progress-bar').find('span').css('width',percentComplete.toString() + '%');
    $('#progress-text').html(percentComplete.toString() + '%');

  }
  else {
    console.log('unable to compute');
  }
}

function uploadComplete(evt) {
  /* This event is raised when the server send back a response */
  //alert(evt.target.responseText);
  //console.log(evt.target.responseText);
  //window.location.href="/?app=firmware&action=preflash&file=" + name;
}

function uploadFailed(evt) {
  //alert("There was an error attempting to upload the file.");
  console.log("There was an error attempting to upload the file.");
}

function uploadCanceled(evt) {
  //alert("The upload has been canceled by the user or the browser dropped the connection.");
  console.log("The upload has been canceled by the user or the browser dropped the connection.");
}

$('#quickModal').find('.like-a-link').click(function(){
  $('#quickModal').find('.like-a-link').removeClass('active');
  $(this).addClass('active');
});
$('[data-target="#quickModal"]').click(function(){
  $('#quickModal').find('.like-a-link').removeClass('active');
});
