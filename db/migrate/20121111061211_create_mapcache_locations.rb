class CreateMapcacheLocations < ActiveRecord::Migration
  def change
    create_table :mapcache_locations do |t|

      t.timestamps
    end
  end
end
