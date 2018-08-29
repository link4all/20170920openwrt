var uci = uciOriginal.clone();
var pkg = 'openvpn_uci';

setTableFromUci(uciOriginal);


$('#set_openvpn_server').submit(function(e){
	e.preventDefault();
	var data = "app=openvpn&action=set_openvpn_server&"+$(this).serialize();
	Ha.disableForm('set_openvpn_server');
	Ha.ajax('/','json',data,'post','set_openvpn_server',Ha.showNotify,1);
});

$('#set_openvpn_client').submit(function(e){
	e.preventDefault();
	var data = "app=openvpn&action=set_openvpn_client&"+$(this).serialize();
	Ha.disableForm('set_openvpn_client');
	Ha.ajax('/','json',data,'post','set_openvpn_client',Ha.showNotify,1);
});

function createClientTable(data){
	var trs = '';
	for(var i=0; i<data.length; i++){
		var subnet_str = ''
		if(data[i].subnet_ip && data[i].subnet_mask){
			subnet_str = '<br>' + data[i].subnet_ip + '/' + data[i].subnet_mask;
		}
		var url = '/?app=openvpn&action=download_client_key&id=' + data[i].id;
		var tr = '<tr id="' + data[i].id + '">'
			   + 	'<td>' + data[i].name + '</td>'
			   +	'<td>' + data[i].ip + subnet_str + '</td>'
			   +	'<td><input type="checkbox" class="enabled_btn" ' + (data[i].enabled ? 'checked' : '') + ' data-id="' + data[i].id + '"></td>'
			   +	'<td><a href="' + url + '"><button class="btn btn-default btn-sm download_cer_btn">'+UI.Download+'</button></a></td>'
			   +	'<td><button data-toggle="modal" data-target="#formModal" data-id="' + data[i].id + '" class="btn btn-primary btn-sm edit_client_btn">'+UI.Edit+'</button></td>'
			   +	'<td><button data-id="' + data[i].id + '" class="btn btn-danger btn-sm del_client_btn">'+UI.Remove+'</button></td>'
			   + '</tr>';
		trs += tr;
	}
	$('#client_container').empty().append(trs);
	$('.edit_client_btn').click(function(){
		var id = $(this).attr('data-id');
		alterFormModal(id);
	});
    $('.del_client_btn').click(function(){
    	var id =$(this).attr('data-id');
    	removeClient(id);
    });

    $('.enabled_btn').click(function(){
    	var id = $(this).attr('data-id');
    	var enabled = $(this).prop('checked');
    	enabledClient(id,enabled);
    });

	return trs;
}

$('#cipher').change(alterSubnet);
$('#add_new_client_btn').click(function(){
	alterFormModal();
});
$('#submit_client_btn').click(function(){
	var id = $(this).attr('data-id');
	var type = $(this).attr('data-type');
	if(type == 'edit'){
		editClient(id);
	}else{
		addNewClient();
	}
});

function alterFormModal(id){
	if(id != null){
    	$('#formModalLabel').html('编辑啥子的自己填');
    	$('#submit_client_btn').html('Save').attr('data-type','edit').attr('data-id',id);
    	setFormData(id);
	}else{
    	$('#formModalLabel').html(UI.Configure_A_New_Client_Set_of_Credentials);
    	$('#submit_client_btn').html('Add').attr('data-type','add').attr('data-id','');
    	setFormData();
	}
}

function alterSubnet(){
	var type = $('#cipher').val();
	if(type == 'false'){
		$('#subnet_container').addClass('hidden');
	}else{
		$('#subnet_container').removeClass('hidden');
	}
}

function setTableFromUci(uci){
	var clientIdArray = uci.getAllSectionsOfType(pkg, "allowed_client");
	clientIdArray.sort();
	var clientData = [];
	for(var i=0; i<clientIdArray.length; i++){
		var client = {};
		client.id = uci.get(pkg, clientIdArray[i], 'id');
		client.name = uci.get(pkg, clientIdArray[i], 'name');
		client.ip = uci.get(pkg, clientIdArray[i], 'ip');
		client.remote = uci.get(pkg, clientIdArray[i], 'remote');
		client.enabled = uci.get(pkg, clientIdArray[i], 'enabled');
		client.subnet_ip = uci.get(pkg, clientIdArray[i], 'subnet_ip');
		client.subnet_mask = uci.get(pkg, clientIdArray[i], 'subnet_mask');
		clientData.push(client);
	}
	createClientTable(clientData);
}

function setFormData(id){
	var data;
	if(id != null){
		data = getDataFromUci(id);
	}else{
		data = {};
		data.id = '';
		data.name = '';
		data.ip = '';
		data.remote = '';
		data.enabled = '';
		data.subnet_ip = '';
		data.subnet_mask = '';
	}
	var cipher_val;
	if(data.subnet_ip && data.subnet_mask){
		cipher_val = 'true';
	}else{
		cipher_val = 'false';
	}
	$('#client_name').val(data.name);
	$('#client_ip').val(data.ip);
	$('#proto').val(data.remote);
	$('#cipher').val(cipher_val);
	alterSubnet();
	if(cipher_val == 'true'){
		$('#subnet_ip').val(data.subnet_ip);
		$('#subnet_mask').val(data.subnet_mask);
	}else{
		$('#subnet_ip').val('');
		$('#subnet_mask').val('');
	}
}
function getDataFromUci(id){
	var clientIdArray = uci.getAllSectionsOfType(pkg, "allowed_client");
	var client = {};
	for(var i=0; i<clientIdArray.length; i++){
		if(uci.get(pkg, clientIdArray[i], 'id') == id){
			client.id = uci.get(pkg, clientIdArray[i], 'id');
			client.name = uci.get(pkg, clientIdArray[i], 'name');
			client.ip = uci.get(pkg, clientIdArray[i], 'ip');
			client.remote = uci.get(pkg, clientIdArray[i], 'remote');
			client.enabled = uci.get(pkg, clientIdArray[i], 'enabled');
			client.subnet_ip = uci.get(pkg, clientIdArray[i], 'subnet_ip');
			client.subnet_mask = uci.get(pkg, clientIdArray[i], 'subnet_mask');
		}
	}
	return client;
}

function setUciFromData(data){
	uci.set(pkg, data.id, "", "allowed_client");
	uci.set(pkg, data.id, "id",  data.id);
	uci.set(pkg, data.id, "name",  data.name);
	uci.set(pkg, data.id, "ip",  data.ip);
	uci.set(pkg, data.id, "remote",  data.remote);
	uci.set(pkg, data.id, "subnet_mask",  data.subnet_mask);
	uci.set(pkg, data.id, "subnet_ip",  data.subnet_ip);
	uci.set(pkg, data.id, "enabled",  data.enabled);
}

function addNewClient(){
	var newId = 'client' + (parseInt($('#client_container>tr:last').prop('id').replace('client','')) + 1);
	var data = {};
	data.id = newId;
	data.name = $('#client_name').val();
	data.ip = $('#client_ip').val();
	data.remote = $('#proto').val();
	data.subnet_ip = $('#subnet_ip').val();
	data.subnet_mask = $('#subnet_mask').val();
	var cipher_type = $('#cipher').val();
	data.enabled = true;
	if(cipher_type == 'false'){
		data.subnet_ip = '';
		data.subnet_mask = '';
	}
	var valid = validateClient(data);
	if(valid.length == 0){
		$('#formModal').modal('hide');

		var post_data = {
			app: 'openvpn',
			action: 'add_client',
			data: data
		};
		$.post('/',post_data,function(res){
			Ha.showNotify(res);
			if(!res.status){
				setUciFromData(data);
				setTableFromUci(uci);
			}
		},'json');	
	}else{
		Ha.showNotify({status: 1,msg: valid[0] + '<br>'+UI.Add_new_client_fail+'.'});
	}
}

function editClient(id){
	var data = {};
	data.id = id;
	data.name = $('#client_name').val();
	data.ip = $('#client_ip').val();
	data.remote = $('#proto').val();
	data.subnet_ip = $('#subnet_ip').val();
	data.subnet_mask = $('#subnet_mask').val();
	var cipher_type = $('#cipher').val();
	data.enabled = $('#' + id).find('[type="checkbox"]').prop('checked');
	if(cipher_type == 'false'){
		data.subnet_ip = '';
		data.subnet_mask = '';
	}
	var valid = validateClient(data);
	if(valid.length == 0){
		$('#formModal').modal('hide');
		
		var post_data = {
			app: 'openvpn',
			action: 'edit_client',
			data: data
		};
		$.post('/',post_data,function(res){
			Ha.showNotify(res);
			if(!res.status){
				var sections = uci.getAllSectionsOfType(pkg, "allowed_client");//全部的sections
				for(sectionIndex=0; sectionIndex < sections.length; sectionIndex++){
					if(uci.get(pkg, sections[sectionIndex], "id") == id){
						uci.removeSection(pkg, sections[sectionIndex]);
					}
				}
				setUciFromData(data);
				setTableFromUci(uci);
			}
		},'json');
	}else{
		Ha.showNotify({status: 1,msg: valid[0] + '<br>'+UI.Add_new_client_fail+'.'});
	}
}

function removeClient(id){
	var post_data = {
		app: 'openvpn',
		action: 'remove_client',
		id: id
	};
	$.post('/',post_data,function(res){
		Ha.showNotify(res);
		if(!res.status){
			var sections = uci.getAllSectionsOfType(pkg, "allowed_client");//全部的sections
			for(sectionIndex=0; sectionIndex < sections.length; sectionIndex++){
				if(uci.get(pkg, sections[sectionIndex], "id") == id){
					uci.removeSection(pkg, sections[sectionIndex]);
				}
			}
			setTableFromUci(uci);
		}
	},'json');
}

function enabledClient(id,enabled){
	var post_data = {
		app: 'openvpn',
		action: 'enabled_client',
		id: id,
		enabled: enabled
	};
	$.post('/',post_data,function(res){
		Ha.showNotify(res);
		if(!res.status){
			uci.set(pkg, id, "enabled",  '' + enabled);
			setTableFromUci(uci);
		}else{
			$('#' + id).find('[type="checkbox"]').prop('checked',!enabled);
		}
	},'json');

	
}

function validateClient(data){
	var errors = [];
	if(data.name == ''){
		errors.push(UI.Client_Name_filed_Empty+'.');
		return errors;
	}else if(validateIP(data.ip)){
		errors.push(UI.IPaddr_is_invalid+'.')
		return errors;
	}
	else if(data.subnet_ip != '' && data.subnet_mask != ''){
		if(validateIP(data.subnet_ip)){
			errors.push(UI.Subnet_IP_is_invalid+'.');
			return errors;
		}else if(validateIP(data.subnet_mask)){
			errors.push(UI.Subnet_mask_is_invalid+'.');
			return errors;
		}
	}
	return errors;
}

function validateIP(address){//验证ip是否有效
	var errorCode = 0;
	if(address == "0.0.0.0")
	{
		errorCode = 1;
	}
	else if(address == "255.255.255.255")
	{
		errorCode = 2;
	}
	else
	{
		var ipFields = address.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
		if(ipFields == null)
		{
			errorCode = 5;
		}
		else
		{
			for(field=1; field <= 4; field++)
			{
				if(ipFields[field] > 255)
				{
					errorCode = 4;
				}
				if(ipFields[field] == 255 && field==4)
				{
					errorCode = 3;
				}
			}
		}
	}
	return errorCode;
}