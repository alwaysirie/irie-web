class CreateAffiliateDeals < ActiveRecord::Migration
  def change
    create_table :affiliate_deals do |t|

      t.timestamps
    end
  end
end
