use "collections"
use "time"
use "debug"

actor Main
  new create(env: Env) =>
    var x: USize = 0
    var start = Time.nanos()
    for i in Range[USize](0, 1_000_000) do
      x = Fib(5)
      Debug.out(x)
    end
    env.out.print(((Time.nanos() - start) / 1_000_000).string() + " ns/op")

    start = Time.nanos()
    for i in Range[USize](0, 1_000_000) do
      DoNotOptimise[USize](x)
      x = Fib(5)
      DoNotOptimise.observe()
    end
    env.out.print(((Time.nanos() - start) / 1_000_000).string() + " ns/op")

primitive Fib
  fun apply(n: USize): USize =>
    if n < 2 then
      n
    else
      apply(n-1) + apply(n-2)
    end
