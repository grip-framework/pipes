module Pipes
  module Twj
    def encode_and_sign(
      data : Hash,
      secret_key : String = ENV["JWT_SECRET"],
      algorithm : JWT::Algorithm = JWT::Algorithm::HS256
    )
      JWT.encode(data, secret_key, algorithm)
    end

    def decode_and_verify(
      data : String,
      claims : Hash = {:aud => nil, :iss => nil, :sub => nil},
      secret_key : String = ENV["JWT_SECRET"],
      algorithm : JWT::Algorithm = JWT::Algorithm::HS256
    )
      JWT.decode(data, secret_key, algorithm, **NamedTuple(aud: String?, iss: String?, sub: String?).from(claims))
    end
  end

  class Jwt < Base
    BEARER = "Bearer"
    AUTH   = "Authorization"

    def initialize(
      @secret_key : String = ENV["JWT_SECRET"],
      claims : Hash(Symbol, String?) = {:aud => nil, :iss => nil, :sub => nil},
      @algorithm : JWT::Algorithm = JWT::Algorithm::HS256
    )
      @claims = NamedTuple(aud: String?, iss: String?, sub: String?).from(claims)
    end

    def call(context : HTTP::Server::Context) : HTTP::Server::Context
      if value = context.request.headers[AUTH]?
        if value.size > 0 && value.starts_with?(BEARER)
          begin
            payload, _ = JWT.decode(value[BEARER.size + 1..], @secret_key, @algorithm, **@claims)
            context.assigns.jwt = payload
            return context
          rescue exception
            raise Exceptions::Unauthorized.new
          end
        end
      end

      raise Exceptions::Unauthorized.new
    end
  end
end
