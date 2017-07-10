class AddViewedAtToMentions < ActiveRecord::Migration
  def change
    add_column :mentions, :viewed_at, :datetime
  end
end
