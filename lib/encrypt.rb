# -*- encoding: utf-8 -*-
require 'openssl'
class String
  def encrypt(solt = 'solt')
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt
    enc.pkcs5_keyivgen(solt)
    ((enc.update(self) + enc.final).unpack("H*")).to_s
  end

  def decrypt(solt = 'solt')
    dec = OpenSSL::Cipher::Cipher.new('aes256') 
    dec.decrypt 
    dec.pkcs5_keyivgen(solt)
    (dec.update(Array.new([self]).pack("H*")) + dec.final)
  end 

  def getHash()
    OpenSSL::Digest::SHA1.new(self)
  end
end
