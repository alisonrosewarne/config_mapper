require "config_mapper/object_as_hash"

module ConfigMapper

  # Sets attributes on an object, collecting errors
  #
  class AttributeSink

    def self.set(data, target)
      mapper = new(target)
      mapper.set_attributes(data)
      mapper.errors
    end

    def initialize(target, errors = {})
      @target = ObjectAsHash[target]
      @errors = errors
    end

    attr_reader :target
    attr_reader :errors

    # Set multiple attributes from a Hash.
    #
    def set_attributes(data)
      data.each do |key, value|
        set_attribute(key, value)
      end
    end

    # Set a single attribute.
    #
    def set_attribute(key, value)
      if value.is_a?(Hash) && !target[key].nil?
        nested_errors = AttributeSink.set(value, target[key])
        nested_errors.each do |nested_key, error|
          errors[".#{key}#{nested_key}"] = error
        end
      else
        target[key] = value
      end
    rescue NoMethodError, ArgumentError => e
      errors[".#{key}"] = e
    end

  end

end
