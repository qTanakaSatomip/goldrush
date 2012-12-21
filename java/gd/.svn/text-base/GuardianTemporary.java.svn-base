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

public class GuardianTemporary extends Base {
  int expense_app_Id;
  HSSFWorkbook workbook;
  ExcelUtil eu;
  
  public GuardianTemporary(String templateName, int expense_app_Id)throws IOException {
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
    + "SELECT * FROM expense_applications a                 \n"
    + " join employees b on a.user_id = b.user_id \n"
  	+ " join expense_details c on a.id = c.expense_application_id \n"
  	+ " join payment_per_months d on d.id = c.payment_per_month_id \n"
  	+ "where                                   \n"
    + " a.id = " + expense_app_Id + "                \n"
    + " and a.deleted = 0 \n"
    + " and b.deleted = 0 \n"
  	+ " and c.deleted = 0 \n"
  	+ " and d.deleted = 0 \n";
  	return sql;
  }

  //@Override
  public void procResultSet(ResultSet res) throws SQLException {
    HSSFSheet curSheet = workbook.getSheetAt(0);
  	while(res.next()) {
      procRewardHeader(res, curSheet);
      procRewardDetail(res, curSheet);
      //procRewardFooter(res, curSheet);
    }
  }
  
  public void procRewardHeader(ResultSet res, HSSFSheet sheet) throws SQLException {
    //承認者分
  	eu.getCell(sheet,2,6).setCellValue(res.getString("employee_name"));
  	//本人分
   	eu.getCell(sheet,31,6).setCellValue(res.getString("employee_name"));
  }

  public void procRewardDetail(ResultSet res, HSSFSheet sheet) throws SQLException {
  	//承認者分
    if (res.getDate("application_date") != null) eu.getCell(sheet,9,8).setCellValue(res.getDate("application_date"));
  	if (res.getDate("cutoff_end_date") != null) eu.getCell(sheet,10,8).setCellValue((new SimpleDateFormat("yyyy/MM")).format(res.getDate("cutoff_end_date")));
  	if (res.getDate("plan_buy_date") != null) eu.getCell(sheet,11,8).setCellValue(res.getDate("plan_buy_date"));
  	if (res.getDate("preferred_date") != null) eu.getCell(sheet,12,8).setCellValue(res.getDate("preferred_date"));
  	eu.getCell(sheet,13,8).setCellValue(res.getString("book_no"));
    eu.getCell(sheet,14,8).setCellValue(res.getString("account_item"));
  	eu.getCell(sheet,15,8).setCellValue(res.getString("purpose"));
  	eu.getCell(sheet,16,8).setCellValue(res.getString("content"));
  	eu.getCell(sheet,17,8).setCellValue(res.getLong("approximate_amount"));
  	//本人分
    if (res.getDate("application_date") != null) eu.getCell(sheet,34,8).setCellValue(res.getDate("application_date"));
  	if (res.getDate("cutoff_end_date") != null) eu.getCell(sheet,35,8).setCellValue((new SimpleDateFormat("yyyy/MM")).format(res.getDate("cutoff_end_date")));
  	if (res.getDate("plan_buy_date") != null) eu.getCell(sheet,36,8).setCellValue(res.getDate("plan_buy_date"));
  	if (res.getDate("preferred_date") != null) eu.getCell(sheet,37,8).setCellValue(res.getDate("preferred_date"));
  	eu.getCell(sheet,38,8).setCellValue(res.getString("book_no"));
    eu.getCell(sheet,39,8).setCellValue(res.getString("account_item"));
  	eu.getCell(sheet,40,8).setCellValue(res.getString("purpose"));
  	eu.getCell(sheet,41,8).setCellValue(res.getString("content"));
  	eu.getCell(sheet,42,8).setCellValue(res.getLong("approximate_amount"));
  }
	
  public void procRewardFooter(ResultSet res, HSSFSheet sheet) throws SQLException {
    //eu.getCell(sheet,32,12).setCellValue(res.getLong("payment_amount"));
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
      
      Base obj = new GuardianTemporary(template, id);
      obj.doProc(url, user, pass);
      obj.writeExcel(output);
    }catch(Exception e){
      e.printStackTrace();
    }

  }
}
