use "term"

actor PonyBench
  """
  Main test framework class that runs benchmarks and reports any errors.
  """
  let _env: Env

  new create(env: Env, list: BenchmarkList tag) =>
    _env = env
    list.benchmarks(this)

  be apply(bench: Benchmark iso) =>
    """
    Run the given benchmark and report any errors.
    """
    let runner = BenchmarkRunner._create(_env)
    let name = bench.name()
    try
      runner(consume bench)
    else
      let red = ANSI.red()
      let failed = "**** FAILED Benchmark: "
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
