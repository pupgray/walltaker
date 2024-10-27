class NutPledge < ApplicationRecord
  belongs_to :user
  belongs_to :past_link, optional: true

  delegate :post_url, to: :past_link, allow_nil: true

  def failed?
    failed_on.present?
  end
end
