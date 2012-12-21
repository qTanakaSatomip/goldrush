# -*- encoding: utf-8 -*-
module ExpenseDetailHelper
  def view_check_box?(detail)
    detail.cutoff_status_type == 'open' && detail.credit_card_flg == 0 && detail.temporary_flg == 0
  end

  def book_no_check(book_no)
    params[:book_no].blank? || ((params[:book_no].match(/^999/) && book_no.match(/^999/)) || (params[:book_no] == book_no))
  end

end
