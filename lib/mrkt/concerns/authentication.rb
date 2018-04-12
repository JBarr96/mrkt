module Mrkt
  module Authentication
    def authenticate!
      authenticate unless authenticated?
      fail Mrkt::Errors::AuthorizationError, 'Client not authenticated' unless authenticated?
    end

    def authenticated?
      @token && valid_token?
    end

    def valid_token?
      @valid_until && Time.now < @valid_until
    end

    def authenticate
      connection.get('/identity/oauth/token', authentication_params).tap do |response|
        data = response.body

        @token = data.fetch(:access_token)
        @token_type = data.fetch(:token_type)
        @valid_until = Time.now + data.fetch(:expires_in)
        @scope = data.fetch(:scope)
      end
    end

    def authentication_params
      params_to_authenticate = {
        grant_type: 'client_credentials',
        client_id: @client_id,
        client_secret: @client_secret
      }

      params_to_authenticate[:partner_id] = @partner_id if !@partner_id.nil?

      params_to_authenticate
    end

    def add_authorization(req)
      req.headers[:authorization] = "Bearer #{@token}"
    end
  end
end
