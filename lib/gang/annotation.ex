defmodule Gang.Annotation do

  defmacro __using__(_opts) do
    quote do
      import Gang.Annotation

      Module.register_attribute(__MODULE__, :gang_funs, accumulate: true, persist: false)

      @on_definition {Gang.Annotation, :on_definition}
      @before_compile {Gang.Annotation, :before_compile}
    end
  end

  defmacro gang_module(opts) do
    quote location: :keep do
      Module.register_attribute(__MODULE__, :gang_default_mod, accumulate: false , persist: false)
      Module.put_attribute(__MODULE__, :gang_default_mod, unquote(opts))
    end
  end

  def on_definition(env, kind, name, args, guards, _body) do
    gang_opts = Module.get_attribute(env.module, :gang) || :no_gang

    unless gang_opts == :no_gang do

      gang_module  = Keyword.get(gang_opts, :mod) || Module.get_attribute(env.module, :gang_default_mod) || raise ArgumentError, "shoude set default module with gang_module/1 macro or in @gang :mod"
      gang_opts = Keyword.put(gang_opts, :mod, gang_module)

      Module.put_attribute(env.module, :gang_funs, %{
        kind: kind,
        name: name,
        args: Enum.map(args, &de_underscore_name/1),
        guards: guards,
        gang_opts: gang_opts
      })

      Module.delete_attribute(env.module, :gang)
    end
  end

  defmacro before_compile(env) do
    gang_funs = Module.get_attribute(env.module, :gang_funs, [])
    Module.delete_attribute(env.module, :gang_funs)

    # IO.inspect(gang_funs, label: "GANG")
    override_list =
      gang_funs
      |> Enum.map(&gen_override_list/1)
      |> List.flatten()

    overrides =
      quote location: :keep do
        defoverridable unquote(override_list)
      end

    functions =
      Enum.map(gang_funs, fn fun ->
        body = gen_body(fun)
        gen_function(fun, body)
      end)

    [overrides | functions]
  end

  defp gen_override_list(%{name: name, args: args}) do
    no_default_args_length =
      Enum.reduce(args, 0, fn
        {:\\, _, _}, acc -> acc
        _, acc -> acc + 1
      end)

    Enum.map(no_default_args_length..length(args), fn i -> {name, i} end)
  end

  defp gen_function(%{kind: :def, guards: [], name: name, args: args}, body) do
    quote location: :keep do
      def unquote(name)(unquote_splicing(args)) do
        unquote(body)
      end
    end
  end

  defp gen_function(%{kind: :def, guards: guards, name: name, args: args}, body) do
    quote location: :keep do
      def unquote(name)(unquote_splicing(args)) when unquote_splicing(guards) do
        unquote(body)
      end
    end
  end

  defp gen_function(%{kind: :defp, guards: [], name: name, args: args}, body) do
    quote location: :keep do
      defp unquote(name)(unquote_splicing(args)) do
        unquote(body)
      end
    end
  end

  defp gen_function(%{kind: :defp, guards: guards, name: name, args: args}, body) do
    quote location: :keep do
      defp unquote(name)(unquote_splicing(args)) when unquote_splicing(guards) do
        unquote(body)
      end
    end
  end

  defp gen_body(%{args: args, gang_opts: gang_opts} = _fun) do
    args =
      Enum.map(args, fn
        {:\\, _, [arg_name | _]} -> arg_name
        arg -> arg
      end)

    gang_mod = Keyword.get(gang_opts, :mod) || raise ArgumentError, ":mod does not set"
    gang_type = Keyword.get(gang_opts, :type) || raise ArgumentError, ":type does not set"
    gang_opts = Keyword.get(gang_opts, :opts) || raise ArgumentError, ":opts does not set"

    quote location: :keep do
      case unquote(gang_mod).call(unquote(gang_type), unquote(args), unquote(gang_opts)) do
        :ok -> super(unquote_splicing(args))
        # TODO now just accept functions with exactly 2 input param.
        # make dynamic param count.
        {:ok, [param0, param1] = _new_args} -> super(param0, param1)
        {:error, reason} -> reason
        e -> e
      end
    end
  end

  defp de_underscore_name({:\\, context, [{name, name_context, name_args} | t]} = arg) do
    case to_string(name) do
      "_" <> real_name ->
        {:\\, context, [{String.to_atom(real_name), name_context, name_args} | t]}

      _ ->
        arg
    end
  end

  defp de_underscore_name({name, context, args} = arg) do
    case to_string(name) do
      "_" <> real_name -> {String.to_atom(real_name), context, args}
      _ -> arg
    end
  end

end
