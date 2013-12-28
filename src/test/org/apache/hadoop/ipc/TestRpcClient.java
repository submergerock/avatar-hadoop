package org.apache.hadoop.ipc;

import java.io.IOException;
import java.net.InetSocketAddress;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.ipc.TestRPC.TestProtocol;
import org.apache.hadoop.util.StringUtils;

public class TestRpcClient {

	Configuration conf = new Configuration();
	MyClientProxyInterface proxy = null;
	InetSocketAddress socAddr = new InetSocketAddress("localhost",55555);		

	public void startClient(boolean doWaiter) throws IOException{
        String nsinfo = null;
		do{
    	    proxy = (MyClientProxyInterface)RPC.getProxy(
    	    		MyClientProxyInterface.class, MyClientProxyInterface.versionID, socAddr, conf);
        }while(doWaiter && nsinfo == null);
	    // create a client
		while(true){
			try{
				System.out.println(proxy.echo("you"));				
			}catch(RemoteException re){
				System.out.println(re);
			}catch(IOException e){
				System.out.println("rpc :"+StringUtils.stringifyException(e));
			}catch(Throwable err){
				System.out.println(err);
			}
			
		}

	}
	
	public void testWhile(boolean doWait){
		String testS = null;
		do{
			System.out.println("5467");
		}while(doWait && testS == null);
	}
	
	public void testBigWhile(){
		boolean shouldRun = true;
		while(shouldRun){
			//testWhile(false);
			//startClient(false);
		}
	}
	/**
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		TestRpcClient tc = new TestRpcClient();
		tc.startClient(false);
		//tc.testBigWhile();
	}

}
