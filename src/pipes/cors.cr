module Pipes
  class Cors < Base
    def call(context : HTTP::Server::Context) : HTTP::Server::Context
      context.response.headers["Access-Control-Allow-Origin"] = "*"
      context.response.headers["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
      context
    end
  end
end
