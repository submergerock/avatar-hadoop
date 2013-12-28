package com.dinglicom.com.server.extend;

import java.lang.management.ThreadInfo;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.hdfs.server.namenode.AvatarNode;

public class ProcessInternalMonitor implements Runnable{
	
	public static final Log LOG = LogFactory.getLog(ProcessInternalMonitor.class.getName());    
	private JvmInfo jvmInfo = null;
	private long    interval = 1000*10;

	public ProcessInternalMonitor(){
		jvmInfo = new JvmInfo();
	}
	
	public void run(){
	    long capacity  = 0;
	    long dfsUsed   = 0;
	    long remaining = 0;
	    long totaVirtualMemory = 0;
	    long freeSweepMemorySize = 0;
	    long totalPhysicalMemorySize = 0;
	    long freePhysicalMemorySize = 0;
	    long commitVirtualMemorySize = 0;
	    long totalJvmMemorySize = 0;
	    long freeJvmMemory = 0;
	    long maxMemory = 0;
	    long usedHeapSize = 0;
	    long usedNoneHeapSize = 0;
	    long thCount = 0;
	    long peekThCount = 0;
	    long daemonThreadCount = 0;
        double sysLoad = 0.0;
        
	    while(true){
	            totaVirtualMemory = jvmInfo.getTotaVirtualMemory();
	            freeSweepMemorySize = jvmInfo.getFreeSweepMemorySize();
	            totalPhysicalMemorySize = jvmInfo.getTotalPhysicalMemorySize();
	            freePhysicalMemorySize = jvmInfo.getFreePhysicalMemorySize();
	            commitVirtualMemorySize = jvmInfo.getCommitVirtualMemorySize();
	            totalJvmMemorySize = jvmInfo.getTotalJvmMemorySize();
	            freeJvmMemory = jvmInfo.getFreeJvmMemorySize();
	            maxMemory = jvmInfo.getMaxMemorySize();
	            usedHeapSize = jvmInfo.getUsedHeapSize();
	            usedNoneHeapSize = jvmInfo.getUsedNoneHeapSize();
	            thCount = jvmInfo.getThreadCount();
	            peekThCount = jvmInfo.getPeekThreadCount();
	            daemonThreadCount = jvmInfo.getDaemonThreadCount();
	            sysLoad =jvmInfo.getSysLoad();
	            
	            Double compare = (Double)(1-freePhysicalMemorySize*1.0/totaVirtualMemory)*100;
	            
	            LOG.info("wzt debuginfo:dfs.avatarnode.internal"+interval+" sysinfo: "
	          		  +" totalvirtualmem="+totaVirtualMemory+"m"
	          		  +" freeSweepMemorySize="+freeSweepMemorySize+"m"
	          		  +" totalPhysicalMemorySize="+totalPhysicalMemorySize+"m"
	          		  +" freePhysicalMemorySize="+freePhysicalMemorySize+"m"
	          		  +" commitVirtualMemorySize="+commitVirtualMemorySize+"m"
	          		  +" totalJvmMemorySize="+totalJvmMemorySize+"m"
	          		  +" freeJvmMemory="+freeJvmMemory+"m"
	          		  +" maxMemory="+maxMemory+"m"
	          		  +" usedHeapSize="+usedHeapSize+"m"
	          		  +" usedNoneHeapSize="+usedNoneHeapSize+"m"
	          		  +" threadCount="+thCount
	          		  +" peekThCount="+peekThCount
	          		  +" daemonThreadCount="+daemonThreadCount
	          		  +" memused="+compare.intValue()+"%"
	          		  +" sysload="+sysLoad
	          		  );
	            
            try {
				Thread.sleep(1000*60);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				LOG.warn("ProcessInternalMonitor:"+e);
			}
	    }//end while
	    
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		ProcessInternalMonitor pim = new ProcessInternalMonitor();
		Thread td = new Thread(pim,"thread test1");
		td.start();
	}

}
