<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="cn.js.fan.db.*" %>
<%@ page import="com.redmoon.oa.person.*" %>
<%@ page import="com.redmoon.oa.flow.*" %>
<%@ page import="com.redmoon.oa.dept.*" %>
<%@page import="com.redmoon.oa.ui.SkinMgr" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>当前用户宏控件属性</title>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
    <script src="../../js/jquery-1.9.1.min.js"></script>
    <script src="../../js/jquery-migrate-1.2.1.min.js"></script>
    <script>
        $(function() {
            var win = window.opener;
            var desc = win.document.getElementById('orgvalue').value;
            if (desc=="") {
                desc = win.document.getElementById('description').value;
            }
            if (desc=="") {
                return;
            }
            if (desc.indexOf('{')==0) {
                var json = $.parseJSON(desc);
                $('#gender').val(json.gender);
                $('#mobile').val(json.mobile);
                $('#address').val(json.address);
                $('#idCard').val(json.idCard);
                $('#entryDate').val(json.entryDate);
                $('#birthday').val(json.birthday);
            }
        })
    </script>
</head>
<body>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
    String formCode = ParamUtil.get(request, "formCode");
    if (formCode.equals("")) {
        out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, "请先创建表单，然后编辑表单时插入此控件！"));
        return;
    }

    String opts = "<option value=''>无</option>";
    FormDb fd = new FormDb();
    fd = fd.getFormDb(formCode);
    Iterator ir = fd.getFields().iterator();
    while (ir.hasNext()) {
        FormField ff = (FormField)ir.next();
        opts += "<option value='" + ff.getName() + "'>" + ff.getTitle() + "</option>";
    }
%>
<table width="100%" height="324" cellPadding="0" cellSpacing="0">
    <tbody>
    <tr>
        <td height="28" colspan="2" class="tabStyle_1_title">&nbsp;映射字段</td>
    </tr>
    <tr>
        <td width="15%" height="42" align="center">性别</td>
        <td width="85%" align="left">
            <select id="gender" name="gender">
                <%=opts%>
            </select>
        </td>
    </tr>
    <tr>
        <td width="15%" height="42" align="center">手机</td>
        <td width="85%" align="left">
            <select id="mobile" name="mobile">
                <%=opts%>
            </select>
        </td>
    </tr>
    <tr>
        <td height="42" align="center">身份证</td>
        <td align="left">
            <select id="idCard" name="idCard">
                <%=opts%>
            </select>
        </td>
    </tr>
    <tr>
      <td height="42" align="center">地址</td>
      <td align="left">
          <select id="address" name="address">
              <%=opts%>
          </select>
      </td>
    </tr>
    <tr>
        <td height="42" align="center">入职时间</td>
        <td align="left">
            <select id="entryDate" name="entryDate">
                <%=opts%>
            </select>
        </td>
    </tr>
    <tr>
        <td height="42" align="center">生日</td>
        <td align="left">
            <select id="birthday" name="birthday">
                <%=opts%>
            </select>
        </td>
    </tr>
    <tr>
      <td height="42" colspan="2" align="center">
          <input type="button" class="btn" value="确定" onclick="ok()"/>
          &nbsp;&nbsp;
          <input type="button" class="btn" value="取消" onclick="window.close()"/>
      </td>
      </tr>
    <tr>
      <td height="42" colspan="2" align="center">注：无需映射，则选择空</td>
    </tr>
    </tbody>
</table>
</body>
<script language="javascript">
    function ok() {
        var json = {};
        json.gender = $('#gender').val();
        json.mobile = $('#mobile').val();
        json.address = $('#address').val();
        json.idCard = $('#idCard').val();
        json.entryDate = $('#entryDate').val();
        json.birthday = $('#birthday').val();
        window.opener.setSequence(JSON.stringify(json), "");
        window.close();
    }
</script>
</html>