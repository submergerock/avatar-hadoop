package org.apache.hadoop.hdfs.server.namenode;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import org.apache.hadoop.fs.*;
import org.apache.hadoop.hdfs.*;
import org.apache.hadoop.hdfs.server.common.*;
import org.apache.hadoop.hdfs.server.namenode.*;
import org.apache.hadoop.hdfs.server.datanode.*;
import org.apache.hadoop.hdfs.protocol.*;
import org.apache.hadoop.util.*;
import java.text.DateFormat;
import java.lang.Math;
import java.net.URLEncoder;

public final class dfsnodelist_005ftxt_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {


JspHelper jspHelper = new JspHelper();
public void generateDFSNodesList(JspWriter out,  NameNode nn,
                                 HttpServletRequest request)
                                 throws IOException {
  ArrayList<DatanodeDescriptor> live = new ArrayList<DatanodeDescriptor>();    
  ArrayList<DatanodeDescriptor> dead = new ArrayList<DatanodeDescriptor>();
  ArrayList<DatanodeDescriptor> excluded = new ArrayList<DatanodeDescriptor>();
  jspHelper.DFSNodesStatus(live, dead, excluded);
  String whatNodes = request.getParameter("whatNodes");
  ArrayList<DatanodeDescriptor> toBePrinted;
  if ("DEAD".equalsIgnoreCase(whatNodes)) {
    toBePrinted = dead;
  } else if ("EXCLUDED".equalsIgnoreCase(whatNodes)) {
    toBePrinted = excluded;
  } else if ("LIVE".equalsIgnoreCase(whatNodes)) {
    toBePrinted = live;
  } else { // Default is all nodes
    toBePrinted = new ArrayList<DatanodeDescriptor>();
    toBePrinted.addAll(dead);
    toBePrinted.addAll(excluded);
    toBePrinted.addAll(live);
  }
  for (DatanodeDescriptor d : toBePrinted) {
    out.print(d.getHostName() + "\n");
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
      response.setContentType("text/plain; charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write('\n');
      out.write('\n');

  NameNode nn = (NameNode)application.getAttribute("name.node");
  FSNamesystem fsn = nn.getNamesystem();
  generateDFSNodesList(out, nn, request); 

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
