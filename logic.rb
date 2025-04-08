# @!group Logic

##
# Converts a string representation of an array into an actual array of integers.
#
# This method removes square brackets, spaces, and splits the string by commas,
# then converts each element into an integer.
#
# @param [String] string The string representation of an array (e.g., "[1, 2, 3]").
# @return [Array<Integer>] The resulting array of integers.
#
# @example
#   to_array("[1, 2, 3]") # => [1, 2, 3]
#   to_array("4,5,6")     # => [4, 5, 6]
def to_array(string)
  string = string.gsub(/[\[\]]/, '')  # Remove square brackets
  string = string.delete(' ')        # Remove spaces
  string = string.split(',').map(&:to_i) # Split by commas and convert to integers
  return string
end