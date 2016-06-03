use "term"

class PonyBench
  """
  Main test framework class that runs benchmarks and reports any errors.
  """
  let _env: Env

  new create(env: Env, list: BenchmarkList) =>
    _env = env
    list.benchmarks(this)

  fun apply(bench: Benchmark) =>
    """
    Run the given benchmark and report any errors.
    """
    let runner = BenchmarkRunner._create(_env)
    try
      runner(bench)
    else
      let red = ANSI.red()
      let failed = "**** FAILED Benchmark: "
      let name = bench.name()
      let reset = ANSI.reset()
      let str = recover
        String(red.size() + failed.size() + name.size() + reset.size())
      end
      str.append(red)
      str.append(failed)
      str.append(name)
      str.append(reset)
      _env.out.print(consume str)
    end
