class CreateMoney < ActiveRecord::Migration
  def change
    create_table :money do |t|

      t.timestamps
    end
  end
end
