<%--Listfile.jsp--%>
<%@ page import="java.io.*"%>
<%@ page import="com.cloudwebsoft.framework.util.*"%>
<%@ page import="com.redmoon.oa.person.*"%>
<%@ page import="com.redmoon.oa.netdisk.*"%>
<%@ page import="cn.js.fan.web.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="cn.js.fan.util.file.*"%>
<%@ page contentType="text/html;charset=GB2312" language="java" %>
<html>   <head><title>�����ļ�Ŀ¼</title></head>
   <body>
   <%!
   // �ָ������ļ�
   UserDb user;
   UserMgr um = new UserMgr();
       public  void travelDirectory(String directory,JspWriter out) throws IOException,ErrMsgException
       {
           File dir = new File(directory);
           if(dir.isFile())            //�ж��Ƿ����ļ���������ļ��򷵻ء�
               return;
           File [] files=dir.listFiles();        //�г���ǰĿ¼�µ������ļ���Ŀ¼
           for(int i=0;i<files.length;i++)
           {
               if(files[i].isDirectory()) {      //�����Ŀ¼�������������Ŀ¼
                   travelDirectory(files[i].getAbsolutePath(),out);
				   // out.print(files[i].getAbsolutePath() + "<BR>");
			   }
			   
			   if (!files[i].isDirectory()) {
			   	
				   out.println( files[i].getName() + "---");    //�����Ŀ¼�����ļ�������
				   out.println( files[i].getAbsolutePath() + "<BR>");    //�����Ŀ¼�����ļ�������
				   // �����ļ�·���У����ڵڼ���
				   String path = files[i].getAbsolutePath();
				   String[] ary = path.split("\\\\");
				  
				   
				   String realName = ary[3];
				   String userName = Cn2Spell.converterToFirstSpell(realName);
					// �ӵ������ļ��п�ʼ���ֱ����û�����Ŀ¼��
					// �����û��Ƿ��Ѵ��ڣ�����������򴴽����û�
					user = um.getUserDb(userName);
					
					if (!user.isLoaded()) {
						user.create(userName, realName, "1", "139", "root");
						Leaf lf = new Leaf();
						lf.initRootOfUser(userName);
						// Ϊ�û������ļ���
						File f = new File(Global.realPath + "upfile/file_netdisk/" + userName);
						if (!f.isDirectory()) {
							f.mkdirs();
						}
					}
					// Ϊ��Ŀ¼�����ĵ�
					com.redmoon.oa.netdisk.Document doc = new com.redmoon.oa.netdisk.Document();
					int docId = doc.getIDOrCreateByCode(userName, userName);
					
					System.out.println("docId:" + docId);

					
					// ���ļ��������û��ļ��еĸ�Ŀ¼��
					String srcFile = path;
					String ext = FileUtil.getFileExt(srcFile);
					String diskFileName = RandomSecquenceCreator.getId(20) + "." + ext;
					String fileName = ary[ary.length-1];
					
					FileUtil.CopyFile(srcFile, Global.realPath + "upfile/file_netdisk/" + userName + "/" + diskFileName );
					// Ϊ�ĵ���Ӹ���
					com.redmoon.oa.netdisk.Attachment att = new com.redmoon.oa.netdisk.Attachment();
					att.setDocId(docId);
					att.setName(fileName);
					att.setDiskName(diskFileName);
					
				   // �����û����ļ����Ƿ������ݿ����Ѵ��ڣ���������ڣ���Ϊ�佨���������ļ��������û����ļ�����
				   String visualPath = "upfile/file_netdisk/" + userName;
				   /*
				   for (int k=3; k<ary.length-1; k++) {
					visualPath += "/" + ary[k];
				   }
				   */
					System.out.println("srcFile:" + srcFile);
					System.out.println("newPath:" + Global.realPath + "upfile/file_netdisk/" + userName + "/" + diskFileName);
					System.out.println("visualPath:" + visualPath);
					
					att.setVisualPath(visualPath);
					att.setPageNum(1);
					att.setOrders(1);
					// ȡ���ļ��Ĵ�С
					long size = 0;
					File f = new File(srcFile);
					if (f.exists())
						size = f.length();				
					att.setSize(size);
					att.setExt(ext);
					// att.setUploadDate(new java.util.Date());
					att.setUserName(userName);
					att.create();
				}
				
           }
       }   %>
    <%
       //����ǰweb����Ŀ¼�ṹ���������̨
       String dir="e:/userbak/file_folder";//pageContext.getServletContext().getRealPath("/images");
       out.println("--------------------------------<BR>");
       travelDirectory(dir,out);
       out.println("--------------------------------<BR>");
   %>
   </body>
</html> 
