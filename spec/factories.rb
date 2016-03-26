Dir[Rails.root.join('spec/factories/*.rb')].each do |file|
  require file
end
