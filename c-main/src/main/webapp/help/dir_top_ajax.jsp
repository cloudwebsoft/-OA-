<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.js.fan.db.*" %>
<%@ page import="com.redmoon.oa.pvg.*" %>
<%@ page import="com.redmoon.oa.help.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="cn.js.fan.web.*"%>
<%@ page import="com.redmoon.oa.ui.*"%>
<%@ taglib uri="/WEB-INF/tlds/LabelTag.tld" prefix="lt" %>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
if (!privilege.isUserLogin(request)) {
	out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "err_not_login")));
	return;
}

String root_code = ParamUtil.get(request, "root_code");
if (root_code.equals("")) {
	root_code = "root";
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>目录</title>
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<style>
a.link:link {
font-weight:bold;
}
a.link:visited {
font-weight:bold;
}
td {
height:20px;
}
a.node_hide {
	color:#cccccc;
}
</style>
<script src="../inc/common.js"></script>
<script>
function insertAdjacentHTML(objId,code,isStart){ 
	var obj = document.getElementById(objId);
	if(isIE()) 
		obj.insertAdjacentHTML(isStart ? "afterbegin" : "afterEnd",code); 
	else{ 
		var range=obj.ownerDocument.createRange(); 
		range.setStartBefore(obj); 
		var fragment = range.createContextualFragment(code); 
		if(isStart) 
			obj.insertBefore(fragment,obj.firstChild); 
		else 
			obj.appendChild(fragment); 
	}
}

function findObj(theObj, theDoc) {
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

function ShowChild(imgobj, name)
{
	var tableobj = findObj("childof"+name);
	if (tableobj==null) {
		document.getElementById("ifrmGetChildren").src = "dir_ajax_getchildren.jsp?root_code=" + root_code + "&parentCode=" + name;
		if (imgobj.src.indexOf("i_puls-root-1.gif")!=-1)
			imgobj.src = "images/i_puls-root.gif";
		if (imgobj.src.indexOf("i_plus.gif")!=-1) {
			imgobj.src = "images/i_minus.gif";
		}
		else
			imgobj.src = "images/i_plus.gif";
		return;
	}
	if (tableobj.style.display=="none")
	{
		tableobj.style.display = "";
		if (imgobj.src.indexOf("i_puls-root-1.gif")!=-1)
			imgobj.src = "images/i_puls-root.gif";
		if (imgobj.src.indexOf("i_plus.gif")!=-1)
			imgobj.src = "images/i_minus.gif";
		else
			imgobj.src = "images/i_plus.gif";
	}
	else
	{
		tableobj.style.display = "none";
		if (imgobj.src.indexOf("i_plus.gif")!=-1)
			imgobj.src = "images/i_minus.gif";
		else
			imgobj.src = "images/i_plus.gif";
	}
}

// 折叠目录
function shrink() {
   return;
   for(var i=0; i<document.images.length; i++) {
		var imgObj = document.images[i];
		try {
			if (imgObj.tableRelate!="") {
				ShowChild(imgObj, imgObj.tableRelate);
			}
		}
		catch (e) {
		}
   }
}
</script>
</head>
<body onLoad="shrink()">
<jsp:useBean id="dir" scope="page" class="com.redmoon.oa.help.Directory"/>
<%
String op = ParamUtil.get(request, "op");
%>
<Script>
var root_code = "<%=root_code%>";
// 使框架的bottom能得到此root_code
function getRootCode() {
	return root_code;
}
</Script>
<%
if (op.equals("AddChild")) {
	boolean re = false;
	try {
		re = dir.AddChild(request);
		if (!re) {
			out.print(StrUtil.Alert("添加节点失败，请检查编码是否重复！"));
		}
		else {
			%>
            <script>
			if (typeof(window.parent.parent.leftFileFrame)!="undefined")
				window.parent.parent.leftFileFrame.location.reload();
			</script>
            <%
		}		
	}
	catch (ErrMsgException e) {
		out.print(StrUtil.Alert(e.getMessage()));
	}
}
if (op.equals("del")) {
	String delcode = ParamUtil.get(request, "delcode");
	try {
		dir.del(request, delcode);
		out.print(StrUtil.Alert("删除成功！"));
	}
	catch (ErrMsgException e) {
		out.print(StrUtil.Alert(e.getMessage()));
	}
}if (op.equals("modify")) {
	boolean re = true;
	try {
		re = dir.update(request);
		if (re)
			out.print(StrUtil.Alert("修改完成"));
	}
	catch (ErrMsgException e) {
		out.print(StrUtil.Alert(e.getMessage()));
	}
}
if (op.equals("move")) {
	try {
		dir.move(request);
	}
	catch (ErrMsgException e) {
		out.print(StrUtil.Alert(e.getMessage()));
	}
}
if (op.equals("removecache")) {
	String curcode = ParamUtil.get(request, "code");
	LeafChildrenCacheMgr.remove(curcode);
	out.print(StrUtil.Alert(curcode + SkinUtil.LoadString(request, "res.label.cms.dir","cache_cleared")));
}
Leaf leaf = dir.getLeaf(root_code);
if (op.equals("repair")) {
	dir.repairTree(leaf);
}

if (leaf==null || !leaf.isLoaded()) {
	out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, SkinUtil.LoadString(request, "res.label.cms.dir","node") + root_code + SkinUtil.LoadString(request, "res.label.cms.dir","not_exsist")));
	return;
}
String root_name = leaf.getName();
int root_layer = leaf.getLayer();
String root_description = leaf.getDescription();
boolean isHome = false;
%>
<table width='100%' cellpadding='0' cellspacing='0' >
  <tr>
    <td class="tdStyle_1">管理&nbsp;<%=root_name%>&nbsp;&nbsp;<a href="javascript:;" onclick="showFileark()">浏览视图</a></td>
  </tr>
</table>
<br>
<TABLE class="frame_gray"  
cellSpacing=0 cellPadding=0 width="95%" align=center>
  <TBODY>
    <TR>
      <TD height=200 valign="top">
<table class="tbg1" cellspacing=0 cellpadding=0 width="100%" align=center onMouseOver="this.className='tbg1sel'" onMouseOut="this.className='tbg1'" 
border=0>
          <tbody>
            <tr>
              <td width="66%" height="13" align=left nowrap>
			  &nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td width="34%" align=right nowrap>>>&nbsp;<%=root_name%>&nbsp;&nbsp;<a href="dir_top_ajax.jsp?op=repair&root_code=<%=root_code%>">修复</a>
            &nbsp;<a href='javascript:;' onclick="addTab('类别', '<%=request.getContextPath()%>/fileark/dir_kind_list.jsp?dirCode=<%=Leaf.ROOTCODE%>')">类别</a>
            &nbsp;<a target="_parent" href="document_list_m.jsp">文件</a>
            &nbsp;<a href="dir_priv_m.jsp?dirCode=<%=StrUtil.UrlEncode(root_code)%>" target="_parent"><lt:Label res="res.label.cms.dir" key="pvg"/></a>
            &nbsp;<a target=dirbottomFrame href="dir_bottom.jsp?parent_code=<%=StrUtil.UrlEncode(root_code, "utf-8")%>&parent_name=<%=StrUtil.UrlEncode(root_name, "utf-8")%>&op=AddChild"><lt:Label res="res.label.cms.dir" key="add_content"/></a>
            &nbsp;<a target="dirbottomFrame" href="dir_bottom.jsp?op=modify&code=<%=StrUtil.UrlEncode(root_code, "utf-8")%>&name=<%=StrUtil.UrlEncode(root_name,"utf-8")%>&description=<%=StrUtil.UrlEncode(root_description,"utf-8")%>"><lt:Label res="res.label.cms.dir" key="modify"/></a>&nbsp; 
			<!--<a target=_self href="#" onClick="if (window.confirm('您确定要删除<%=root_name%>吗?')) window.location.href='dir_top_ajax?op=del&delcode=<%=root_code%>'">删除</a>-->
			  </td>
            </tr>
          </tbody>
        </table>
<%
DirectoryView tv = new DirectoryView(request, leaf);
tv.listAjax(request, out, true);
%>	</TD>
    </TR>
  </TBODY>
</TABLE>
<iframe id="ifrmGetChildren" style="display:none" src="" width="100%" height="200"></iframe>
</body>
<script>
function showFileark() {
	var pwin = window.parent;
	var ppwin = null;
	if (pwin) {
		ppwin = pwin.parent;
		if (ppwin.leftFileFrame) {
			ppwin.location.href = "frame.jsp";
			return;
		}
	}
	window.parent.location.href = "frame.jsp";
}
</script>
</html>
