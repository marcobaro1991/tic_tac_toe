defmodule TicTacToe.Graphql.Plug.Context do
  @moduledoc """
  Conn utility functions
  """

  alias TicTacToe.Graphql.Plug.Helper

  alias Noether.Either
  alias TicTacToe.Token

  @behaviour Plug

  @jwt_sign Application.compile_env!(:tic_tac_toe, :jwt)[:sign]

  @type user_context :: %{
          current_user: map() | nil,
          authorization_token: String.t() | nil
        }

  def init(opts), do: opts

  def call(conn, _) do
    context = conn |> get_authorization_token() |> get_user_from_token()

    Absinthe.Plug.put_options(conn, context: context)
  end

  defp get_authorization_token(conn) do
    conn
    |> Helper.get_header("authorization")
    |> case do
      "Bearer " <> token -> token
      _ -> nil
    end
  end

  @spec get_user_from_token(String.t() | nil) :: user_context()
  defp get_user_from_token(nil), do: jwt_not_valid()

  defp get_user_from_token(token) do
    with signer <- Joken.Signer.create(@jwt_sign, "secret"),
         now <- DateTime.truncate(DateTime.utc_now(), :second),
         {:ok, %{"sub" => sub, "exp" => exp}} <- Token.verify_and_validate(token, signer),
         exp <- exp |> DateTime.from_unix() |> Either.unwrap(),
         :lt <- DateTime.compare(now, exp) do
      %{current_user: %{identifier: sub}, authorization_token: token}
    else
      _ -> jwt_not_valid()
    end
  end

  defp jwt_not_valid do
    %{current_user: nil, authorization_token: nil}
  end
end
