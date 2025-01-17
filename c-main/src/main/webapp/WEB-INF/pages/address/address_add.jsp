<%@ page contentType="text/html; charset=utf-8" %>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<!DOCTYPE html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>通讯录</title>
    <link type="text/css" rel="stylesheet" href="${skinPath}/css.css"/>
    <script src="../inc/common.js"></script>
    <script src="../js/jquery-1.9.1.min.js"></script>
<script src="../js/jquery-migrate-1.2.1.min.js"></script>
    <script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
    <script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
    <link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet" type="text/css" media="screen"/>
    <link href="../js/jquery-showLoading/showLoading.css" rel="stylesheet" media="screen"/>
    <script type="text/javascript" src="../js/jquery-showLoading/jquery.showLoading.js"></script>
    <script src="../js/jquery.toaster.js"></script>
    <script src="../inc/livevalidation_standalone.js"></script>
</head>
<body>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" style="margin-bottom: 10px">
    <tr>
        <td width="100%" height="23" valign="middle" class="tdStyle_1">
            通讯录
        </td>
    </tr>
</table>
<form id="form1" name="form1" method="post">
    <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="tabStyle_1 percent98">
        <tr>
            <td class="tabStyle_1_title" height="21" colspan="4" align="left">类别</td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">类&nbsp;&nbsp;别</td>
            <td height="19" colspan="3" class="stable">
                <select name="typeId" id="typeId">
                    <option value="">-----请选择-----</option>
                    ${dirOpts}
                </select>
                <script>
                    o("typeId").value = "{$typeId}";
                </script>
            </td>
        </tr>
        <tr>
            <td height="21" colspan="4" align="left" class="tabStyle_1_title">个人信息</td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">姓&nbsp;&nbsp;名</td>
            <td height="19" class="stable"><input name="person" size=50>
                <input type="hidden" name="type" value="${type}">
                <script>
                    var person = new LiveValidation('person');
                    person.add(Validate.Presence);
                    person.add(Validate.Length, {minimum: 1, maximum: 50});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">单&nbsp;&nbsp;位</td>
            <td height="19" colspan="3" class="stable"><input name="company" size=35>
                <script>
                    var company = new LiveValidation('company');
                    company.add(Validate.Length, {maximum: 20});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">职&nbsp;&nbsp;务</td>
            <td height="19" colspan="3" class="stable"><input name="job" size=35>
                <script>
                    var job = new LiveValidation('job');
                    job.add(Validate.Length, {maximum: 20});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">手&nbsp;&nbsp;机</td>
            <td height="19" colspan="3" class="stable"><input name="mobile" size="35"/>
                <script>
                    var mobile = new LiveValidation('mobile');
                    mobile.add(Validate.Mobile);
                    //mobile.add( Validate.Length, { is: 11 } );
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">短&nbsp;&nbsp;号</td>
            <td height="19" colspan="3" class="stable"><input name="MSN" size="25"/>
                <script>
                    var MSN = new LiveValidation('MSN');
                    MSN.add(Validate.Length, {maximum: 20});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">Email</td>
            <td height="19" colspan="3" class="stable"><input name="email" size=35>
                <script>
                    var email = new LiveValidation('email');
                    email.add(Validate.Email);
                    email.add(Validate.Length, {maximum: 40});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">微信</td>
            <td height="19" colspan="3" class="stable"><input name="weixin" size=25>
                <script>
                    var weixin = new LiveValidation('weixin');
                    weixin.add(Validate.Length, {maximum: 45});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">电话</td>
            <td height="19" colspan="3" class="stable"><input name="tel" size=25>
                <script>
                    var tel = new LiveValidation('tel');

                    tel.add(Validate.Length, {maximum: 20});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">传真</td>
            <td height="19" colspan="3" class="stable"><input name="fax" size=35>
                <script>
                    var fax = new LiveValidation('fax');
                    fax.add(Validate.Length, {maximum: 20});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">QQ</td>
            <td height="19" colspan="3" class="stable"><input name="QQ" size=25>
                <script>
                    var QQ = new LiveValidation('QQ');
                    QQ.add(Validate.Numericality);
                    QQ.add(Validate.Length, {maximum: 20});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">网页</td>
            <td height="19" colspan="3" class="stable"><input name="web" size=35>
                <script>
                    var web = new LiveValidation('web');
                    web.add(Validate.Length, {maximum: 50});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">邮编</td>
            <td height="19" colspan="3" class="stable"><input name="postalcode" size=35>
                <script>
                    var companyPostcode = new LiveValidation('companyPostcode');
                    companyPostcode.add(Validate.Numericality);
                    companyPostcode.add(Validate.Length, {maximum: 50});
                </script>
            </td>
        </tr>
        <tr>
            <td height="19" align="center" class="stable">地址</td>
            <td height="19" colspan="3" class="stable"><input name="address" size=45>
                <script>
                    var address = new LiveValidation('address');
                    address.add(Validate.Length, {maximum: 50});
                </script>
            </td>
        </tr>
        <tr>
            <td height="17" align="center" class="stable">附注</td>
            <td height="17" colspan="3" class="stable"><textarea name="introduction" cols="50" rows="8"></textarea>
                <script>
                    var introduction = new LiveValidation('introduction');
                    introduction.add(Validate.Length, {maximum: 500});
                </script>
            </td>
        </tr>
        <tr>
            <td colspan="4" align="center" class="stable"><input id="btnSubmit" type="button" class="btn" value="确定"></td>
        </tr>
    </table>
</form>
</body>
<script>
    $('#btnSubmit').click(function() {
        var params = $("#form1").serialize();
        $.ajax({
            type: "post",
            url: "create.do",
            contentType:"application/x-www-form-urlencoded; charset=UTF-8",
            data: params,
            dataType: "html",
            beforeSend: function(XMLHttpRequest){
                $('body').showLoading();
            },
            success: function(data, status){
                data = $.parseJSON(data);
                if (data.ret == "1") {
                    $.toaster({priority: 'info', message: data.msg});
                    window.location.href = "list.do?type=${type}&dir_code=${typeId}";
                } else {
                    $.toaster({priority: 'info', message: data.msg});
                }
            },
            complete: function(XMLHttpRequest, status){
                $('body').hideLoading();
            },
            error: function(XMLHttpRequest, textStatus){
                // 请求出错处理
                alert(XMLHttpRequest.responseText);
            }
        });
    })
</script>
</html>
