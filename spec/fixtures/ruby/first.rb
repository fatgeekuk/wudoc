class Parent
end

#
# This is a leading comment, leading into the FirstChild class.
#
class FirstChild < Parent
  #
  # This is an instance method of FirstChild, called method_one
  #
  def method_one
  end
end

=begin
  
This is a multi line comment
  
=end
class Inner::SecondChild < Parent
end

class ::ThirdChild < Parent
end