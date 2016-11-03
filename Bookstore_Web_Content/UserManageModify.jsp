<!-- -->
<%@ page import="java.sql.PreparedStatement" %>
<%@ include file="hashPassword.jsp" %>

<%! //this is a declaration tag
static final String sFileName = "UserManagement.jsp";
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
<title>User Management</title>
</head>
<body>
<center><font size ="12">Update User Information</font></center>

	<tr><td><br/></td></tr>
	<% verifyAdmin(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<% updateUsers(request, response, session, out, sLoginErr, sForm, conn, stat); %>
	<tr><td><br/></td></tr>
	<tr><td><br/></td></tr>

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
//Modify credentials about the user and update the user
  void updateUsers(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
		String numRegex = ".*[0-9].*";
		String alphaRegex = ".*[a-zA-Z].*";
		if((request.getParameter("password").matches(numRegex) && request.getParameter("password").matches(alphaRegex) && request.getParameter("password").length() > 7) || request.getParameter("password").equals(""))
		{
	    	String fullname = request.getParameter("fullname");
	    	String username = request.getParameter("username");
	    	String password = MD5(request.getParameter("password"));
	    	String address = request.getParameter("address");
	    	String creditcard = request.getParameter("creditcard");
	    	String adminrights = request.getParameter("adminrights");
	    	String user_id = request.getParameter("user_id");
	    	if(!(request.getParameter("password").equals("")))
	    	{
		        String sqlQuery = "UPDATE Users SET name= ?,username = ?, password= ?, address= ? , credit_card=?, admin= ? WHERE user_id = ?;";
				ps = conn.prepareStatement(sqlQuery);
		        ps.setString(1, fullname);
				ps.setString(2, username);
				ps.setString(3, password);
				ps.setString(4, address);
				ps.setString(5, creditcard);
				ps.setString(6, adminrights);
				ps.setString(7, user_id);
	    	}
	    	else{
		        String sqlQuery = "UPDATE Users SET name= ?,username = ?, address= ? , credit_card=?, admin= ? WHERE user_id = ?;";
				ps = conn.prepareStatement(sqlQuery);
		        ps.setString(1, fullname);
				ps.setString(2, username);
				ps.setString(3, address);
				ps.setString(4, creditcard);
				ps.setString(5, adminrights);
				ps.setString(6, user_id);
	    	}
	      	int rs = ps.executeUpdate(); //execute the query
		}
		else{
			response.sendRedirect("UserManageAddError.jsp");
		}

	      out.println("<form action=\""+sFileName+"\" method=\"POST\">");
	      out.println("<font size = \"5\"> User Updated Successfully! </font>");
	      out.println("<tr>");
	      out.println("<td> <input type = \"submit\" value=\"Continue\"> </td>");
	      out.println("</tr>");
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