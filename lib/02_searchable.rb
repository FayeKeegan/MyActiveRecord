require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
	def where(params)
		result = []
		where_line = params.keys.map {|key| key.to_s + " = ?"}.join(" AND ")
		rows = DBConnection.execute(<<-SQL, params.values)
		  SELECT
		    *
		  FROM
		    #{self.table_name}
	      WHERE 
	    	#{where_line}
		SQL
		result.concat(parse_all(rows))
	end
end

class SQLObject
  extend Searchable
end
