import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :tic_tac_toe, TicTacToe.Repo,
  username: "tic_tac_toe",
  password: "tic_tac_toe",
  hostname: "db",
  database: "tic_tac_toe",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

if System.get_env("GITHUB_ACTIONS") do
  config :tic_tac_toe, TicTacToe.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost"
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tic_tac_toe, TicTacToeWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "CecrBgosXt00uogACi+Z+l9l5c4a4yW/jWpipbTeJr/x4p7jtkHDmQYC0s1UGodC",
  server: false

# In test we don't send emails.
config :tic_tac_toe, TicTacToe.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :joken, default_signer: "secret"

config :tic_tac_toe, :jwt,
  sign: "HS256",
  exp_days: 7
