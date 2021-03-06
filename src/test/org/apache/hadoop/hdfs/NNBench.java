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

package org.apache.hadoop.hdfs;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Random;
import java.io.DataInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.File;
import java.io.BufferedReader;
import java.util.StringTokenizer;
import java.net.InetAddress;
import java.text.SimpleDateFormat;
import java.util.Iterator;

import org.apache.commons.logging.LogFactory;
import org.apache.commons.logging.Log;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FilterFileSystem;
import org.apache.hadoop.fs.FileSystem;

import org.apache.hadoop.hdfs.NNBenchThread.RemoteFileHandle;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SequenceFile.CompressionType;
import org.apache.hadoop.io.SequenceFile;

import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.SequenceFileInputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Reporter;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.Reducer;

import org.apache.hadoop.util.StringUtils;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * This program executes a specified operation that applies load to 
 * the NameNode.
 * 
 * When run simultaneously on multiple nodes, this program functions 
 * as a stress-test and benchmark for namenode, especially when 
 * the number of bytes written to each file is small.
 * 
 * Valid operations are:
 *   create_write
 *   open_read
 *   rename
 *   delete
 * 
 * NOTE: The open_read, rename and delete operations assume that the files
 *       they operate on are already available. The create_write operation 
 *       must be run before running the other operations.
 */

public class NNBench extends Configured implements Tool {
  private static final Log LOG = LogFactory.getLog(
          "org.apache.hadoop.hdfs.NNBench");
  
  protected static String CONTROL_DIR_NAME = "control";
  protected static String OUTPUT_DIR_NAME = "output";
  protected static String DATA_DIR_NAME = "data";
  protected static final String DEFAULT_RES_FILE_NAME = "NNBench_results.log";
  protected static final String NNBENCH_VERSION = "NameNode Benchmark 0.4";
  
  public static String operation = "none";
  public static long numberOfMaps = 1l; // default is 1
  public static long numberOfReduces = 1l; // default is 1
  public static long startTime = 
          System.currentTimeMillis() + (120 * 1000); // default is 'now' + 2min
  public static long blockSize = 1l; // default is 1
  public static int bytesToWrite = 0; // default is 0
  public static long bytesPerChecksum = 1l; // default is 1
  public static long numberOfFiles = 1l; // default is 1
  public static boolean hardlinks = false; // default is false;
  public static short replicationFactorPerFile = 1; // default is 1
  public static String baseDir = "/benchmarks/NNBench";  // default
  public static boolean readFileAfterOpen = false; // default is to not read
  
  // Supported operations
  private static final String OP_CREATE_WRITE = "create_write";
  private static final String OP_OPEN_READ = "open_read";
  private static final String OP_RENAME = "rename";
  private static final String OP_DELETE = "delete";
  //add by wzt 2012-01-09
  private static int sectionInterval = 2;
  private static int sectionNum = 2;
  private static int ulimt = 0;
  private static String jvmopt = null;
  private static long maxExceptionsPerFile = 2000;
  //end add
  
  // To display in the format that matches the NN and DN log format
  // Example: 2007-10-26 00:01:19,853
  static SimpleDateFormat sdf = 
          new SimpleDateFormat("yyyy-MM-dd' 'HH:mm:ss','S");

  // private static Configuration config = new Configuration();
  
  /**
   * Clean up the files before a test run
   * 
   * @throws IOException on error
   */
  private static void cleanupBeforeTestrun(
    Configuration config
  ) throws IOException {

    FileSystem tempFS = FileSystem.get(config);
    
    // Delete the data directory only if it is the create/write operation
    if (operation.equals(OP_CREATE_WRITE)) {
      LOG.info("Deleting data directory");
      tempFS.delete(new Path(baseDir, DATA_DIR_NAME), true);
    }
    tempFS.delete(new Path(baseDir, CONTROL_DIR_NAME), true);
    tempFS.delete(new Path(baseDir, OUTPUT_DIR_NAME), true);
  }

	static private void handleException(String operation, Throwable e,
			int singleFileExceptions) {
		LOG.warn("Exception while " + operation + ": "
				+ StringUtils.stringifyException(e));
		if (singleFileExceptions >= maxExceptionsPerFile) {
			throw new RuntimeException(
					singleFileExceptions
							+ " exceptions for a single file exceeds threshold. Aborting");
		}
	}//end func
  
  /**
   * Create control files before a test run.
   * Number of files created is equal to the number of maps specified
   * 
   * @throws IOException on error
   */
  private static void createControlFiles(
    Configuration config
  ) throws IOException {
	int singleFileExceptions = 0;
    boolean success=true;
    
    FileSystem tempFS = FileSystem.get(config);
    LOG.info("Creating " + numberOfMaps + " control files");

    for (int i = 0; i < numberOfMaps; i++) {
      String strFileName = "NNBench_Controlfile_" + i;
      Path filePath = new Path(new Path(baseDir, CONTROL_DIR_NAME),
              strFileName);

      SequenceFile.Writer writer = null;
      try {
          //update by wzt 2012-01-09
          do { // create file until is succeeds or max exceptions reached
              try {
                  writer = SequenceFile.createWriter(tempFS, config, filePath, Text.class, 
                          LongWritable.class, CompressionType.NONE);
                  success = true;
              } catch (IOException ioe) { 
                success=false; 
                handleException("creating file #" + i, ioe,
                        ++singleFileExceptions);
              }
            } while (!success);//创建文件直到成功
            //writer = SequenceFile.createWriter(tempFS, config, filePath, Text.class, 
          	//        LongWritable.class, CompressionType.NONE);
        writer.append(new Text(strFileName), new LongWritable(0l));
      } finally {
        if (writer != null) {
          
        	int totalExceptions = 3;
		      do { // close file until is succeeds
		          try {
		        	  writer.close();
		            success = true;
		          } catch (IOException ioe) {
		            success=false; 
		            totalExceptions--;
		            System.out.println("closing file " + filePath+"\n"+ioe);
		          }
		      } while (!success && totalExceptions > 0);
		      //writer.close();
        }
      }
    }//end for
    
  }//end func
  /**
   * Display version
   */
  private static void displayVersion() {
    System.out.println(NNBENCH_VERSION);
  }
  
  /**
   * Display usage
   */
  private static void displayUsage() {
    String usage =
      "Usage: nnbench <options>\n" +
      "Options:\n" +
      "\t-operation <Available operations are " + OP_CREATE_WRITE + " " +
      OP_OPEN_READ + " " + OP_RENAME + " " + OP_DELETE + ". " +
      "This option is mandatory>\n" +
      "\t * NOTE: The open_read, rename and delete operations assume " +
      "that the files they operate on, are already available. " +
      "The create_write operation must be run before running the " +
      "other operations.\n" +
      "\t-maps <number of maps. default is 1. This is not mandatory>\n" +
      "\t-reduces <number of reduces. default is 1. This is not mandatory>\n" +
      "\t-startTime <time to start, given in seconds from the epoch. " +
      "Make sure this is far enough into the future, so all maps " +
      "(operations) will start at the same time>. " +
      "default is launch time + 2 mins. This is not mandatory \n" +
      "\t-blockSize <Block size in bytes. default is 1. " + 
      "This is not mandatory>\n" +
      "\t-bytesToWrite <Bytes to write. default is 0. " + 
      "This is not mandatory>\n" +
      "\t-bytesPerChecksum <Bytes per checksum for the files. default is 1. " + 
      "This is not mandatory>\n" +
      "\t-numberOfFiles <number of files to create. default is 1. " +
      "This is not mandatory>\n" +
      "\t-replicationFactorPerFile <Replication factor for the files." +
        " default is 1. This is not mandatory>\n" +
      "\t-baseDir <base DFS path. default is /becnhmarks/NNBench. " +
      "This is not mandatory>\n" +
      "\t-readFileAfterOpen <true or false. if true, it reads the file and " +
      "reports the average time to read. This is valid with the open_read " +
      "operation. default is false. This is not mandatory>\n" +
      "\t-help: Display the help statement\n";
      
    
    System.out.println(usage);
  }

  /**
   * check for arguments and fail if the values are not specified
   * @param index  positional number of an argument in the list of command
   *   line's arguments
   * @param length total number of arguments
   */
  public static void checkArgs(final int index, final int length) {
    if (index == length) {
      displayUsage();
      System.exit(-1);
    }
  }
  
  /**
   * Parse input arguments
   * 
   * @param args array of command line's parameters to be parsed
   */
  public static void parseInputs(final String[] args, Configuration config) {
    // If there are no command line arguments, exit
    if (args.length == 0) {
      displayUsage();
      System.exit(-1);
    }
    
    // Parse command line args
    for (int i = 0; i < args.length; i++) {
      if (args[i].equals("-operation")) {
        operation = args[++i];
      } else if (args[i].equals("-maps")) {
        checkArgs(i + 1, args.length);
        numberOfMaps = Long.parseLong(args[++i]);
      } else if (args[i].equals("-reduces")) {
        checkArgs(i + 1, args.length);
        numberOfReduces = Long.parseLong(args[++i]);
      } else if (args[i].equals("-startTime")) {
        checkArgs(i + 1, args.length);
        //startTime = Long.parseLong(args[++i]) * 1000;
        startTime = System.currentTimeMillis();
      } else if (args[i].equals("-blockSize")) {
        checkArgs(i + 1, args.length);
        blockSize = Long.parseLong(args[++i]);
      } else if (args[i].equals("-bytesToWrite")) {
        checkArgs(i + 1, args.length);
        bytesToWrite = Integer.parseInt(args[++i]);
      } else if (args[i].equals("-bytesPerChecksum")) {
        checkArgs(i + 1, args.length);
        bytesPerChecksum = Long.parseLong(args[++i]);
      } else if (args[i].equals("-numberOfFiles")) {
        checkArgs(i + 1, args.length);
        numberOfFiles = Long.parseLong(args[++i]);
      } else if (args[i].equals("-hardlinks")) {
        checkArgs(i + 1, args.length);
        if(args[++i].equals("false")){
        	hardlinks = false;
        }else{
        	hardlinks = true;
        }
        
      } else if (args[i].equals("-replicationFactorPerFile")) {
        checkArgs(i + 1, args.length);
        replicationFactorPerFile = Short.parseShort(args[++i]);
      } else if (args[i].equals("-baseDir")) {
        checkArgs(i + 1, args.length);
        baseDir = args[++i];
      } else if (args[i].equals("-readFileAfterOpen")) {
        checkArgs(i + 1, args.length);
        readFileAfterOpen = Boolean.parseBoolean(args[++i]);
      }else if(args[i].equals("-sectionInterval")){
    	  sectionInterval = Integer.parseInt(args[++i]) * 1000;
      }else if(args[i].equals("-sectionNum")){
    	  sectionNum = Integer.parseInt(args[++i]);  
      }else if(args[i].equals("-ulimit")){
	        checkArgs(i + 1, args.length);
	        ulimt = Integer.parseInt(args[++i]);
      }else if(args[i].equals("-jvmopt")){
	        checkArgs(i + 1, args.length);
	        jvmopt = args[++i];
    }
      else if (args[i].equals("-help")) {
        displayUsage();
        System.exit(-1);
      }
    }
    
    if(numberOfFiles > 0 && numberOfMaps > 0){
        config.setLong("test.nnbench.totalfiles", numberOfFiles);    	
    }else{
    	LOG.info("param error numberOfFiles > 0 and  numberOfMaps > 0 ");
    	return;
    }
    

    //add by wzt 2013-01-16,avg file for map
    if(numberOfFiles > 0 && numberOfMaps > 0 && numberOfMaps < numberOfFiles){
    	numberOfFiles = numberOfFiles / numberOfMaps;    	
    }
    if(numberOfFiles > 0 && numberOfMaps > 0 && numberOfMaps > numberOfFiles){
    	numberOfMaps = numberOfFiles;
    	numberOfFiles = 1;
    }

    LOG.info("Test Inputs: ");
    LOG.info("  Test Operation: " + operation);
    LOG.info("    Start time: " + sdf.format(new Date(startTime)));
    LOG.info("  Number of maps: " + numberOfMaps);
    LOG.info("  Number of reduces: " + numberOfReduces);
    LOG.info("    Block Size: " + blockSize);
    LOG.info("    Bytes to write: " + bytesToWrite);
    LOG.info("  Bytes per checksum: " + bytesPerChecksum);
    LOG.info("  Number of files: " + numberOfFiles);
    LOG.info("  Replication factor: " + replicationFactorPerFile);
    LOG.info("    Base dir: " + baseDir);
    LOG.info("  Read file after open: " + readFileAfterOpen);
    LOG.info("  Collection array upload interval(second):"+sectionInterval);
    LOG.info("  Collection num files:"+sectionNum);
    LOG.info("  Virtual memory limit:"+ulimt+"KB");
    LOG.info("  JVM param:"+jvmopt);
    LOG.info("  hardlinks:"+hardlinks);
    // Set user-defined parameters, so the map method can access the values
    config.set("test.nnbench.operation", operation);
    config.setLong("test.nnbench.maps", numberOfMaps);
    config.setLong("test.nnbench.reduces", numberOfReduces);
    config.setLong("test.nnbench.starttime", startTime);
    config.setLong("test.nnbench.blocksize", blockSize);
    config.setInt("test.nnbench.bytestowrite", bytesToWrite);
    config.setLong("test.nnbench.bytesperchecksum", bytesPerChecksum);
    config.setLong("test.nnbench.numberoffiles", numberOfFiles);
    config.setBoolean("test.nnbench.hardlinks", hardlinks);
    config.setInt("test.nnbench.replicationfactor", 
            (int) replicationFactorPerFile);
    config.set("test.nnbench.basedir", baseDir);
    config.setBoolean("test.nnbench.readFileAfterOpen", readFileAfterOpen);

    config.set("test.nnbench.datadir.name", DATA_DIR_NAME);
    config.set("test.nnbench.outputdir.name", OUTPUT_DIR_NAME);
    config.set("test.nnbench.controldir.name", CONTROL_DIR_NAME);
    
    //add by wzt 2012-01-09
    config.setLong("test.nnbench.collectioninterval", sectionInterval);
    config.setInt("test.nnbench.collectionnum", sectionNum);
    
    if(jvmopt == null){
    	//
    }else{
        config.set("mapred.child.java.opts", jvmopt);    	
    }

    if(ulimt == 0){
    	//
    }else{
        config.setInt("mapred.child.ulimit", ulimt);    	
    }

    config.setLong("dfs.block.size", blockSize);//add by wzt
    //end add
  }
  
  /**
   * Analyze the results
   * 
   * @throws IOException on error
   */
  private static void analyzeResults(
    Configuration config
  ) throws IOException {

    final FileSystem fs = FileSystem.get(config);
    Path reduceFile = new Path(new Path(baseDir, OUTPUT_DIR_NAME),
            "part-00000");

    DataInputStream in;
    in = new DataInputStream(fs.open(reduceFile));

    BufferedReader lines;
    lines = new BufferedReader(new InputStreamReader(in));

    long totalTimeAL1 = 0l;
    long totalTimeAL2 = 0l;
    long totalTimeTPmS = 0l;
    long lateMaps = 0l;
    long numOfExceptions = 0l;
    long hardlinkErrors = 0l;
    long successfulFileOps = 0l;
    
    long mapStartTimeTPmS = 0l;
    long mapEndTimeTPmS = 0l;
    long failCount = 0;
    
    String resultTPSLine1 = null;
    String resultTPSLine2 = null;
    String resultALLine1 = null;
    String resultALLine2 = null;
    
    String line;
    while((line = lines.readLine()) != null) {
      StringTokenizer tokens = new StringTokenizer(line, " \t\n\r\f%;");
      String attr = tokens.nextToken();
      if (attr.endsWith(":totalTimeAL1")) {
        totalTimeAL1 = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":totalTimeAL2")) {
        totalTimeAL2 = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":totalTimeTPmS")) {
        totalTimeTPmS = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":latemaps")) {
        lateMaps = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":numOfExceptions")) {
        numOfExceptions = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":hardlinkErrors")) {
        hardlinkErrors = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":successfulFileOps")) {
        successfulFileOps = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":mapStartTimeTPmS")) {
        mapStartTimeTPmS = Long.parseLong(tokens.nextToken());
      } else if (attr.endsWith(":mapEndTimeTPmS")) {
        mapEndTimeTPmS = Long.parseLong(tokens.nextToken());
      }else if(attr.endsWith(":failCount")){
    	  failCount = Long.parseLong(tokens.nextToken());
      }
    }
    
    // Average latency is the average time to perform 'n' number of
    // operations, n being the number of files
    double avgLatency1 = (double) totalTimeAL1 / successfulFileOps;
    double avgLatency2 = (double) totalTimeAL2 / successfulFileOps;
    
    // The time it takes for the longest running map is measured. Using that,
    // cluster transactions per second is calculated. It includes time to 
    // retry any of the failed operations
    double longestMapTimeTPmS = (double) (mapEndTimeTPmS - mapStartTimeTPmS);
    double totalTimeTPS = (longestMapTimeTPmS == 0) ?
            (1000 * successfulFileOps) :
            (double) (1000 * successfulFileOps) / longestMapTimeTPmS;
            
    // The time it takes to perform 'n' operations is calculated (in ms),
    // n being the number of files. Using that time, the average execution 
    // time is calculated. It includes time to retry any of the
    // failed operations
    double AverageExecutionTime = (totalTimeTPmS == 0) ?
        (double) successfulFileOps : 
        (double) totalTimeTPmS / successfulFileOps;
            
    if (operation.equals(OP_CREATE_WRITE)) {
      // For create/write/close, it is treated as two transactions,
      // since a file create from a client perspective involves create and close
      resultTPSLine1 = "               TPS: Create/Write/Close: " + 
        (int) (totalTimeTPS * 2);
      resultTPSLine2 = "Avg exec time (ms): Create/Write/Close: " + 
        AverageExecutionTime;
      resultALLine1 = "            Avg Lat (ms): Create/Write: " + avgLatency1;
      resultALLine2 = "                   Avg Lat (ms): Close: " + avgLatency2;
    } else if (operation.equals(OP_OPEN_READ)) {
      resultTPSLine1 = "                        TPS: Open/Read: " + 
        (int) totalTimeTPS;
      resultTPSLine2 = "         Avg Exec time (ms): Open/Read: " + 
        AverageExecutionTime;
      resultALLine1 = "                    Avg Lat (ms): Open: " + avgLatency1;
      if (readFileAfterOpen) {
        resultALLine2 = "                  Avg Lat (ms): Read: " + avgLatency2;
      }
    } else if (operation.equals(OP_RENAME)) {
      resultTPSLine1 = "                           TPS: Rename: " + 
        (int) totalTimeTPS;
      resultTPSLine2 = "            Avg Exec time (ms): Rename: " + 
        AverageExecutionTime;
      resultALLine1 = "                  Avg Lat (ms): Rename: " + avgLatency1;
    } else if (operation.equals(OP_DELETE)) {
      resultTPSLine1 = "                           TPS: Delete: " + 
        (int) totalTimeTPS;
      resultTPSLine2 = "            Avg Exec time (ms): Delete: " + 
        AverageExecutionTime;
      resultALLine1 = "                  Avg Lat (ms): Delete: " + avgLatency1;
    }
    
    String resultLines[] = {
    "-------------- NNBench -------------- : ",
    "                               Version: " + NNBENCH_VERSION,
    "                           Date & time: " + sdf.format(new Date(
            System.currentTimeMillis())),
    "",
    "                        Test Operation: " + operation,
    "                            Start time: " + 
      sdf.format(new Date(startTime)),
    "                           Maps to run: " + numberOfMaps,
    "                        Reduces to run: " + numberOfReduces,
    "                    Block Size (bytes): " + blockSize,
    "                        Bytes to write: " + bytesToWrite,
    "                    Bytes per checksum: " + bytesPerChecksum,
    "                       Number of files: " + numberOfFiles,
    "                    Replication factor: " + replicationFactorPerFile,
    "            Successful file operations: " + successfulFileOps,
    "",
    "        # maps that missed the barrier: " + lateMaps,
    "                          # exceptions: " + numOfExceptions,
    "                    # hardlink errors : " + hardlinkErrors,
    "",
    resultTPSLine1,
    resultTPSLine2,
    resultALLine1,
    resultALLine2,
    "",
    "                 RAW DATA: AL Total #1: " + totalTimeAL1,
    "                 RAW DATA: AL Total #2: " + totalTimeAL2,
    "              RAW DATA: TPS Total (ms): " + totalTimeTPmS,
    "       RAW DATA: Longest Map Time (ms): " + longestMapTimeTPmS,
    "                   RAW DATA: Late maps: " + lateMaps,
    "             RAW DATA: # of exceptions: " + numOfExceptions,
    "       #failCount                     : " + failCount,
    ""};

    PrintStream res = new PrintStream(new FileOutputStream(
            new File(DEFAULT_RES_FILE_NAME), true));
    
    // Write to a file and also dump to log
    for(int i = 0; i < resultLines.length; i++) {
      LOG.info(resultLines[i]);
      res.println(resultLines[i]);
    }
  }
  
  /**
   * Run the test
   * 
   * @throws IOException on error
   */
  public static void runTests(Configuration config) throws IOException {
    config.setLong("io.bytes.per.checksum", bytesPerChecksum);
    
    JobConf job = new JobConf(config, NNBench.class);

    job.setJobName("NNBench-" + operation);
    FileInputFormat.setInputPaths(job, new Path(baseDir, CONTROL_DIR_NAME));
    job.setInputFormat(SequenceFileInputFormat.class);
    
    // Explicitly set number of max map attempts to 1.
    job.setMaxMapAttempts(1);
    
    // Explicitly turn off speculative execution
    job.setSpeculativeExecution(false);

    job.setMapperClass(NNBenchMapper.class);
    job.setReducerClass(NNBenchReducer.class);

    FileOutputFormat.setOutputPath(job, new Path(baseDir, OUTPUT_DIR_NAME));
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);
    job.setNumReduceTasks((int) numberOfReduces);
    JobClient.runJob(job);
  }
  
  /**
   * Validate the inputs
   */
  public static void validateInputs() {
    // If it is not one of the four operations, then fail
    if (!operation.equals(OP_CREATE_WRITE) &&
            !operation.equals(OP_OPEN_READ) &&
            !operation.equals(OP_RENAME) &&
            !operation.equals(OP_DELETE)) {
      System.err.println("Error: Unknown operation: " + operation);
      displayUsage();
      System.exit(-1);
    }
    
    // If number of maps is a negative number, then fail
    // Hadoop allows the number of maps to be 0
    if (numberOfMaps < 0) {
      System.err.println("Error: Number of maps must be a positive number");
      displayUsage();
      System.exit(-1);
    }
    
    // If number of reduces is a negative number or 0, then fail
    if (numberOfReduces <= 0) {
      System.err.println("Error: Number of reduces must be a positive number");
      displayUsage();
      System.exit(-1);
    }

    // If blocksize is a negative number or 0, then fail
    if (blockSize <= 0) {
      System.err.println("Error: Block size must be a positive number");
      displayUsage();
      System.exit(-1);
    }
    
    // If bytes to write is a negative number, then fail
    if (bytesToWrite < 0) {
      System.err.println("Error: Bytes to write must be a positive number");
      displayUsage();
      System.exit(-1);
    }
    
    // If bytes per checksum is a negative number, then fail
    if (bytesPerChecksum < 0) {
      System.err.println("Error: Bytes per checksum must be a positive number");
      displayUsage();
      System.exit(-1);
    }
    
    // If number of files is a negative number, then fail
    if (numberOfFiles < 0) {
      System.err.println("Error: Number of files must be a positive number");
      displayUsage();
      System.exit(-1);
    }
    
    // If replication factor is a negative number, then fail
    if (replicationFactorPerFile < 0) {
      System.err.println("Error: Replication factor must be a positive number");
      displayUsage();
      System.exit(-1);
    }
    
    // If block size is not a multiple of bytesperchecksum, fail
    if (blockSize % bytesPerChecksum != 0) {
      System.err.println("Error: Block Size in bytes must be a multiple of " +
              "bytes per checksum: blockSize="+blockSize +" bytesPerChecksum="+bytesPerChecksum);
      displayUsage();
      System.exit(-1);
    }
  }
  /**
  * Main method for running the NNBench benchmarks
  *
  * @param args array of command line arguments
  * @throws IOException indicates a problem with test startup
  */
  public static void main(String[] args) throws Exception {
    int res = ToolRunner.run(new NNBench(), args);
    System.exit(res);
  }

  @Override
  public int run(String[] args) throws Exception {
    final Configuration config = getConf();
    // Display the application version string
    displayVersion();

    // Parse the inputs
    parseInputs(args, config);
    
    // Validate inputs
    validateInputs();
    
    // Clean up files before the test run
    cleanupBeforeTestrun(config);
    
    // Create control files before test run
    createControlFiles(config);

    // Run the tests as a map reduce job
    runTests(config);
    
    // Analyze results
    analyzeResults(config);

    return 0;
  }

  
  /**
   * Mapper class
   */
  static class NNBenchMapper extends Configured 
          implements Mapper<Text, LongWritable, Text, Text> {
    FileSystem filesystem = null;
    private String hostName = null;

    private Random random = new Random();
    long numberOfFiles = 1l;
    boolean hardlinks = false;
    long blkSize = 1l;
    short replFactor = 1;
    int bytesToWrite = 0;
    String baseDir = null;
    String dataDirName = null;
    String op = null;
    boolean readFile = false;
    final int MAX_OPERATION_EXCEPTIONS = 1000;
    //add by wzt
    private static long maxExceptionsPerFile = 200;
    
    // Data to collect from the operation
    int numOfExceptions = 0;
    long startTimeAL = 0l;
    long totalTimeAL1 = 0l;
    long totalTimeAL2 = 0l;
    long successfulFileOps = 0l;
    long hardlinkErrors = 0l;
    List<List<Path>> hardlinkList = new ArrayList<List<Path>>();
    //add by wzt 2012-01-09
    long sectionInterval = 0l;
    int  sectionNum = 0;
    int  failCount = 0;
    long allMapTotaFiles = 0;
    //end add
    /**
     * Constructor
     */
    public NNBenchMapper() {
    }
    
    /**
     * Mapper base implementation
     */
    public void configure(JobConf conf) {
        LOG.info("wzt debuginfo:MR configure");
    	setConf(conf);
      try {
        filesystem = FileSystem.get(conf);
      } catch(Exception e) {
        throw new RuntimeException("Cannot get file system.", e);
      }
      
      try {
        hostName = InetAddress.getLocalHost().getHostName();
      } catch(Exception e) {
        throw new RuntimeException("Error getting hostname", e);
      }
      
    }
    
    /**
     * Mapper base implementation
     */
    public void close() throws IOException {
    	LOG.info("wzt debuginfo:MR close");
    }
    
    /**
    * Returns when the current number of seconds from the epoch equals
    * the command line argument given by <code>-startTime</code>.
    * This allows multiple instances of this program, running on clock
    * synchronized nodes, to start at roughly the same time.
     * @return true if the method was able to sleep for <code>-startTime</code>
     * without interruption; false otherwise
    */
    private boolean barrier() {
      long startTime = getConf().getLong("test.nnbench.starttime", 0l);
      long currentTime = System.currentTimeMillis();
      //long sleepTime = startTime - currentTime;
      long sleepTime = currentTime - startTime;//update by wzt 2012-01-16
      boolean retVal = false;
      
      // If the sleep time is greater than 0, then sleep and return
      if (sleepTime > 0) {
        LOG.info("Waiting in barrier for: " + sleepTime + " ms");
      
        try {
          Thread.sleep(sleepTime);
          retVal = true;
        } catch (Exception e) {
          retVal = false;
        }
      }
      
      return retVal;
    }

//    private void createHardLinks(Path filePath) throws IOException {
//      if (hardlinks && random.nextBoolean()) {
//        List<Path> hardlinks = new ArrayList<Path>();
//        hardlinks.add(filePath);
//        int nlinks = 1 + random.nextInt(3);
//        for (int i = 0; i < nlinks; i++) {
//          Path target = new Path(filePath.toUri() + "hardlink" + i);
//          filesystem.hardLink(filePath, target);
//          if (random.nextBoolean()) {
//            // Delete directly from namenode, otherwise file will
//            // instead go to trash.
//            if (filesystem instanceof FilterFileSystem) {//wzt debuginfo
//              ((DistributedFileSystem) (((FilterFileSystem) filesystem)
//                .getRawFileSystem())).dfs.namenode.delete(target
//              .toString());
//            } else {
//              ((DistributedFileSystem) filesystem).dfs.namenode
//                .delete(target.toString());
//            }
//          } else {
//            hardlinks.add(target);
//          }
//        }
//        hardlinkList.add(hardlinks);
//      }
//    }

//    private void verifyHardLinks() {
//      if (hardlinks) {
//        for (List<Path> paths : hardlinkList) {
//          try {
//            Path src = paths.get(0);
//            String[] actual = filesystem.getHardLinkedFiles(src);
//            Arrays.sort(actual);
//            String[] expected = new String[paths.size() - 1];
//            for (int i = 1; i < paths.size(); i++) {
//              expected[i-1] = paths.get(i).toString();
//            }
//            Arrays.sort(expected);
//            LOG.info("Actual hardlink files for " + src + " : ");
//            for (String s : actual) {
//              LOG.info(s);
//            }
//            LOG.info("Expected hardlink files for " + src + " : ");
//            for (String s : expected) {
//              LOG.info(s);
//            }
//            if (!Arrays.equals(expected, actual)) {
//              LOG.warn("Hardlinked files for : " + src + " do not match!");
//              hardlinkErrors++;
//            }
//          } catch (IOException e) {
//            LOG.info("Exception recorded in op: " +
//                "getHardLinkedFiles");
//            numOfExceptions++;
//          }
//        }
//      }
//    }//end func
    
    /**
     * Map method
     */ 
    public void map(Text key, 
            LongWritable value,
            OutputCollector<Text, Text> output,
            Reporter reporter) throws IOException {
    	LOG.info("wzt debuginfo:mr map ...");
      Configuration conf = filesystem.getConf();
      
      numberOfFiles = conf.getLong("test.nnbench.numberoffiles", 1l);
      hardlinks = conf.getBoolean("test.nnbench.hardlinks", false);
      blkSize = conf.getLong("test.nnbench.blocksize", 1l);
      replFactor = (short) (conf.getInt("test.nnbench.replicationfactor", 1));
      bytesToWrite = conf.getInt("test.nnbench.bytestowrite", 0);
      baseDir = conf.get("test.nnbench.basedir");
      dataDirName = conf.get("test.nnbench.datadir.name");
      op = conf.get("test.nnbench.operation");
      readFile = conf.getBoolean("test.nnbench.readFileAfterOpen", false);

      //add by wzt 2012-01-09
      sectionInterval =conf.getLong("test.nnbench.collectioninterval", 10*1000);
      sectionNum =conf.getInt("test.nnbench.collectionnum", 100);
      allMapTotaFiles = conf.getLong("test.nnbench.totalfiles", 1);
      //end add
      
      long totalTimeTPmS = 0l;
      long startTimeTPmS = 0l;
      long endTimeTPms = 0l;
      
      numOfExceptions = 0;
      hardlinkErrors = 0l;
      startTimeAL = 0l;
      totalTimeAL1 = 0l;
      totalTimeAL2 = 0l;
      successfulFileOps = 0l;
      LOG.info("wzt debuginfo:mr map barrier before");
      if (barrier()) {
    	  LOG.info("wzt debuginfo:mr map barrier after");
        if (op.equals(OP_CREATE_WRITE)) {
        	LOG.info("wzt debuginfo:mr map create_write ");
          startTimeTPmS = System.currentTimeMillis();
          doCreateWriteOp("file_" + hostName + "_", reporter);
        } else if (op.equals(OP_OPEN_READ)) {
        	LOG.info("wzt debuginfo:mr map open_read ");
          startTimeTPmS = System.currentTimeMillis();
          doOpenReadOp("file_" + hostName + "_", reporter);
        } else if (op.equals(OP_RENAME)) {
        	LOG.info("wzt debuginfo:mr map rename ");        	
          startTimeTPmS = System.currentTimeMillis();
          doRenameOp("file_" + hostName + "_", reporter);
        } else if (op.equals(OP_DELETE)) {
        	LOG.info("wzt debuginfo:mr map delete ");
          startTimeTPmS = System.currentTimeMillis();
          doDeleteOp("file_" + hostName + "_", reporter);
        }
        
        endTimeTPms = System.currentTimeMillis();
        totalTimeTPmS = endTimeTPms - startTimeTPmS;
      } else {
        output.collect(new Text("l:latemaps"), new Text("1"));
      }
      
      // collect after the map end time is measured
      output.collect(new Text("l:totalTimeAL1"), 
          new Text(String.valueOf(totalTimeAL1)));
      output.collect(new Text("l:totalTimeAL2"), 
          new Text(String.valueOf(totalTimeAL2)));
      output.collect(new Text("l:numOfExceptions"), 
          new Text(String.valueOf(numOfExceptions)));
      output.collect(new Text("l:hardlinkErrors"),
          new Text(String.valueOf(hardlinkErrors)));
      output.collect(new Text("l:successfulFileOps"), 
          new Text(String.valueOf(successfulFileOps)));
      output.collect(new Text("l:totalTimeTPmS"), 
              new Text(String.valueOf(totalTimeTPmS)));
      output.collect(new Text("min:mapStartTimeTPmS"), 
          new Text(String.valueOf(startTimeTPmS)));
      output.collect(new Text("max:mapEndTimeTPmS"), 
          new Text(String.valueOf(endTimeTPms)));
      output.collect(new Text("l:failCount"), 
    	  new Text(String.valueOf(failCount)));
    }

    static private void handleException(String operation, Throwable e, 
            int singleFileExceptions) {
    	LOG.warn("Exception while " + operation + ": " +
    			StringUtils.stringifyException(e));
    	if (singleFileExceptions >= maxExceptionsPerFile) {
    		throw new RuntimeException(singleFileExceptions + 
    				" exceptions for a single file exceeds threshold. Aborting");
    	}
}
    
    /**
     * Create and Write operation.
     * @param name of the prefix of the putput file to be created
     * @param reporter an instanse of (@link Reporter) to be used for
     *   status' updates
     */
    private void doCreateWriteOp(String name,
            Reporter reporter) {
      FSDataOutputStream out=null;
      int totalExceptions = 0;
      boolean success;
      //byte[] buffer = new byte[bytesToWrite];
      // initialize buffer used for writing/reading file
      byte[] buffer = new byte[(int) Math.min(bytesToWrite, 32768L)];
      for(int k=0;k<buffer.length;k++){
      	int tmpasc = k - '0';
      	buffer[k]=(byte)tmpasc;
      }//end for
      
      LOG.info("wzt debuginfo:numberOfFiles:"+numberOfFiles);
      
      for (long l = 0l; l < numberOfFiles; l++) {
        int singleFileExceptions = 0;
        Path filePath = new Path(new Path(baseDir, dataDirName), 
                name + "_" + l);
        
        boolean successfulOp = false;
        while (!successfulOp && numOfExceptions < MAX_OPERATION_EXCEPTIONS) {
          try {
            // Set up timer for measuring AL (transaction #1)
            startTimeAL = System.currentTimeMillis();
            
            //update by wzt 2012-01-09
            totalExceptions = 10;
            do { // create file until is succeeds or max exceptions reached
                try {
                  out = filesystem.create(
                		  filePath, false, 512,
                          (short)replFactor, blkSize);
                 
                  LOG.info("wzt debuginfo: success create file:" + filePath);
                  
                  success = true;
                } catch (IOException ioe) { 
                  success=false; 
                  totalExceptions--;
                  handleException("creating file #" + l, ioe,
                          ++singleFileExceptions);
                }
              } while (!success && totalExceptions > 0 );//创建文件直到成功
              
              if(!success || totalExceptions <= 0){
            	  LOG.info("wzt debuginfo: fail create file:"+filePath);
            	  this.failCount++;
            	  continue;
              }
//            try{
//                // Create the file
//                // Use a buffer size of 512
//                out = filesystem.create(filePath, 
//                        true, 
//                        512, 
//                        replFactor, 
//                        blkSize);
//                success = true;
//            	
//            }catch(IOException ioe ){
//                success=false; 
//                totalExceptions++;
//                handleException("creating file #" + l, ioe,
//                        ++singleFileExceptions);
//            }
//            if(!success){
//            	continue;
//            }
            //end add
            
            //update by wzt 2012-01-09
            //out.write(buffer);
        	  System.out.println("wzt debuginfo: write file bytes:"+bytesToWrite);
            long toBeWritten = bytesToWrite;
            while (toBeWritten > 0) {
                int nbytes = (int) Math.min(buffer.length, toBeWritten);
                toBeWritten -= nbytes;
                try { // only try once
                  out.write(buffer, 0, nbytes);
                } catch (IOException ioe) {
                  totalExceptions++;
                  handleException("writing to file #" + l, ioe,
                          ++singleFileExceptions);
                }
              }//end while
             //end update
               
           totalTimeAL1 += (System.currentTimeMillis() - startTimeAL);
           // Close the file / file output stream
           // Set up timers for measuring AL (transaction #2)
           startTimeAL = System.currentTimeMillis();
          
          //update by wzt 2013-010-08
          //out.close();
          totalExceptions=10;
          do { // close file until is succeeds
          try {
            out.close();
            success = true;
            System.out.println("wzt debuginfo:close file success "+filePath);
          } catch (IOException ioe) {
            success=false; 
            totalExceptions--;
            handleException("closing file #" + l, ioe,
                    ++singleFileExceptions);
          }
        } while (!success && totalExceptions > 0 );
        //end update
        
        if(!success || totalExceptions <= 0){
        	failCount++;
        }
         
         
        totalTimeAL2 += (System.currentTimeMillis() - startTimeAL);
        successfulOp = true;
        successfulFileOps ++;

          reporter.setStatus("Finish "+ l + " files");
          //createHardLinks(filePath);
         } catch (Exception e) {
            LOG.info("Exception recorded in op: " +
                    "Create/Write/Close/HardLink");
             numOfExceptions++;
         }catch(OutOfMemoryError ooMIe){
        	 LOG.info(" create write outofmemory ",ooMIe);
        	 System.gc();
        	 try{
        		 Thread.sleep(10*1000);
        	 }catch(Exception er){}
         }//end catch
        }//end while (!successfulOp && numOfExceptions < MAX_OPERATION_EXCEPTIONS)
        
        //add by wzt 2012-01-09
        if(l % sectionNum  == 0){
            try{
            	Thread.sleep(sectionInterval);
            }catch(Exception er){
            	System.err.println(er);
            }
        	
        }//end if
        
        //end add
        float progress = Math.min(1.0f, (allMapTotaFiles - l) / (float) (allMapTotaFiles - l));
        reporter.incrCounter("mapprogress", "File complete count", (long)progress);
        //reporter.setProgress(progress);
        //reporter.setProgress(progress);
      }//end for
      //verifyHardLinks();

    }
	/**
	 * Get the progress within the split
	 */
    
    /**
     * Open operation
     * @param name of the prefix of the putput file to be read
     * @param reporter an instanse of (@link Reporter) to be used for
     *   status' updates
     */
    private void doOpenReadOp(String name,
            Reporter reporter) {
      FSDataInputStream input;
      int singleFileExceptions = 0;
      //update by wzt 2012-01-09
      //byte[] buffer = new byte[bytesToWrite];
      // initialize buffer used for writing/reading file
      byte[] buffer = new byte[(int) Math.min(bytesToWrite, 32768L)];
      //end add
      
      for (long l = 0l; l < numberOfFiles; l++) {
        Path filePath = new Path(new Path(baseDir, dataDirName), 
                name + "_" + l);

        boolean successfulOp = false;
        while (! successfulOp && numOfExceptions < MAX_OPERATION_EXCEPTIONS) {
          int totalExceptions = 0;
          try {
            // Set up timer for measuring AL
            startTimeAL = System.currentTimeMillis();
            input = filesystem.open(filePath);
            totalTimeAL1 += (System.currentTimeMillis() - startTimeAL);
            
            // If the file needs to be read (specified at command line)
            if (readFile) {
              startTimeAL = System.currentTimeMillis();
              
              //update by wzt 2013-01-09
              //input.readFully(buffer);
              long toBeRead = bytesToWrite;
              while (toBeRead > 0) {
                int nbytes = (int) Math.min(buffer.length, toBeRead);
                toBeRead -= nbytes;
                try { // only try once && we don't care about a number of bytes read
                  input.readFully(buffer, 0, nbytes);
                } catch (IOException ioe) {
                  totalExceptions++;
                  handleException("reading from file #" + l, ioe,++singleFileExceptions);
                }
              }//end while

              totalTimeAL2 += (System.currentTimeMillis() - startTimeAL);
            }

            input.close();
            
            successfulOp = true;
            successfulFileOps ++;

            reporter.setStatus("Finish "+ l + " files");
          } catch (IOException e) {
            LOG.info("Exception recorded in op: OpenRead " + e);
            numOfExceptions++;
          }catch(OutOfMemoryError ooMIe){
        	  LOG.info("read outofmemory",ooMIe);
        	  System.gc();
        	  try{
        		  Thread.sleep(10*1000);
        	  }catch(Exception er){}
          }//enc catch
        }//end while (! successfulOp && numOfExceptions < MAX_OPERATION_EXCEPTIONS)
      }//end for
    }//end func
    
    /**
     * Rename operation
     * @param name of prefix of the file to be renamed
     * @param reporter an instanse of (@link Reporter) to be used for
     *   status' updates
     */
    private void doRenameOp(String name,
            Reporter reporter) {
      for (long l = 0l; l < numberOfFiles; l++) {
        Path filePath = new Path(new Path(baseDir, dataDirName), 
                name + "_" + l);
        Path filePathR = new Path(new Path(baseDir, dataDirName), 
                name + "_r_" + l);

        boolean successfulOp = false;
        while (! successfulOp && numOfExceptions < MAX_OPERATION_EXCEPTIONS) {
          try {
            // Set up timer for measuring AL
            startTimeAL = System.currentTimeMillis();
            filesystem.rename(filePath, filePathR);
            totalTimeAL1 += (System.currentTimeMillis() - startTimeAL);
            
            successfulOp = true;
            successfulFileOps ++;

            reporter.setStatus("Finish "+ l + " files");
          } catch (IOException e) {
            LOG.info("Exception recorded in op: Rename");

            numOfExceptions++;
          }
        }
      }
    }
    
    /**
     * Delete operation
     * @param name of prefix of the file to be deleted
     * @param reporter an instanse of (@link Reporter) to be used for
     *   status' updates
     */
    private void doDeleteOp(String name,
            Reporter reporter) {
      for (long l = 0l; l < numberOfFiles; l++) {
        Path filePath = new Path(new Path(baseDir, dataDirName), 
                name + "_" + l);
        
        boolean successfulOp = false;
        while (! successfulOp && numOfExceptions < MAX_OPERATION_EXCEPTIONS) {
          try {
            // Set up timer for measuring AL
            startTimeAL = System.currentTimeMillis();
            filesystem.delete(filePath, true);
            totalTimeAL1 += (System.currentTimeMillis() - startTimeAL);
            
            successfulOp = true;
            successfulFileOps ++;

            reporter.setStatus("Finish "+ l + " files");
          } catch (IOException e) {
            LOG.info("Exception in recorded op: Delete");

            numOfExceptions++;
          }
        }
      }
    }
  }
  
  /**
   * Reducer class
   */
  static class NNBenchReducer extends MapReduceBase
      implements Reducer<Text, Text, Text, Text> {

    protected String hostName;

    public NNBenchReducer () {
      LOG.info("Starting NNBenchReducer !!!");
      try {
        hostName = java.net.InetAddress.getLocalHost().getHostName();
      } catch(Exception e) {
        hostName = "localhost";
      }
      LOG.info("Starting NNBenchReducer on " + hostName);
    }

    /**
     * Reduce method
     */
    public void reduce(Text key, 
                       Iterator<Text> values,
                       OutputCollector<Text, Text> output, 
                       Reporter reporter
                       ) throws IOException {
      String field = key.toString();
      
      reporter.setStatus("starting " + field + " ::host = " + hostName);
      
      // sum long values
      if (field.startsWith("l:")) {
        long lSum = 0;
        while (values.hasNext()) {
          lSum += Long.parseLong(values.next().toString());
        }
        output.collect(key, new Text(String.valueOf(lSum)));
      }
      
      if (field.startsWith("min:")) {
        long minVal = -1;
        while (values.hasNext()) {
          long value = Long.parseLong(values.next().toString());
          
          if (minVal == -1) {
            minVal = value;
          } else {
            if (value != 0 && value < minVal) {
              minVal = value;
            }
          }
        }
        output.collect(key, new Text(String.valueOf(minVal)));
      }
      
      if (field.startsWith("max:")) {
        long maxVal = -1;
        while (values.hasNext()) {
          long value = Long.parseLong(values.next().toString());
          
          if (maxVal == -1) {
            maxVal = value;
          } else {
            if (value > maxVal) {
              maxVal = value;
            }
          }
        }
        output.collect(key, new Text(String.valueOf(maxVal)));
      }
      
      reporter.setStatus("finished " + field + " ::host = " + hostName);
    }
  }
}
