class GenerateActivityPubKey < ActiveRecord::Migration[7.1]
  def up
    #Removed, so you don't have to deal with this when running mirgrations
    #rsa_key = OpenSSL::PKey::RSA.new(2048)
    #Key.create(purpose: :activity_pub, public: rsa_key.public_key.to_pem(nil), private: rsa_key.to_pem(nil))
  end

  def down
    Key.delete_by(purpose: :activity_pub)
  end
end
