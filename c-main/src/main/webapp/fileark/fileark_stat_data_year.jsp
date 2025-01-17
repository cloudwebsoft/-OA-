<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.*"%>
<%@ page import="cn.js.fan.db.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="com.cloudwebsoft.framework.db.*"%>
<%@ page import="com.redmoon.oa.fileark.*"%>
<%@ page import="jofc2.model.axis.*"%>
<%@ page import="jofc2.model.elements.*"%>
<%@ page import="jofc2.model.*"%>
<%@page import="jofc2.OFCException"%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONArray"%>
<%@ include file="../inc/nocache.jsp"%>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege" />
<%
	if (!privilege.isUserPrivValid(request, "admin"))
		return;
	JSONObject json = new JSONObject();
	String dirCode = ParamUtil.get(request, "dirCode");

	String typeName = "全部";
	if (!dirCode.equals("")) {
		Leaf lf = new Leaf();
		lf = lf.getLeaf(dirCode);
		typeName = lf.getName();
	}

	int showyear;
	Calendar cal = Calendar.getInstance();

	String strshowyear = request.getParameter("showyear");

	if (strshowyear != null)
		showyear = Integer.parseInt(strshowyear);
	else
		showyear = cal.get(Calendar.YEAR);

	int total = 0;

	String chart = ParamUtil.get(request, "chart");
	if (chart.equals("")) {
		double max = 0; // Y轴最大值
		XAxis x = new XAxis(); // X轴

		BarChart chartFlow = new BarChart(BarChart.Style.GLASS);

		Calendar showCal = Calendar.getInstance();
		Vector actionV;
		String sql;
		ArrayList al = new ArrayList();
		for (int i = 0; i <= 11; i++) {
			showCal.set(showyear, i, 1);

			String bdate = SQLFilter.getDateStr(DateUtil.format(showCal, "yyyy-MM-dd 00:00:00"), "yyyy-MM-dd HH:mm:ss");

			Calendar nextCal = Calendar.getInstance();
			if (i <= 10)
				nextCal.set(showyear, i + 1, 1);
			else
				nextCal.set(showyear + 1, 0, 1);
			String edate = SQLFilter.getDateStr(DateUtil.format(nextCal, "yyyy-MM-dd 00:00:00"), "yyyy-MM-dd HH:mm:ss");

			// 全部计划
			if (dirCode.equals(""))
				sql = "select count(*) from document where createDate>=" + bdate + " and createDate<" + edate;
			else
				sql = "select count(*) from document where class1=" + StrUtil.sqlstr(dirCode) + " and createDate>=" + bdate + " and createDate<" + edate;
			
			JdbcTemplate jt = new JdbcTemplate();
			ResultIterator ri = jt.executeQuery(sql);
			int count = 0;
			if (ri.hasNext()) {
				ResultRecord rr = (ResultRecord)ri.next();
				count = rr.getInt(1);
				
				al.add(count);
			}
			
			total += count;
			if (max < count)
				max = count;

			BarChart.Bar bar = new BarChart.Bar(count, i + "月"); //条标题，显示在x轴上
			bar.setColour("0xff0000"); //颜色
			bar.setTooltip("#val# 个"); //鼠标移动上去后的提示         
			chartFlow.addBars(bar);

			x.addLabels("" + (i + 1)); //x轴的文字
		}

		// chartFlow.setAlpha(0.8f);
		chartFlow.setColour("0xff0000");

		Chart flashChart = new Chart();
		flashChart.addElements(chartFlow);

		YAxis y = new YAxis(); //y轴

		if (max < 10)
			max = 10;
		y.setMax(max); //y轴最大值
		y.setSteps(max / 10 * 1.0); //步进
		flashChart.setYAxis(y);
		flashChart.setXAxis(x);

		Text yLegend = new Text("count", "font-size:14px; color:#736AFF");
		flashChart.setYLegend(yLegend);

		Text title = new Text(typeName + " " + showyear + "年   共计：" + total);
		flashChart.setTitle(title);

		String printString = "";
		try {
			printString = flashChart.toString();
		} catch (OFCException e) {
			printString = flashChart.toDebugString();
		}
		json.put("total",total);
		for(int i = 1 ; i<=al.size(); i++){
			json.put("mData"+i , al.get(i-1));
		}
		out.print(json);
		//out.print(printString);
	} else {
		PieChart c2 = new PieChart(); //饼图
		ArrayList num = new ArrayList();
		ArrayList name = new ArrayList();
		Calendar showCal = Calendar.getInstance();
		Leaf lf = null;
		Directory dir = new Directory();
		String sql;
		JdbcTemplate jt = new JdbcTemplate();
		ResultIterator ri = jt.executeQuery("select code from directory where type<>" + Leaf.TYPE_NONE + " order by orders desc");
		while (ri.hasNext()) {
			ResultRecord rr = (ResultRecord)ri.next();
			String code = rr.getString(1);
			lf = dir.getLeaf(code);
			if (lf==null)
				continue;

			showCal.set(showyear, 0, 1);
			String bdate = SQLFilter.getDateStr(DateUtil.format(showCal, "yyyy-MM-dd 00:00:00"), "yyyy-MM-dd HH:mm:ss");
			Calendar nextCal = Calendar.getInstance();
			nextCal.set(showyear + 1, 11, 31);
			String edate = SQLFilter.getDateStr(DateUtil.format(nextCal, "yyyy-MM-dd 00:00:00"), "yyyy-MM-dd HH:mm:ss");

			sql = "select count(*) from document where class1=" + StrUtil.sqlstr(lf.getCode()) + " and createDate>=" + bdate + " and createDate<" + edate;
			int c = 0;
			ResultIterator ri2 = jt.executeQuery(sql);
			if (ri2.hasNext()) {
				ResultRecord rr2 = (ResultRecord)ri2.next();
				c = rr2.getInt(1);
				num.add(c);
				name.add(lf.getName());
			}
			
			total += c;
			c2.addSlice(c, lf.getName()); //增加一块 
		}

		c2.setStartAngle(-90); //开始的角度
		c2.setColours(new String[] { "0x336699", "0x88AACC", "0x999933", "0x666699", "0xCC9933", "0x006666", "0x3399FF", "0x993300", "0xAAAA77", "0x666666", "0xFFCC66", "0x6699CC", "0x663366", "0x9999CC", "0xAAAAAA", "0x669999", "0xBBBB55", "0xCC6600", "0x9999FF", "0x0066CC", "0x99CCCC", "0x999999", "0xFFCC00", "0x009999", "0x99CC33", "0xFF9900", "0x999966", "0x66CCCC", "0x339966", "0xCCCC33" });// 饼图每块的颜色
		c2.setTooltip("#val#  /  #total#<br>占百分之 #percent#\n 角度 = #radius#"); //鼠标移动上去后提示内容

		Chart flashChart = new Chart();
		flashChart = new Chart(showyear + "年   共计：" + total); //整个图的标题
		flashChart.addElements(c2); //把饼图加入到图表
		
		String printString = "";
		try {
			printString = flashChart.toString();
		} catch (OFCException e) {
			printString = flashChart.toDebugString();
		}
		json.put("total",total);
		for(int i = 1 ; i<=num.size(); i++){
			json.put("mNum"+i , num.get(i-1));
		}
		for(int i = 1 ; i<=name.size(); i++){
			json.put("mName"+i , name.get(i-1));
		}
		JSONArray jsa = new JSONArray();
		for(int i = 1 ; i<=name.size(); i++){
		    JSONArray obj = new JSONArray();
		    obj.add(name.get(i-1));
		    obj.add(num.get(i-1));
		    jsa.add(obj);
		}
		json.put("jsa",jsa);
		out.print(json);
		//out.print(printString);
	}
%>
