class CreateEncrypts < ActiveRecord::Migration
  def change
    create_table :encrypts do |t|

      t.timestamps
    end
  end
end
