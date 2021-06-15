<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="cn.js.fan.security.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="java.util.*"%>
<%@ page import="cn.js.fan.web.*"%>
<%@ page import="com.redmoon.oa.help.*"%>
<%@ page import="com.redmoon.oa.pvg.*"%>
<%@ page import="java.util.Calendar" %>
<%@ page import="cn.js.fan.db.Paginator"%>
<%@ page import="com.redmoon.oa.person.*"%>
<%@ page import="com.redmoon.oa.kernel.*"%>
<%@ page import="com.redmoon.oa.basic.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9">
<link href="../common.css" rel="stylesheet" type="text/css">
<link href="../fileark/default.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../util/jscalendar/calendar.js"></script>
<script type="text/javascript" src="../util/jscalendar/lang/calendar-zh.js"></script>
<script type="text/javascript" src="../util/jscalendar/calendar-setup.js"></script>
<style type="text/css"> @import url("../util/jscalendar/calendar-win2k-2.css"); </style>
<script src="../inc/common.js"></script>
<script src="../js/jquery-1.9.1.min.js"></script>
<script src="../js/jquery-migrate-1.2.1.min.js"></script>
<script type="text/javascript" src="../js/activebar2.js"></script>
<script src="../inc/livevalidation_standalone.js"></script>
<script>
var isLeftMenuShow = true;
function closeLeftMenu() {
	if (isLeftMenuShow) {
		window.parent.setCols("0,*");
		isLeftMenuShow = false;
		btnName.innerHTML = "打开菜单";
	}
	else {
		window.parent.setCols("200,*");
		isLeftMenuShow = true;
		btnName.innerHTML = "关闭菜单";
	}
}

function onAddFile() {
}
</script>
<%
response.setHeader("Pragma","No-cache");
response.setHeader("Cache-Control","no-cache");
response.setDateHeader("Expires", 0);
%>
<jsp:useBean id="strutil" scope="page" class="cn.js.fan.util.StrUtil"/>
<jsp:useBean id="docmanager" scope="page" class="com.redmoon.oa.help.DocumentMgr"/>
<jsp:useBean id="dir" scope="page" class="com.redmoon.oa.help.Directory"/>
<%
com.redmoon.clouddisk.Config cfgNd = com.redmoon.clouddisk.Config
.getInstance();
boolean isUsed = cfgNd.getBooleanProperty("isUsed"); //判断网盘是否启用
String dir_code = ParamUtil.get(request, "dir_code");
String dir_name = ParamUtil.get(request, "dir_name");
int id = 0;

Privilege privilege = new Privilege();
String op = ParamUtil.get(request, "op");
String action = ParamUtil.get(request, "action");

String correct_result = "操作成功";
Document doc = null;

if (op.equals("edit")) {
	id = ParamUtil.getInt(request, "id");
	doc = docmanager.getDocument(id);
	dir_code = doc.getDirCode();
}

Document template = null;
Leaf leaf = dir.getLeaf(dir_code);

String strtemplateId = ParamUtil.get(request, "templateId");
int templateId = Document.NOTEMPLATE;
if (!strtemplateId.trim().equals("")) {
	if (StrUtil.isNumeric(strtemplateId))
		templateId = Integer.parseInt(strtemplateId);
}
if (templateId==Document.NOTEMPLATE) {
	templateId = leaf.getTemplateId();
}

if (templateId!=Document.NOTEMPLATE) {
	template = docmanager.getDocument(templateId);
}

if (op.equals("add")) {
	LeafPriv lp = new LeafPriv();
	lp.setDirCode(dir_code);
	if (!lp.canUserAppend(privilege.getUser(request))) {
		out.print(StrUtil.Alert_Back(privilege.MSG_INVALID));
		return;
	}

	if (action.equals("selTemplate")) {
		int tid = ParamUtil.getInt(request, "templateId");
		template = docmanager.getDocument(tid);
	}
}
else if (op.equals("edit")) {
	try {
		LeafPriv lp = new LeafPriv(doc.getDirCode());
		if (!lp.canUserModify(privilege.getUser(request))) {
			out.print(SkinUtil.makeErrMsg(request, privilege.MSG_INVALID));
			return;
		}
		
		if (action.equals("selTemplate")) {
			int tid = ParamUtil.getInt(request, "templateId");
			doc.setTemplateId(tid);
			doc.updateTemplateId();
		}
		if (doc!=null) {
			template = doc.getTemplate();
		}
	} catch (ErrMsgException e) {
		out.print(SkinUtil.makeErrMsg(request, e.getMessage()));
		return;
	}
	
	if (action.equals("changeAttachOrders")) {
		int attachId = ParamUtil.getInt(request, "attachId");
		String direction = ParamUtil.get(request, "direction");
		// 取得第一页的内容
		DocContent dc = new DocContent();
		dc = dc.getDocContent(id, 1);
		dc.moveAttachment(attachId, direction);		
	}
}
if (op.equals("editarticle")) {
	op = "edit";
	try {
		doc = docmanager.getDocumentByCode(request, dir_code, privilege);
		dir_code = doc.getDirCode();

		LeafPriv lp = new LeafPriv();
		lp.setDirCode(doc.getDirCode());
		if (!lp.canUserModify(privilege.getUser(request))) {
			out.print(SkinUtil.makeErrMsg(request, privilege.MSG_INVALID));
			return;
		}
		
	} catch (ErrMsgException e) {
		out.print(SkinUtil.makeErrMsg(request, e.getMessage()));
		return;
	}
}

if (doc!=null) {
	id = doc.getID();
	Leaf lfn = new Leaf();
	lfn = lfn.getLeaf(doc.getDirCode());
	dir_name = lfn.getName();
}
%>
<title><%=doc!=null?doc.getTitle():""%></title>
<style type="text/css">
<!--
td {  font-family: "Arial", "Helvetica", "sans-serif"; font-size: 14px; font-style: normal; line-height: 150%; font-weight: normal}
.style2 {color: #FF3300}
-->
</style>
<!--用ckeditor34才能贴粘上传-->
<script type="text/javascript" src="../ckeditor/ckeditor.js" mce_src="ckeditor/ckeditor.js"></script>
<script type="text/javascript" src='../ckeditor/formpost.js'></script>
<script language="JavaScript">
<!--
<%
if (doc!=null) {
	out.println("var id=" + doc.getID() + ";");
}
%>
	var op = "<%=op%>";

	function SubmitWithFileDdxc() {
		addform.webedit.isDdxc = 1;
		if (document.addform.title.value.length == 0) {
			alert("请输入文章标题.");
			document.addform.title.focus();			
			return false;
		}
		loadDataToWebeditCtrl(addform, addform.webedit);
		addform.webedit.MTUpload();
		// 因为Upload()中启用了线程的，所以函数在执行后，会立即反回，使得下句中得不到ReturnMessage的值
		// 原因是此时服务器的返回信息还没收到
		// alert("ReturnMessage=" + addform.webedit.ReturnMessage);
	}

	function SubmitWithFileThread() {
		if (document.addform.title.value.length == 0) {
			alert("请输入文章标题.");
			document.addform.title.focus();			
			return false;
		}
		loadDataToWebeditCtrl(addform, addform.webedit);
		addform.webedit.Upload();
		// 因为Upload()中启用了线程的，所以函数在执行后，会立即反回，使得下句中得不到ReturnMessage的值
		// 原因是此时服务器的返回信息还没收到
		// alert("ReturnMessage=" + addform.webedit.ReturnMessage);
	}

	function SubmitWithFile(){
		if (document.addform.title.value.length == 0) {
			alert("请输入文章标题.");
			document.addform.title.focus();			
			return false;
		}
		loadDataToWebeditCtrl(addform, addform.webedit);
		addform.webedit.UploadArticle();
		if (addform.webedit.ReturnMessage.indexOf("<%=correct_result%>")!=-1)
			doAfter(true);
		else
			doAfter(false);
	}
	
	function SubmitWithoutFile() {
		if (document.addform.title.value.length == 0) {
			alert("请输入文章标题.");
			document.addform.title.focus();	
			return false;
		}

		addform.isuploadfile.value = "false";
		loadDataToWebeditCtrl(addform, addform.webedit);
		addform.webedit.UploadMode = 0;
		addform.webedit.UploadArticle();
		addform.isuploadfile.value = "true";
		if (addform.webedit.ReturnMessage.indexOf("<%=correct_result%>")!=-1)
			doAfter(true);
		else
			doAfter(false);		
	}
	
	var action = "<%=action%>";
	function doAfter(isSucceed) {
		if (isSucceed) {
			if (op=="edit")
			{
				if (confirm("<%=correct_result%>，请点击确定按钮刷新页面\r\n(如果您确定文件是来自其它服务器，可以不刷新！)。")) {
					// 此处一定要reload，否则会导致再点击上传（连同文件）时，因为images已被更改，而content中路径未变，从而下载不到，导到最终会丢失			
					// 以前未注意到此问题，可能是因为再点击上传时，获取的图片在服务器端虽然已丢失，但是缓存中可能还有的原因
					// 也可能是因为在编辑文件时，编辑完了并未重新刷新页面，content中的图片还是来源的位置（来源自别的服务器），所以依然能够上传，但是只要此时再一刷新，再连续上传两次，问题就会出现
					if (action=="selTemplate")
						window.location.href = "fwebedit.jsp?op=edit&id=<%=id%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>";
					else
						window.location.reload(true);
				}
			}
			else {
				if (confirm("<%=correct_result%>，点击确定继续转至目录列表，点击取消继续添加！\r\n"))
					<%
					String pageUrl = "document_list_m.jsp?";
					if (dir_code.indexOf("cws_prj_")==0) {
						String projectId = dir_code.substring(8);
						// 如果projectId中含有下划线_，则截取出其ID
						int p = projectId.indexOf("_");
						if (p!=-1) {
							projectId = projectId.substring(0, p);
						}						
						pageUrl = "project/project_doc_list.jsp?projectId=" + projectId;
					}
					%>
					window.location.href = "<%=pageUrl%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&dir_name=<%=StrUtil.UrlEncode(dir_name)%>";
				else
					window.location.reload();
		    }
		}
		else {
			alert(addform.webedit.ReturnMessage);
		}
	}
	
function showvote(isshow)
{
	if (addform.isvote.checked)
	{
		divVote.style.display = "";
	}
	else
	{
		divVote.style.display = "none";		
	}
}

function selTemplate(id)
{
	if (addform.templateId.value!=id) {
		addform.templateId.value = id;
		// 此处注意当模式对话框的路径在admin下时，退出后本页路径好象被改为admin了
<%if (doc!=null) {%>
		window.location.href="../fwebedit.jsp?op=edit&action=selTemplate&id=<%=id%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&dir_name=<%=StrUtil.UrlEncode(dir_name)%>&templateId=" + id;
<%}else{%>
		if (id!=-1)
			window.location.href="../fwebedit.jsp?op=add&action=selTemplate&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&dir_name=<%=StrUtil.UrlEncode(dir_name)%>&templateId=" + id;		
<%}%>
	}
}

var recordFilePath = "";
function Operate() {
	recordFilePath = addform.Recorder.FilePath;
	addform.webedit.InsertFileToList(recordFilePath);
}

function checkWebEditInstalled() {
	if (!isIE())
		return;
	var bCtlLoaded = false;
	try	{
		if (typeof(addform.webedit.AddField)=="undefined")
			bCtlLoaded = false;
		if (typeof(addform.webedit.AddField)=="unknown") {
			bCtlLoaded = true;
		}
	}
	catch (ex) {
	}
	if (!bCtlLoaded) {
		<%if(isUsed){%> //判断网盘是否启用
			if (isWow64()) {
				$('<div></div>').html('您还没有安装客户端控件，请点击确定此处下载安装！').activebar({
					'icon': 'images/alert.gif',
					'highlight': '#FBFBB3',
					'url': '../activex/clouddisk_x64.exe',
					'button': '../images/bar_close.gif'
				});
			}else{		
				$('<div></div>').html('您还没有安装客户端控件，请点击确定此处下载安装！').activebar({
					'icon': 'images/alert.gif',
					'highlight': '#FBFBB3',
					'url': '../activex/clouddisk.exe',
					'button': '../images/bar_close.gif'
				});
			}
		<%}else{%>
			$('<div></div>').html('您还没有安装流程设计控件，请点击确定此处下载安装！').activebar({
			    'icon': '../images/alert.gif',
			    'highlight': '#FBFBB3',
			    'url': '../activex/oa_client.exe',
			    'button': '../images/bar_close.gif'
			});
		<%}%>
		
	}
	
	

}

function onDropFile(filePaths) {
	var ary = filePaths.split(",");
	var hasFile = false;
	for (var i=0; i<ary.length; i++) {
		var filePath = ary[i].trim();
		if (filePath!="") {
			hasFile = true;
			addform.webedit.InsertFileToList(filePath);
		}
	}
}

function window_onload() {
	checkWebEditInstalled();
}
//-->
</script>
</head>
<body onLoad="window_onload()">
<TABLE width="98%" BORDER=0 align="center" CELLPADDING=0 CELLSPACING=0>
  <TR valign="top" bgcolor="#FFFFFF">
    <TD width="" height="430" colspan="2" style="background-attachment: fixed; background-image: url(images/bg_bottom.jpg); background-repeat: no-repeat">
          <TABLE cellSpacing=0 cellPadding=0 width="100%">
            <TBODY>
              <TR>
                <TD width="90%" class=head>
				<%
				if (op.equals("add")) {
				%>
					添加&nbsp;-&nbsp;<a href="<%=pageUrl%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&dir_name=<%=StrUtil.UrlEncode(dir_name)%>">&nbsp;<%=dir_name%></a>
				<%}else{%>
					修改&nbsp;-
<%
					Leaf dlf = new Leaf();
					if (doc!=null) {
						dlf = dlf.getLeaf(doc.getDirCode());
					}
					if (doc!=null && dlf.getType()==2) {%>
						<a href="<%=pageUrl%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&dir_name=<%=StrUtil.UrlEncode(dir_name)%>"><%=dlf.getName()%></a>
					<%}else{%>
						<%=dir_name%>
					<%}%>
				<%}%>
		<script>
		if (typeof(window.parent.leftFileFrame)=="object"){
			var btnN = "关闭菜单";
			if (window.parent.getCols()!="200,*"){
				btnN = "打开菜单";
				isLeftMenuShow=false;
			}
			document.write("&nbsp;&nbsp;<a href=\"javascript:closeLeftMenu()\"><span id=\"btnName\">");
			document.write(btnN);
			document.write("</span></a>");
		}
		</script>				
				</TD>
                <TD width="10%" align="right" class=head><a href="fwebedit_new.jsp?op=<%=op%>&id=<%=id%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&dir_name=<%=StrUtil.UrlEncode(dir_name)%>">普通方式</a>&nbsp;&nbsp;</TD>
              </TR>
            </TBODY>
          </TABLE>
	<form name="addform" action="fwebedit_do.jsp" method="post" enctype="MULTIPART/FORM-DATA">
          <table border="0" cellspacing="1" width="100%" cellpadding="2" align="center">
            <tr align="center" bgcolor="#F2F2F2">
              <td height="20" colspan=2 align=center><b><%=doc!=null?doc.getTitle():""%></b>&nbsp;<input type="hidden" name=isuploadfile value="true">
			  <input type="hidden" name=id value="<%=doc!=null?""+doc.getID():""%>">
<%=doc!=null?"(id:"+doc.getID()+")":""%>
<%if (doc!=null) {%>
<!--( <a href="fileark/comment_m.jsp?doc_id=<%=doc.getID()%>">管理评论</a> )-->
<%}%></td>
            </tr>
            <tr>
              <td colspan="2" align="left" valign="middle">标&nbsp;&nbsp;&nbsp;题：
        	  <input name="title" id=me type="text" size=50 maxlength=100 value="<%=doc!=null?doc.getTitle():""%>">                  
			  <script>
              var title = new LiveValidation('title');
              title.add(Validate.Presence);
              </script>
              作者：
              <%
			  String userName = "";
			  userName = (doc!=null)?doc.getAuthor():privilege.getUser(request);
			  UserDb ud = new UserDb();
			  ud = ud.getUserDb(userName);
			  if (ud!=null && ud.isLoaded())
			  	userName = ud.getRealName();
			  %>
              <input name="author" id="author" type="text" size=10 maxlength=100 value="<%=userName%>" readonly>
              <input type="hidden" name="op" value="<%=op%>">
			  </td>
            </tr>
            <tr>
              <td colspan="2" align="left" valign="middle">关键字：
              	<input title="请用&quot;，&quot;号分隔" name="keywords" id=keywords type="text" size=20 maxlength=100 value="<%=StrUtil.getNullStr(doc==null?dir_name:doc.getKeywords())%>">
			    <input type="hidden" name="isRelateShow" value="1">
			    <%
			String strChecked = "";
			if (doc!=null) {
				if (doc.getCanComment())
					strChecked = "checked";
			}
			else
				strChecked = "checked";
			%>
                <input type="checkbox" name="canComment" value="1" <%=strChecked%>>
允许评论
<%if (doc!=null) {%>
[<a href="fileark/comment_m.jsp?doc_id=<%=doc.getID()%>">管理评论</a>]
<%}%>
<input type="hidden" name="examine" value="<%=Document.EXAMINE_PASS%>">
<%
String checknew = "";
if (doc!=null && doc.getIsNew()==1)
	checknew = "checked";
%>
<!--
<input type="checkbox" name="isNew" value="1" <%=checknew%>>
<img src="images/i_new.gif" width="18" height="7">
-->
            </tr>
            <tr align="left">
              <td colspan="2" valign="middle">
			  <%if (doc!=null) {%>
				  <script>
				  var bcode = "<%=doc.getDirCode()%>";
				  </script>目&nbsp;&nbsp;&nbsp;&nbsp;录：
				  <%
				  if (leaf.getType()==leaf.TYPE_DOCUMENT) {
					out.print("<input name=dir_code type=hidden value='" + doc.getDirCode() + "'>" + leaf.getName());
				  }else{
				  %>				  
					<select name="dir_code" onChange="if(this.options[this.selectedIndex].value=='not'){alert(this.options[this.selectedIndex].text+' 不能被选择！'); this.value=bcode; return false;}">
					<option value="not" selected>请选择目录</option>
					<%
					Leaf lf = dir.getLeaf("root");
					DirectoryView dv = new DirectoryView(lf);
					dv.ShowDirectoryAsOptions(out, lf, lf.getLayer());
					%>
					</select>
					<script>
                    addform.dir_code.value = "<%=doc.getDirCode()%>";
                    </script>
                    &nbsp;( <span class="style3">蓝色</span>表示可选 )
				  <%}%>			  
				<%}else{%>
					<input type=hidden name="dir_code" value="<%=dir_code%>">
				<%}%>
				<input name="templateId" class="btn" value="<%=templateId%>" type=hidden>
				排序号：&nbsp;
				<input name="level" value="<%=doc!=null?doc.getLevel():"0"%>" size="2" />
				(<a href="javascript:;" onclick="o('level').value=100">置顶</a>)
<input type="hidden" name="editFlag" value="redmoon">   
              </td>
            </tr>
            
            <tr align="left" bgcolor="#F2F2F2">
              <td colspan="2" valign="middle" bgcolor="#FFFFFF">颜&nbsp;&nbsp;&nbsp;&nbsp;色：
                <select name="color">
                <option value="" style="COLOR: black" selected>显示颜色</option>
                <option style="BACKGROUND: #000088" value="#000088"></option>
                <option style="BACKGROUND: #0000ff" value="#0000ff"></option>
                <option style="BACKGROUND: #008800" value="#008800"></option>
                <option style="BACKGROUND: #008888" value="#008888"></option>
                <option style="BACKGROUND: #0088ff" value="#0088ff"></option>
                <option style="BACKGROUND: #00a010" value="#00a010"></option>
                <option style="BACKGROUND: #1100ff" value="#1100ff"></option>
                <option style="BACKGROUND: #111111" value="#111111"></option>
                <option style="BACKGROUND: #333333" value="#333333"></option>
                <option style="BACKGROUND: #50b000" value="#50b000"></option>
                <option style="BACKGROUND: #880000" value="#880000"></option>
                <option style="BACKGROUND: #8800ff" value="#8800ff"></option>
                <option style="BACKGROUND: #888800" value="#888800"></option>
                <option style="BACKGROUND: #888888" value="#888888"></option>
                <option style="BACKGROUND: #8888ff" value="#8888ff"></option>
                <option style="BACKGROUND: #aa00cc" value="#aa00cc"></option>
                <option style="BACKGROUND: #aaaa00" value="#aaaa00"></option>
                <option style="BACKGROUND: #ccaa00" value="#ccaa00"></option>
                <option style="BACKGROUND: #ff0000" value="#ff0000"></option>
                <option style="BACKGROUND: #ff0088" value="#ff0088"></option>
                <option style="BACKGROUND: #ff00ff" value="#ff00ff"></option>
                <option style="BACKGROUND: #ff8800" value="#ff8800"></option>
                <option style="BACKGROUND: #ff0005" value="#ff0005"></option>
                <option style="BACKGROUND: #ff88ff" value="#ff88ff"></option>
                <option style="BACKGROUND: #ee0005" value="#ee0005"></option>
                <option style="BACKGROUND: #ee01ff" value="#ee01ff"></option>
                <option style="BACKGROUND: #3388aa" value="#3388aa"></option>
                <option style="BACKGROUND: #000000" value="#000000"></option>
                </select>
                <%if (doc!=null) {%>
                <script>
				addform.color.value = "<%=StrUtil.getNullStr(doc.getColor())%>";
				  </script>
                <%}%>
                <%
				  String strExpireDate = "";
				  if (doc!=null) {
				  	strExpireDate = DateUtil.format(doc.getExpireDate(), "yyyy-MM-dd");
				  %>
                <input type="checkbox" name="isBold" value="true" <%=doc.isBold()?"checked":""%> >
                <%}else{%>
                <input type="checkbox" name="isBold" value="true" >
                <%}%>
                标题加粗 
                  &nbsp;到期时间：
                <input type="text" id="expireDate" name="expireDate" size="10" value="<%=strExpireDate%>">
              <script type="text/javascript">
    Calendar.setup({
        inputField     :    "expireDate",      // id of the input field
        ifFormat       :    "%Y-%m-%d",       // format of the input field
        showsTime      :    false,            // will display a time selector
        singleClick    :    false,           // double-click mode
        align          :    "Tl",           // alignment (defaults to "Bl")		
        step           :    1                // show all years in drop-down boxes (instead of every other year as default)
    });
                  </script></td>
            </tr>
            <tr>
              <td valign="middle">
			  <script>
			  var vp = "";
			  </script>
		<%
		String display="none",ischecked="false", isreadonly = "";
		if (doc!=null) {
			if (doc.getType()==1) {
				display = "";
				ischecked = "checked disabled";
				isreadonly = "readonly";
				%>
				<script>
				var voteoption = "<%=doc.getVoteOption()%>";
				var votes = voteoption.split("|");
				var len = votes.length;
				for (var i=0; i<len; i++) {
					if (vp=="")
						vp = votes[i];
					else
						vp += "\r\n" + votes[i];
				}
				</script>
			<%}
		}%>
					  <input type="checkbox" name="isvote" value="1" onClick="showvote()" <%=ischecked%>>
              投票</td>
              <td width="854" valign="middle">
			  <div id="divVote" style="display:<%=display%>">
截止日期
                <input id="expire_date" name="expire_date">
                <script type="text/javascript">
    Calendar.setup({
        inputField     :    "expire_date",      // id of the input field
        ifFormat       :    "%Y-%m-%d",       // format of the input field
        showsTime      :    false,            // will display a time selector
        singleClick    :    false,           // double-click mode
        align          :    "Tl",           // alignment (defaults to "Bl")		
        step           :    1                // show all years in drop-down boxes (instead of every other year as default)
    });
                </script>
                最多可选
                <input name="max_choice" size=1 value="1">
                项<br>
                <textarea <%=isreadonly%> cols="60" name="vote" rows="8" wrap="VIRTUAL" title="输入投票选项" type="_moz">
			    </textarea>
                <script>
  				addform.vote.value = vp;
			  </script><br>
每行代表一个选项(编辑文档时选项不可更改)</div></td>
            </tr>
            <tr align="center">
              <td colspan="2" valign="top" bgcolor="#F2F2F2">
<div style="clear:both">              
<textarea id="htmlcode" name="htmlcode"><%
	if (template!=null) {
		out.print(template.getContent(1));
    }
	else if (!op.equals("add")) {
		out.print(doc.getDocContent(1).getContent());
	}
%></textarea>
</div>
<script>
CKEDITOR.replace('htmlcode',
	{
		skin : 'kama'
	});
</script> 
			  </td>
            </tr>
            <tr>
              <td width="88" align="left">提示：</td>
              <td>
			  回车可用Shift+Enter			  </td>
            </tr>
            <tr>
              <td align="left">网盘文件：</td>
              <td>
              <a href="javascript:;" onClick="openWin('../netdisk/netdisk_frame.jsp?mode=select', 800, 600)">选择文件</a>
			  <div id="netdiskFilesDiv" style="line-height:1.5"></div>              
              </td>
            </tr>
            <tr>
              <td height="25" colspan=2 align="center" bgcolor="#FFFFFF">
		<%
		com.redmoon.oa.Config cfg = new com.redmoon.oa.Config();
        com.redmoon.oa.kernel.License license = com.redmoon.oa.kernel.License.getInstance();	  
		if (!cfg.get("isUseNTKO").equals("true")) {
		%>              
			<table id="rmofficeTable" name="rmofficeTable" style="display:none;margin-top:10px;margin-bottom:10px" width="29%"  border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#CCCCCC">
            <tr>
              <td height="22" align="center" bgcolor="#eeeeee"><strong>&nbsp;编辑Office文件</strong></td>
            </tr>
            <tr>
              <td align="center"><div style="width:400px;height:43"><object id="redmoonoffice" classid="CLSID:D01B1EDF-E803-46FB-B4DC-90F585BC7EEE" codebase="../activex/cloudym.CAB#version=1,2,0,1" width="316" height="43" viewastext="viewastext">
                  <param name="Encode" value="utf-8" />
                  <param name="BackColor" value="0000ff00" />
                  <param name="Server" value="<%=request.getServerName()%>" />
                  <param name="Port" value="<%=request.getServerPort()%>" />
                  <!--设置是否自动上传-->
                  <param name="isAutoUpload" value="1" />
                  <!--设置文件大小不超过1M-->
                  <param name="MaxSize" value="<%=Global.FileSize%>" />
                  <!--设置自动上传前出现提示对话框-->
                  <param name="isConfirmUpload" value="1" />
                  <!--设置IE状态栏是否显示信息-->
                  <param name="isShowStatus" value="0" />
                  <param name="PostScript" value="<%=Global.virtualPath%>/fileark/upload_office_file.jsp" />
                  <param name="Organization" value="<%=license.getCompany()%>" />
                  <param name="Key" value="<%=license.getKey()%>" />                  
                </object></div>
                <!--<input name="remsg" type="button" onclick='alert(redmoonoffice.ReturnMessage)' value="查看上传后的返回信息" />--></td>
            </tr>
          </table>
          <%}%>           
			  <%
			  if (doc!=null) {
				  Vector attachments = doc.getAttachments(1);
				  Iterator ir = attachments.iterator();
				  while (ir.hasNext()) {
				  	Attachment am = (Attachment) ir.next(); %>
					<table width="100%"  border="0" cellspacing="0" cellpadding="0">
                      <tr>
                        <td width="80" align="right"><img src="../images/attach.gif"></td>
                        <td width="91%" align="left">&nbsp;
                        <input name="attach_name<%=am.getId()%>" value="<%=am.getName()%>" size="30">
                            <a href="javascript:changeAttachName('<%=am.getId()%>', '<%=doc.getID()%>', '<%="attach_name"+am.getId()%>')">重命名</a>&nbsp;&nbsp;
                            <a href="javascript:delAttach('<%=am.getId()%>', '<%=doc.getID()%>')">删除</a>&nbsp;&nbsp;
                            <!--<a target=_blank href="<%=am.getVisualPath() + "/" + am.getDiskName()%>">查看</a>&nbsp;-->
                            <a target=_blank href="fileark/getfile.jsp?docId=<%=doc.getID()%>&attachId=<%=am.getId()%>">下载</a>&nbsp;&nbsp;
							<%if (StrUtil.getFileExt(am.getDiskName()).equals("doc") || StrUtil.getFileExt(am.getDiskName()).equals("docx") || StrUtil.getFileExt(am.getDiskName()).equals("xls") || StrUtil.getFileExt(am.getDiskName()).equals("xlsx")) {%>
                            <a href="javascript:;" onClick="editdoc(<%=doc.getID()%>, <%=am.getId()%>)">编辑</a>&nbsp;&nbsp;
                            <%}%>                            
                            <a href="?op=edit&id=<%=doc.getID()%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&action=changeAttachOrders&direction=up&attachId=<%=am.getId()%>">                        
                        <img src="../images/arrow_up.gif" alt="往上" width="16" height="20" border="0" align="absmiddle"></a>&nbsp;<a href="?op=edit&id=<%=doc.getID()%>&dir_code=<%=StrUtil.UrlEncode(dir_code)%>&action=changeAttachOrders&direction=down&attachId=<%=am.getId()%>"><img src="../images/arrow_down.gif" alt="往下" width="16" height="20" border="0" align="absmiddle"></a></td>
                      </tr>
                    </table>
				<%}
			  }
			  %>
              </td>
            </tr>
            <tr>
              <td height="120" colspan=2 align=center bgcolor="#FFFFFF">
			    <table  border="0" align="center" cellpadding="0" cellspacing="1">
                <tr>
                  <td><%
Calendar cal = Calendar.getInstance();
String year = "" + (cal.get(cal.YEAR));
String month = "" + (cal.get(cal.MONTH) + 1);
String filepath = cfg.get("file_folder") + "/" + year + "/" + month;
%></td>
                </tr>
              </table>
			    <object classid="CLSID:DE757F80-F499-48D5-BF39-90BC8BA54D8C" codebase="../activex/cloudym.CAB#version=1,2,0,1" width=400 height=175 align="middle" id="webedit">
			      <param name="Encode" value="utf-8">
			      <param name="MaxSize" value="<%=Global.MaxSize%>">
			      <!--上传字节-->
			      <param name="ForeColor" value="(255,255,255)">
			      <param name="BgColor" value="(107,154,206)">
			      <param name="ForeColorBar" value="(255,255,255)">
			      <param name="BgColorBar" value="(104,181,200)">
			      <param name="ForeColorBarPre" value="(0,0,0)">
			      <param name="BgColorBarPre" value="(230,230,230)">
			      <param name="FilePath" value="<%=filepath%>">
			      <param name="Relative" value="2">
			      <!--上传后的文件需放在服务器上的路径-->
			      <param name="Server" value="<%=request.getServerName()%>">
			      <param name="Port" value="<%=request.getServerPort()%>">
			      <param name="VirtualPath" value="<%=Global.virtualPath%>">
			      <param name="PostScript" value="<%=Global.virtualPath%>/help/fwebedit_do.jsp">
			      <param name="PostScriptDdxc" value="<%=Global.virtualPath%>/ddxc.jsp">
			      <param name="SegmentLen" value="204800">
			      <param name="Organization" value="<%=license.getCompany()%>">
			      <param name="Key" value="<%=license.getKey()%>">
	          </object></td>
            </tr>
            <tr>
              <td height="" colspan=2 align=center bgcolor="#FFFFFF">
			  <div id=recorderDiv style="display:none"><!-- <OBJECT ID="Recorder" CLASSID="CLSID:E4A3D135-E189-48AF-B348-EF5DFFD99A67" codebase="../activex/cloudym.CAB#version=1,2,0,1"></OBJECT> --></div></td>
            </tr>
            <tr>
              <td height="30" colspan=2 align=center bgcolor="#FFFFFF">
			  <%
			  if (op.equals("add"))
			  	action = "添 加";
			  else
			  	action = "保 存";
			  %>
<!--		  <%if (templateId==-1) {%>
              <input name="cmdok2" type="button" class="btn" value="<%=action%>(续传)" onClick="return SubmitWithFileDdxc()">
              <%}
			  if (templateId==-1) {%>
              <input name="cmdok3" type="button" class="btn" value="<%=action%>(单线程)" onClick="return SubmitWithFileThread()">
              <%}%>
-->			  <%if (templateId==-1) {%>
			  <input name="cmdok" type="button" class="btn" value=" <%=action%> " onClick="return SubmitWithFile()">
			  <%}else{%>
				&nbsp;
				<input name="notuploadfile" type="button" class="btn" value="<%=action%>(不上传文件)" onClick="return SubmitWithoutFile()">
			  <%}%>
                <!--<input name="remsg2" type="button" class="btn" onClick="recorderDiv.style.display=''" value="录制语音">-->
                <!--&nbsp;
                <input name="remsg" type="button" class="btn" onClick='alert(webedit.ReturnMessage)' value="返回信息">
                <%if (op.equals("edit")) {%>
                      <input name="editbtn" type="button" class="btn" onClick="location.href='doc_abstract.jsp?id=<%=doc.getID()%>'" value=" 摘要 ">
                <%}%>
                -->
			  <%if (op.equals("edit")) {
                    String viewPage = request.getContextPath() + "/help/doc_show.jsp";
              %>
			  &nbsp;<input name="remsg" type="button" class="btn" onClick='addTab("<%=doc.getTitle()%>", "<%=viewPage%>?id=<%=id%>")' value=" 预 览 ">                
              <%}%>
              </td>
            </tr>
        </table>
  </form>
		<table width="100%"  border="0">
          <tr>
            <td align="center">
			<%if (doc!=null) {
				int pageNum = 1;
			%>
			文章共<%=doc.getPageCount()%>页&nbsp;&nbsp;页码
            <%
					int pagesize = 1;
					int total = DocContent.getContentCount(doc.getID());
					int curpage,totalpages;
					Paginator paginator = new Paginator(request, total, pagesize);
					// 设置当前页数和总页数
					totalpages = paginator.getTotalPages();
					curpage	= paginator.getCurrentPage();
					if (totalpages==0)
					{
						curpage = 1;
						totalpages = 1;
					}
					
					String querystr = "op=edit&doc_id=" + id;
					out.print(paginator.getCurPageBlock("doc_editpage.jsp?"+querystr));
					%>
            <%if (op.equals("edit")) {
						if (doc.getPageCount()!=pageNum) {					
					%>
&nbsp;<a href="doc_editpage.jsp?op=add&action=insertafter&doc_id=<%=doc.getID()%>&afterpage=<%=pageNum%>">当前页之后插入一页</a>
<%	}
					}%>
&nbsp;<a href="doc_editpage.jsp?op=add&doc_id=<%=doc.getID()%>">增加一页</a>
<%}%>		
			</td>
          </tr>
          <tr>
            <form name="form3" action="?" method="post"><td align="center">
			<input name="newname" type="hidden">
			</td></form>
          </tr>
        </table>
	</TD>
  </TR>
</TABLE>

<iframe id="hideframe" name="hideframe" src="" width=0 height=0></iframe>
</body>
<script>
function findObj(theObj, theDoc)
{
  var p, i, foundObj;
  
  if(!theDoc) theDoc = document;
  if( (p = theObj.indexOf("?")) > 0 && parent.frames.length)
  {
    theDoc = parent.frames[theObj.substring(p+1)].document;
    theObj = theObj.substring(0,p);
  }
  if(!(foundObj = theDoc[theObj]) && theDoc.all) foundObj = theDoc.all[theObj];
  for (i=0; !foundObj && i < theDoc.forms.length; i++) 
    foundObj = theDoc.forms[i][theObj];
  for(i=0; !foundObj && theDoc.layers && i < theDoc.layers.length; i++) 
    foundObj = findObj(theObj,theDoc.layers[i].document);
  if(!foundObj && document.getElementById) foundObj = document.getElementById(theObj);
  
  return foundObj;
}

function changeAttachName(attach_id, doc_id, nm) {
	var obj = findObj(nm);
	// document.frames.hideframe.location.href = "fwebedit_do.jsp?op=changeattachname&page_num=1&doc_id=" + doc_id + "&attach_id=" + attach_id + "&newname=" + obj.value
	form3.action = "fwebedit_do.jsp?op=changeattachname&page_num=1&doc_id=" + doc_id + "&attach_id=" + attach_id;
	form3.newname.value = obj.value;
	form3.submit();
}

function delAttach(attach_id, doc_id) {
	if (!window.confirm("您确定要删除吗？")) {
		return;
	}
	document.frames.hideframe.location.href = "fwebedit_do.jsp?op=delAttach&page_num=1&doc_id=" + doc_id + "&attach_id=" + attach_id
}
// 编辑文件
function editdoc(doc_id, file_id) {
<%if (cfg.get("isUseNTKO").equals("true")) {%>
	openWin("fileark/fileark_ntko_edit.jsp?docId=" + doc_id + "&attachId=" + file_id + "&isRevise=0", 1024, 768);
<%}else{%>
	rmofficeTable.style.display = "";
	addform.redmoonoffice.AddField("doc_id", doc_id);
	addform.redmoonoffice.AddField("file_id", file_id);
	addform.redmoonoffice.Open("<%=Global.getFullRootPath(request)%>/fileark/getfile.jsp?docId=" + doc_id + "&attachId=" + file_id);
<%}%>
}

function OfficeOperate() {
	alert(addform.redmoonoffice.ReturnMessage.substring(0, 4)); // 防止后面跟乱码
}

function setNetdiskFiles(ids) {
	getNetdiskFiles(ids);
}

function doGetNetdiskFiles(response){
	var rsp = response.responseText.trim();
	o("netdiskFilesDiv").innerHTML += rsp;
}

var errFunc = function(response) {
	// alert('Error ' + response.status + ' - ' + response.statusText);
	alert(response.responseText);
}

function getNetdiskFiles(ids) {
	var str = "ids=" + ids;
	var myAjax = new cwAjax.Request( 
		"<%=cn.js.fan.web.Global.getFullRootPath(request)%>/netdisk/ajax_getfile.jsp", 
		{ 
			method:"post",
			parameters:str,
			onComplete:doGetNetdiskFiles,
			onError:errFunc
		}
	);
}
</script>
</html>