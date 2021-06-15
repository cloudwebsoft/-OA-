<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import = "java.util.*"%>
<%@ page import = "cn.js.fan.db.*"%>
<%@ page import = "cn.js.fan.web.*"%>
<%@ page import = "cn.js.fan.util.*"%>
<%@ page import = "com.redmoon.oa.visual.*"%>
<%@ page import = "com.redmoon.oa.flow.FormDb"%>
<%@ page import = "com.redmoon.oa.flow.FormField"%>
<%@ page import="com.redmoon.oa.ui.*"%>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
String priv = "read";
if (!privilege.isUserPrivValid(request, priv))
{
	// out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
	// return;
}

String op = ParamUtil.get(request, "op");
String formCode = "sales_product_service";

String querystr = "";

FormDb fd = new FormDb();
fd = fd.getFormDb(formCode);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title><%=fd.getName()%>列表</title>
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<%@ include file="../inc/nocache.jsp"%>
<script>
function sel(sth) {
	window.opener.setIntpuObjValue(sth);
	window.close();
}
</script>
</head>
<body>
<%
String sql = "select id from " + fd.getTableNameByForm();		

String query = ParamUtil.get(request, "query");
if (!query.equals(""))
	sql = query;
else
	if (op.equals("search")) {
		Iterator ir = fd.getFields().iterator();
		String cond = "";
		while (ir.hasNext()) {
			FormField ff = (FormField)ir.next();
			String value = ParamUtil.get(request, ff.getName());
			String name_cond = ParamUtil.get(request, ff.getName() + "_cond");
			if (ff.getType().equals(ff.TYPE_DATE) || ff.getType().equals(ff.TYPE_DATE_TIME)) {
				String fDate = ParamUtil.get(request, ff.getName() + "FromDate");
				String tDate = ParamUtil.get(request, ff.getName() + "ToDate");
				if (!fDate.equals("")) {
					if (cond.equals(""))
						cond += ff.getName() + ">=" + StrUtil.sqlstr(fDate);
					else
						cond += " and " + ff.getName() + ">=" + StrUtil.sqlstr(fDate);
				}
				if (!tDate.equals("")) {
					if (cond.equals(""))
						cond += ff.getName() + "<=" + StrUtil.sqlstr(tDate);
					else
						cond += " and " + ff.getName() + "<=" + StrUtil.sqlstr(tDate);
				}
			}
			else {
				if (name_cond.equals("0")) {
					if (!value.equals("")) {
						if (cond.equals(""))
							cond += ff.getName() + " like " + StrUtil.sqlstr("%" + value + "%");
						else
							cond += " and " + ff.getName() + " like " + StrUtil.sqlstr("%" + value + "%");
					}
				}
				else if (name_cond.equals("1")) {
					if (!value.equals("")) {
						if (cond.equals(""))
							cond += ff.getName() + "=" + StrUtil.sqlstr(value);
						else
							cond += " and " + ff.getName() + "=" + StrUtil.sqlstr(value);
					}
				}
			}
		}
		if (!cond.equals(""))
			sql = sql + " where " + cond;	
	}
querystr = "query=" + StrUtil.UrlEncode(sql);
%>
<form id="form2" name="form2" action="?op=search" method="post">
  <table class="tabStyle_1 percent98" cellspacing="0" cellpadding="0" width="100%" border="0">
    <tbody>
      <tr>
        <td class="tabStyle_1_title" colspan="3">服务型产品查询</td>
      </tr>
      <tr>
        <td width="29%">服务提供商：</td>
        <td nowrap="nowrap" width="19%"><select name="provider_cond">
          <option value="1">等于</option>
          <option value="0" selected="selected">包含</option>
        </select></td>
        <td width="52%"><input name="provider" size="20" /></td>
      </tr>
      <tr>
        <td width="29%">服务名称：</td>
        <td nowrap="nowrap" width="19%"><select name="service_name_cond">
          <option value="1">等于</option>
          <option value="0" selected="selected">包含</option>
        </select></td>
        <td width="52%"><input name="service_name" size="20" /></td>
      </tr>
      <tr>
        <td width="29%">服务收费标准：</td>
        <td nowrap="nowrap" width="19%"><select name="standad_name_cond">
          <option value="1">等于</option>
          <option value="0" selected="selected">包含</option>
        </select></td>
        <td width="52%"><input name="standad_name" size="20" /></td>
      </tr>
      <tr>
        <td colspan="3" align="center"><input class="btn"  type="submit" value="查  询" name="submit" /></td>
      </tr>
    </tbody>
  </table>
</form>
<%
		int pagesize = 10;
		Paginator paginator = new Paginator(request);
		int curpage = paginator.getCurPage();
			
		FormDAO fdao = new FormDAO();
		
		ListResult lr = fdao.listResult(formCode, sql, curpage, pagesize);
		long total = lr.getTotal();
		Vector v = lr.getResult();
	    Iterator ir = null;
		if (v!=null)
			ir = v.iterator();
		paginator.init(total, pagesize);
		// 设置当前页数和总页数
		int totalpages = paginator.getTotalPages();
		if (totalpages==0)
		{
			curpage = 1;
			totalpages = 1;
		}
%>
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td align="right">找到符合条件的记录 <b><%=paginator.getTotal() %></b> 条　每页显示 <b><%=paginator.getPageSize() %></b> 条　页次 <b><%=curpage %>/<%=totalpages %></td>
  </tr>
</table>
<table class="tabStyle_1 percent98" width="98%" border="0" align="center" cellpadding="2" cellspacing="1">
  <tr align="center">
    <td class="tabStyle_1_title" width="26%">服务产品名称</td>
    <td class="tabStyle_1_title" width="20%">收费标准</td>
    <td class="tabStyle_1_title" width="17%">操作</td>
  </tr>
  <%	
	  	int i = 0;
		while (ir!=null && ir.hasNext()) {
			fdao = (FormDAO)ir.next();
			i++;
			long id = fdao.getId();
		%>
  <tr align="center">
    <td width="26%"><a href="product_service_show.jsp?id=<%=id%>&amp;formCode=<%=formCode%>"><%=fdao.getFieldValue("service_name")%></a></td>
    <td width="20%"><%=fdao.getFieldValue("standad_name")%></td>
    <td width="17%">&nbsp;&nbsp;<a href="javascript:sel('<%=fdao.getFieldValue("service_name")%>')">选择</a>&nbsp;&nbsp; </td>
  </tr>
  <%
		}
%>
</table>
<table width="98%" border="0" cellspacing="1" cellpadding="3" align="center" class="9black">
  <tr>
    <td height="23" align="right">
      <%
			out.print(paginator.getCurPageBlock("?"+querystr));
			%>    </td>
  </tr>
</table>
</body>
</html>
