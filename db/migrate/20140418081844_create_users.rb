class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, nll: false

      t.timestamps
    end
  end
end
