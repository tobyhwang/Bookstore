<!-- -->
<%! //this is a declaration tag
static final String sFileName = "AddUser.jsp";
static final String sLogout = "Logout.jsp";
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
<title>Error Page</title>
</head>
<body>
<center><font size ="12">Error Page</font></center>

	<tr><td><br/></td></tr>
	<% continueButton(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>

</body>
</html>

<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>


<%!
//All the user to continue from the error page
  void continueButton(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {

      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
      out.println("<font size = \"5\"> Please enter missing fields </font>");
      out.println("<tr>");
      out.println("<td> <input type = \"submit\" value=\"Re-Enter Information\"> </td>");
      out.println("</tr>");
      out.println("</form>");

  }
%>
