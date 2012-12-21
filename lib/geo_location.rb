# -*- encoding: utf-8 -*-
class GeoLocation
  def GeoLocation.calculationDistance(lat1, lng1, lat2, lng2)
    # 定数のセット
    p = Math::PI
    a = 6378137

    # 位置情報をラジアンに変換
    a1 = lat1 * p / 180
    n1 = lng1 * p / 180
    a2 = lat2 * p / 180
    n2 = lng2 * p / 180

    # 距離の算出
    d_a = a1 - a2
    d_n = n1 - n2
    ra = Math.cos( (a1 + a2 ) / 2 )
    dx = a * d_n * ra
    dy = a * d_a
    Math.hypot( dx , dy ).floor
  end
end
