<!-- -->
<%! //this is a declaration tag
static final String sFileName = "Login.jsp";
String sLoginErr = "";
static final String DBDriver  ="com.mysql.jdbc.Driver";
static final String strConn   ="jdbc:mysql://localhost/Bookstore";
static final String DBusername="root";
static final String DBpassword="password";
%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
%>

<% //create the connection with the database
boolean bDebug = false;
String sForm = request.getParameter("FormName");
if(sForm==null)
  sForm="";

java.sql.Connection conn = null;
java.sql.Statement stat = null;
String sErr="";
try {
    java.sql.DriverManager.registerDriver((java.sql.Driver)(Class.forName(DBDriver).newInstance()));
    conn = java.sql.DriverManager.getConnection(strConn , DBusername, DBpassword);
}
catch (Exception e) {
      sErr = e.toString();
}
if ( ! sErr.equals("") ) {
 try {
   out.println(sErr);
 }
 catch (Exception e) {}
}
stat = conn.createStatement();
%>
<html>
<head>
<meta charset="UTF-8">
<title>Logout Page</title>
</head>
<body>
<% loggedOut(request, response, session, out, sLoginErr, sForm, conn, stat); %>
</body>
</html>

<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>


<%!
//Nofity the user that they have been logged out
  void loggedOut(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
		  //logout of the session
		  session.invalidate();
		  out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<table>");
	      out.println("<tr>");
	      out.println("<th>You Have Been Logged Out</th>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td> <input type = \"submit\" value=\"Sign Back In\"> </td>");
	      out.println("</tr>");
	      out.print("</table>");
	      out.println("</form>");

  }
%>