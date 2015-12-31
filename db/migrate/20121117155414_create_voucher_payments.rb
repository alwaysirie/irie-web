class CreateVoucherPayments < ActiveRecord::Migration
  def change
    create_table :voucher_payments do |t|

      t.timestamps
    end
  end
end
