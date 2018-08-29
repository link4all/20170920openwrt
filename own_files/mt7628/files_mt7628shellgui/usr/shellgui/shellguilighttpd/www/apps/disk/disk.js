var disk_data = [];
$.post('/','app=disk&action=show_fstab',initPage,'json');
function initPage(data){
	if(data == null){
		$('thead').addClass('hidden');
		return;
	}
	$('thead').removeClass('hidden');
	$('#disk_container').empty();
	disk_data = [];
	for(var key in data){
		var info = data[key].hwinfo;
		info.uuid = key;
		var dev_type_str = info.dev_type != 'usb' ? '<span class="glyphicon glyphicon-hdd"></span>' : '<span class="glyphicon glyphicon-magnet"></span>';
		var infostr = dev_type_str + ' '  
								+ (info.part_size ? '(' + info.part_size + ')' : '') + ' '
								+　(info.vendor || '')
								+ ':<br><span style="color: #666;"> ' + (info.model || '') 
								+ '</span><span style="color: #666;">' + (info.total_size ? '(' + info.total_size + ')' : '') + '</span>';
		var moreinfo = 'UUID: ' + info.uuid
								 + '&#13;IdVendor: ' + (info.idVendor || '')
								 + '&#13;IdProduct: ' + (info.idProduct || '')
								 + '&#13;Serial: ' + (info.serial || '')
								 + '&#13;bInterfaceNumber: ' + (info.bInterfaceNumber || '')
								 + '&#13;class: ' + (info.class || '')
								 + '&#13;class_prog: ' + (info.class_prog || '')
								 + '&#13;subsystem_vendor: ' + (info.subsystem_vendor || '')
								 + '&#13;subsystem_device: ' + (info.subsystem_device || '')
								 + '&#13;bus_id: ' + (info.bus_id || '');
		console.log(info);
		var disk = {
			uuid: data[key].uuid,
			target: data[key].target,
			enabled: data[key].enabled,
			options: data[key].options,
			device: data[key].device
		};
		disk_data.push(disk);
		var checked = data[key].enabled == 1 ? 'checked' : '';
		var detail = data[key].enabled == 1 ? (UI.Size+':' + data[key].size + '&nbsp;&nbsp;'+UI.Available+':' + data[key].ava + '<br>'+UI.Used+':' + data[key].used + '(' + data[key].used_pct + ')') : '';
		var dom = '<tr class="text-left">'
				+	'<td title="' + moreinfo + '" style="cursor: wait">' 
				+ infostr
				+ '</td>'
				+	'<td>' + data[key].device + '</td>'
				+	'<td>' + data[key].type + '</td>'
				+	'<td><input type="text" class="disk_target" data-id="target_' + key + '" value="' + data[key].target + '"></td>'
				+	'<td>'
				+		'<div class="switch-ctrl switch-sm">'
				+			'<input type="checkbox" id="device_enabled_' + key + '" ' + checked + '>'
				+			'<label for="device_enabled_' + key + '"><span></span></label>'
				+		'</div>'
				+	'</td>'
				+	'<td>' + detail + '</td>'
				+ '</tr>'
		$('#disk_container').append(dom);
		$('.disk_target').blur(function(){
			var id = $(this).attr('data-id').replace('target_','');
			var value = $(this).val();
			for(var i=0; i<disk_data.length; i++){
				if(disk_data[i].uuid == id){
					disk_data[i].target = value;
				}
				break;
			}
		});
		$('.switch-sm').find('input').click(function(){
			var id = $(this).prop('id').replace('device_enabled_','');
			var enabled = $(this).prop('checked') ? 1 : 0;
			for(var i=0; i<disk_data.length; i++){
				if(disk_data[i].uuid == id){
					disk_data[i].enabled = enabled;
				}
				break;
			}
		});
	}
}
$('#save_page_btn').click(function(){
	data = {
		app: 'disk',
		action: 'disk_setting',
		data: disk_data
	}
	$.post('/',data,function(data){
		Ha.showNotify(data);
		setTimeout(resetData,8000);
	},'json');
});
$('#reset_page_btn').click(resetData);
function resetData(){
	$.post('/','app=disk&action=show_fstab',initPage,'json');
}
