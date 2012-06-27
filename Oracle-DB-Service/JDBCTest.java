
	import java.sql.Connection;  
	import java.sql.DatabaseMetaData;  
	import java.sql.ResultSet;  
	import java.sql.SQLException;  
	 
	import java.sql.Statement;  
	 
	import java.util.Date;  
	 
	import oracle.jdbc.pool.OracleDataSource;  
	 
	public class JDBCTest {  
	  
	 public static void main(String [] args) throws Exception {
	 	
	 	OracleDataSource ods = null;  
	    String userId = "SYSTEM";  
	    String password = "examplepassword";  
	    String url =  "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)" +  
	                  "(HOST=10.140.17.165)(PORT=1521))" +  
	                  "(CONNECT_DATA=(SERVICE_NAME=exampledb.us.oracle.com)))";  
	    ods = new OracleDataSource();  
	    ods.setUser(userId);  
	    ods.setPassword(password);  
	    ods.setURL(url);    
	    
	    Connection conn = ods.getConnection();
	    DatabaseMetaData meta = conn.getMetaData (); 
	    System.out.println(meta.getDatabaseProductName());
	    
	    String sql = "create table emp1 (fname varchar2(50), lname varchar2(50), emailid varchar2(50), role varchar2(50), project varchar2(50), mobile varchar2(50))";     
	    Statement stmt = conn.createStatement();  
	    stmt.executeQuery(sql);
	    
	    sql = "insert into emp1 values('TEST1','TEST2','TEST3','TEST4','TEST','TEST')";         
	    stmt.executeQuery(sql);
	      
	    sql = "select * from emp1"; 
	    ResultSet rset = stmt.executeQuery(sql);  
	    while (rset.next())  
	    {  
	       System.out.println  
	       ("Connection # 1 : instance[" + rset.getString(1) + "], host[" +   
	        rset.getString(2) + "], service[" + rset.getString(3) + "]");  
	    }
	    
	    stmt.close();
	 }  
	} 

