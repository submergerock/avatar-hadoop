package com.dinglicom.com.rpctest;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hdfs.protocol.ClientDatanodeProtocol;
import org.apache.hadoop.ipc.RPC;
import org.apache.hadoop.net.NetUtils;


public class RpcClientTest {
     public ClientDatanodeProtocol DistributeNode ;
     public Configuration conf = new Configuration();
     public String ipAddr1 = "172.16.40.242:50020";
     public String ipAddr2 = "192.168.137.119:8888";
     public void rpcTest(){
 		try {
            /*  			
 		    return (AvatarProtocol)RPC.getProxy(AvatarProtocol.class,
 		           AvatarProtocol.versionID, nameNodeAddr, ugi, conf,
 		           NetUtils.getSocketFactory(conf, AvatarProtocol.class));
            */
			DistributeNode = (ClientDatanodeProtocol)RPC.getProxy(ClientDatanodeProtocol.class,
					ClientDatanodeProtocol.versionID, 
					NetUtils.createSocketAddr(ipAddr2), 
					this.conf,
			        NetUtils.getSocketFactory(this.conf, ClientDatanodeProtocol.class)
			        );
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
 		if(DistributeNode != null){
 			String vv = DistributeNode.getWztTestStr("paramma");
 			System.out.println(vv);
 		}
     }
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		RpcClientTest rpctest = new RpcClientTest();
		rpctest.rpcTest();
	}

}
