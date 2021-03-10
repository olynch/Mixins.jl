module TestMixins
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

end
