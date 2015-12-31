class CreateMapCaches < ActiveRecord::Migration
  def change
    create_table :map_caches do |t|

      t.timestamps
    end
  end
end
