class CreateAffiliates < ActiveRecord::Migration
  def change
    create_table :affiliates do |t|

      t.timestamps
    end
  end
end
