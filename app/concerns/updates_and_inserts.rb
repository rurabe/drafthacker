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


    # extend ApiCall
    # players = json_response( { :api_call => 'players/list', :params => { :SPORT => "football" } } )[:body][:players]
    # players.map! do |player|
    #   player[:created_at] = Time.now # upsert does not seem to handle created_at and updated_at
    #   player[:updated_at] = Time.now # it errors if either are missing, whether or not the row exists already
    #   player[:cbs_id] = player.delete(:id)
    #   player[:icons_injury] = player[:icons][:injury] if player[:icons][:injury]
    #   player[:icons_headline] = player[:icons][:headline] if player[:icons][:headline]
    #   # player.delete(:icons)
    # end
    # upsert(Player, players, :id)


end