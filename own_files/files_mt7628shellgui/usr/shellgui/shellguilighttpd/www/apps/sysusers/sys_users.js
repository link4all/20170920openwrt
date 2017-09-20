(function(){
	$('#add_user_btn').click(function(){
		$('#editUserModal').find('#editUserModalLabel').html(UI.Add_user);
		$('#editUserModal').find('form').attr('data-name','add_user_form');
		$('#upwd').removeClass('hidden').prop('disabled',false);
		$('#deletePassword').addClass('hidden');
		$('#resetPassword').addClass('hidden');
		$('#edit_upwd').addClass('hidden').find('input').prop('disabled',true);
		initForm('user_form');
	});

	$('.edit_user_btn').each(function(){
		$(this).click(function(){
			var data;//获取当前行数据
			$('#editUserModal').find('#editUserModalLabel').html(UI.Edit_user);
			$('#editUserModal').find('form').attr('data-name','edit_user_form');
			$('#upwd').addClass('hidden').prop('disabled',true);
			$('#deletePassword').removeClass('hidden');
			$('#resetPassword').removeClass('hidden');
			$('#edit_upwd').addClass('hidden').find('input').prop('disabled',false);
			var user = $(this).attr('data-user');
			//当前行数据映射到表单
			$.post('/','app=sysusers&action=get_user_detail&user=' + user,function(data){
			 	if(data.status == 0){

			 		$('#editUserModal').find('[name="username"]').val(data.user_detail.usrname);
			 		$('#editUserModal').find('[name="username"]').prop('readonly',true);
			 		$('#editUserModal').find('[name="uid"]').val(data.user_detail.uid);
			 		$('#editUserModal').find('[name="gecos"]').val(data.user_detail.gecos);
			 		$('#editUserModal').find('[name="home_dir"]').val(data.user_detail.home_dir);
			 		$('#editUserModal').find('[name="shell"]').val(data.user_detail.shell);
			 		
			 		$('#editUserModal').find('[name="group"]').find('option').each(function(){
			 			$(this).prop('selected',false);
			 			if($(this).val() == data.user_detail.group){
			 				$(this).prop('selected',true);
			 			}
			 		});
			 	}
			},'json');

		});
	});

	$('#resetPassword').click(function(){
		$('#edit_upwd').removeClass('hidden');
		$(this).addClass('hidden');
		$('#deletePassword').addClass('hidden');
		return false;
	});

	$('#cancle-resetpwd').click(function(){
		$('#deletePassword,#resetPassword').removeClass('hidden');
		$('#edit_upwd').addClass('hidden');
	});

	$('#deletePassword').click(function(){
		var confirms = confirm(UI.Are_you_sure_to +' '+UI.DELETE_PASSWORD+'?');
		if(confirms){
			var user = $('#editUserModal').find('[name="username"]').val();
			$.post('/','app=sysusers&action=do_deluserpass&username=' + user, function(data){
				Ha.showNotify(data);
				if(!data.status){
					$('#' + user).find('.user_pwd').html('');
				}
			},'json');

		}

		return false;
	});

	$('#submit_user_btn').click(function(){
		if($('#editUserModal').find('form').attr('data-name') == 'add_user_form'){
			addUser();
		}else{
			editUser();
		}
	});

	$('#add_group_btn').click(function(){
		initForm('group_form');
		$('#editGroupModal').find('#editGroupModalLabel').html(UI.Add_new_group);
		$('#editGroupModal').find('form').attr('data-name','add_group_form');
	});

	$('.edit_group_btn').each(function(){
		$(this).click(function(){
			var group = $(this).attr('data-group');
			var gid = $(this).attr('data-gid');
			$('#editGroupModal').find('#editGroupModalLabel').html(UI.Edit_group);
			$('#editGroupModal').find('form').attr('data-name','edit_group_form');
			//当前行数据映射到表单
			$('#editGroupModal').find('[name="group"]').val(group).prop('readonly',true);
			$('#editGroupModal').find('[name="gid"]').val(gid);
		});
	});	

	$('#submit_group_btn').click(function(){
		if($('#editGroupModal').find('form').attr('data-name') == 'add_group_form'){
			addGroup();
		}else{
			editGroup();
		}
	});

	$('.del_user_btn').click(function(){
		var user = $(this).parent().find('.edit_user_btn').attr('data-user');
		$('#delete_user_btn').attr('data-user',user);
	});

	$('#delete_user_btn').click(function(){
		var user = $(this).attr('data-user');
		deleteUser(user);
	});

	$('.del_group_btn').click(function(){
		var group = $(this).parent().find('.edit_group_btn').attr('data-group');
		$('#delete_group_btn').attr('data-group',group);
	});

	$('#delete_group_btn').click(function(){
		var group = $(this).attr('data-group');
		deleteGroup(group);
	});

	function addUser(){
		var data = $('#user_form').serialize();
		data = 'app=sysusers&action=do_adduser&' + data;
		$.post('/',data,Ha.showNotify,'json');
	};

	function editUser(){
		var data = $('#user_form').serialize();
		data = 'app=sysusers&action=do_useredit&' + data;
		$.post('/',data,Ha.showNotify,'json');
	};

	function addGroup(){
		var data = $('#group_form').serialize();
		data = 'app=sysusers&action=do_addgroup&' + data;
		$.post('/',data,Ha.showNotify,'json');
	}

	function editGroup(){
		var data = $('#group_form').serialize();
		data = 'app=sysusers&action=do_editgroup&' + data;
		$.post('/',data,Ha.showNotify,'json');
	}

	function deleteUser(id){
		$.post('/','app=sysusers&action=do_deluser&username=' + id,Ha.showNotify,'json');
		$('#' + id).empty();
	}

	function deleteGroup(id){
		$.post('/','app=sysusers&action=do_delgroup&group=' + id,Ha.showNotify,'json');
		$('#' + id).empty();
	}

	function initForm(id){
		$('#' + id).find('input').val('').prop('readonly',false);
		$('#' + id).find('option').prop('selected',false);
	}
})()	