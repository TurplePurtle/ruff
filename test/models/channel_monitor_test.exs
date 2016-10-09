defmodule Ruff.ChannelMonitorTest do
  use ExUnit.Case

  alias Ruff.ChannelMonitor, as: CM

  test "stores channel users" do
    channel_id = "42"
    user1 = %{id: 1, username: "Bill"}
    user2 = %{id: 2, username: "Bob"}

    CM.start_link
    assert Enum.empty? CM.get_users(channel_id)
    CM.add_user(channel_id, user1.id, user1)
    assert CM.get_users(channel_id)[user1.id] == user1
    refute CM.get_users(channel_id)[user2.id] == user2
    CM.add_user(channel_id, user2.id, user2)
    assert CM.get_users(channel_id)[user1.id] == user1
    assert CM.get_users(channel_id)[user2.id] == user2
    CM.remove_user(channel_id, user1.id)
    refute CM.get_users(channel_id)[user1.id] == user1
    assert CM.get_users(channel_id)[user2.id] == user2
    CM.remove_user(channel_id, user2.id)
    assert Enum.empty? CM.get_users(channel_id)
    CM.stop
  end

  test "stores channel leader" do
    channel_id = "42"
    leader_id = 1

    CM.start_link
    assert CM.get_leader(channel_id) == nil
    CM.set_leader(channel_id, leader_id)
    assert CM.get_leader(channel_id) == leader_id
    CM.stop
  end
end
