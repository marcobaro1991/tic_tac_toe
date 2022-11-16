alias TicTacToe.Repo, as: Repo

alias TicTacToe.Schema.{
  Game,
  Move
}

first_player = "Pippo"
second_player = "Pluto"

games = [
  %{
    title: "Partita del girone",
    identifier: UUID.string_to_binary!("4c347efa-eadf-4a04-b474-f0f252b86110"),
    player_a: first_player,
    player_b: second_player,
    status: :progress,
    winner: nil
  },
  %{
    title: "Partita della finale",
    identifier: UUID.string_to_binary!("fdfe92f2-32a8-43c2-a0b2-73bff8efe020"),
    player_a: first_player,
    player_b: second_player,
    status: :progress,
    winner: nil
  },
  %{
    title: "Partita di un girone",
    identifier: UUID.string_to_binary!("7aa88de7-f3c3-4b7a-8e20-78d87d66f45b"),
    player_a: first_player,
    player_b: second_player,
    status: :done,
    winner: nil
  },
  %{
    title: "Partita test",
    identifier: UUID.string_to_binary!("59c20534-96a1-4833-bc4c-f26bec42a1b7"),
    player_a: first_player,
    player_b: second_player,
    status: :progress,
    winner: nil
  },
  %{
    title: "Partita con nessun vincitore",
    identifier: UUID.string_to_binary!("95e7ffc1-a198-45e5-8edb-4cbe57c3cbce"),
    player_a: first_player,
    player_b: second_player,
    status: :progress,
    winner: nil
  }
]

moves = [
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 2,
    player: first_player,
    x: :a,
    y: :one
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 2,
    player: second_player,
    x: :b,
    y: :one
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 2,
    player: first_player,
    x: :a,
    y: :two
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 2,
    player: second_player,
    x: :b,
    y: :two
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: first_player,
    x: :a,
    y: :one
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: second_player,
    x: :b,
    y: :one
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: first_player,
    x: :c,
    y: :one
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: second_player,
    x: :b,
    y: :two
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: first_player,
    x: :b,
    y: :three
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: second_player,
    x: :a,
    y: :two
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: first_player,
    x: :c,
    y: :two
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    game_id: 5,
    player: second_player,
    x: :c,
    y: :three
  }
]

Repo.insert_all(Game, games)
Repo.insert_all(Move, moves)
