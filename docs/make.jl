using Mixins
using Documenter

DocMeta.setdocmeta!(Mixins, :DocTestSetup, :(using Mixins); recursive=true)

makedocs(;
    modules=[Mixins],
    authors="Owen Lynch <root@owenlynch.org> and contributors",
    repo="https://github.com/olynch/Mixins.jl/blob/{commit}{path}#{line}",
    sitename="Mixins.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
