package org.apache.hadoop.ipc;

import java.io.IOException;

import org.apache.hadoop.io.Writable;

public interface MyClientProxyInterface extends VersionedProtocol {
    public static final long versionID = 1L;
    
    String echo(String value) throws IOException;
}
