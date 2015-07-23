require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    table_name.singularize.camelcase.constantize
  end

  def table_name
    class_name.downcase.underscore + "s"
  end


end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
      defaults = {
        foreign_key: (name.to_s + "_id").to_sym,
        primary_key: :id,
        class_name: name.to_s.camelcase.singularize
      }
      attributes = defaults.merge(options)
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
      defaults = {
        foreign_key: (self_class_name.to_s.downcase + "_id").to_sym,
        primary_key: :id,
        class_name: name.to_s.camelcase.singularize
      }
      attributes = defaults.merge(options)
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name.to_sym] = options
    define_method(name) do 
      fk = options.foreign_key
      pk = options.primary_key
      class_name = options.model_class
      class_name.send("where", {pk => self.send(fk.to_s)}).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    assoc_options[name.to_sym] = options
    define_method(name) do
      pk = options.foreign_key
      fk = options.primary_key
      class_name = options.model_class
      class_name.send("where", {pk => self.send(fk.to_s)})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def assoc_options=(given_options)
    @assoc_options = given_options
  end

end

class SQLObject
  extend Associatable
end
