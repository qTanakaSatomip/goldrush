package gd;

public class Main {

  /**
   *      0       1     2      3      4    5          6
   * args [yp|mx] [url] [user] [pass] [id] [template] [output]  
   * @param args
   */
  public static void main(String[] args) {
    
    try {
      // 引数が足りない場合、例外を投げて終了
      if(args.length < 7) throw new Exception("usage args.. [month|case] [url] [user] [pass] [id] [template] [output]");

      // 引数を変数に格納
      String mode = args[0];
      String url = args[1];
      String user = args[2];
      String pass = args[3];
      int id = Integer.valueOf(args[4]).intValue();
      String template = args[5];
      String output = args[6];
      Base obj;
      // モードによって分岐
      if(mode.equals("month")){
        obj = new GuardianMonth(template, id);
      }else if(mode.equals("case")){
        obj = new GuardianCase(template, id);
      }else if(mode.equals("fee_expense_app")){
        obj = new GuardianFeeExpense(template, id);
      }else if(mode.equals("temporary_app")){
        obj = new GuardianTemporary(template, id);
      }else if(mode.equals("card")){
        obj = new GuardianCard(template, id);
      }else{
        throw new Exception("usage args.. [month|case|fee_expense_app|temporary_app|card] [url] [user] [pass] [id] [template] [output]");
      }
      obj.doProc(url, user, pass);
      obj.writeExcel(output);

    }catch(Exception e){
      e.printStackTrace();
    }

  }

}
