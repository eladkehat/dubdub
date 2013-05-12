module Dubdub
  module Config
    extend self

      # Appdata provides a basic single-method DSL with .parameter method
      # being used to define a set of available settings.
      # This method takes one or more symbols, with each one being
      # a name of the configuration option.
      def parameter(*names)
        names.each do |name|
          attr_accessor name

          # For each given symbol generate accessor method that sets option's
          # value being called with an argument, or returns option's current value
          # when called without arguments
          define_method name do |*values|
            value = values.first
            value ? self.send("#{name}=", value) : instance_variable_get("@#{name}")
          end
        end
      end
      alias :parameters :parameter

      # Define a wrapper for the configuration block, that we'll use to set up
      # our set of options
      def config(&block)
        instance_eval &block
      end

  end
end
