defmodule TicTacToeWeb.Graphql.GameTest do
  use TicTacToeWeb.ConnCase

  @game_identifier_without_moves "4c347efa-eadf-4a04-b474-f0f252b86110"
  @game_identifier_with_moves "fdfe92f2-32a8-43c2-a0b2-73bff8efe020"
  @game_identifier_that_is_done "7aa88de7-f3c3-4b7a-8e20-78d87d66f45b"
  @game_identifier_with_no_winners "95e7ffc1-a198-45e5-8edb-4cbe57c3cbce"

  @game_query """
  query ($identifier: Uuid!) {
    game(identifier: $identifier) {
      title
      playerA
      playerB
      identifier
      status
      winner
      moves {
        player
        x
        y
      }
    }
  }
  """

  @game_query_without_moves """
  query ($identifier: Uuid!) {
    game(identifier: $identifier) {
      title
      playerA
      playerB
      status
      winner
    }
  }
  """

  @game_mutation """
  mutation ($game: InputGame!) {
    createGame(game: $game) {
      ... on CreateGameSuccess {
        game {
          title
          playerA
          playerB
          status
          winner
        }
      }
      ... on CreateGameFailure {
        error
      }
    }
  }
  """

  @move_mutation """
  mutation ($move: InputMove!) {
    createMove(move: $move) {
      ... on CreateMoveSuccess{
        playerHasWon
      }
      ... on CreateMoveFailure{
        error
        message
      }
    }
  }
  """

  test "query: get game success!", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @game_query,
        "variables" => %{"identifier" => @game_identifier_without_moves}
      })

    result_expected = %{
      "data" => %{
        "game" => %{
          "title" => "Partita del girone",
          "identifier" => @game_identifier_without_moves,
          "moves" => [],
          "playerA" => "Pippo",
          "playerB" => "Pluto",
          "status" => "PROGRESS",
          "winner" => nil
        }
      }
    }

    assert json_response(conn, 200) == result_expected
  end

  test "query: game not found, null result", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @game_query,
        "variables" => %{"identifier" => "4261d3ec-02a8-4307-80ac-bb2bcf0f4cfc"}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"game" => nil}
           }
  end

  test "mutation: create game success!", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @game_mutation,
        "variables" => %{
          "game" => %{
            "title" => "semifinale",
            "playerA" => "marco",
            "playerB" => "francesco"
          }
        }
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "createGame" => %{
                 "game" => %{
                   "playerA" => "marco",
                   "playerB" => "francesco",
                   "status" => "PROGRESS",
                   "title" => "semifinale",
                   "winner" => nil
                 }
               }
             }
           }
  end

  test "mutation: create move and user win! check also the game status and winner", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @move_mutation,
        "variables" => %{
          "move" => %{
            "gameIdentifier" => @game_identifier_with_moves,
            "player" => "Pluto",
            "x" => "B",
            "y" => "THREE"
          }
        }
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "createMove" => %{
                 "playerHasWon" => true
               }
             }
           }

    conn =
      post(conn, "/graphql", %{
        "query" => @game_query_without_moves,
        "variables" => %{"identifier" => @game_identifier_with_moves}
      })

    result_expected = %{
      "data" => %{
        "game" => %{
          "title" => "Partita della finale",
          "playerA" => "Pippo",
          "playerB" => "Pluto",
          "status" => "DONE",
          "winner" => "Pluto"
        }
      }
    }

    assert json_response(conn, 200) == result_expected
  end

  test "mutation: create move with wrong user user, error!", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @move_mutation,
        "variables" => %{
          "move" => %{
            "gameIdentifier" => @game_identifier_with_moves,
            "player" => "WrongUsername",
            "x" => "B",
            "y" => "THREE"
          }
        }
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "createMove" => %{
                 "error" => "WRONG_PLAYER",
                 "message" => "Wrong player!"
               }
             }
           }
  end

  test "mutation: create move on game that is done, error!", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @move_mutation,
        "variables" => %{
          "move" => %{
            "gameIdentifier" => @game_identifier_that_is_done,
            "player" => "Pippo",
            "x" => "B",
            "y" => "THREE"
          }
        }
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "createMove" => %{
                 "error" => "GAME_DONE",
                 "message" => "The game is close"
               }
             }
           }
  end

  test "mutation: create move on game that does not exist, error!", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @move_mutation,
        "variables" => %{
          "move" => %{
            "gameIdentifier" => "0e7f8461-9897-405b-a171-b2223f848342",
            "player" => "Pippo",
            "x" => "B",
            "y" => "THREE"
          }
        }
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "createMove" => %{
                 "error" => "GAME_NOT_FOUND",
                 "message" => "Game not found"
               }
             }
           }
  end

  test "mutation: create move on game that there will be not winners", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @move_mutation,
        "variables" => %{
          "move" => %{
            "gameIdentifier" => @game_identifier_with_no_winners,
            "player" => "Pluto",
            "x" => "A",
            "y" => "THREE"
          }
        }
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "createMove" => %{
                 "playerHasWon" => false
               }
             }
           }

    conn =
      post(conn, "/graphql", %{
        "query" => @game_query_without_moves,
        "variables" => %{"identifier" => @game_identifier_with_no_winners}
      })

    result_expected = %{
      "data" => %{
        "game" => %{
          "title" => "Partita con nessun vincitore",
          "playerA" => "Pippo",
          "playerB" => "Pluto",
          "status" => "DONE",
          "winner" => nil
        }
      }
    }

    assert json_response(conn, 200) == result_expected
  end
end
