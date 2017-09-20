#!/usr/bin/haserl
<%
shellgui '{"action":"check_session","session_type":"http-session","session":"'"$COOKIE_session"'"}' &>/dev/null
[ $? -ne 0 ] && printf "Location: /?app=login\r\n\r\n" && exit 1
eval $(/usr/shellgui/progs/main.sbin l_p '_LANG_App_|_LANG_Form_' ${FORM_app} $COOKIE_lang)
userlist() {
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'","url":"/?app=sysusers"},"3":{"title":"'"${_LANG_Form_Managing_user}"'"}}'
%>
<div class="table-responsive">
	<table class="table">
		<thead>
			<tr>
				<th>uid</th>
				<th><%= ${_LANG_Form_Username} %></th>
				<th><%= ${_LANG_Form_Password} %></th>
				<th><%= ${_LANG_Form_Group} %></th>
				<th><%= ${_LANG_Form_Desc} %></th>
				<th><%= ${_LANG_Form_Home_dir} %></th>
				<th>shell</th>
				<th><%= ${_LANG_Form_Option} %></th>
			</tr>
		</thead>
		<tbody>
<%
table_str=$(awk 'NR==FNR{a[FNR]=$0;next}{print a[FNR] ":" $0}' /etc/passwd /etc/shadow | awk -F ":" '{if ($1 == "root") print "<tr id=\""$1"\"><td>"$3"</td><td>"$1"</td><td class=\"user_pwd\" style=\"width: 20%\">"$9"</td><td>:"$4":</td><td>"$5"</td><td>"$6"</td><td>"$7"</td><td><button data-user=\""$1"\" data-toggle=\"modal\" data-target=\"#editUserModal\" class=\"btn btn-default btn-xs edit_user_btn\">'"${_LANG_Form_Edit}"'</button></td></tr>";else print "<tr id=\""$1"\"><td>"$3"</td><td>"$1"</td><td class=\"user_pwd\" style=\"width: 20%\">"$9"</td><td>:"$4":</td><td>"$5"</td><td>"$6"</td><td>"$7"</td><td><button data-toggle=\"modal\" data-user=\""$1"\" data-target=\"#editUserModal\" class=\"btn btn-default btn-xs edit_user_btn\">'"${_LANG_Form_Edit}"'</button><button class=\"btn btn-danger btn-xs del_user_btn\" data-toggle=\"modal\" data-target=\"#confirmModal\">'"${_LANG_Form_Del}"'</button></td></tr>"}')
group_str=$(cat /etc/group)
for i in $(echo "$group_str" | awk -F ":" {'print $3'}); do
group=$(echo "$group_str" | grep ":${i}:" | awk -F ":" {'print $1'})
table_str=$(echo "$table_str" | sed "s/:${i}:/$group/g")
done
echo "$table_str"
%>
		</tbody>
	</table>
</div>
<!-- 编辑弹窗 -->
<button type="button" class="btn btn-success" id="add_user_btn" data-toggle="modal" data-target="#editUserModal"><%= ${_LANG_Form_Add_new_user} %></button>
<div class="modal fade" id="editUserModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
	<form class="form-horizontal" id="user_form">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="editUserModalLabel"><%= ${_LANG_Form_Edit_user} %></h4>
      </div>
      <div class="modal-body">
			<div class="form-group">
				<label for="" class="control-label col-sm-4">uid</label>
				<div class="col-sm-8">
					<input type="text" class="form-control" name="uid">
					<span class="help-block"><%= ${_LANG_Form_System_will_automatically_assign_uid_when_it_empty} %></span>
				</div>
			</div>
			<div class="form-group">
				<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Username} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" name="username">
					<span class="help-block"><%= ${_LANG_Form_Can_not_be_empty} %></span>
				</div>
			</div>
			<!-- <div class="form-group">
				<div class="col-sm-offset-4 col-sm-8">
					<button class="btn btn-danger btn-sm"><%= ${_LANG_Form_DELETE_PASSWORD} %></button>
				</div>
			</div> -->
			<div class="form-group">
				<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Password} %></label>
				<div class="col-sm-8">
					<button class="btn btn-danger btn-sm col-xs-6" id="deletePassword"><%= ${_LANG_Form_DELETE_PASSWORD} %></button>
					<button class="btn btn-info btn-sm col-xs-6" id="resetPassword"><%= ${_LANG_Form_RESET_PASSWORD} %></button>
					<input type="password" class="form-control" value="" name="password" id="upwd" disabled>
					<div class="input-group" id="edit_upwd">
						<input type="password" class="form-control" name="password" disabled>
						<span class="input-group-addon cancle-addon" id="cancle-resetpwd"><%= ${_LANG_Form_Cancel} %></span>
					</div>
					<span class="help-block"><%= ${_LANG_Form_When_you_use_a_empty_password_and_it_can_not_log_in} %></span>
				</div>
			</div>
			<div class="form-group">
				<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Group} %></label>
				<div class="col-sm-8">
					<select name="group" class="form-control">
						<%
						cat /etc/group | cut -d ':' -f1 | while read group; do
						%>
						<option value="<%= ${group} %>"><%= ${group} %></option>
						<%
						done
						%>
					</select>
					<span class="help-block"><%= ${_LANG_Form_Choose_group_which_the_user_will_belong_to} %></span>
				</div>
			</div>
			<div class="form-group">
				<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Desc} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" name="gecos">
					<span class="help-block"><%= ${_LANG_Form_Will_not_use_GECOS_when_empty} %></span>
				</div>
			</div>
			<div class="form-group">
				<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Home_dir} %></label>
				<div class="col-sm-8">
					<input type="text" class="form-control" name="home_dir">
					<span class="help-block"><%= ${_LANG_Form_Will_not_use_home_dictionary_when_empty} %></span>
				</div>
			</div>
			<div class="form-group">
				<label for="" class="control-label col-sm-4">shell</label>
				<div class="col-sm-8">
					<input class="form-control" list="shell_adduser" name="shell" value="/bin/nologin" />
					<datalist id="shell_adduser">
					<%
					for shell in sh ash clish bash dash klish mksh tcsh slsh; do
					path_output=""
					path_output=`which ${shell}`
					[ -n "$path_output" ]&& echo "<option value=\"$path_output\">$path_output</option>"
					done %>
					<option value="/bin/nologin">/bin/nologin</option>
					</datalist>
					<span class="help-block"><%= ${_LANG_Form_Will_use_bin_nologin_when_empty} %></span>
				</div>
			</div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-default" id="submit_user_btn" data-dismiss="modal"><%= ${_LANG_Form_Save} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
	</form>
    </div>
  </div>
</div>
<!-- 确认弹窗 -->
<div class="modal fade" id="confirmModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="confirmModalLabel"><%= ${_LANG_Form_Confirm_modal} %></h4>
      </div>
      <div class="modal-body">
		<p><%= ${_LANG_Form_Are_you_sure_to_DELETE_this_User} %>?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-danger" id="delete_user_btn" data-dismiss="modal"><%= ${_LANG_Form_Del} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
    </div>
  </div>
</div>
<%
}
grouplist() {
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'","url":"/?app=sysusers"},"3":{"title":"'"${_LANG_Form_Managing_user_groups}"'"}}' %>
<div class="table-responsive">
	<table class="table">
		<thead>
			<tr>
				<th><%= ${_LANG_Form_Edit_group} %></th>
				<th>gid</th>
				<th><%= ${_LANG_Form_Users_in_the_group} %></th>
				<th><%= ${_LANG_Form_Option} %></th>
			</tr>
		</thead>
		<tbody>
			
<%
passwd_str=$(cat /etc/passwd)
group_pre=$(cat /etc/group)
group_pre_supplemental="$group_pre"
group_pre_main=""
for groupid_used in $(echo "$passwd_str" | awk -F ":" {'print $4'} | sort -n | uniq); do
group_pre_supplemental=$(echo "$group_pre_supplemental" | sed "/\:${groupid_used}\:/d")
group_pre_main=$(printf "$group_pre_main\n"$(echo "$group_pre" | grep ":${groupid_used}:"))
done
group_pre_main=$(echo "$group_pre_main" | sed '/^$/d')
group_pre_main=$(echo "$group_pre_main" | sed -e 's/$/:/g' -e '/-e/d')
IFS_bak=$IFS
IFS='
'
for line in $passwd_str; do
user_group_str=""
gid=$(echo ${line} | awk -F ":" {'print $4'})
user_name=$(echo ${line} | awk -F ":" {'print $1'})
user_group_str=$(echo "$group_pre_main" | grep "^.*:.:${gid}:")
[ -n "$user_group_str" ] && echo "$group_main" | grep -q "^.*:.:$gid:"
if [ $? -ne 0 ]; then
group_main=$(printf "$group_main\n""${user_group_str}$user_name,")
fi
done
IFS=$IFS_bak
group_main=`echo "$group_main" | sed -e '/^$/d' -e '/-e/d' -e 's/,$//'`
echo "$group_main" | awk -F ":" {'print "<tr id=\""$1"\"><td>"$1"</td><td>"$3"</td><td>"$5"</td><td><button class=\"btn btn-default btn-xs edit_group_btn\" data-group=\""$1"\" data-gid=\""$3"\" data-toggle=\"modal\" data-target=\"#editGroupModal\">'"${_LANG_Form_Edit}"'</button></td></tr>"'}
echo "$group_pre_supplemental" | awk -F ":" {'print "<tr id=\""$1"\"><td>"$1"</td><td>"$3"</td><td></td><td><button class=\"btn btn-default btn-xs edit_group_btn\" data-group=\""$1"\" data-gid=\""$3"\" data-toggle=\"modal\" data-target=\"#editGroupModal\">'"${_LANG_Form_Edit}"'</button><button class=\"btn btn-danger btn-xs del_group_btn\" data-toggle=\"modal\" data-target=\"#confirmModal\">'"${_LANG_Form_Del}"'</button></td></tr>"'}
%>
		</tbody>
	</table>
</div>
<!-- 编辑弹窗 -->
<button type="button" class="btn btn-success" id="add_group_btn" data-toggle="modal" data-target="#editGroupModal"><%= ${_LANG_Form_Add_new_group} %></button>
<div class="modal fade" id="editGroupModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
	<form class="form-horizontal" id="group_form">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="editGroupModalLabel"><%= ${_LANG_Form_Edit_group} %></h4>
      </div>
      <div class="modal-body">
		<div class="form-group">
			<label for="" class="control-label col-sm-4"><%= ${_LANG_Form_Group} %></label>
			<div class="col-sm-8">
				<input type="text" class="form-control" name="group">
				<span class="help-block"><%= ${_LANG_Form_Can_not_be_empty} %></span>
			</div>
		</div>
		<div class="form-group">
			<label for="" class="control-label col-sm-4">gid</label>
			<div class="col-sm-8">
				<input type="text" class="form-control" name="gid">
				<span class="help-block"><%= ${_LANG_Form_System_will_automatically_assign_gid_when_it_empty} %></span>
			</div>
		</div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-default" id="submit_group_btn" data-dismiss="modal"><%= ${_LANG_Form_Save} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
	</form>
    </div>
  </div>
</div>
<!-- 确认弹窗 -->
<div class="modal fade" id="confirmModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        <h4 class="modal-title" id="confirmModalLabel"><%= ${_LANG_Form_Confirm_modal} %></h4>
      </div>
      <div class="modal-body">
		<p><%= ${_LANG_Form_Are_you_sure_to_DELETE_this_Group} %>?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-danger" id="delete_group_btn" data-dismiss="modal"><%= ${_LANG_Form_Del} %></button>
        <button type="button" class="btn btn-warning" data-dismiss="modal"><%= ${_LANG_Form_Close} %></button>
      </div>
    </div>
  </div>
</div>
<%
}
%>
<!DOCTYPE html>
<html>
<% /usr/shellgui/progs/main.sbin h_h '{"title":"'"${_LANG_Form_Shellgui_Web_Control}"'"}'
%>
<body>
<div id="header">
<% /usr/shellgui/progs/main.sbin h_sf
/usr/shellgui/progs/main.sbin h_nav '{"active":"home"}' %>
</div>
<div id="main">
	<div class="container">
<%
if [ "$FORM_action" = "userlist" ]; then
  userlist
elif [ "$FORM_action" = "grouplist" ]; then
  grouplist
else
/usr/shellgui/progs/main.sbin hm '{"1":{"title":"'${_LANG_App_type}'","url":"/?app=home#'${_LANG_App_type}'"},"2":{"title":"'${_LANG_App_name}'"}}' %>
    <div class="content">
	<div class="app row app-item">
		<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Managing_user} %></h2>
		<div class="col-sm-offset-2 col-sm-10 text-left">
		  <p><%= ${_LANG_Form_Enter_user_management_list} %>:</p>
		  <a href="/?app=sysusers&action=userlist"><button class="btn btn-default" type="button"><%= ${_LANG_Form_Enter} %></button></a>
		</div>
	</div>
	<hr>
	<div class="app row app-item">
		<h2 class="app-sub-title col-sm-12"><%= ${_LANG_Form_Managing_user_groups} %></h2>
		<div class="col-sm-offset-2 col-sm-10 text-left">
		  <p><%= ${_LANG_Form_Enter_user_groups_management_list} %>:</p>
		  <a href="/?app=sysusers&action=grouplist"><button class="btn btn-default" type="button"><%= ${_LANG_Form_Enter} %></button></a>
		</div>
	</div>
	</div>
<% fi %>
	</div> 
</div>
<% /usr/shellgui/progs/main.sbin h_f
/usr/shellgui/progs/main.sbin h_end %>
<script>
<% /usr/shellgui/progs/main.sbin l_p_J '_LANG_JsUI_' ${FORM_app} $COOKIE_lang %>
</script>
<script src="/apps/sysusers/sys_users.js"></script>
</body>
</html>
