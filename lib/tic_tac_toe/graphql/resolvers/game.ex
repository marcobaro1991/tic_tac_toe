defmodule TicTacToe.Graphql.Resolvers.Game do
  @moduledoc false

  alias TicTacToe.Application.Game, as: GameApplication
  alias TicTacToe.Schema.Game, as: GameSchema

  alias Absinthe.Resolution
  alias Noether.Either

  @spec get(map(), Resolution.t()) :: tuple()
  def get(%{identifier: identifier}, %Resolution{
        context:
          _context = %{
            current_user: _current_user,
            authorization_token: _authorization_token
          }
      }) do
    identifier
    |> GameApplication.get_by_identifier()
    |> Either.wrap()
  end

  def get(_args, %Resolution{source: %{game_identifier: game_identifier}}) do
    game_identifier
    |> UUID.binary_to_string!()
    |> GameApplication.get_by_identifier()
    |> Either.wrap()
  end

  @spec create(map(), Resolution.t()) :: tuple()
  def create(%{game: data}, %Resolution{
        context:
          _context = %{
            current_user: _current_user,
            authorization_token: _authorization_token
          }
      }) do
    data
    |> GameApplication.create()
    |> case do
      %GameSchema{} = game -> %{game: game}
      error -> error
    end
    |> Either.wrap()
  end
end
