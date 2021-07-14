package com.redmoon.oa.netdisk;

import java.io.File;
import java.sql.*;
import java.util.Iterator;
import java.util.Vector;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import cn.js.fan.base.ITagSupport;
import cn.js.fan.db.Conn;
import cn.js.fan.security.SecurityUtil;
import cn.js.fan.util.ErrMsgException;
import cn.js.fan.util.StrUtil;
import cn.js.fan.util.file.FileUtil;
import cn.js.fan.web.Global;
import com.redmoon.kit.util.FileInfo;
import org.apache.log4j.Logger;
import com.redmoon.oa.db.SequenceManager;
import com.cloudwebsoft.framework.util.LogUtil;

/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2004</p>
 *
 * <p>Company: </p>
 *
 * @author not attributable
 * @version 1.0
 */
public class Document implements java.io.Serializable, ITagSupport {
    public static final int NOTEMPLATE = -1;
    String connname = "";
    int id = -1;
    String title;
    String content;
    String date;
    String class1;
    Date modifiedDate;
    String summary;
    boolean isHome = false;
    int examine = 0;

    public static final int EXAMINE_NOT = 0; // 未审核
    public static final int EXAMINE_NOTPASS = 1; // 未通过
    public static final int EXAMINE_PASS = 2; //　审核通过

    public static final int TYPE_DOC = 0;
    public static final int TYPE_VOTE = 1;

    transient Logger logger = Logger.getLogger(Document.class.getName());

    private static final String INSERT_DOCUMENT =
            "INSERT into netdisk_document (id, title, class1, type, voteoption, voteresult, nick, keywords, isrelateshow, can_comment, hit, template_id, parent_code, examine, isNew, author, flowTypeCode, modifiedDate) VALUES (?,?,?,?,?,?,?,?,?,?,0,?,?,?,?,?,?,?)";

    private static final String LOAD_DOCUMENT =
            "SELECT title, class1, modifiedDate, can_comment,summary,ishome,type,voteOption,voteResult,examine,nick,keywords,isrelateshow,hit,template_id,page_count,parent_code,isNew,author,flowTypeCode FROM netdisk_document WHERE id=?";

    private static final String DEL_DOCUMENT =
            "delete FROM netdisk_document WHERE id=?";
    private static final String SAVE_DOCUMENT =
            "UPDATE netdisk_document SET title=?, can_comment=?, ishome=?, modifiedDate=?,examine=?,keywords=?,isrelateshow=?,template_id=?,class1=?,isNew=?,author=?,flowTypeCode=? WHERE id=?";
    private static final String SAVE_SUMMARY =
            "UPDATE netdisk_document SET summary=? WHERE id=?";
    private static final String SAVE_HIT =
            "UPDATE netdisk_document SET hit=? WHERE id=?";

    public Document() {
        connname = Global.getDefaultDB();
        if (connname.equals(""))
            logger.info("Document:默认数据库名为空！");
    }

    /**
     * 从数据库中取出数据
     * @param id int
     * @throws ErrMsgException
     */
    public Document(int id) {
        connname = Global.getDefaultDB();
        if (connname.equals(""))
            logger.info("Directory:默认数据库名为空！");
        this.id = id;
        loadFromDB();
    }

    public void renew() {
        if (logger==null)
            logger = Logger.getLogger(Document.class.getName());
    }

    /**
     * 当directory结点的类型为文章时，根据code的值取得文章ID，如果文章不存，则创建文章
     * @param code String
     */
    public int getIDOrCreateByCode(String code, String nick) {
    	Leaf lf = new Leaf();
    	lf = lf.getLeaf(code);
    	if (lf.getDocId()!=-1) {
    		return lf.getDocId();
    	}
    	
        int myid = getFirstIDByCode(code);
        if (myid != -1) {
            this.id = myid;
            loadFromDB();
            
            lf.setDocID(myid);
            lf.update();
            
        } else { // 文章不存在
            title = "";
            content = " "; // TEXT 类型字段，必须加一空格符，否则在读出时会出错
            Leaf leaf = new Leaf();
            leaf = leaf.getLeaf(code);
            create(code, title, content, 0, "", "", nick, leaf.getTemplateId(), nick);
            this.id = getFirstIDByCode(code);
            // 更改目录中的doc_id
            //logger.info("id=" + id);
            leaf.setDocID(id);
            leaf.update();
        }
        return id;
    }

    public void delDocumentByDirCode(String code) throws ErrMsgException {
        Vector v = getDocumentsByDirCode(code);
        Iterator ir = v.iterator();
        while (ir.hasNext()) {
            Document doc = (Document) ir.next();
            doc.del();
        }
    }

    public Vector getDocumentsByDirCode(String code) {
        Vector v = new Vector();
        String sql = "select id from netdisk_document where class1=" +
                     StrUtil.sqlstr(code);
        logger.info("getDocumentsByDirCode:" + sql);
        Conn conn = new Conn(connname);
        ResultSet rs = null;
        try {
            rs = conn.executeQuery(sql);
            if (rs != null) {
               while (rs.next()) {
                   v.addElement(getDocument(rs.getInt(1)));
                   logger.info("getDocumentsByDirCode:" + getDocument(rs.getInt(1)).getID());
               }
            }
        } catch (SQLException e) {
            logger.error("getDocumentsByDirCode:" + e.getMessage());
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return v;
    }

    /**
     * 当确定dirCode为文章型结点时，取得其对应的文章，但是当节点对应的文章还没创建时，会出错
     * @param dirCode String
     * @return Document
     */
    public Document getDocumentByDirCode(String dirCode) {
        Leaf leaf = new Leaf();
        leaf = leaf.getLeaf(dirCode);
        //logger.info("dirCode=" + dirCode);

        // if (leaf != null && leaf.isLoaded() &&
        //    leaf.getType() == leaf.TYPE_DOCUMENT) {
        if (leaf != null && leaf.isLoaded()) {
            int id = leaf.getDocID();
            return getDocument(id);
        } else
            return null; // throw new ErrMsgException("该结点不是文章型节点或者文章尚未创建！");

    }

    public boolean changeAttachmentToDir(Attachment att, String newDirCode) throws ErrMsgException {
        Document doc = new Document();
        doc = doc.getDocumentByDirCode(newDirCode);
        int newDocId = doc.getID();

		com.redmoon.oa.Config cfg = new com.redmoon.oa.Config();
		String file_netdisk = cfg.get("file_netdisk");
		String fullPath = Global.getRealPath() + file_netdisk + "/" + att.getVisualPath() + "/" + att.getDiskName();
		
		// 先将文件从物理路径同步转移
		Leaf leaf = new Leaf();
		leaf = leaf.getLeaf(newDirCode);
		
		// 取得目的文件夹虚拟路径
		String visualPath = leaf.getFilePath();
		String filePath = file_netdisk + "/" + visualPath;
        
		String fullPath2 = Global.getRealPath() + filePath + "/" + att.getDiskName();
		LogUtil.getLog(getClass()).info("fullPath2=" + fullPath2 + " filePath=" + filePath);
		File f = new File(fullPath2);
		if (f.isFile() && f.exists()) {
			LogUtil.getLog(getClass()).info("文件夹中存在同名文件" + fullPath2 + "！");
			// throw new ErrMsgException("文件夹中存在同名文件！");
		}
		// 先移动文件
		boolean re = FileUtil.CopyFile(fullPath, fullPath2);

		f = new File(fullPath);
		re = f.delete();
		// 更改数据库中指向
		att.setVisualPath(visualPath);
		att.setDocId(newDocId);
		re = att.save();

		DocContentCacheMgr dcm = new DocContentCacheMgr();
		dcm.refreshUpdate(id, 1);
		dcm.refreshUpdate(newDocId, 1);

		
        return re;
    }

    /**
	 * 取得结点为code的文章的ID，只取第一个
	 * 
	 * @param code
	 *            String
	 * @return int -1未取得
	 */
    public int getFirstIDByCode(String code) {
        String sql = "select id from netdisk_document where class1=" +
                     StrUtil.sqlstr(code);
        Conn conn = new Conn(connname);
        ResultSet rs = null;
        try {
            rs = conn.executeQuery(sql);
            if (rs != null && rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error(e.getMessage());
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return -1;
    }

    public String getSummary() {
        return this.summary;
    }

    public int getID() {
        return id;
    }

    public void setID(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public boolean getIsHome() {
        return this.isHome;
    }

    public void setIsHome(boolean h) {
        this.isHome = h;
    }

    public void setType(int type) {
        this.type = type;
    }

    public void setVoteOption(String voteOption) {
        this.voteOption = voteOption;
    }

    public void setVoteResult(String voteResult) {
        this.voteResult = voteResult;
    }

    public String getContent(int pageNum) {
        DocContent dc = new DocContent();
        dc = dc.getDocContent(id, pageNum);
        if (dc!=null)
            return dc.getContent();
        else
            return null;
    }

    /**
     * 获取前count个数据
     * @param sql String
     * @param count int
     * @return Vector
     */
    public Vector list(String sql, int count) {
        ResultSet rs = null;
        Vector result = new Vector();
        Conn conn = new Conn(connname);
        try {
            rs = conn.executeQuery(sql);
            if (rs == null) {
                return result;
            } else {
                // defines the number of rows that will be read from the database when the ResultSet needs more rows
                rs.setFetchSize(count); // rs一次从POOL中所获取的记录数
                while (rs.next()) {
                    int id = rs.getInt(1);
                    Document doc = getDocument(id);
                    result.addElement(doc);
                }
            }
        } catch (SQLException e) {
            logger.error("list: " + e.getMessage());
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return result;
    }

    public String RenderContent(HttpServletRequest request, int pageNum) {
        DocContent dc = new DocContent();
        dc = dc.getDocContent(id, pageNum);
        if (dc != null) {
            // 插件名称
            return dc.getContent();
        } else
            return null;
    }

    public DocContent getDocContent(int pageNum) {
        DocContent dc = new DocContent();
        return dc.getDocContent(id, pageNum);
    }

    public boolean isCanComment() {
        return canComment;
    }

    public String getDirCode() {
        return class1;
    }

    public synchronized boolean UpdateWithoutFile(ServletContext application,CMSMultiFileUploadBean mfu) throws
            ErrMsgException {
        //取得表单中域的信息
        String dir_code = StrUtil.getNullStr(mfu.getFieldValue("dir_code"));
        author = StrUtil.getNullString(mfu.getFieldValue("author"));
        title = StrUtil.getNullString(mfu.getFieldValue("title"));
        //logger.info("FilePath=" + FilePath);
        String strCanComment = StrUtil.getNullStr(mfu.getFieldValue(
                "canComment"));
        if (strCanComment.equals(""))
            canComment = false;
        else if (strCanComment.equals("1"))
            canComment = true;
        String strIsHome = StrUtil.getNullString(mfu.getFieldValue("isHome"));
        if (strIsHome.equals(""))
            isHome = false;
        else if (strIsHome.equals("false"))
            isHome = false;
        else if (strIsHome.equals("true"))
            isHome = true;
        else
            isHome = false;
        String strexamine = mfu.getFieldValue("examine");
        int oldexamine = examine;
        examine = Integer.parseInt(strexamine);
        String strisnew = StrUtil.getNullStr(mfu.getFieldValue("isNew"));
        if (StrUtil.isNumeric(strisnew))
            isNew = Integer.parseInt(strisnew);
        else
            isNew = 0;

        keywords = StrUtil.getNullStr(mfu.getFieldValue("keywords"));
        String strisRelateShow = StrUtil.getNullStr(mfu.getFieldValue("isRelateShow"));
        int intisRelateShow = 0;
        if (StrUtil.isNumeric(strisRelateShow)) {
            intisRelateShow = Integer.parseInt(strisRelateShow);
            if (intisRelateShow==1)
                isRelateShow = true;
        }

        flowTypeCode = StrUtil.getNullString(mfu.getFieldValue("flowTypeCode"));

        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        try {
            //更新文件内容
            pstmt = conn.prepareStatement(SAVE_DOCUMENT);
            pstmt.setString(1, title);
            pstmt.setInt(2, canComment ? 1 : 0);
            pstmt.setBoolean(3, isHome);
            pstmt.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
            pstmt.setInt(5, examine);
            pstmt.setString(6, keywords);
            pstmt.setInt(7, intisRelateShow);
            pstmt.setInt(8, templateId);
            pstmt.setString(9, dir_code);
            pstmt.setInt(10, isNew);
            pstmt.setString(11, author);
            pstmt.setString(12, flowTypeCode);
            pstmt.setInt(13, id);
            conn.executePreUpdate();
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            if (oldexamine==examine) {
                dcm.refreshUpdate(id);
            }
            else {
                dcm.refreshUpdate(id, class1, parentCode);
            }

            // 如果是更改了类别
            if (!dir_code.equals(class1)) {
                dcm.refreshChangeDirCode(class1, dir_code);
            }

            // 更新内容
            DocContent dc = new DocContent();
            dc = dc.getDocContent(id, 1);
            dc.saveWithoutFile(application, mfu);
        } catch (SQLException e) {
            logger.error(e.getMessage());
            throw new ErrMsgException("服务器内部错！");
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }

    public synchronized boolean UpdateIsHome(boolean isHome) throws
            ErrMsgException {
        String sql = "update netdisk_document set isHome=? where id=?";
        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        try {
            //更新文件内容
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, isHome ? 1 : 0);
            pstmt.setInt(2, id);
            conn.executePreUpdate();
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            dcm.refreshUpdate(id);
        } catch (SQLException e) {
            logger.error(e.getMessage());
            throw new ErrMsgException("服务器内部错！");
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }

    public synchronized boolean increaseHit() throws
            ErrMsgException {
        hit ++;
        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        try {
            //更新文件内容
            pstmt = conn.prepareStatement(SAVE_HIT);
            pstmt.setInt(1, hit);
            pstmt.setInt(2, id);
            conn.executePreUpdate();
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            dcm.refreshUpdate(id);
        } catch (SQLException e) {
            logger.error(e.getMessage());
            throw new ErrMsgException("服务器内部错！");
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }

    public synchronized boolean UpdateSummaryWithoutFile(ServletContext application,
                                                CMSMultiFileUploadBean mfu) throws
            ErrMsgException {
        Conn conn = new Conn(connname);
        boolean re = true;
        try {
            //取得表单中域的信息
            String idstr = StrUtil.getNullString(mfu.getFieldValue("id"));
            if (!StrUtil.isNumeric(idstr))
                throw new ErrMsgException("标识id=" + idstr + "非法，必须为数字！");
            id = Integer.parseInt(idstr);
            summary = StrUtil.getNullString(mfu.getFieldValue("htmlcode"));
/*
            String FilePath = StrUtil.getNullString(mfu.getFieldValue(
                    "filepath"));
            // 处理附件
            String tempAttachFilePath = application.getRealPath("/") + FilePath +
                                        "/";
            mfu.setSavePath(tempAttachFilePath); //取得目录
            File f = new File(tempAttachFilePath);
            if (!f.isDirectory()) {
                f.mkdirs();
            }
            // 写入磁盘
            mfu.writeAttachment(true);

            Vector attachs = mfu.getAttachments();
            Iterator ir = attachs.iterator();
            String sql = "";
            while (ir.hasNext()) {
                FileInfo fi = (FileInfo) ir.next();
                String filepath = mfu.getSavePath() + fi.getDiskName();
                sql +=
                        "insert netdisk_document_attach (fullpath,doc_id,name,diskname,visualpath,page_num) values (" +
                        StrUtil.sqlstr(filepath) + "," + id + "," +
                        StrUtil.sqlstr(fi.getName()) +
                        "," + StrUtil.sqlstr(fi.getDiskName()) + "," +
                        StrUtil.sqlstr(FilePath) + "," + 0 + ");";
            }
            if (!sql.equals(""))
                conn.executeUpdate(sql);
*/
            PreparedStatement pstmt = null; //更新文件内容
            pstmt = conn.prepareStatement(SAVE_SUMMARY);
            pstmt.setString(1, summary);
            pstmt.setInt(2, id);
            re = conn.executePreUpdate()==1?true:false;
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            dcm.refreshUpdate(id);
        } catch (SQLException e) {
            re = false;
            logger.error(e.getMessage());
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return re;
    }

    public synchronized boolean UpdateSummary(ServletContext application, CMSMultiFileUploadBean mfu) throws
            ErrMsgException {
        String isuploadfile = StrUtil.getNullString(mfu.getFieldValue(
                "isuploadfile"));
        // logger.info("filepath=" + mfu.getFieldValue("filepath"));
        if (isuploadfile.equals("false"))
            return UpdateSummaryWithoutFile(application, mfu);

        String FilePath = StrUtil.getNullString(mfu.getFieldValue("filepath"));
        //目录更换为公用配置目录
        //String tempAttachFilePath = application.getRealPath("/") + FilePath +
        //                            "/";
        String tempAttachFilePath = Global.getRealPath() + FilePath + "/";
        mfu.setSavePath(tempAttachFilePath); //取得目录
        File f = new File(tempAttachFilePath);
        if (!f.isDirectory()) {
            f.mkdirs();
        }

        boolean re = false;
        ResultSet rs = null;
        Conn conn = new Conn(connname);
        try {
            // 删除图像文件
            String sql = "select path from cms_images where mainkey=" + id +
                         " and kind='netdisk_document' and subkey=" + 0 + "";

            rs = conn.executeQuery(sql);
            if (rs != null) {
                String fpath = "";
                while (rs.next()) {
                    fpath = rs.getString(1);
                    if (fpath != null) {
                        File virtualFile = new File(Global.getRealPath() + fpath);
                        virtualFile.delete();
                    }
                }

            }
            if (rs != null) {
                rs.close();
                rs = null;
            }
            // 从数据库中删除图像
            sql = "delete from cms_images where mainkey=" + id +
                  " and kind='netdisk_document' and subkey=" + 0 + "";
            conn.executeUpdate(sql);

            // 处理图片
            int ret = mfu.getRet();
            if (ret == 1) {
                mfu.writeFile(false);
                Vector files = mfu.getFiles();
                // logger.info("files size=" + files.size());
                java.util.Enumeration e = files.elements();
                String filepath = "";
                sql = "";
                while (e.hasMoreElements()) {
                    FileInfo fi = (FileInfo) e.nextElement();
                    filepath = FilePath + "/" + fi.getName();
                    sql = "insert into cms_images (path,mainkey,kind,subkey) values (" +
                            StrUtil.sqlstr(filepath) + "," + id +
                            ",'netdisk_document'," + 0 + ")";
                    conn.executeUpdate(sql);
                }
            } else
                throw new ErrMsgException("上传失败！ret=" + ret);
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {e.printStackTrace();}
                rs = null;
            }

            re = UpdateSummaryWithoutFile(application, mfu);
        } catch (Exception e) {
            logger.error("UpdateSummary:" + e.getMessage());
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }

        return re;
    }

	public synchronized boolean updateTemplateId() {
		String sql = "update netdisk_document set template_id=? where id=?";
		Conn conn = new Conn(connname);
		boolean re = false;
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, templateId);
			pstmt.setInt(2, id);
			re = conn.executePreUpdate() == 1 ? true : false;
			if (re) {
				// 更新缓存
				DocCacheMgr dcm = new DocCacheMgr();
				dcm.refreshUpdate(id);
			}
		} catch (SQLException e) {
			logger.error(e.getMessage());
		} finally {
			if (conn != null) {
				conn.close();
				conn = null;
			}
		}
		return re;
	}
	
	/**
	 * @Description: 文件夹重命名时使用
	 * @return
	 */
	public synchronized boolean update() {
		Conn conn = new Conn(connname);
		PreparedStatement pstmt = null;

		String sql = "update netdisk_document set title=?,class1=?,modifiedDate=? where id=?";

		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, title);
			pstmt.setString(2, class1);
			pstmt
					.setTimestamp(3, new Timestamp(new java.util.Date()
							.getTime()));
			pstmt.setInt(4, id);
			conn.executePreUpdate();
			// 更新缓存
			DocCacheMgr dcm = new DocCacheMgr();
			dcm.refreshUpdate(id);
		} catch (SQLException e) {
			LogUtil.getLog(getClass()).error(StrUtil.trace(e));
		} finally {
			if (conn != null) {
				conn.close();
				conn = null;
			}
		}
		return true;
	}

    public synchronized boolean Update(ServletContext application,
                                       CMSMultiFileUploadBean mfu) throws
            ErrMsgException {
        String isuploadfile = StrUtil.getNullString(mfu.getFieldValue(
                "isuploadfile"));
        // logger.info("filepath=" + mfu.getFieldValue("filepath"));
        if (isuploadfile.equals("false"))
            return UpdateWithoutFile(application, mfu);

        // 取得表单中域的信息
        String dir_code = StrUtil.getNullStr(mfu.getFieldValue("dir_code"));
        author = StrUtil.getNullString(mfu.getFieldValue("author"));
        title = StrUtil.getNullString(mfu.getFieldValue("title"));
        String strIsHome = StrUtil.getNullString(mfu.getFieldValue("isHome"));
        if (strIsHome.equals(""))
            isHome = false;
        else if (strIsHome.equals("false"))
            isHome = false;
        else if (strIsHome.equals("true"))
            isHome = true;
        else
            isHome = false;
        String strexamine = mfu.getFieldValue("examine");
        int oldexamine = examine;
        examine = Integer.parseInt(strexamine);
        keywords = StrUtil.getNullStr(mfu.getFieldValue("keywords"));
        String strisRelateShow = StrUtil.getNullStr(mfu.getFieldValue("isRelateShow"));
        int intisRelateShow = 0;
        if (StrUtil.isNumeric(strisRelateShow)) {
            intisRelateShow = Integer.parseInt(strisRelateShow);
            if (intisRelateShow==1)
                isRelateShow = true;
        }

        String strisnew = StrUtil.getNullStr(mfu.getFieldValue("isNew"));
        if (StrUtil.isNumeric(strisnew))
            isNew = Integer.parseInt(strisnew);
        else
            isNew = 0;
        String strCanComment = StrUtil.getNullStr(mfu.getFieldValue(
                "canComment"));
        if (strCanComment.equals(""))
            canComment = false;
        else if (strCanComment.equals("1"))
            canComment = true;

        flowTypeCode = StrUtil.getNullStr(mfu.getFieldValue("flowTypeCode"));

        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        try {
            pstmt = conn.prepareStatement(SAVE_DOCUMENT);
            pstmt.setString(1, title);
            pstmt.setInt(2, canComment ? 1 : 0);
            pstmt.setBoolean(3, isHome);
            pstmt.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
            pstmt.setInt(5, examine);
            pstmt.setString(6, keywords);
            pstmt.setInt(7, intisRelateShow);
            pstmt.setInt(8, templateId);
            pstmt.setString(9, dir_code);
            pstmt.setInt(10, isNew);
            pstmt.setString(11, author);
            pstmt.setString(12, flowTypeCode);
            pstmt.setInt(13, id);
            conn.executePreUpdate();
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            if (oldexamine==examine) {
                dcm.refreshUpdate(id);
            }
            else {
                dcm.refreshUpdate(id, class1, parentCode);
            }
            // 如果是更改了类别
            if (!dir_code.equals(class1)) {
                dcm.refreshChangeDirCode(class1, dir_code);
            }

            // 更新第一页的内容
            DocContent dc = new DocContent();
            dc = dc.getDocContent(id, 1);
            dc.save(application, mfu);
        } catch (SQLException e) {
            LogUtil.getLog(getClass()).error(StrUtil.trace(e));
            throw new ErrMsgException("服务器内部错！");
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }
/*
    public boolean create(ServletContext application,
                          CMSMultiFileUploadBean mfu, String nick) throws
            ErrMsgException {
        String isuploadfile = StrUtil.getNullString(mfu.getFieldValue(
                "isuploadfile"));

        // 取得表单中域的信息
        author = StrUtil.getNullString(mfu.getFieldValue("author"));
        title = StrUtil.getNullString(mfu.getFieldValue("title"));
        content = StrUtil.getNullString(mfu.getFieldValue("htmlcode"));
        String dir_code = StrUtil.getNullStr(mfu.getFieldValue("dir_code"));
        keywords = StrUtil.getNullStr(mfu.getFieldValue("keywords"));
        String strisRelateShow = StrUtil.getNullStr(mfu.getFieldValue("isRelateShow"));
        int intisRelateShow = 0;
        if (StrUtil.isNumeric(strisRelateShow)) {
            intisRelateShow = Integer.parseInt(strisRelateShow);
            if (intisRelateShow==1)
                isRelateShow = true;
        }

        String strexamine = StrUtil.getNullStr(mfu.getFieldValue("examine"));
        if (StrUtil.isNumeric(strexamine)) {
            examine = Integer.parseInt(strexamine);
        }
        else
            examine = 0;

        String strisnew = StrUtil.getNullStr(mfu.getFieldValue("isNew"));
        if (StrUtil.isNumeric(strisnew))
            isNew = Integer.parseInt(strisnew);
        else
            isNew = 0;

        flowTypeCode = StrUtil.getNullStr(mfu.getFieldValue("flowTypeCode"));

        // 检查目录节点中是否允许插入文章
        Directory dir = new Directory();
        Leaf lf = dir.getLeaf(dir_code);
        if (lf==null || !lf.isLoaded()) {
            throw new ErrMsgException("节点：" + dir_code + "不存在！");
        }
        if (lf.getType() == 0)
            throw new ErrMsgException("对不起，该目录不包含具体内容，请选择正确的目录项！");
        if (lf.getType() == 1) {
            if (getFirstIDByCode(dir_code) != -1)
                throw new ErrMsgException("该目录节点为文章节点，且文章已经被创建！");
        }

        String strCanComment = StrUtil.getNullStr(mfu.getFieldValue(
                "canComment"));
        if (strCanComment.equals(""))
            canComment = false;
        else if (strCanComment.equals("1"))
            canComment = true;
        //logger.info("strCanComment=" + strCanComment);
        String strtid = StrUtil.getNullStr(mfu.getFieldValue("templateId"));
        if (StrUtil.isNumeric(strtid))
            templateId = Integer.parseInt(strtid);

        // 投票处理
        String isvote = mfu.getFieldValue("isvote");
        String[] voptions = null;
        type = TYPE_DOC; // 类型1表示为投票
        String voteresult = "", votestr = "";
        if (isvote != null && isvote.equals("1")) {
            type = TYPE_VOTE;

            String voteoption = mfu.getFieldValue("vote").trim();
            if (!voteoption.equals("")) {
                voptions = voteoption.split("\\r\\n");
            }
            if (voteoption.indexOf("|") != -1)
                throw new ErrMsgException("投票选项中不能包含|");

            int len = voptions.length;
            for (int k = 0; k < len; k++) {
                if (voteresult.equals("")) {
                    voteresult = "0";
                    votestr = voptions[k];
                } else {
                    voteresult += "|" + "0";
                    votestr += "|" + voptions[k];
                }
            }
        }

        // 清缓存
        DocCacheMgr dcm = new DocCacheMgr();
        dcm.refreshCreate(dir_code, lf.getParentCode());

        // 如果不上传文件
        if (isuploadfile.equals("false"))
            return create(dir_code, title, content, type, votestr, voteresult,
                          nick, templateId, author);

        this.id = (int) SequenceManager.nextID(SequenceManager.OA_DOCUMENT_NETDISK);

        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        try {
            // 插入文章标题及相关设置
            parentCode = lf.getParentCode();
            pstmt = conn.prepareStatement(INSERT_DOCUMENT);
            pstmt.setInt(1, id);
            pstmt.setString(2, title);
            pstmt.setString(3, dir_code);
            pstmt.setInt(4, type);
            pstmt.setString(5, votestr);
            pstmt.setString(6, voteresult);
            pstmt.setString(7, nick);
            pstmt.setString(8, keywords);
            pstmt.setInt(9, intisRelateShow);
            pstmt.setInt(10, canComment?1:0);
            pstmt.setInt(11, templateId);
            pstmt.setString(12, parentCode);
            pstmt.setInt(13, examine);
            pstmt.setInt(14, isNew);
            pstmt.setString(15, author);
            pstmt.setString(16, flowTypeCode);
            conn.executePreUpdate();

            pstmt.close();
            pstmt = null;

            // 插入文章中的内容
            DocContent dc = new DocContent();
            dc.create(application, mfu, id, content, 1);
        } catch (SQLException e) {
            logger.error("create:" + e.getMessage());
            throw new ErrMsgException("服务器内部错！");
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }

        return true;
    }
*/
    /**
     * 用以在不上传图片时直接创建文件
     * @param application ServletContext
     * @param request HttpServletRequest
     * @throws ErrMsgException
     */
    public boolean create(String code_class1, String title, String content,
                          int type, String voteoption, String voteresult,
                          String nick, int templateId, String author) {
        Leaf lf = new Leaf();
        lf = lf.getLeaf(code_class1);
        parentCode = lf.getParentCode();
        Conn conn = new Conn(connname);
        this.id = (int) SequenceManager.nextID(SequenceManager.OA_DOCUMENT_NETDISK);
        try {
            // 插入文章标题及相关设置
            PreparedStatement pstmt = conn.prepareStatement(INSERT_DOCUMENT);
            pstmt.setInt(1, id);
            pstmt.setString(2, title);
            pstmt.setString(3, code_class1);
            pstmt.setInt(4, type);
            pstmt.setString(5, voteoption);
            pstmt.setString(6, voteresult);
            pstmt.setString(7, nick);
            pstmt.setString(8, "");
            pstmt.setInt(9, 1);
            pstmt.setInt(10, canComment?1:0);
            pstmt.setInt(11, templateId);
            pstmt.setString(12, parentCode);
            pstmt.setInt(13, examine);
            pstmt.setInt(14, isNew);
            pstmt.setString(15, author);
            pstmt.setString(16, flowTypeCode);
            pstmt.setTimestamp(17, new Timestamp(new java.util.Date().getTime()));
            conn.executePreUpdate();

            // 插入文章中的内容
            DocContent dc = new DocContent();
            dc.create(id, content);

        } catch (SQLException e) {
            logger.error(e.getMessage());
            logger.error(StrUtil.trace(e));
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }

    public String get(String field) {
        if (field.equals("title"))
            return getTitle();
        else if (field.equals("content"))
            return getContent(1);
        else if (field.equals("summary"))
            return getSummary();
        else if (field.equals("id"))
            return "" + getID();
        else
            return "";
    }

    public boolean del() throws ErrMsgException {
        // 删除文章中的页
        DocContent dc = new DocContent();
        dc.delDocContentOfDocument(id);

        Conn conn = new Conn(connname);
        try {
            PreparedStatement pstmt = conn.prepareStatement(DEL_DOCUMENT);
            pstmt.setInt(1, id);
            conn.executePreUpdate();
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            dcm.refreshDel(id, class1, parentCode);
        } catch (SQLException e) {
            logger.error(e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }

    private void loadFromDB() {
        // Based on the id in the object, get the message data from the database.
        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            pstmt = conn.prepareStatement(LOAD_DOCUMENT);
            pstmt.setInt(1, id);
            rs = conn.executePreQuery();
            if (!rs.next()) {
                logger.error("文档 " + id +
                             " 在数据库中未找到.");
            } else {
                this.title = rs.getString(1);
                this.class1 = rs.getString(2);
                this.modifiedDate = rs.getDate(3);
                this.canComment = rs.getBoolean(4);
                this.summary = rs.getString(5);
                this.isHome = rs.getBoolean(6);
                this.type = rs.getInt(7);
                this.voteOption = rs.getString(8);
                this.voteResult = rs.getString(9);
                this.examine = rs.getInt(10);
                this.nick = rs.getString(11);
                this.keywords = rs.getString(12);
                this.isRelateShow = rs.getInt(13)==1?true:false;
                this.hit = rs.getInt(14);
                this.templateId = rs.getInt(15);
                this.pageCount = rs.getInt(16);
                this.parentCode = rs.getString(17);
                this.isNew = rs.getInt(18);
                this.author = rs.getString(19);
                this.flowTypeCode = rs.getString(20);
                loaded = true; // 已初始化
            }
        } catch (SQLException e) {
            logger.error("loadFromDB:" + e.getMessage());
        } finally {
            /*
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (Exception e) {}
                pstmt = null;
            }*/
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
    }

    public String toString() {
        return "Netdisk document " + id + ":" + title;
    }

    private boolean canComment = true;

    public boolean getCanComment() {
        return canComment;
    }

    public int getType() {
        return type;
    }

    public String getVoteOption() {
        return voteOption;
    }

    public int getExamine() {
        return this.examine;
    }

    public void setExamine(int e) {
        this.examine = e;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public void setKeywords(String keywords) {
        this.keywords = keywords;
    }

    public void setIsRelateShow(boolean isRelateShow) {
        this.isRelateShow = isRelateShow;
    }

    public void setHit(int hit) {
        this.hit = hit;
    }

    public void setTemplateId(int templateId) {
        this.templateId = templateId;
    }

    public void setPageCount(int pageCount) {
        this.pageCount = pageCount;
    }

    public void setParentCode(String parentCode) {
        this.parentCode = parentCode;
    }

    public void setIsNew(int isNew) {
        this.isNew = isNew;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setFlowTypeCode(String flowTypeCode) {
        this.flowTypeCode = flowTypeCode;
    }

    public String getVoteResult() {
        return voteResult;
    }

    public String getNick() {
        return nick;
    }

    public String getModifiedDate() {
        Date d = modifiedDate;
        if (d != null)
            return d.toString().substring(0, 10);
        else
            return "";
    }

    public boolean vote(int id, int votesel) throws
            ErrMsgException {
        boolean re = false;
        Conn conn = new Conn(connname);
        try {
            String[] rlt = voteResult.split("\\|");
            int len = rlt.length;
            int[] intre = new int[len];
            for (int i = 0; i < len; i++)
                intre[i] = Integer.parseInt(rlt[i]);
            intre[votesel]++;
            String result = "";
            for (int i = 0; i < len; i++) {
                if (result.equals(""))
                    result = "" + intre[i];
                else
                    result += "|" + intre[i];
            }

            String sql = "update netdisk_document set voteresult=" +
                         StrUtil.sqlstr(result)
                         + " where id=" + id;
            logger.info(sql);
            re = conn.executeUpdate(sql) == 1 ? true : false;
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            dcm.refreshUpdate(id);
        } catch (SQLException e) {
            logger.error("vote:" + e.getMessage());
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return re;
    }

    /**
     * Returns a block of threadID's from a query and performs transparent
     * caching of those blocks. The two parameters specify a database query
     * and a startIndex for the results in that query.
     *
     * @param query the SQL thread list query to cache blocks from.
     * @param startIndex the startIndex in the list to get a block for.
     */
    protected long[] getDocBlock(String query, String groupKey, int startIndex) {
        DocCacheMgr dcm = new DocCacheMgr();
        return dcm.getDocBlock(query, groupKey, startIndex);
    }

    public DocBlockIterator getDocuments(String query, String groupKey,
                                         int startIndex,
                                         int endIndex) {
        if (!SecurityUtil.isValidSql(query))
            return null;
        //可能取得的infoBlock中的元素的顺序号小于endIndex
        long[] docBlock = getDocBlock(query, groupKey, startIndex);

        return new DocBlockIterator(docBlock, query, groupKey,
                                    startIndex, endIndex);
    }

    /**
     *
     * @param sql String
     * @return int -1 表示sql语句不合法
     */
    public int getDocCount(String sql) {
        DocCacheMgr dcm = new DocCacheMgr();
        return dcm.getDocCount(sql);
    }

    public Document getDocument(int id) {
        DocCacheMgr dcm = new DocCacheMgr();
        return dcm.getDocument(id);
    }

    private int type = TYPE_DOC;
    private String voteOption;
    private String voteResult;
    private String nick;

    public String getKeywords() {
        return keywords;
    }

    public boolean getIsRelateShow() {
        return isRelateShow;
    }

    private String keywords;
    private boolean isRelateShow;
    private boolean loaded = false;

    public boolean isLoaded() {
        if (id==-1)
            return false;
        return loaded;
    }

    public int getHit() {
        return hit;
    }

    public int getTemplateId() {
        return templateId;
    }

    public int getPageCount() {
        return pageCount;
    }

    public String getParentCode() {
        return parentCode;
    }

    public int getIsNew() {
        return isNew;
    }

    public String getAuthor() {
        return author;
    }

    public String getFlowTypeCode() {
        return flowTypeCode;
    }

	public String getClass1() {
		return class1;
	}

	public void setClass1(String class1) {
		this.class1 = class1;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	private int hit = 0;
	private int templateId = NOTEMPLATE;

    public boolean AddContentPage(ServletContext application,
                                  CMSMultiFileUploadBean mfu, String content) throws
            ErrMsgException {
        String action = StrUtil.getNullStr(mfu.getFieldValue("action"));
        int afterpage = -1;
        if (action.equals("insertafter")) {
            String insafter = StrUtil.getNullStr(mfu.getFieldValue("afterpage"));
            if (StrUtil.isNumeric(insafter))
                afterpage = Integer.parseInt(insafter);
        }

        int pageNo = 1;
        if (afterpage!=-1)
            pageNo = afterpage + 1;
        else
            pageNo = pageCount + 1;
        // System.out.println(getClass() + " pageNo=" + pageNo);

        String isuploadfile = StrUtil.getNullString(mfu.getFieldValue(
                "isuploadfile"));
        DocContent dc = new DocContent();
        if (isuploadfile.equals("false")) {
            if (dc.createWithoutFile(application, mfu, id, content, pageNo)) {
                pageCount++;
                return UpdatePageCount(pageCount);
            }
        }
        else {
            if (dc.create(application, mfu, id, content, pageNo)) {
                pageCount++;
                return UpdatePageCount(pageCount);
            }
        }
        return false;
    }

    public boolean EditContentPage(ServletContext application,
                                                CMSMultiFileUploadBean mfu) throws ErrMsgException {
        String strpageNum = StrUtil.getNullStr(mfu.getFieldValue("pageNum"));
        int pageNum = Integer.parseInt(strpageNum);

        DocContent dc = new DocContent();
        dc = dc.getDocContent(id, pageNum);
        dc.setContent(content);
        dc.save(application, mfu);

        return true;
    }

    public synchronized boolean UpdatePageCount(int pagecount) throws
            ErrMsgException {
        String sql = "update netdisk_document set modifiedDate=?,page_count=? where id=?";
        Conn conn = new Conn(connname);
        PreparedStatement pstmt = null;
        try {
            //更新文件内容
            pstmt = conn.prepareStatement(sql);
            pstmt.setTimestamp(1, new Timestamp(new java.util.Date().getTime()));
            pstmt.setInt(2, pagecount);
            pstmt.setInt(3, id);
            conn.executePreUpdate();
            // 更新缓存
            DocCacheMgr dcm = new DocCacheMgr();
            dcm.refreshUpdate(id);
        } catch (SQLException e) {
            logger.error(e.getMessage());
            throw new ErrMsgException("服务器内部错！");
        } finally {
            if (conn != null) {
                conn.close();
                conn = null;
            }
        }
        return true;
    }

    private int pageCount = 1;
    private String parentCode;

    public Vector getAttachments(int pageNum) {
        DocContent dc = new DocContent();
        dc = dc.getDocContent(id, pageNum);
        if (dc==null)
            return null;
        return dc.getAttachments();
    }

    public Attachment getAttachment(int pageNum, int att_id) {
        Iterator ir = getAttachments(pageNum).iterator();
        while (ir.hasNext()) {
            Attachment at = (Attachment)ir.next();
            if (at.getId()==att_id)
                return at;
        }
        return null;
    }

    public Document getTemplate() {
        if (templateId == this.NOTEMPLATE)
            return null;
        else
            return getDocument(templateId);
    }
    
    public int getId() {
    	return id;
    }
    
    public Document getDocumentByName(String parentCode, String name) {
		String sql = "select id from netdisk_document where parent_code="
				+ StrUtil.sqlstr(parentCode) + " and title="
				+ StrUtil.sqlstr(name);
		logger.info("getDocumentsByName:" + sql);
		Conn conn = new Conn(connname);
		ResultSet rs = null;
		try {
			rs = conn.executeQuery(sql);
			if (rs != null && rs.next()) {
				return getDocument(rs.getInt(1));
			}
		} catch (SQLException e) {
			logger.error("getDocumentsByName:" + e.getMessage());
		} finally {
			if (conn != null) {
				conn.close();
				conn = null;
			}
		}
		return null;
	}    

    private int isNew = 0;
    private String author;
    private String flowTypeCode = "";
}

