import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases

if System.get_env("PHX_SERVER", "") != "" do
  config :my_app, MyAppWeb.Endpoint, server: true
end

scheme =
  if System.get_env("HTTP_SSL", "") == "" do
    "http"
  else
    "https"
  end

# The secret key base is used to sign/encrypt cookies and other secrets.
# A default value is used in config/dev.exs and config/test.exs but you
# want to use a different value for prod and you most likely don't want
# to check this value into version control, so we use an environment
# variable instead.
secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

host =
  System.get_env("PHX_HOST") ||
    raise """
    environment variable PHX_HOST is missing.
    """

port =
  System.get_env("PORT")
  |> Kernel.||(
    raise """
    environment variable PORT is missing.
    """
  )
  |> String.to_integer()

http_port =
  System.get_env("HTTP_PORT")
  |> Kernel.||(
    raise """
    environment variable HTTP_PORT is missing.
    """
  )
  |> String.to_integer()

ip = {0, 0, 0, 0}

config :my_app, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

config :my_app, MyAppWeb.Endpoint,
  url: [
    host: host,
    port: port,
    scheme: scheme
  ],
  https: [
    ip: ip,
    port: port
  ],
  http: [
    ip: ip,
    port: http_port
  ],
  secret_key_base: secret_key_base

if config_env() == :prod do
  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :my_app, MyAppWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :my_app, MyAppWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
