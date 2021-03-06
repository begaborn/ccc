module Korbit
  class Token
    attr :access_token, :refresh_token

    def initialize(client, options)
      @client        = client
      @client_id     = options[:client_id]
      @client_secret = options[:client_secret]
      @username      = options[:username]
      @password      = options[:password]
    end

    def valid?
      @access_token and not expired?
    end

    def expired?
      Time.now > @expired_at
    end

    def need_to_refresh?
      @expired_at && (Time.now + 300) > @expired_at && @expired_at > Time.now
    end

    def refresh_token!
      if need_to_refresh?
        refresh_access_token
      elsif @refresh_token.nil? || expired?
        new_access_token
      end
    end

    def attach_token(params = {})
      refresh_token!
      params.merge access_token: @access_token, nonce: nonce
    end

    private
    def nonce
      (Time.now.to_f * 1000).floor
    end

    def new_access_token
      resp = @client.post 'oauth2/access_token',
        client_id:     @client_id,
        client_secret: @client_secret,
        username:      @username,
        password:      @password,
        grant_type:    'password'

      @access_token  = resp['access_token']
      @refresh_token = resp['refresh_token']
      @expired_at  = Time.now + resp['expires_in'] - 300
      resp
    end

    def refresh_access_token
      resp = @client.post 'oauth2/access_token',
        client_id:     @client_id,
        client_secret: @client_secret,
        refresh_token: @refresh_token,
        grant_type:    'refresh_token'

      @access_token  = resp['access_token']
      @refresh_token = resp['refresh_token']
      @expired_at  = Time.now + resp['expires_in'] - 300
      resp
    end
  end
end
