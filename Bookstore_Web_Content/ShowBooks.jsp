<!-- -->
<%@ page import="java.sql.PreparedStatement" %>

<%! //this is a declaration tag


static final String sFileName = "ShoppingCart.jsp";
static final String sLogout = "Logout.jsp";
static final String refreshPage = "ShowBooks.jsp";
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
out.println(sForm);
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
<title>Show Books</title>
</head>
<body>
<center>
	<table>
		<thead>
			<tr>
				<td style="width: 200px;">Book Title</td>
				<td style="width: 200px;">Author</td>
				<td style="width: 200px;">Description</td>
				<td style="width: 200px;">Price</td>
				<td style="width: 200px;">Quantity</td>
			</tr>
			</thead>
	<% ShowBookTable(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
	<% GoToAdminPage(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>
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
//Show all the avilable books to the user
  void ShowBookTable(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
    try {
      String sqlQuery = "SELECT Books.ISBN_number, description, image, price, GROUP_CONCAT(name SEPARATOR ' & ') AS name FROM Books, ISBN, Authors WHERE Books.ISBN_number = ISBN.ISBN_number AND ISBN.id = Authors.id GROUP BY Books.ISBN_number;"; //Query to grab all the books and data
      ps = conn.prepareStatement(sqlQuery);
      java.sql.ResultSet rs = ps.executeQuery(); //execute the query

      while (rs.next())
      {
	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<tr>");
	      out.println("<td><img src='" + rs.getString("image") + "' style=\"height: 318px; width: 197px; \"></td>");
	      out.println("<td>" + rs.getString("name") + "</td>");
	      out.println("<td>" + rs.getString("description") +" </td>");
	      out.println("<td> $" + rs.getString("price") +" </td>");
	      out.println("<td> <input type=\"text\" name=\"quantity\" value=\"\"> </td>");
	      out.println("<input type=\"hidden\" name=\"ISBN\" value=" + rs.getString(1) + ">");
	      out.println("<td> <input type = \"submit\" value=\"Add to Cart\"> </td>");
	      out.println("</tr>");
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
	if(session.getAttribute("UserID") != null){
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
  }
%>

<%!
  //allows the user to go the User management page
  void GoToAdminPage(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	if(session.getAttribute("UserID") != null){
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
  }
%>





