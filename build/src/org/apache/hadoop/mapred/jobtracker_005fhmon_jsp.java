package org.apache.hadoop.mapred;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.text.DecimalFormat;
import org.apache.hadoop.mapred.*;
import org.apache.hadoop.util.*;

public final class jobtracker_005fhmon_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {


  private static DecimalFormat percentFormat = new DecimalFormat("##0.00");

  //  Filter the jobs by a list of jobids
  //  @param jobs  the jobs to be filtered
  //  @param jobIds  the job ids that needs to be retained
  //  @return  filtered jobs
  public List<JobInProgress> filterJobs(List<JobInProgress> jobs, String[] jobIds) {
    List<JobInProgress> filteredJobs = new LinkedList<JobInProgress>();
    Set<String> jobIdSet = new HashSet<String>(Arrays.asList(jobIds));
    for (JobInProgress job : jobs) {
      if (jobIdSet.contains(job.getJobID().toString())) {
        filteredJobs.add(job);
      }
    }
    return filteredJobs;
  }
  
  public void generateSummaryTable(JspWriter out, ClusterStatus status,
                                   JobTracker tracker) throws IOException {
    String tasksPerNode = status.getTaskTrackers() > 0 ?
      percentFormat.format(((double)(status.getMaxMapTasks() +
               status.getMaxReduceTasks())) / status.getTaskTrackers()) : "-";
    out.print("<table border=\"1\" cellpadding=\"5\" cellspacing=\"0\">\n" +
              "<tr><th colspan=6>Maps</th>" +
              "<th colspan=6>Reduces</th>" +
              "<th colspan=3>Nodes</th>" +
              "<th colspan=2>Jobs</th>" +
              "<th rowspan=2>Avg. Tasks/Node</th></tr>\n");
    out.print("<tr><td>Running</td><td>Waiting</td><td>Complete</td>" +
              "<td>Total</td><td>Capacity</td><td>Idle</td>" +
              "<td>Running</td><td>Waiting</td><td>Complete</td>" +
              "<td>Total</td><td>Capacity</td><td>Idle</td>" +
              "<td>Total</td><td>Blacklisted</td><td>Excluded</td>" +
              "<td>Running</td><td>Total</td></tr>\n");
    // Compute the total and finished tasks
    int totalMaps = 0;
    int completeMaps = 0;
    int totalReduces = 0;
    int completeReduces = 0;
    int pendingMaps = 0;
    int pendingReduces = 0;
    int runningJobs = tracker.getRunningJobs().size();
    for (JobInProgress job : tracker.getRunningJobs()) {
      totalMaps += job.desiredMaps();
      totalReduces += job.desiredReduces();
      completeMaps += job.finishedMaps();
      completeReduces += job.finishedReduces();
      pendingMaps += job.pendingMaps();
      pendingReduces += job.pendingReduces();
    }
    int runMaps = status.getMapTasks();
    int capMaps = status.getMaxMapTasks();
    int idleMaps = capMaps - runMaps;
    int runReduces = status.getReduceTasks();
    int capReduces = status.getMaxReduceTasks();
    int idleReduces = capReduces - runReduces;
    out.print("<tr><td>" + runMaps + "</td>" +
              "<td>" + pendingMaps + "</td>" +
              "<td>" + completeMaps + "</td>" +
              "<td>" + totalMaps + "</td>" +
              "<td>" + capMaps + "</td>" +
              "<td>" + idleMaps + "</td>" +
              "<td>" + runReduces + "</td>" +
              "<td>" + pendingReduces + "</td>" +
              "<td>" + completeReduces + "</td>" +
              "<td>" + totalReduces + "</td>" +
              "<td>" + capReduces + "</td>" +
              "<td>" + idleReduces + "</td>" +
              "<td><a href=\"machines.jsp?type=active\">" +
              status.getTaskTrackers() + "</a></td>" +
              "<td><a href=\"machines.jsp?type=blacklisted\">" +
              status.getBlacklistedTrackers() + "</a></td>" +
              "<td><a href=\"machines.jsp?type=excluded\">" +
              status.getNumExcludedNodes()+ "</a></td>" +
              "<td>" + runningJobs + "</td>" +
              "<td>" + tracker.getTotalSubmissions() + "</td>" +
              "<td>" + tasksPerNode + "</td></tr></table>\n");
    out.print("<br>");
    out.print(JSPUtil.generateClusterResTable(tracker));
    out.print("<br>");
    if (tracker.hasRestarted()) {
      out.print("<span class=\"small\"><i>");
      if (tracker.hasRecovered()) {
        out.print("The JobTracker got restarted and recovered back in " );
        out.print(StringUtils.formatTime(tracker.getRecoveryDuration()));
      } else {
        out.print("The JobTracker got restarted and is still recovering");
      }
      out.print("</i></span>");
    }
  }
  private static java.util.List _jspx_dependants;

  public Object getDependants() {
    return _jspx_dependants;
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    JspFactory _jspxFactory = null;
    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      _jspxFactory = JspFactory.getDefaultFactory();
      response.setContentType("text/html; charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write('\n');

  JobTracker tracker = (JobTracker) application.getAttribute("job.tracker");
  ClusterStatus status = tracker.getClusterStatus();
  String trackerName = 
           StringUtils.simpleHostname(tracker.getJobTrackerMachine());
  JobQueueInfo[] queues = tracker.getQueues();
  List<JobInProgress> runningJobs = tracker.getRunningJobs();
  List<JobInProgress> completedJobs = tracker.getCompletedJobs();
  List<JobInProgress> failedJobs = tracker.getFailedJobs();

      out.write('\n');
      out.write("\n\n\n<html>\n<head>\n<title>");
      out.print( trackerName );
      out.write(" Hadoop Map/Reduce Administration</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"/static/hadoop.css\">\n<script type=\"text/javascript\" src=\"/static/jobtracker.js\"></script>\n</head>\n<body>\n\n");
 JSPUtil.processButtons(request, response, tracker); 
      out.write("\n\n<h1>");
      out.print( trackerName );
      out.write(" Hadoop Map/Reduce Administration</h1>\n\n<div id=\"quicklinks\">\n  <a href=\"#quicklinks\" onclick=\"toggle('quicklinks-list'); return false;\">Quick Links</a>\n  <ul id=\"quicklinks-list\">\n    <li><a href=\"#running_jobs\">Running Jobs</a></li>\n    <li><a href=\"#retired_jobs\">Retired Jobs</a></li>\n    <li><a href=\"#local_logs\">Local Logs</a></li>\n  </ul>\n</div>\n\n<b>State:</b> ");
      out.print( status.getJobTrackerState() );
      out.write("<br>\n<b>Started:</b> ");
      out.print( new Date(tracker.getStartTime()));
      out.write("<br>\n<b>Version:</b> ");
      out.print( VersionInfo.getVersion());
      out.write(",\n                r");
      out.print( VersionInfo.getRevision());
      out.write("<br>\n<b>Compiled:</b> ");
      out.print( VersionInfo.getDate());
      out.write(" by \n                 ");
      out.print( VersionInfo.getUser());
      out.write("<br>\n<b>Identifier:</b> ");
      out.print( tracker.getTrackerIdentifier());
      out.write("<br>                 \n                   \n<hr>\n<h2>Cluster Summary (Heap Size is ");
      out.print( StringUtils.byteDesc(status.getUsedMemory()) );
      out.write('/');
      out.print( StringUtils.byteDesc(status.getMaxMemory()) );
      out.write(")</h2>\n");
 
 generateSummaryTable(out, status, tracker); 

      out.write("\n<hr>\n<h2><a href=\"scheduler\">Scheduling Information</a></h2>\n<hr>\n<b>Filter (Jobid, Priority, User, Name)</b> <input type=\"text\" id=\"filter\" onkeyup=\"applyfilter()\"> <br>\n<span class=\"small\">Example: 'user:smith 3200' will filter by 'smith' only in the user field and '3200' in all fields</span>\n<hr>\n<h2 id=\"running_jobs\">Running Jobs</h2>\n");

if (request.getParameter("jobid") == null) {
  out.print(JSPUtil.generateJobTableWithResourceInfo("Running", runningJobs,
            30, 0, tracker));
} else {
  out.print(JSPUtil.generateJobTableWithResourceInfo("Running",
            filterJobs(runningJobs, request.getParameter("jobid").split(",")),
            30, 0, tracker));
}

      out.write("\n<hr>\n\n");

if (completedJobs.size() > 0) {
  out.print("<h2 id=\"completed_jobs\">Completed Jobs</h2>");
  out.print(JSPUtil.generateJobTable("Completed", completedJobs, 0, 
    runningJobs.size()));
  out.print("<hr>");
}

      out.write('\n');
      out.write('\n');

if (failedJobs.size() > 0) {
  out.print("<h2 id=\"failed_jobs\">Failed Jobs</h2>");
  out.print(JSPUtil.generateJobTable("Failed", failedJobs, 0, 
    (runningJobs.size()+completedJobs.size())));
  out.print("<hr>");
}

      out.write("\n\n<h2 id=\"retired_jobs\">Retired Jobs</h2>\n");
      out.print(JSPUtil.generateRetiredJobTable(tracker, 
  (runningJobs.size()+completedJobs.size()+failedJobs.size())));
      out.write("\n<hr>\n\n<h2 id=\"local_logs\">Local Logs</h2>\n<a href=\"logs/\">Log</a> directory, <a href=\"jobhistory.jsp\">\nJob Tracker History</a>\n\n");

out.println(ServletUtil.htmlFooter());

      out.write('\n');
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          out.clearBuffer();
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
      }
    } finally {
      if (_jspxFactory != null) _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
