defmodule Flatten do
    # 注意模式匹配的顺序哟！

    @doc """
    Flatten an arbitrarily nested lists

    ## Examples

        iex> Flatten.flatten [[1,2] ,[3] ,[4,5]]
        [1,2,3,4,5]
        iex> Flatten.flatten [1,2,3,4,5]
        [1,2,3,4,5]
    """
    def flatten([]), do: []
    def flatten([h|t]) when is_list(h), do: h ++ flatten(t)
    def flatten([h|t]), do: [h] ++ flatten(t)
end
