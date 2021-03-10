# Mixins

The best way to understand this is by looking at the test file.

``` julia
using Test
using Mixins
using MLStyle: @match

@define_mixin f begin
  x::Int
  y::String
end

@define_mixin g begin
  z::Symbol
end

@use_mixins struct Cocktail
  @mixin(f)
  @mixin(g)
end

c = Cocktail(2,"gin",:tonic)
@test c.x == 2
@test c.y == "gin"
@test c.z == :tonic

macro modifyfields(structdef)
  modifieddef = @match structdef begin
    Expr(:struct, parent, name, body) => begin
      modifiedlines = map(body.args) do line
        @match line begin
          Expr(:(::), field, type) => :($(Symbol(string(field)*"prime")) :: $(type))
          _ => line
        end
      end
      Expr(:struct, parent, name, Expr(:block, modifiedlines...))
    end
    _ => error("expects a struct")
  end
  esc(modifieddef)
end
      
@use_mixins @modifyfields struct CocktailPrime
  @mixin(f)
  @mixin(g)
end

c = CocktailPrime(2,"gin",:tonic)
@test c.xprime == 2
@test c.yprime == "gin"
@test c.zprime == :tonic
```

If you aren't familiar with Julia, this shouldn't look that impressive, but it's actually a very clever (ab)use of the macro system. Normally a macro cannot expand into more than one AST node, and normally you cannot change the order of macro expansion; i.e. you cannot make an inner macro expand before an outer macro, as seen in

``` julia
@use_mixins @modifyfields struct CocktailPrime
  @mixin(f)
  @mixin(g)
end
```

