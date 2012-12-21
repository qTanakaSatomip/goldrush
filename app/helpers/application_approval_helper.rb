module ApplicationApprovalHelper

  def report_xxx?
    @approver_type == 'report_xxx'
  end

  def expense_xxx?
    @approver_type == 'expense_xxx'
  end
end
