# -*- encoding: utf-8 -*-
#
#see
# * http://www.flash-jp.com/modules/newbb/viewtopic.php?viewmode=flat&order=DESC&topic_id=3414&forum=18

class ParameterInjector

	#==parameters
	# * src_swf 元になるswfのファイルパス
	# * 挿入するパラメータ（Hash）
	def self.inject(src_swf,flash_params={})

		doaction_tag = tag_create(flash_params)

		oldsize = File.size(src_swf)
		file = File.new(src_swf,'rb')

			# ヘッダ長さは可変なので途中まで読んでから確定させる
			# 背景色設定タグよりも前に DoActionTag 挿入するとエラーでるので
			# 便宜的にそいつもヘッダ扱い(headlen 計算の末尾の "+5" 部分)

			headtmp = file.read(9)
			rectbit = headtmp[8]>>3
			headlen = (((( 8 - ((rectbit*4+5)&7) )&7)+ rectbit*4 + 5 )/8).ceil + 12 + 5
			head = headtmp + file.read(headlen - 9)

			# 挿入によるファイルサイズ変更反映のためのヘッダ変更

			newsize = oldsize + doaction_tag.length
			newhead = head[0..3] + h32(newsize) + head[8..head.length]
			tail = file.read(oldsize-headlen)

		file.close

		newhead + doaction_tag + tail

	end

private

	def self.h32(size)
		[size].pack("V")
	end

	def self.h16(size)
		[size].pack("v")
	end

	def self.tag_length(flash_params)
		ret = 0;
		flash_params.each do |key , value|
			ret += key.length + value.to_s.length + 11
		end
		ret+1;
	end

	# フォームから渡ってきた変数代入文相当のアクションタグ生成
	def self.tag_create(flash_params)
		tag = "\x3f\x03"
		taglen = tag_length(flash_params)
		tag += h32(taglen)

		flash_params.each do | key , val |
      tag += "\x96" + h16(key.length+2)      + "\x00" + key      + "\x00" \
           + "\x96" + h16(val.to_s.length+2) + "\x00" + val.to_s + "\x00" \
           + "\x1d"
		end
		tag += "\x00"
	end

end