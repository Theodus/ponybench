use "collections"

actor Main is BenchmarkList

  new create(env: Env) =>
    PonyBench(env, this)

  fun tag benchmarks(bench: PonyBench) =>
    bench(_BenchmarkFib5)
    bench(_BenchmarkFib10)
    bench(_BenchmarkFib20)
    bench(_BenchmarkFib40)
    bench(_BenchmarkFibFail)
    bench(_BenchmarkAdd)
    bench(_BenchmarkSub)

class iso _BenchmarkFib5 is Benchmark
  fun name(): String => "Fib5"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(5))
    end

class iso _BenchmarkFib10 is Benchmark
  fun name(): String => "Fib10"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(10))
    end

class iso _BenchmarkFib20 is Benchmark
  fun name(): String => "Fib20"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(20))
    end

class iso _BenchmarkFib40 is Benchmark
  fun name(): String => "Fib40"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(40))
    end

class iso _BenchmarkFibFail is Benchmark
  fun name(): String => "FibFail"

  fun apply(b: BenchmarkRunner) ? =>
    for i in Range[USize](0, b.n()) do
      b.discard(Fib(25))
    end
    error

class iso _BenchmarkAdd is Benchmark
  fun name(): String => "addition"

  fun apply(b: BenchmarkRunner) =>
    let n1: USize = 2
    let n2: USize = 2
    for i in Range[USize](0, b.n()) do
      b.discard(n1 + n2)
    end

class iso _BenchmarkSub is Benchmark
  fun name(): String => "subtraction"

  fun apply(b: BenchmarkRunner) =>
    let n1: USize = 4
    let n2: USize = 2
    for i in Range[USize](0, b.n()) do
      b.discard(n1 - n2)
    end

primitive Fib
  fun apply(n: USize): USize =>
    match n
    | 0 => 0
    | 1 => 1
    else
      apply(n-1) + apply(n-2)
    end
