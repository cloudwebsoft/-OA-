package com.redmoon.oa.fileark.plugin.sms;

import cn.js.fan.web.SkinUtil;
import java.util.Locale;
import javax.servlet.http.HttpServletRequest;
import cn.js.fan.util.ResBundle;
import cn.js.fan.base.ISkin;
import com.cloudwebsoft.framework.util.LogUtil;
import com.redmoon.oa.fileark.plugin.PluginMgr;
import com.redmoon.oa.fileark.plugin.PluginUnit;

/**
 *
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2005</p>
 *
 * <p>Company: </p>
 *
 * @author not attributable
 * @version 1.0
 */
public class SMSSkin implements ISkin {
    public static String resource = null;
    public static String code = SMSUnit.code;

    public SMSSkin() {
    }

/*
    public static Skin getSkin(String skinCode) {
        PluginMgr pm = new PluginMgr();
        PluginUnit pu = pm.getPluginUnit(code);
        Iterator ir = pu.getSkins().iterator();
        while (ir.hasNext()) {
            Skin skin = (Skin)ir.next();
            if (skin.getCode().equals(skinCode))
                return skin;
        }
        return null;
    }
*/
     public static String getResource() {
        if (resource==null) {
            PluginMgr pm = new PluginMgr();
            PluginUnit pu = pm.getPluginUnit(code);
            return pu.getResource();
        }
        return resource;
    }

    public static String LoadString(HttpServletRequest request, String key) {
        Locale locale = SkinUtil.getLocale(request);
        ResBundle rb = new ResBundle(getResource(), locale);
        if (rb == null)
            return "";
        else {
            String str = "";
            try {
                str = rb.get(key);
            }
            catch (Exception e) {
                LogUtil.getLog(SMSSkin.class).error("LoadString:" + key + " " + e.getMessage());
            }
            return str;
        }
    }

    public String LoadStr(HttpServletRequest request, String key) {
        return LoadString(request, key);
    }
}
