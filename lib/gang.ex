defmodule Gang do

  @callback call(atom(), list(any()), keyword()) :: {:ok, list(any())} | :ok | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      import Gang

      @behaviour Gang
    end
  end

end
