defmodule TicTacToe.Graphql.Types.Game do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias Noether.Either
  alias TicTacToe.Graphql.Resolvers.Game, as: GameResolver
  alias TicTacToe.Graphql.Resolvers.Move, as: MoveResolver

  object :game_queries do
    field :game, type: :game do
      arg(:identifier, non_null(:uuid))
      resolve(&GameResolver.get/2)
    end
  end

  object :game_mutations do
    field :create_game, non_null(:create_game_response) do
      arg(:game, non_null(:input_game))
      resolve(&GameResolver.create/2)
    end
  end

  input_object :input_game do
    field :title, non_null(:string)
    field :player_a, non_null(:string)
    field :player_b, non_null(:string)
  end

  union :create_game_response do
    types([:create_game_success, :create_game_failure])

    resolve_type(fn
      %{error: _}, _ -> :create_game_failure
      _, _ -> :create_game_success
    end)
  end

  object :create_game_failure, is_type_of: :create_game_response do
    field :error, non_null(:game_created_error)
  end

  object :create_game_success, is_type_of: :create_game_response do
    field :game, non_null(:game)
  end

  enum :game_created_error do
    value(:unknown)
  end

  object :move do
    field :player, non_null(:string)

    field :identifier, non_null(:uuid) do
      resolve(fn %{identifier: identifier}, _, _ ->
        identifier
        |> UUID.binary_to_string!()
        |> Either.wrap()
      end)
    end

    field :x, non_null(:move_x)
    field :y, non_null(:move_y)
    field :inserted_at, non_null(:datetime)
  end

  object :game do
    field :title, non_null(:string)

    field :identifier, non_null(:uuid) do
      resolve(fn %{identifier: identifier}, _, _ ->
        identifier
        |> UUID.binary_to_string!()
        |> Either.wrap()
      end)
    end

    field :player_a, non_null(:string)
    field :player_b, non_null(:string)
    field :status, non_null(:game_status)
    field :winner, :string
    field :inserted_at, non_null(:datetime)

    field :moves, non_null(list_of(:move)) do
      resolve(&MoveResolver.get_all_by_game_id/2)
    end
  end

  enum :game_status do
    value(:progress)
    value(:done)
  end

  enum :move_x do
    value(:a)
    value(:b)
    value(:c)
  end

  enum :move_y do
    value(:one)
    value(:two)
    value(:three)
  end
end
