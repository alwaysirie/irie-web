class CreateMyEncryptors < ActiveRecord::Migration
  def change
    create_table :my_encryptors do |t|

      t.timestamps
    end
  end
end
