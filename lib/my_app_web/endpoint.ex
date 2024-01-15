defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app
  use SiteEncrypt.Phoenix

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_my_app_key",
    signing_salt: "jZ8r5XxT",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :my_app,
    gzip: false,
    only: MyAppWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug MyAppWeb.Router

  @impl SiteEncrypt
  def certification do
    SiteEncrypt.configure(
      client: :native,
      domains: [
        System.fetch_env!("PHX_HOST")
      ],
      emails: [
        "maneptha+elixir-phoenix-terraform@gmail.com"
      ],
      db_folder: System.get_env("SITE_ENCRYPT_DB", Path.join("tmp", "site_encrypt_db")),
      directory_url:
        case System.get_env("CERT_MODE", "local") do
          "local" ->
            cert_port =
              System.fetch_env!("LOCAL_CERT_PORT")
              |> String.to_integer()

            {:internal, port: cert_port}

          "staging" ->
            "https://acme-staging-v02.api.letsencrypt.org/directory"

          "production" ->
            "https://acme-v02.api.letsencrypt.org/directory"
        end
    )
  end

  @impl Phoenix.Endpoint
  def init(_key, config) do
    # this will merge key, cert, and chain into `:https` configuration from config.exs
    {:ok, SiteEncrypt.Phoenix.configure_https(config)}

    # to completely configure https from `init/2`, invoke:
    #   SiteEncrypt.Phoenix.configure_https(config, port: 4001, ...)
  end
end
