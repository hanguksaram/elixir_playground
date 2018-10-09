defmodule Test.PledgeController do
  def create(conv, %{"name" => name, "amount" => amount}) do

    Test.PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conv) do

    pledges = Test.PledgeServer.recent_pledges()

    %{ conv | status: 200, resp_body: (inspect pledges)}
  end


end
