class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  has_many :teams, :through => :league
  has_many :rounds
  has_many :picks, :through => :rounds


  attr_accessible :name,
                  :start_time,
                  :league_attributes,
                  :rounds_attributes

  accepts_nested_attributes_for :league,
                                :rounds


  after_create :link_picks

  def build_feed
    this_draft = Draft.where(:id => self).includes(:picks,:teams,:rounds,:league).first
    feed = []
    self.picks.where('picks.player_id IS NOT NULL').order('picks.number DESC').each do |pick|
      feed << pick.to_feed_item
    end
    feed
  end

  def drafted_players
    # Select all players with ids that have been drafted, sorted by pick order
    Player.where(:id => drafted_ids, :position => self.teams.first.slots.pluck(:eligible_positions).uniq ).includes(:picks).order('picks.number')
  end

  def undrafted_players
    # Select all players with ids that have not been drafted, sorted by ADP
    Player.where(:id => undrafted_ids, :position => self.teams.first.slots.pluck(:eligible_positions).uniq ).order(:avg)
  end

  private

    def link_picks
      self.teams.each do |team|
        self.picks.where(:league_team_id => team.league_team_id).update_all(:team_id => team, :draft_id => self)
      end
    end

    def drafted_ids
      # Find the ids of all picks made
      self.picks.order('picks.number').pluck(:player_id)
    end

    def undrafted_ids
      # Find the ids of all picks and remove the ids of those already drafted
      Player.order(:avg).pluck(:id) - drafted_ids
    end

  end
