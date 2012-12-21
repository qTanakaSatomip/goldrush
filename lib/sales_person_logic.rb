# -*- encoding: utf-8 -*-
module SalesPersonLogic

  # 営業担当の承認が必要な区分(出張、謝礼)の場合、たっせい君から受注Noに紐づく営業担当を
  # 取得してくる。1名だった場合、そのまま承認者として追加。
  # 2名以上だった場合は、コンボボックスを設定して選択させる。
  # もし、Guardian側に営業担当のユーザがいなければワーニングする
  def check_sales_person(_application, approval_authorities)
    if _application.book_no.blank?
      raise ValidationAbort.new("受注Noを入力してください。")
    end
    unless job_header = TasseikunJobHeader.get_job(_application.book_no)
      raise ValidationAbort.new("受注Noが不正です。(#{_application.book_no})")
    end

    job_details = job_header.job_details
    if job_details.empty?
      raise ValidationAbort.new('受注Noに、営業担当が登録されていませんでした')
    end

    if job_details.size == 1
      _application.sales_person = job_details[0].jbusid
    end
    hit = false
    @sales_persons = []
    job_details.each do |job|
      hit = true if _application.sales_person == job.jbusid
      @sales_persons << [job.jbusa3, job.jbusid]
    end
    if _application.sales_person.blank? || !hit
      raise ValidationAbort.new("担当の営業担当が複数人います。選択してください")
    end

    if sales_person_user = User.find(:first, :conditions => ["deleted = 0 and login = ?", _application.sales_person])
      hit = false
      approval_authorities.each do |approval_authority|
        hit = true if approval_authority.approver_id == sales_person_user.id
      end
      if !hit
        approval_authorities << ApprovalAuthority.new({:approver_id => sales_person_user.id, :user_id => _application.user_id})
      end
      _application.sales_person_id = sales_person_user.id
    else
      raise ValidationAbort.new("営業担当のユーザ登録がありません(#{_application.sales_person})")
#      flash[:warning] = "営業担当のユーザ登録がありません(#{_application.sales_person})"
    end
  end
end
