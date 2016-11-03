<!-- -->
<%@ page import="java.sql.PreparedStatement" %>

<%! //this is a declaration tag
static final String sFileName = "DisplayStats.jsp";
static final String sLogout = "Logout.jsp";
static final String sMainPage = "ShowBooks.jsp";
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
<center><font size="12">Statistics</font>
</center>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
	<% verifyAdmin(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% showOrderStats(request, response, session, out, sLoginErr, sForm, conn, stat); %>
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
//Show the order statistics
  void showOrderStats(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    try {
	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("Current Order and Order History for a User");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("<table border = '1'>");
	      out.println("<th>Username</th>");
	      out.println("<th>Date (YYYY-MM-DD)</th>");
	      out.println("<tr>");
	      out.println("<td> <input type=\"text\" name=\"username\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"date\" value=\"\"> </td>");
	      out.println("</tr>");
	      out.println("</table>");
	      out.println("<table>");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("</table>");

	      out.println("# of Orders, Total Sales in Date Range, Book Ranking by Sales");
	      out.println("<table border = '1'>");
	      out.println("<th>Start Date (YYYY-MM-DD)</th>");
	      out.println("<th>End Date (YYYY-MM-DD)</th>");
	      out.println("<tr>");
	      out.println("<td> <input type=\"text\" name=\"startdate\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"enddate\" value=\"\"> </td>");
	      out.println("</tr>");
	      out.println("</table>");
	      out.println("<table>");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("</table>");


	      out.println("Total Sales by Book Title in Date Range");
	      out.println("<table border = '1'>");
	      out.println("<th>Book Title</th>");
	      out.println("<th>Start Date (YYYY-MM-DD)</th>");
	      out.println("<th>End Date (YYYY-MM-DD)</th>");
	      out.println("<tr>");
	      out.println("<td> <input type=\"text\" name=\"Title\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"bookstartdate\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"bookenddate\" value=\"\"> </td>");
	      out.println("</tr>");
	      out.println("</table>");
	      out.println("<table>");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("</table>");

	      out.println("Total Sales by Author in Date Range");
	      out.println("<table border = '1'>");
	      out.println("<th>Author</th>");
	      out.println("<th>Start Date (YYYY-MM-DD)</th>");
	      out.println("<th>End Date (YYYY-MM-DD)</th>");
	      out.println("<tr>");
	      out.println("<td> <input type=\"text\" name=\"Author\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"authorstartdate\" value=\"\"> </td>");
	      out.println("<td> <input type=\"text\" name=\"authorenddate\" value=\"\"> </td>");
	      out.println("</tr>");
	      out.println("</table>");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("<tr><td><br/></td></tr>");
	      out.println("<tr>");
	      out.println("<input type = \"submit\" value=\"Get Statistics\">");
	      out.println("</tr>");
	      out.println("</form>");

    }
    catch (Exception e) { out.println(e.toString());
    }
  }
%>

<%!
//Alllows the user to go back to the main page
  void MainPage(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {

  	      out.println("<form action=\""+sMainPage +"\" method=\"POST\">");
  	      out.println("<tr>");
  	      out.println("<td> <input type = \"submit\" value=\"Go back to Main Page\"> </td>");
  	      out.println("</tr>");
  	      out.println("</form>");
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






