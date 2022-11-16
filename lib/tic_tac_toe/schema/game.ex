defmodule TicTacToe.Schema.Game do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @required_fields [:title, :identifier, :player_a, :player_b, :status]
  @optional_fields [:winner]

  schema "games" do
    field :title, :string
    field :identifier, :string
    field :player_a, :string
    field :player_b, :string
    field :status, Ecto.Enum, values: [:progress, :done]
    field :winner, :string
    timestamps()
  end

  def get_by_identifier(query, identifier) do
    from g in query,
      where: g.identifier == ^identifier
  end

  def update_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
