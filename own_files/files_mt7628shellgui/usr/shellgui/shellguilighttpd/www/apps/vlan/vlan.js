var submit_switchs = {};
initPage();
function initPage(){
	submit_switchs = {};
	for(key in switchs){
		$('#add_btn_' + key).unbind('click');
		var switch_item = switchs[key];
		setSwitch(key,switch_item);
		submit_switchs[key] = [];
		for(var i=0; i<switchs[key].vlans.length; i++){
			var vlan = $.extend({},switchs[key].vlans[i]);
			submit_switchs[key].push(vlan);
		}
	}
	$('.help-block').addClass('hidden');
}
$('#submit_page_btn').click(submitPage);
$('#reset_page_btn').click(initPage);

var new_config = -1;
function setSwitch(key,item){
	setPortTr(key,item);
	setPortIcon(key,item);
	setVlanTr(key,item);
	$('#add_btn_td_' + key).prop('colspan',item.portsCount + 2);
	$('#add_btn_' + key).bind('click',function(){
		setVlan(getNewId(key),'',new_config,key,item);
		submit_switchs[key].push({config: new_config, vlan_id: getNewId(key), ports: ''});
		Ha.setFooterPosition();
		new_config --;
	});
	setInterval(function(){
		setPortIconData(key,item);
	},5000);
}

function getNewId(key){
	var id = 1;
	var vlans = submit_switchs[key];
	for(var i=0; i<vlans.length; i++){
		id = Math.max(id,vlans[i].vlan_id);
	}
	id = id+1;
	return id;
}

function getNewPorts(key){
	var ports = [];
	var count = switchs[key].portsCount;
	for(var i=0; i<count; i++){
		ports.push(i);
	}
	return ports.join(' ');
}

function submitPage(){
	console.log(submit_switchs);
	var data = {
		app: 'vlan',
		action: 'set_vlan',
		data: submit_switchs
	};
	$.post('/',data,function(data){
		Ha.showNotify(data);
		if(!data.status){
			switchs = data.switchs;
			for(key in switchs){
				$('#add_btn_' + key).unbind('click');
				var switch_item = switchs[key];
				setSwitch(key,switch_item);
			}
		}
	},'json');
}

function setPortTr(key,item){
	var portsTr = '<th  class="text-center">Vlan ID</th>';
	for(var i=0; i<item.portsCount; i++){
		var port_tr;
		if(i == item.cpuPort){
			port_tr = '<th class="text-center">CPU</th>';
		}else{
			port_tr = '<th class="text-center">Port' + i + '</th>';
		}
		portsTr += port_tr;
	}
	$('#port_tr_' + key).empty().append(portsTr);
	$('#port_tr_' + key).append('<th></th>');
	Ha.setFooterPosition();
}

function setPortIcon(name,item){
	var tds;
	var name_sp = 'http://www.w3.org/2000/svg';
	$('#ports_status_tr_' + name).empty().append('<td></td>');
	$.post('/','app=vlan&action=port_status&switch=' + name,function(data){
		for(key in data){
			var svg = document.createElementNS(name_sp,"svg");
			svg.setAttribute('width',30);
			svg.setAttribute('height',30);
			var path = document.createElementNS(name_sp,"path");
			svg.appendChild(path);
			path.setAttribute('d','M28.063,15.377V2.312c0,0,0-1.621-1.621-1.621H2.313c-1.622,0-1.622,1.622-1.622,1.622v13.127c0,0,0,1.607,1.622,1.621l3.739-0.044l3.208,0.046l0.037,4.626l0,0c0,0-0.011,1.621,1.622,1.621h6.918c0,0,1.574,0,1.621-1.621l0.037-4.626l3.207-0.046h3.74C26.441,17.017,28.063,17,28.063,15.377z');
			path.setAttribute('stroke-width',2);
			path.setAttribute('data-id',key);
			var isLinked = data[key].link == 'up' ? true : false;
			var statuStr = isLinked ? data[key].speed + '<br>' + data[key].duplex : 'unLinked';
			var td = $('<td></td>');
			var svg_class = data[key].link == 'up' ? 'svg_fill' : 'svg_stroke';
			var svg_fill = data[key].link == 'up' ? '' : 'none';
			var svg_stroke = data[key].link == 'up' ? 'none' : '';
			path.setAttribute('class',svg_class);
			path.setAttribute('fill',svg_fill);
			path.setAttribute('stroke',svg_stroke);
			td.get(0).appendChild(svg);
			td.append('<br><span data-status="' + key + '">' + statuStr + '</span>');
			$('#ports_status_tr_' + name).append(td);
		}
		$('#ports_status_tr_' + name).append('<td></td>');
		return true;
	},'json');
	Ha.setFooterPosition();
}
function setPortIconData(name,item){
	$.post('/','app=vlan&action=port_status&switch=' + name,function(data){
		$('#ports_status_tr_' + name).find('.svg_fill').each(function(){
			$(this).removeClass('svg_fill').addClass('svg_stroke');
			$(this).get(0).setAttribute('fill','none');
		});
		setTimeout(function(){
			for(key in data){
				var isLinked = data[key].link == 'up' ? true : false;
				var statuStr = isLinked ? data[key].speed + '<br>' + data[key].duplex : 'unLinked';
				var svg_class = data[key].link == 'up' ? 'svg_fill' : 'svg_stroke';
				var svg_fill = data[key].link == 'up' ? '' : 'none';
				var svg_stroke = data[key].link == 'up' ? 'none' : '';
				var path = $('#ports_status_tr_' + name).find('[data-id="' + key + '"]').get(0);

				path.setAttribute('fill',svg_fill);
				path.setAttribute('stroke',svg_stroke);
				path.setAttribute('class',svg_class);

				$('#ports_status_tr_' + name).find('[data-status="' + key + '"]').html(statuStr);
			}
		},1000);
	},'json');
}

function setVlanTr(key,item){
	var vlans = item.vlans;
	for(var i=0; i<vlans.length; i++){
		var ports = vlans[i].ports;
		var vlan_id = vlans[i].vlan_id;
		var config = vlans[i].config;
		$('#vlan_trs_' + key).empty();
		setVlan(vlan_id,ports,config,key,item);
	}
	Ha.setFooterPosition();
}

function setVlan(id,ports,config,key,item){
	var trs = '<tr data-config="' + config + '"><td><input type="number" min="1" class="vlan_input error" size="6" value="' + id + '"></td></tr>';
	trs = $(trs);
	ports = ' ' + ports + ' ';
	for(var i=0; i<item.portsCount; i++){
		var td = '<td><select><option value="off">off</option><option value="tag">tag</option><option value="untag">untag</option></select></td>';
		td = $(td);
		var reg = '[^0-9]' + i + '[^0-9]t?';
		var re=new RegExp(reg); 
	  if (re.test(ports)){
	    if(ports.charAt(ports.indexOf(i) + 1) == 't'){
	    	td.find('select').val('tag');
	    }else{
	    	td.find('select').val('untag');
	    }
	  }else{
	  	td.find('select').val('off');
	  }
	  trs.append(td);
	}
  
	var removeBtn = $('<td><button class="btn btn-xs btn-danger">Remove</button></td>');
  trs.append(removeBtn);
	$('#vlan_trs_' + key).append(trs);

	var sumSel = 0;
  trs.find('select').each(function(index){
  	var val = $(this).val();
  	if(val != 'off'){
  		sumSel += 1;
  	}
  	$(this).change(function(){
  		var val = $(this).val();
  		var config = $(this).parent().parent().attr('data-config');
  		var validate = checkSelect(config);
  		if(validate){
  			trs.find('select').addClass('error')
  			console.log(key);
  			$('#add_btn_td_' + key).find('.port-help').removeClass('hidden');
  		}else{
  			trs.find('select').removeClass('error')
  			$('#add_btn_td_' + key).find('.port-help').addClass('hidden');
  		}
			setPorts(key,config,index,val);
  		disableBtn();
  	});
  });

  if(!sumSel){
  	trs.find('select').addClass('error')
		$('#add_btn_td_' + key).find('.port-help').removeClass('hidden');
  }else{
  	trs.find('select').removeClass('error')
		$('#add_btn_td_' + key).find('.port-help').addClass('hidden');
  }

	if(id != ''){
  	trs.find('input').removeClass('error');
  }
  disableBtn();
	removeBtn.find('button').click(function(){
		$(this).parent().parent().remove();
		var config = $(this).parent().parent().attr('data-config');
		for(var a=0; a<submit_switchs[key].length; a++){
			if(config == submit_switchs[key][a].config){
				submit_switchs[key].splice(a,1);
			}
		}
  	disableBtn();
	});

	$('.vlan_input').bind('keyup',function(){
		var val = $(this).val();
		var config = $(this).parent().parent().attr('data-config');
		if(va.validateNum(val)){
			$(this).addClass('error');
			$('#add_btn_td_' + key).find('.id-help').removeClass('hidden');
		}else{
			if(!uniqueId(val,config,key)){
				$(this).addClass('error');
  			$('#add_btn_td_' + key).find('.id-help').removeClass('hidden');
			}else{
				$(this).removeClass('error');
  			$('#add_btn_td_' + key).find('.id-help').addClass('hidden');
				for(var i=0; i<submit_switchs[key].length; i++){
					if(config == submit_switchs[key][i].config){
						submit_switchs[key][i].vlan_id = parseInt(val);
					}
				}
			}
		}
		disableBtn();
	});
	$('.vlan_input').bind('blur',function(){
		var val = $(this).val();
		var config = $(this).parent().parent().attr('data-config');
		if(va.validateNum(val)){
			for(var i=0; i<submit_switchs[key].length; i++){
				if(config == submit_switchs[key][i].config){
					$(this).val(submit_switchs[key][i].vlan_id);
				}
			}
			$(this).removeClass('error');
			$('#add_btn_td_' + key).find('.id-help').addClass('hidden');
		}else{
			if(!uniqueId(val,config,key)){
  			for(var i=0; i<submit_switchs[key].length; i++){
					if(config == submit_switchs[key][i].config){
						$(this).val(submit_switchs[key][i].vlan_id);
					}
				}
				$(this).removeClass('error');
  			$('#add_btn_td_' + key).find('.id-help').addClass('hidden');
			}else{
				$(this).removeClass('error');
  			$('#add_btn_td_' + key).find('.id-help').addClass('hidden');
				for(var i=0; i<submit_switchs[key].length; i++){
					if(config == submit_switchs[key][i].config){
						submit_switchs[key][i].vlan_id = parseInt(val);
					}
				}
			}
		}
		disableBtn();
	});
	Ha.setFooterPosition();
}

function checkSelect(config){
	var sum = 0;
	$('[data-config="' + config + '"]').find('select').each(function(){
		if($(this).val() !== 'off'){
			sum += 1;
		}
	});

	if(sum){
		return false;
	}else{
		return true;
	}
}

function uniqueId(id,config,key){
	for(var i=0; i<submit_switchs[key].length; i++){
		if(id == submit_switchs[key][i].vlan_id && config != submit_switchs[key][i].config){
			return false;
		}
	}
	return true;
}

function disableBtn(){
	var sum = 0;
	$('.vlan_input,select').each(function(){
		if($(this).hasClass('error')){
			sum += 1;
		}
	});
	if(sum){
		$('#submit_page_btn').prop('disabled',true);
	}else{
		$('#submit_page_btn').prop('disabled',false);
		$('.help-block').addClass('hidden');
	}
}

function setPorts(key,config,index,value){
	var vlans = submit_switchs[key];
	for(var i=0; i<vlans.length; i++){
		if(config == vlans[i].config){
			submit_switchs[key][i].ports = setPortsStr(value,index,vlans[i].ports);
		}
	}
}

function setPortsStr(value,index,ports){
	ports = ' ' + ports + ' ';
	var reg = '[^0-9]' + index + '[^0-9]t?';
	var re=new RegExp(reg); 
	if(re.test(ports)){
		//原来就是开启的
		if(ports.indexOf(' ' + index + 't ') >= 0){
			if(value == 'off'){
				ports = ports.replace(' ' + index + 't ', ' ');
			}else if(value == 'tag'){
				ports = ports;
			}else if(value == 'untag'){
				ports = ports.replace(' ' + index + 't ', ' ' + index);
			}
		}else{
			if(value == 'off'){
				ports = ports.replace(' ' + index + ' ', ' ');
			}else if(value == 'tag'){
				ports = ports.replace(' ' + index + ' ', ' ' + index + 't ');
			}else if(value == 'untag'){
				ports = ports;
			}
		}
	}else{
		if(value == 'off'){
			ports = ports;
		}else if(value == 'tag'){
			ports = ports + ' ' + index + 't ';
		}else if(value == 'untag'){
			ports = ports + ' ' + index + ' ';
		}
	}
	ports = $.trim(ports);
	ports = ports.split(' ');
	for(var i=0; i<ports.length; i++){
		ports[i] = $.trim(ports[i]);
		if(ports[i] == ''){
			ports.splice(i,1);
		}
	}
	ports = ports.sort(function(a,b){
		return parseInt(a)-parseInt(b);
	});
	return ports.join(' ');
}
