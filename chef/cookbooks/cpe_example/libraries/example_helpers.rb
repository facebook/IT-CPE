module CPE
  module Example
    # This should only be functions that contain raw Ruby. No Chef resources
    # should be used in here.
    # Every function you write in here should have a spec test.

    def example_function
      # Instead of using constants, it's much easier to use functions that
      # return string values. Constants are difficult to mix in, but library
      # helpers are trivially easy.
      'this_is_the_return_value'
    end
  end
end
