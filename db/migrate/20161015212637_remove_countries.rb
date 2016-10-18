class RemoveCountries < ActiveRecord::Migration
  def up
    # pick countries data manually since there is no longer a model for it
    countries_data = ActiveRecord::Base.connection.execute('SELECT * from countries')

    # t_deposits is the only table that had a foreign key to countries table
    # in order to denormalize we add a new column and match the country manually
    add_column :t_deposits, :country, :string
    TDeposit.all.each do |deposit|
      country_data_for_deposit = countries_data.detect { |country_data| country_data['id'].to_i.eql? deposit.country_id }
      deposit.update_attributes(country: country_data_for_deposit['name'])
    end
    change_column :t_deposits, :country, :string, null: false

    # then remove the foreign key and the countries table
    remove_column :t_deposits, :country_id
    drop_table :countries
  end

  def down
    # we rollback the countries table and feed it
    create_table :countries do |t|
      t.string :name
      t.timestamps null: false
      t.index :name, unique: true
    end
    Country::ALL.each { |country_name| Country.create!(name: country_name) }

    # normalize the information of the countries for the deposits
    add_reference :t_deposits, :country
    TDeposit.all.each do |deposit|
      country_id = Country.find_by_name(deposit.name).id
      deposit.update_attributes(country_id: country_id)
    end

    # remove the unnormalized country column
    remove_column :t_deposits, :country
  end
end
