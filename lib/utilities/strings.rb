module Utilities::Strings

  # Strips space, leaves internal widespace as is
  def self.nil_strip(string) # string should have content or be empty
    if !string.nil?
      string.strip!
      string = nil if string == ''
    end
    string
  end

  # Strips space both condenses space
  def self.nil_squish_strip(string)
    if !string.nil?
      string.squish!
      string = nil if string == ''
    end
    string
  end


  def self.generate_md5(text)
    return nil if text.blank?
    Digest::MD5.hexdigest(text.gsub(/\s*/, '').downcase)
  end

end
