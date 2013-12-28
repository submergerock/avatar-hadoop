package org.apache.hadoop.ipc;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;

public class TestRpcServer {
	private Server server;
	private InetSocketAddress serverAddress = null; 
	
	public void createRpcServer() throws IOException{
		Configuration conf = new Configuration();
		InetSocketAddress socAddr = new InetSocketAddress("localhost",55555);
	    this.server = RPC.getServer(new MyClientProxyImpl(), socAddr.getHostName(), socAddr.getPort(),
                10, false, conf);
	    // The rpc-server port can be ephemeral... ensure we have the correct info
        this.serverAddress = this.server.getListenerAddress(); 
       //  LOG.info("===========NameNode========this.serverAddress  : " + this.serverAddress );
      System.out.println("Namenode up at: " + this.serverAddress);
      this.server.start();
		
	}
	
	
	/**
	 * @param args
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public static void main(String[] args) throws IOException, InterruptedException {
		// TODO Auto-generated method stub
		TestRpcServer ts = new TestRpcServer();
		ts.createRpcServer();
		while(true){
			Thread.sleep(1000);
		}
	}

}
