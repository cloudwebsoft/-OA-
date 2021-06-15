<%@ page contentType="text/html;charset=GBK" %>
<%@page import="com.redmoon.oa.report.ReportManageDb" %>
<%@page import="java.net.URLEncoder" %>
<%@page import="java.net.URLDecoder" %>
<%@ taglib uri="/WEB-INF/tlds/runqianReport4.tld" prefix="report" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.runqian.report4.usermodel.Context" %>
<%@ page import="cn.js.fan.db.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="com.cloudwebsoft.framework.db.*" %>
<%@ page import="com.redmoon.oa.Config" %>
<%@ page import="com.redmoon.oa.flow.FormDb" %>
<%@ page import="com.redmoon.oa.visual.FormDAO" %>
<%@ page import="com.redmoon.oa.visual.FormDAOLog" %>
<%@ page import="cn.js.fan.web.Global" %>
<%@ page import="com.redmoon.oa.sys.DebugUtil" %>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<html>
<!--
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
-->
<link type="text/css" href="css/style.css" rel="stylesheet"/>
<script src="../inc/common.js" type="text/javascript"></script>
<script src="../js/jquery-1.9.1.min.js"></script>
<script src="../js/jquery-migrate-1.2.1.min.js"></script>
<script type="text/javascript" src="../util/jscalendar/calendar.js"></script>
<script type="text/javascript" src="../util/jscalendar/lang/calendar-zh.js"></script>
<script type="text/javascript" src="../util/jscalendar/calendar-setup.js"></script>
<script type="text/javascript" src="../ckeditor/ckeditor.js" mce_src="../ckeditor/ckeditor.js"></script>
<style type="text/css"> @import url("../util/jscalendar/calendar-win2k-2.css"); </style>
<style type="text/css">
    #watermark {
        width: 100%;
        height: 100%;
        background: red;
        background-color: #ffffff;
        position: absolute;
        z-index: 10;
        opacity: 1;
        filter: alpha(opacity=100);
    }
</style>
<body topmargin=0 leftmargin=0 rightmargin=0 bottomMargin=0>
<%
    // request.setCharacterEncoding( "utf-8" );
    //String report = request.getParameter("raq");
    //report = new String (report.getBytes("iso8859-1"),"utf-8");
    //report = URLDecoder.decode(report,"utf-8");
    int id = ParamUtil.getInt(request, "id", -1);        //�õ����������

    if (id == -1) {
        out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "err_id") + " id=" + id));
        return;
    }

    //���ݴ����ļ������ƻ�ȡ����Ȩ�޼���
    ReportManageDb rmdb = new ReportManageDb();
    rmdb = (ReportManageDb) rmdb.getQObjectDb(id);
    String priv_code = "";
    String report = "";
    if (rmdb != null) {
        priv_code = rmdb.getString("priv_code");
        report = rmdb.getString("name");
    }
    String[] privArr = priv_code.split(",");
    boolean isValid = false;
    if (privArr != null && privArr.length > 0) {
        for (int i = 0; i < privArr.length; i++) {
            if (privilege.isUserPrivValid(request, privArr[i]) || privArr[i].equals("")) {
                isValid = true;
                break;
            }
        }
    }
    if (!isValid) {
        out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
        return;
    }

    Config cfg = new Config();
    // ���������־
    if (cfg.getBooleanProperty("isModuleLogRead")) {
        FormDb fd = new FormDb("module_log_read");
        FormDAO fdao = new FormDAO(fd);
        fdao.setFieldValue("read_type", String.valueOf(FormDAOLog.READ_TYPE_REPORT));
        fdao.setFieldValue("log_date", DateUtil.format(new Date(), "yyyy-MM-dd HH:mm:ss"));
        fdao.setFieldValue("module_code", "");
        fdao.setFieldValue("form_code", "");
        fdao.setFieldValue("module_id", String.valueOf(id));
        fdao.setFieldValue("form_name", "");
        fdao.setFieldValue("user_name", privilege.getUser(request));
        fdao.setCreator(privilege.getUser(request)); // ����Ϊ�û�����������¼�ߣ�
        fdao.setUnitCode(privilege.getUserUnitCode(request)); // �õ�λ����
        fdao.setFlowTypeCode(String.valueOf(System.currentTimeMillis())); // �������ֶΡ����̱��롱��������ȡ���ղ���ļ�¼��Ҳ����Ϊ��
        boolean re = fdao.create();
    }

    String reportFileHome = Context.getInitCtx().getMainDir();
    reportFileHome = "reportFiles";
    StringBuffer param = new StringBuffer();

    //��֤�������Ƶ�������
    int iTmp = 0;
    if ((iTmp = report.lastIndexOf(".raq")) <= 0) {
        report = report + ".raq";
        iTmp = 0;
    }

    Enumeration paramNames = request.getParameterNames();
    if (paramNames != null) {
        while (paramNames.hasMoreElements()) {
            String paramName = (String) paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            // DebugUtil.i(getClass(), paramName, paramValue);
            paramValue = new String(paramValue.getBytes("iso-8859-1"), "GB2312");
            // DebugUtil.i(getClass(), paramName + "2", paramValue);
    
            if ("userName1".equals(paramName)) {
                paramValue = new String(request.getParameter("userName").getBytes("iso-8859-1"), "GB2312");
            }
    
            if (paramValue != null) {
                try {
                    com.redmoon.oa.security.SecurityUtil.antiXSS(request, privilege, paramName, paramValue, getClass().getName());
                } catch (ErrMsgException e) {
                    out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, e.getMessage()));
                    return;
                }

                //�Ѳ���ƴ��name=value;name2=value2;.....����ʽ
                param.append(paramName).append("=").append(paramValue).append(";");
            }
        }
    }

    //���´����Ǽ����������Ƿ�����Ӧ�Ĳ���ģ��
    String paramFile = report.substring(0, iTmp) + "_arg.raq";
    // File f = new File(application.getRealPath(reportFileHome + File.separator + paramFile));
    File f = new File(Global.getRealPath() + reportFileHome + File.separator + paramFile);
%>
<jsp:include page="toolbar.jsp" flush="false"/>
<table id="rpt" align="center">
    <tr>
        <td>
            <% //�������ģ����ڣ�����ʾ����ģ��
                if (f.exists()) {
            %>
            <table id="param_tbl" width="100%" height="100%">
                <tr>
                    <td <%--align="center" �����Ϊ���У���ĳЩ����ı��������δ���У�����ѯ����������ʹ�÷���������������--%>>
                        <report:param name="form1" paramFileName="<%=paramFile%>"
                                      needSubmit="no"
                                      params="<%=param.toString()%>"/>
                    </td>
                    <td id="btnTd">
                        <a id="btnSearch" style="display: none; margin-left: 10px" href="javascript:_submit( form1 )">
                            <img src="../images/search.png" border=no style="vertical-align:middle">
                        </a>
                        <%
                            String val = StrUtil.getNullStr(request.getParameter("userName"));
                            String valGb2312 = new String(val.getBytes("iso-8859-1"), "GB2312");
                            // DebugUtil.i(getClass(), "valGb2312", valGb2312);
                        %>
                        <script>
                            $(function() {
                                o("form1").action = "showReport.jsp?id=<%=id%>&userName=<%=StrUtil.UrlEncode(valGb2312, "GB2312")%>";
                                // o("resultPage").value = "/reportJsp/showReport.jsp?id=<%=id%>&userName=<%=StrUtil.UrlEncode(valGb2312, "GB2312")%>";
                                // console.log("action=2" + o("form1").action);
                            });
                        </script>
                    </td>
                </tr>
            </table>
            <%
                }
            %>
            <report:html name="report1" reportFileName="<%=report%>"
                         funcBarLocation="top"
                         needPageMark="no"
                         generateParamForm="no"
                         needPrintPrompt="no"
                         params="<%=param.toString()%>"
                         exceptionPage="/reportJsp/myError2.jsp"
                         appletJarName="runqianReport4Applet.jar,dmGraphApplet.jar"
                         width="-1"
                         height="-1"
            />
        </td>
    </tr>
</table>
<div id="watermark" style="width: 2000px;height: 50px; margin-top: -30px;"></div>
<script language="javascript">
    //���÷�ҳ��ʾֵ

    document.getElementById("t_page_span").innerHTML = report1_getTotalPage();
    document.getElementById("c_page_span").innerHTML = report1_getCurrPage();

    // ���񱨱��ѯ
    function query() {
        var start_date = document.getElementById("begin_date").value;
        var end_date = document.getElementById("end_date").value;
        var start_month = document.getElementById("month_1").value;
        var end_month = document.getElementById("month_2").value;
        window.location.href = "<%=request.getContextPath()%>/reportJsp/showReport.jsp?id=<%=id%>&start_date=" + start_date + "&end_date=" +
            end_date + "&start_month=" + start_month + "&end_month=" + end_month;
    }

    function jb_query() {
        var year = document.getElementById("year").value;
        window.location.href = "<%=request.getContextPath()%>/reportJsp/showReport.jsp?id=<%=id%>&year=" + year;

    }

    // ��ҳ�����ɵ�һ���ύ����
    window.onload = function () {
        $('#report1_prompt').hide();
        $('#watermark').hide();
        if (document.getElementById("runqian_submit"))
            document.getElementById("runqian_submit").style.display = "none";
    }
</script>
</body>
<script>
    // ʹ��ѯ��ť�����ڲ����ؼ��Ҳ�
    $(function () {
        // �ҵ����в����ؼ�����һ��
        var $trs = $('#form1_tbl tr');
        $trs.each(function(k) {
            var $tr = $(this).children('td');
            // �ж�tr�Ƿ���ʾ
            if ($(this).css("display") != "none") {
                var lastParamTdIndex = -1;
                $tr.each(function (i) {
                    if ($(this).attr('paramname')) {
                        lastParamTdIndex = i;
                    }
                });
                if (lastParamTdIndex != -1) {
                    $tr.eq(lastParamTdIndex + 1).html($('#btnTd').html());
                    return false;
                }
            }
        })

        $('#btnSearch').show();
        
        // ����pdf��ť
        $('.pdf').parent().parent().hide();
    })
</script>
</html>
