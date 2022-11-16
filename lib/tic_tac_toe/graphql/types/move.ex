defmodule TicTacToe.Graphql.Types.Move do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias TicTacToe.Graphql.Resolvers.Move, as: MoveResolver
  alias TicTacToe.Graphql.Resolvers.Game, as: GameResolver

  object :move_mutations do
    field :create_move, non_null(:create_move_response) do
      arg(:move, non_null(:input_move))
      resolve(&MoveResolver.create/2)
    end
  end

  input_object :input_move do
    field :game_identifier, non_null(:uuid)
    field :player, non_null(:string)
    field :x, non_null(:move_x)
    field :y, non_null(:move_y)
  end

  union :create_move_response do
    types([:create_move_success, :create_move_failure])

    resolve_type(fn
      %{error: _, message: _}, _ -> :create_move_failure
      _, _ -> :create_move_success
    end)
  end

  object :create_move_failure do
    field :error, non_null(:create_move_error)
    field :message, non_null(:string)
  end

  enum :create_move_error do
    value(:game_done)
    value(:game_not_found)
    value(:wrong_player)
    value(:wrong_position)
    value(:unknown)
    value(:move_not_saved)
    value(:cant_update_status)
    value(:cant_update_winner_and_game_status)
  end

  object :create_move_success do
    field :player_has_won, non_null(:boolean)

    field :game, non_null(:game) do
      resolve(&GameResolver.get/2)
    end
  end
end
