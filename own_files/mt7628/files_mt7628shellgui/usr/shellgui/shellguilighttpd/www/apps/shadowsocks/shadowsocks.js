var originData,serverData,configData,localData,redirData,statusData;

$.post('/','app=shadowsocks&action=get_client_configs',function(data){
	originData = data;
	resetPageData(originData);
},'json');

$('#add_config_btn').click(addConfig);
$('#save_config').click(function(){
	var type = $(this).attr('data-type');
	var id = $(this).attr('data-id');
	if(id == 0){
		var num = 0;
		for(var key in configData){
			num++;
		}
		id = num+1;
	}
	saveConfig(type,id);
});

$('#reset_page_btn').click(function(){
	$.post('/','app=shadowsocks&action=get_client_configs',resetPageData,'json');
});

$('#save_page_btn').click(submitPage);

function getEmptyConfig(){
	return data = {
		desc: '',
		data: {
			method: 'table',
			password: '',
			server: '',
			local_address: '',
			server_port: '',
			timeout: '',
			local_port: ''
		}
	};
}

function resetPageData(data){
	//显示运行状态
	statusData = data.status;
	$('#server_status').html(statusData.server == 1 ? UI.Runed : UI.Not_Runed);
	$('#local_status').html(statusData.local == 1 ? UI.Runed : UI.Not_Runed);
	$('#redir_status').html(statusData.redir == 1 ? UI.Runed : UI.Not_Runed);

	//set shadowsocks server
	serverData = data.server.data;
	serverData.enabled = data.server.enabled;
	setServerData(serverData);

	//设置config表格及选择项
	configData = data.client_configs;
	setClientConfig(configData);
	

	//set local
	localData = data.local;
	setLocal(localData);

	//set redir
	redirData = data.redir;
	setRedir(redirData);

}

function setServerData(data){
	$('#server_enabled').prop('checked',data.enabled == 1 ? true : false);
	$('#server_bind_ip').val(data.server);
	$('#server_bind_port').val(data.server_port);
	$('#server_password').val(data.password);
	$('#server_timeout').val(data.timeout);
	$('#enc_method').val(data.method);
}

function setClientConfig(data){
	$('#local_config,#redir_config,#config_container').empty();
	for(var key in data){
		$('#local_config,#redir_config').append('<option value="' + key + '">' + data[key]['desc'] + '</option>')
		//设置表格
		var tr = '<tr data-id="' + key + '">'
			   + 	'<td>' + data[key]['desc'] + '</td>'
			   +	'<td><button class="btn btn-primary btn-xs edit_config" data-id="' + key + '"'
			   +	'data-toggle="modal" data-target="#configModal">'+UI.Edit+'</button></td>'
			   +	'<td><button class="btn btn-danger btn-xs remove_config" data-id="' + key + '">'+UI.Remove+'</button></td>'
			   + '</tr>'
		$('#config_container').append(tr);
	}
	$('.edit_config').click(function(){
		var id = $(this).attr('data-id');
		var data = configData[id];
		editConfig(id,data);
	});
	$('.remove_config').click(function(){
		var id = $(this).attr('data-id');
		removeConfig(id);
	});
}

function setLocal(data){
	$('#local_enabled').prop('checked',data.enabled == 1 ? true : false);
	$('#local_config').val(data.client_config);
}

function setRedir(data){
	$('#redir_enabled').prop('checked',data.enabled == 1 ? true : false);
	$('#redir_config').val(data.client_config);
	//外网规则
	$('#geoip_cc').val(data.external.except_cc.join(','));
	$('#geoip_cc').focus(function(){
		$(this).parent().find('.help-block').removeClass('hidden');
	});
	$('#geoip_cc').blur(function(){
		$(this).parent().find('.help-block').addClass('hidden');
	});
	$('#hit_ips').val(data.external.except_ips.join('\n'));
	//内网规则
	$('#internal_mode').prop('checked',data.internal_mode == 'all' ? true : false);
	$('#internal_except_ips').val(data.internal.except_ips.join('\n'));
	$('#internal_hit_ips').val(data.internal.hit_ips.join('\n'));
	$('textarea').focus(function(){
		$(this).parent().find('.help-block').removeClass('hidden');
	}).blur(function(){
		$(this).parent().find('.help-block').addClass('hidden');
	});
}

function editConfig(id,data){
	$('#configModalLabel').html(UI.Edit_Client_Config);
	$('#save_config').attr('data-type','edit').attr('data-id',id).html(UI.Save);
	setConfigForm(data);
}

function addConfig(){
	$('#configModalLabel').html(UI.Add_new_Client_Config);
	$('#save_config').attr('data-type','add').attr('data-id',0).html(UI.Add);
	var data = getEmptyConfig();
	setConfigForm(data);
}

function setConfigForm(data){
	$('#config_desc').val(data.desc);
	$('#config_server_ip').val(data.data.server);
	$('#config_server_port').val(data.data.server_port);
	$('#config_password').val(data.data.password);
	$('#config_local_ip').val(data.data.local_address);
	$('#config_local_port').val(data.data.local_port);
	$('#config_timeout').val(data.data.timeout);
	$('#config_enc_method').val(data.data.method);
}

function saveConfig(type,id){
	var data = getEmptyConfig().data;
	data.method = $('#config_enc_method').val();
	data.password = $('#config_password').val();
	data.server = $('#config_server_ip').val();
	data.server_port = parseInt($('#config_server_port').val());
	data.local_address = $('#config_local_ip').val();
	data.local_port = parseInt($('#config_local_port').val());
	data.timeout = parseInt($('#config_timeout').val());

	configData[id] = {
		data: data,
		desc: $('#config_desc').val()
	};
	setClientConfig(configData);
	$('#configModal').modal('hide');
}

function removeConfig(id){
	var data = {};
	for(var key in configData){
		if(parseInt(key) < parseInt(id)){
			data[parseInt(key)] = configData[key];
		}else if(parseInt(key) > parseInt(id)){
			data[parseInt(key)-1] = configData[parseInt(key)-1];
		}
	}
	configData = data;
	setClientConfig(configData);
}

function submitPage(){
	var data = {
		client_configs: configData,
		server: getServerData(),
		local: getLocalData(),
		redir: getRedirData()
	};
	var postData = {
		app: 'shadowsocks',
		action: 'set_shadowsocks',
		data: JSON.stringify(data)
		// data:data
	}
	$('input,select,button,textarea').prop('disabled',true);
	$.post('/',postData,function(data){
		Ha.showNotify(data);
		$('input,select,button,textarea').prop('disabled',false);
	},'json');
}

function getServerData(){
	var data = {
		enabled: $('#server_enabled').prop('checked') == true ? 1 : 0,
		data: {
			server: $('#server_bind_ip').val(),
			method: $('#enc_method').val(),
			password: $('#server_password').val(),
			server_port: parseInt($('#server_bind_port').val()),
			timeout: parseInt($('#server_timeout').val())
		}
	};
	return data;
}

function getLocalData(){
	var data = {
		enabled: $('#local_enabled').prop('checked') == true ? 1 : 0,
		client_config: $('#local_config').val()
	};
	return data;
}

function getRedirData(){
	var data = {
		enabled: $('#redir_enabled').prop('checked') == true ? 1 : 0,
		client_config: $('#redir_config').val(),
		external: {
			except_cc: $('#geoip_cc').val().split(','),
			except_ips: getCleanArr($('#hit_ips').val().split('\n'))
		},
		internal: {
			hit_ips: getCleanArr($('#internal_hit_ips').val().split('\n')),
			except_ips: getCleanArr($('#internal_except_ips').val().split('\n'))
		},
		internal_mode: $('#internal_mode').prop('checked') == true ? 'all' : ''
	};
	return data;
}

function getCleanArr(arr){
	for(var i=0; i<arr.length; i++){
		if(arr[i] == ''){
			arr.splice(i,1);
		}
	}
	return arr;
}