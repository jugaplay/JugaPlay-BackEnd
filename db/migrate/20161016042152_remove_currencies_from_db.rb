class RemoveCurrenciesFromDb < ActiveRecord::Migration
  def up
    # pick currencies data manually since there is no longer a model for them
    currencies_data = ActiveRecord::Base.connection.execute('SELECT * from currencies')

    # t_deposits is the only table that had a foreign key to currencies table
    # in order to denormalize we add a new column and match the currency manually
    add_column :t_deposits, :currency, :string
    TDeposit.all.each do |deposit|
      currency_data_for_deposit = currencies_data.detect { |currency_data| currency_data['id'].to_i.eql? deposit.currency_id }
      deposit.update_attributes(currency: currency_data_for_deposit['name'])
    end
    change_column :t_deposits, :currency, :string, null: false

    # then remove the foreign key and the currencies table
    remove_column :t_deposits, :currency_id
    drop_table :currencies
  end

  def down
    # we rollback the currencies table and feed it
    create_table :currencies do |t|
      t.string :name
      t.timestamps null: false
      t.index :name, unique: true
    end
    Currency::ALL.each { |currency_name| Currency.create!(name: currency_name) }

    # normalize the information of the currencies for the deposits
    add_reference :t_deposits, :currency
    TDeposit.all.each do |deposit|
      currency_id = Currency.find_by_name(deposit.name).id
      deposit.update_attributes(currency_id: currency_id)
    end

    # remove the unnormalized currency column
    remove_column :t_deposits, :currency
  end
end
