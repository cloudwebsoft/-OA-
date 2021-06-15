<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.js.fan.db.*" %>
<%@ page import="com.redmoon.oa.dept.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import = "com.redmoon.oa.person.*"%>
<%@ page import = "com.redmoon.oa.ui.*"%>
<%@ page import = "cn.js.fan.cache.jcs.*"%>
<%@ page import = "org.json.*"%>
<%@page import="com.cloudwebsoft.framework.db.JdbcTemplate"%>
<%@page import="com.redmoon.oa.basic.TreeSelectView"%>
<%@page import="com.redmoon.oa.basic.TreeSelectDb"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=8">
<META HTTP-EQUIV="pragma" CONTENT="no-cache"> 
<META HTTP-EQUIV="Cache-Control" CONTENT= "no-cache, must-revalidate"> 
<META HTTP-EQUIV="expires" CONTENT= "Wed, 26 Feb 1997 08:21:57 GMT">
<title>部门管理</title>
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<script src="../inc/common.js"></script>
<link type="text/css" rel="stylesheet" href="<%=request.getContextPath() %>/js/jstree/themes/default/style.css" />
<script src="<%=request.getContextPath() %>/js/jquery.my.js"></script>
<script src="<%=request.getContextPath() %>/js/jstree/jstree.js"></script>
<script src="<%=request.getContextPath() %>/js/jquery.toaster.js"></script>
<style>
td {
	height:20px;
}
.unit {
	font-weight:bold; 
}
.deptNodeHidden {
	color:#cccccc;
}
</style>
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

function ShowChild(imgobj, name) {
	var tableobj = o("childof"+name);
	if (tableobj==null) {
		// document.frames.ifrmGetChildren.location.href = "dir_ajax_getchildren.jsp?root_code=" + root_code + "&parentCode=" + name;
		document.getElementById("ifrmGetChildren").src = "officeequip_ajax_getchildren.jsp?root_code=" + root_code + "&parentCode=" + name;
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

function showModify(obj) {
	var aObj = obj.getElementsByTagName('span');
	if (aObj.length>1) {
		aObj[aObj.length-1].style.display = '';
	}
}
function hiddenModify(obj) {
	var aObj = obj.getElementsByTagName('span');
	if (aObj.length>1) {	
		aObj[aObj.length-1].style.display = 'none';
	}
}

var isSuo = true;
function shensuo() {
	if (isSuo) {
		isSuo = false;
		//o("imgShensuo").src = "images/shousuo.gif";
	}
	else {
		isSuo = true;
		//o("imgShensuo").src = "images/shenzhan.gif";
	}
	window.parent.shensuo();
	//window.shensuo();
}

function shrink() {
	if (!isSuo) {
		isSuo = true;
		//o("imgShensuo").src = "images/shenzhan.gif";
		window.parent.shrink();
	}
}

$(document).click(function(event){
	if(event.target.tagName=="A"){
		var tagText = event.target.innerHTML;
		if (tagText.indexOf("修改")!=-1 || tagText.indexOf("添")!=-1) {
			if (isSuo) {
				shensuo();
			}
		}
	}
})

function init() {
	if (window.parent.allFrame.rows==window.parent.shen) {
		isSuo = false;
		shensuo();
	}
}

function doAdd(parentCode, code) {
	// 删除父目录的孩子节点，然后用ajax重新获取
	var ch = o("childof" + parentCode);
	if (ch!=null) {
		// ch.outerHTML = "";
		ch.parentNode.removeChild(ch);
	}
	
	// 取得含有tableRelate属性的图片，将展开标志图象改为加号
	var p = o(parentCode);
	var ary = p.getElementsByTagName("img");
	var isFound = false;
	for (i=0; i<ary.length; i++) {
		if (ary[i].attributes['tableRelate']!=null) {
			ary[i].src = "images/i_plus.gif";
			ShowChild(ary[i], ary[i].attributes['tableRelate'].nodeValue);
			return;
		}
	}
	
	if (!isFound) {
		ary[0].style.width = (parseInt(ary[0].width)-16) + "px";
		var str = "<img style='cursor:pointer' tableRelate='" + parentCode + "' onClick=\"ShowChild(this, '" + parentCode + "')\" src='images/i_plus.gif' align='absmiddle' style='margin-right:3px'>";
		ary[0].insertAdjacentHTML("afterEnd", str);
		
		var ary = p.getElementsByTagName("img");
		for (i=0; i<ary.length; i++) {
			if (ary[i].attributes['tableRelate']!=null) {
				ary[i].src = "images/i_plus.gif";
				ShowChild(ary[i], ary[i].attributes['tableRelate'].nodeValue);
				return;
			}
		}		
	}
}

function doModify(tableId, newName) {
	var ary = o(tableId).getElementsByTagName("A");
	ary[0].innerText = newName;
	//alert(newName);
	//alert(tableId);
	//document.getElementById(tableId).innerText = newName;
}

function doMove(tableId, tableId2) {
	var t = o(tableId);
	var t2 = o(tableId2);
	
	if (t==null || t2==null)
		return;
	
	var tn = o(tableId).cloneNode(true);
	var tn2 = o(tableId2).cloneNode(true);

	var tch = o("childof"+tableId);
	var tch2 = o("childof"+tableId2);
	
	var tchn = null;
	if (tch!=null)
		tchn = tch.cloneNode(true);
	var tchn2 = null;
	if (tch2!=null)
		tchn2 = tch2.cloneNode(true);

	var p = t.parentNode;

	if (tch==null && tch2==null) {
		p.replaceChild(tn2, t);
		p.replaceChild(tn, t2);
	}
	else if (tch==null && tch2!=null) {
		p.replaceChild(tn2, t);
		p.replaceChild(tchn2, t2);
		p.replaceChild(tn, tch2);
	}
	else if (tch!=null && tch2==null) {
		p.replaceChild(tn2, t);
		p.replaceChild(tn, tch);
		p.replaceChild(tchn, t2);
	}
	else {
		p.replaceChild(tn2, t);
		p.replaceChild(tn, t2);
		
		p.replaceChild(tchn2, tch);
		p.replaceChild(tchn, tch2);
	}		
}

function syncUnitUser() {
	window.location.href = "dept_top_ajax.jsp?op=sync";
}

var inst;
var node;
var code;

</script>
</head>
<body >
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<jsp:useBean id="dm" scope="page" class="com.redmoon.oa.basic.TreeSelectMgr"/>
<%
String priv = "admin.user";
if (!privilege.isUserPrivValid(request,priv)) {
	out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
	return;
}
%>
<%
String root_code = ParamUtil.get(request, "root_code");

try {
	com.redmoon.oa.security.SecurityUtil.antiXSS(request, privilege, "root_code", root_code, getClass().getName());
}
catch (ErrMsgException e) {
	out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, e.getMessage()));
	return;
}

if (root_code.equals("")) {
	root_code = privilege.getUserUnitCode(request);
}
%>
<Script>
var root_code = "<%=root_code%>";
// 使框架的bottom能得到此root_code
function getRootCode() {
	return root_code;
}
</Script>
<%
String op = ParamUtil.get(request, "op");




//DeptDb leaf = dm.getDeptDb(root_code);
TreeSelectDb leaf = dm.getTreeSelectDb(root_code);
if (op.equals("repair")) {
	dm.repairTree(leaf);
	//leaf = dm.getDeptDb(root_code);
	leaf = dm.getTreeSelectDb(root_code);
}

String root_name = leaf.getName();
int root_layer = leaf.getLayer();
String root_description = leaf.getDescription();
boolean isHome = false;

//得到含有子节点的节点

%>

<table width='100%' cellpadding='0' cellspacing='0' >
  <tr>
    <td class="head">&nbsp;</td>
  </tr>
</table>
<TABLE  
cellSpacing=0 cellPadding=0 width="95%" align=center>
  <TBODY>
    <TR>
      <TD height=200 valign="top">
	<!--<table class="tbg1" cellspacing=0 cellpadding=0 width="100%" align=center onMouseOver="this.className='tbg1sel'" onMouseOut="this.className='tbg1'" border=0>
          <tbody>
            <tr>
              <td width="66%" height="13" align=left nowrap>&nbsp;</td>
            <td width="34%" align=right nowrap>
            <!--<font style="font-family:'宋体'">>></font>&nbsp;<a href="dept_top_ajax.jsp?op=repair&root_code=<%=root_code%>">修复</a>&nbsp;&nbsp;<%=root_name%>&nbsp;&nbsp;<a target="dirbottomFrame" href="dept_bottom.jsp?parent_code=<%=StrUtil.UrlEncode(root_code, "utf-8")%>&parent_name=<%=StrUtil.UrlEncode(root_name, "utf-8")%>&op=AddChild">添子部门</a>&nbsp;&nbsp;<a target="dirbottomFrame" href="dept_bottom.jsp?op=modify&code=<%=StrUtil.UrlEncode(root_code, "utf-8")%>&name=<%=StrUtil.UrlEncode(root_name,"utf-8")%>&description=<%=StrUtil.UrlEncode(root_description,"utf-8")%>">修改</a> <a target=_self href="#" onClick="if (window.confirm('您确定要删除<%=root_name%>吗?')) window.location.href='dir_top.jsp?op=del&delcode=<%=root_code%>'">删除</a>
			  </td>
            </tr>
          </tbody>
        </table>-->
		<%
			//DeptView dv = new DeptView(leaf);
			TreeSelectView dv = new TreeSelectView(leaf);
			//dv.listAjax(request, out, true);
			String jsonData = dv.getJsonString();
			List<String> list = dv.getAllUnit();
			
		%>
		<div id="departmentTree"></div>
		<script>
		var listCode = new Array();
		var i = 0;
		<%	
			
			for(String str : list){
			%>
			listCode[i]= "<%=str%>";
			i++;
		<%
		}
		%>
		var myjsTree;
		  $(function () {
			myjsTree = $('#departmentTree')
			  	.jstree({
			    	"core" : {
			            "data" :  <%=jsonData%>,
			            "themes" : {
						   "theme" : "default" ,
						   "dots" : true,  
						   "icons" : true  
						},
						"check_callback" : true,	
			 		},
			 		"ui" : {"initially_select" : [ "<%=root_code %>" ]  },
			 		"plugins" : ["unique", "dnd", "wholerow", "themes", "ui", "contextmenu" ,"types","crrm","state"],
			 		"contextmenu": {	//绑定右击事件
			 			"items": {
			 				"create": {  
			                    "label": "添加子项",
								"icon" : "<%=request.getContextPath() %>/js/jstree/themes/default/tree_icon_add.png",
			                    "action": function (data) { 
			                    	var inst = $.jstree.reference(data.reference);
									var	node = inst.get_node(data.reference);
									code = node.id;
									var name = node.text;
									window.open("officeequip_bottom.jsp?op=AddChild&root_code=<%=root_code%>&parent_code="+code+"&parent_name="+name+"&number="+Math.random(),"dirbottomFrame");
			                    }
			                },  
			                "rename": {  
			                    "label": "修改",  
								"icon" : "<%=request.getContextPath() %>/js/jstree/themes/default/tree_icon_alter.png",
			                    "action": function (data) { 
			                    	inst = $.jstree.reference(data.reference);
			                    	node = inst.get_node(data.reference);
			                    	var code = node.id;
			                    	var name = node.text;
									window.open("officeequip_bottom.jsp?op=modify&root_code=<%=root_code%>&code="+code+"&parent_name="+name+"&number="+Math.random(),"dirbottomFrame");
			                    }  
			                },   
			                "remove": {  
			                    "label": "删除",
								"icon" : "<%=request.getContextPath() %>/js/jstree/themes/default/tree_icon_close.png",
			                    "action": function (data) { 
			                    	var inst = $.jstree.reference(data.reference);
			                    	var obj = inst.get_node(data.reference);
			                    	var code = obj.id;
			                    	if( "<%=root_code %>" == code){
			                    		alert("根节点不能被删除!");
			                    		return;
			                    	}
			                    	if(window.confirm('您确定要删除吗?')){
			                    		$.ajax({
											type: "post",
											url: "officeequip_do.jsp",
											dataType: "json",
											data: {
												op: "del",
												root_code: " <%=root_code %>",
												delcode:code+""
											},
											success: function(data, status){
												//注释代码能支持批量删除
		                    					//if(inst.is_selected(obj)) {
												//	inst.delete_node(inst.get_selected());
												//}
												//else {
												//	inst.delete_node(obj);
												//}
												inst.delete_node(obj);
												//window.open("dept_user.jsp?deptCode=root","dirhidFrame");  
											},
											complete: function(XMLHttpRequest, status){
												shrink();
												for(var i=0;i<listCode.length;i++){
													//$("#"+listCode[i]+" a").first().css("font-weight","bold");
												} 
											},
											error: function(XMLHttpRequest, textStatus){
												alert(XMLHttpRequest.responseText);
											}
										});	
			                    	}
			                    } 
			                }
			 			}
			 		}
				}).bind('move_node.jstree', function (e, data) {//绑定移动节点事件
				    //data.node.id移动节点的id
				    //data.parent移动后父节点的id
				    //data.position移动后所在父节点的位置，第一个位置为0
				    $.ajax({
						type: "post",
						url: "officeequip_do.jsp",
						dataType: "json",
						data: {
							op: "move",
							code: data.node.id+"",
							parent_code: data.parent+"",
							position : data.position+"" 
						},
						success: function(data, status){
							if(data.ret == 0){
								alert(data.msg);
								window.location.reload(true);   
							}  
						},
						complete: function(XMLHttpRequest, status){
						},
						error: function(XMLHttpRequest, textStatus){
							alert("移动失败！");
							window.location.reload(true); 
						}
					});	
					for(var i=0;i<listCode.length;i++){
						//$("#"+listCode[i]+" a").first().css("font-weight","bold");
					} 
           		}).bind('select_node.jstree', function (e, data) {//绑定选中事件
				     //window.open("dept_user.jsp?deptCode="+data.node.id,"dirhidFrame");
				     for(var i=0;i<listCode.length;i++){
						//$("#"+listCode[i]+" a").first().css("font-weight","bold");
					 }
           		}).bind('click.jstree', function(event) {               
		            for(var i=0;i<listCode.length;i++){
						//$("#"+listCode[i]+" a").first().css("font-weight","bold");
					}
			    });
			    //初始化，使得单位加粗
                for(var i=0;i<listCode.length;i++){
						//$("#"+listCode[i]+" a").first().css("font-weight","bold");
				}
           		$.toaster({priority : 'info', message : '右键菜单可管理或拖动办公用品' });

			  });
			  function addNewNode(myId,myText,unitCode){
			  		 if (code == undefined){ 
			  		 	code = "root";
			  		 }
           			myjsTree.jstree('create_node', code+"", {'id' : myId+"", 'text' : myText+""}, 'last');
           			
	            	if(unitCode == "0"){
	            		listCode[listCode.length] = myId+"";
	            	}
            		for(var i=0;i<listCode.length;i++){
						//$("#"+listCode[i]+" a").first().css("font-weight","bold");
					}
	            	
           	  }
           	  function modifyTitle(name,unitCode){
					inst.set_text(node, name, "zh");
					//window.open("dept_user.jsp?deptCode="+node.id,"dirhidFrame"); 
	            	for(var i=0;i<listCode.length;i++){
						if(listCode[i] == node.id+""){
							listCode.splice(i,1);
							break;
						}
					}
	            	if(unitCode == "0"){
						listCode[listCode.length] = node.id+"";
	            	}
            		for(var i=0;i<listCode.length;i++){
						//$("#"+listCode[i]+" a").first().css("font-weight","bold");
					}
				}
		  </script>
		</TD>
    </TR>
  </TBODY>
</TABLE>
<iframe id="ifrmGetChildren" style="display:none" src="" width="100%" height="200"></iframe>
</body>
</html>




