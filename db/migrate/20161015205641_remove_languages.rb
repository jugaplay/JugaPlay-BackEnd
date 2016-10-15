class RemoveLanguages < ActiveRecord::Migration
  def change
    remove_reference :countries, :language
    drop_table :languages
  end
end
