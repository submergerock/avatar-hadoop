/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.hdfs.server.namenode;

import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.DataOutputStream;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.net.InetSocketAddress;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Collection;
import java.text.SimpleDateFormat;

import javax.security.auth.login.LoginException;

import org.apache.hadoop.ipc.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.avatarpro.tools.getHostIP;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.FileUtil;
import org.apache.hadoop.io.DataOutputBuffer;
import org.apache.hadoop.hdfs.protocol.FSConstants;
import org.apache.hadoop.security.UnixUserGroupInformation;
import org.apache.hadoop.security.UserGroupInformation;
import org.apache.hadoop.util.ReflectionUtils;
import org.apache.hadoop.util.StringUtils;
import org.apache.hadoop.hdfs.protocol.AvatarProtocol;
import org.apache.hadoop.hdfs.protocol.AvatarConstants.Avatar;
import org.apache.hadoop.hdfs.protocol.AvatarConstants.StartupOption;
import org.apache.hadoop.hdfs.protocol.AvatarConstants.InstanceId;
import org.apache.hadoop.hdfs.protocol.Block;
import org.apache.hadoop.hdfs.server.protocol.DatanodeRegistration;
import org.apache.hadoop.hdfs.server.common.Storage;
import org.apache.hadoop.hdfs.server.common.Storage.StorageDirectory;
import org.apache.hadoop.hdfs.server.namenode.NameNode;
import org.apache.hadoop.hdfs.server.namenode.BlocksMap.BlockInfo;
import org.apache.hadoop.hdfs.server.namenode.FSImage.NameNodeDirType;

/**
 * This is an implementation of the AvatarNode, a hot
 * standby for the NameNode.
 * This is really cool, believe me!
 * The AvatarNode has two avatars.. the Standby avatar and the Active
 * avatar.
 * 
 * In the Standby avatar, the AvatarNode is consuming transaction logs
 * generated by the primary (via a transaction log stored in a shared device).
 * Typically, the primary Namenode is writing transactions to a NFS filesystem
 * and the Standby is reading the log from the same NFS filesystem. The 
 * Standby is also making periodic checkpoints to the primary namenode.
 * 
 * A manual command can switch the AvatarNode from the Standby avatar
 * to the Active avatar. In the Active avatar, the AvatarNode performs precisely
 * the same functionality as a real usual Namenode. The switching from 
 * Standby avatar to the Active avatar is fast and can typically occur 
 * within seconds.
 *
 * Typically, an adminstrator will run require two shared mount points for
 * transaction logs. It has to be set in fs.name.dir.shared0 and
 * fs.name.dir.shared1 (similarly for edits). Then the adminstrator starts
 * the AvatarNode on two different machines as follows:
 *
 * bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -zero -active
 * bin/hadoop org.apache.hadoop.hdfs.server.namenode.AvatarNode -one -standby
 * The first  AvatarNode uses  fs.name.dir.shared0 while the second
 * AvatarNode uses fs.name.dir.shared1 to write its transaction logs.
 * Also, at startup, the first instance is the primary Namenode and the
 * second instance is the Standby
 *
 * After a while, the adminstrator decides to change the avatar of the
 * second instance to Active. In this case, he/she has to first ensure that the
 * first instance is really really dead. This code does not handle the
 * split-brain scenario where there are two active namenodes in one cluster.
 *
 */

public class AvatarNode_Master extends AvatarNode{

	AvatarNode_Master(Configuration conf) throws IOException {
		super(conf);
		// TODO Auto-generated constructor stub
	}

  
}
