# frozen_string_literal: true

class ProfileAdderForm
  include ActiveModel::API

  attr_accessor :profile_id

  def profile
    Profile.find(profile_id)
  end

  def self.from_params(params)
    new params.require(:profile_adder_form).permit(:profile_id)
  end
end
