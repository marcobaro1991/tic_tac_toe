defmodule TicTacToe.Graphql.Resolvers.Move do
  @moduledoc false

  alias TicTacToe.Application.Move, as: MoveApplication

  alias Absinthe.Resolution
  alias Noether.Either

  @spec get_all_by_game_id(any(), Resolution.t()) :: tuple()
  def get_all_by_game_id(_args, %Resolution{source: %{id: game_id}}) do
    game_id
    |> MoveApplication.get_all_by_game_id()
    |> Either.wrap()
  end

  @spec create(map(), Resolution.t()) :: tuple()
  def create(%{move: data}, %Resolution{
        context:
          _context = %{
            current_user: _current_user,
            authorization_token: _authorization_token
          }
      }) do
    data
    |> MoveApplication.create()
    |> Either.wrap()
  end
end
