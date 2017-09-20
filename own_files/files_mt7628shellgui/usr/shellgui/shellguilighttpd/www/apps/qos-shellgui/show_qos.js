//状态页面

function setBrowserTimeCookie() {
    var e = Math.floor((new Date).getTime() / 1e3);
    document.cookie = "browser_time=" + e + "; path=/";
}
function getRequestObj() {
    var e;
    try {
        e = new XMLHttpRequest;
    } catch (t) {
        try {
            e = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (t) {
            try {
                e = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (t) {
                return !1;
            }
        }
    }
    return e;
}
function runAjax(e, t, n, r) {
    setBrowserTimeCookie();
    var i = getRequestObj();
    return i && (i.onreadystatechange = function() {
        r(i)
    }
        ,
        e == "POST" ? (n = n == null ? " " : n,
            i.open("POST", t, !0),
            i.setRequestHeader("Content-type", "application/x-www-form-urlencoded"),
            i.send(n)) : e == "GET" && (i.open("GET", t + "?" + n, !0),
            i.send(null ))),
        i
}
function getParameterDefinition(e, t) {
    return encodeURIComponent(e) + "=" + encodeURIComponent(t)
}
function parseBytes(bytes, units, abbr, dDgt)
{
    var parsed;
    units = units != "KBytes" && units != "MBytes" && units != "GBytes" && units != "TBytes" ? "mixed" : units;
    spcr = abbr==null||abbr==0 ? " " : "";
    if( (units == "mixed" && bytes > 1024*1024*1024*1024) || units == "TBytes")
    {
        parsed = (bytes/(1024*1024*1024*1024)).toFixed(dDgt||3) + spcr + (abbr?'TB':'TBy');
    }
    else if( (units == "mixed" && bytes > 1024*1024*1024) || units == "GBytes")
    {
        parsed = (bytes/(1024*1024*1024)).toFixed(dDgt||3) + spcr + (abbr?'GB':'GBy');
    }
    else if( (units == "mixed" && bytes > 1024*1024) || units == "MBytes" )
    {
        parsed = (bytes/(1024*1024)).toFixed(dDgt||3) + spcr + (abbr?'MB':'MBy');
    }
    else
    {
        parsed = (bytes/(1024)).toFixed(dDgt||3) + spcr + (abbr?'KB':'KBy');
    }
    return parsed;
}


function getSelectedValue(selectId, controlDocument)
{
    controlDocument = controlDocument == null ? document : controlDocument;

    if(controlDocument.getElementById(selectId) == null)
    {
        alert(UI.Err+": " + selectId + " "+UI.nex);
        return;
    }

    selectedIndex = controlDocument.getElementById(selectId).selectedIndex;
    selectedValue = "";
    if(selectedIndex >= 0)
    {
        selectedValue= controlDocument.getElementById(selectId).options[ controlDocument.getElementById(selectId).selectedIndex ].value;
    }
    return selectedValue;
}

window.onresize = function() {
    try {
        document.getElementById("darken").style.display == "block" && setControlsEnabled(!1, document.getElementById("wait_msg").style.display == "block")
    } catch (t) {}
};

var qosStr=new Object(); //part of i18n

var uploadClassIds = [];
var downloadClassIds = [];
var uploadClassNames = [];
var downloadClassNames = [];

var uploadUpdateInProgress = false;
var downloadUpdateInProgress = false;
var updateInProgress = false;

var setUploadPie = null;
var setDownloadPie = null;

var ctx_up,ctx_down,data_up,data_down,upPieChart,downPieChart;

$('#up_timeframe,#down_timeframe').change(function(){
    updatePieCharts();
})
function initializePieCharts()
{

    uploadClassIds = [];
    downloadClassIds = [];
    uploadClassNames = [];
    downloadClassNames = [];

    var definedUploadClasses = [];
    var definedDownloadClasses = [];
    for(monitorIndex=0; monitorIndex < monitorNames.length; monitorIndex++)
    {
        var monId = monitorNames[monitorIndex];
        if(monId.match(/qos/))
        {
            var isQosUpload = monId.match(/up/);
            var isQosDownload = monId.match(/down/);

            var splitId = monId.split("-");
            splitId.shift();
            splitId.shift();
            splitId.pop();
            splitId.pop();
            var qosClass = splitId.join("-");
            var qosName = uciOriginal.get("qos_shellgui", qosClass, "name");

            if(isQosUpload && definedUploadClasses[qosClass] == null)
            {
                uploadClassIds.push(qosClass);
                uploadClassNames.push(qosName);
                definedUploadClasses[qosClass] = 1;
            }
            if(isQosDownload && definedDownloadClasses[qosClass] == null)
            {
                downloadClassIds.push(qosClass);
                downloadClassNames.push(qosName);
                definedDownloadClasses[qosClass] = 1;
            }
        }
    }
    uploadClassNames = formateLabel(uploadClassNames);
    downloadClassNames = formateLabel(downloadClassNames);
    initPieChart(uploadClassNames,downloadClassNames);

    setInterval(updatePieCharts, 2000);
}

function getMonitorId(isUp, graphTimeFrameIndex, plotType, plotId, graphNonTotal)
{
    var nameIndex;
    var selectedName = null;

    var match1 = "";
    var match2 = "";

    if(plotType == "total")
    {
        match1 = graphNonTotal ? "total" + graphTimeFrameIndex + "B" : "total" + graphTimeFrameIndex + "A";
    }
    else if(plotType.match(/qos/))
    {
        match1 = "qos" + graphTimeFrameIndex;
        match2 = plotId;
    }
    else if(plotType == "ip")
    {
        match1 = "bdist" + graphTimeFrameIndex;
    }

    if(plotType != "none")
    {
        for(nameIndex=0;nameIndex < monitorNames.length && selectedName == null; nameIndex++)
        {
            var name = monitorNames[nameIndex];
            if( ((name.match("up") && isUp) || (name.match("down") && !isUp)) &&
                (match1 == "" || name.match(match1)) &&
                (match2 == "" || name.match(match2))
            )
            {
                selectedName = name;
            }
        }
    }
    return selectedName;
}


function updatePieCharts()
{
    if(!updateInProgress)
    {
        updateInProgress=true;

        var directions = ["up", "down" ];
        // var monitorQueryNames = ["qos1-up-uclass_1-minute-15", "qos1-up-uclass_2-minute-15", "qos1-up-uclass_3-minute-15", "qos1-up-uclass_4-minute-15", "qos1-down-dclass_1-minute-15", "qos1-down-dclass_2-minute-15", "qos1-down-dclass_3-minute-15", "qos1-down-dclass_4-minute-15"];
        var monitorQueryNames = [];
        for(directionIndex = 0; directionIndex < directions.length; directionIndex++)
        {
            var direction = directions[directionIndex];
            var classIdList = direction == "up" ? uploadClassIds : downloadClassIds;
            //----------------------------------------------------------------------------------
            var timeFrameIndex = parseInt(getSelectedValue(direction + "_timeframe"));//获取时间格式，并根据这个处理请求参数
            for(classIndex=0; classIndex < classIdList.length; classIndex++)
            {
                monitorQueryNames.push( getMonitorId((direction == "up" ? true : false), timeFrameIndex, "qos", classIdList[classIndex], true) );
            }
        }
        var param_monitor = getParameterDefinition("monitor", monitorQueryNames.join(" "));
        var param = 'app=qos-shellgui&action=get_bandwidth&' + param_monitor;


        var stateChangeFunction = function(req)
        {
            if(req.readyState == 4)
            {
                var monitors = parseMonitors(req.responseText);
                var directions = ["up", "down" ];
                var uploadClassData = [];
                var uploadClassLabels = [];
                var downloadClassData = [];
                var downloadClassLabels = [];
                for(directionIndex = 0; directionIndex < directions.length; directionIndex++)
                {
                    var direction = directions[directionIndex];
                    var classData = [];
                    var totalSum = 0;
                    var classLabels = [];
                    var directionMonitorNames = [];
                    for(nameIndex=0; nameIndex < monitorQueryNames.length; nameIndex++)
                    {
                        if(monitorQueryNames[nameIndex].match(direction))
                        {
                            var classSum = 0;
                            var monitor = monitors[ monitorQueryNames[nameIndex] ];
                            if( monitor != null)
                            {
                                var points = monitor[0];
                                classSum = parseInt(points[points.length-1]);
                            }
                            classData.push(classSum);
                            totalSum = totalSum + classSum;
                        }
                    }
                    var sumIsZero = totalSum == 0 ? true : false;
                    if(sumIsZero)
                    {
                        var classIndex;
                        for(classIndex=0; classIndex < classData.length; classIndex++)
                        {
                            classData[classIndex] = 1;
                            totalSum++;
                        }
                    }
                    for(nameIndex=0; nameIndex < classData.length; nameIndex++)
                    {
                        var classNameList = direction.match("up") ? uploadClassNames : downloadClassNames;
                        classNameList = formateLabel(classNameList);
                        className = classNameList[nameIndex];
                        if(sumIsZero)
                        {
                            var percentage = "(" + truncateDecimal( 100*(1/classData.length) ) + "%)";
                            classLabels.push( className + " - " + parseBytes((classData[nameIndex]-1),null,true) + " " + percentage);

                        }
                        else
                        {
                            var percentage = "(" + truncateDecimal( 100*(classData[nameIndex])/totalSum ) + "%)";
                            classLabels.push( className + " - " + parseBytes(classData[nameIndex],null,true) + " " + percentage);
                        }
                    }


                    uploadClassData = direction.match("up") ? classData : uploadClassData;
                    uploadClassLabels = direction.match("up") ? classLabels : uploadClassLabels;
                    downloadClassData = direction.match("down") ? classData : downloadClassData;
                    downloadClassLabels = direction.match("down") ? classLabels : downloadClassLabels;

                }
                updatePieChart(uploadClassData,uploadClassLabels,downloadClassData,downloadClassLabels);
                updateInProgress = false;
            }
        }
        runAjax("POST", "/", param, stateChangeFunction);
    }
}

function parseMonitors(outputData)
{
    var monitors = new Array();
    var dataLines = outputData.split("\n");
    var currentDate = parseInt(dataLines.shift());
    for(lineIndex=0; lineIndex < dataLines.length; lineIndex++)
    {
        if(dataLines[lineIndex].length > 0)
        {
            monitorName = dataLines[lineIndex];
            monitorName = monitorName.replace(/[\t ]+.*$/, "");
            lineIndex++;
            lineIndex++; //ignore first interval start
            lineIndex++; //ignore first interval end
            lastTimePoint = dataLines[lineIndex];
            lineIndex++;
            points = dataLines[lineIndex].split(",");
            monitors[monitorName] = [points, lastTimePoint];
        }
    }
    return monitors;
}

function truncateDecimal(dec)
{
    result = "" + ((Math.floor(dec*1000))/1000);

    decMatch=result.match(/.*\.(.*)$/);
    if(decMatch == null)
    {
        result = result + ".000"
    }
    else
    {
        if(decMatch[1].length==1)
        {
            result = result + "00";
        }
        else if(decMatch[1].length==2)
        {
            result = result + "0";
        }
    }
    return result;
}



initializePieCharts();


function initPieChart(label_up,label_down){
	var dataup = [],datadown = [];
	for(var i=0; i<label_up.length; i++){
		dataup.push(1);
	}
	for(var i=0; i<label_down.length; i++){
		datadown.push(1);
	}
    ctx_up = document.getElementById("uploadChart");
    ctx_down = document.getElementById("downloadChart");
    var colorLibs = [
                    "#8E44AD",
                    "#E74C3C",
                    "#27AE60",
                    "#2980B9",
                    "#7F8C8D",
                    "#BDC3C7",
                    "#F1C40F",
                    "#16A085",
                    "#E67E22",
                    "#34495E"
                ];
    var color_up = colorLibs.slice(0,label_up.length);
    var color_down = colorLibs.slice(0,label_down.length);

    for(var i=0; i<label_up.length; i++){
        var legend_dom = '<div class="legend_item" style="background-color: ' + color_up[i] + '">'
                       +    '<span class="legend_label">&nbsp;&nbsp;<span id="up_legend_text_' + i + '">' + label_up[i] + ' - ' + UI.loading + '...</span></span>'
                       +    '<span class="line-through hidden"></span>'
                       + '</div>';
        $('#up_legend_container').append(legend_dom);
    }
    for(var i=0; i<label_down.length; i++){
        var legend_dom = '<div class="legend_item" style="background-color: ' + color_down[i] + '">'
                       +    '<span class="legend_label">&nbsp;&nbsp;<span id="down_legend_text_' + i + '">' + label_down[i] + ' - ' + UI.loading + '...</span></span>'
                       +    '<span class="line-through hidden"></span>'
                       + '</div>';
        $('#down_legend_container').append(legend_dom);
    }

    $('.legend_item').click(function(){
        if($(this).find('.line-through').hasClass('hidden')){
            $(this).find('.line-through').removeClass('hidden');
            updatePieCharts();
        }else{
            $(this).find('.line-through').addClass('hidden');
            updatePieCharts();
        }
    });
    data_up = {
        labels: label_up,
        datasets: [
            {
                data: dataup,
                backgroundColor: color_up,
                hoverBackgroundColor: color_up
            }]
    };
    data_down = {
        labels: label_down,
        datasets: [
            {
                data: datadown,
                backgroundColor: color_down,
                hoverBackgroundColor: color_down
            }]
    };
    upPieChart = new Chart(ctx_up,{
        type: 'pie',
        data: data_up,
        options:{
            // responsive: false,
            legend: {
                display: false
            },
            tooltips: {
                enabled: true,
                callbacks: {
                    label: function(arr,data){
                        var data = data.labels[arr.index];
                        var label = [];
                        var name = data.split('-').shift();
                        var datas = data.split('-').pop().replace(' ','');
                        label.push(name);
                        if(name != datas){
                            label.push(datas);
                        }
                        return label;
                    }
                }
            }
        }
    });
    downPieChart = new Chart(ctx_down,{
        type: 'pie',
        data: data_down,
        options:{
            // responsive: true,
            legend: {
                display: false
            },
            tooltips: {
                enabled: true,
                callbacks: {
                    label: function(arr,data){
                        var data = data.labels[arr.index];
                        var label = [];
                        var name = data.split('-').shift();
                        var datas = data.split('-').pop().replace(' ','');
                        label.push(name);
                        if(name != datas){
                            label.push(datas);
                        }
                        return label;
                    }
                }
            }
        }
    });

    Ha.setFooterPosition();

}

function updatePieChart(data_up,labels_up,data_down,labels_down){
    for(var i=0; i<labels_up.length; i++){
        $('#up_legend_text_' + i).html(labels_up[i]);
    }
    for(var i=0; i<labels_down.length; i++){
        $('#down_legend_text_' + i).html(labels_down[i]);
    }

    $('.legend_item').each(function(){
        var hidden = $(this).find('.line-through').hasClass('hidden');
        var id = $(this).find('.legend_label').find('span').prop('id');
        var action = id.split('_').shift();
        var locate = id.split('_').pop();
        if(action == 'up'){
            if(!hidden){
            data_up[locate] = 0;
            }
        }else{
            if(!hidden){
                data_down[locate] = 0;
            }
        }
    });
    var activeData_up = data_up;
    upPieChart.config.data.datasets[0].data = activeData_up;
    upPieChart.config.data.labels = labels_up;
    upPieChart.update();
    var activeData_down = data_down;
    downPieChart.config.data.datasets[0].data = activeData_down;
    downPieChart.config.data.labels = labels_down;
    downPieChart.update();
    Ha.setFooterPosition();
}

function formateLabel(data){
    for(var i=0; i<data.length; i++){
        for(var key in UI){
            if(data[i] == key){
                data[i] = UI[key];
            }
        }
    }
    return data;
}
