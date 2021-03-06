require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id",
      :primary_key => :id,
      :class_name  => "#{name}".capitalize
    }
    options = defaults.merge(options)

    @foreign_key = options[:foreign_key].to_sym
    @primary_key = options[:primary_key]
    @class_name  = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name}_id".downcase,
      :primary_key => :id,
      :class_name  => "#{name}".capitalize
    }
    options = defaults.merge(options)

    @foreign_key = options[:foreign_key].to_sym
    @primary_key = options[:primary_key]
    @class_name  = options[:class_name].singularize
  end
end

module Associatable
  def belongs_to(name, options = {})

    options = BelongsToOptions.new(name, options)

    define_method("#{name}") do
      options.model_class.where(id: self.send(options.foreign_key)).first
    end
    assoc_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self ,options)

    define_method("#{name}") do
      options.model_class.where({options.foreign_key => self.id})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
