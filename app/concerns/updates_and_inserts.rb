module UpdatesAndInserts

  def upsert(activerecord_subclass, array_of_hashes, index_column)
      if array_of_hashes.class == Array
        Upsert.batch(activerecord_subclass.connection, activerecord_subclass.table_name) do |upsert|
          array_of_hashes.each do |hash|
            binding.pry
            upsert.row({index_column => hash.delete(index_column)}, hash) # This syntax is fine.
            binding.pry
          end
          binding.pry
        end
      else
        # :error => "you must provide an array of attribute hashes"
      end
    end

end