defmodule Ruff.ChannelMonitor do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stop do
    Agent.stop(__MODULE__)
  end

  def get_leader(channel_id) do
    Agent.get(__MODULE__, &(&1[channel_id][:leader]))
  end

  def set_leader(channel_id, user_id) do
    Agent.get_and_update(__MODULE__, fn state ->
      new_state = state
        |> Map.put_new_lazy(channel_id, &create_channel/0)
        |> put_in([channel_id, :leader], user_id)
      {new_state[channel_id], new_state}
    end)
  end

  def get_users(channel_id) do
    Agent.get(__MODULE__, &(&1[channel_id][:users] || %{}))
  end

  def add_user(channel_id, key, user) do
    Agent.get_and_update(__MODULE__, fn state ->
      new_state = state
        |> Map.put_new_lazy(channel_id, &create_channel/0)
        |> put_in([channel_id, :users, key], user)
      {new_state[channel_id], new_state}
    end)
  end

  def remove_user(channel_id, key) do
    Agent.get_and_update(__MODULE__, fn state ->
      {_user, new_state} = state
        |> Map.put_new_lazy(channel_id, &create_channel/0)
        |> pop_in([channel_id, :users, key])
      {new_state[channel_id], new_state}
    end)
  end

  defp create_channel do
    %{leader: nil, users: %{}}
  end
end
