module Mixins

export @use_mixins, @define_mixin

using MacroTools: prewalk, @capture
using MLStyle: @match

macro use_mixins(code)
  mixins = Symbol[]
  stripped_code = prewalk(code) do exp
    @match exp begin
      Expr(args...) => begin
        for arg in args
          @match arg begin
            Expr(:macrocall, macroargs...) => begin
              if macroargs[1] == Symbol("@mixin")
                push!(mixins, macroargs[3])
              end
            end
            _ => ()
          end
        end
        exp
      end
      _ => exp
    end
  end
  unique!(mixins)
  @match mixins begin
    [] => esc(stripped_code)
    [m,rest...] => esc(Expr(:macrocall, Symbol("@" * string(m)), nothing, [], copy(rest), stripped_code))
  end
end

macro expand_mixins(mixin_defs, code)
  mixin_defs = Dict(mixin_defs...)
  unescaped = prewalk(code) do exp
    @match exp begin
      Expr(head, args...) => begin
        newargs = map(args) do arg
          @match arg begin
            Expr(:macrocall, macroargs...) => begin
              if macroargs[1] == Symbol("@mixin")
                mixin_defs[macroargs[3]]
              end
            end
            _ => [arg]
          end
        end
        Expr(head, vcat(newargs...)...)
      end
      _ => exp
    end
  end
  esc(unescaped)
end

function shift_mixins(newdef,defs,remaining,code)
  newdefs = [defs...;newdef]
  if length(remaining) == 0
    Expr(:macrocall, GlobalRef(Mixins, Symbol("@expand_mixins")), nothing, newdefs, code)
  else
    m,rest... = remaining
    Expr(:macrocall, Symbol("@"*string(m)), nothing, newdefs, copy(rest), code)
  end |> esc
end

macro define_mixin(name, block)
  newdef = name => copy(block.args)
  :(macro $(esc(name))(defs, remaining, code)
      $(GlobalRef(Mixins,:shift_mixins))($newdef, defs, remaining, code)
    end)
end

end # module
