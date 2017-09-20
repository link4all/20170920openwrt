<%
disk_part_edit() {
fdisk_l_str=$(fdisk -l)
cat <<'EOF' >/tmp/query_type.sh
#!/bin/sh
eval $(echo "
EOF
(block detect | sed 's/#option/option/g' >/tmp/fstab_tmp1 ;uci -c/tmp show -X fstab_tmp1; rm -f /tmp/fstab_tmp1) | cut -d '.' -f3- >>/tmp/query_type.sh
cat <<'EOF' >>/tmp/query_type.sh
" | grep -A 1 -E 'device=[[:punct:]]'"$1"'[[:punct:]]')
echo $type
EOF
chmod +x /tmp/query_type.sh
%>
<div class="app row app-item">
	<h2 class="app-sub-title col-sm-12">磁盘分区</h2>
<% echo "$fdisk_l_str" | grep -E 'Disk /dev/[hs]d' | while read line ; do
dev=$(echo "${line}" | grep -Eo '/dev/[hs]d[a-z]*')
sectors=$(echo "${line}" | cut -d ',' -f3 | grep -Eo '[0-9]*')
max_sectors_used=$(echo "$fdisk_l_str" | grep -E "${dev}[0-9]* " | awk 'BEGIN {max = 0} {if ($(NF-4)>max) {max=$(NF-4)}} END {print max}')
diff=$((${sectors} - ${max_sectors_used:-0}))
%>
	<div class="col-sm-offset-1 col-sm-11 text-left">
			<div class="">
				<h2 class="app-sub-title col-sm-12">设备:<%= ${dev} %></h2>
				<div class="col-sm-12 table-responsive">
				总大小: <% shellgui '{"action":"bit_conver","bit":'"$((${sectors} * 512))"'}' | jshon -e "result" -u;
				if [ ${diff} -gt 1024 ]; then printf "|可用: ";shellgui '{"action":"bit_conver","bit":'"$((${diff} * 512))"'}' | jshon -e "result" -u; fi %>
<table class="table">
<tr><th>Device</th><th>Boot</th><th>Start</th><th>End</th><th>Sectors</th><th>Size</th><th>Id</th><th>Type</th><th>操作</th></tr>
<%
echo "$fdisk_l_str" | grep -E "${dev}[0-9]* " | while read part_line; do
	%><tr <%
	echo "${part_line}" | awk '{print "data-part=\""$1"\"><td>"$1"</td><td>";
	if ($2 == "*") {printf "*"};
	print "</td><td>"$(NF-5)"</td><td>"$(NF-4)"</td><td>"$(NF-3)"</td><td>"$(NF-2)"</td><td>"$(NF-1)"</td><td>";
	"/tmp/query_type.sh "$1 | getline type ; printf("%s", type);
	print "</td><td>";
	printf("<button data-ptype=\"%s", type);
	print "\" type=\"button\" class=\"btn btn-info btn-xs btn_formate\" data-toggle=\"modal\" data-target=\"#format_partition_modal\">格式化</button><button type=\"button\" class=\"btn btn-danger btn-xs btn_remove confirm_trigger\" data-callback=\"deleteDisk\" data-confirm-title=\"删除分区\" data-confirm-text=\"确定删除分区？\">删除</button>";
	if (type == "swap") {
		if (system("swapon -s | grep -q \"^" $1 "\" ")) {
		print "<button type=\"button\" class=\"btn btn-default btn-xs btn_swap_mount\" data-action=\"swap_mount\">挂载</button>";
		} else {
		print "<button type=\"button\" class=\"btn btn-warning btn-xs btn_swap_mount\" data-action=\"swap_unmount\">卸载</button>";
		}
	}
	print "</td>"}'
	%></tr><%
done
%>
</table>
<% if [ ${diff} -gt 1024 ]; then %>
					<button type="button" data-dev="<%= ${dev} %>" class="btn btn-success btn-sm btn_add" data-toggle="modal" data-target="#add_new_partition_modal"><span class="icon-plus"></span>&nbsp;&nbsp;新分区</button>
<% fi %>
				</div>
			</div>
	</div>
<% done %>
</div>

<% } %>
