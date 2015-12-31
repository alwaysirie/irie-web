class CreateLowercases < ActiveRecord::Migration
  def change
    create_table :lowercases do |t|

      t.timestamps
    end
  end
end
