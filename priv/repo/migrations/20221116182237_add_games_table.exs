defmodule TicTacToe.Repo.Migrations.AddGamesTable do
  use Ecto.Migration

  @game_status_type :game_status

  def change do
    execute(
      """
        CREATE TYPE #{@game_status_type}
        AS ENUM ('progress','done')
      """,
      "drop TYPE #{@game_status_type}"
    )

    create table(:games) do
      add(:identifier, :uuid, null: false)
      add(:title, :string, null: false)
      add(:player_a, :string, null: false)
      add(:player_b, :string, null: false)
      add(:status, @game_status_type, null: false)
      add(:winner, :string, null: true)
      timestamps(default: fragment("NOW()"))
    end
  end

  def down do
    drop(table(:games))
  end
end
