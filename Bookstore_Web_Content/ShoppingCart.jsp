<!-- -->
<%@ page import="java.sql.PreparedStatement" %>

<%! //this is a declaration tag
static String sFileName = "ShowBooks.jsp";
static final String SubmitOrder = "SubmitOrder.jsp";
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
<title>Shopping Cart</title>
</head>
<body>
<center>
	<table>
		<thead>
			<tr>
				<td style="width: 200px;">Book</td>
        <td> </td>
				<td style="width: 200px;">Price/Book</td>
				<td style="width: 200px;">Quantity</td>
				<td style="width: 200px;">Total Price</td>
			</tr>
			</thead>
	<% loggedOnStatus(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% insertQuery(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% ShowShoppingCart(request, response, session, out, sLoginErr, sForm, conn, stat); %>
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
//Verify that the correct user is logged in
  void loggedOnStatus(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
		if(session.getAttribute("UserID") == null)
		{
			session.setAttribute("page", response.getHeader("referer"));
			session.setAttribute("login_toggle", "not_logged");
			response.sendRedirect("Login.jsp");
		}
	}
%>


<%!
	//function to insert the orders
	void insertQuery(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
    	double order_amount = Integer.parseInt(request.getParameter("quantity"));
        String isbn = request.getParameter("ISBN");
        int userid = Integer.parseInt(session.getAttribute("UserID").toString());
        String sqlQuery = "INSERT INTO Orders(ISBN_number, user_id, quantity) VALUES(?,?,?);"; //Query to grab all the books and data
        ps = conn.prepareStatement(sqlQuery);
        ps.setString(1, isbn);
        ps.setInt(2, userid);
        ps.setDouble(3, order_amount);
        int rs = ps.executeUpdate(); //execute the query

      }
      catch (Exception e) { out.println(e.toString());}
    }
%>

<%!
	//Display everything in the user's shopping cart
  void ShowShoppingCart(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
	  int userid = Integer.parseInt(session.getAttribute("UserID").toString());
      String sqlQuery = "SELECT DISTINCT Books.ISBN_number, image, price, SUM(Orders.quantity) AS quantity FROM Orders, Books WHERE Orders.ISBN_number = Books.ISBN_number AND user_id = ? GROUP BY Books.ISBN_number, image, price"; //Query to grab all the books and data
      ps = conn.prepareStatement(sqlQuery);
      ps.setInt(1, userid);
      java.sql.ResultSet rs = ps.executeQuery(); //execute the query
   	  float grandTotal = 0;
      //Loops through and gets
      while (rs.next())
      {
    	  float booktotal_price = Float.parseFloat(rs.getString("price")) * Float.parseFloat(rs.getString("quantity"));
	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<tr>");
	      out.println("<td><img src=" + rs.getString("image") + " style=\"height: 318px; width: 197px; \"></td>");
          out.println("<td> </td>");
	      out.println("<td>$" + rs.getString("price") +" </td>");
	      out.println("<td>" + rs.getString("quantity") +" </td>");
	      out.println("<td>$" + String.format("%.2f", booktotal_price) + " </td>");
	      out.println("<td> <input type=\"hidden\" name=\"booktotal_price\" value=\"" + String.format("%.2f", booktotal_price) + "\"> </td>");
	      out.println("</tr>");
	      out.println("</form>");
	      grandTotal += booktotal_price;
	      booktotal_price = 0;
      }
      //go back and do more shopping
      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
      out.println("<td> <input type = \"submit\" value=\"Continue Shopping\"> </td>");
      out.println("</form>");
      //submit final order
      out.println("<form action=\""+SubmitOrder+"\" method=\"POST\">");
      out.println("<td> <input type = \"submit\" value=\"Submit Order\"> </td>");
      out.println("</form>");
      out.println("<td> </td>");
      out.println("<td> </td>");
      out.println("<td> Grand Total: $" + String.format("%.2f", grandTotal) + "</td>");
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
    catch (Exception e) { out.println(e.toString()); }
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
