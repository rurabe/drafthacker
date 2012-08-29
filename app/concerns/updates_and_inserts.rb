module UpdatesAndInserts


  def self.upsert(activerecord_subclass, array_of_hashes, index_column)
      if array_of_hashes.class == Array
        Upsert.batch(activerecord_subclass.connection, activerecord_subclass.table_name) do |upsert|
          array_of_hashes.each do |hash|
            upsert.row({index_column => hash.delete(index_column)}, hash) # This syntax is fine.
          end
        end
      else
        # :error => "you must provide an array of attribute hashes"
      end
    end

  def self.upsert_players
    extend ApiCall
    players = json_response( { :api_call => 'players/list', :params => { :SPORT => "football" } } )[:body][:players]
    players.map! do |player|
      player[:created_at] = Time.now # upsert does not seem to handle created_at and updated_at
      player[:updated_at] = Time.now # it errors if either are missing, whether or not the row exists already
      player[:cbs_id] = player.delete(:id)
      
      if player[:icons]
      player[:icons_injury] = player[:icons][:injury] if player[:icons][:injury]
      player[:icons_headline] = player[:icons][:headline] if player[:icons][:headline]
      player.delete(:icons)
      end
      
      player
    end
    upsert(Player, players, :cbs_id)
    puts "Player.count = #{Player.count}"
  end

end