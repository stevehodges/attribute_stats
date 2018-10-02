ActiveRecord::Schema.define do
  self.verbose = false
  create_table :identities, force: true do |t|
    t.string  :first_name,     limit: 255
    t.text    :last_name,      limit: 255
    t.string  :middle_initial, limit: 255
    t.integer :address_id
    t.timestamps               null: false
  end

  create_table :addresses, force: true do |t|
    t.string   :line_1,        limit: 255
    t.string   :line_2,        limit: 255
    t.string   :country,       limit: 255,       default: 'United States'
    t.integer  :postal_code
  end
end