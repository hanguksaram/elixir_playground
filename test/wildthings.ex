defmodule Test.Wildthings do
  alias Test.Bear
  def list_bears do
    [
    %Bear{id: 1, name: "teddy", type: "Brown", hibernating: true},
    %Bear{id: 2, name: "petya", type: "White"}
    ]
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear
  end

end
