# These should trigger all the grep regexes
[:line_1, :line_2].each do |attribute|
  address.send attribute

identity.first_name
identity.last_name

address.line_1
address.line_2

address['line_1']
address['line_2']

address["line_1"]
address["line_2"]
