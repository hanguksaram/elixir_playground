defmodule Test.GenericServer do

  def start(initial_state, name) do

    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = Test.PledgeServer.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state)
      {:cast, message }  ->
        new_state = Test.PledgeServer.handle_cast(message, state)
        listen_loop(new_state)
      unexpected ->
        IO.puts "Unexpected messaged: #{inspect unexpected}"
        listen_loop(state)
    end
  end
end


defmodule Test.PledgeServer do

  #client interface
  @name :pledge_server

  alias Test.GenericServer


  def start do
    IO.puts "Starting the pledge server"
    GenericServer.start([], @name)
  end
  def create_pledge(name, amount) do
    GenericServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    GenericServer.call @name, :recent_pledges

  end

  def total_pledged do
    GenericServer.call @name, :total_pledged
  end

  def clear do
    GenericServer.cast @name, :clear
  end

  #Helper Functions



  # Server



  def handle_cast(:clear, _state) do
    []
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}

  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end
  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {total, state}
  end


  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Test.PledgeServer

pid = PledgeServer.start()



PledgeServer.create_pledge("moe", 20)
 PledgeServer.create_pledge("moe", 20)
 PledgeServer.create_pledge("moe", 20)
 PledgeServer.create_pledge("moe", 20)
 PledgeServer.create_pledge("moe", 20)
 PledgeServer.clear()
 PledgeServer.recent_pledges()
IO.inspect PledgeServer.total_pledged()
