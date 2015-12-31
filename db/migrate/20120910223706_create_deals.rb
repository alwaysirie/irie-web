class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|

      t.timestamps
    end
  end
end
