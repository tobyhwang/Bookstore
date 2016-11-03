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
<title>Add User Information</title>
</head>
<body>
<% addUser(request, response, session, out, sLoginErr, sForm, conn, stat); %>
</body>
</html>

<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>


<%!
//Allow the user to add a new user
  void addUser(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	try {
		out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<table>");
	      out.println("<tr>");
	      out.println("<th>Enter User Information</th>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td><style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 12pt; color: #000000\">Full Name</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"name\" name=\"add_name\" maxlength=\"50\"> </td>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td><style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 12pt; color: #000000\">Username</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"username\" name=\"add_username\" maxlength=\"50\"> </td>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td><style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 12pt; color: #000000\">Password</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"password\" name=\"add_password\" maxlength=\"50\"> </td>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td><style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 12pt; color: #000000\">Address</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"address\" name=\"Address\" maxlength=\"50\"> </td>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td><style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 12pt; color: #000000\">Credit Card #</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"creditcard\" name=\"CreditCard\" maxlength=\"50\"> </td>");
	      out.println("</tr>");
	      out.println("<tr>");
	      out.println("<td> <input type = \"submit\" value=\"Create New User Account\"> </td>");
	      out.println("</tr>");
	      out.print("</table>");
	      out.println("</form>");
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>



