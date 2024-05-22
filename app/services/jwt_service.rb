class JwtService
  require 'jwt'

  # Secret key for encoding and decoding
  HMAC_SECRET = Rails.application.credentials.jwt_secret || ENV['JWT_SECRET_KEY']

  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, HMAC_SECRET, 'HS256')
    end

    def decode(token)
      decoded = JWT.decode(token, HMAC_SECRET, true, algorithm: 'HS256')
      decoded[0]  # return the first index where the payload data is
    rescue JWT::DecodeError => e
      nil  # or raise an error as per your error handling policy
    end
  end
end
