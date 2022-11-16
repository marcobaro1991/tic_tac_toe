defmodule TicTacToe.Repo.Migrations.AddMovesTable do
  use Ecto.Migration

  @move_x_type :move_x

  @move_y_type :move_y

  def change do
    execute(
      """
        CREATE TYPE #{@move_x_type}
        AS ENUM ('a','b', 'c')
      """,
      "drop TYPE #{@move_x_type}"
    )

    execute(
      """
        CREATE TYPE #{@move_y_type}
        AS ENUM ('one','two', 'three')
      """,
      "drop TYPE #{@move_y_type}"
    )

    create table(:moves) do
      add :identifier, :uuid, null: false
      add :game_id, references("games")
      add :player, :string, null: false
      add :x, @move_x_type, null: false
      add :y, @move_y_type, null: false

      timestamps(default: fragment("NOW()"))
    end
  end
end
