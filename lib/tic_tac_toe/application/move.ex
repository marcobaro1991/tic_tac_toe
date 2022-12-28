defmodule TicTacToe.Application.Move do
  @moduledoc false
  alias TicTacToe.Repo
  alias TicTacToe.Schema.Move, as: MoveSchema
  alias TicTacToe.Schema.Game, as: GameSchema
  alias TicTacToe.Application.Game, as: GameApplication

  require Logger

  @winnable_combinations [
    ["a_three", "b_two", "c_one"],
    ["a_one", "b_two", "c_three"],
    ["c_one", "c_two", "c_three"],
    ["b_one", "b_two", "b_three"],
    ["a_one", "a_two", "a_three"],
    ["a_three", "b_three", "c_three"],
    ["a_two", "b_two", "c_two"],
    ["a_one", "b_one", "c_one"]
  ]

  @moves_per_game 9

  @spec get_by_game_and_position(integer(), atom(), atom()) :: MoveSchema.t() | nil
  def get_by_game_and_position(game_id, x, y) do
    MoveSchema
    |> MoveSchema.get_by_game_and_position(game_id, x, y)
    |> Repo.one()
  end

  @spec get_all_by_game_id(integer()) :: [MoveSchema.t()]
  def get_all_by_game_id(game_id) do
    MoveSchema
    |> MoveSchema.get_by_game_id(game_id)
    |> Repo.all()
  end

  @spec get_last_by_game_id(integer()) :: MoveSchema.t() | nil
  def get_last_by_game_id(game_id) do
    MoveSchema
    |> MoveSchema.get_last_by_game_id(game_id)
    |> Repo.one()
  end

  @spec get_all_by_game_id_and_player(integer(), String.t()) :: [MoveSchema.t()]
  def get_all_by_game_id_and_player(game_id, player) do
    MoveSchema
    |> MoveSchema.get_by_game_id_and_player(game_id, player)
    |> Repo.all()
  end

  @spec create(map()) ::
          %{player_has_won: boolean(), game_identifier: String.t()}
          | %{error: atom(), message: String.t()}
  def create(%{game_identifier: game_identifier, player: player, x: x, y: y}) do
    with game = %GameSchema{id: game_id, status: :progress} <-
           GameApplication.get_by_identifier(game_identifier),
         %{valid_player: true} <- valid_player(game, player),
         %{position_available: true} <- is_position_available(game_id, x, y),
         %MoveSchema{} <- save_move(game_id, player, x, y),
         %GameSchema{} = updated_game <-
           game_id |> no_more_available_moves?() |> update_game_status(game) do
      player
      |> player_has_won?(game_id)
      |> build_result(player, updated_game)
    else
      error -> parse_error(error, game_identifier, player, x, y)
    end
  end

  @spec valid_player(GameSchema.t(), String.t()) :: %{valid_player: boolean()}
  defp valid_player(game = %GameSchema{id: game_id}, player) do
    %{
      valid_player:
        player_exist_in_game(game, player) &&
          player_can_move(player, get_last_by_game_id(game_id))
    }
  end

  @spec player_exist_in_game(GameSchema.t(), String.t()) :: boolean()
  defp player_exist_in_game(_game = %GameSchema{player_a: player_a, player_b: player_b}, player) do
    player_a == player || player_b == player
  end

  @spec player_can_move(String.t(), String.t() | nil) :: boolean()
  defp player_can_move(_player, nil) do
    true
  end

  defp player_can_move(player, _last_move = %MoveSchema{player: last_player_that_move}) do
    player != last_player_that_move
  end

  @spec is_position_available(integer(), atom(), atom()) :: %{position_available: boolean()}
  defp is_position_available(game_id, x, y) do
    game_id
    |> get_by_game_and_position(x, y)
    |> case do
      %MoveSchema{} -> %{position_available: false}
      _ -> %{position_available: true}
    end
  end

  @spec no_more_available_moves?(integer()) :: boolean()
  defp no_more_available_moves?(game_id) do
    game_id
    |> get_all_by_game_id()
    |> Enum.count()
    |> case do
      @moves_per_game -> true
      _ -> false
    end
  end

  @spec update_game_status(boolean(), GameSchema.t()) :: GameSchema.t() | %{error: atom()}
  defp update_game_status(_no_more_available_moves = true, game) do
    game
    |> GameApplication.update(%{status: :done})
    |> case do
      %GameSchema{} = game -> game
      _ -> %{error: :cant_update_status}
    end
  end

  defp update_game_status(_, game) do
    game
  end

  @spec save_move(integer(), String.t(), atom(), atom()) :: MoveSchema.t() | %{error: atom()}
  defp save_move(game_id, player, x, y) do
    %MoveSchema{
      identifier: UUID.string_to_binary!(UUID.uuid4()),
      game_id: game_id,
      player: String.trim(player),
      x: x,
      y: y
    }
    |> Repo.insert()
    |> case do
      {:ok, res = %MoveSchema{}} -> res
      {:ok, _err} -> %{error: :move_not_saved}
    end
  end

  @spec player_has_won?(String.t(), integer()) :: boolean()
  defp player_has_won?(player, game_id) do
    player_moves =
      game_id
      |> get_all_by_game_id_and_player(player)
      |> Enum.map(fn _move = %{x: x, y: y} ->
        Atom.to_string(x) <> "_" <> Atom.to_string(y)
      end)

    Enum.any?(@winnable_combinations, fn winnable_combination ->
      combination_found(winnable_combination, player_moves)
    end)
  end

  @spec combination_found(list(), list()) :: boolean()
  defp combination_found(winnable_combination, player_moves) do
    Enum.all?(winnable_combination, fn winnable_position ->
      nil !=
        Enum.find(player_moves, fn player_position ->
          player_position == winnable_position
        end)
    end)
  end

  @spec build_result(boolean(), String.t(), GameSchema.t()) ::
          %{player_has_won: boolean(), game_identifier: String.t()}
          | %{error: atom(), message: String.t()}
  defp build_result(_player_has_won? = true, player, game) do
    game
    |> GameApplication.update(%{status: :done, winner: player})
    |> case do
      %GameSchema{} -> %{player_has_won: true, game_identifier: Map.get(game, :identifier)}
      _ -> %{error: :cant_update_winner_and_game_status, message: "Cant update the game status"}
    end
  end

  defp build_result(_, _player, game) do
    %{player_has_won: false, game_identifier: Map.get(game, :identifier)}
  end

  @spec parse_error(any(), String.t(), String.t(), atom(), atom()) :: %{
          error: atom(),
          message: String.t()
        }
  defp parse_error(%GameSchema{status: :done}, game_identifier, _player, _x, _y) do
    Logger.error("game #{game_identifier} status done")
    %{error: :game_done, message: "The game is close"}
  end

  defp parse_error(nil, game_identifier, _player, _x, _y) do
    Logger.error("game #{game_identifier} not found")
    %{error: :game_not_found, message: "Game not found"}
  end

  defp parse_error(%{valid_player: false}, game_identifier, player, _x, _y) do
    Logger.error("wrong player #{player} for game #{game_identifier}")
    %{error: :wrong_player, message: "Wrong player!"}
  end

  defp parse_error(%{position_available: false}, game_identifier, _player, x, y) do
    Logger.error(
      "wrong position for game #{game_identifier}, you cant move in X:#{x}, Y:#{y}! position is already used"
    )

    %{
      error: :wrong_position,
      message: "Wrong position, you cant move here!, position is already used"
    }
  end

  defp parse_error(%{error: :move_not_saved}, game_identifier, _player, _x, _y) do
    Logger.error("Cannot save move in db on game #{game_identifier}")
    %{error: :move_not_saved, message: "Cannot save move in db"}
  end

  defp parse_error(%{error: :cant_update_status}, game_identifier, _player, _x, _y) do
    Logger.error("Cannot update game status for game #{game_identifier}")
    %{error: :cant_update_status, message: "Cannot update game status for game"}
  end

  defp parse_error(error, _game_identifier, _player, _x, _y) do
    Logger.error("generic error #{inspect(error)}")
    %{error: :unknown, message: "unknown"}
  end
end
