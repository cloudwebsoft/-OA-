package com.redmoon.oa.fileark.robot;

import org.quartz.JobExecutionException;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobDataMap;
import cn.js.fan.util.ErrMsgException;
import com.cloudwebsoft.framework.util.LogUtil;

/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2006</p>
 *
 * <p>Company: </p>
 *
 * @author not attributable
 * @version 1.0
 */
public class RobotJob implements Job {
    public RobotJob() {
    }

    /**
     * execute
     *
     * @param jobExecutionContext JobExecutionContext
     * @throws JobExecutionException
     */
    @Override
    public void execute(JobExecutionContext jobExecutionContext) throws
            JobExecutionException {
        JobDataMap data = jobExecutionContext.getJobDetail().getJobDataMap();
        String strId = data.getString("id");
        int id = Integer.parseInt(strId);

        RobotDb rd = new RobotDb();
        rd = (RobotDb) rd.getQObjectDb(new Integer(id));
        Roboter rt = new Roboter();
        try {
            rt.gatherList(null, rd);
        } catch (ErrMsgException e) {
            LogUtil.getLog(getClass()).error("execute:" + e.getMessage());
        }
    }
}
