# Gang

A package developed in Elixir for code organization and preventing code repetition in specific development scenarios.

## Installation

Add `gang` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gang, "~> 0.1.0"}
  ]
end
```

## Documentation

Check out the [API reference](https://hexdocs.pm/gang) for the latest documentation.


## Usage

```elixir
defmodule Project.MyModule do
  use Gang.Annotation

  gang_module Project.MyGang

  @gang type: :test, opts: [with: [roles: [:super_admin]]]
  def test_func(param0, param1) do

    IO.inspect(param0, label: "param0")
    IO.inspect(param1, label: "param1")

    :ok
  end
end

defmodule Project.MyGang do
  use Gang

  @impl true
  def call(:test, [param0, param1] = _inputs, opts) do

    # if returns :ok `test_func/2' will call with parames.
    :ok

    # if returns {:ok, `list of params`} test_func/2' will call with new parames.
    {:ok, [param0, param1]}

    # if returns {:error, `reason`} test_func/2' will return `reason`.
    {:error, {:error, :unauthorize}}
  end

end

```
