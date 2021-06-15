<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="cn.js.fan.web.*" %>
<%@ page import="com.redmoon.oa.basic.*" %>
<%@ page import="com.redmoon.oa.person.*" %>
<%@ page import="com.redmoon.oa.dept.*" %>
<%@ page import="com.redmoon.oa.flow.*" %>
<%@ page import="com.redmoon.oa.flow.strategy.*" %>
<%@ page import="com.redmoon.oa.ui.*" %>
<%@ page import="org.json.*" %>
<%@ page import="com.redmoon.oa.visual.ModuleUtil" %>
<jsp:useBean id="fchar" scope="page" class="cn.js.fan.util.StrUtil"/>
<jsp:useBean id="cfg" scope="page" class="com.redmoon.oa.Config"/>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
    String priv = "admin";
    if (!privilege.isUserPrivValid(request, priv)) {
        out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
        return;
    }

    String op = ParamUtil.get(request, "op");

    String code = ParamUtil.get(request, "code");
    FormDb fd = new FormDb();
    fd = fd.getFormDb(code);

    if ("save".equals(op)) {
        String xml = ParamUtil.get(request, "xml");
        fd.setViewSetup(xml);
        boolean re = fd.saveContent();
        JSONObject json = new JSONObject();
        if (re) {
            json.put("ret", "1");
            json.put("msg", "操作成功！");
        } else {
            json.put("ret", "0");
            json.put("msg", "操作失败！");
        }
        out.print(json);
        return;
    }

    Vector fieldV = fd.getFields();
    Iterator fieldIr = fieldV.iterator();
    String options = "";
    String optionsVar = "";
    while (fieldIr.hasNext()) {
        FormField ff = (FormField) fieldIr.next();
        options += "<option value='" + ff.getName() + "' id='" + ff.getFieldType() + "' name='" + ff.getMacroType() + "' lrc='" + ff.getType() + "'>" + ff.getTitle() + "</option>";
        optionsVar += "<option value='{$" + ff.getName() + "}' id='" + ff.getFieldType() + "' name='" + ff.getMacroType() + "' lrc='" + ff.getType() + "'>" + ff.getTitle() + "</option>";
    }

    // 解析表单中的元素，包括控件、表格行、span、div
    StringBuffer opts = new StringBuffer();
    opts.append("<option value=''>无</option>");
    JSONArray ary = FormParser.getElements(request, fd);
    for (int i = 0; i < ary.length(); i++) {
        JSONObject json = ary.getJSONObject(i);
        String objId = json.getString("id");
        String objName = json.getString("name");
        if ("".equals(objId)) {
            objId = objName;
        }
        String objTitle = json.getString("title");
        if ("".equals(objTitle)) {
            if (!"".equals(objName)) {
                objTitle = objName;
            } else {
                objTitle = objId;
            }
        }

        String tagName = json.getString("tagName");
        if (tagName.equals("tr")) {
            tagName = "表格行";
        } else if (tagName.equals("input")) {
            tagName = "输入框";
        } else if (tagName.equals("textarea")) {
            tagName = "多行输入框";
        } else if (tagName.equals("select")) {
            tagName = "下拉菜单";
        } else if (tagName.equals("checkbox")) {
            tagName = "复选框";
        }
        else if (tagName.equals("radio")) {
            tagName = "单选框";
        }
        opts.append("<option value='" + objId + "'>" + tagName + ": " + objTitle + "(" + objId + ")</option>");
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>表单显示规则</title>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
    <script src="../inc/common.js"></script>
    <script src="../js/jquery-1.9.1.min.js"></script>
    <script src="../js/jquery-migrate-1.2.1.min.js"></script>
    
    <link rel="stylesheet" href="../js/bootstrap/css/bootstrap.min.css" />  
	<script src="../js/bootstrap/js/bootstrap.min.js"></script>	
    
    <link href="../js/select2/select2.css" rel="stylesheet"/>
    <script src="../js/select2/select2.js"></script>
    <script src="../js/jquery.xmlext.js"></script>
    <link href="../js/jquery-showLoading/showLoading.css" rel="stylesheet" media="screen"/>
    <script type="text/javascript" src="../js/jquery-showLoading/jquery.showLoading.js"></script>
    <script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
    <script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
    <link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet" type="text/css" media="screen"/>
    <script language="JavaScript">
        var divCount = 0;
        var count = 0;

        function onload() {
            var viewSetup = '<%=fd.getViewSetup()%>';
            if (viewSetup == "") {
                return;
            }

            var xml = $.parseXML(viewSetup);
            $xml = $(xml);

            var arrFields = [];

            var childs = $xml.find("views").children();
            childs.each(function (i) {
                // 删除ready事件中addCond中加入的第一行
                $("#views1").remove();

                count++;

                var str = "";
                var json = $.parseJSON($(this).find("display").text());
                var jsonLen = 0;
                for (var key in json) {
                    jsonLen++;
                }

                if (jsonLen == 0)
                    return;

                var conditionText = $(this).find("condition").text();
				var fieldName = $(this).find("fieldName").text();
				var operator = $(this).find("operator").text();
				var val = $(this).find("value").text();

                str += "<tr id=\"views" + count + "\">";
                str += "  <td width=\"9%\" height=\"22\" align=\"left\">";
                str += "  如果</td>";
                
                var options = "<%=options%>";
                str += '<td width="40%">';
                str += "<input id=\"condition" + count + "\" name=\"condition" + count + "\" value='" + conditionText + "' class='condition' style='display:none' />";
                str += "<span id='cond" + count + "'>";
                str += '<select name="fieldName' + count + '" id="fieldName' + count + '" style="display:inline-block;" onChange="changeFieldName(' + count + ')">';
                str += options;
                str += '</select>';
                str += '<select name="compare' + count + '" id="compare' + count + '">';
                str += '    <option value=">=">>=</option>';
                str += '    <option value="<="><=</option>';
                str += '    <option value=">">></option>';
                str += '    <option value="&lt;"><</option>';
                str += '    <option value="<>"><></option>';
                str += '    <option value="=">=</option>';
                str += '</select>';

                str += '<div id="columnInput' + count + '" style="display:inline">';
                str += '    <input type="text" name="columnName' + count + '" id="columnName' + count + '" value="" style="display:inline-block;width:100px;"/>';
                str += '</div>';
                str += '<div class="dropdown" style="display:inline">';
                str += '    <button type="button" class="btn dropdown-toggle" id="dropdownMenu1" data-toggle="dropdown">';
                str += '        <span class="caret"></span>';
                str += '    </button>';
                str += '    <ul num="' + count + '" class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu1">';
                str += '        <li role="presentation" val="<%=ModuleUtil.FILTER_CUR_DATE %>">';
                str += '            <a role="menuitem" tabindex="-1" href="#"><%=ModuleUtil.getFilterDesc(request, ModuleUtil.FILTER_CUR_DATE) %></a>';
                str += '       </li>';
                str += '       <li role="presentation" val="<%=ModuleUtil.FILTER_CUR_USER %>">';
                str += '           <a role="menuitem" tabindex="-1" href="#"><%=ModuleUtil.getFilterDesc(request, ModuleUtil.FILTER_CUR_USER) %></a>';
                str += '        </li>';
                str += '       <li role="presentation" val="mainFormOpt">';
                str += '           <a role="menuitem" tabindex="-1" href="#">表单字段</a>';
                str += '        </li>';
                str += '       <li role="presentation" val="null">';
                str += '           <a role="menuitem" tabindex="-1" href="#">空值</a>';
                str += '        </li>';
                str += '   </ul>';
                str += '</div>';
                str += '</span>';
                str += '</td>';

                // 如果condition不为空，则显示，以向下兼容
                if (""!=conditionText) {
                    str += "<script>";
                    str += "$('#cond" + count + "').hide();";
                    str += "$('#condition" + count + "').show();";
                    str += "<\/script>";
                }
                else {
                    str += "<script>";
                    str += "$('#cond" + count + "').show();";
                    str += "$('#condition" + count + "').hide();";
                    str += "<\/script>";
                }
				str += "<script>";
				str += "$('#fieldName" + count + "').val('" + fieldName + "');";
				str += "$('#compare" + count + "').val('" + operator + "');";
				str += "$('#columnName" + count + "').val('" + val + "');";
				str += "<\/script>";
					
                str += "  <td width=\"4%\">则";
                str += "  </td>";
                str += "  <td width=\"40%\" id=\"td" + count + "\">";

                arrFields.push('fieldName' + count);

                var m = 0;
                for (var key in json) {
                    str += "  <div id=\"divtd" + count + divCount + "\">";
                    str += "  <span id=\"span" + count + "\">";
                    str += "  <select id='field" + count + divCount + "' name='field" + count + "' value='" + key + "' class='field'><%=opts%></select><select id=\"field" + count + "_display\" name=\"field" + count + "_display\">";
                    str += "    <option value=\"show\" " + ((json[key] == "show") ? "selected" : "") + ">显示</option>";
                    str += "    <option value=\"hide\" " + ((json[key] == "hide") ? "selected" : "") + ">隐藏</option>";
                    str += "  </select></span>";

                    if (m == 0)
                        str += "  &nbsp;<a href=\"javascript:;\" onclick=\"addDisplay('td" + count + "', o('span" + count + "').innerHTML)\">+</a>";
                    else
                        str += "  &nbsp;<a href='javascript:;' onclick=\"$('#divtd" + count + divCount + "').remove()\" class='delBtn'>×</a>";

                    str += "  </div>";

                    str += "<script>";
                    str += "$('#field" + count + divCount + "').val('" + key + "');";
                    str += "<\/script>";

                    arrFields.push('field' + count + divCount);

                    m++;
                    divCount++;
                }

                str += "  </td>";
                str += "<td class='delBtn'>";
                str += "<a href='javascript:;' title='删除' onclick=\"$('#views" + count + "').remove();\">×</a>";

                // 第一行的count值为2，因为在页面载入时调用了addCond增加了一行，而在onload事件中又删除了这一行
                str += "&nbsp;&nbsp;<a href='javascript:;' title='上移' onclick=\"moveUp('views" + count + "')\">↑</a>";
                str += "&nbsp;&nbsp;<a href='javascript:;' title='下移' onclick=\"moveDown('views" + count + "')\">↓</a>";

                str += "</td>";
                str += "</tr>";

                $("#tabCond").append(str);
            });
            
            for (var k=0; k<arrFields.length; k++) {
                $('#' + arrFields[k]).select2();
            }
            
            if (count == 0)
                count = 1;

            initDropdownMenu();
        }

        function moveUp(trId) {
            if ($('#' + trId).prev().index() == 0) {
                jAlert('已到顶部', '提示');
                return;
            }
            $('#' + trId).prev().before($('#' + trId));
        }

        function moveDown(trId) {
            if ($('#' + trId).next()[0] == null) {
                jAlert('已到底部', '提示');
                return;
            }
            $('#' + trId).next().after($('#' + trId));
        }
    </script>
</head>
<body onload="onload()">
<%@ include file="form_edit_inc_menu_top.jsp" %>
<script>
    o("menu5").className = "current";
</script>
<div class="spacerH"></div>
<table width="100%" align="center" cellpadding="2" cellspacing="0" class="tabStyle_1 percent80" id="tabCond" style="padding:0px; margin:0px; margin-top:3px; width:100%">
    <tr>
        <td height="22" colspan="5" align="center"><input name="okbtn" type="button" onclick="ModifyView()" value="保存"/>
            &nbsp;&nbsp;
            <input type="button" value="增加" onclick="addCond()"/></td>
    </tr>
</table>
<div id="mainFormOptDiv" style="display:none"><%=optionsVar %></div>
<div class="percent80" style="width: 80%; margin: 20px auto">
    注：日期型字段格式，例：2020-10-08，2020-10-09 15:30:10，current表示当前日期
</div>
</BODY>
<style>
    .delBtn {
        font-size: 16px;
    }

    .condition {
        width: 200px;
    }

    .field {
        width: 230px;
        margin-right: 10px;
    }
</style>
<script>
    function addDisplay(tdId, html) {
        html = "<div id='div" + tdId + divCount + "'>" + html + "&nbsp;<a href='javascript:;' onclick=\"$('#div" + tdId + divCount + "').remove()\" class='delBtn' title='删除'>×</a>";

        var $obj = $(html);
        // 删除原来生成的select2
        $obj.find('.select2-container').remove();
        $("#" + tdId).append($obj.prop('outerHTML'));

        // 重新生成select2
        $('#div' + tdId + divCount).find('.field').removeClass('select2-hidden-accessible');
        $('#div' + tdId + divCount).find('.field').select2();

        divCount++;
    }

    function addCond() {
        count++;

        var str = "<tr id='views" + count + "'>";
        str += "<td>如果</td>";
        // str += "<td ><input id='condition" + count + "' name='condition" + count + "' class='condition' size=6 /></td>";

        var options = "<%=options%>";
        str += '<td>';
        str += "<input id=\"condition" + count + "\" name=\"condition" + count + "\" value='' class='condition' style='display:none' />";
        str += "<span id='cond" + count + "'>";
        str += '<select name="fieldName' + count + '" id="fieldName' + count + '" style="display:inline-block;" onChange="changeFieldName(' + count + ')">';
        str += options;
        str += '</select>';
        str += '<select name="compare' + count + '" id="compare' + count + '">';
        str += '    <option value=">=">>=</option>';
        str += '    <option value="<="><=</option>';
        str += '    <option value=">">></option>';
        str += '    <option value="&lt;"><</option>';
        str += '    <option value="<>"><></option>';
        str += '    <option value="=">=</option>';
        str += '</select>';

        str += '<div id="columnInput' + count + '" style="display:inline">';
        str += '    <input type="text" name="columnName" id="columnName' + count + '" value="" style="display:inline-block;width:100px;"/>';
        str += '</div>';
        str += '<div class="dropdown" style="display:inline">';
        str += '    <button type="button" class="btn dropdown-toggle" id="dropdownMenu1" data-toggle="dropdown">';
        str += '        <span class="caret"></span>';
        str += '    </button>';
        str += '    <ul num="' + count + '" class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu1">';
        str += '        <li role="presentation" val="<%=ModuleUtil.FILTER_CUR_DATE %>">';
        str += '            <a role="menuitem" tabindex="-1" href="#"><%=ModuleUtil.getFilterDesc(request, ModuleUtil.FILTER_CUR_DATE) %></a>';
        str += '       </li>';
        str += '       <li role="presentation" val="<%=ModuleUtil.FILTER_CUR_USER %>">';
        str += '           <a role="menuitem" tabindex="-1" href="#"><%=ModuleUtil.getFilterDesc(request, ModuleUtil.FILTER_CUR_USER) %></a>';
        str += '        </li>';
        str += '       <li role="presentation" val="mainFormOpt">';
        str += '           <a role="menuitem" tabindex="-1" href="#">表单字段</a>';
        str += '        </li>';
        str += '       <li role="presentation" val="null">';
        str += '           <a role="menuitem" tabindex="-1" href="#">空值</a>';
        str += '        </li>';
        str += '   </ul>';
        str += '</div>';
        str += '</span>';
        str += '</td>';

        str += "<td>则</td>";
        str += "<td id='td" + count + "'>";
        str += "<div><span id='span" + count + "'><select class='field' id='field" + count + "' name='field" + count + "'><%=opts%></select>";
        str += "<select id='field" + count + "_display' name='field" + count + "_display'><option value='show'>显示</option><option value='hide'>隐藏</option></select></span>";
        str += "&nbsp;<a href='javascript:;' onclick=\"addDisplay('td" + count + "', span" + count + ".innerHTML)\">+</a>";
        str += "</div>";
        str += "</td>";
        str += "<td class='delBtn'><a href='javascript:;' onclick=\"$('#views" + count + "').remove();\" title='删除'>×</a>";

        str += "&nbsp;&nbsp;<a href='javascript:;' title='上移' onclick=\"moveUp('views" + count + "')\">↑</a>";
        str += "&nbsp;&nbsp;<a href='javascript:;' title='下移' onclick=\"moveDown('views" + count + "')\">↓</a>";

        str += "</td>";
        str += "</tr>";
        $("#tabCond").append(str);
        
        $('#fieldName' + count).select2();
        $('#field' + count).select2();

        initDropdownMenu();
    }

    function changeFieldName(str){
        var obj = document.getElementById("fieldName"+str);
        var index = obj.selectedIndex;
        var val = obj.options[index].getAttribute("value");
        if (val=="cws_status") {
            var htmlStr = "<select name='columnName' id='columnName"+str+"'>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_DRAFT%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_DRAFT)%></option>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_NOT%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_NOT)%></option>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_DONE%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_DONE)%></option>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_REFUSED%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_REFUSED)%></option>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.STATUS_DISCARD%>'><%=com.redmoon.oa.flow.FormDAO.getStatusDesc(com.redmoon.oa.flow.FormDAO.STATUS_DISCARD)%></option>";
            htmlStr += "</select>";

            $("#columnInput"+str).html(htmlStr);

            $("#compare"+str).empty();
            $("#compare"+str).append("<option value='='>=</option><option value='<>'><></option>");

            return;
        }
        else if (val=="cws_flag") {
            var htmlStr = "<select name='columnName' id='columnName"+str+"'>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.FLAG_AGAINST_NO%>'>未冲抵</option>";
            htmlStr += "<option value='<%=com.redmoon.oa.flow.FormDAO.FLAG_AGAINST_YES%>'>已冲抵</option>";
            htmlStr += "</select>";

            $("#columnInput"+str).html(htmlStr);

            $("#compare"+str).empty();
            $("#compare"+str).append("<option value='='>=</option>");

            return;
        }

        var fieldType = obj.options[index].getAttribute("id");
        if (fieldType == "<%=FormField.FIELD_TYPE_TEXT%>" || fieldType == "<%=FormField.FIELD_TYPE_VARCHAR%>"){
            $("#compare"+str).empty();
            $("#compare"+str).append("<option value='='>=</option><option value='<>'><></option>");
        }else{
            $("#compare"+str).empty();
            $("#compare"+str).append("<option value='>='>>=</option><option value='<='><=</option><option value='>'>></option><option value='<'><</option><option value='='>=</option><option value='<>'><></option>");
        }

        var fieldNameType = obj.options[index].getAttribute("name");
        var lrc =obj.options[index].getAttribute("lrc");
        $.ajax({
            type: "post",
            url: "../visual/module_combination_condition.jsp",
            data : {
                op:"selectMactl",
                fieldNameType: fieldNameType,
                val:val,
                isMacro:lrc,
                moduleCode:"<%=code%>",
                mainFormCode:"<%=code%>"
            },
            dataType: "html",
            beforeSend: function(XMLHttpRequest){
            },
            success: function(data, status){
                data = $.parseJSON(data);
                if (data.ret=="1") {
                    $("#columnInput"+str).html("<select name='columnName' id='columnName"+str+"'>"+data.msg+"</select>");
                }else if (data.ret == "2"){
                    $("#compare"+str).empty();
                    $("#compare"+str).append("<option value='='>=</option><option value='<>'><></option>");
                    $("#columnInput"+str).html("<select name='columnName' id='columnName"+str+"'>"+data.msg+"</select>");
                }else{
                    $("#columnInput"+str).html("<input type='text' name='columnName' id='columnName"+str+"' value=''/>");
                }
            },
            complete: function(XMLHttpRequest, status){
            },
            error: function(XMLHttpRequest, textStatus){
                // 请求出错处理
                //alert(XMLHttpRequest.responseText);
            }
        });
    }

    function initDropdownMenu() {
        $('.dropdown-menu li').on('click', function() {
            var num = $(this).parent().attr("num");
            if ($(this).attr("val")=="mainFormOpt") {
                $("#columnInput" + num).html("<select name='columnName' id='columnName" + num + "'>"+$('#mainFormOptDiv').html()+"</select>");
            }
            else if ($(this).attr("val")=="null") {
                $("#columnInput" + num).html("<input name='columnName' id='columnName" + num + "' value='null' />");
            }
            else {
                $("#columnInput" + num).html("<input type='text' name='columnName' id='columnName" + num + "' readonly val='" + $(this).attr("val") + "' value='" + $(this).children(0).text() + "'/>");
            }
        });
    }

    $(function() {
        addCond();
    })

    function makeViews() {
        var str = "";
        var isValid = true;
        $("tr[id^='views']").each(function () {
            var trId = $(this).attr("id");
            var id = trId.substring("views".length);

            var displays = "";
            $("select[name='field" + id + "']").each(function (k) {
                if ($(this).val().trim() == "") {
                    jAlert("请选择显示或隐藏项", "提示");
                    isValid = false;
                    return false;
                }

                var nm = $(this).attr("name");

                var ary = document.getElementsByName(nm + "_display");

                var dis = ary[k].value;
                if (displays == "")
                    displays += "\"" + $(this).val() + "\":\"" + dis + "\"";
                else
                    displays += ",\"" + $(this).val() + "\":\"" + dis + "\"";
            });
            displays = "{" + displays + "}";

            str += "<view>";
            str += "<condition>" + $("#condition" + id).val().replaceAll("'", "\"") + "</condition>";

            str += "<fieldName>"+$("#fieldName"+id).val()+"</fieldName>";
            var compare = $("#compare"+id).val();
            // > < &gt; &lt;
            compare = compare.replaceAll("<", "&lt;");
            compare = compare.replaceAll(">", "&gt;");
            str += "<operator>"+compare+"</operator>";
            var val;
            if ($("#columnName"+id).attr("val")) {
                str += "<value>"+$("#columnName"+id).attr("val")+"</value>";
            }
            else {
                str += "<value>"+$("#columnName"+id).val()+"</value>";
            }

            str += "<display>" + displays + "</display>";
            str += "</view>";
        });

        if (!isValid)
            return;

        var xmlStr = "<config></config>";
        var xml = $.parseXML(xmlStr);
        $xml = $(xml);

        var $elem = $($.parseXML("<views>" + str + "</views>"));
        var newNode = null;
        if (typeof document.importNode == 'function') {
            newNode = document.importNode($elem.find('views').get(0), true);
        } else {
            newNode = $elem.find('views').get(0);
        }
        $xml.find("config").get(0).appendChild(newNode);

        $.ajax({
            type: "post",
            url: "form_view_setup.jsp",
            contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
            data: {
                op: "save",
                code: "<%=code%>",
                xml: $xml.xml()
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

    function ModifyView() {
        makeViews();
    }
</script>
</HTML>