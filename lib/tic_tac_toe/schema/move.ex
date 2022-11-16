defmodule TicTacToe.Schema.Move do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  schema "moves" do
    field :identifier, :string
    field :game_id, :integer
    field :player, :string
    field :x, Ecto.Enum, values: [:a, :b, :c]
    field :y, Ecto.Enum, values: [:one, :two, :three]
    timestamps()
  end

  def get_by_game_id(query, game_id) do
    from m in query,
      where: m.game_id == ^game_id,
      select: [:identifier, :player, :x, :y, :inserted_at]
  end

  def get_last_by_game_id(query, game_id) do
    from m in query,
      where: m.game_id == ^game_id,
      order_by: [desc: :inserted_at],
      limit: 1,
      select: [:identifier, :player, :x, :y, :inserted_at]
  end

  def get_by_game_id_and_player(query, game_id, player) do
    from m in query,
      where: m.game_id == ^game_id and m.player == ^player,
      select: [:identifier, :player, :x, :y, :inserted_at]
  end

  def get_by_game_and_position(query, game_id, x, y) do
    from g in query,
      where: g.game_id == ^game_id and g.x == ^x and g.y == ^y,
      select: [:identifier, :player, :x, :y, :inserted_at]
  end
end
