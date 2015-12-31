class CreateAffiliateVouchers < ActiveRecord::Migration
  def change
    create_table :affiliate_vouchers do |t|

      t.timestamps
    end
  end
end
