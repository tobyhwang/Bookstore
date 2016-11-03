<!-- -->
<%@ page import="java.sql.PreparedStatement" %>

<%@page import="java.util.ArrayList" %>
<%! //this is a declaration tag
static final String sFileName = "ShowBooks.jsp";
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
<title>Submitted Order</title>
</head>
<body>
Your order is complete.  Thank you for shopping!
<% insertOrderHistory(request, response, session, out, sLoginErr, sForm, conn, stat); %>
<% deleteOrderTable(request, response, session, out, sLoginErr, sForm, conn, stat); %>
<% createAnotherOrder(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
	<table>
	<% GoToAdminPage(request, response, session, out, sLoginErr, sForm, conn, stat); %>
		<table border = "1">
	<% Logout(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	</table>
	</table>
</body>
</html>

<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>

<%!   
	//Insert the user's orders into their own order_history
	void insertOrderHistory(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
    PreparedStatement ps2 = null;
	try {        
		int userid = Integer.parseInt(session.getAttribute("UserID").toString());
    	ArrayList <String> bookOrders = new ArrayList<String>();
    	String Query = "SELECT quantity, price, title FROM Orders NATURAL JOIN Books WHERE user_id = ?;";
    	ps = conn.prepareStatement(Query);
    	ps.setInt(1, userid);
    	java.sql.ResultSet rs = ps.executeQuery(); //execute the query
    	while(rs.next())
    	{
    		double total_price = Double.parseDouble(rs.getString("price")) * Double.parseDouble(rs.getString("quantity"));
    		String quantity = rs.getString("quantity");
    		String final_price = String.format("%.2f", total_price);
    		String title = rs.getString("title").replaceAll("'", "''"); 
    		
	        String sqlQuery = "INSERT INTO Order_History(user_id, date, time, quantity, total_price, title) VALUES(?, CURDATE(), CURTIME(), ?, ?, ? );";
	        ps2 = conn.prepareStatement(sqlQuery);
	        ps2.setInt(1, userid);
	        ps2.setString(2, quantity);
	        ps2.setString(3, final_price);
	        ps2.setString(4, title);
	        ps2.addBatch();
    	}
		int [] rs1 = ps2.executeBatch();
    }
      catch (Exception e) { out.println(e.toString()); System.out.println("Check here"); }
    }
%>

<%! //Delete all the entries from the user orders in their shopping cart  
	void deleteOrderTable(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {        
		int userid = Integer.parseInt(session.getAttribute("UserID").toString());
        String sqlQuery = "DELETE FROM Orders WHERE user_id = ?"; 
        ps = conn.prepareStatement(sqlQuery);
        ps.setInt(1, userid);
        int rs = ps.executeUpdate(); //execute the query
      }
      catch (Exception e) { out.println(e.toString()); }
    }
%>

<%! //All for the user to go back and create a new order
	void createAnotherOrder(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    try {        
    	out.println("<form action=\""+sFileName+"\" method=\"POST\">");
        out.println("<td> <input type = \"submit\" value=\"Create New Book Order\"> </td>");
        out.println("</form>");
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
  //lets the user logout
  void GoToAdminPage(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {  
		int userid = Integer.parseInt(session.getAttribute("UserID").toString());
        String sqlQuery = "SELECT admin FROM Users where user_id = ?;";
        ps = conn.prepareStatement(sqlQuery);
        ps.setInt(1, userid);
        java.sql.ResultSet rs = ps.executeQuery(); //execute the query
        
        while (rs.next())
        {
          if(rs.getString("admin").equals("yes"))
          {
          	  out.println("<tr>");
          	  out.println("<td>" + "Admin Options" + "</td>");
          	  out.println("</tr>");
	  	      out.println("<form action=\""+"UserManagement.jsp"+"\" method=\"POST\">");
	  	      out.println("<tr>");
	  	      out.println("<td> <input type = \"submit\" value=\"User Management\"> </td>");
	  	      out.println("</form>");
	  	      out.println("<form action=\""+"Statistics.jsp"+"\" method=\"POST\">");
	  	      out.println("<td> <input type = \"submit\" value=\"Statistics\"> </td>");
	  	      out.println("</tr>");
	  	      out.println("</form>");
  	      }
        }
    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>
