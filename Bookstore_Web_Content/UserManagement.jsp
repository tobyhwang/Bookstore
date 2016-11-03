<!-- -->
<%@ page import="java.sql.PreparedStatement" %>
<%@ include file="hashPassword.jsp" %>

<%! //this is a declaration tag
static final String sFileName = "UserManageModify.jsp";
static final String sDeleteUser = "UserDelete.jsp";
static final String sAddUser = "UserManageAdd.jsp";
static final String sLogout = "Logout.jsp";
static final String sMainPage = "ShowBooks.jsp";
static final String sSearch = "SearchUser.jsp";
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
<title>User Management</title>
</head>
<body>
<center><font size ="12">Update User Information</font></center>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
	<% searchUser(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<% verifyAdmin(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% showUsers(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% addUser(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
	<% MainPage(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<table border = "1">
	<% Logout(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	</table>
</body>
</html>

<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>

<%!
//Verify that it is an admin user
  void verifyAdmin(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
		int userid = Integer.parseInt(session.getAttribute("UserID").toString());
        String sqlQuery = "SELECT admin FROM Users where user_id = ?";
        ps = conn.prepareStatement(sqlQuery);
        ps.setInt(1, userid);
        java.sql.ResultSet rs = ps.executeQuery(); //execute the query

        while (rs.next())
        {
          if(rs.getString("admin").equals("no")){
	  	      response.sendRedirect("401Page.jsp");
          }
        }
    }
    catch (Exception e) { out.println(e.toString());}

  }
%>


<%!
//allow the Admin to search for a specific user
  void searchUser(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    try {

	      out.println("<form action=\""+sSearch+"\" method=\"POST\">");
	      out.println("<table>");
	      out.println("<th>Search for User (by username)</th>");
	      out.println("<tr>");
	      out.println("<td> <input type=\"text\" name=\"searchUser\" value=\"\"> </td>");
	      out.println("<td><input type = \"submit\" value=\"Search\"></td>");
	      out.println("</tr>");
	      out.println("</form>");
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>

<%!
  void showUsers(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps= null;
	try {
      String sqlQuery = "SELECT * FROM Users"; //Query to grab all the books and data
      ps = conn.prepareStatement(sqlQuery);
      java.sql.ResultSet rs = ps.executeQuery(); //execute the query

      while (rs.next())
      {
	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<table border = '1'>");
	      out.println("<th>User ID</th>");
	      out.println("<th>Full Name</th>");
	      out.println("<th>Username</th>");
	      out.println("<th>Enter New Password</th>");
	      out.println("<th>Address</th>");
	      out.println("<th>Credit Card #</th>");
	      out.println("<th>Admin Rights?</th>");
	      out.println("<tr>");
	      out.println("<td><center>" + rs.getString("user_id") + "</center></td>");
	      out.println("<td> <input type=\"text\" name=\"fullname\" value=\"" + rs.getString("name") + "\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"username\" value=\"" + rs.getString("username") + "\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"password\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"address\" value=\"" + rs.getString("address") + "\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"creditcard\" value=\"" + rs.getString("credit_card") + "\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"adminrights\" value=\"" + rs.getString("admin") + "\"> </td>");
	      out.println("</tr>");
	      out.println("</table>");
	      out.println("<td> <input type=\"hidden\" name=\"user_id\" value=\"" + rs.getString("user_id") + "\"> </td>");
	      out.println("<table>");
	      out.println("<tr>");
	      out.println("<input type = \"submit\" value=\"Update User\">");
	      out.println("</form>");

	      out.println("<form action=\""+sDeleteUser+"\" method=\"POST\">");
	      out.println("<td> <input type=\"hidden\" name=\"user_id\" value=\"" + rs.getString("user_id") + "\"> </td>");
	      out.println("<input type = \"submit\" value=\"Delete User\">");
	      out.println("</tr>");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("</table>");
	      out.println("</form>");
      }

    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>

<%!
  //lets the user logout
  void Logout(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
		int userid = Integer.parseInt(session.getAttribute("UserID").toString());
        String sqlQuery = "SELECT name FROM Users where user_id = ?";
        ps = conn.prepareStatement(sqlQuery);
        ps.setInt(1, userid);
        java.sql.ResultSet rs = ps.executeQuery(); //execute the query

        while (rs.next())
        {
  	      out.println("<form action=\""+sLogout+"\" method=\"POST\">");
  	      out.println("<tr>");
  	      out.println("<td>" + rs.getString("name") + "</td>");
  	      out.println("<td> <input type = \"submit\" value=\"Logout\"> </td>");
  	      out.println("</tr>");
  	      out.println("</form>");
        }
    }
    catch (Exception e) { out.println(e.toString());}
  }
%>

<%!
//Allow the admin to go back to the main page
  void MainPage(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {

  	      out.println("<form action=\""+sMainPage+"\" method=\"POST\">");
  	      out.println("<tr>");
  	      out.println("<td> <input type = \"submit\" value=\"Go back to Main Page\"> </td>");
  	      out.println("</tr>");
  	      out.println("</form>");
  }
%>


<%!
//Add a new user
  void addUser(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    try {
    	  out.println("Create A New User");
	      out.println("<form action=\""+sAddUser+"\" method=\"POST\">");
	      out.println("<table border = '1'>");
	      out.println("<th>Full Name</th>");
	      out.println("<th>Username</th>");
	      out.println("<th>Password</th>");
	      out.println("<th>Address</th>");
	      out.println("<th>Credit Card #</th>");
	      out.println("<th>Admin Rights?</th>");
	      out.println("<tr>");
	      out.println("<td> <input type=\"text\" name=\"fullname\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"username\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"password\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"address\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"creditcard\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"adminrights\" value=\"\"> </td>");
	      out.println("</tr>");
	      out.println("</table>");
	      out.println("<tr><td> <input type = \"submit\" value=\"Add New User\"> </td></tr>");
	      out.println("</form>");
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>
