class CopyUserDetailsToProfile < ActiveRecord::Migration[7.1]
  def up
    User.all.each do |user|
      Profile.create({
                       user:,
                       name: 'Imported',
                       content: user.details
                     })
    end
  end
end
