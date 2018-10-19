defmodule Test.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts "Starting the services supervisor"
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Test.PledgeServer,
      {Test.SensorServer, 60}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
