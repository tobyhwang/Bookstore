<!-- -->
<%@ page import="java.sql.PreparedStatement" %>
<%@ include file="hashPassword.jsp" %>

<%! //this is a declaration tag
static final String sFileName = "UserManagement.jsp";
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
<% verifyAdmin(request, response, session, out, sLoginErr, sForm, conn, stat); %>
<% checkUsername(request, response, session, out, sLoginErr, sForm, conn, stat); %>


<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>

<%!
//Verify that it is admin user
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
	//add new user information
  void checkUsername(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;

	try{
		String sqlQuery = "SELECT username FROM Users;";
		String username = request.getParameter("username");
		ps = conn.prepareStatement(sqlQuery);
	    java.sql.ResultSet rs = ps.executeQuery(); //execute the query


	    while(rs.next())
	    {
	    	if(rs.getString("username").equals(username))
	    	{
	    		response.sendRedirect("ModifyUsernameError.jsp");
	    		return;
	    	}
	    }
	    addUser(request, response, session, out, sLoginErr, sForm, conn, stat);
	}
    catch (Exception e) { out.println(e.toString()); }
}
%>

<%!
//Add the new user
  void addUser(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
    PreparedStatement ps = null;
	try {
    	if(request.getParameter("username") != "" && request.getParameter("password") != "" && request.getParameter("fullname") != ""
    			&& request.getParameter("address") != "" && request.getParameter("creditcard") != ""
    			&& request.getParameter("adminrights") != "")
    	{
    		String password_raw = request.getParameter("password");
    		String numRegex = ".*[0-9].*";
    		String alphaRegex = ".*[a-zA-Z].*";
    		if(password_raw.matches(numRegex) && password_raw.matches(alphaRegex) && password_raw.length() > 7)
    		{
		    	String username = request.getParameter("username");
		    	String password = MD5(request.getParameter("password"));
		    	String fullname = request.getParameter("fullname");
		    	String address = request.getParameter("address");
		    	String creditcard = request.getParameter("creditcard");
		    	String adminrights = request.getParameter("adminrights");
		        String sqlQuery = "INSERT INTO Users (username, password, name, address, credit_card, admin) VALUES(?,?,?,?,?,?);";
				ps = conn.prepareStatement(sqlQuery);
		        ps.setString(1, username);
				ps.setString(2, password);
				ps.setString(3, fullname);
				ps.setString(4, address);
				ps.setString(5, creditcard);
				ps.setString(6, adminrights);
			    int rs = ps.executeUpdate(); //execute the query
    		}
    		else{
    			response.sendRedirect("UserManageAddError.jsp");
    		}

    	}
        response.sendRedirect(sFileName);

    }
    catch (Exception e) { out.println(e.toString()); }
  }
%>