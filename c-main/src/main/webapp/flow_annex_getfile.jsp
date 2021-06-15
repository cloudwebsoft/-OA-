<%@ page contentType="text/html;charset=gb2312"%><%@page import="cn.js.fan.util.*"%><%@page import="com.redmoon.oa.flow.*"%><%@page import="java.io.*"%><%@page import="java.net.*"%><jsp:useBean id="fchar" scope="page" class="cn.js.fan.util.StrUtil"/><jsp:useBean id="fsecurity" scope="page" class="cn.js.fan.security.SecurityUtil"/><jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/><%
String priv = request.getParameter("priv");
if (priv==null)
	priv = "read";
if (!privilege.isUserPrivValid(request, priv)) {
	//response.setContentType("text/html;charset=gb2312"); 
	out.print("<meta http-equiv='Content-Type' content='text/html; charset=gb2312'>");
	out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
	return;
}

//int flowId = ParamUtil.getInt(request, "flowId");
//int attId = ParamUtil.getInt(request, "attachId");
long id = ParamUtil.getInt(request, "id");

WorkflowAnnexAttachment waa = new WorkflowAnnexAttachment(id);
String fileName = waa.getName();
com.redmoon.oa.Config cfg = new  com.redmoon.oa.Config();
String fileDiskPath = cn.js.fan.web.Global.getRealPath() + cfg.get("file_flow") + "/" + waa.getVisualPath() + "/" + waa.getDiskName();

if (StrUtil.isImage(StrUtil.getFileExt(waa.getDiskName()))) {
	%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>    
<style>
img {
	border:none;
	max-width: 800px;
	width: expression (
		function(img){
		img.onload=function(){
			this.style.width = (this.width > 800)?'800px':this.width+'px'
			};
		return '800px';
		}(this)
	);
}    
</style>
</head>
<body style="text-align:center">
	<img title="����鿴ԭͼ" style="cursor:pointer" src="<%=request.getContextPath()%>/img_show.jsp?path=<%=waa.getVisualPath() + "/" + waa.getDiskName()%>" onclick="window.open('<%=waa.getVisualPath() + "/" + waa.getDiskName()%>')" />
</body>
</html>
	<%
	return;
}
String op = ParamUtil.get(request, "op");
if (op.equals("toPDF")) {
	String fName = fileName.substring(0, fileName.lastIndexOf("."));
	fileName = fName + ".pdf";
	
	String diskName = waa.getDiskName();
	String pdfName = diskName.substring(0, diskName.lastIndexOf("."));
	pdfName += ".pdf";
	
	/*
	String pdfPath = cn.js.fan.web.Global.getRealPath() + com.redmoon.kit.util.FileUpload.TEMP_PATH + "/" + fileName;
	if (com.redmoon.oa.util.PDFConverter.convert2PDF(fileDiskPath, pdfPath))
		fileDiskPath = pdfPath;
	*/
	
	String pdfPath = cn.js.fan.web.Global.getRealPath() + waa.getVisualPath() + "/" + pdfName;
	System.out.println(getClass() + " " + pdfPath);
	System.out.println(getClass() + " " + fileDiskPath);
	File f = new File(pdfPath);
	if (!f.exists()) {
		com.redmoon.oa.util.PDFConverter.convert2PDF(fileDiskPath, pdfPath);
	}
	fileDiskPath = pdfPath;
}

// response.setContentType(MIMEMap.get(StrUtil.getFileExt(att.getDiskName())));
response.setContentType("application/octet-stream");
response.setHeader("Content-disposition","attachment; filename=\""+StrUtil.GBToUnicode(fileName) + "\"");

BufferedInputStream bis = null;
BufferedOutputStream bos = null;

try {
	bis = new BufferedInputStream(new FileInputStream(fileDiskPath));
	bos = new BufferedOutputStream(response.getOutputStream());
	
	byte[] buff = new byte[2048];
	int bytesRead;
	
	while(-1 != (bytesRead = bis.read(buff, 0, buff.length))) {
		bos.write(buff,0,bytesRead);
	}
} catch(final IOException e) {
	System.out.println( "IOException." + e );
} finally {
	if (bis != null)
		bis.close();
	if (bos != null)
		bos.close();
}
	
out.clear();
out = pageContext.pushBody();
%>