class AddFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :omniauth_providers
      t.string :uid
    end
  end
end
