require "oauth2"

module Rack
  module OAuth2
    module Server
      class Token
        module Extension
          class TokenExchange < Abstract::Handler
            class << self
              def grant_type_for?(grant_type)
                grant_type == 'token_exchange'
              end
            end

            def _call(env)
              @request  = Request.new(env)
              @response = Response.new(request)
              super
            end

            class Request < Token::Request
              attr_required :access_token

              def initialize(env)
                super
                @grant_type = :token_exchange
                @access_token = params['access_token']
                attr_missing!
              end
            end
          end
        end
      end
    end
  end
end
