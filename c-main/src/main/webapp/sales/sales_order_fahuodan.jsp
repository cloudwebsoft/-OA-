<%@ page contentType="text/html;charset=gb2312"%>
<%@ page import = "java.util.*"%>
<%@ page import = "cn.js.fan.db.*"%>
<%@ page import = "cn.js.fan.util.file.*"%>
<%@ page import = "com.cloudwebsoft.framework.util.*"%>
<%@ page import = "cn.js.fan.util.*"%>
<%@ page import = "cn.js.fan.web.*"%>
<%@ page import = "com.cloudwebsoft.framework.db.*"%>
<%@ page import = "com.redmoon.oa.dept.*"%>
<%@ page import = "com.redmoon.oa.basic.*"%>
<%@ page import = "com.redmoon.oa.sale.*"%>
<%@ page import = "com.redmoon.oa.ui.*"%>
<%@ page import = "com.redmoon.oa.person.*"%>
<%@ page import = "com.redmoon.oa.visual.*"%>
<%@ page import = "com.redmoon.oa.flow.FormDb"%>
<%@ page import = "com.redmoon.oa.flow.macroctl.*"%>
<%@ page import = "com.redmoon.oa.flow.FormField"%>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
	response.reset();

	response.setContentType("application/msword;charset=gb2312");
	response.setHeader("Content-disposition","attachment; filename=" + StrUtil.GBToUnicode("������.doc"));
	
	// String path = Global.getRealPath() + "sales/template/";
	// String t = FileUtil.ReadFile(path + "fahuodan.htm", "gb2312");
	
	SalesFahuodanDb sfd = new SalesFahuodanDb();
	sfd = sfd.getSalesFahuodanDb(privilege.getUserUnitCode(request));
	String t = sfd.getString("content");
	
	long orderId = ParamUtil.getLong(request, "orderId");
	
	String formCode = "sales_order";
	FormDb fd = new FormDb();
	fd = fd.getFormDb(formCode);
	FormDAO fdao = new FormDAO();
	fdao = fdao.getFormDAO(orderId, fd);
	
	FormDb fdCustomer = new FormDb();
	fdCustomer = fdCustomer.getFormDb("sales_customer");
	FormDAO fdaoCustomer = new FormDAO();
	fdaoCustomer = fdaoCustomer.getFormDAO(StrUtil.toLong(fdao.getCwsId()), fdCustomer);

	t = t.replaceAll("\\{�ͻ�\\}", fdaoCustomer.getFieldValue("customer"));
	t = t.replaceAll("\\{������\\}", fdao.getFieldValue("code"));
	t = t.replaceAll("\\{�绰\\}", fdaoCustomer.getFieldValue("tel"));
	t = t.replaceAll("\\{��ַ\\}", fdaoCustomer.getFieldValue("address"));
	t = t.replaceAll("\\{�ʱ�\\}", fdaoCustomer.getFieldValue("postcode"));
	t = t.replaceAll("\\{����\\}", fdaoCustomer.getFieldValue("fax"));
	t = t.replaceAll("\\{��ַ\\}", fdaoCustomer.getFieldValue("web"));
	t = t.replaceAll("\\{����\\}", DateUtil.format(new java.util.Date(), "yyyy��MM��dd��"));
	
	UserMgr um = new UserMgr();
	UserDb user = um.getUserDb(fdao.getCreator());
	t = t.replaceAll("\\{ҵ��Ա\\}", user.getRealName());

	String url = "http://" + request.getServerName() + ":" +
				  request.getServerPort() + request.getContextPath() +
				  "/sales/sales_order_stock_info_nesttable.jsp?formCode=sales_ord_product&orderId=" + orderId;
    String tab = NetUtil.gather(request, "utf-8", url);
	// System.out.println(getClass() + tab);
	t = t.replace("{��Ʒ��}", tab);

	out.print(t);
%>