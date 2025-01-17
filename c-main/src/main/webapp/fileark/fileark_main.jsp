<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="com.redmoon.oa.fileark.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="com.redmoon.oa.person.*" %>
<%@ page import="com.redmoon.oa.ui.*" %>
<%@ page import="com.redmoon.oa.fileark.plugin.*" %>
<%@ page import="cn.js.fan.web.SkinUtil" %>
<%
    String skincode = UserSet.getSkin(request);
    if (skincode == null || skincode.equals("")) {
        skincode = UserSet.defaultSkin;
    }
    SkinMgr skm = new SkinMgr();
    Skin skin = skm.getSkin(skincode);
    String skinPath = skin.getPath();
%>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<jsp:useBean id="dir" scope="page" class="com.redmoon.oa.fileark.Directory"/>
<!DOCTYPE HTML>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>文件柜</title>
    <link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/<%=skinPath%>/frame.css"/>
    <link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/<%=skinPath%>/css.css"/>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0" class="frameRightMain" style="width: 100%">
    <tr>
        <td>
            <%
                String dir_code = ParamUtil.get(request, "dir_code");
                if (dir_code.equals("") || dir_code.equals(Leaf.ROOTCODE)) {
                    dir_code = Leaf.ROOTCODE;
                    LeafPriv lp = new LeafPriv();
                    lp.setDirCode(dir_code);
                    if (privilege.isUserPrivValid(request, "admin") || lp.canUserSee(privilege.getUser(request))) {
                        response.sendRedirect("docListPage.do");
                        return;
                    }
                }
		else if (dir_code.equals(Leaf.CODE_DRAFT)) {
			response.sendRedirect("docListPage.do?op=search&dirCode=" + Leaf.CODE_DRAFT + "&examine1=" + Document.EXAMINE_DRAFT);
			return;
		}
                Leaf leaf = dir.getLeaf(dir_code);
                if (leaf == null) {
                    out.print(SkinUtil.makeInfo(request, "该目录已不存在！"));
                    return;
                }
                int type = leaf.getType();
                if (type == Leaf.TYPE_NONE) {
                    LeafPriv lp = new LeafPriv();
                    if (!dir_code.equals("")) {
                        lp.setDirCode(dir_code);
                    }
                    if (lp.canUserSee(privilege.getUser(request))) {
                        response.sendRedirect("docListPage.do?parentCode=" + dir_code);
                        return;
                    } else {
                        out.print(SkinUtil.makeInfo(request, "请选择目录！"));
                    }
                } else {
                    if (leaf.getType() == Leaf.TYPE_DOCUMENT) {
                        response.sendRedirect("../doc_show.jsp?dir_code=" + StrUtil.UrlEncode(leaf.getCode()));
                    } else {
                        int projectId = ParamUtil.getInt(request, "projectId", 0);
                        if (projectId == 0) {
                            response.sendRedirect("docListPage.do?dirCode=" +
                                    StrUtil.UrlEncode(leaf.getCode()) +
                                    "&dir_name=" + StrUtil.UrlEncode(leaf.getName()));
                        } else {
                            response.sendRedirect("docListPage.do?dirCode=" +
                                    StrUtil.UrlEncode(leaf.getCode()) +
                                    "&dir_name=" + StrUtil.UrlEncode(leaf.getName()) + "&projectId=" + projectId + "&parentId=" + projectId + "&formCode=project");
                        }
                    }
                }
            %>
        </td>
    </tr>
</table>
</body>
</html>
