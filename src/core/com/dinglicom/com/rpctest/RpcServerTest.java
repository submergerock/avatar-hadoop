package com.dinglicom.com.rpctest;

import java.io.IOException;
import java.net.InetSocketAddress;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hdfs.job.Job;
import org.apache.hadoop.hdfs.protocol.Block;
import org.apache.hadoop.hdfs.protocol.ClientDatanodeProtocol;
import org.apache.hadoop.hdfs.protocol.DatanodeID;
import org.apache.hadoop.hdfs.protocol.DatanodeInfo;
import org.apache.hadoop.hdfs.protocol.LocatedBlock;
import org.apache.hadoop.ipc.RPC;
import org.apache.hadoop.ipc.Server;
import org.apache.hadoop.net.NetUtils;

public class RpcServerTest implements ClientDatanodeProtocol{
    
    public Configuration conf = new Configuration();
    public Server server;
	public void rpcServerTest(){
		InetSocketAddress socAddr = NetUtils.createSocketAddr("0.0.0.0:" + 8888);
		//cprocframework里面有 2个主类 JobEntityStore,JobControl
	    // create rpc server 
	    try {
	        /*ipcServer = RPC.getServer(this, ipcAddr.getHostName(), ipcAddr.getPort(), 
	                conf.getInt("dfs.datanode.handler.count", 3), false, conf);
	    	*/
			this.server = RPC.getServer(this, 
					socAddr.getHostName(), 
					socAddr.getPort(),
					8, false, this.conf);
			this.server.start();
			System.out.println("rpc server at:8888");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	  public long getProtocolVersion(String protocol, long clientVersion)
			  throws RPC.VersionIncompatible, IOException{
		  return ClientDatanodeProtocol.versionID;
	  }
	
	  public LocatedBlock recoverBlock(Block block, boolean keepLength,
		      DatanodeInfo[] targets) throws IOException{
		  return null;
	  }
	  
	
	  public String[]   getBlockFiles(Block[] b) {
		  return null;
	  }
	//-------------wl826214------------2011.9.19--------
	  public void submitJob(Job e) throws IOException{
		  
	  }
	//-------------wl826214------------2011.9.20--------
	  public void stopJob(Job j) throws IOException{
		  
	  }
		//-------add by wl826214 ---------2011.11.11
	  public Configuration getConfiguration() {
		  return null;
	  }
	  //wzt test
	  public String getWztTestStr(String param){
		  return param;
	  }
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		RpcServerTest rpcServerTest = new RpcServerTest();
		rpcServerTest.rpcServerTest();
	}

}
