<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="cn.js.fan.web.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="com.redmoon.oa.kernel.*"%>
<%@ page import="com.redmoon.oa.ui.*"%>
<%@ page import="com.redmoon.oa.fileark.*"%>
<%@ page import="com.redmoon.oa.person.*"%>
<%@ page import="com.redmoon.oa.pvg.Privilege" %>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
String priv="read";
if (!privilege.isUserPrivValid(request,priv)) {
	out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
	return;
}

int docId = ParamUtil.getInt(request, "docId");

Document doc = new Document();
doc = doc.getDocument(docId);
LeafPriv lp = new LeafPriv(doc.getDirCode());
if (!lp.canUserModify(privilege.getUser(request))) {
	out.print(SkinUtil.makeErrMsg(request, Privilege.MSG_INVALID));
	return;
}
		
int attachId = ParamUtil.getInt(request, "attachId");
int pageNum = ParamUtil.getInt(request, "pageNum", 1);
Attachment att = doc.getAttachment(pageNum, attachId);
att.setDownloadCount(att.getDownloadCount() + 1);
att.save();

Leaf lf = new Leaf(doc.getDirCode());
DocLogDb dld = new DocLogDb();
DocAttachmentLogDb dad = new DocAttachmentLogDb();
if(lf.isLog()){
	String uName = privilege.getUser(request);
	String ip = com.cloudwebsoft.framework.util.IPUtil.getRemoteAddr(request);
	dad.setUserName(uName);
	dad.setAtt_id(attachId);
	dad.setDoc_id(docId);
	dad.setIp(ip);
	dad.setLogDate(new java.util.Date());
	dad.create();
	
	dld.setUserName(uName);
	dld.setDoc_id(docId);
	dld.setIp(ip);
	dld.setLogDate(new java.util.Date());
	dld.create();
}

int isRevise = ParamUtil.getInt(request, "isRevise", 0);

// System.out.println(getClass() + " " + isRevise);

UserDb user = new UserDb();
user = user.getUserDb(privilege.getUser(request));
String userRealName = user.getRealName();
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<title>Office - 在线编辑</title>
<script>
var TANGER_OCX;
function init(){
	// 获取文档控件对象
	TANGER_OCX = document.getElementById('TANGER_OCX');
	TANGER_OCX.IsUseUTF8Data = true;
	// 创建新文档
	// TANGER_OCX.CreateNew("Word.Document");
	
	var url = "<%=Global.getFullRootPath(request)%>/fileark/getFile.do?docId=<%=docId%>&attachId=<%=attachId%>";

	if (<%=att.getExt().equals("xls") || att.getExt().equals("xlsx")%>) {
		TANGER_OCX.OpenFromURL(url, false, "excel.sheet");
	} else if (<%=att.getExt().equals("doc") || att.getExt().equals("docx")%>) {
		TANGER_OCX.OpenFromURL(url, false, "Word.Document");
	} else if (<%=att.getExt().equals("wps")%>) {
		TANGER_OCX.OpenFromURL(url, false, "WPS.Document");
	} else {
		TANGER_OCX.OpenFromURL(url);
	}
	
	TANGER_OCX_SetDocUser("<%=userRealName%>");
	<%
	if(isRevise!=0){
	%>
	TANGER_OCX_SetMarkModify(true);
	<%}%>
	
	TANGER_OCX.height = document.body.clientHeight;
	
	TANGER_OCX.ActiveDocument.Saved = true;
}

function TANGER_OCX_SetDocUser(cuser)
{
	with(TANGER_OCX.ActiveDocument.Application)
   {
		UserName = cuser;
   }	
}

function TANGER_OCX_SetMarkModify(boolvalue)
{
	TANGER_OCX_SetReviewMode(boolvalue);
	//TANGER_OCX_EnableReviewBar(!boolvalue);
}

function TANGER_OCX_SetReviewMode(boolvalue)
{
	TANGER_OCX.ActiveDocument.TrackRevisions = boolvalue;
}

function TANGER_OCX_EnableReviewBar(boolvalue)
{
	TANGER_OCX.ActiveDocument.CommandBars("Reviewing").Enabled = boolvalue;
	TANGER_OCX.ActiveDocument.CommandBars("Track Changes").Enabled = boolvalue;
	TANGER_OCX.IsShowToolMenu = boolvalue;	//关闭或打开工具菜单
}
//接受所有修订
function TANGER_OCX_AcceptAllRevisions()
{
   TANGER_OCX.ActiveDocument.AcceptAllRevisions();
}
function AddMyMenuItems()
{
 	try
	{
		//在自定义主菜单中增加菜单项目
		TANGER_OCX.AddCustomMenuItem('保存文件',false,false,1);
		// TANGER_OCX.AddCustomMenuItem('');
		// TANGER_OCX.AddCustomMenuItem('图片签章',false,false,2);
		// TANGER_OCX.AddCustomMenuItem('手写签名',false,false,3);
		//TANGER_OCX.AddCustomMenuItem('我的菜单2',false,false,2);
		//TANGER_OCX.AddCustomMenuItem('');
		//TANGER_OCX.AddCustomMenuItem('我的菜单3',false,true,3);
        //在文件菜单中增加菜单项目
		//TANGER_OCX.AddFileMenuItem('创建Word文档',false,false,1);
		//TANGER_OCX.AddFileMenuItem('创建Excel文档',false,false,2);
		//TANGER_OCX.AddFileMenuItem('创建PPT文档',false,false,3);
		//TANGER_OCX.AddFileMenuItem('关闭文档',false,true,4);
		//TANGER_OCX.AddFileMenuItem('');
	}
   	catch(err){
		alert("不能创建新对象："+ err.number +":" + err.description);
	}
	finally{
	}
}

function checkLeave() {
	try {
		if (!TANGER_OCX.ActiveDocument.Application.ActiveWorkbook.Saved) {
			event.returnValue="您还没有保存文件，确定要关闭么？";
			return;
		}
	}
	catch (e) {
		// alert(e);
	}
	
	if (!TANGER_OCX.ActiveDocument.Saved)
		event.returnValue="您还没有保存文件，确定要关闭么？";
}
</script>
</HEAD>
<BODY onLoad="init();AddMyMenuItems();" onbeforeunload="checkLeave()">
<object id="TANGER_OCX" classid="clsid:C9BC4DFF-4248-4a3c-8A49-63A7D317F404" codebase="../activex/OfficeControl.cab#version=5,0,2,1" width="100%" height="100%" >
<param name="CustomMenuCaption" value="操作">
<param name="Caption" value="Office - 编辑">
<param name="MakerCaption" value="cloudweb">
<param name="MakerKey" value="0727BEFE0CCD576DFA15807DA058F1AC691E1904">
<%
if (com.redmoon.oa.kernel.License.getInstance().isOem()) {%>
<param name="ProductCaption" value="<%=License.getInstance().getCompany()%>">
<param name="ProductKey" value="<%=License.getInstance().getOfficeControlKey()%>">
<%}else{ %>
<param name="ProductCaption" value="YIMIOA">
<param name="ProductKey" value="D026585BDAFC28B18C8E01C0FC4C0AA29B6226B5">
<%} %>
<SPAN STYLE="color:red">该网页需要控件浏览.浏览器无法装载所需要的文档控件.请检查浏览器选项中的安全设置.</SPAN>
</object>
<form id="myForm" METHOD="post" NAME="myForm">
</FORM>
</BODY>
<script language="JScript" for="TANGER_OCX" event="OnCustomMenuCmd(menuIndex,menuCaption,menuID)">
switch(menuID)
{
case 1:
//TANGER_OCX_AcceptAllRevisions();
edit();
break;
}
</script>
<script>
function edit() {
    var msg = TANGER_OCX.SaveToURL("<%=Global.getFullRootPath(request)%>/fileark/upload_office_file.jsp", "some.doc", "doc_id=<%=docId%>&file_id=<%=attachId%>", "some.doc", "myForm");
	
	alert(msg);
}
</script>
<script>
//图片印章
function userStamp()
{
   openChooseStamp("getstamp");
   //alert(URL);
}
<% String rootpath = request.getContextPath(); %>
function openWinForFlowAccess(url,width,height)
{
	var newwin = window.open(url,"_blank","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,top=400,left=550,width="+width+",height="+height);
}

function test() {
	AddSignFromURL(URL);
}

function AddSignFromURL(URL)
{
     alert(URL);
//   alert(TANGER_OCX_key);
      TANGER_OCX.AddSignFromURL(
	'<%=userRealName%>',//当前登陆用户
	URL,//URL
	50,//left
	50,
	"1",
1,
100,
0) 
}

function AddPictureFromURL(URL)
{
    TANGER_OCX.AddPicFromURL(
		URL,//URL 注意；URL必须返回Word支持的图片类型。
		true,//是否浮动图片
		0, 
		0,
        1, //当前光标处
		100,//无缩放
		1 //文字上方
)
	};
</script>
<script>
function useHandSign()
{
   DoHandSign();
}
function DoHandSign()
{
//   alert(TANGER_OCX_key);
	TANGER_OCX.DoHandSign(
	'<%=userRealName%>',//当前登陆用户 必须
	0,//笔型0－实线 0－4 //可选参数
	0x000000ff, //颜色 0x00RRGGBB//可选参数
	2,//笔宽//可选参数
	100,//left//可选参数
	50,//top//可选参数
	false,//可选参数
	1
	); 
  }
</script>
</html>
