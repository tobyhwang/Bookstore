<!-- -->
<%@ page import="java.sql.PreparedStatement" %>
<%@ include file="hashPassword.jsp" %>

<%! //this is a declaration tag
static final String sFileName = "Login.jsp";
static final String addUser = "AddUser.jsp";

String sLoginErr = "";
static final String DBDriver  ="com.mysql.jdbc.Driver";
static final String strConn   ="jdbc:mysql://localhost/Bookstore";
static final String DBusername="root";
static final String DBpassword="password";

%>

<%

boolean bDebug = false;
String sForm = request.getParameter("FormName");
if(sForm==null)
  sForm="";


//Create connection
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
if(sForm.equals("Login")) {
  sLoginErr = Login(request, response, session, out, sForm, conn, stat);
  if ( "sendRedirect".equals(sLoginErr)) return;
}

%>
<html>
<head>
<title>Book Store</title>
</head>
<body>
<center>
 <table>
  <tr>
   <td valign="top">
<% checkUsername(request, response, session, out, sLoginErr, sForm, conn, stat); %>
<% ShowLoginTable(request, response, session, out, sLoginErr, sForm, conn, stat); %>
   </td>
  </tr>
 </table>


<%
if ( stat != null ) stat.close();
if ( conn != null ) conn.close();
%>

<%!
	//check the validity of the username
  void checkUsername(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;

	try{
		if(request.getParameter("add_name") != null && request.getParameter("add_username") != null && request.getParameter("add_password") != null && request.getParameter("Address") != null && request.getParameter("CreditCard") != null)
		{
			if(request.getParameter("add_name") == "" || request.getParameter("add_username") == "" || request.getParameter("add_password") == "" || request.getParameter("Address") == "" || request.getParameter("CreditCard") == "")
			{
				response.sendRedirect("InfoError.jsp");
				return;
			}
			else{
				String sqlQuery = "SELECT username FROM Users;";
				String addusername = request.getParameter("add_username");
				ps = conn.prepareStatement(sqlQuery);
			    java.sql.ResultSet rs = ps.executeQuery(); //execute the query


			    while(rs.next())
			    {
			    	if(rs.getString("username").equals(addusername))
			    	{
			    		response.sendRedirect("AddUserError.jsp");
			    		return;
			    	}
			    }
		    	checkPassword(request, response, session, out, sLoginErr, sForm, conn, stat);
			}
		}
	}
    catch (Exception e) { out.println(e.toString()); }
}
%>

<%!
	//Check the user password
  void checkPassword(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	String password = request.getParameter("add_password");
	String numRegex = ".*[0-9].*";
	String alphaRegex = ".*[a-zA-Z].*";
	if(request.getParameter("add_name") == "" || request.getParameter("add_username") == "" || request.getParameter("add_password") == "" || request.getParameter("Address") == "" || request.getParameter("CreditCard") == "")
	{
		response.sendRedirect("InfoError.jsp");
	}
	if(password.matches(numRegex) && password.matches(alphaRegex) && password.length() > 7)
	{
		addQuery(request, response, session, out, sLoginErr, sForm, conn, stat);
	}
	else{
		response.sendRedirect("PasswordError.jsp");
	}
}
%>

<%!
	//add a new user
  void addQuery(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	PreparedStatement ps = null;
	try{
		String username = request.getParameter("add_username");
		String password = MD5(request.getParameter("add_password"));
		String name = request.getParameter("add_name");
		String address = request.getParameter("Address");
		String creditcard = request.getParameter("CreditCard");
		String sqlQuery = "INSERT INTO Users(username, password, name, address, credit_card) VALUES(?,?,?,?,?)";
		ps = conn.prepareStatement(sqlQuery);
		ps.setString(1, username);
		ps.setString(2, password);
		ps.setString(3, name);
		ps.setString(4, address);
		ps.setString(5, creditcard);
	    int rs = ps.executeUpdate(); //execute the query

	}
    catch (Exception e) { out.println(e.toString()); }
  }
%>


<%!
  //Verify the user's login
  String Login(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	String sLoginErr = "";
    PreparedStatement ps = null;
    try {
      String sPassword = MD5(request.getParameter("Password"));
      String sLogin = request.getParameter("Login");
      String sqlQuery = "select user_id, password from Users where username = ? and password= ?";
      ps = conn.prepareStatement(sqlQuery);
      ps.setString(1, sLogin);
      ps.setString(2, sPassword);
      java.sql.ResultSet rs = ps.executeQuery();
      if ( rs.next() ) {
            session.setAttribute("UserID", rs.getString(1));
            try {
                 if ( stat != null ) stat.close();
                if ( conn != null ) conn.close();
            }
            catch ( java.sql.SQLException ignore ) {}

           	if(session.getAttribute("login_toggle") == null)
           	{
           		response.sendRedirect("ShowBooks.jsp");
           	}
           	else{
           		session.setAttribute("login_toggle", null);
           		response.sendRedirect(session.getAttribute("page").toString());
           	}

            return "";
      }
      else
        sLoginErr = "Login or Password is incorrect.";
      rs.close();
    }
    catch (Exception e) { out.println(e.toString());
    }
    return (sLoginErr);
  }

 //Show the login table to the user
  void ShowLoginTable(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, javax.servlet.http.HttpSession session, javax.servlet.jsp.JspWriter out, String sLoginErr, String sForm, java.sql.Connection conn, java.sql.Statement stat) throws java.io.IOException {
	session.setAttribute("page", request.getHeader("referer"));
	try {
      String sSQL="";
      String transitParams = "";
      String sQueryString = request.getParameter("querystring");
      String sPage = request.getParameter("ret_page");
      String signUp = request.getParameter("");

      out.println("    <table style=\"\" border=1>");
      out.println("     <tr>\n      <td style=\"background-color: #336699; text-align: Center; border-style: outset; border-width: 1\" colspan=\"2\"><font style=\"font-size: 12pt; color: #FFFFFF; font-weight: bold\">Enter login and password</font></td>\n     </tr>");

      if ( sLoginErr.compareTo("") != 0 ) {
        out.println("     <tr>\n      <td colspan=\"2\" style=\"background-color: #FFFFFF; border-width: 1\"><font style=\"font-size: 10pt; color: #000000\">"+sLoginErr+"</font></td>\n     </tr>");
      }
      sLoginErr="";
      out.println("     <form action=\""+sFileName+"\" method=\"POST\">");
      out.println("     <input type=\"hidden\" name=\"FormName\" value=\"Login\">");
      if ( session.getAttribute("UserID") == null || ((String) session.getAttribute("UserID")).compareTo("") == 0 ) {
        // User did not login
        out.println("     <tr>\n      <td style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 10pt; color: #000000\">Login</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"text\" name=\"Login\" maxlength=\"50\" value=\""+request.getParameter("Login")+"\"></td>\n     </tr>");
        out.println("     <tr>\n      <td style=\"background-color: #FFEAC5; border-style: inset; border-width: 0\"><font style=\"font-size: 10pt; color: #000000\">Password</font></td><td style=\"background-color: #FFFFFF; border-width: 1\"><input type=\"password\" name=\"Password\" maxlength=\"50\"></td>\n     </tr>");
        out.print("     <tr>\n      <td colspan=\"2\"><input type=\"submit\" value=\"Login\"");
        out.println("<input type=\"hidden\" name=\"ret_page\" value=\""+sPage+"\"><input type=\"hidden\" name=\"querystring\" value=\""+sQueryString+"\">    </form><form action=\""+addUser+"\" method=\"POST\"> <input type=\"submit\" value=\"Sign Up\"></form>");
      }
      else {
        // User logged in
        //String getUserID(java.sql.Statement stat, String table, String fName, String where)
        //String sUserID = dLookUp( stat, "members", "member_login", "member_id =" + session.getAttribute("UserID"));
        java.sql.Connection conn1 = null;
        java.sql.Statement stat1 = null;
         String userID ="";
        try {
          conn1 = java.sql.DriverManager.getConnection(strConn , DBusername, DBpassword);
          stat1 = conn1.createStatement();

          PreparedStatement ps = null;
          int UserID = Integer.parseInt(session.getAttribute("UserID").toString());
          String sqlQ = "SELECT user_id FROM Users WHERE user_id = ?";
          ps.setInt(1, UserID);
          ps = conn.prepareStatement(sqlQ);
          java.sql.ResultSet rsLookUp = ps.executeQuery();


          if (! rsLookUp.next()) {
            rsLookUp.close();
            stat1.close();
            conn1.close();
        }
          userID = rsLookUp.getString(1);
          rsLookUp.close();
          stat1.close();
          conn1.close();

        }
        catch (Exception e) {   }

        out.print("<input type=\"hidden\" name=\"ret_page\" value=\""+sPage+"\"><input type=\"hidden\" name=\"querystring\" value=\""+sQueryString+"\">");
        out.println("</td>\n     </form>\n     </tr>");
        out.println("     <form action=\""+"Logout.jsp"+"\" method=\"POST\">");
        out.print("     <tr><td style=\"background-color: #FFFFFF; border-width: 1\"><font style=\"font-size: 10pt; color: #000000\">"+userID+"&nbsp;&nbsp;"+"</font><input type=\"hidden\" name=\"FormAction\" value=\"logout\"/><input type=\"submit\" value=\"Logout\"/>");
        out.println("</td>\n     </form>\n     </tr>");
      }
      out.println("    </table>");


    }
    catch (Exception e) { }//out.println(e.toString());}
  }
%>
</body>
</html>



