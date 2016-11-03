<!-- -->
<%@ page import="java.sql.PreparedStatement" %>

<%! //this is a declaration tag
static final String sFileName = "UserManageModify.jsp";
static final String sDeleteUser = "UserDelete.jsp";
static final String sAddUser = "UserManageAdd.jsp";
static final String sLogout = "Logout.jsp";
static final String sMainPage = "ShowBooks.jsp";
static final String sStat = "Statistics.jsp";
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
String home_folder = System.getProperty("user.dir");
System.setProperty("org.owasp.esapi.resources", home_folder);
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
	<% DisplayOrderHistory(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% DateNumOrdersSales(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% DateRankBooks(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% DateBookTitle(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% DateByAuthor(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
	<% BackToStats(request, response, session, out, sLoginErr, sForm, conn, stat); %>
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
//Verify that it is an admin
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
//Display the order history to the user
  void DisplayOrderHistory(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;

	try {
    	if(request.getParameter("username") != "" && request.getParameter("date") != ""){
    	  String username = request.getParameter("username");
    	  String date = request.getParameter("date");
    	  String sqlQuery = "SELECT * FROM Order_History NATURAL JOIN Users WHERE username=? AND date > ?";
    	  ps = conn.prepareStatement(sqlQuery);
    	  ps.setString(1, username);
    	  ps.setString(2, date);
	      java.sql.ResultSet rs = ps.executeQuery();

	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> From Order History </font>");
	      out.println("<table>");
	      out.println("<th>Order History ID</th>");
	      out.println("<th>User ID</th>");
	      out.println("<th>Date</th>");
	      out.println("<th>Time</th>");
	      out.println("<th>Quantity</th>");
	      out.println("<th>Total Price</th>");
	      out.println("<th>Title</th>");
    	  while(rs.next())
    	  {
    	      out.println("<tr>");
    	      out.println("<td> <input type=\"text\" name=\"historyID\" value=\"" + rs.getString("history_id") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"userID\" value=\"" + rs.getString("user_id") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"date\" value=\"" + rs.getString("date") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"time\" value=\"" + rs.getString("time") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"quantity\" value=\"" + rs.getString("quantity") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"totalprice\" value=\"" + rs.getString("total_price") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"title\" value=\"" + rs.getString("title") + "\" disabled> </td>");
    	      out.println("</tr>");
    	  }
    	  out.println("</table>");
	      out.println("</form>");

	      //Display the current order of items in the cart
	      DisplayCartData(request, response, session, out, sLoginErr, sForm, conn, stat);
    	}
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>

<%!
//Display what is currently in the user's shopping cart
  void DisplayCartData(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;
	try {
    	  String username = request.getParameter("username");
    	  String sqlQueryCurr = "SELECT * FROM (Orders NATURAL JOIN Users) NATURAL JOIN Books WHERE username= ? ";
    	  ps = conn.prepareStatement(sqlQueryCurr);
    	  ps.setString(1, username);
		  java.sql.ResultSet rsCurr = ps.executeQuery();

	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> From Shopping Cart (current orders) </font>");
	      out.println("<table>");
	      out.println("<th>Order ID</th>");
	      out.println("<th>User ID</th>");
	      out.println("<th>Quantity</th>");
	      out.println("<th>Price Per Book</th>");
	      out.println("<th>Title</th>");

    	  while(rsCurr.next())
    	  {
    	      out.println("<tr>");
    	      out.println("<td> <input type=\"text\" name=\"orderID\" value=\"" + rsCurr.getString("order_id") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"userID\" value=\"" + rsCurr.getString("user_id") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"quantity\" value=\"" + rsCurr.getString("quantity") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"price\" value=\"" + rsCurr.getString("price") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"title\" value=\"" + rsCurr.getString("title") + "\" disabled> </td>");
    	      out.println("</tr>");
    	  }
    	  out.println("</table>");
	      out.println("</form>");
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>


<%!
//Order the books by the totals sales
  void DateNumOrdersSales(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps= null;
	try {
    	if(request.getParameter("startdate") != "" && request.getParameter("enddate") != ""){
    	  String startdate = request.getParameter("startdate");
    	  String enddate = request.getParameter("enddate");
    	  String sqlQuery = "SELECT SUM(total_price) AS Total, COUNT(*) AS Order_Num  FROM Order_History WHERE date BETWEEN ? AND ?";
    	  ps = conn.prepareStatement(sqlQuery);
    	  ps.setString(1, startdate);
    	  ps.setString(2, enddate);
	      java.sql.ResultSet rs = ps.executeQuery();

	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> Statistics about Orders </font>");
	      out.println("<table>");
	      out.println("<th>Number of Orders</th>");
	      out.println("<th>Total Sales</th>");

    	  while(rs.next())
    	  {
    	      out.println("<tr>");
    	      out.println("<td> <input type=\"text\" name=\"userID\" value=\"" + rs.getString("Order_Num") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"historyID\" value=\"$" + String.format("%.2f", Double.parseDouble(rs.getString("Total"))) + "\" disabled> </td>");
    	      out.println("</tr>");
    	  }
    	  out.println("</table>");
	      out.println("</form>");

    	}
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>

<%!
//Rank the books by Date for top sales
  void DateRankBooks(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;
	try {
    	if(request.getParameter("startdate") !="" && request.getParameter("enddate") != ""){
        String startdate = request.getParameter("startdate");
        String enddate = request.getParameter("enddate");
    	  String sqlQuery = "SELECT title, sum(total_price) AS sales FROM order_history WHERE date BETWEEN ? AND ? GROUP BY title ORDER BY sales DESC;";
    	  ps = conn.prepareStatement(sqlQuery);
    	  ps.setString(1, startdate);
    	  ps.setString(2, enddate);

	      java.sql.ResultSet rs = ps.executeQuery();

	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> Book Ranking by Top Sales </font>");
	      out.println("<table>");
	      out.println("<th>Book Title</th>");
	      out.println("<th>Total Sales</th>");

    	  while(rs.next())
    	  {
    	      out.println("<tr>");
    	      out.println("<td> <input type=\"text\" name=\"title\" value=\"" + rs.getString("title") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"sales\" value=\"$" + String.format("%.2f", Double.parseDouble(rs.getString("sales"))) + "\" disabled> </td>");
    	      out.println("</tr>");
    	  }
    	  out.println("</table>");
	      out.println("</form>");
    	  stat = conn.createStatement();

    	}
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>

<%!
//List the total sales by Title
  void DateBookTitle(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;
	try {
    	if(request.getParameter("bookstartdate") !="" && request.getParameter("endstartdate") != "" && request.getParameter("Title") != ""){
    	  String startdate = request.getParameter("bookstartdate");
    	  String enddate = request.getParameter("bookenddate");
    	  String title = request.getParameter("Title");
    	  String sqlQuery = "SELECT title, sum(total_price) as sales FROM order_history WHERE date BETWEEN ? AND  ? AND title = ? GROUP BY title";
	      ps = conn.prepareStatement(sqlQuery);
	      ps.setString(1, startdate);
	      ps.setString(2, enddate);
	      ps.setString(3, title);
    	  java.sql.ResultSet rs = ps.executeQuery();

	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> Total Sales by Title </font>");
	      out.println("<table>");
	      out.println("<th>Book Title</th>");
	      out.println("<th>Total Sales</th>");

    	  while(rs.next())
    	  {
    	      out.println("<tr>");
    	      out.println("<td> <input type=\"text\" name=\"title\" value=\"" + rs.getString("title") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"sales\" value=\"$" + String.format("%.2f", Double.parseDouble(rs.getString("sales"))) + "\" disabled> </td>");
    	      out.println("</tr>");
    	  }
    	  out.println("</table>");
	      out.println("</form>");
    	  stat = conn.createStatement();

    	}
    }
    catch (Exception e) { out.println(e.toString());}
  }
%>

<%!
//List the total sales by author
  void DateByAuthor(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
    	if(request.getParameter("authorstartdate") !="" && request.getParameter("authorenddate") != "" && request.getParameter("Author") != ""){
    	  String authorstartdate= request.getParameter("authorstartdate");
    	  String authorenddate = request.getParameter("authorenddate");
    	  String author = request.getParameter("Author").replaceAll("'", "''");
    	  String sqlQuery = "SELECT Authors.name, sum(Order_History.total_price) as sales FROM Order_History NATURAL JOIN Books NATURAL JOIN ISBN NATURAL JOIN Authors WHERE date BETWEEN ? AND ? AND Authors.name = ? GROUP BY Authors.name;";
	      ps = conn.prepareStatement(sqlQuery);
	      ps.setString(1, authorstartdate);
	      ps.setString(2, authorenddate);
	      ps.setString(3, author);
    	  java.sql.ResultSet rs = ps.executeQuery();
	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> Total Sales by Author </font>");
	      out.println("<table>");
	      out.println("<th>Authors Name</th>");
	      out.println("<th>Total Sales</th>");

    	  while(rs.next())
    	  {
    	      out.println("<tr>");
    	      out.println("<td> <input type=\"text\" name=\"name\" value=\"" + rs.getString("Authors.name") + "\" disabled> </td>");
    	      out.println("<td> <input type=\"text\" name=\"sales\" value=\"$" + String.format("%.2f", Double.parseDouble(rs.getString("sales"))) + "\" disabled> </td>");
    	      out.println("</tr>");
    	  }
    	  out.println("</table>");
	      out.println("</form>");
    	  stat = conn.createStatement();

    	}
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>

<%!
  void BackToStats(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {

  	      out.println("<form action=\""+sStat +"\" method=\"POST\">");
  	      out.println("<tr>");
  	      out.println("<td> <input type = \"submit\" value=\"Re-enter Statistics\"> </td>");
  	      out.println("</tr>");
  	      out.println("</form>");
  }
%>

<%!
//Allow the user to go back to the main page
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
    catch (Exception e) { out.println(e.toString()); }
  }
%>
