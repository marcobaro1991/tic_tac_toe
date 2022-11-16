defmodule TicTacToe.Application.Game do
  @moduledoc false
  alias TicTacToe.Repo
  alias TicTacToe.Schema.Game, as: GameSchema

  @spec get_by_identifier(String.t()) :: GameSchema.t() | nil
  def get_by_identifier(identifier) do
    GameSchema
    |> GameSchema.get_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
  end

  @spec update(GameSchema.t(), map()) :: GameSchema.t() | nil
  def update(schema, attrs) do
    schema
    |> GameSchema.update_changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, res = %GameSchema{}} -> res
      {_, _err} -> nil
    end
  end

  @spec create(map()) :: GameSchema.t() | nil
  def create(%{title: title, player_a: player_a, player_b: player_b}) do
    %GameSchema{
      identifier: UUID.string_to_binary!(UUID.uuid4()),
      title: String.trim(title),
      player_a: String.trim(player_a),
      player_b: String.trim(player_b),
      status: :progress,
      winner: nil
    }
    |> Repo.insert()
    |> case do
      {:ok, res = %GameSchema{}} -> res
      {_, _err} -> nil
    end
  end
end
