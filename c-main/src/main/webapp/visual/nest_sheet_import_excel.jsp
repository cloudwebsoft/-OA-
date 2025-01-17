<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="cn.js.fan.util.ErrMsgException" %>
<%@ page import="cn.js.fan.util.ParamUtil" %>
<%@ page import="cn.js.fan.util.StrUtil" %>
<%@ page import="com.cloudweb.oa.api.INestSheetCtl" %>
<%@ page import="com.cloudweb.oa.service.MacroCtlService" %>
<%@ page import="com.cloudweb.oa.utils.SpringUtil" %>
<%@ page import="com.redmoon.oa.flow.FormDb" %>
<%@ page import="com.redmoon.oa.ui.SkinMgr" %>
<%@ page import="com.redmoon.oa.visual.ModuleSetupDb" %>
<%@ page import="java.util.Enumeration" %>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>导入Excel</title>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
    <%
        String formCode = ParamUtil.get(request, "formCode");
        String moduleCode = ParamUtil.get(request, "moduleCode");
        if ("".equals(moduleCode)) {
            moduleCode = formCode;
        }
        long parentId = ParamUtil.getLong(request, "parentId", -1);
        int flowId = ParamUtil.getInt(request, "flowId", com.redmoon.oa.visual.FormDAO.NONEFLOWID);
        MacroCtlService macroCtlService = SpringUtil.getBean(MacroCtlService.class);
        INestSheetCtl ntc = macroCtlService.getNestSheetCtl();
        String op = ParamUtil.get(request, "op");
        StringBuffer requestParamBuf = new StringBuffer();
        Enumeration reqParamNames = request.getParameterNames();
        while (reqParamNames.hasMoreElements()) {
            String paramName = (String) reqParamNames.nextElement();
            String[] paramValues = request.getParameterValues(paramName);
            if (paramValues.length == 1) {
                String paramValue = ParamUtil.getParam(request, paramName);
                // 过滤掉formCode等
                if ("code".equals(paramName)
                        || "formCode".equals(paramName)
                        || "moduleCode".equals(paramName)
                        || "flowId".equals(paramName)
                        || "op".equals(paramName)
                ) {
                    ;
                } else {
                    // 传入在定制时，可能带入的其它参数
                    StrUtil.concat(requestParamBuf, "&", paramName + "=" + StrUtil.UrlEncode(paramValue));
                }
            }
        }

        if ("add".equals(op)) {
            try {
                int rows = ntc.uploadExcel(application, request, parentId);
                if (rows > 0) {
    %>
    <script>
        if (window.opener != null) {
            // window.opener.location.reload();
            window.opener.refreshNestSheetCtl<%=moduleCode%>();
            window.close();
        }
    </script>
    <% return;
    } else {
        out.print(StrUtil.Alert("文件不能为空"));
    }
    } catch (ErrMsgException e) {
        out.print(StrUtil.Alert_Back(e.getMessage()));
    }
    }
    %>
</head>
<body>
<form name="form1"
      action="nest_sheet_import_excel.jsp?op=add&moduleCode=<%=moduleCode%>&formCode=<%=StrUtil.UrlEncode(formCode)%>&parentId=<%=parentId %>&<%=requestParamBuf.toString()%>"
      method="post" encType="multipart/form-data">
    <table width="409" border="0" align="center" cellspacing="0" class="tabStyle_1 percent98">
        <thead>
        <tr>
            <td align="left" class="right-title">&nbsp;请选择需导入的文件</td>
        </tr>
        </thead>
        <tr>
            <td width="319" align="left">
                <input title="选择附件文件" type="file" size="20" name="excel">
                <input name="formCode" value="<%=formCode%>" type=hidden>
                <input name="moduleCode" value="<%=moduleCode%>" type=hidden>
                <input name="flowId" value="<%=flowId%>" type=hidden>
                <input class="btn" name="submit" type="submit" value="确  定"/></td>
        </tr>
        <tr>
            <td align="left">
                Excel文件表头：
                <a target="_blank"
                   href="nest_import_excel_template.jsp?moduleCode=<%=moduleCode%>&formCode=<%=formCode%>">下载模板</a>
                <br/>
                <%
                    ModuleSetupDb msd = new ModuleSetupDb();
                    msd = msd.getModuleSetupDbOrInit(moduleCode);
                    String[] fieldCodes = msd.getColAry(false, "list_field");

                    FormDb fd = new FormDb();
                    fd = fd.getFormDb(formCode);
                    String str = "";
                    if (fieldCodes != null) {
                        for (String fieldCode : fieldCodes) {
                            if ("".equals(str)) {
                                str = fd.getFormField(fieldCode).getTitle();
                            } else {
                                str += "&nbsp;|&nbsp;" + fd.getFormField(fieldCode).getTitle();
                            }
                        }
                    }
                    out.print(str);
                %>
            </td>
        </tr>
    </table>
</form>
</body>
</html>
