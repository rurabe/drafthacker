class Player < ActiveRecord::Base
  has_many :slots
  has_many :teams, :through => :slots
  has_many :picks

                  #cbs players api data:
  attr_accessible :id,                
                  :first_name,
                  :full_name,
                  :icons_injury,
                  :icons_headline,
                  :last_name,
                  :on_waivers,             # Is this neccesary?   
                  :pro_status,
                  :pro_team,
                  :bye_week,
                  :is_locked,
                  :opponent,
                  :pct,                    # ADP
                  :change,                 # ADP
                  :avg,                    # ADP
                  :position,           
                  :high,                   # ADP
                  :low,                    # ADP
                  :rank,                   # ADP
                  :av_cbs,                 # Auction Values
                  :av_cbs_ppr,             # Auction Values
                  :av_dave_richard,        # Auction Values
                  :av_dave_richard_ppr,    # Auction Values
                  :av_jamey_eisenberg,     # Auction Values
                  :av_jamey_eisenberg_ppr, # Auction Values
                  :av_nathan_zegura        # Auction Values

  def self.drafted(options = {}) #eg. {:draft_id => 3}
    draft = Draft.find(options.fetch(:draft_id))
    drafted_player_ids = draft.picks.order('picks.number').pluck(:player_id)

    Player.where(:id => drafted_player_ids)
  end

  def self.undrafted(options = {})
    Player.all - drafted(options)
  end


end
