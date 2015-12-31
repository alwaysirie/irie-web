class CreateOperationHours < ActiveRecord::Migration
  def change
    create_table :operation_hours do |t|

      t.timestamps
    end
  end
end
