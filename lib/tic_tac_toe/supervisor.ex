defmodule TicTacToe.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children = [
      pub_sub(),
      repo(),
      endpoint()
    ]

    opts = [strategy: :one_for_one, max_restarts: 6]
    Supervisor.init(children, opts)
  end

  defp repo do
    TicTacToe.Repo
  end

  defp pub_sub do
    {Phoenix.PubSub, name: TicTacToe.PubSub}
  end

  def endpoint do
    Supervisor.child_spec({TicTacToeWeb.Endpoint, []}, shutdown: 60_000)
  end
end
