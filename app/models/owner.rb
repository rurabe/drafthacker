class Owner < ActiveRecord::Base
  belongs_to :team

  attr_accessible :commissioner,
                  :cbs_hex_id,
                  :name,
                  :team_id #
end
