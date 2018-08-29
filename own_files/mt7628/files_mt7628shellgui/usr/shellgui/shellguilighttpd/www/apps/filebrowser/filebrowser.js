var cwd = old_path ? old_path : '/';
$('#path-search-input').val(cwd);
getLine(cwd);

function getLine(path){
	$.post('/','app=filebrowser&action=get_line&path=' + path,function(data){
		var dom = $(data);
		// $(dom.find('a').get(0)).html(cwd);
		$('#data-container').empty().append(dom);
		$('#data-container').find('tr:gt(1)').append('<td><button class="btn btn-warning btn-xs" data-toggle="modal" data-target="#authModal">权限</button><button class="btn btn-danger btn-xs" data-toggle="modal" data-target="#confirmModal">删除</button></td>');
		$('#data-container').find('a').each(function(){
			if($(this).hasClass('fb-desc')){
				$(this).parent().next('td').find('.btn-danger').remove();
			}
		});
		Ha.setFooterPosition();
		$('#data-container').find('.btn-danger').click(function(){
			var tr = $(this).parent().parent();
			var target = tr.find('a').attr('data-value');
			var title = '删除确认';
			var text = '确定删除文件 ' + target + '?';
			if(cwd == '/'){
				target = cwd + target;
			}else{
				target = cwd + '/' + target;
			}
			console.log(text);
			Ha.alterModal('confirmModal',title,text,function(){
				$.post('/','app=filebrowser&action=del_file&file=' + target,function(data){
					Ha.showNotify(data);
					if(data.status){

					}else{
						tr.remove();
					}
				},'json');	
			});
		});

		$('#data-container').find('.btn-warning').click(function(){
			var tr = $(this).parent().parent();
			var target = tr.find('a').attr('data-value');
			$('#auth_btn').attr('data-target',target);
			if(cwd == '/'){
				target = cwd + target;
			}else{
				target = cwd + '/' + target;
			}
			$('#authModal').find('.confirm-text').html(target);
			var currentD = tr.find('pre').html().substring(1,10);
			$('#auth-btn-group').find('.btn').each(function(index){
				if(currentD[index] != '-'){
					$(this).addClass('btn-default');
				}else{
					$(this).removeClass('btn-default');
				}
			});
		});
	});	
}

$('#auth-btn-group').find('.btn').click(function(){
	if($(this).hasClass('btn-default')){
		$(this).removeClass('btn-default');
	}else{
		$(this).addClass('btn-default');
	}
});

$('#auth_btn').click(function(){
	var target = $(this).attr('data-target');
	var tr = $('[data-value="' + target + '"]').parent().parent();
	var currentD = tr.find('pre').html().substring(1,10);
	if(cwd == '/'){
		target = cwd + target;
	}else{
		target = cwd + '/' + target;
	}
	var data = '';
	$('#auth-btn-group').find('.btn').each(function(){
		if($(this).hasClass('btn-default')){
			data += $(this).html();
		}else{
			data += '-'
		}
	});
	// var d = tr.find('pre').html().replace(currentD,data);
	// 		tr.find('pre').html(d);
	$.post('/','app=filebrowser&action=post_privilege&file=' + target + '&data=' + data,function(data){
		Ha.showNotify(data);
		if(data.status){

		}else{
			var d = tr.find('pre').html().replace(currentD,data);
			tr.find('pre').html(d);
		}
	});
	$('#authModal').modal('hide');
});

$('#data-container').delegate('.fb-dir','click',function(){
	if($(this).hasClass('glyphicon')){
		$(this).next('a').trigger('click');
		return;
	}
	var path;
	if(cwd != '/'){
		path = cwd + '/' + $(this).attr('data-value');
	}else{
		path = cwd + $(this).attr('data-value');
	}
	if($(this).attr('data-value') == '..'){
		if(cwd == '/'){
			return false;
		}else{
			path = cwd.split('/');
			path.pop();
			path = path.join('/');
			path = '/' + path;
		}
	}else if($(this).attr('data-value') == '.'){
		path = cwd;
	}
	path = path.replace('//','/');
	getLine(path);
	cwd = path;
	$('#path-search-input').val(cwd);
});
$('#data-container').delegate('.fb-file,.fb-exec','click',function(){
	if($(this).hasClass('glyphicon')){
		$(this).next('a').trigger('click');
		return;
	}
	var target = $(this).attr('data-value');
	if(cwd == '/'){
		target = cwd + target;
	}else{
		target = cwd + '/' + target;
	}
	$('#editModal').modal('show');
	$('#editModal').find('.confirm-text').html(target);
	$('#edit_file_btn').attr('data-target',target);
	$.post('/','app=filebrowser&action=get_text_file&file=' + target,function(data){
		if(data.status){
			$('#editModal').modal('hide');
			Ha.showNotify(data);
		}else{
			$('#file-data-container').val(data.data);
			$('#editModal').modal('show');
		}
	},'json');
});

$('#edit_file_btn').click(function(){
	var file_data = $('#file-data-container').val();
	var target = $(this).attr('data-target');
	$.post('/','app=filebrowser&action=post_text_file&file=' + target + '&data=' + file_data,function(data){
		Ha.showNotify(data);
	},'json');
});

$('#path-submit-form').submit(function(){
	var path = $('#path-search-input').val();
	if(va.validatePath(path)){
		$(this).prop('disabled',true);
		$(this).next('.help-block').removeClass('hidden');
		$(this).parent().addClass('has-error');
	}else{
		getLine(path);
		cwd = path;
	}
	return false;
});

$('#path-search-input').bind('blur keyup',function(){
	var path = $(this).val();
	if(va.validatePath(path)){
		$('#path-search-btn').prop('disabled',true);
		$(this).parent().find('.help-block').removeClass('hidden');
		$(this).parent().addClass('has-error');
	}else{
		$('#path-search-btn').prop('disabled',false);
		$(this).parent().find('.help-block').addClass('hidden');
		$(this).parent().removeClass('has-error');
	}
});

$('#upload-btn').click(function(){
	$('#upload_target').val(cwd);
	$('#uploadModal').find('.confirm-text').html('目标路径：' + cwd);
	$('#upload-fw').val('');
	$('#file_name').html('上传文件');
	$('#file_info').addClass('hidden');
});
$('#uplevel-btn').click(function(){
	$('#data-container').find('.fb-dir:eq(3)').trigger('click');
});

$('#upload-fw').change(function(){
	$('[type="submit"]').one('click',function(){
		$('#uploader').submit();
	});
	var file = $(this).val();
	var file_name = file.split('\\').pop();
	$('#file_name').html(file_name);
	var firmware = $(this).get(0).files[0];
	if (firmware) {
		$('#file_info').removeClass('hidden');
		var fileSize = 0;
		if (firmware.size > 1024 * 1024){
			fileSize = (Math.round(firmware.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
		}
		else{
			fileSize = (Math.round(firmware.size * 100 / 1024) / 100).toString() + 'KB';
		}

		// $('#file_name').html(firmware.name || '');
		$('#file_size').html(fileSize || '');
		$('#file_type').html(firmware.type || '');
	}
});

$('#uploader').submit(function(){
	uploadFile('upload-fw','apps/filebrowser/uplod.cgi');
	setProgressLength();
	$('[type="submit"]').click(function(){
		return false;
	});
	//return false;
});