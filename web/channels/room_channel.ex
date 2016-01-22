defmodule Ruff.RoomChannel do
  use Phoenix.Channel

  # Join

  def join("rooms:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  # Handle in

  def handle_in("new_msg", %{"body" => body}, %{assigns: %{user: user}} = socket)
  when user != nil do
    msg = %{body: body} |> set_user_fields(user)
    broadcast! socket, "new_msg", msg
    {:noreply, socket}
  end

  def handle_in("video_state", payload, %{assigns: %{user: user}} = socket)
  when user != nil do
    msg = payload |> set_user_fields(user)
    broadcast! socket, "video_state", msg
    {:noreply, socket}
  end

  def handle_in(_, _, socket), do: {:noreply, socket}

  # Handle out

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  # Helpers

  defp set_user_fields(msg, nil), do: msg
  defp set_user_fields(msg, user) do
    Map.merge(msg, %{userId: user.id, username: user.username})
  end
end
