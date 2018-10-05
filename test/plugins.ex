defmodule Test.Plugins do

  alias Test.Conv
  def track(%Conv{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  def track(%Conv{} = conv), do: conv
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end
  def rewrite_path(%Conv{} = conv), do: conv
  def log(%Conv{} = conv), do: IO.inspect conv
  def trimPath(%Conv{} = conv), do: %{conv | path: String.trim(conv.path)}

end
