use "collections"

actor Main is BenchmarkList

  new create(env: Env) =>
    PonyBench(env, this)

  fun benchmarks(bench: PonyBench) =>
    bench(_BenchmarkFib5)
    bench(_BenchmarkFib10)
    bench(_BenchmarkFib20)
    bench(_BenchmarkFib40)
    bench(_BenchmarkFibFail)

class _BenchmarkFib5 is Benchmark
  fun name(): String => "Fib5"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(5))
    end

class _BenchmarkFib10 is Benchmark
  fun name(): String => "Fib10"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(10))
    end

class _BenchmarkFib20 is Benchmark
  fun name(): String => "Fib20"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(20))
    end

class _BenchmarkFib40 is Benchmark
  fun name(): String => "Fib40"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(40))
    end

class _BenchmarkFibFail is Benchmark
  fun name(): String => "FibFail"

  fun apply(b: BenchmarkRunner) ? =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(25))
    end
    error

primitive Fib
  fun apply(n: USize): USize =>
    match n
    | 0 => 0
    | 1 => 1
    else
      apply(n-1) + apply(n-2)
    end
