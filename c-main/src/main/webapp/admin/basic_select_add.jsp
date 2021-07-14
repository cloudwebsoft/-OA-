<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import = "java.net.URLEncoder"%>
<%@ page import = "com.cloudwebsoft.framework.db.*"%>
<%@ page import = "java.util.*"%>
<%@ page import = "cn.js.fan.util.*"%>
<%@ page import = "cn.js.fan.web.SkinUtil"%>
<%@ page import = "com.redmoon.oa.basic.*"%>
<%@ page import = "com.redmoon.oa.pvg.*"%>
<%@ page import = "com.redmoon.oa.person.*"%>
<%@ page import = "java.util.*"%>
<%@ page import = "cn.js.fan.db.*"%>
<%@ page import = "cn.js.fan.web.*"%>
<%@ page import="com.redmoon.oa.ui.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>基础数据管理</title>
<script src="../inc/common.js"></script>
</head>
<jsp:useBean id="fchar" scope="page" class="cn.js.fan.util.StrUtil"/>
<body>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
int kind = ParamUtil.getInt(request, "kind", -1);

String userName = privilege.getUser(request);
SelectKindPriv skp = new SelectKindPriv();
if (!privilege.isUserPrivValid(request, PrivDb.PRIV_ADMIN)) {
	if (skp.canUserAppend(userName, kind) || skp.canUserModify(userName, kind) || skp.canUserDel(userName, kind)) {
	}
	else {	  
		out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
		return;
	}
}
%>
<%@ include file="basic_select_inc_menu_top.jsp"%>
<script>
$("menu2").className="current";
</script>
<div class="spacerH"></div>
<table width="45%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabStyle_1 percent80">
  <form action="basic_select_list.jsp" method="post" name="form1" id="form1">
    <tbody>
      <tr>
        <td colspan="2" align="left" class="tabStyle_1_title">&nbsp;增加基础数据</td>
      </tr>
      <tr>
        <td height="26" align="right">编&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;码：</td>
        <td align="left"><input name="code" /></td>
      </tr>
      <tr>
        <td height="26" align="right">名&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;称：</td>
        <td align="left"><input name="name" id="name" />
          &nbsp;
          <input type="hidden" name="op" value="add" />        </td>
      </tr>
      <tr>
        <td height="26" align="right">类&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;别：</td>
        <td align="left">
		<select name="type">
		<option value="<%=SelectDb.TYPE_LIST%>">列表</option>
		<option value="<%=SelectDb.TYPE_TREE%>">树状</option>
		</select>
	  </td>
      </tr>
      <tr>
        <td height="26" align="right">序&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;号：</td>
        <td align="left"><input name="orders"  id="orders" size="5" value="0" /></td>
      </tr>
      <tr>
        <td height="26" align="right">类&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;型：</td>
        <td align="left">
      <%
	  SelectKindDb wptd = new SelectKindDb();
	  if (privilege.isUserPrivValid(request, PrivDb.PRIV_ADMIN)) {	  
		  String opts = "";
		  Iterator ir = wptd.list().iterator();
		  while (ir.hasNext()) {
		  	wptd = (SelectKindDb)ir.next();
		  	opts += "<option value='" + wptd.getId() + "'>" + wptd.getName() + "</option>";
		  }
		  %>
	      <select name="kind" id="kind">
			<option value="-1">无</option>
			<%=opts%>
		  </select>
		  <script>
		  form1.kind.value = "<%=kind%>";
		  </script>
	  <%}else{
	  	wptd = wptd.getSelectKindDb(kind);
	  	out.print(wptd.getName());
	  	%>
	  	<input type="hidden" name="kind" value="<%=kind %>"/>
	  	<%
	  }%>
		</td>
      </tr>
      <tr>
        <td height="30" colspan="2" align="center"><input name="button" type="submit" class="btn"  value="确定 " />
          &nbsp;&nbsp;&nbsp;</td>
      </tr>
    </tbody>
  </form>
</table>
</body>
</html>
