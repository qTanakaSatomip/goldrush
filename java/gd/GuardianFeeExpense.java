package gd;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.record.*;
import org.apache.poi.hssf.model.*;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

public class GuardianFeeExpense extends Base {
  int expense_app_Id;
  HSSFWorkbook workbook;
  ExcelUtil eu;
  
  public GuardianFeeExpense(String templateName, int expense_app_Id)throws IOException {
    super();
    this.expense_app_Id = expense_app_Id;
    // Excelファイルの読み込み    
    FileInputStream fis = new FileInputStream(templateName);    
    o.println("Excel Template Open !! : " + templateName);
    POIFSFileSystem fs = new POIFSFileSystem(fis);    
    workbook = new HSSFWorkbook(fs);
    eu = new ExcelUtil();
  }

  //@Override
  public String getQueryString() {
  	String sql = ""
  	+ "select * from expense_applications a,employees b,TASSEIKUN_RECIPIENTS r, TASSEIKUN_RECIPIENT_DETAILS rd"
  	+ " where"
    + " a.id = " + expense_app_Id
  	+ " and b.user_id = a.user_id"
  	+ " and r.REREID = a.payment_no"
  	+ " and r.REREID = rd.REREID"
  	+ " and a.deleted = 0"
    + " and b.deleted = 0";
  	return sql;
  }

  //@Override
  public void procResultSet(ResultSet res) throws SQLException {
    HSSFSheet curSheet = workbook.getSheetAt(0);
  	HSSFSheet curSheet2 = workbook.getSheetAt(1);
  	while(res.next()) {
  	  
      procRewardHeader(res, curSheet);
  	  procRewardDetail(res, curSheet);
  	  procRewardFooter(res, curSheet);
  	  
  	  procTasseikunRecipient(res, curSheet2);
  	  procRewardHeader2(res, curSheet2);	
  	  procRewardDetail2(res, curSheet2);
      procRewardFooter2(res, curSheet2);
    }
  }
  
  public void procTasseikunRecipient(ResultSet res, HSSFSheet sheet) throws SQLException {
    eu.getCell(sheet,1,5).setCellValue(res.getString("REREK5"));
  	eu.getCell(sheet,3,5).setCellValue(res.getString("REREA5"));
  	eu.getCell(sheet,4,8).setCellValue(res.getString("REZPCD"));
  	if (res.getString("READA1") != null) eu.getCell(sheet,5,0).setCellValue(res.getString("READA1") + "　" + res.getString("READA2"));
  	//eu.getCell(sheet,5,0).setCellValue(res.getString("READA1") + "　" + res.getString("READA2"));
  	//eu.getCell(sheet,5,11).setCellValue(res.getString("READA2"));
  	String building_name = "";
  	if (res.getString("READA4") != null) building_name = res.getString("READA4");
  	if (res.getString("READA3") != null) eu.getCell(sheet,6,6).setCellValue(res.getString("READA3") + "　" + building_name);
  	//eu.getCell(sheet,6,6).setCellValue(res.getString("READA3") + "　" + res.getString("READA4"));
  	//eu.getCell(sheet,6,18).setCellValue(res.getString("READA4"));
  	eu.getCell(sheet,7,2).setCellValue(res.getString("RETLNO"));
  	eu.getCell(sheet,9,5).setCellValue(res.getString("REBKK3"));
  	eu.getCell(sheet,10,5).setCellValue(res.getString("REBRK3"));
  	if (res.getLong("REBKTP") == 1) { eu.getCell(sheet,11,5).setCellValue("普通"); }
  	else if (res.getLong("REBKTP") == 2) { eu.getCell(sheet,11,5).setCellValue("当座"); }
  	eu.getCell(sheet,12,5).setCellValue(res.getString("REACNM"));
  	eu.getCell(sheet,15,5).setCellValue(res.getString("REACA3"));
  	
  }
	
  public void procRewardHeader2(ResultSet res, HSSFSheet sheet) throws SQLException {
    eu.getCell(sheet,24,6).setCellValue(res.getString("employee_name"));
  	if (res.getDate("application_date") != null) eu.getCell(sheet,25,6).setCellValue(res.getDate("application_date"));
  	
  }
  
  public void procRewardHeader(ResultSet res, HSSFSheet sheet) throws SQLException {
    eu.getCell(sheet,11,6).setCellValue(res.getString("payee_name_kana"));
  	eu.getCell(sheet,12,6).setCellValue(res.getString("payee_name"));
  }

  public void procRewardDetail(ResultSet res, HSSFSheet sheet) throws SQLException {
    eu.getCell(sheet,14,6).setCellValue(res.getString("content"));
    
  	//eu.getCell(sheet,18,6).setCellValue(res.getLong("approximate_amount"));
  	eu.getCell(sheet,18,6).setCellValue(res.getLong("payment_amount") + res.getLong("withholding_tax"));
    eu.getCell(sheet,20,6).setCellValue(res.getLong("withholding_tax"));
  	eu.getCell(sheet,22,6).setCellValue(res.getLong("other_expenses"));
  	//eu.getCell(sheet,24,6).setCellValue(res.getLong("payment_amount"));
  	eu.getCell(sheet,24,6).setCellValue(res.getLong("payment_amount") + res.getLong("other_expenses"));
  }
	
  public void procRewardDetail2(ResultSet res, HSSFSheet sheet) throws SQLException {
    if (res.getDate("plan_buy_date") != null) eu.getCell(sheet,26,6).setCellValue(res.getDate("plan_buy_date"));
    
  	eu.getCell(sheet,27,6).setCellValue(res.getString("book_no"));
  	eu.getCell(sheet,28,6).setCellValue(res.getString("purpose"));
  	eu.getCell(sheet,29,6).setCellValue(res.getString("content"));
  	eu.getCell(sheet,30,6).setCellValue(res.getString("payment_no"));
  	eu.getCell(sheet,31,6).setCellValue(res.getString("account_item"));
  	if (res.getString("payment_method_type").equals("direct")) { eu.getCell(sheet,32,6).setCellValue("持参"); }
  	else if (res.getString("payment_method_type").equals("transfer")) { eu.getCell(sheet,32,6).setCellValue("振込"); }
  	if (res.getDate("preferred_date") != null) eu.getCell(sheet,33,6).setCellValue(res.getDate("preferred_date"));
    
  }
	
  public void procRewardFooter(ResultSet res, HSSFSheet sheet) throws SQLException {
    //eu.getCell(sheet,32,10).setCellValue(res.getLong("payment_amount"));
  	eu.getCell(sheet,32,10).setCellValue(res.getLong("payment_amount") + res.getLong("withholding_tax") + res.getLong("other_expenses"));
  }

   public void procRewardFooter2(ResultSet res, HSSFSheet sheet) throws SQLException {
     //eu.getCell(sheet,36,27).setCellValue(res.getLong("approximate_amount"));
   	 eu.getCell(sheet,36,27).setCellValue(res.getLong("payment_amount") + res.getLong("withholding_tax"));
     eu.getCell(sheet,37,27).setCellValue(res.getLong("withholding_tax"));
  	 eu.getCell(sheet,38,27).setCellValue(res.getLong("other_expenses"));
     //eu.getCell(sheet,39,27).setCellValue(res.getLong("payment_amount"));
   	 eu.getCell(sheet,39,27).setCellValue(res.getLong("payment_amount") + res.getLong("other_expenses"));
  }
  
  public void writeExcel(String fileName) throws IOException{
    eu.writeExcel(workbook, fileName);
  }
  
  /**
   *      0     1      2      3    4          5
   * args [url] [user] [pass] [id] [template] [output]  
   * @param args
   */
  public static void main(String[] args) {
    
    try {
      if(args.length < 6) throw new Exception("usage args.. [url] [user] [pass] [id] [template] [output]");
      String url = args[0];
      String user = args[1];
      String pass = args[2];
      int id = Integer.valueOf(args[3]).intValue();
      String template = args[4];
      String output = args[5];
      
      Base obj = new GuardianFeeExpense(template, id);
      obj.doProc(url, user, pass);
      obj.writeExcel(output);
    }catch(Exception e){
      e.printStackTrace();
    }

  }
}
