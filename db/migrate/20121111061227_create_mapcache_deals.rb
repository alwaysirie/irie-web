class CreateMapcacheDeals < ActiveRecord::Migration
  def change
    create_table :mapcache_deals do |t|

      t.timestamps
    end
  end
end
