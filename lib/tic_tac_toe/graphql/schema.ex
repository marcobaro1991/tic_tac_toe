defmodule TicTacToe.Graphql.Schema do
  @moduledoc false

  use Absinthe.Schema

  import_types(TicTacToe.Graphql.Types.Custom.Uuid)
  import_types(TicTacToe.Graphql.Types.Custom.Date)
  import_types(TicTacToe.Graphql.Types.Game)
  import_types(TicTacToe.Graphql.Types.Move)

  def context(context) do
    loader = Dataloader.new()

    Map.put(context, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  query do
    import_fields(:game_queries)
  end

  mutation do
    import_fields(:game_mutations)
    import_fields(:move_mutations)
  end
end
