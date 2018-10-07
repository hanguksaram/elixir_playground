defmodule Test.PledgeServer do

  def start do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [[]])
  end

  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send sender, {:response, id}
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
    end
  end

  def create_pledge(pid, name, amount) do
    send pid, {self(), :create_pledge, name, amount}

    receive do {:response, status} -> status end
  end

  def recent_pledges(pid) do
    send pid, {self(), :recent_pledges}

    receive do {:response, pledges} -> pledges end

  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Test.PledgeServer

pid = PledgeServer.start()
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.recent_pledges(pid)
