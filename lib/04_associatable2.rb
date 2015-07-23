require_relative '03_associatable'

# Phase IV
module Associatable
  def has_one_through(name, through_name, source_name)
 	 
 	 define_method(name) do 

 	 	self_name = self.class.table_name.singularize
 	 	#cat

 	 	#cat belongs to human
 	 	through_options = self.class.assoc_options[through_name]
 	 	#<BelongsToOptions:0x007fd0720fc0b8 @foreign_key=:owner_id, @primary_key=:id, @class_name="Human">
 	 	through_table = through_options.class_name.downcase + "s"
 	 	#humans
 	 	through_fk = through_options.foreign_key.to_s
 	 	#owner_id
 	 	through_pk = through_options.primary_key.to_s
 	 	#id

 	 	#human belongs to home
 	 	source_options = through_options.model_class.assoc_options[source_name]
 	 	#<BelongsToOptions:0x007fd072112b10 @foreign_key=:house_id, @primary_key=:id, @class_name="House">
 	 	source_table = source_options.class_name.downcase + "s"
 	 	#houses
 	 	source_fk = source_options.foreign_key.to_s
 	 	#house_id
 	 	source_pk = source_options.primary_key.to_s
 	 	#id

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

   #  	result = DBConnection.execute(<<-SQL)
			# SELECT
			#   houses.*
			# FROM
			#   humans
			# JOIN
			#   houses ON humans.house_id = houses.id
			# WHERE
			#   humans.id = cat.owner_id
		 #  SQL
	  # end




