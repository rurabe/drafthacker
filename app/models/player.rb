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

  def chance(team) # input is in the form of teams 
    chances = {:past_picks => nil, :future_picks => nil}
    picks = team.picks.order(:number)
    past_picks = picks.where('player_id IS NOT NULL').pluck(:number)
    future_picks = picks.where('player_id IS NULL').pluck(:number)
    chances[:past_picks] = past_picks.inject({}) { |hash,pick| hash[pick] = normal(pick); hash }
    
    if picked?(team.league.draft)
      chances[:future_picks] = future_picks.inject({}) { |hash,pick| hash[pick] = 0; hash }
    else
      chances[:future_picks] = future_picks.inject({}) { |hash,pick| hash[pick] = normal(pick); hash }
    end
    chances
  end

  def picked?(draft)
    draft.drafted_players.include?(self)
  end

  private

    def normal(pick)
      mu = self.avg.to_f
      sigma = (self.low.to_f - self.high.to_f) / 3.96
      z = (pick.to_f - mu) / sigma
      dist = Rubystats::NormalDistribution.new
      pick == 1 ? 100 : ((1 - dist.cdf(z)) * 100).round(1)

    end

end
