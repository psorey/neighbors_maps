class ChangeUserLines < ActiveRecord::Migration
  def change
    add_column :user_lines, :guid, :string
    add_column :user_lines, :name, :string
    add_column :user_lines, :text, :text
    add_column :user_lines, :number, :integer
    add_column :user_lines, :amount, :float
  end
end
