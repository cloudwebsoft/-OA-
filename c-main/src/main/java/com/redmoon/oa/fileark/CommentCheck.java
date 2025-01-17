package com.redmoon.oa.fileark;

import cn.js.fan.base.*;
import cn.js.fan.security.SecurityUtil;
import javax.servlet.http.HttpServletRequest;
import cn.js.fan.util.ParamUtil;
import cn.js.fan.util.ErrMsgException;
import com.cloudwebsoft.framework.util.IPUtil;
import com.cloudwebsoft.framework.util.LogUtil;

public class CommentCheck extends AbstractCheck {
    int id;
    String nick;
    String link;
    String content;
    String ip;
    int doc_id;

    public CommentCheck() {
    }

    public String getNick() {
        return nick;
    }

    public String getLink() {
        return link;
    }

    public int getDocId() {
        return this.doc_id;
    }

    public String getContent() {
        return this.content;
    }

    public String getIp() {
        return this.ip;
    }

    public int getId() {
        return id;
    }

    public String chkNick(HttpServletRequest request) {
        nick = ParamUtil.get(request, "nick");
        if (nick.equals("")) {
            log("名称必须填写！");
        }
        if (!SecurityUtil.isValidSqlParam(nick))
            log("请勿使用' ; 等字符！");
        return nick;
    }

    public String chkLink(HttpServletRequest request) {
        link = ParamUtil.get(request, "link");
        if (link.equals("")) {
            log("链接必须填写！");
        }
        // if (!SecurityUtil.isValidSqlParam(link))
        //    log("请勿使用' ; 等字符！");
        return link;
    }

    public String chkContent(HttpServletRequest request) {
        content = ParamUtil.get(request, "content");
        if (content.equals("")) {
            log("内容必须填写！");
        }
        return content;
    }

    public int chkId(HttpServletRequest request) throws ErrMsgException {
        id = ParamUtil.getInt(request, "id");
        return id;
    }

    public String chkIp(HttpServletRequest request) {
        ip = IPUtil.getRemoteAddr(request);
        return ip;
    }

    public int chkDocId(HttpServletRequest request) throws ErrMsgException {
        try {
            doc_id = ParamUtil.getInt(request, "doc_id");
        }
        catch (ErrMsgException e) {
            LogUtil.getLog(getClass()).error(e.getMessage());
            throw e;
        }
        return doc_id;
    }

    public boolean checkInsert(HttpServletRequest request) throws ErrMsgException {
        init();
        chkDocId(request);
        chkNick(request);
        chkLink(request);
        chkContent(request);
        chkIp(request);
        report();
        return true;
    }

    public boolean checkId(HttpServletRequest request) throws ErrMsgException {
        init();
        chkId(request);
        report();
        return true;
    }

    public boolean checkDel(HttpServletRequest request) throws ErrMsgException {
        init();
        chkId(request);
        report();
        return true;
    }
}
