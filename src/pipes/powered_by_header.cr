module Pipes
  class PoweredByHeader < Base
    def call(context : HTTP::Server::Context) : HTTP::Server::Context
      context.response.headers["Server"] = "Grip"
      context
    end
  end
end
