require 'openssl'
class MyEncryptor
  
  KEY = "\xE9v\f\xC3\xBD\x8EH\xBD.G\x17\x84\xD5K\xDB\xE5\r\x8D0\xEC\xBF9\xA2\xAF\x9Bp\xFEd\xAA\x8DH\x99"
  IV = "\x94\x19\xB7\x96\xC7\xFC\x92:_4\xB4\xF6\xCE\xED\xB9\xD0"

  def self.encrypt(text)
    self.aes_wrapper(:encrypt, text)
  end

  def self.decrypt(text)
    self.aes_wrapper(:decrypt, text)
  end

  private
    def self.aes_wrapper(direction, text)
      return nil unless text

      aes = OpenSSL::Cipher::Cipher.new('aes-256-cbc').send(direction)
      aes.key = KEY
      aes.iv = IV

      aes.update(text) << aes.final
    end
end