class RemovePaymentServicesFromDb < ActiveRecord::Migration
  def up
    # pick payment services data manually since there is no longer a model for them
    payment_services_data = ActiveRecord::Base.connection.execute('SELECT * from payment_services')

    # t_deposits is the only table that had a foreign key to payment services table
    # in order to denormalize we add a new column and match the payment service manually
    add_column :t_deposits, :payment_service, :string
    TDeposit.all.each do |deposit|
      payment_service_data_for_deposit = payment_services_data.detect { |payment_service_data| payment_service_data['id'].to_i.eql? deposit.payment_service_id }
      deposit.update_attributes(payment_service: payment_service_data_for_deposit['name'])
    end
    change_column :t_deposits, :payment_service, :string, null: false

    # then remove the foreign key and the payment services table
    remove_column :t_deposits, :payment_service_id
    drop_table :payment_services
  end

  def down
    # we rollback the payment services table and feed it
    create_table :payment_services do |t|
      t.string :name
      t.timestamps null: false
      t.index :name, unique: true
    end
    PaymentService::ALL.each { |payment_service_name| payment_service.create!(name: payment_service_name) }

    # normalize the information of the payment services for the deposits
    add_reference :t_deposits, :payment_service
    TDeposit.all.each do |deposit|
      payment_service_id = payment_service.find_by_name(deposit.name).id
      deposit.update_attributes(payment_service_id: payment_service_id)
    end

    # remove the unnormalized payment service column
    remove_column :t_deposits, :payment_service
  end
end
