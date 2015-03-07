require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    puts "#{name}".tableize
    define_method("#{name}") do
    through_options = self.class.assoc_options[through_name.to_sym]
    source_options = through_options.model_class.assoc_options[source_name.to_sym]

    select_this = "#{source_options.class_name.pluralize}.*"
    from_here = "#{through_options.model_class.table_name}"
    join_this = "#{source_options.class_name.pluralize}"


    data = DBConnection.execute(<<-SQL)
      SELECT
        #{select_this}
      FROM
        #{from_here}
      JOIN
        #{join_this} ON #{from_here}.#{through_options.primary_key} = #{source_options.class_name.pluralize}.#{source_options.primary_key}
    SQL

    source_options.model_class.parse_all(data).first
    end
  end
end
