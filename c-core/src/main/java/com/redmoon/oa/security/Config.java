package com.redmoon.oa.security;

/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2007</p>
 *
 * <p>Company: </p>
 *
 * @author not attributable
 * @version 1.0
 */

import java.net.*;

import cn.js.fan.util.*;
import org.apache.log4j.*;
import cn.js.fan.cache.jcs.RMCache;
import com.cloudwebsoft.framework.util.LogUtil;
import org.jdom.input.SAXBuilder;
import java.io.FileInputStream;
import org.jdom.Document;
import org.jdom.Element;

public class Config {
    private XMLProperties properties;
    private final String CONFIG_FILENAME = "config_security.xml";
    private Document doc = null;
    private Element root = null;
    private String cfgpath;

    Logger logger;

    public static Config cfg = null;

    private static Object initLock = new Object();

    public Config() {
    }

    public void init() {
        logger = Logger.getLogger(Config.class.getName());
        URL cfgURL = getClass().getResource("/" + CONFIG_FILENAME);
        cfgpath = cfgURL.getFile();
        cfgpath = URLDecoder.decode(cfgpath);
        properties = new XMLProperties(cfgpath);

        SAXBuilder sb = new SAXBuilder();
        try {
            FileInputStream fin = new FileInputStream(cfgpath);
            doc = sb.build(fin);
            root = doc.getRootElement();
            fin.close();
        } catch (org.jdom.JDOMException e) {
            LogUtil.getLog(getClass()).error("Config:" + e.getMessage());
        } catch (java.io.IOException e) {
            LogUtil.getLog(getClass()).error("Config:" + e.getMessage());
        }
    }

    public Element getRoot() {
        return root;
    }

    public static Config getInstance() {
        if (cfg == null || cfg.properties == null) {
            synchronized (initLock) {
                cfg = new Config();
                cfg.init();
            }
        }
        return cfg;
    }

    public String getProperty(String name) {
    	String str = "";
    	try{
    		str = StrUtil.getNullStr(properties.getProperty(name));
    	}catch(Exception e){
    		e.printStackTrace();
    	}
        return str;
    }

    public int getIntProperty(String name) {
        String p = getProperty(name);
        if (StrUtil.isNumeric(p)) {
            return Integer.parseInt(p);
        } else {
            return -65536;
        }
    }

    public boolean getBooleanProperty(String name) {
        String p = getProperty(name);
        return p.equals("true");
    }

    public void setProperty(String name, String value) {
        properties.setProperty(name, value);
        refresh();
    }

    public String getProperty(String name, String childAttributeName,
                              String childAttributeValue) {
        return StrUtil.getNullStr(properties.getProperty(name, childAttributeName,
                                      childAttributeValue));
    }

    public String getProperty(String name, String childAttributeName,
                              String childAttributeValue, String subChildName) {
        return StrUtil.getNullStr(properties.getProperty(name, childAttributeName,
                                      childAttributeValue, subChildName));
    }

    public void setProperty(String name, String childAttributeName,
                            String childAttributeValue, String value) {
        properties.setProperty(name, childAttributeName, childAttributeValue,
                               value);
        refresh();
    }

    public void setProperty(String name, String childAttributeName,
                            String childAttributeValue, String subChildName,
                            String value) {
        properties.setProperty(name, childAttributeName, childAttributeValue,
                               subChildName, value);
        refresh();
    }

    public void refresh() {
        cfg = null;
    }

    /**
     * 判断是否强制修改初始密码
     * @return boolean
     */
    public boolean isForceChangeInitPassword() {
        return getBooleanProperty("password.isForceChangeInitPassword");
    }

    public boolean isForceChangeWhenWeak() {
        return getBooleanProperty("password.isForceChangeWhenWeak");
    }
    public int getStrenthLevelMin() {
        return getIntProperty("password.strenthLevelMin");
    }
    /**
     * 取得初始密码
     * @return String
     */
    public String getInitPassword() {
        return getProperty("password.initPassword");
    }

    /**
     * 是否防暴力破解
     * @return boolean
     */
    public boolean isDefendBruteforceCracking() {
        return getBooleanProperty("isDefendBruteforceCracking");
    }

    /**
     * 是否记住用户名
     * @return boolean
     */
    public boolean isRememberUserName() {
        return getBooleanProperty("isRememberUserName");
    }
}
