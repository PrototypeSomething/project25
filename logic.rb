def to_array(string)
  string = string.gsub(/[\[\]]/, '')  # Assign the result back to string
  string = string.delete(' ')       # Assign the result back to string
  string = string.split(',').map(&:to_i)
  return string
end