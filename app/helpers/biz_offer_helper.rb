# -*- encoding: utf-8 -*-
module BizOfferHelper

  def star_links_bizoffer(id, starred, param_id)
    link_to(raw("<span id='starred_icon_#{id}' style='#{_starstyle_bizoffer(starred)}'>★</span>"), "#", :onclick => "return changeFlg(#{id}, #{param_id}, 'starred');")
  end
  
  def _starstyle_bizoffer(flg)
    flg.to_i == 1 ? "color: #ffff00" : "color: #dfdfdf"
  end

end
