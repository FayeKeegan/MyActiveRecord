require_relative '03_associatable'

# Phase IV
module Associatable
  def has_one_through(name, through_name, source_name)
 	 
 	 define_method(name) do 

 	 	self_name = self.class.table_name.singularize

 	 	through_options = self.class.assoc_options[through_name]
 	 	through_table = through_options.class_name.downcase + "s"
 	 	through_fk = through_options.foreign_key.to_s
 	 	through_pk = through_options.primary_key.to_s

 	 	source_options = through_options.model_class.assoc_options[source_name]
 	 	source_table = source_options.class_name.downcase + "s"
 	 	source_fk = source_options.foreign_key.to_s
 	 	source_pk = source_options.primary_key.to_s

    	result = DBConnection.execute(<<-SQL, self.owner_id)
			SELECT
			  #{source_table}.*
			FROM
			  #{through_table}
			JOIN
			  #{source_table} ON #{through_table}.#{source_fk} = #{source_table}.id
			WHERE
			  #{through_table}.id = ?
		  SQL
		 source_options.class_name.constantize.new(result.first)
	  end
	end
end




