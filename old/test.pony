
actor Main
  new create(env: Env) =>
    let bench = PonyBench(env)
    bench[USize]("fib 5", lambda(): USize => Fib(5) end)
    bench[USize]("fib 10", lambda(): USize => Fib(10) end)
    bench[USize]("fib 20", lambda(): USize => Fib(20) end)
    bench[USize]("fib 40", lambda(): USize => Fib(40) end)
    bench[String]("fail", lambda(): String ? => error end)
    bench[USize]("add", lambda(): USize => 1 + 2 end, 1_000_000)
    bench[USize]("sub", lambda(): USize => 2 - 1 end, 1_000_000)

primitive Fib
  fun apply(n: USize): USize =>
    if n < 2 then
      n
    else
      apply(n-1) + apply(n-2)
    end

primitive FibR
  fun apply(n: USize): USize =>
    _rec(n, 0, 1)

  fun _rec(n: USize, a: USize, b: USize): USize =>
    if n < 2 then
      return n
    end
    _rec(n-1, b, a+b)
