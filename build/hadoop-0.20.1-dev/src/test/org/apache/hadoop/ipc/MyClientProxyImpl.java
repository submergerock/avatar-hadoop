package org.apache.hadoop.ipc;

import java.io.IOException;

import org.apache.hadoop.ipc.TestRPC.TestProtocol;


public class MyClientProxyImpl implements MyClientProxyInterface{
    public long getProtocolVersion(String protocol, long clientVersion) {
        return TestProtocol.versionID;
      }

      public String echo(String value) throws IOException { 
    	  return value; 
      }    
}
