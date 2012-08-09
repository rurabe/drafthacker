module CbsClient
  # class UserInstantiation

    def get_params(access_token,cbs_id)
      @@access_token = access_token
      @@cbs_id = cbs_id

      # build_mega_hash
      build_hash_league_details


    end

    private

    def build_mega_hash
      {:user => @@cbs_id,
        :drafts_attributes =>
          [
            {
              :league_attributes =>
              {
                build_hash_league_details.merge build_hash_draft_config
              },
              :rounds_attributes =>
              [
                {
                  :picks_attributes =>
                  [
                    {

                    }
                  ]
                }
              ]
            }
          ]
      }

    end

    def build_hash_league_details
      json_response('league/details')[:body][:league_details]
    end

    def build_hash_draft_config
      json_response('league/draft/config')
    end

    def build_hash_draft_order
      json_response('league/draft/order')
    end

    def build_hash_fantasy_teams
      json_response('league/teams')
    end

    def json_response(api_call)
      JSON.parse(read_response(api_call), :symbolize_names => true)
    end

    def read_response(api_call)
      open(build_url(api_call)).read
    end

    def build_url(api_call)
      "http://api.cbssports.com/fantasy/#{api_call}?access_token=#{@@access_token}&response_format=JSON"
    end
  # end
end