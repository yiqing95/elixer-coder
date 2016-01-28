defmodule LineSigil do
    @doc """
        Implement the `~l` sigil, wich takes a string containing
        multiple lines and return a list of those lines .
        ## Exaple usage
        iex> import LineSigil
        nil
        iex> ~l'''
        ...>  one
        ...>  two
        ...>  three
        ...>  '''
        ["one","two","three"]
    """
    def sigil_l(lines, _opts) do
        lines |> String.rstrip |> String.split("\n")
    end
end

defmodule Example do
    import LineSigil
    def lines do
        ~l"""
        line 1
        line 2
        and another line in #{__MODULE__}
        """
    end
end

IO.inspect  Example.lines