<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="com.redmoon.oa.fileark.*" %>
<%@ page import="org.json.*" %>
<%@ page import="cn.js.fan.web.*" %>
<%@ page import="com.cloudwebsoft.framework.db.*" %>
<%@ page import="com.redmoon.oa.util.*" %>
<%@ page import="com.redmoon.oa.basic.*" %>
<%@ page import="com.redmoon.oa.pvg.*" %>
<%@ page import="com.redmoon.oa.person.*" %>
<%@ page import="com.redmoon.oa.ui.*" %>
<%@ page import="com.redmoon.oa.flow.*" %>
<%@ page import="com.redmoon.oa.visual.*" %>
<%@ page import="com.redmoon.oa.flow.macroctl.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="com.redmoon.oa.Config" %>
<%@ page import="org.apache.http.client.utils.URIBuilder" %>
<%@ page import="com.cloudweb.oa.utils.ConstUtil" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="com.redmoon.oa.sys.DebugUtil" %>
<%
	String op = ParamUtil.get(request, "op");
	String code = ParamUtil.get(request, "code"); // 模块编码
	String formCode = ParamUtil.get(request, "formCode");
	Config cfg = new Config();
	boolean isServerConnectWithCloud = cfg.getBooleanProperty("isServerConnectWithCloud");
	String url = cfg.get("cloudUrl");
	URIBuilder uriBuilder = new URIBuilder(url);
	String host = uriBuilder.getHost();
	int port = uriBuilder.getPort();
	if (port == -1) {
		port = 80;
	}
	String path = uriBuilder.getPath();
	if (path.startsWith("/")) {
		path = path.substring(1);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<title>模块设置</title>
	<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
	<link href="../lte/css/font-awesome.min.css?v=4.4.0" rel="stylesheet"/>
	<style>
		.role-sel-btn {
			vertical-align: baseline;
			width: 24px;
		}
	</style>
	<script src="../inc/common.js"></script>
	<script src="../inc/livevalidation_standalone.js"></script>
	<script src="<%=request.getContextPath()%>/js/jquery-1.9.1.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/jquery-migrate-1.2.1.min.js"></script>
	<script src="../inc/map.js"></script>

	<link rel="stylesheet" href="<%=request.getContextPath()%>/js/bootstrap/css/bootstrap.min.css"/>
	<script src="<%=request.getContextPath()%>/js/bootstrap/js/bootstrap.min.js"></script>

	<script src="../js/select2/select2.js"></script>
	<link href="../js/select2/select2.css" rel="stylesheet"/>

	<script src="../js/jquery.toaster.js"></script>

	<script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
	<script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
	<link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet" type="text/css" media="screen"/>

	<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/flexbox/flexbox.css"/>
	<script type="text/javascript" src="../js/jquery.flexbox.js"></script>

	<link href="../js/jquery-showLoading/showLoading.css" rel="stylesheet" media="screen"/>
	<script type="text/javascript" src="../js/jquery-showLoading/jquery.showLoading.js"></script>
	<script type="text/javascript" src="../inc/livevalidation_standalone.js"></script>

	<script type="text/javascript" src="../js/formpost.js"></script>
	<script src="../js/json2.js"></script>
	<script type="text/javascript" src="../js/activebar2.js"></script>

	<script>
		function window_onload() {
			getFieldOfForm($('#otherFormCode').val());
		}

		var errFunc = function (response) {
			window.status = response.responseText;
		}

		function doGetField(response) {
			var rsp = response.responseText.trim();
			$('#spanField').html(rsp);
			$('#otherShowField').append("<option value='id'>ID</option>");
			$('#otherField').append("<option value='cws_id'>cws_id</option>");
		}

		function getFieldOfForm(formCode) {
			var str = "formCode=" + formCode;
			var myAjax = new cwAjax.Request(
					"module_field_ajax.jsp",
					{
						method: "post",
						parameters: str,
						onComplete: doGetField,
						onError: errFunc
					}
			);
		}
	</script>
</head>
<body onload="window_onload()">
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
if (!privilege.isUserPrivValid(request, "admin.flow")) {
	out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
	return;
}

String tabIdOpener = ParamUtil.get(request, "tabIdOpener");

ModuleSetupDb vsd = new ModuleSetupDb();
vsd = vsd.getModuleSetupDb(code);
if (vsd==null) {
	out.print(SkinUtil.makeErrMsg(request, "模块：" + code + "不存在"));
	return;
}
else {
	formCode = vsd.getString("form_code");
}

FormMgr fm = new FormMgr();
FormDb fd = fm.getFormDb(formCode);
if (!fd.isLoaded()) {
	out.print(StrUtil.jAlert_Back("表单不存在！","提示"));
	return;
}

int work_log = vsd.getInt("is_workLog");
%>
<%@ include file="module_setup_inc_menu_top.jsp"%>
<script>
o("menu1").className="current";
</script>
<div class="spacerH"></div>
<form id="formModuleProps" method="post">
	<table cellspacing="0" class="tabStyle_1 percent98" cellpadding="3" width="95%" align="center">
		<tr>
			<td colspan="6" align="center" class="tabStyle_1_title">模块信息</td>
		</tr>
		<tr>
			<td width="11%" align="center">
				模块名称
				<input name="code" value="<%=code%>" type="hidden"/>
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
			</td>
			<td width="22%" align="left"><input name="name" value="<%=StrUtil.getNullStr(vsd.getString("name"))%>"/></td>
			<%
				License license = License.getInstance();
				if (license.isPlatformSrc()) {
			%>
			<td width="9%" align="center">模块状态</td>
			<td width="14%" align="left"><select name="isUse">
				<option value="1" <%=vsd.getInt("is_use") == 1 ? "selected" : ""%>>启用</option>
				<option value="0" <%=vsd.getInt("is_use") == 0 ? "selected" : ""%>>停用</option>
			</select></td>
			<%} %>
			<td width="11%" align="center">模块编码</td>
			<td width="33%" align="left" <%=license.isPlatformSrc() ? "" : "colspan=3"%>><%=vsd.getString("code")%>
			</td>
		</tr>
		<tr>
			<td align="center">模块描述</td>
			<td align="left">
				<input id="description" name="description" value="<%=StrUtil.getNullStr(vsd.getString("description"))%>"/>
			</td>
			<td align="center">在位编辑</td>
			<td align="left">
				<select name="is_edit_inplace" title="在位编辑不支持相关事件脚本，且从模块暂不支持在位编辑">
					<option value="1" <%=vsd.getInt("is_edit_inplace") == 1 ? "selected" : ""%>>是</option>
					<option value="0" <%=vsd.getInt("is_edit_inplace") == 0 ? "selected" : ""%>>否</option>
				</select>
			</td>
			<td align="center">&nbsp;</td>
			<td align="left">&nbsp;</td>
		</tr>
		<tr style="display:<%=code.equals(formCode)?"":"none"%>">
			<td align="center">事件提醒</td>
			<td align="left">
				<img src="../admin/images/combination.png" style="margin-bottom:-5px;"/>
				<a href="javascript:;" onclick="openMsgPropDlg()">配置</a>
				<span style="margin:10px"><img src="../admin/images/gou.png" style="margin-bottom:-5px;width:20px;height:20px;display:<%=StrUtil.getNullStr(vsd.getString("msg_prop")).equals("")?"none":"" %>"/></span>
				<textarea id="msgProp" style="display:none"><%=StrUtil.getNullStr(vsd.getString("msg_prop"))%></textarea>
			</td>
			<td align="center">添加后跳转</td>
			<td align="left"><input id="add_to_url" name="add_to_url" value="<%=StrUtil.getNullStr(vsd.getString("add_to_url"))%>"/></td>
			<td align="center">&nbsp;</td>
			<td align="left">&nbsp;</td>
		</tr>
		<tr>
			<td align="center">查看按钮</td>
			<td align="left">
				<select id="btn_display_show" name="btn_display_show">
					<option value="1">显示</option>
					<option value="0">隐藏</option>
				</select>
				<script>
					o("btn_display_show").value = "<%=vsd.getInt("btn_display_show")%>";
				</script>
			</td>
			<td align="center">添加按钮</td>
			<td align="left">
				<select id="btn_add_show" name="btn_add_show">
					<option value="1">显示</option>
					<option value="0">隐藏</option>
				</select>
				<script>
					o("btn_add_show").value = "<%=vsd.getInt("btn_add_show")%>";
				</script>
			</td>
			<td align="center">编辑按钮</td>
			<td align="left">
				<select id="btn_edit_show" name="btn_edit_show">
					<option value="1">显示</option>
					<option value="0">隐藏</option>
				</select>
				<script>
					o("btn_edit_show").value = "<%=vsd.getInt("btn_edit_show")%>";
				</script>
			</td>
		</tr>
		<tr>
			<td align="center">流程按钮</td>
			<td align="left"><select id="btn_flow_show" name="btn_flow_show">
				<option value="1">显示</option>
				<option value="0">隐藏</option>
			</select>
				<script>
					o("btn_flow_show").value = "<%=vsd.getInt("btn_flow_show")%>";
				</script>
			</td>
			<td align="center">日志按钮</td>
			<td align="left"><select id="btn_log_show" name="btn_log_show">
				<option value="1">显示</option>
				<option value="0">隐藏</option>
			</select>
				<script>
					o("btn_log_show").value = "<%=vsd.getInt("btn_log_show")%>";
				</script>
			</td>
			<td align="center">删除按钮</td>
			<td align="left"><select id="btn_del_show" name="btn_del_show">
				<option value="1">显示</option>
				<option value="0">隐藏</option>
			</select>
				<script>
					o("btn_del_show").value = "<%=vsd.getInt("btn_del_show")%>";
				</script>
			</td>
		</tr>
		<tr>
			<td align="center">显示视图</td>
			<td align="left">
				<select id="view_show" name="view_show" onchange="onChangeViewShow(this)">
					<option value="<%=ModuleSetupDb.VIEW_DEFAULT%>">默认</option>
					<%
						FormViewDb fvd = new FormViewDb();
						Iterator irv = fvd.getViews(formCode).iterator();
						while (irv.hasNext()) {
							fvd = (FormViewDb) irv.next();
					%>
					<option value="<%=fvd.getInt("id")%>"><%=fvd.getString("name")%>
					</option>
					<%
						}
					%>
					<option value="<%=ModuleSetupDb.VIEW_SHOW_TREE%>">树形视图</option>
					<option value="<%=ModuleSetupDb.VIEW_SHOW_CUSTOM%>">自定义</option>
				</select>
				<script>
					o("view_show").value = "<%=vsd.getInt("view_show")%>";
				</script>
				<%--&nbsp;
				<input type="checkbox" id="btn_edit_display" name="btn_edit_display" value="1" <%=vsd.getInt("btn_edit_display") == 1 ? "checked" : ""%> title="显示视图中编辑按钮是否显示"/>
				&nbsp;编辑按钮
				&nbsp;&nbsp;
				<input type="checkbox" id="btn_print_display" name="btn_print_display" value="1" <%=vsd.getInt("btn_print_display") == 1 ? "checked" : ""%> title="显示视图中打印按钮是否显示"/>
				&nbsp;打印按钮--%>
			</td>
			<td colspan="2" align="left">
        <span id="urlModuleShow" style="display:none">
        &nbsp;&nbsp;显示页地址 <input title="如果页面是定制的，请输入显示页地址" name="url_show" value="<%=StrUtil.getNullStr(vsd.getString("url_show"))%>"/>
        </span>
				<span id="fieldTreeModuleShow" style="display:none">
        &nbsp;&nbsp;树形字段 
        <select title="树形视图时，左侧树形结构对应的基础数据宏控件字段" id="field_tree_show" name="field_tree_show">
        <option value="">请选择</option>
        <%
			SelectMgr sm = new SelectMgr();
			MacroCtlMgr mm = new MacroCtlMgr();
			Iterator ir = fd.getFields().iterator();
			while (ir.hasNext()) {
				FormField ff = (FormField) ir.next();
				MacroCtlUnit mu = mm.getMacroCtlUnit(ff.getMacroType());
				if (mu != null && mu.getCode().equals("macro_flow_select")) {
					String valRaw = ff.getDefaultValueRaw();
					SelectDb sd = sm.getSelect(valRaw);
					if (sd.getType() == SelectDb.TYPE_TREE) {
		%>
		        	<option value="<%=ff.getName() %>"><%=ff.getTitle() %></option>
		<%
					}
				}
			}
		%>
        </select>
	    <script>
		o("field_tree_show").value = "<%=StrUtil.getNullStr(vsd.getString("field_tree_show"))%>";
		</script>        
        </span>
			</td>
			<td align="center">日志模块
			</td>
			<td align="left">
				<select id="module_code_log" name="module_code_log" style="width: 150px;">
					<%
						String sql = vsd.getTable().getSql("listForForm") + StrUtil.sqlstr("module_log") + " order by kind asc, name asc";
						Iterator irLog = vsd.list(sql).iterator();
						while (irLog.hasNext()) {
							ModuleSetupDb msd = (ModuleSetupDb) irLog.next();
					%>
					<option value="<%=msd.getString("code")%>"><%=msd.getString("name")%>
					</option>
					<%
						}
					%>
				</select>
				<script>
					$(function () {
						$('#module_code_log').val('<%=vsd.getString("module_code_log")%>');
						$('#module_code_log').select2();
					})
				</script>
			</td>
		</tr>
		<tr>
			<td align="center">编辑视图</td>
			<td align="left">
				<select id="view_edit" name="view_edit" onchange="onChangeViewEdit(this)">
					<option value="<%=ModuleSetupDb.VIEW_DEFAULT%>">默认</option>
					<option value="<%=ModuleSetupDb.VIEW_EDIT_CUSTOM%>">自定义</option>
					<%
						irv = fvd.getViews(formCode).iterator();
						while (irv.hasNext()) {
							fvd = (FormViewDb) irv.next();
					%>
					<option value="<%=fvd.getInt("id")%>"><%=fvd.getString("name")%>
					</option>
					<%
						}
					%>
				</select>
				<script>
					o("view_edit").value = "<%=vsd.getInt("view_edit")%>";
				</script>
			</td>
			<td colspan="2" align="left">
        <span id="urlModuleEdit" style="display:none">
        &nbsp;&nbsp;编辑页地址 <input title="如果页面是定制的，请输入列表页地址" name="url_edit" value="<%=StrUtil.getNullStr(vsd.getString("url_edit"))%>"/>
        </span>
			</td>
			<td align="center">生成视图</td>
			<td align="left">
				<select id="exportWordView" name="exportWordView" title="生成word时指定视图">
					<option value="<%=ConstUtil.MODULE_EXPORT_WORD_VIEW_SELECT%>">用户自选</option>
					<option value="<%=ConstUtil.MODULE_EXPORT_WORD_VIEW_FORM%>">根据表单</option>
					<%
						FormViewDb formViewDb = new FormViewDb();
						Vector vtView = formViewDb.getViews(formCode);
						Iterator irView = vtView.iterator();
						while (irView.hasNext()) {
							formViewDb = (FormViewDb) irView.next();
					%>
					<option value="<%=formViewDb.getLong("id")%>"><%=formViewDb.getString("name")%>
					</option>
					<%
						}
					%>
				</select>
				<script>
					$('#exportWordView').val('<%=vsd.getInt("export_word_view")%>');
				</script>
			</td>
		</tr>
		<tr>
			<td align="center">列表视图</td>
			<td align="left">
				<select id="view_list" name="view_list" onchange="onChangeViewList(this)">
					<option value="<%=ModuleSetupDb.VIEW_DEFAULT%>">默认</option>
					<option value="<%=ModuleSetupDb.VIEW_LIST_GANTT%>">任务看板</option>
					<option value="<%=ModuleSetupDb.VIEW_LIST_GANTT_LIST%>">任务看板/列表</option>
					<option value="<%=ModuleSetupDb.VIEW_LIST_TREE%>">树形（一对多）</option>
					<!--<option value="<%=ModuleSetupDb.VIEW_LIST_MODULE_TREE%>">树形（一对一）</option>-->
					<option value="<%=ModuleSetupDb.VIEW_LIST_CALENDAR%>">日历看板</option>
					<option value="<%=ModuleSetupDb.VIEW_LIST_CALENDAR_LIST%>">日历看板/列表</option>
					<option value="<%=ModuleSetupDb.VIEW_LIST_CUSTOM%>">自定义</option>
				</select>
				<script>
					function onChangeViewList() {
						var val = $('#view_list').val();
						if (val == '<%=ModuleSetupDb.VIEW_LIST_CUSTOM%>') {
							$('#urlListRow').show();
							// $('#urlModuleEdit').hide();
							$('#fieldDateRow').hide();
							$('#fieldRow').hide();
							$('#scaleRow').hide();
							$('#fieldTreeList').hide();
							$('#moduleTreeListSpan').hide();
						} else if (val == '<%=ModuleSetupDb.VIEW_LIST_GANTT%>' || val == '<%=ModuleSetupDb.VIEW_LIST_GANTT_LIST%>') {
							$('#fieldDateRow').show();
							$('#fieldRow').show();
							$('#scaleRow').show();
							$('#urlListRow').hide();
							$('#fieldTreeList').hide();
							$('#moduleTreeListSpan').hide();
							// $('#urlModuleEdit').hide();
						} else if (val == '<%=ModuleSetupDb.VIEW_LIST_CALENDAR%>' || val == '<%=ModuleSetupDb.VIEW_LIST_CALENDAR_LIST%>') {
							$('#fieldDateRow').show();
							$('#fieldRow').show();
							$('#scaleRow').hide();
							$('#urlListRow').hide();
							$('#fieldTreeList').hide();
							$('#moduleTreeListSpan').hide();
						} else if (val == '<%=ModuleSetupDb.VIEW_LIST_TREE%>') {
							$('#fieldDateRow').hide();
							$('#fieldRow').hide();
							$('#scaleRow').hide();
							$('#urlListRow').hide();
							$('#fieldTreeList').show();
							$('#moduleTreeListSpan').hide();
						}
						else if (val == '<%=ModuleSetupDb.VIEW_LIST_MODULE_TREE%>') {
							$('#fieldDateRow').hide();
							$('#fieldRow').hide();
							$('#scaleRow').hide();
							$('#urlListRow').hide();
							$('#fieldTreeList').hide();
							$('#moduleTreeListSpan').show();
						}
						else {
							$('#fieldDateRow').hide();
							$('#fieldRow').hide();
							$('#scaleRow').hide();
							$('#urlListRow').hide();
							$('#fieldTreeList').hide();
							$('#moduleTreeListSpan').hide();
							// $('#urlModuleEdit').hide();
						}
					}

					function onChangeViewEdit() {
						var val = $('#view_edit').val();
						if (val == '<%=ModuleSetupDb.VIEW_EDIT_CUSTOM%>') {
							$('#urlModuleEdit').show();
						} else {
							$('#urlModuleEdit').hide();
						}
					}

					function onChangeViewShow() {
						var val = $('#view_show').val();
						if (val == '<%=ModuleSetupDb.VIEW_SHOW_CUSTOM%>') {
							$('#urlModuleShow').show();
							$('#fieldTreeModuleShow').hide();
						} else if (val == '<%=ModuleSetupDb.VIEW_SHOW_TREE%>') {
							$('#fieldTreeModuleShow').show();
							$('#urlModuleShow').hide();
						} else {
							$('#urlModuleShow').hide();
							$('#fieldTreeModuleShow').hide();
						}
					}

					$(function () {
						o("view_list").value = "<%=vsd.getInt("view_list")%>";
						o("view_edit").value = "<%=vsd.getInt("view_edit")%>";
						onChangeViewList();
						onChangeViewEdit();
						onChangeViewShow();
					});
				</script>
			</td>
			<td colspan="2" align="center">
			  <span id="urlListRow" style="display:none">
			  &nbsp;&nbsp;列表页地址
			  <input title="如果页面是定制的，请输入列表页地址" name="url_list" value="<%=StrUtil.getNullStr(vsd.getString("url_list"))%>"/>
			  </span>
			  <span id="fieldTreeList" style="display:none">
				&nbsp;&nbsp;树形字段
				<select title="树形视图时，左侧树形结构对应的基础数据宏控件字段" id="field_tree_list" name="field_tree_list">
				</select>
				<script>
				$(function () {
					$('#field_tree_list').html($('#field_tree_show').html());
					$('#field_tree_list').val("<%=StrUtil.getNullStr(vsd.getString("field_tree_list"))%>");
				});
				</script>
			  </span>
				<span id="moduleTreeListSpan" style="display:none">
				基础数据
				<select title="树形基础数据" id="module_tree_basic" name="module_tree_basic">
					<option value="">无</option>
					<%
						List<SelectDb> listTree = sm.listByTree();
						for (SelectDb sd : listTree) {
					%>
						<option value="<%=sd.getCode() %>"><%=sd.getName() %></option>
					<%
						}
					%>
				</select>
				<%
					String opts = "", optsDate = "";
					ir = fd.getFields().iterator();
					while (ir.hasNext()) {
						FormField ff = (FormField) ir.next();
						if (ff.getFieldType() == FormField.FIELD_TYPE_DATE || ff.getFieldType() == FormField.FIELD_TYPE_DATETIME) {
							optsDate += "<option value='" + ff.getName() + "'>" + ff.getTitle() + "</option>";
						}
						opts += "<option value='" + ff.getName() + "'>" + ff.getTitle() + "</option>";
					}
				%>
				<br/>编码字段
				<select title="树形基础数据对应的编码字段" id="module_tree_field_code" name="module_tree_field_code">
					<option value="">无</option>
					<%=opts%>
				</select>
				<br/>名称字段
				<select title="树形基础数据对应的名称字段" id="module_tree_field_name" name="module_tree_field_name">
					<option value="">无</option>
					<%=opts%>
				</select>
				<script>
				$(function () {
					$('#module_tree_basic').val('<%=StrUtil.getNullStr(vsd.getString("module_tree_basic"))%>');
					$('#module_tree_field_code').val("<%=StrUtil.getNullStr(vsd.getString("module_tree_field_code"))%>");
					$('#module_tree_field_name').val("<%=StrUtil.getNullStr(vsd.getString("module_tree_field_name"))%>");
				});
				</script>
			  </span>
			</td>
			<td align="center">
				列表高度
			</td>
			<td>
				<input id="is_auto_height" name="is_auto_height" type="checkbox" value="1" <%=vsd.getInt("is_auto_height") == 1 ? "checked" : ""%>/>&nbsp;自适应
			</td>
		</tr>
		<tr>
			<td align="center">映射字段</td>
			<td align="left">
				排序
				<select id="other_multi_order" name="other_multi_order" title="映射字段有多个值时按ID号排序">
					<option value="1">升序</option>
					<option value="0">降序</option>
				</select>
				<script>
					$('#other_multi_order').val('<%=vsd.getInt("other_multi_order")%>');
				</script>
			</td>
			<td align="center">分隔符</td>
			<td align="left">
				<input id="other_multi_ws" name="other_multi_ws" title="为空时默认分隔符为半角逗号" value="<%=StrUtil.getNullStr(vsd.getString("other_multi_ws"))%>"/>
			</td>
			<td align="center">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr id="fieldDateRow">
			<td align="center">日期字段</td>
			<td colspan="5" align="left">
				开始日期：
				<select id="field_begin_date" name="field_begin_date">
					<option value="">无</option>
					<%=optsDate%>
				</select>
				结束日期：
				<select id="field_end_date" name="field_end_date">
					<option value="">无</option>
					<%=optsDate%>
				</select>
			</td>
		</tr>
		<tr id="fieldRow">
			<td align="center">显示字段</td>
			<td colspan="5" align="left">
				名称：
				<select id="field_name" name="field_name">
					<option value="">无</option>
					<%=opts%>
				</select>
				描述：
				<select id="field_desc" name="field_desc">
					<option value="">无</option>
					<%=opts%>
				</select>
				标签：
				<select id="field_label" name="field_label">
					<option value="">无</option>
					<%=opts%>
				</select>
			</td>
		</tr>
		<tr id="scaleRow">
			<td align="center">显示比例</td>
			<td colspan="5" align="left">
				默认：
				<select id="scale_default" name="scale_default">
					<option value="">无</option>
					<option value="hours">小时</option>
					<option value="days">天</option>
					<option value="weeks" selected>周</option>
					<option value="months">月</option>
				</select>
				最小：
				<select id="scale_min" name="scale_min">
					<option value="hours" selected>小时</option>
					<option value="days">天</option>
					<option value="weeks">周</option>
					<option value="months">月</option>
				</select>
				最大：
				<select id="scale_max" name="scale_max">
					<option value="hours">小时</option>
					<option value="days">天</option>
					<option value="weeks">周</option>
					<option value="months" selected>月</option>
				</select>
				<script>
					$('#field_begin_date').val("<%=StrUtil.getNullStr(vsd.getString("field_begin_date"))%>");
					$('#field_end_date').val("<%=StrUtil.getNullStr(vsd.getString("field_end_date"))%>");
					$('#field_name').val("<%=StrUtil.getNullStr(vsd.getString("field_name"))%>");
					$('#field_desc').val("<%=StrUtil.getNullStr(vsd.getString("field_desc"))%>");
					$('#field_label').val("<%=StrUtil.getNullStr(vsd.getString("field_label"))%>");
					<%
                    String scaleDefault = StrUtil.getNullStr(vsd.getString("scale_default"));
                    String scaleMin = StrUtil.getNullStr(vsd.getString("scale_min"));
                    String scaleMax = StrUtil.getNullStr(vsd.getString("scale_max"));
                    if ("".equals(scaleDefault)) {
                        scaleDefault = "weeks";
                    }
                    if ("".equals(scaleMin)) {
                        scaleMin = "hours";
                    }
                    if ("".equals(scaleMax)) {
                        scaleMax = "months";
                    }
                    %>
					$('#scale_default').val("<%=scaleDefault%>");
					$('#scale_min').val("<%=scaleMin%>");
					$('#scale_max').val("<%=scaleMax%>");
				</script>
			</td>
		</tr>
		<%if (code.equals("prj") || code.equals("prj_task") || code.equals("mobile_prj") || code.equals("mobile_prj_task") || code.equals("mobile_prj_task_for_prj") || code.equals("mobile_prj_task_created")) { %>
		<tr>
			<td align="center">关联汇报</td>
			<td colspan="5" align="left">
				<input type="checkbox" id="is_workLog" onclick="changeWorkLog()"/>
				<input type="hidden" class="is_workLog" id="is_workLog_val" name="is_workLog_val" value="0"/>
			</td>
		</tr>
		<%} %>
		<tr>
			<td colspan="6" align="center">
				<input id="btnModuleProp" class="btn btn-default" type="button" value="确定"/>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<%
					String moduleUrlList = request.getContextPath() + "/visual/module_list.jsp?code=" + code + "&formCode=" + StrUtil.UrlEncode(formCode);
					if (vsd.getInt("view_list") == ModuleSetupDb.VIEW_LIST_GANTT) {
						moduleUrlList = request.getContextPath() + "/visual/module_list_gantt.jsp?code=" + code + "&formCode=" + StrUtil.UrlEncode(formCode);
					} else if (vsd.getInt("view_list") == ModuleSetupDb.VIEW_LIST_CALENDAR) {
						moduleUrlList = request.getContextPath() + "/visual/module_list_calendar.jsp?code=" + code + "&formCode=" + StrUtil.UrlEncode(formCode);
					} else if (vsd.getInt("view_list") == ModuleSetupDb.VIEW_LIST_TREE) {
						boolean isInFrame = ParamUtil.getBoolean(request, "isInFrame", false);
						if (!isInFrame) {
							moduleUrlList = request.getContextPath() + "/visual/module_list_frame.jsp?code=" + code + "&formCode=" + StrUtil.UrlEncode(formCode);
						}
					} else if (vsd.getInt("view_list") == ModuleSetupDb.VIEW_LIST_CUSTOM) {
						moduleUrlList = StrUtil.getNullStr(vsd.getString("url_list"));
						if (!"".equals(moduleUrlList)) {
							moduleUrlList = request.getContextPath() + "/" + moduleUrlList + "?code=" + code + "&formCode=" + StrUtil.UrlEncode(formCode);
						}
					}

					if (license.isPlatformSrc() && vsd.getInt("is_use") == 1) {
				%>
				<input class="btn btn-default" type="button" value="打开" onclick="addTab('<%=StrUtil.getNullStr(vsd.getString("name"))%>', '<%=moduleUrlList%>');"/></td>
			<%
				}
			%>
		</tr>
	</table>
</form>
<%
String listField = StrUtil.getNullStr(vsd.getString("list_field"));
String[] fields = StrUtil.split(listField, ",");
String listFieldWidth = StrUtil.getNullStr(vsd.getString("list_field_width"));
String[] fieldsWidth = StrUtil.split(listFieldWidth, ",");
String listFieldOrder = StrUtil.getNullStr(vsd.getString("list_field_order"));
String[] fieldOrder = StrUtil.split(listFieldOrder, ",");
String listFieldLink = StrUtil.getNullStr(vsd.getString("list_field_link"));
String[] fieldsLink = StrUtil.split(listFieldLink, ",");
String listFieldShow = StrUtil.getNullStr(vsd.getString("list_field_show"));
String[] fieldsShow = StrUtil.split(listFieldShow, ",");
String[] fieldsTitle = vsd.getColAry(true, "list_field_title");
String listFieldTitle = StrUtil.getNullStr(vsd.getString("list_field_title"));
/*String[] fieldsTitle = StrUtil.split(listFieldTitle, ",");*/
String[] fieldsAlign = vsd.getColAry(true, "list_field_align");
String listFieldAlign = StrUtil.getNullStr(vsd.getString("list_field_align"));

int len = 0;
if (fields!=null) {
	len = fields.length;
}

if (fieldsShow==null || fields.length != fieldsShow.length) {
	fieldsShow = new String[len];
	for (int i=0; i<len; i++) {
		fieldsShow[i] = "1";
	}
}

int i;
%>
<table cellSpacing="0" class="tabStyle_1 percent98" cellPadding="3" width="95%" align="center">
	<tr>
		<td>
			<jsp:include page="module_field_inc_preview.jsp">
				<jsp:param name="code" value="<%=code%>"/>
				<jsp:param name="formCode" value="<%=formCode%>"/>
				<jsp:param name="from" value="module_field_list"/>
			</jsp:include>
		</td>
	</tr>
</table>

<table cellSpacing="0" id="mainTable" class="tabStyle_1 percent98" cellPadding="3" width="95%" align="center">
	<thead>
	<tr>
		<td class="tabStyle_1_title" width="4%">序号</td>
		<td class="tabStyle_1_title" width="12%">字段名称</td>
		<td class="tabStyle_1_title" width="15%">字段标题</td>
		<td class="tabStyle_1_title" width="15%">标题别名</td>
		<td class="tabStyle_1_title" width="6%">位置</td>
		<td class="tabStyle_1_title" width="5%">显示</td>
		<td class="tabStyle_1_title" width="5%">顺序号</td>
		<td class="tabStyle_1_title" width="5%">宽度</td>
		<td class="tabStyle_1_title" width="17%">链接</td>
		<td class="tabStyle_1_title">操作</td>
	</tr>
	</thead>
<%
JSONArray jsonAry = new JSONArray();
for (i=0; i<len; i++) {
	String fieldName = fields[i];
	String fieldNameRaw = fieldName;
	String title = "";
	if (fieldName.equals("cws_creator")) {
		title = "创建者";		
	}
	else if (fieldName.equals("ID")) {
		title = "ID";
	}
	else if (fieldName.equals("cws_progress")) {
		title = "进度";
	}
	else if (fieldName.equals("flowId")) {
	    title = "流程号";
    }
	else if (fieldName.equals("cws_status")) {
		title = "状态";
	}	
	else if (fieldName.equals("cws_flag")) {
		title = "冲抵状态";
	}
	else if (fieldName.equals("colOperate")) {
		title = "操作";
	}
	else if (fieldName.equals("cws_create_date")) {
		title = "创建时间";
	}
	else if (fieldName.equals("flow_begin_date")) {
		title = "流程开始时间";
	}
	else if (fieldName.equals("flow_end_date")) {
		title = "流程结束时间";
	}
	else if (fieldName.equals("cws_id")) {
		title = "关联ID";
	}
	else {
		if (fieldName.startsWith("main")) {
			String[] ary = StrUtil.split(fieldName, ":");
			fieldName = fieldName.substring(5);
			if (ary.length>1) {
				FormDb mainFormDb = fm.getFormDb(ary[1]);
				title = mainFormDb.getName() + "：" + mainFormDb.getFieldTitle(ary[2]);
			}
		}
		else if (fieldName.startsWith("other")) {
			String[] ary = StrUtil.split(fieldName, ":");
			if (fieldName.length()>6) {			
				fieldName = fieldName.substring(6);
			}
			if (ary.length<5) {
				title = "<font color='red'>格式非法</font>";
			}
			else {
				FormDb otherFormDb = fm.getFormDb(ary[2]);
				if (ary.length>=5) {
					title = otherFormDb.getName() + "：" + otherFormDb.getFieldTitle(ary[4]);
				}
				
				if (ary.length>=8) {
					FormDb oFormDb = fm.getFormDb(ary[5]);
					title += "：" + oFormDb.getFieldTitle(ary[7]);
				}
			}
		}
		else {
			title = fd.getFieldTitle(fieldName);
		}
	}
%>
<form id="formModify<%=i%>" name="formModify<%=i%>" method="post" action="module_field_list.jsp?op=modify">
    <tr fieldName="<%=fieldNameRaw%>">
      <td align="center"><%=i+1%></td>
      <td><%=fieldName%>
        <input name="code" value="<%=code%>" type="hidden" />
        <input name="formCode" value="<%=formCode%>" type="hidden" />
      	<input name="fieldName" value="<%=fieldNameRaw%>" type="hidden" />
      </td>
	<td>
		<%=title%>
	</td>
	<td>
		<input name="fieldTitle" value="<%="#".equals(fieldsTitle[i]) ? "" : fieldsTitle[i]%>" title="为空则默认使用字段名称"/>
	</td>
	<td>
		<select name="fieldAlign">
			<option value="center" <%="center".equals(fieldsAlign[i]) ? "selected" : ""%>>居中</option>
			<option value="left" <%="left".equals(fieldsAlign[i]) ? "selected" : ""%>>居左</option>
			<option value="right" <%="right".equals(fieldsAlign[i]) ? "selected" : ""%>>居右</option>
		</select>
	</td>
	<td>
		<select name="fieldShow">
			<option value="1" <%="1".equals(fieldsShow[i])?"selected":""%>>显示</option>
			<option value="0" <%="0".equals(fieldsShow[i])?"selected":""%>>隐藏</option>
		</select>
	</td>
      <td><input name="fieldOrder" size="5" value="<%=fieldOrder[i]%>" /></td>
      <td><input name="fieldWidth" size="5" value="<%="#".equals(fieldsWidth[i])?"":fieldsWidth[i]%>" />      </td>
      <td><input name="fieldLink" style="width:98%" value="<%=(fieldsLink==null || "#".equals(fieldsLink[i]))?"":fieldsLink[i]%>" /></td>
      <td align="center">
	  <input class="btn btn-default" type="button" value="修改" onclick="submitModifyCol('formModify<%=i%>')" />
	  &nbsp;&nbsp;
	  <input class="btn btn-default" type="button" value="删除" onclick="delCol('<%=fieldNameRaw%>')" style="cursor:pointer"/>
	  </td>
    </tr>
</form>
	<script>
		function submitModifyCol(formId) {
			<%
            if (isServerConnectWithCloud) {
            %>
			$.ajax({
				type: "post",
				url: "colModify.do",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				data: $('#' + formId).serialize(),
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					jAlert(data.msg, "提示");
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					alert(XMLHttpRequest.responseText);
				}
			});
			<%
            }else {
            %>
			var we = o("webedit");
			we.PostScript = "<%=path%>/public/module/modify.do";

			loadDataToWebeditCtrl(o(formId), o("webedit"));
			we.AddField("cwsVersion", "<%=cfg.get("version")%>");
			we.AddField("listField", "<%=listField%>");
			we.AddField("listFieldWidth", "<%=listFieldWidth%>");
			we.AddField("listFieldOrder", "<%=listFieldOrder%>");
			we.AddField("listFieldLink", "<%=listFieldLink%>");
			we.AddField("listFieldShow", "<%=listFieldShow%>");
			we.AddField("listFieldTitle", "<%=listFieldTitle%>");
			we.AddField("listFieldAlign", "<%=listFieldAlign%>");
			we.UploadToCloud();

			var data = $.parseJSON(o("webedit").ReturnMessage);
			if (data.ret == "1") {
				$.ajax({
					type: "post",
					url: "colSave.do",
					contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
					data: {
						code: "<%=code%>",
						formCode: "<%=formCode%>",
						result: JSON.stringify(data.result)
					},
					dataType: "html",
					beforeSend: function (XMLHttpRequest) {
						$('body').showLoading();
					},
					success: function (data, status) {
						data = $.parseJSON(data);
						jAlert(data.msg, "提示");
					},
					complete: function (XMLHttpRequest, status) {
						$('body').hideLoading();
					},
					error: function (XMLHttpRequest, textStatus) {
						// 请求出错处理
						alert(XMLHttpRequest.responseText);
					}
				});
			} else {
				jAlert(data.msg, "提示");
			}
			<%
            }
            %>
		}

		function delCol(fieldNameRaw) {
			jConfirm('您确定要删除么？', '提示', function (r) {
				if (!r) {
					return;
				} else {
					$.ajax({
						type: "post",
						url: "colDel.do",
						contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
						data: {
							code: "<%=code%>",
							formCode: "<%=formCode%>",
							fieldName: fieldNameRaw
						},
						dataType: "html",
						beforeSend: function (XMLHttpRequest) {
							$('body').showLoading();
						},
						success: function (data, status) {
							data = $.parseJSON(data);
							if (data.ret == "1") {
								jAlert(data.msg, "提示", function () {
									window.location.reload()
								});
							} else {
								jAlert(data.msg, "提示");
							}
						},
						complete: function (XMLHttpRequest, status) {
							$('body').hideLoading();
						},
						error: function (XMLHttpRequest, textStatus) {
							// 请求出错处理
							alert(XMLHttpRequest.responseText);
						}
					});
				}
			})
		}
	</script>
<%}%>
	<tr>
		<td colspan="10" align="left" style="PADDING-LEFT: 10px" class="tabStyle_1_title">添加列表中的字段</td>
	</tr>
	<tr>
		<td colspan="10" align="left" style="PADDING-LEFT: 10px">
			<form id="formAddCol" name="formAddCol" method="post" action="module_field_list.jsp?op=add">
				字段
				<select id="fieldNameForList" name="fieldName">
					<option value="ID">-ID-</option>
					<option value="cws_creator">-创建者-</option>
					<option value="cws_progress">-进度-</option>
					<%if (fd.isFlow()) {%>
					<option value="flowId">-流程号-</option>
					<option value="cws_status">-记录状态-</option>
					<option value="flow_begin_date">-流程开始时间-</option>
					<option value="flow_end_date">-流程结束时间-</option>
					<%}%>
					<option value="cws_flag">-冲抵状态-</option>
					<option value="colOperate">-操作列-</option>
					<option value="cws_create_date">-创建时间-</option>
					<option value="cws_id">-关联ID-</option>
					<%
						Vector v = fd.getFields();
						ir = v.iterator();
						while (ir.hasNext()) {
							FormField ff = (FormField) ir.next();
					%>
					<option value="<%=ff.getName()%>"><%=ff.getTitle()%>
					</option>
					<%
						}

						ModuleRelateDb mrd = new ModuleRelateDb();
						Vector v2 = mrd.getFormsRelatedWith(formCode);
						Iterator ir2 = v2.iterator();
						while (ir2.hasNext()) {
							FormDb frmDb = (FormDb) ir2.next();
							ir = frmDb.getFields().iterator();
							while (ir.hasNext()) {
								FormField ff = (FormField) ir.next();
					%>
					<option style="BACKGROUND: #eeeeee" value="main:<%=frmDb.getCode()%>:<%=ff.getName()%>"><%=frmDb.getName()%>：<%=ff.getTitle()%>
					</option>
					<%
							}
						}
					%>
				</select>
				<select name="fieldAlign">
					<option value="center">居中</option>
					<option value="left">居左</option>
					<option value="right">居右</option>
				</select>
				<select name="fieldShow">
					<option value="1">显示</option>
					<option value="0">隐藏</option>
				</select>
				顺序号
				<input name="fieldOrder" size="5" value="<%=len>0?String.valueOf(StrUtil.toDouble(fieldOrder[len-1]) + 1):"1"%>"/>
				宽度
				<input name="fieldWidth" size="5" value="150">
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
				<input name="code" value="<%=code%>" type="hidden"/>
				<input class="btn btn-default" type="button" value="添加" onclick="submitAddCol('formAddCol')"/>
				<script>
					$('#fieldNameForList').select2();
				</script>
			</form>
		</td>
	</tr>
</table>
<script>
	function submitAddCol(formId) {
		<%
        if (isServerConnectWithCloud) {
        %>
		$.ajax({
			type: "post",
			url: "colAdd.do",
			contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
			data: $('#' + formId).serialize(),
			dataType: "html",
			beforeSend: function (XMLHttpRequest) {
				$('body').showLoading();
			},
			success: function (data, status) {
				data = $.parseJSON(data);
				if (data.ret == "1") {
					jAlert(data.msg, "提示", function () {
						window.location.reload()
					});
				} else {
					jAlert(data.msg, "提示");
				}
			},
			complete: function (XMLHttpRequest, status) {
				$('body').hideLoading();
			},
			error: function (XMLHttpRequest, textStatus) {
				// 请求出错处理
				alert(XMLHttpRequest.responseText);
			}
		});
		<%
        }else {
        %>
		var we = o("webedit");
		we.PostScript = "<%=path%>/public/module/add.do";

		loadDataToWebeditCtrl(o(formId), o("webedit"));
		we.AddField("cwsVersion", "<%=cfg.get("version")%>");
		we.AddField("listField", "<%=listField%>");
		we.AddField("listFieldWidth", "<%=listFieldWidth%>");
		we.AddField("listFieldOrder", "<%=listFieldOrder%>");
		we.AddField("listFieldLink", "<%=listFieldLink%>");
		we.AddField("listFieldShow", "<%=listFieldShow%>");
		we.AddField("listFieldTitle", "<%=listFieldTitle%>");
		we.AddField("listFieldAlign", "<%=listFieldAlign%>");
		we.UploadToCloud();

		var data = $.parseJSON(o("webedit").ReturnMessage);
		if (data.ret == "1") {
			$.ajax({
				type: "post",
				url: "colSave.do",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				data: {
					code: "<%=code%>",
					formCode: "<%=formCode%>",
					result: JSON.stringify(data.result)
				},
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					if (data.ret=="1") {
						jAlert(data.msg, "提示", function() {
							window.location.reload();
						});
					}
					else {
						jAlert(data.msg, "提示");
					}
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					alert(XMLHttpRequest.responseText);
				}
			});
		} else {
			jAlert(data.msg, "提示");
		}
		<%
        }
        %>
	}
</script>
<form id="formAddColMap" name="formAddColMap" method="post" action="module_field_list.jsp?op=add">
	<table class="tabStyle_1 percent98" align="center" width="95%">
		<tr>
			<td align="left" style="PADDING-LEFT: 10px" class="tabStyle_1_title">添加映射字段</td>
		</tr>
		<tr>
			<td align="left" style="PADDING-LEFT: 10px">
				本表字段
				<select id="fieldNameMapForList" name="fieldName">
					<%
						ir = v.iterator();
						while (ir.hasNext()) {
							FormField ff = (FormField) ir.next();
					%>
					<option value="<%=ff.getName()%>"><%=ff.getTitle()%>
					</option>
					<%
						}%>
					<option value="id">ID</option>
					<option value="cws_id">cws_id</option>
				</select>
				=
				表单
				<select id="otherFormCode" name="otherFormCode" onchange="getFieldOfForm(this.value)">
					<%
						sql = "select code from " + fd.getTableName() + " order by orders asc";
						ir = fd.list(sql).iterator();
						while (ir.hasNext()) {
							FormDb fdb = (FormDb) ir.next();
					%>
					<option value="<%=fdb.getCode()%>"><%=fdb.getName()%>
					</option>
					<%}%>
				</select>
				<script>
					$('#otherFormCode').select2();
				</script>
				中的字段
				<span id="spanField"></span>
				<br/>
				<select name="fieldShow">
					<option value="1">显示</option>
					<option value="0">隐藏</option>
				</select>
				顺序号
				<input name="fieldOrder" size="5" value="<%=len>0?String.valueOf(StrUtil.toDouble(fieldOrder[len-1]) + 1):""%>"/>
				宽度
				<input name="fieldWidth" size="5" value="150"/>
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
				<input name="code" value="<%=code%>" type="hidden"/>
				<input name="fieldType" value="1" type="hidden"/>
				<input class="btn btn-default" type="button" value="添加" onclick="submitAddCol('formAddColMap')"/>
				<script>
					$('#fieldNameMapForList').select2();
				</script>
			</td>
		</tr>
	</table>
</form>

<form id="formAddMulti" name="formAddMulti" method="post" action="module_field_list.jsp?op=add" onsubmit="return formAddMulti_onsubmit()">
	<table class="tabStyle_1 percent98" width="95%" align="center">
		<tr>
			<td align="left" style="PADDING-LEFT: 10px" class="tabStyle_1_title">添加多重映射字段</td>
		</tr>
		<tr>
			<td align="left" style="PADDING-LEFT: 10px">字段
				<input name="fieldName" style="width:200px"/>
				<input name="fieldType" value="2" type="hidden"/>
				顺序号
				<input name="fieldOrder" size="5" value="<%=len>0?String.valueOf(StrUtil.toDouble(fieldOrder[len-1]) + 1):"1"%>"/>
				宽度
				<input name="fieldWidth" size="5"/>
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
				<input name="code" value="<%=code%>" type="hidden"/>
				<input class="btn btn-default" type="button" value="添加" onclick="submitAddCol('formAddMulti')"/>
				<br/>
				规则：本表字段:对应表单编码:对应字段:获取字段:......
			</td>
		</tr>
	</table>
</form>

<form id="formPropStat" name="formPropStat" method="post">
	<table class="tabStyle_1 percent98" width="95%" align="center">
		<tr>
			<td align="left" style="PADDING-LEFT: 10px" class="tabStyle_1_title">合计字段</td>
		</tr>
		<tr>
			<td align="left" style="PADDING-LEFT: 10px">
				<a href="javascript:" onclick="addCalcuField()">添加字段</a>
				<div id="divCalcuField" style="text-align:left; margin-top:3px;">
				<%
					StringBuffer optsFieldsNum = new StringBuffer();
					Iterator irField = fd.getFields().iterator();
					while (irField.hasNext()) {
						FormField ff = (FormField) irField.next();
						int fieldType = ff.getFieldType();
						if (fieldType == FormField.FIELD_TYPE_INT
								|| fieldType == FormField.FIELD_TYPE_FLOAT
								|| fieldType == FormField.FIELD_TYPE_DOUBLE
								|| fieldType == FormField.FIELD_TYPE_PRICE
								|| fieldType == FormField.FIELD_TYPE_LONG
						) {
							optsFieldsNum.append("<option value='" + ff.getName() + "'>" + ff.getTitle() + "</option>");
						}
					}

					int curCalcuFieldCount = 0;
					String propStat = StrUtil.getNullStr(vsd.getString("prop_stat"));
					if (propStat.equals("")) {
						propStat = "{}";
					}
					JSONObject jsonPropStat = new JSONObject(propStat);
					Iterator irPropStat = jsonPropStat.keys();
					while (irPropStat.hasNext()) {
						String key = (String) irPropStat.next();
				%>
				<div id="divCalcuField<%=curCalcuFieldCount%>" style="float:left">
					<select id="calcFieldCode<%=curCalcuFieldCount%>" name="calcFieldCode">
						<option value="">无</option>
						<%=optsFieldsNum.toString()%>
					</select>
					<select id="calcFunc<%=curCalcuFieldCount%>" name="calcFunc">
						<option value="0">求和</option>
						<option value="1">求平均值</option>
					</select>
					<a href='javascript:;' onclick="var pNode=this.parentNode; pNode.parentNode.removeChild(pNode);">×</a>
					&nbsp;
				</div>
				<script>
					$("#calcFieldCode<%=curCalcuFieldCount%>").val("<%=key%>");
					$("#calcFunc<%=curCalcuFieldCount%>").val("<%=jsonPropStat.get(key)%>");
				</script>
				<%
						curCalcuFieldCount++;
					}
				%>
				</div>
				<div class="text-center" style="clear: both">
					<button id="btnPropStat" class="btn btn-default">确定</button>
				</div>
			</td>
		</tr>
	</table>
</form>

<form id="formModuleFilter" method="post" name="frmFilter" id="frmFilter" onsubmit="return frmFilter_onsbumit()">
<table cellspacing="0" class="tabStyle_1 percent98" cellpadding="3" width="95%" align="center">
    <tr>
      <td align="center"  class="tabStyle_1_title">过滤条件</td>
    </tr>
    <tr>
      <td width="91%" align="left" >
<%
String filter = StrUtil.getNullStr(vsd.getString("filter")).trim();
boolean isComb = filter.startsWith("<items>") || filter.equals("");
String cssComb = "", cssScript = "";
String kind;
if (isComb) {
	cssComb = "in active";
	kind = "comb";
}
else {
	cssScript = "in active";
	kind = "script";
	%>
	<script>
	$(function() {
		$('#trOrderBy').hide();
	});
	</script>
	<%
}
%>
<ul id="myTab" class="nav nav-tabs">
   <li class="dropdown active">
      <a href="#" id="myTabDrop1" class="dropdown-toggle" data-toggle="dropdown">
         	条件<b class="caret"></b></a>
      <ul class="dropdown-menu" role="menu" aria-labelledby="myTabDrop1">
         <li><a href="#comb" kind="comb" tabindex="-1" data-toggle="tab">组合条件</a></li>
         <li><a href="#script" kind="script" tabindex="-1" data-toggle="tab">脚本条件</a></li>
      </ul>
   </li>
</ul>
<div id="myTabContent" class="tab-content">
   <div class="tab-pane fade <%=cssComb %>" id="comb">
   		<div style="margin:10px">
      		<img src="../admin/images/combination.png" style="margin-bottom:-5px;"/>&nbsp;<a href="javascript:;" onclick="openCondition(o('condition'), o('imgId'))">配置条件</a>&nbsp;
      		<img src="../admin/images/gou.png" style="margin-bottom:-5px;width:20px;height:20px;display:<%=(isComb && !filter.equals(""))?"":"none" %>;" id="imgId"/>
      		<textarea id="condition" name="condition" style="display:none" cols="80" rows="5"><%=filter %></textarea>
		</div>
   </div>
   <div class="tab-pane fade <%=cssScript %>" id="script">
      <textarea id="filter" name="filter" style="width:98%; height:200px"><%=StrUtil.HtmlEncode(filter)%></textarea>
      <br />
		字段：
        <select id="filterField" name="filterField" onchange="if (o('filterField').value!='') o('filter').value += o('filterField').value">
        <option value="">请选择字段</option>
		<%
        ir = v.iterator();
        while (ir.hasNext()) {
            FormField ff = (FormField) ir.next();
        %>
            <option value="<%=ff.getName()%>"><%=ff.getTitle()%></option>
        <%}%>
        </select>
        &nbsp;&nbsp;
      	<a href="javascript:;" onclick="o('filter').value += '{$request.key}';" title="从request请求中获取参数">request参数</a>
        &nbsp;&nbsp;
      	<a href="javascript:;" onclick="o('filter').value += ' {$curDate}';" title="当前日期">当前日期</a>
        &nbsp;&nbsp;
      	<a href="javascript:;" onclick="o('filter').value += ' ={$curUser}';" title="当前用户">当前用户</a>
        &nbsp;&nbsp;
      	<a href="javascript:;" onclick="o('filter').value += ' in ({$curUserDept})';" title="当前用户">当前用户所在的部门</a>
        &nbsp;&nbsp;        
      	<a href="javascript:;" onclick="o('filter').value += ' in ({$curUserRole})';" title="当前用户的角色">当前用户的角色</a>
        &nbsp;&nbsp;        
      	<a href="javascript:;" onclick="o('filter').value += ' in ({$admin.dept})';" title="用户可以管理的部门">当前用户管理的部门</a>
        &nbsp;&nbsp; 
        <span style="text-align:center">
      	<input type="button" value="设计器" class="btn btn-default" onclick="openIdeWin()" />
      	<br />
        (注：条件不能以and开头，可以直接输入条件，也可以使用脚本，脚本中必须返回ret)
      	</span>      
   </div>
</div>
      </td>
    </tr>
    <tr id="trOrderBy">
      <td align="left" >
      	排序字段
        <select id="orderby" name="orderby">
        <option value="">请选择字段</option>
			<option value="id">ID</option>
		<%
        ir = v.iterator();
        while (ir.hasNext()) {
            FormField ff = (FormField) ir.next();
        %>
            <option value="<%=ff.getName()%>"><%=ff.getTitle()%></option>
        <%}%>
        </select>      
        顺序
        <select id="sort" name="sort">
        <option value="desc">降序</option>
        <option value="asc">升序</option>
        </select>
        &nbsp;&nbsp;
		记录状态
        <select id="cws_status" name='cws_status'>
        <option value='<%=SQLBuilder.CWS_STATUS_NOT_LIMITED%>'>不限</option>
        <option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_DRAFT%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_DRAFT)%></option>
        <option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_NOT%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_NOT)%></option>
        <option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_DONE%>' selected><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_DONE)%></option>
        <option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_REFUSED%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_REFUSED)%></option>
        <option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_DISCARD%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_DISCARD)%></option>
        </select>     
        &nbsp;&nbsp;
        单位
        <select id="isUnitShow" name="isUnitShow" title="模块列表过滤条件中的单位下拉框">
        <option value="0">隐藏</option>
        <option value="1">显示</option>
        </select>
        默认
        <select id="unitCode" name="unitCode">
        <option value="-1">不限</option>
        <option value="0">本单位</option>
        </select>        
        <script>
		$(function() {
			$('#orderby').val("<%=vsd.getString("orderby")%>");
			$('#sort').val("<%=vsd.getString("sort")%>");
			$('#cws_status').val("<%=vsd.getInt("cws_status")%>");
			$('#isUnitShow').val("<%=vsd.getInt("is_unit_show")%>");
			$('#unitCode').val("<%=vsd.getInt("unit_code")%>");
		});
		</script>
      </td>
    </tr>
    <tr>
      <td align="center" ><input class="btn btn-default" type="submit" value="确定" />
        <input name="code" value="<%=code%>" type="hidden" />
        <input name="formCode" value="<%=formCode%>" type="hidden" />
      </td>
    </tr>
  </table>
</form>    
<br />
<form action="module_field_list.jsp?op=setPromptIcon" method="post" name="frmPromptIcon" id="frmPromptIcon">
	<table cellspacing="0" class="tabStyle_1 percent98" cellpadding="3" width="95%" align="center">
		<tr>
			<td colspan="3" class="tabStyle_1_title">行首图标</td>
		</tr>
		<tr>
			<td width="52%" align="right">当
				<select id="promptField" name="promptField">
					<option value="">无</option>
					<%
						ir = fd.getFields().iterator();
						while (ir.hasNext()) {
							FormField ff = (FormField) ir.next();
					%>
					<option value="<%=ff.getName()%>" fieldType="<%=ff.getFieldType()%>"><%=ff.getTitle()%>
					</option>
					<%
						}
					%>
				</select>
				<select id="promptCondNum" name="promptCond">
					<option value="=">=</option>
					<option value=">=">>=</option>
					<option value=">">></option>
					<option value="<=">&lt;=</option>
					<option value="&lt;"><</option>
				</select>
				<select id="promptCondStr" name="promptCond" disabled style="display:none">
					<option value="=">=</option>
					<option value="<>"><></option>
				</select>
				<script>
					$(function () {
						$('#promptField').change(function () {
							var fieldType = this.options[this.selectedIndex].getAttribute("fieldType");
							if (fieldType == <%=FormField.FIELD_TYPE_INT%> || fieldType == <%=FormField.FIELD_TYPE_FLOAT%>
									|| fieldType == <%=FormField.FIELD_TYPE_LONG%> || fieldType == <%=FormField.FIELD_TYPE_PRICE%> || fieldType == <%=FormField.FIELD_TYPE_DOUBLE%>
									|| fieldType == <%=FormField.FIELD_TYPE_DATE%> || fieldType ==<%=FormField.FIELD_TYPE_DATETIME%>) {
								$('#promptCondNum').show();
								$("#promptCondNum").attr("disabled", false);
								$('#promptCondStr').hide();
								$("#promptCondStr").attr("disabled", true);
							} else {
								$('#promptCondNum').hide();
								$("#promptCondNum").attr("disabled", true);
								$('#promptCondStr').show();
								$("#promptCondStr").attr("disabled", false);
							}
						});
					});
				</script>
				<input id="promptValue" name="promptValue" value="<%=StrUtil.HtmlEncode(StrUtil.getNullStr(vsd.getString("prompt_value")))%>"/>
				时，行首显示图标
			</td>
			<td width="23%">
				<%
					com.redmoon.forum.ui.FileViewer fileViewer = new com.redmoon.forum.ui.FileViewer(Global.getAppPath(request) + "images/prompt/");
					fileViewer.init();
				%>
				<select id="promptIcon" name="promptIcon" class="js-example-templating js-states form-control">
					<option value="">无</option>
					<%
						while (fileViewer.nextFile()) {
							if (fileViewer.getFileName().lastIndexOf("gif") != -1 || fileViewer.getFileName().lastIndexOf("jpg") != -1 || fileViewer.getFileName().lastIndexOf("png") != -1 || fileViewer.getFileName().lastIndexOf("bmp") != -1) {
								String fileName = fileViewer.getFileName();
					%>
					<option value="<%=fileName%>" style="background-image: url('<%=request.getContextPath()%>/images/prompt/<%=fileName%>');"><%=fileName %>
					</option>
					<%
							}
						}
					%>
				</select>
				<script>
					var mapPrompt = new Map();
					<%
                    fileViewer.init();
                    while(fileViewer.nextFile()) {
                          if (fileViewer.getFileName().lastIndexOf("gif") != -1 || fileViewer.getFileName().lastIndexOf("jpg") != -1 || fileViewer.getFileName().lastIndexOf("png") != -1 || fileViewer.getFileName().lastIndexOf("bmp") != -1) {
                            String fileName = fileViewer.getFileName();
                          %>
					mapPrompt.put('<%=fileName%>', '<%=request.getContextPath()%>/images/prompt/<%=fileName%>');
					<%
                  }
              }
              %>
					$(function () {
						$('#promptIcon').val("<%=StrUtil.getNullStr(vsd.getString("prompt_icon"))%>");
						$('#promptField').val("<%=StrUtil.getNullStr(vsd.getString("prompt_field"))%>");
						$('#promptCondNum').val("<%=StrUtil.getNullStr(vsd.getString("prompt_cond"))%>");
						$('#promptCondStr').val("<%=StrUtil.getNullStr(vsd.getString("prompt_cond"))%>");
						// 带图片
						$("#promptIcon").select2({
							templateResult: formatStatePrompt,
							templateSelection: formatStatePrompt
						});
					});

					function formatStatePrompt(state) {
						if (!state.id) {
							return state.text;
						}
						var $state = $(
								'<span><img src="' + mapPrompt.get(state.id).value + '" class="img-flag" /> ' + state.text + '</span>'
						);
						return $state;
					};
				</script>
			</td>
			<td width="25%" align="left">
				<input id="btnPrompt" class="btn btn-default" type="button" value="确定"/>
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
				<input name="code" value="<%=code%>" type="hidden"/>
				<script>
					$('#btnPrompt').click(function (e) {
						e.preventDefault();
						$.ajax({
							type: "post",
							url: "setPromptIcon",
							data: $('#frmPromptIcon').serialize(),
							dataType: "html",
							beforeSend: function (XMLHttpRequest) {
								$('body').showLoading();
							},
							success: function (data, status) {
								data = $.parseJSON(data);
								$.toaster({priority: 'info', message: data.msg});
							},
							complete: function (XMLHttpRequest, status) {
								$('body').hideLoading();
							},
							error: function (XMLHttpRequest, textStatus) {
								alert("error:" + XMLHttpRequest.responseText);
							}
						});
					})
				</script>
			</td>
		</tr>
	</table>
</form>
<br />
<table cellspacing="0" class="tabStyle_1 percent98" cellpadding="3" width="95%" align="center">
	<tr>
		<td class="tabStyle_1_title" width="13%">导航页签</td>
		<td colspan="3" class="tabStyle_1_title">链接</td>
		<td class="tabStyle_1_title" width="13%">顺序号</td>
		<td width="22%" class="tabStyle_1_title">操作</td>
	</tr>
	<%
		ModuleSetupDb msd = new ModuleSetupDb();
		v = msd.listUsed();
		ir = v.iterator();
		String jsonStr = "";
		while (ir.hasNext()) {
			msd = (ModuleSetupDb) ir.next();

			if (jsonStr.equals("")) {
				jsonStr = "{\"id\":\"" + msd.getString("code") + "\", \"name\":\"" + msd.getString("name") + "\"}";
			} else {
				jsonStr += ",{\"id\":\"" + msd.getString("code") + "\", \"name\":\"" + msd.getString("name") + "\"}";
			}

		}

		String nav_tag_name = StrUtil.getNullStr(vsd.getString("nav_tag_name"));
		String[] tags = StrUtil.split(nav_tag_name, ",");

		String nav_tag_order = StrUtil.getNullStr(vsd.getString("nav_tag_order"));
		String[] tagOrders = StrUtil.split(nav_tag_order, ",");

		String nav_tag_url = StrUtil.getNullStr(vsd.getString("nav_tag_url"));
		String[] tagUrls = StrUtil.split(nav_tag_url, ",");

		len = 0;
		if (tags != null) {
			len = tags.length;
		}
		for (i = 0; i < len; i++) {
			String tagName = tags[i];
	%>
	<form action="module_field_list.jsp?op=modifyTag" method="post" name="formTag<%=i%>" id="formTag<%=i%>">
		<tr id="trTag<%=i%>">
			<td align="center"><%=tagName%>
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
				<input name="code" value="<%=code%>" type="hidden"/>
				<input name="tagName" value="<%=tagName%>" type="hidden"/>
			</td>
			<td colspan="3">
				<%if (!tagUrls[i].startsWith("{")) {%>
				<input name="tagUrl" size="35" value="<%=tagUrls[i]%>"/>
				<%
				} else {
					JSONObject json = new JSONObject(tagUrls[i]);
					String tagModuleCode = json.getString("moduleCode");
					ModuleSetupDb tagMsd = new ModuleSetupDb();
					if (!StringUtils.isEmpty(tagModuleCode)) {
						tagMsd = tagMsd.getModuleSetupDb(tagModuleCode);
					}
				%>
				<div id="tagModuleSel<%=i%>"></div>
				<%
					String tagMsdName = "";
					if (tagMsd == null) {
						out.println("<span style='color:red'>模块:" + tagModuleCode + "不存在！</span>");
					} else {
						if (tagMsd.isLoaded()) {
							tagMsdName = tagMsd.getString("name");
						}
					}
				%>
				<input id="tagModuleCode<%=i%>" name="tagModuleCode" type="hidden" value="<%=tagModuleCode%>"/>
				<input name="tagType" value="module" type="hidden"/>
				<script>
					var tagModuleSel = $('#tagModuleSel<%=i%>').flexbox({
						"results": [<%=jsonStr%>],
						"total":<%=v.size()%>
					}, {
						initialValue: '<%=tagMsdName%>',
						watermark: '请选择模块',
						paging: false,
						width: 200,
						maxVisibleRows: 10,
						onSelect: function () {
							o("tagModuleCode<%=i%>").value = $("input[name=tagModuleSel<%=i%>]").val();
						}
					});
				</script>
				<%}%>
			</td>
			<td><input name="tagOrder" size="5" value="<%=tagOrders[i]%>"/></td>
			<td align="center">
				<input class="btn btn-default" type="button" onclick="modifyTag('<%=i%>')" value="修改"/>
				&nbsp;&nbsp;
				<input class="btn btn-default" name="button" type="button" onclick="delTag('<%=i%>')" value="删除"/>
			</td>
		</tr>
	</form>
	<%}%>
	<form action="module_field_list.jsp?op=addTag" method="post" name="formTag" id="formTag" onsubmit="if (o('tagNameAdd').value=='') {jAlert('名称不能为空！','提示'); return false;}">
		<tr>
			<td colspan="3" align="right" style="PADDING-LEFT: 10px">
				名称
				<span style="margin-bottom:10px;">
        <input id="tagNameAdd" name="tagNameAdd"/>
        <select id="tagType" name="tagType">
          <option value="module">模块</option>
          <option value="link">链接</option>
        </select>
        <script>
		$(function () {
			$('#tagType').change(function () {
				if ($(this).val() == "module") {
					$('#tagModuleSel').show();
					$('#tagUrl').hide();
				} else {
					$('#tagModuleSel').hide();
					$('#tagUrl').show();
				}
			});
		});
		</script>
      </span>
			</td>
			<td width="24%" align="left" style="PADDING-LEFT: 10px">
				<input id="tagUrl" name="tagUrl" style="display:none"/>
				<div id="tagModuleSel"></div>
				<input id="tagModuleCode" name="tagModuleCode" type="hidden"/>
				<script>
					var tagModuleSel = $('#tagModuleSel').flexbox({
						"results": [<%=jsonStr%>],
						"total":<%=v.size()%>
					}, {
						initialValue: '',
						watermark: '请选择模块',
						paging: false,
						width: 200,
						maxVisibleRows: 10,
						onSelect: function () {
							o("tagModuleCode").value = $("input[name=tagModuleSel]").val();
							o("tagNameAdd").value = $("#tagModuleSel").find(".ffb-sel").eq(0).text();
						}
					});
				</script>
			</td>
			<td align="left">
				<input name="tagOrder" size="5" value="<%=tags!=null?StrUtil.toDouble(tagOrders[i-1])+1:1%>"/>
				<input name="formCode" value="<%=formCode%>" type="hidden"/>
				<input name="code" value="<%=code%>" type="hidden"/></td>
			<td align="center" style="PADDING-LEFT: 10px"><input id="btnTagAdd" type="button" class="btn btn-default" value="添加"/></td>
		</tr>
	</form>
</table>
<script>
	function delTag(index) {
		jConfirm('您确定要删除么？', '提示', function (r) {
			if (!r) {
				return;
			} else {
				$.ajax({
					type: "post",
					url: "delTag",
					data: $('#formTag' + index).serialize(),
					dataType: "html",
					beforeSend: function (XMLHttpRequest) {
						$('body').showLoading();
					},
					success: function (data, status) {
						data = $.parseJSON(data);
						$.toaster({priority: 'info', message: data.msg});
						if (data.ret==1) {
							$('#trTag' + index).remove();
						}
					},
					complete: function (XMLHttpRequest, status) {
						$('body').hideLoading();
					},
					error: function (XMLHttpRequest, textStatus) {
						alert("error:" + XMLHttpRequest.responseText);
					}
				});
			}
		})
	}

	function modifyTag(index) {
		$.ajax({
			type: "post",
			url: "modifyTag",
			data: $('#formTag' + index).serialize(),
			dataType: "html",
			beforeSend: function (XMLHttpRequest) {
				$('body').showLoading();
			},
			success: function (data, status) {
				data = $.parseJSON(data);
				$.toaster({priority: 'info', message: data.msg});
			},
			complete: function (XMLHttpRequest, status) {
				$('body').hideLoading();
			},
			error: function (XMLHttpRequest, textStatus) {
				alert("error:" + XMLHttpRequest.responseText);
			}
		});
	}

	$(function() {
		$('#btnTagAdd').click(function(e) {
			e.preventDefault();
			$.ajax({
				type: "post",
				url: "addTag",
				data: $('#formTag').serialize(),
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					if (data.ret==1) {
						jAlert(data.msg, '提示', function() {
							window.location.reload();
						})
					}
					else {
						jAlert(data.msg, '提示');
					}
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					alert("error:" + XMLHttpRequest.responseText);
				}
			});
		});
	})
</script>
<br />
<table cellspacing="0" class="tabStyle_1 percent98" cellpadding="3" width="95%" align="center">
  <tr>
    <td class="tabStyle_1_title" width="9%">名称</td>
    <td width="46%" class="tabStyle_1_title">操作列链接</td>
    <td class="tabStyle_1_title" width="24%">链接可见角色</td>
    <td class="tabStyle_1_title" width="7%">顺序号</td>
    <td width="14%" class="tabStyle_1_title">操作</td>
  </tr>
  <%
String op_link_name = StrUtil.getNullStr(vsd.getString("op_link_name"));
String[] linkNames = StrUtil.split(op_link_name, ",");

String op_link_order = StrUtil.getNullStr(vsd.getString("op_link_order"));
String[] linkOrders = StrUtil.split(op_link_order, ",");

String op_link_url = StrUtil.getNullStr(vsd.getString("op_link_url"));
String[] linkHrefs = StrUtil.split(op_link_url, ",");

String op_link_field = StrUtil.getNullStr(vsd.getString("op_link_field"));
String[] linkFields = StrUtil.split(op_link_field, ",");
String op_link_cond = StrUtil.getNullStr(vsd.getString("op_link_cond"));
String[] linkConds = StrUtil.split(op_link_cond, ",");
String op_link_value = StrUtil.getNullStr(vsd.getString("op_link_value"));
String[] linkValues = StrUtil.split(op_link_value, ",");
String op_link_event = StrUtil.getNullStr(vsd.getString("op_link_event"));
String[] linkEvents = StrUtil.split(op_link_event, ",");
String op_link_role = StrUtil.getNullStr(vsd.getString("op_link_role"));
String[] linkRoles = StrUtil.split(op_link_role, "#");
if (linkNames!=null && linkRoles==null) {
	linkRoles = new String[linkNames.length];
	for (i=0; i<linkNames.length; i++) {
		linkRoles[i] = "";
	}
}

com.redmoon.oa.flow.Leaf rootlf = new com.redmoon.oa.flow.Leaf();
rootlf = rootlf.getLeaf(com.redmoon.oa.flow.Leaf.CODE_ROOT);
com.redmoon.oa.flow.DirectoryView flowdv = new com.redmoon.oa.flow.DirectoryView(rootlf);

len = 0;
if (linkNames!=null)
	len = linkNames.length;
for (i=0; i<len; i++) {
	String linkName = linkNames[i];
	
	String linkField = linkFields[i];
	String linkCond = linkConds[i];
	String linkValue = linkValues[i];
	String linkEvent = linkEvents[i];
	String linkRole = linkRoles[i];
	
	if (linkField.equals("#")) {
		linkField = "";
	}
	if (linkCond.equals("#")) {
		linkCond = "";
	}
	if (linkValue.equals("#")) {
		linkValue = "";
	}
	if (linkEvent.equals("#")) {
		linkEvent = "";
	}
	int m = i+1;
	%>
  <form action="module_field_list.jsp?op=modifyLink" method="post" name="formLink<%=i%>" id="formLink<%=i%>">
    <tr id="trLink<%=i %>">
      <td align="center"><%=linkName%>
          <input name="formCode" value="<%=formCode%>" type="hidden" />
          <input name="code" value="<%=code%>" type="hidden" />          
          <input name="linkName" value="<%=linkName%>" type="hidden" /></td>
      <td>
      <%
		  boolean isCombCond = true; // 是否为组合条件
		  if (!linkField.startsWith("<items>") && !"".equals(linkField)) {
			  out.print(linkField + linkCond + linkValue);
			  isCombCond = false;
		  }
		  else {
			  // System.out.println(getClass() + " linkField=" + linkField);
		  %>
            <img src="../admin/images/combination.png" style="margin-bottom:-5px;"/>
            <a href="javascript:;" onclick="openCondition(o('linkConds<%=i%>'), o('imgConds<%=i%>'))" title="当满足条件时，显示链接">配置条件</a>
            <span style="margin:10px">
            <img src="../admin/images/gou.png" style="margin-bottom:-5px;width:20px;height:20px;<%="".equals(linkField)?"display:none":""%>" id="imgConds<%=i%>"/>
            </span>
            <textarea id="linkConds<%=i%>" name="linkFieldCond" style="display:none"><%=linkField%></textarea>
		  <%
	  }
	  %>
      <%if (linkEvent.equals("flow")) {%>
      	发起流程
      	<%
		try {
			JSONObject json = new JSONObject(StrUtil.decodeJSON(linkHrefs[i]));
			com.redmoon.oa.flow.Leaf lf = new com.redmoon.oa.flow.Leaf();
			lf = lf.getLeaf(json.getString("flowTypeCode"));
			FormDb fdFlow = new FormDb();
			if (lf!=null) {
				fdFlow = fdFlow.getFormDb(lf.getFormCode());
			}
			String params = json.getString("params");
            %>
          <select id="flowTypeCode<%=m%>" name="flowTypeCode">
              <%
                  flowdv.ShowDirectoryAsOptions(request, out, rootlf, rootlf.getLayer());
              %>
          </select>
          <script>
              $(function() {
                  $('#flowTypeCode<%=m%>').val('<%=lf.getCode()%>');
              })
          </script>
            <textarea id="params<%=m%>" name="params" style="display: none;"><%=params%></textarea>
		  	<a href="javascript:;" onclick="editMap(<%=m%>)"><i class="fa fa-cog" style="margin-right:5px"></i>映射字段</a>
            <%
		}
		catch( JSONException e ) {
			e.printStackTrace();
		}
		%>
      	<input name="linkEvent" type="hidden" value="flow"/>
      	<input name="linkHref" type="hidden" value="<%=StrUtil.HtmlEncode(linkHrefs[i])%>" />
      <%}else{%>
       	事件
      <select id="linkEvent" name="linkEvent">
          <option value="link">链接</option>
          <option value="click">点击</option>
          <!--<option value="flow">发起流程</option> 编辑时，不能选“发起流程”-->
      </select>
      <input name="linkHref" size="30" value="<%=StrUtil.HtmlEncode(StrUtil.decodeJSON(linkHrefs[i]))%>" />
	  <%}%>
	  <script>
	  $(function() {
	  	  // 因为form的写法不合规范，所以不能用$("#formLink<%=i%> select[name='linkField']")来获取
		  $("#trLink<%=i%> select[name='linkEvent']").val("<%=linkEvent%>");
	  });
	  </script>
      </td>
      <td align="center">
      <%
	  	String roleCodes = "", descs = "";
	  	String roles = linkRoles[i];
		String[] roleAry = StrUtil.split(roles, ",");
		if (roleAry!=null) {
			for (int k=0; k<roleAry.length; k++) {
				RoleDb rd = new RoleDb();
				rd = rd.getRoleDb(roleAry[k]);
				String roleCode = rd.getCode();
				String desc = rd.getDesc();
				if (roleCodes.equals("")) {
					roleCodes += roleCode;
				} else {
					roleCodes += "," + roleCode;
				}
				if (descs.equals("")) {
					descs += desc;
				} else {
					descs += "," + desc;
				}
			}	 
		}      
		%>
        <textarea title="为空则表示角色不限，均可以看见此按钮" id="roleDescsLinkAdd<%=i%>" name="roleDescs" style="width:80%; height:40px" readonly="readonly"><%=descs %></textarea>
        <input id="roleCodesLinkAdd<%=i%>" name="roleCodesLink" type="hidden" value="<%=roleCodes %>" />
		<a href="javascript:;" onclick="selRoles('LinkAdd<%=i%>')"><img title="选择角色" class="role-sel-btn" src="../images/role_sel.png" /></a>
      </td>
      <td align="center"><input name="linkOrder" size="5" value="<%=linkOrders[i]%>" /></td>
      <td align="center">
		  <%if (isCombCond) {%>
		  <input class="btn btn-default" type="button" value="修改" onclick="submitModifyFormLink('<%=i%>')" />
		  <%}%>
        &nbsp;&nbsp;
        <input class="btn btn-default" name="button" type="button" onclick="delLink('<%=linkName%>', <%=i%>)" value="删除" />      </td>
    </tr>
  </form>
	<script>
		function delLink(linkName, i) {
			jConfirm('您确定要删除么？', '提示', function (r) {
				if (!r) {
					return;
				} else {
					jConfirm('您确定要删除么？', '提示', function (r) {
						if (!r) {
							return;
						} else {
							$.ajax({
								type: "post",
								url: "linkDel.do",
								contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
								data: {
									linkName: linkName,
									code: "<%=code%>",
									formCode: "<%=formCode%>"
								},
								dataType: "html",
								beforeSend: function (XMLHttpRequest) {
									$('body').showLoading();
								},
								success: function (data, status) {
									data = $.parseJSON(data);
									if (data.ret == "1") {
										jAlert(data.msg, "提示", function () {
											$('#trLink' + i).remove();
										});
									} else {
										jAlert(data.msg, "提示");
									}
								},
								complete: function (XMLHttpRequest, status) {
									$('body').hideLoading();
								},
								error: function (XMLHttpRequest, textStatus) {
									// 请求出错处理
									alert(XMLHttpRequest.responseText);
								}
							});
						}
					})
				}
			})
		}
	</script>
  <%
	}

	  msd = msd.getModuleSetupDb(code);
	  String tName = StrUtil.getNullStr(msd.getString("op_link_name"));
	  String tUrl = StrUtil.getNullStr(msd.getString("op_link_url"));
	  String tOrder = StrUtil.getNullStr(msd.getString("op_link_order"));
	  String tField = StrUtil.getNullStr(msd.getString("op_link_field"));
	  String tCond = StrUtil.getNullStr(msd.getString("op_link_cond"));
	  String tValue = StrUtil.getNullStr(msd.getString("op_link_value"));
	  String tEvent = StrUtil.getNullStr(msd.getString("op_link_event"));
	  String tRole = StrUtil.getNullStr(msd.getString("op_link_role"));
  %>
    <script>
		function submitModifyFormLink(i) {
			<%
			if (isServerConnectWithCloud) {
			%>
			$.ajax({
				type: "post",
				url: "linkModify.do",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				data: $('#formLink' + i).serialize(),
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					jAlert(data.msg, "提示");
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					alert(XMLHttpRequest.responseText);
				}
			});
			<%
			}else {
			%>
			var we = o("webedit");
			we.PostScript = "<%=path%>/public/module/modifyLink.do";

			loadDataToWebeditCtrl(o("formLink" + i), o("webedit"));
			we.AddField("cwsVersion", "<%=cfg.get("version")%>");

			we.AddField("tName", "<%=tName%>");
			we.AddField("tUrl", "<%=tUrl%>");
			we.AddField("tOrder", "<%=tOrder%>");
			we.AddField("tField", "<%=tField.replaceAll("\"", "\\\\\"")%>");
			we.AddField("tCond", "<%=tCond%>");
			we.AddField("tValue", "<%=tValue%>");
			we.AddField("tEvent", "<%=tEvent%>");
			we.AddField("tRole", "<%=tRole%>");
			we.UploadToCloud();

			var data = $.parseJSON(o("webedit").ReturnMessage);
			if (data.ret=="1") {
				$.ajax({
					type: "post",
					url: "linkSave.do",
					contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
					data: {
						code: "<%=code%>",
						formCode: "<%=formCode%>",
						result: JSON.stringify(data.result)
					},
					dataType: "html",
					beforeSend: function (XMLHttpRequest) {
						$('body').showLoading();
					},
					success: function (data, status) {
						data = $.parseJSON(data);
						jAlert(data.msg, "提示");
					},
					complete: function (XMLHttpRequest, status) {
						$('body').hideLoading();
					},
					error: function (XMLHttpRequest, textStatus) {
						// 请求出错处理
						alert(XMLHttpRequest.responseText);
					}
				});
			}
			else {
				jAlert(data.msg, "提示");
			}
			<%
			}
			%>
		}

        var curM;
        var curParamId;
        function getMaps() {
            return $('#params' + curM).val();
        }
        function editMap(m) {
            curM = m;
			curParamId = "params" + m;
            openWin('../flow/form_data_map.jsp?formCode=<%=formCode%>&flowTypeCode=' + $('#flowTypeCode' + m).val(), 800, 600);
        }
    </script>
  <form action="module_field_list.jsp?op=addLink" method="post" name="formLink" id="formLink" onsubmit="if (o('linkNameAdd').value=='') {jAlert('名称不能为空！','提示'); return false;}">
    <tr >
      <td colspan="2" align="center" style="PADDING-LEFT: 10px">
<img src="../admin/images/combination.png" style="margin-bottom:-5px;"/>
<a href="javascript:;" onclick="openCondition(o('linkCondsAdd'), o('imgCondsAdd'))" title="当满足条件时，显示链接">配置条件</a>
<span style="margin:10px">
<img src="../admin/images/gou.png" style="margin-bottom:-5px;width:20px;height:20px;display:none" id="imgCondsAdd"/>
</span>
<textarea id="linkCondsAdd" name="linkFieldCond" style="display:none"></textarea>
名称
<input id="linkNameAdd" name="linkName" size="10" />
事件
<select id="linkEventeAdd" name="linkEvent">
  <option value="link">链接</option>
  <option value="click">点击</option>
  <option value="flow">发起流程</option>
</select>
<input id="linkHref" name="linkHref" title="注：点击事件方法中如有双引号将会被自动替换为单引号" />
        <div id="divFlow" style="display:none">
          <select id="flowTypeCodeAdd" name="flowTypeCode">
        <%
        flowdv.ShowDirectoryAsOptions(request, out, rootlf, rootlf.getLayer());
        %>
          </select>
			<input id="paramsAdd" name="params" type="hidden"/>
          	<a href="javascript:;" id="btnFlowMap"><i class="fa fa-cog" style="margin-right:5px"></i>映射字段</a>
			<script>
				$(function () {
					$('#linkEventeAdd').change(function () {
						if ($(this).val() == 'flow') {
							$('#divFlow').show();
							$('#linkHref').hide();
						} else {
							$('#divFlow').hide();
							$('#linkHref').show();
						}
					});

					$('#btnFlowMap').click(function () {
						if ($('#flowTypeCodeAdd').val() == 'not') {
							jAlert('请选择流程！', '提示');
							return;
						}
						curParamId = "paramsAdd";
						openWin('../flow/form_data_map.jsp?formCode=<%=formCode%>&flowTypeCode=' + $('#flowTypeCodeAdd').val(), 800, 600);
					})
				});

				function setSequence(mapJson) {
					$('#' + curParamId).val(mapJson);
				}
			</script>
      </div>
</td>
      <td align="center"><textarea title="为空则表示角色不限，均可以看见此按钮" id="roleDescsLinkAdd" name="roleDescsLink" style="width:80%; height:40px" readonly="readonly"></textarea>
        <input id="roleCodesLinkAdd" name="roleCodesLink" type="hidden" />
	  	<a href="javascript:" onclick="selRoles('LinkAdd')"><img title="选择角色" class="role-sel-btn" src="../images/role_sel.png" /></a>
	  </td>
      <td align="center"><input name="linkOrder" size="5" value="<%=linkNames!=null?StrUtil.toDouble(linkOrders[i-1])+1:1%>" />
        <input name="formCode" value="<%=formCode%>" type="hidden" />
      <input name="code" value="<%=code%>" type="hidden" /></td>
      <td align="center" style="PADDING-LEFT: 10px"><input class="btn btn-default" type="button" value="添加" onclick="submitAddFormLink()" /></td>
    </tr>
  </form>
</table>
<script>
	function submitAddFormLink() {
		<%
        if (isServerConnectWithCloud) {
        %>
		$.ajax({
			type: "post",
			url: "linkAdd.do",
			contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
			data: $('#formLink').serialize(),
			dataType: "html",
			beforeSend: function (XMLHttpRequest) {
				$('body').showLoading();
			},
			success: function (data, status) {
				data = $.parseJSON(data);
				if (data.ret=="1") {
					jAlert(data.msg, "提示", function() {
						window.location.reload();
					});
				}
				else {
					jAlert(data.msg, "提示");
				}
			},
			complete: function (XMLHttpRequest, status) {
				$('body').hideLoading();
			},
			error: function (XMLHttpRequest, textStatus) {
				// 请求出错处理
				alert(XMLHttpRequest.responseText);
			}
		});
		<%
        } else {
        %>

		var we = o("webedit");
		we.PostScript = "<%=path%>/public/module/addLink.do";

		loadDataToWebeditCtrl(o("formLink"), o("webedit"));
		we.AddField("cwsVersion", "<%=cfg.get("version")%>");

		we.AddField("tName", "<%=tName%>");
		we.AddField("tUrl", "<%=tUrl%>");
		we.AddField("tOrder", "<%=tOrder%>");
		we.AddField("tField", "<%=tField.replaceAll("\"", "\\\\\"")%>");
		we.AddField("tCond", "<%=tCond%>");
		we.AddField("tValue", "<%=tValue%>");
		we.AddField("tEvent", "<%=tEvent%>");
		we.AddField("tRole", "<%=tRole%>");
		we.UploadToCloud();

		// console.log(we.ReturnMessage);
		var data = $.parseJSON(we.ReturnMessage);
		if (data.ret=="1") {
			$.ajax({
				type: "post",
				url: "linkSave.do",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				data: {
					code: "<%=code%>",
					formCode: "<%=formCode%>",
					result: JSON.stringify(data.result)
				},
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					if (data.ret=="1") {
						jAlert(data.msg, "提示", function() {
							window.location.reload();
						});
					}
					else {
						jAlert(data.msg, "提示");
					}
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					alert(XMLHttpRequest.responseText);
				}
			});
		}
		else {
			jAlert(data.msg, "提示");
		}
		<%
        }
        %>
	}
</script>
<br />
<table cellspacing="0" class="tabStyle_1 percent98" cellpadding="3" width="95%" align="center">
  <tr>
    <td class="tabStyle_1_title"  width="11%">按钮名称</td>
    <td class="tabStyle_1_title"  width="36%">脚本</td>
    <td class="tabStyle_1_title"  width="26%">可见角色</td>
    <td class="tabStyle_1_title"  width="5%">顺序号</td>
    <td class="tabStyle_1_title"  width="9%">样式</td>
    <td width="13%"  class="tabStyle_1_title">操作</td>
  </tr>
<%
String btn_name = StrUtil.getNullStr(vsd.getString("btn_name"));
String[] btnNames = StrUtil.split(btn_name, ",");

String btn_order = StrUtil.getNullStr(vsd.getString("btn_order"));
String[] btnOrders = StrUtil.split(btn_order, ",");

String btn_script = StrUtil.getNullStr(vsd.getString("btn_script"));
String[] btnScripts = StrUtil.split(btn_script, "#");
if (btn_script.replaceAll("#", "").equals("")) {
	btnScripts = null;
}
if (btnNames!=null && btnScripts==null) {
	btnScripts = new String[btnNames.length];
	for (i=0; i<btnNames.length; i++) {
		btnScripts[i] = "";
	}
}

String btn_role = StrUtil.getNullStr(vsd.getString("btn_role"));
String[] btnRoles = StrUtil.split(btn_role, "#");
if (btn_role.replaceAll("#", "").equals("")) {
	btnRoles = null;
}
if (btnNames!=null && btnRoles==null) {
	btnRoles = new String[btnNames.length];
	for (i=0; i<btnNames.length; i++) {
		btnRoles[i] = "";
	}
}

String btn_bclass = StrUtil.getNullStr(vsd.getString("btn_bclass"));
String[] btnBclasses = StrUtil.split(btn_bclass, ",");
// 为了与以前的版本兼容,bluewind20140420
if (btnNames!=null) {
	if (btnBclasses==null || (btnBclasses.length!=btnNames.length)) {
		btnBclasses = new String[btnNames.length];
		for (i=0; i<btnNames.length; i++) {
			btnBclasses[i] = "";
		}
	}
}

boolean hasCond = false;
len = 0;
if (btnNames!=null) {
	len = btnNames.length;
}
for (i=0; i<len; i++) {
	String btnName = btnNames[i];
	boolean isCond = false;
	JSONObject json = null;
	if (btnScripts[i].startsWith("{")) {
		json = new JSONObject(btnScripts[i]);		
		if (json.getString("btnType").equals("queryFields")) {
			continue;
		}
	}
	%>
  <form action="module_field_list.jsp?op=modifyBtn" method="post" name="formBtn<%=i%>" id="formBtn<%=i%>">
    <tr id="tr_btn_<%=btnName%>">
      <td align="center"><%=btnName%>
          <input name="formCode" value="<%=formCode%>" type="hidden" />
          <input name="code" value="<%=code%>" type="hidden" />
          <input name="btnName" value="<%=btnName%>" type="hidden" />
      <td>
      <%
	  // 非查询
	  // System.out.println(getClass() + " btnScripts[i]=" + btnScripts[i]);
	  if (!btnScripts[i].startsWith("{")) {%>
      	<textarea name="btnScript" style="width:100%" rows="2"><%=btnScripts[i].replaceAll("/\\*\\*/", "")%></textarea>
      <%}else{
		if (json.getString("btnType").equals("batchBtn")) {
			String batchField = json.getString("batchField");
			String batchValue = json.getString("batchValue");
			%>
			<div>
           	 置
            <select id="batchField<%=i%>" name="batchField">
			<%
            ir = fd.getFields().iterator();
            while (ir.hasNext()) {
                FormField ff = (FormField) ir.next();
            %>
                <option value="<%=ff.getName()%>"><%=ff.getTitle()%></option>
            <%
            }
            %>              
            </select>
                                 为
            <input id="batchValue<%=i%>" name="batchValue" value="<%=batchValue%>" />
            <script>
			o("batchField<%=i%>").value = "<%=batchField%>";
			</script>
            </div>
			<%
		}
		else if (json.getString("btnType").equals("flowBtn")) {
			String flowTypeCode = json.getString("flowTypeCode");
			%>
			<span>
				流程
				  <select id="btnFlowTypeCode<%=i%>" name="flowTypeCode">
					  <%
						  flowdv.ShowDirectoryAsOptions(request, out, rootlf, rootlf.getLayer());
					  %>
				  </select>
			</span>
			<script>
				o("btnFlowTypeCode<%=i%>").value = "<%=flowTypeCode%>";
			</script>`
			</span>
		<%
				}
		else {
		  	isCond = true;
		}		
	  }
	  %>
      </td>
      <td align="center">
      <%
	  if (!isCond) {
	  	String roleCodes = "", descs = "";
	  	String roles = btnRoles[i];
		String[] roleAry = StrUtil.split(roles, ",");
		if (roleAry!=null) {
			for (int k=0; k<roleAry.length; k++) {
				RoleDb rd = new RoleDb();
				rd = rd.getRoleDb(roleAry[k]);
				String roleCode = rd.getCode();
				String desc = rd.getDesc();
				if (roleCodes.equals("")) {
					roleCodes += roleCode;
				} else {
					roleCodes += "," + roleCode;
				}
				if (descs.equals("")) {
					descs += desc;
				} else {
					descs += "," + desc;
				}
			}	 
		}
	  %>
        <textarea title="为空则表示角色不限，均可以看见此按钮" style="width:80%; height:40px" id="roleDescs<%=i%>" name="roleDescs" readonly="readonly"><%=descs%></textarea>
        <input id="roleCodes<%=i%>" name="roleCodes" value="<%=roleCodes%>" type=hidden />
		<a href="javascript:;" onclick="selRoles('<%=i%>')"><img title="选择角色" class="role-sel-btn" src="../images/role_sel.png" /></a>
      <%}%>   
      </td>
      <td align="center"><input name="btnOrder" size="5" value="<%=btnOrders[i]%>" /></td>
      <td align="center">
      <%if (!btnScripts[i].startsWith("{") || (btnScripts[i].startsWith("{") && !isCond)) {%>      
      <select id="btnBclass<%=i %>" name="btnBclass" class="js-example-templating js-states form-control">
      <%
      ArrayList<String[]> btnAry = CSSUtil.getFlexigridBtn();
      int btnAryLen = btnAry.size();
      for (int k=0; k<btnAryLen; k++) {
      	String[] ary = btnAry.get(k);
      	String selected = "";
      	if (btnBclasses[i].equals(ary[0])) {
      		selected = "selected";
      	}
      	%>
      	<option value="<%=ary[0] %>" <%=selected %> style="background-image: url('<%=SkinMgr.getSkinPath(request)%>/flexigrid/<%=ary[1] %>');"><%=ary[0]%></option>
      	<%
      }
      %>
      </select>      
      <script>
		$(function () {
		    //带图片
		    $("#btnBclass<%=i%>").select2({
		        templateResult: formatState,
		        templateSelection: formatState
		    });
		});      
      </script>
      <%}else{%>
          <input type="hidden" name="btnBclass" size="5" value="<%=btnBclasses[i]%>" />
          查询
      <%}%>
      </td>
      <td align="center"><input class="btn btn-default" type="button" value="修改" onclick="submitModifyBtn('formBtn<%=i%>')" />
        &nbsp;&nbsp;
        <input class="btn btn-default" name="button" type="button" onclick="delBtn('<%=btnName%>')" value="删除" />      </td>
    </tr>
  </form>
	<script>
		function submitModifyBtn(formId) {
			<%
            if (isServerConnectWithCloud) {
            %>
			$.ajax({
				type: "post",
				url: "btnModify.do",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				data: $('#' + formId).serialize(),
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					jAlert(data.msg, "提示");
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					alert(XMLHttpRequest.responseText);
				}
			});
			<%
            }else {
            	String tNameBtn = StrUtil.getNullStr(msd.getString("btn_name"));
				String tOrderBtn = StrUtil.getNullStr(msd.getString("btn_order"));
				String tScriptBtn = StrUtil.getNullStr(msd.getString("btn_script"));
				String tBclassBtn = StrUtil.getNullStr(msd.getString("btn_bclass"));
				String tRoleBtn = StrUtil.getNullStr(msd.getString("btn_role"));
            %>
			var we = o("webedit");
			we.PostScript = "<%=path%>/public/module/modifyBtn.do";

			loadDataToWebeditCtrl(o(formId), o("webedit"));
			we.AddField("cwsVersion", "<%=cfg.get("version")%>");
			we.AddField("tName", "<%=tNameBtn%>");
			we.AddField("tOrder", "<%=tOrderBtn%>");
			we.AddField("tScript", "<%=tScriptBtn.replaceAll("\"", "\\\\\"")%>");
			we.AddField("tBclass", "<%=tBclassBtn%>");
			we.AddField("tRole", "<%=tRoleBtn%>");
			we.UploadToCloud();

			var data = $.parseJSON(o("webedit").ReturnMessage);
			if (data.ret == "1") {
				$.ajax({
					type: "post",
					url: "btnSave.do",
					contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
					data: {
						code: "<%=code%>",
						formCode: "<%=formCode%>",
						result: JSON.stringify(data.result)
					},
					dataType: "html",
					beforeSend: function (XMLHttpRequest) {
						$('body').showLoading();
					},
					success: function (data, status) {
						data = $.parseJSON(data);
						jAlert(data.msg, "提示");
					},
					complete: function (XMLHttpRequest, status) {
						$('body').hideLoading();
					},
					error: function (XMLHttpRequest, textStatus) {
						// 请求出错处理
						alert(XMLHttpRequest.responseText);
					}
				});
			} else {
				jAlert(data.msg, "提示");
			}
			<%
            }
            %>
		}

		function delBtn(btnName) {
			jConfirm('您确定要删除么？', '提示', function (r) {
				if (!r) {
					return;
				} else {
					$.ajax({
						type: "post",
						url: "btnDel.do",
						contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
						data: {
							btnName: btnName,
							code: "<%=code%>",
							formCode: "<%=formCode%>"
						},
						dataType: "html",
						beforeSend: function (XMLHttpRequest) {
							$('body').showLoading();
						},
						success: function (data, status) {
							data = $.parseJSON(data);
							if (data.ret == "1") {
								jAlert(data.msg, "提示", function () {
									$('#tr_btn_' + btnName).remove();
								});
							} else {
								jAlert(data.msg, "提示");
							}
						},
						complete: function (XMLHttpRequest, status) {
							$('body').hideLoading();
						},
						error: function (XMLHttpRequest, textStatus) {
							// 请求出错处理
							alert(XMLHttpRequest.responseText);
						}
					});
				}
			})
		}
	</script>
  <%}%>
  <form action="module_field_list.jsp" method="post" name="formBtn" id="formBtn" onsubmit="if (getRadioValue('btnBatchOrScript')=='0') {$('#opAddBtn').val('addBtnBatch');} else {$('#opAddBtn').val('addBtn')}">
    <tr >
      <td align="center"><input id="btnName" name="btnName" size="8" />
      <input id="opAddBtn" name="op" type="hidden" value="addBtn" />
      </td>
      <td>
		  <div style="margin-bottom:10px;">
			  <input type="radio" name="btnBatchOrScript" value="0" checked/>
			  &nbsp;批处理
			  <input type="radio" name="btnBatchOrScript" value="1"/>&nbsp;脚本
			  <input type="radio" name="btnBatchOrScript" value="2"/>&nbsp;流程
		  </div>
      <span id="spanBatch">
      置
      <select id="batchField" name="batchField">
<%
ir = fd.getFields().iterator();
while (ir.hasNext()) {
	FormField ff = (FormField) ir.next();
%>
        <option value="<%=ff.getName()%>"><%=ff.getTitle()%></option>
<%
}
%>     
      </select>
      为
      <input id="batchValue" name="batchValue" />
      </span>
      <span id="spanScript" style="display:none">
      <textarea id="btnScript" name="btnScript" cols="50" rows="2"></textarea>
      </span>
		  <span id="spanFlow" style="display:none">
			  <select id="btnFlowTypeCode" name="flowTypeCode">
				  <%
					  flowdv.ShowDirectoryAsOptions(request, out, rootlf, rootlf.getLayer());
				  %>
			  </select>
		  </span>
      <script>
	  $('input[name=btnBatchOrScript]').click(function() {
		  if ($(this).val()==0) {
			  $('#spanBatch').show();
			  $('#spanScript').hide();
			  $('#spanFlow').hide();
		  }
		  else if ($(this).val() == 2) {
			  $('#spanFlow').show();
			  $('#spanBatch').hide();
			  $('#spanScript').hide();
		  }
		  else {
			  $('#spanScript').show();
			  $('#spanFlow').hide();
			  $('#spanBatch').hide();
		  }
	  });
	  </script>
      </td>
      <td align="center">
        <textarea title="为空则表示角色不限，均可以看见此按钮" id="roleDescsAdd" name="roleDescs" style="width:80%; height:40px" readonly="readonly"></textarea>
        <input id="roleCodesAdd" name="roleCodes" type="hidden" />
		<a href="javascript:;" onclick="selRoles('Add')"><img title="选择角色" class="role-sel-btn" src="../images/role_sel.png" /></a>
        <script>
        var objCode, objDesc;
        function selRoles(param) {
        	var descId = "roleDescs" + param;
        	var codeId = "roleCodes" + param;
        	objCode = o(codeId);
        	objDesc = o(descId);
        	openWin('../role_multi_sel.jsp?roleCodes=' + objCode.value + '&unitCode=<%=StrUtil.UrlEncode(privilege.getUserUnitCode(request))%>', 526, 435);
        }
        
		function setRoles(roles, descs) {
			objCode.value = roles;
			objDesc.value = descs;
		}        
        </script>
      </td>
      <td align="center"><input name="btnOrder" size="5" value="<%=btnNames!=null?StrUtil.toDouble(btnOrders[i-1])+1:1%>" /></td>
      <td align="center">
      <select id="btnBclassAdd" name="btnBclass" class="js-example-templating js-states form-control">
      <%
      ArrayList<String[]> btnAry = CSSUtil.getFlexigridBtn();
      int btnAryLen = btnAry.size();
      for (int k=0; k<btnAryLen; k++) {
      	String[] ary = btnAry.get(k);
      	%>
      	<option value="<%=ary[0] %>" style="background-image: url('<%=SkinMgr.getSkinPath(request)%>/flexigrid/<%=ary[1] %>');"><%=ary[0]%></option>
      	<%
      }
      %>
      </select>
      <script>
      var map = new Map();
      <%
      for (int k=0; k<btnAryLen; k++) {
      	String[] ary = btnAry.get(k);
      	%>
     	map.put('<%=ary[0]%>', '<%=SkinMgr.getSkinPath(request)%>/flexigrid/<%=ary[1] %>');
      	<%
      }
      %>
      	var oMenuIcon;
		$(function () {
		    //带图片
		    oMenuIcon = $("#btnBclassAdd").select2({
		        templateResult: formatState,
		        templateSelection: formatState
		    });
		    
			var btnName = new LiveValidation('btnName');
			btnName.add( Validate.Presence );
		});
		
		function formatState(state) {
		    if (!state.id) { return state.text; }
		    var $state = $(
		      '<span><img src="' + map.get(state.text).value + '" class="img-flag" /> ' + state.text + '</span>'
		    );
		    return $state;
		};      	
      	</script>
      </td>
      <td align="center">
      <input class="btn btn-default" type="button" value="添加" onclick="submitAddBtn()" />
      <input name="formCode" value="<%=formCode%>" type="hidden" />
      <input name="code" value="<%=code%>" type="hidden" />      
      </td>
    </tr>
  </form>
</table>
<script>
	function submitAddBtn() {
		if ($('#btnName').val().indexOf("\"")!=-1 || $('#btnName').val().indexOf("'")!=-1) {
			jAlert("按钮名称中不能含有单引号或双引号", "提示");
			return;
		}

		var btnBatchOrScriptVal = getRadioValue('btnBatchOrScript');
		if ( btnBatchOrScriptVal == '0') {
			$('#opAddBtn').val('addBtnBatch');
		}
		else if (btnBatchOrScriptVal == '1') {
			$('#opAddBtn').val('addBtn');
		}
		else {
			$('#opAddBtn').val('addBtnFlow');
		}

		<%
        if (isServerConnectWithCloud) {
        %>
		$.ajax({
			type: "post",
			url: "btnAdd.do",
			contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
			data: $('#formBtn').serialize(),
			dataType: "html",
			beforeSend: function (XMLHttpRequest) {
				$('body').showLoading();
			},
			success: function (data, status) {
				data = $.parseJSON(data);
				if (data.ret == "1") {
					jAlert(data.msg, "提示", function () {
						window.location.reload()
					});
				} else {
					jAlert(data.msg, "提示");
				}
			},
			complete: function (XMLHttpRequest, status) {
				$('body').hideLoading();
			},
			error: function (XMLHttpRequest, textStatus) {
				// 请求出错处理
				alert(XMLHttpRequest.responseText);
			}
		});
		<%
        }else {
			String tNameBtn = StrUtil.getNullStr(msd.getString("btn_name"));
			String tOrderBtn = StrUtil.getNullStr(msd.getString("btn_order"));
			String tScriptBtn = StrUtil.getNullStr(msd.getString("btn_script"));
			String tBclassBtn = StrUtil.getNullStr(msd.getString("btn_bclass"));
			String tRoleBtn = StrUtil.getNullStr(msd.getString("btn_role"));
        %>
		var we = o("webedit");
		if (btnBatchOrScriptVal == '0') {
			we.PostScript = "<%=path%>/public/module/addBtnBatch.do";
		} else if (btnBatchOrScriptVal == '1') {
			we.PostScript = "<%=path%>/public/module/addBtn.do";
		}
		else {
			we.PostScript = "<%=path%>/public/module/addBtnFlow.do";
		}

		loadDataToWebeditCtrl(o("formBtn"), o("webedit"));
		we.AddField("cwsVersion", "<%=cfg.get("version")%>");

		we.AddField("tName", "<%=tNameBtn%>");
		we.AddField("tOrder", "<%=tOrderBtn%>");
		we.AddField("tScript", "<%=tScriptBtn.replaceAll("\"", "\\\\\"")%>");
		we.AddField("tBclass", "<%=tBclassBtn%>");
		we.AddField("tRole", "<%=tRoleBtn%>");
		we.UploadToCloud();

		var data = $.parseJSON(o("webedit").ReturnMessage);
		if (data.ret == "1") {
			$.ajax({
				type: "post",
				url: "btnSave.do",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				data: {
					code: "<%=code%>",
					formCode: "<%=formCode%>",
					result: JSON.stringify(data.result)
				},
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					if (data.ret=="1") {
						jAlert(data.msg, "提示", function() {
							window.location.reload();
						});
					}
					else {
						jAlert(data.msg, "提示");
					}
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					alert(XMLHttpRequest.responseText);
				}
			});
		} else {
			jAlert(data.msg, "提示");
		}
		<%
        }
        %>
	}
</script>
<br />
<%
	if (!isServerConnectWithCloud) {
%>
<TABLE align="center" class="tabStyle_1 percent60" style="margin-top: 20px; width:450px">
	<TR>
		<TD align="left" class="tabStyle_1_title">上传助手</TD>
	</TR>
	<TR>
		<td align="center">
			<object classid="CLSID:DE757F80-F499-48D5-BF39-90BC8BA54D8C" codebase="../activex/cloudym.CAB#version=1,3,0,0" width=450 height=86 align="middle" id="webedit">
				<param name="Encode" value="utf-8">
				<param name="MaxSize" value="<%=Global.MaxSize%>">
				<!--上传字节-->
				<param name="ForeColor" value="(255,255,255)">
				<param name="BgColor" value="(107,154,206)">
				<param name="ForeColorBar" value="(255,255,255)">
				<param name="BgColorBar" value="(0,0,255)">
				<param name="ForeColorBarPre" value="(0,0,0)">
				<param name="BgColorBarPre" value="(200,200,200)">
				<param name="FilePath" value="">
				<param name="Relative" value="2">
				<!--上传后的文件需放在服务器上的路径-->
				<param name="Server" value="<%=host%>">
				<param name="Port" value="<%=port%>">
				<param name="VirtualPath" value="<%=Global.virtualPath%>">
				<param name="PostScript" value="<%=path%>/public/module/modifyLink.do">
				<param name="PostScriptDdxc" value="">
				<param name="SegmentLen" value="204800">
				<param name="BasePath" value="">
				<param name="InternetFlag" value="">
				<param name="Organization" value="<%=license.getCompany()%>" />
				<param name="Key" value="<%=license.getKey()%>" />
			</object>
		</TD>
	</TR>
	</table>
<%
	}
%>
</body>
<script>
var work_log = "<%=work_log%>";
if(work_log==1) {
	$("#is_workLog").attr({"checked":"checked"});
}else{
	$("#is_workLog").removeAttr("checked");
}

function changeWorkLog(){
	//alert($("#is_workLog:checked").parent().html());
	if($("#is_workLog:checked").parent().html() != null){
		$(".is_workLog").val(1);
	}else{
		$(".is_workLog").val(0);
	}
}

function formAddMulti_onsubmit() {
	if (formAddMulti.fieldName.value=="") {
		jAlert("字段不能为空！","提示");
		return false;
	}
}

function getScript() {
	return $('#filter').val();
}

function setScript(script) {
	$('#filter').val(script);
}

function openWin(url,width,height) {
	var newwin=window.open(url,"fieldWin","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,top=50,left=120,width="+width+",height="+height);
	return newwin;
}

var curCondsObj, curImgObj;
function openCondition(condsObj, imgObj){
	curCondsObj = condsObj;
	curImgObj = imgObj
	
    openWin("",1024,568);

	var url = "module_combination_condition.jsp";
	var tempForm = document.createElement("form");
	tempForm.id="tempForm1";  
	tempForm.method="post";
	tempForm.action=url;  

	var hideInput = document.createElement("input");
	hideInput.type="hidden";
	hideInput.name= "condition";
	hideInput.value = curCondsObj.value;
	tempForm.appendChild(hideInput);   
	    
	hideInput = document.createElement("input");  
	hideInput.type="hidden";  
	hideInput.name= "fromValue";
	hideInput.value=  "" ;
	tempForm.appendChild(hideInput);   
			  
	hideInput = document.createElement("input");  
	hideInput.type="hidden";  
	hideInput.name= "toValue";
	hideInput.value=  ""
	tempForm.appendChild(hideInput);   
	    
	hideInput = document.createElement("input");  
	hideInput.type="hidden";  
	hideInput.name= "moduleCode";
	hideInput.value=  "<%=code %>";
	tempForm.appendChild(hideInput);   
	    
	hideInput = document.createElement("input");  
	hideInput.type="hidden";  
	hideInput.name= "operate";
	hideInput.value=  "";
	tempForm.appendChild(hideInput);   
	
	document.body.appendChild(tempForm);
	tempForm.target="fieldWin";
	tempForm.submit();
	document.body.removeChild(tempForm);
}

function setCondition(val) {
	curCondsObj.value = val;
	if (val=="") {
		$(curImgObj).hide();
	}
	else {
		$(curImgObj).show();
	}		
}

function openMsgPropDlg(){
  openWin("module_msg_prop.jsp?moduleCode=<%=code%>", 700, 600);
}		 

function getMsgProp() {
	return o("msgProp").value;
}

function setMsgProp(msgProp) {
	o("msgProp").value = msgProp;
	$.ajax({
		url: "setMsgProp",
		type: "post",
		data: {
			code: "<%=code%>",
			msgProp: msgProp
		},
		dataType: "json",
		beforeSend: function(XMLHttpRequest){
		},
		success: function(data, status) {
            jAlert(data.msg, "提示");
		},
		complete: function(XMLHttpRequest, status){
		},
		error: function(XMLHttpRequest, textStatus){
		}
	});	
}

<%
	com.redmoon.oa.Config oaCfg = new com.redmoon.oa.Config();
	com.redmoon.oa.SpConfig spCfg = new com.redmoon.oa.SpConfig();
	String version = StrUtil.getNullStr(oaCfg.get("version"));
	String spVersion = StrUtil.getNullStr(spCfg.get("version"));
%>
var ideUrl = "../admin/script_frame.jsp";
var ideWin;
var cwsToken = "";

function openIdeWin() {
	ideWin = openWinMax(ideUrl);
}

var onMessage = function(e) {
	var d = e.data;
	var data = d.data;
	var type = d.type;
	if (type=="setScript") {
		setScript(data);
		if (d.cwsToken!=null) {
			cwsToken = d.cwsToken;
			ideUrl = "../admin/script_frame.jsp?cwsToken=" + cwsToken;
		}
	}
	else if (type=="getScript") {
		var data={
		    "type":"openerScript",
		    "version":"<%=version%>",
		    "spVersion":"<%=spVersion%>",
		    "scene":"module.filter",	    
		    "data":getScript()
	    }
		ideWin.leftFrame.postMessage(data, '*');
	}
	else if (type == "setCwsToken") {
		cwsToken = d.cwsToken;
		ideUrl = "../admin/script_frame.jsp?cwsToken=" + cwsToken;
	}
};

$(function() {
     if (window.addEventListener) { // all browsers except IE before version 9
         window.addEventListener("message", onMessage, false);
     } else {
         if (window.attachEvent) { // IE before version 9
             window.attachEvent("onmessage", onMessage);
         }
     }
});

  <%
      if (!isServerConnectWithCloud) {
  %>
  function checkWebEditInstalled() {
	  var bCtlLoaded = false;
	  try {
		  if (typeof(o("webedit").AddField)=="undefined")
			  bCtlLoaded = false;
		  if (typeof(o("webedit").AddField)=="unknown") {
			  bCtlLoaded = true;
		  }
	  }
	  catch (ex) {
	  }
	  if (!bCtlLoaded) {
		  $('<div></div>').html('您还没有安装客户端控件，请点击确定此处下载安装！').activebar({
			  'icon': 'images/alert.gif',
			  'highlight': '#FBFBB3',
			  'url': 'activex/oa_client.exe',
			  'button': 'images/bar_close.gif'
		  });
	  }
  }

  $(function() {
	  checkWebEditInstalled();
  })
  <%
  }
  %>

	$.fn.outerHTML = function () {
		return $("<p></p>").append(this.clone()).html();
	};

	function addCalcuField() {
		if (o("divCalcuField0")) {
			$("#divCalcuField").append($("#divCalcuField0").outerHTML());
		} else {
			initDivCalcuField();
		}
	}

	function initDivCalcuField() {
		$.ajax({
			type: "POST",
			url: "module_field_calcu_field_ajax.jsp",
			data: {
				formCode: "<%=formCode%>"
			},
			success: function (html) {
				$("#divCalcuField").html(html);
			},
			error: function (XMLHttpRequest, textStatus) {
				// 请求出错处理
				jAlert(XMLHttpRequest.responseText, "提示");
			}
		});
	}

	$(function () {
		$('#btnPropStat').click(function (e) {
			e.preventDefault();

			// 字段合计描述字符串处理
			var calcCodesStr = "";
			var calcFuncs = $("select[name='calcFunc']");

			var map = new Map();
			var isFound = false;
			$("select[name='calcFieldCode']").each(function (i) {
				if ($(this).val() != "") {
					if (!map.containsKey($(this).val()))
						map.put($(this).val(), $(this).val());
					else {
						isFound = true;
						jAlert($(this).find("option:selected").text() + "存在重复！", "提示");
						return false;
					}

					if (calcCodesStr == "")
						calcCodesStr = "\"" + $(this).val() + "\":\"" + calcFuncs.eq(i).val() + "\"";
					else
						calcCodesStr += "," + "\"" + $(this).val() + "\":\"" + calcFuncs.eq(i).val() + "\"";
				}
			})
			if (isFound)
				return;

			calcCodesStr = "{" + calcCodesStr + "}";

			$.ajax({
				type: "post",
				url: "updatePropStat",
				data: {
					code: "<%=code%>",
					propStat: calcCodesStr
				},
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					jAlert(data.msg, "提示");
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					jAlert(XMLHttpRequest.responseText, "提示");
				}
			});
		});

		$('#btnModuleProp').click(function (e) {
			e.preventDefault();
			$.ajax({
				type: "post",
				url: "setModuleProps",
				data: $('#formModuleProps').serialize(),
				dataType: "html",
				beforeSend: function (XMLHttpRequest) {
					$('body').showLoading();
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					jAlert(data.msg, "提示");
					if (data.ret == 1) {
						reloadTab("<%=tabIdOpener%>");
					}
				},
				complete: function (XMLHttpRequest, status) {
					$('body').hideLoading();
				},
				error: function (XMLHttpRequest, textStatus) {
					// 请求出错处理
					jAlert(XMLHttpRequest.responseText, "提示");
				}
			});
		})
	})

	function openWinMax(url) {
		return window.open(url, '', 'scrollbars=yes,resizable=yes,channelmode'); // 开启一个被F11化后的窗口起作用的是最后那个特效
	}

	var kind = "<%=kind%>";

	function frmFilter_onsbumit() {
		if (kind == "comb") {
			o("filter").value = o("condition").value;
		}

		$.ajax({
			type: "post",
			url: "setModuleFilter",
			data: $('#formModuleFilter').serialize(),
			dataType: "html",
			beforeSend: function (XMLHttpRequest) {
				$('body').showLoading();
			},
			success: function (data, status) {
				data = $.parseJSON(data);
				$.toaster({priority: 'info', message: data.msg});
			},
			complete: function (XMLHttpRequest, status) {
				$('body').hideLoading();
			},
			error: function (XMLHttpRequest, textStatus) {
				// 请求出错处理
				jAlert(XMLHttpRequest.responseText, "提示");
			}
		});
		return false;
	}

	$(function () {
		$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
			kind = $(e.target).attr("kind");
			if (kind == "script") {
				if (o("filter").value.indexOf("<items>") == 0) {
					o("filter").value = "";
				}
				$('#trOrderBy').hide();
			} else {
				$('#trOrderBy').show();
			}
		});

		$("#mainTable td").mouseout(function () {
			if ($(this).parent().parent().get(0).tagName != "THEAD")
				$(this).parent().find("td").each(function (i) {
					$(this).removeClass("tdOver");
				});
		});

		$("#mainTable td").mouseover(function () {
			if ($(this).parent().parent().get(0).tagName != "THEAD")
				$(this).parent().find("td").each(function (i) {
					$(this).addClass("tdOver");
				});
		});
	});
</script>
</html>