class AddAccessToken < ActiveRecord::Migration
  def change

    create_table :access_tokens do |t|
      t.references :user
      t.string :token, null: false, unique: true
      t.datetime :expires_in, null: false

      t.timestamps
    end
  end
end
