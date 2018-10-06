defmodule Test.Api.BearController do

  alias Test.Conv
  def index(%Conv{} = conv) do
    json =
      Test.Wildthings.list_bears()
      |> Poison.encode!

      IO.inspect(conv)
     %{ conv | status: 200, cont_type: "applicatiion/json", resp_body: json}
  end

end
