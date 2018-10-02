class Identity < ActiveRecord::Base

	def my_attrs
		[:first_name, :last_name, :middle_initial]
	end

end

class Address < ActiveRecord::Base
	def my_attrs
		[:line_1, :line_2, :country, :postal_code]
	end
end