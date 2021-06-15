<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.redmoon.oa.ui.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="cn.js.fan.web.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.redmoon.oa.person.UserDb" %>
<%@ page import="com.redmoon.oa.workplan.WorkPlanAnnexDb" %>
<%@ page import="com.redmoon.oa.workplan.WorkPlanDb" %>
<%@ page import="com.redmoon.oa.flow.WorkflowDb" %>
<jsp:useBean id="fchar" scope="page" class="cn.js.fan.util.StrUtil"/>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
	if (!privilege.isUserLogin(request)) {
		out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
		return;
	}

	String userName = ParamUtil.get(request, "userName");
	if (userName.equals("")) {
		userName = privilege.getUser(request);
	}

	if (!userName.equals(privilege.getUser(request))) {
		if (!(privilege.canAdminUser(request, userName))) {
			out.print(StrUtil.Alert_Back(SkinUtil.LoadString(request, "pvg_invalid")));
			return;
		}
	}

	int id = ParamUtil.getInt(request, "id", -1); // workplanId
	WorkPlanDb wpd = new WorkPlanDb();
	wpd = wpd.getWorkPlanDb(id);
	if (!wpd.isLoaded()) {
		out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, "计划不存在！"));
		return;
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<HEAD>
	<TITLE>计划日报</TITLE>
	<meta http-equiv=Content-Type content="text/html; charset=utf-8"/>
	<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
	<script src="../inc/common.js"></script>
	<script src="<%=request.getContextPath()%>/js/jquery-1.9.1.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/jquery-migrate-1.2.1.min.js"></script>
	<script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
	<script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
	<link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet" type="text/css" media="screen"/>
	<link href="../lte/css/font-awesome.css?v=4.4.0" rel="stylesheet">
	<script type="text/javascript" src="../js/jquery.toaster.js"></script>
	<link rel="stylesheet" href="../js/bootstrap/css/bootstrap.min.css"/>
	<script src="../js/bootstrap/js/bootstrap.min.js"></script>
	<link href="../js/bootstrap-switch/bootstrap-switch.css" rel="stylesheet">
	<script src="../js/bootstrap-switch/bootstrap-switch.js"></script>
	<script src="../js/BootstrapMenu.min.js"></script>
	<style>
		.box-cur-day {
			background-color: #ffecd1;
		}
	</style>
</HEAD>
<BODY>
<%@ include file="workplan_show_inc_menu_top.jsp"%>
<script>
	o("menu3").className="current";
</script>
<div class="spacerH"></div>
<script language="javascript" type="text/javascript">
	var y;
	var m;

	function onTypeCodeChange(obj) {
		y = obj.options[obj.options.selectedIndex].value;
		o("y").value = y;
		$('#form1').submit();
	}

	function onTypeCodeChange1(obj) {
		m = obj.options[obj.options.selectedIndex].value;
		o("m").value = m;
		$('#form1').submit();
	}

	function yearChange(obj, isChange) {
		y = o("year").value;
		if (isChange == true) {
			y--;
			o("year").value = y;
			$('#form1').submit();
		} else {
			y++;
			o("year").value = y;
			$('#form1').submit();
		}
	}

	function monthChange(obj, isChange) {
		m = o("month").value;
		if (isChange == true) {
			m--;
			o("month").value = m;
			$('#form1').submit();
		} else {
			m++;
			o("month").value = m;
			$('#form1').submit();
		}
	}
</script>
<form id="form1" name="form1" action="workplan_annex_day.jsp">
<%
	  int y = ParamUtil.getInt(request, "year", -1);
	  int m = ParamUtil.getInt(request, "month", -1); 
	  Calendar c1 = Calendar.getInstance();
	  int year = c1.get(Calendar.YEAR);
	  if(y==-1){
	    y=year;
	  }
	  if(m==-1){
	    m=c1.get(Calendar.MONTH)+1;
	  }
	  %>
	<input type="hidden" name="y" value="<%=y%>">
	<input type="hidden" name="m" value="<%=m%>">
	<input type="hidden" name="id" value="<%=id%>">
<table width="98%" align="center" class="tabStyle_1 percent98">
  <tr>
    <td width="17%" class="tabStyle_1_title"><input class="btn" type="button" value="今天" onclick="window.location.href='workplan_annex_day.jsp?id=<%=id%>'"/></td>
	  <td class="tabStyle_1_title">
		  <a href="javascript:;" onclick="yearChange(<%=y%>,true)"><img title="上一年" src="../plan/images/1.gif"/></a>
		  &nbsp;
		  <a href="javascript:;" onclick="monthChange(<%=m%>,true)"><img title="上一月" src="../plan/images/4.gif"/></a>
		  &nbsp;
		  <select name="year" onChange="onTypeCodeChange(this)">
			  <%
				  for (int i = 0; i < 30; i++) {
					  if (y == year) {
			  %>
			  <option value="<%=year%>" selected="selected"><%=year%>年</option>
			  <%} else {%>
			  <option value="<%=year%>"><%=year%>年</option>
			  <%
					  }
					  year--;
				  }
			  %>
		  </select>
		  <select name="month" onchange="onTypeCodeChange1(this)">
			  <%
				  for (int i = 1; i <= 12; i++) {
					  if (m == i) {
			  %>
			  <option value="<%=i%>" selected="selected"><%=i%>月</option>
			  <%} else {%>
			  <option value="<%=i%>"><%=i%>月</option>
			  <%
					  }
				  }
			  %>
		  </select>
		  &nbsp;
		  <a href="#" onclick="monthChange(<%=m%>,false)"><img title="下一月" src="../plan/images/3.gif"/></a>
		  &nbsp;
		  <a href="#" onclick="yearChange(<%=y%>,false)"><img title="下一年" src="../plan/images/2.gif"/></a>
		  <input name="userName" value="<%=userName%>" type="hidden"/>
	  </td>
	  <td class="tabStyle_1_title">
		  <i class="fa fa-list-ul" style="color:#666" aria-hidden="true"></i>&nbsp;<a title="列表视图" href="workplan_annex_list.jsp?id=<%=id%>">列表</a>
	  </td>
    </td>
  </tr>
</table>
	<%
		boolean b;
		int dd = DateUtil.getDayCount(y, m - 1);
		//得到每月的第一天和最后一天是一年的第几周
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Calendar c = Calendar.getInstance();
		c.setTime(df.parse(y + "-" + m + "-" + "1"));
		int e = c.get(Calendar.DAY_OF_WEEK) - 1;//每月的第一天是星期几
		if (e == 0) {
			e = 7;
		}
		int ww[] = new int[2];
		ww[0] = c.get(Calendar.WEEK_OF_YEAR);
		c.setTime(new SimpleDateFormat("yyyy-MM-dd").parse(y + "-" + m + "-" + dd));
		c.setMinimalDaysInFirstWeek(7);
		int week1 = c.get(Calendar.WEEK_OF_YEAR);
		ww[1] = week1 + 1;
		int k = 1;
		int temp1 = dd;
		Vector content = new Vector();
		Vector hour_of_day = new Vector();
		Vector vid = new Vector();
		Vector date = new Vector();
		Vector vFlow = new Vector();

		String cont = "";
		String title = "";
		UserDb user = new UserDb();

		WorkPlanAnnexDb wad = new WorkPlanAnnexDb();
		String sql = wad.getSqlForListWorkplanAnnexDayOfWorkplan(id, y, m);

		Iterator ir = wad.list(sql).iterator();
		while (ir.hasNext()) {
			wad = (WorkPlanAnnexDb) ir.next();
			long annexId = wad.getLong("id");
			cont = wad.getString("content");
			user = user.getUserDb(wad.getString("user_name"));

			String addDate = DateUtil.format(wad.getDate("add_date"), "yyyy-MM-dd HH:mm:ss");
			String startDay = addDate.substring(8, 10);
			String startHour = addDate.substring(11, 13);
			title = user.getRealName() + "：" + cont + "<br/>";

			if (wad.getInt("annex_type") == WorkPlanAnnexDb.TYPE_FLOW) {
				WorkflowDb wf = wad.getWorkflowDb();
				vFlow.add(wf);
			}
			else {
				vFlow.add(null);
			}

			content.add(title);
			hour_of_day.add(startHour);
			vid.add(String.valueOf(annexId));
			date.add(startDay);
		}
	%>
<table width="98%" align="center" class="tabStyle_1 percent98">
  <tr>
    <td class="tabStyle_1_title" width="7%">周数</td>
    <td class="tabStyle_1_title" width="13%">星期一</td>
    <td class="tabStyle_1_title" width="13%">星期二</td>
    <td class="tabStyle_1_title" width="13%">星期三</td>
    <td class="tabStyle_1_title" width="13%">星期四</td>
    <td class="tabStyle_1_title" width="13%">星期五</td>
    <td class="tabStyle_1_title" width="13%">星期六</td>
    <td class="tabStyle_1_title" width="13%">星期日</td>
  </tr>
  <%
	  Calendar current = Calendar.getInstance();
	  int currentYear = current.get(Calendar.YEAR);
	  int currentMonth = current.get(Calendar.MONTH) + 1;
	  int currentDay = current.get(Calendar.DATE);
	  int count = 1;
	  int num = 0;
	  b = false;
	  for (int i = ww[0]; i <= ww[1]; i++) {
  %>
	<tr>
		<td style="height:100px ">第<%=i%>周</td>
		<%
			for (int j = 0; j < 7; j++) {
				if (k < e) {
					out.print("<td></td>");
				} else if (k >= temp1 && k <= ((ww[1] - ww[0] + 1) * 7) && count > temp1) {
					out.print("<td></td>");
				} else if (k > ((ww[1] - ww[0] + 1) * 7)) {
					break;
				} else if (k >= e || count <= temp1) {
					String cls = "";
					if (currentYear == y && currentMonth == m && currentDay == count) {
						cls = "box-cur-day";
					}
		%>
		<td valign="top" align="right" class="<%=cls%>">
			<div style="background-color:#C8E1FF">
				<a href="javascript:;" onclick="addTab('<%=y%>-<%=m%>-<%=count%>日报', 'workplan/workplan_annex_list.jsp?id=<%=id%>&year=<%=y%>&month=<%=m%>&day=<%=count%>')">
					<span style="color:#0000FF"><b><%=count%></b></span>
				</a>
			</div>
			<%
				if (count == temp1 && j == 6) {
					b = true;
					break;
				}
				for (int t = num; t < content.size(); t++) {
					String tempDay = date.get(t).toString();
					if (StrUtil.toInt(tempDay) == count) {
			%>
			<div style="text-align:left">
				<a id="annex<%=vid.get(t)%>" annexId="<%=vid.get(t)%>" class="annex-content nav" href="javascript:;" onclick="show('<%=vid.get(t)%>')"><%=content.get(t).toString()%></a>
				<%
					WorkflowDb wf = (WorkflowDb)vFlow.get(t);
					if (wf!=null) {
						out.print("<a href = \"javascript:;\" onclick = \"addTab('汇报流程', '" + request.getContextPath() + "/flow_modify.jsp?flowId=" + wf.getId() + "')\">" + wf.getTitle() + "&nbsp;(" + wf.getStatusDesc() + ")</a>");
					}
				%>
			</div>
			<%
					} else {
						break;
					}
					num++;
				}
				count++;
		%>
		</td>
		<%
				} else {
					break;
				}
				k++;
			}
			if (b == true) {
				break;
			}
		%>
	</tr>
  <%
	}
	  if(count <= temp1){
  %>
	<tr>
		<td style="height:100px">第<%=ww[1] + 1%>周</td>
		<%
			for (int i = 0; i < 7; i++) {
				if (count > temp1) {
		%>
		<td></td>
		<%
				} else {
		%>
		<td valign="top" align="right">
			<div style="background-color:#C8E1FF">
				<a href="javascript:;" onclick="addTab('<%=y%>-<%=m%>-<%=count%>日报', 'workplan/workplan_annex_list.jsp?id=<%=id%>&year=<%=y%>&month=<%=m%>&day=<%=count%>')"><font
					color="#0000FF"><b><%=count%>
			</b></font></a></div>
		</td>
		<%
				}
				count++;
			}
		%>
	</tr>
  <%}
%>
</table>
</form>
<div class=menuskin id=popmenu onmouseover="clearhidemenu();highlightmenu(event,'on')" 
      onmouseout="highlightmenu(event,'off');dynamichide(event)" style="Z-index:100"></div>
</BODY>
<script>
	var addBtpMenuEvent = function(){
		var menu = new BootstrapMenu('.annex-content', {
			fetchElementData:function($rowElem){
				var data = $rowElem;
				return data;    //return的目的是给下面的onClick传递参数
			},
			// menuEvent: 'hover',
			actions: [{
				name: '修改',
				width:300,
				iconClass: 'fa-edit',
				onClick: function (obj) {
					edit(obj.attr("annexId"));
				}
			},{
				name: '删除',
				width:300,
				iconClass: 'fa-trash',
				onClick: function (obj) {
					del(obj.attr("annexId"));
				}
			}]
		});
	};

	$(function(){
		addBtpMenuEvent();
	});

	function show(annexId) {
		addTab("查看汇报", "workplan/workplan_annex_show.jsp?annexId=" + annexId);
	}

	function edit(annexId) {
		addTab("修改汇报", "workplan/workplan_annex_edit.jsp?annexId=" + annexId);
	}

	function del(id) {
		jConfirm('确定要删除吗？', '提示', function (r) {
			if (!r) {
				return;
			}
			$.ajax({
				type: "post",
				url: "../public/workplan/delAnnex.do",
				data: {
					id: id
				},
				dataType: "html",
				contentType: "application/x-www-form-urlencoded; charset=iso8859-1",
				beforeSend: function (XMLHttpRequest) {
				},
				success: function (data, status) {
					data = $.parseJSON(data);
					if (data.ret == "1") {
						$('#annex' + id).remove();
					}
					$.toaster({
						"priority": "info",
						"message": data.msg
					});
				},
				error: function (XMLHttpRequest, textStatus) {
					alert(XMLHttpRequest.responseText);
				}
			});
		});
	}
</script>
</HTML>
