use "collections"
use "time"
use "term"

actor PonyBench
  let _env: Env

  new create(env: Env) =>
    _env = env

  be apply[A: Any #share](name: String, f: {(): A ?} val, ops: U64 = 0) =>
    """
    Benchmark the given function by calling it repeatedly and calculating an
    average execution time.
    """
    try
      (let ops', let nspo) = if ops == 0 then
        _AutoBench[A](f)
      else
        @pony_triggergc[None](this)
        let start = Time.nanos()
        for i in Range[U64](0, ops) do
          DoNotOptimise[A](f())
        end
        let stop = Time.nanos()
        (ops, (stop - start) / ops)
      end

      let fmt = FormatSettingsInt.set_width(10)
      let sl = [name, "\t", ops'.string(fmt), "\t", nspo.string(fmt), " ns/op"]
      _env.out.print(String.join(sl))
    else
      let sl = [ANSI.red(), "**** FAILED Benchmark: ", name, ANSI.reset()]
      _env.out.print(String.join(sl))
    end
