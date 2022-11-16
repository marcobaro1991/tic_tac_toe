# TicTacToe Graphlql Api

## Run the webserver that expose graphql api through the docker container:
```
docker-compose down && docker-compose run --service-ports api bash
mix local.hex --force
mix deps.get
mix local.rebar --force
mix ecto.reset
mix test
mix s

```
The application can generate the schema exposed by:
```
mix sdl
```

## Graphql curl example:
-  get game data:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Content-Type: application/json' \
  --data '{"query":"query ($identifier: Uuid!) {\n\tgame(identifier: $identifier) {\n\t\ttitle\n\t\tplayerA\n\t\tplayerB\n\t\tidentifier\n\t\tinsertedAt\n\t\tstatus\n\t\twinner\n\t\tmoves {\n\t\t\tinsertedAt\n\t\t\tidentifier\n\t\t\tplayer\n\t\t\tx\n\t\t\ty\n\t\t}\n\t}\n}\n","variables":{"identifier":"98b87dc3-44c4-4913-a11d-98672842a95d"}}'
```

- create a game:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation ($game: InputGame!) {\n\tcreateGame(game: $game) {\n\t\t... on CreateGameSuccess {\n\t\t\tgame {\n\t\t\t\ttitle\n\t\t\t\tplayerA\n\t\t\t\tplayerB\n\t\t\t\tidentifier\n\t\t\t\tinsertedAt\n\t\t\t\tstatus\n\t\t\t\twinner\n\t\t\t\tmoves {\n\t\t\t\t\tinsertedAt\n\t\t\t\t\tidentifier\n\t\t\t\t\tplayer\n\t\t\t\t\tx\n\t\t\t\t\ty\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\t\t... on CreateGameFailure {\n\t\t\terror\n\t\t}\n\t}\n}\n","variables":{"game":{"title":"semifinale","playerA":"marco","playerB":"francesco"}}}'
```

- make a move:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation ($move: InputMove!) {\n\tcreateMove(move: $move) {\n\t\t__typename\n\t\t... on CreateMoveSuccess {\n\t\t\tplayerHasWon\n\t\t}\n\n\t\t... on CreateMoveFailure {\n\t\t\terror\n\t\t\tmessage\n\t\t}\n\t}\n}\n","variables":{"move":{"gameIdentifier":"71f1dc41-951d-45f0-b758-ebb2eb6fdf8e","player":"marco","x":"A","y":"THREE"}}}'
```