(function(){

	var isAnySelected = 0;


	init();
	setSelectAll('select_all_fw','fw_list');
	setSelectAll('select_all_restore','restore_file_list');

	$('#operate_btn').find('button').click(function(){
		isAnySelected = 0;
		$('#ac_container :checkbox').each(function(){
			if($(this).prop('checked')){
				isAnySelected += 1;
			}
		});
		if(!isAnySelected){
			return false;
		}
	});

	$('#upload-fw').change(function(){
		var file = $(this).val();
		var file_name = file.split('\\').pop();
		$('#file_name').html(file_name);
    });


	$('#upload_fw_btn').click(function(){
		$('#uploadFWModal').find('.form-group').removeClass('hidden');
		$('#submit_flash').addClass('hidden');
		$('#submit_upload').removeClass('hidden');
		$('#uploadFWModal').find('.modal-title').html('Upload FW');
		$('#uploadFWModal').find('table').addClass('hidden');
		$('#fw_select').addClass('hidden');
		$('#file_desc').empty();
	});

	function quickSubmit(action){
		$('#' + action + '_btn').click(function(){
			var macs = getCheckedVal('ac_container');
			var data = {};
			data['app'] = 'ac-set';
			data['action'] = action;
			data['ap_list'] = macs;
			$.post('/',data,function(data){
				Ha.showNotify(data);
			},'json');
		});
	}
	quickSubmit('reboot');
	quickSubmit('enable');
	quickSubmit('disable');

	$('#submit_upload').click(function(){
		var ifmname = 'ifm' + Math.random();
		var ifm = $('<iframe width="0" height="0" frameborder="0" name="'+ ifmname +'">');
		ifm.appendTo($('body'));

		$('#uploader').attr('target',ifmname);
		$('#uploader').submit();

		ifm.load(function(){
			var content = $(this.contentDocument).find('pre').html();
			content = JSON.parse(content);
			if(content.md5){
				Ha.showNotify({status: 0,msg:'Upload success.'})
				var dom = '<div>'
						+	'<span>File:&nbsp;&nbsp;' + content.file + '</span><br>'
						+	'<span>MD5:&nbsp;&nbsp;' + content.md5 + '</span><br>'
						+	'<span>Size:&nbsp;&nbsp;' + content.size + '</span>'
						+ '</div>';
				$('#uploadFWModal').find('.form-group').addClass('hidden');
				$('#uploadFWModal').find('.modal-title').html('刷机');
				$('#uploadFWModal').find('table').removeClass('hidden');
				$('#submit_flash').removeClass('hidden');
				$('#fw_select').removeClass('hidden');
				$('#submit_upload').addClass('hidden');
				$('#file_desc').append(dom);
			}else{
				Ha.showNotify(content);
			}
			this.remove();
		});
		return false;
	});

	$('#submit_flash').click(function(){
		var data = {};
		data['bak_file'] = [];
		data['ap_list'] = getCheckedVal('ac_container');
		$('#fw_list :checkbox').each(function(){
			if($(this).prop('checked')){
				data['bak_file'].push($(this).val());
			}
		});
		data['app'] = 'ac-set';
		data['action'] = 'flash_ap';
		$.post('/',data,function(data){
			Ha.showNotify(data);
			if(!data.status){
				$('#uploadFWModal').modal('hide');
			}
		},'json');
		return false;
	});

	$('#submit_restore').click(function(){//TODO可以直接利用上传固件弹窗中的刷机
		var data = {};
		data['bak_file'] = [];
		data['ap_list'] = getCheckedVal('ac_container');
		data['bak_file'] = getCheckedVal('restore_file_list');
		data['app'] = 'ac-set';
		data['action'] = 'restore_ap';
		$.post('/',data,function(data){
			Ha.showNotify(data);
			if(!data.status){
				$('#restoreModal').modal('hide');
			}
		},'json');
		return false;
	});

	$('#submit_ssid').click(function(){
		var data = {};
		data['app'] = 'ac-set';
		data['action'] = 'setssid_ap';
		data['ap_list'] = getCheckedVal('ac_container');
		data['ssid_24g'] = $('#set_ssid_form').find('[name="ssid_24g"]').val();
		data['ssid_58g'] = $('#set_ssid_form').find('[name="ssid_58g"]').val();
		data['enc'] = $('#enc_types').val();
		data['key'] = $('#enc_keys').val();
		Ha.ajax('/','json',data,'post','',function(data){
			Ha.showNotify(data);
			if(!data.status){
				$('#ssidSetModal').modal('hide');
			}
		},1);//TODO what's the fuck!???
		// $.post('/',data,function(data){
		// 	// Ha.showNotify(data);
		// 	if(!data.status){
		// 		$('#ssidSetModal').modal('hide');
		// 	}
		// },'json');
	});

	$('#submit_bw').click(function(){
		var data = {};
		data['app'] = 'ac-set';
		data['action'] = 'bw_set';
		data['ap_list'] = getCheckedVal('ac_container');
		data['total'] = $('#bw_set_form').find('[name="total"]').val();
		$.post('/',data,function(data){
			Ha.showNotify(data);
			if(!data.status){
				$('#bwModal').modal('hide');
			}
		},'json');
	});

	$('[data-target="#ssidSetModal"]').click(function(){
		$('#enc_types').val('none');
		$('#enc_keys').parent().parent().addClass('hidden');
	});



	$('#enc_types').change(function(){
		var type = $(this).val();
		if(type == 'none'){
			$('#enc_keys').parent().parent().addClass('hidden');
			$('#enc_keys').val('');
		}else{
			$('#enc_keys').parent().parent().removeClass('hidden');
			$('#enc_keys').val('');
		}
	});

	$('#kick_out_clients_btn').click(function(){
		var ori_mac = $('[data-target="#clientModal"]').attr('data-mac');
		var mac = [];
		$('#client_table :checkbox').each(function(){
			if($(this).prop('checked')){
				mac.push($(this).attr('data-mac'));
			}
		});
		var data = {
			app: 'ac-set',
			action: 'kick_out_clients',
			mac: mac,
			ap_mac: ori_mac
		};
		if(data.mac.length <= 0){
			Ha.showNotify({status: 1,msg: '没有选择设备。'});
			return;
		}
		// kick out selected clients
		$.post('/',data,function(data){
			Ha.showNotify(data);
			if(!data.status){
				$('#clientModal').modal('hide');
			}
		},'json');
	});

	function init(){

		$.post('/','app=ac-set&action=get_aps_list',function(data){
			$('#ac_container').empty();
			for(var i=0; i<data.length; i++){
				var dom = createTr(data[i]);
				$('#ac_container').append(dom);
			}


			$('[data-target="#editAcModal"]').click(function(){
				$('#editAcModal').find('.modal-body').empty();
				var dataStr = $(this).attr('data-data');
				var data = JSON.parse(dataStr);
				var dom = createEditTr(data);
				$('#editAcModal').find('.modal-body').append(dom);

				$('#enc_type').change(function(){
					var type = $(this).val();
					if(type == 'none'){
						$('#key_container').addClass('hidden');
					}else{
						$('#key_container').removeClass('hidden');
					}
					$('#key_container').find('input').val('');
				});
			});
			$('#submit_edit_ac_btn').click(function(){
				var mac = $('#mac_input').val();
				var ver = $('#ver_input').val();
				var ip = $('#ip_input').val();
				var desc = $('#desc_input').val();
				var ssid = [];
				var enc = $('#enc_type').val();
				var key = $('#enc_key').val();
				$('#ssid_group').find('input').each(function(){
					ssid.push($(this).val());
				})
				var data = {
					app: 'ac-set',
					action: 'edit_ac',
					mac: mac,
					ver: ver,
					ip: ip,
					desc: desc,
					ssid: ssid,
					enc: enc,
					key: key
				};
				//save edit_ac
				Ha.ajax('/','json',data,'post','',function(data){
					Ha.showNotify(data);
					if(!data.status){
						$('#editAcModal').modal('hide');
					}
				},1);
			});


			$('[data-target="#clientModal"]').click(function(){
				//初始化全选框
				$('#select_all_client').prop('checked',false);
				$('#client_container').html('Loading...');
				var ori_mac = $(this).attr('data-mac');
				var data = {
					app: 'ac-set',
					action: 'get_ap_clients',
					mac: ori_mac
				};
				$.post('/',data,function(data){
					$('#client_container').empty();
					if(!data){
						$('#client_container').html('未发现设备。');
						return;
					}
					var table = '<div class="table-responsive">'
							  + 	'<table class="table">'
							  + 		'<thead>'
							  +				'<tr>'
							  +					'<th></th>'
							  +					'<th>Signal</th>'
							  +					'<th>Mac/IP</th>'
							  +					'<th>Rate</th>'
							  +					'<th>operate</th>'
							  +				'</tr>'
							  +			'</thead>'
							  +			'<tbody id="client_table"></tbody>'
							  + 	'</table>'
							  + '</div>';
					$('#client_container').append(table);
					for(var mac in data){
						var ip = data[mac].IP ? data[mac].IP : '设备未设置';
						var mac_id = mac.replace(/:/g,'');
						var dom = '<tr>'
								+ 	'<td><input type="checkbox" data-mac="' + mac + '"></td>'
								+ 	'<td>'
                           		+   '<div class="" id="sta-item-' + mac_id + '">'
								+	   '<div class="rssi-icon">'
		                        +   	   '<span></span><span></span><span></span><span></span>'
		                        +      '</div><br>'
		                        +	   '<span class="rssi-text"></span>'
		                        +	'</div>'
								+	'</td>'
								+ 	'<td><span>Mac:&nbsp;' + mac + '</span><br><span>IP:&nbsp;' + ip + '</span></td>'
								+ 	'<td><span>Rx:&nbsp;' + data[mac].rx_bitrate + '&nbsp;MBit/s</span><br><span>Tx:&nbsp;' + data[mac].tx_bitrate + '&nbsp;MBit/s</span></td>'
								+ 	'<td><button data-mac="' + mac + '" class="btn btn-danger btn-xs">Kick out</button></td>'
								+ '</tr>';
						$('#client_table').append(dom);
						Ha.setRssiIcon(mac_id,data[mac].signal_pct);
					}
					setSelectAll('select_all_client','client_container');
					$('#client_table').find('button').click(function(){
						var mac = $(this).attr('data-mac');
						//kick out single mac client
						var data = {
							app: 'ac-set',
							action: 'kick_out_client',
							mac: mac,
							ap_mac: ori_mac
						};
						$.post('/',data,function(data){
							Ha.showNotify(data);
							if(!data.status){
								$('#clientModal').modal('hide');
							}
						},'json');
					});

				},'json');

			});
			setSelectAll('selectAll','ac_container');

		  	Ha.setFooterPosition()

	  		$('#ac_container :checkbox,#selectAll').click(function(){
				isAnySelected = 0;
				$('#ac_container :checkbox').each(function(){
					if($(this).prop('checked')){
						isAnySelected += 1;
					}
				});
				if(isAnySelected){
					$('#operate_btn').find('button').prop('disabled',false);
				}else{
					$('#operate_btn').find('button').prop('disabled',true);
				}
			});

		},'json');

	}

	function createTr(data){
		var dataStr = JSON.stringify(data);
		var ssid = data.SSID ? data.SSID.replace(/,/g,'<br>') : '';
		var desc = data.Desc ? data.Desc : '未设置';
		var bw = data.BW_up && data.BW_down ? '<span class="glyphicon glyphicon-arrow-up"></span>' + data.BW_up + '<br><span class="glyphicon glyphicon-arrow-down"></span>' + data.BW_down : '未连接';
		var quota = data.Quota_used && data.Quota_total && typeof(data.Quota_pused) != 'undefined' ? '' + data.Quota_used + '/' + data.Quota_total + '<br>' + data.Quota_pused + '%' : '未连接';
		var runtime = strSeconds(data.Uptimes);
		var status_class;
		var timestamp=new Date().getTime();
		if(typeof(data.Id) == 'undefined'){
			status_class = 'glyphicon glyphicon-asterisk alert-warning';
		}else if(data.Enabled == 0){
			status_class = 'glyphicon glyphicon-asterisk alert-danger';
		}else if(data.Time + 300 < Math.floor(timestamp/1000)){
			status_class = 'glyphicon glyphicon-asterisk alert-default';
		}else{
			status_class = 'glyphicon glyphicon-asterisk alert-success';
		}
		var dom = '<tr data-mac="' + data.Mac + '">'
				+		'<td><input type="checkbox" name="" value="' + data.Mac + '" data-id=""></td>'
				+		'<td class="like-a-link" data-mac="' + data.Mac + '" data-toggle="modal" data-target="#clientModal"><span class="' + status_class + '">' + data.Clients + '</span><br>v'+ data.Version +'</td>'
				+		'<td>' + runtime + '<br>M:' + data.Loads_pmem + '%&nbsp;C:' + data.Loads_pcpu + '%</td>'
				+		'<td class="like-a-link" data-data=\'' + dataStr + '\' data-toggle="modal" data-target="#editAcModal">' + desc + '</td>'
				+		'<td>' + data.Mac + '<br>' + data.IP + '</td>'
				+		'<td>' + ssid + '</td>'
				+		'<td>' + data.Enc + ':<br>' + data.Key + '</td>'
				+		'<td>' + bw + '</td>'
				+		'<td>' + quota + '</td>'
				+ '</tr>';
		return dom;

	}

	function createEditTr(data){
		var desc = data.Desc ? data.Desc : '';
		var ssid = data.SSID.split(',');
		var ssid_dom = '';
		var none_selected = '',psk2_selected = '',mixed_selected = '';
		var hidden_key = '';
		var key = '';
		if(data.Enc == 'none'){
			none_selected = 'selected';
			hidden_key = 'hidden';
			key = '';
		}else if(data.Enc == 'psk2'){
			psk2_selected = 'selected';
			key = data.Key;
		}else{
			mixed_selected = 'selected';
			key = data.Key;
		}
		for(var i=0; i<ssid.length; i++){
			ssid_dom += '<input type="text" class="form-control" id="" name="" value="' + ssid[i] + '">';
		}
		var dom = '<form name="eidt_client_form" class="form-horizontal">'
				+	'<input type="hidden" id="mac_input" value="' + data.Mac + '">'
				+	'<input type="hidden" id="ver_input" value="' + data.Version + '">'
				+ 	'<div class="form-group">'
				+ 		'<label for="" class="control-label col-sm-2">Desc</label>'
				+ 		'<div class="col-sm-10">'
				+ 			'<input type="text" class="form-control" id="desc_input" name="" value="' + desc + '">'
				+ 		'</div>'
				+	'</div>'
				+ 	'<div class="form-group" id="ssid_group">'
				+ 		'<label for="" class="control-label col-sm-2">SSID</label>'
				+ 		'<div class="col-sm-10">'
				+ 			ssid_dom
				+ 		'</div>'
				+	'</div>'
				+ 	'<div class="form-group">'
				+ 		'<label for="" class="control-label col-sm-2">IP</label>'
				+ 		'<div class="col-sm-10">'
				+ 			'<input type="text" class="form-control" id="ip_input" name="" value="' + data.IP + '">'
				+ 		'</div>'
				+	'</div>'
				+ 	'<div class="form-group">'
				+ 		'<label for="" class="control-label col-sm-2">Enc</label>'
				+ 		'<div class="col-sm-10">'
				+ 			'<select id="enc_type" name="" value="wpa2" class="form-control">'//TODO 这里的加密方式有没有确定下来？？？
				+				'<option value="none" ' + none_selected + '>None</option>'
				+				'<option value="psk2" ' + psk2_selected + '>PSK2</option>'
				+				'<option value="mixed-psk" ' + mixed_selected + '>Mixed</option>'
				+			'</select>'
				+ 		'</div>'
				+	'</div>'
				+ 	'<div class="form-group ' + hidden_key + '" id="key_container">'
				+ 		'<label for="" class="control-label col-sm-2">Key</label>'
				+ 		'<div class="col-sm-10">'
				+ 			'<input id="enc_key" name="" value="' + key + '" class="form-control">'
				+ 		'</div>'
				+	'</div>'
				+ '</form>';
		return dom;

	}

	function strSeconds(sec){
		if(sec<=0){
			return '';
		}
		var str = '';
		if(sec < 60){
			str = str + sec + '秒';
		}else if(sec < 3600){
			str = str + Math.floor(sec/60) + '分' + sec%60 + '秒';
		}else if(sec < 86400){
			str = str + Math.floor(sec/3600) + '小时' + Math.floor((sec%3600)/60) + '分' + sec%60 + '秒';
		}else{
			str = str + Math.floor(sec/86400) + '天' + Math.floor((sec%86400)/3600) + '小时' + Math.floor(((sec%86400)%3600)/60) + '分' + sec%60 + '秒';
		}

		return str;
	}

	function setSelectAll(ctr_id,sub_id){//TODO 添加到common函数库
		$('#' + ctr_id).click(function(){
			$('#' + sub_id + ' :checkbox').prop('checked',$('#' + ctr_id).prop('checked'));
		});
	}

	function getCheckedVal(containerId){
		var data = [];
		$('#' + containerId + ' :checkbox').each(function(){
			if($(this).prop('checked')){
				data.push($(this).val());
			}
		});

		return data;
	}

})();
