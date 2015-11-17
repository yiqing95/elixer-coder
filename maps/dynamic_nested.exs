nested = %{
   buttercup: %{

        actor: %{
             first: "Robin",
            first: "Wright",
        },
        role: "princess"
        },
        westly: %{
            actor: %{
                first: "Carey" ,
                last: "Ewes" # typo!
            },
            role: "farm boy" ,
        }
}

# IO.inspect nested

IO.inspect get_in(nested, [:buttercup])

IO.inspect get_in( nested, [:buttercup, :actor])