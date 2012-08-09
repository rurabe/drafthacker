class Round < ActiveRecord::Base
  belongs_to  :draft
  has_many    :picks
  after_save  :create_picks

  def create_picks
    hash = [{:number=>1, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team2", :abbr=>"T2", :short_name=>"Team 2", :name=>"Team 2", :id=>"2"}}, {:number=>2, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team9", :abbr=>"T9", :short_name=>"Team 9", :name=>"Team 9", :id=>"9"}}, {:number=>3, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team10", :abbr=>"T1", :short_name=>"Team 1", :name=>"Team 10", :id=>"10"}}, {:number=>4, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team4", :abbr=>"T4", :short_name=>"Team 4", :name=>"Team 4", :id=>"4"}}, {:number=>5, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team6", :abbr=>"T6", :short_name=>"Team 6", :name=>"Team 6", :id=>"6"}}, {:number=>6, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team3", :abbr=>"T3", :short_name=>"Team 3", :name=>"Team 3", :id=>"3"}}, {:number=>7, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team7", :abbr=>"T7", :short_name=>"Team 7", :name=>"Team 7", :id=>"7"}}, {:number=>8, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team1", :abbr=>"T1", :short_name=>"Team 1", :name=>"Team 1", :id=>"1"}}, {:number=>9, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team8", :abbr=>"T8", :short_name=>"Team 8", :name=>"Team 8", :id=>"8"}}, {:number=>10, :round=>1, :team=>{:logo=>"http://sports.cbsimg.net/images/splash/football/lg-mgmtgold.gif", :long_abbr=>"Team5", :abbr=>"T5", :short_name=>"Team 5", :name=>"Team 5", :id=>"5"}}]
    hash.each do |pick|
      self.picks.create(:team_id => (pick[:team][:id].to_i ))
    end
  end

end
