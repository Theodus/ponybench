use "collections"

use "debug"

actor Main is BenchmarkList

  new create(env: Env) =>
    PonyBench(env, this)

  fun tag benchmarks(bench: PonyBench) =>
    bench(_BenchmarkFib5)
    bench(_BenchmarkFib10)
    bench(_BenchmarkFib20)
    //bench(_BenchmarkFib40)
    //bench(_BenchmarkFibFail)
    //bench(_BenchmarkAdd)
    //bench(_BenchmarkSub)

class iso _BenchmarkFib5 is Benchmark
  fun name(): String => "Fib5"

  fun apply(b: BenchmarkRunner) =>
    var x: USize = 0
    for i in Range[USize](0, b.n()) do
      x = Fib(5)
      Debug.out(x)
    end

class iso _BenchmarkFib10 is Benchmark
  fun name(): String => "Fib10"

  fun apply(b: BenchmarkRunner) =>
    var x: USize = 0
    for i in Range[USize](0, b.n()) do
      DoNotOptimise[USize](x)
      x = Fib(10)
      DoNotOptimise.observe()
    end

class iso _BenchmarkFib20 is Benchmark
  fun name(): String => "Fib20"

  fun apply(b: BenchmarkRunner) =>
    var x: USize = 0
    DoNotOptimise[USize](x)
    for i in Range[USize](0, b.n()) do
      x = Fib(20)
      DoNotOptimise.observe()
    end

class iso _BenchmarkFib40 is Benchmark
  fun name(): String => "Fib40"

  fun apply(b: BenchmarkRunner) =>
    for i in Range[USize](0, b.n()) do
      DoNotOptimise[USize](Fib(40))
    end

class iso _BenchmarkFibFail is Benchmark
  fun name(): String => "FibFail"

  fun apply(b: BenchmarkRunner) ? =>
    var x: USize = 0
    for i in Range[USize](0, b.n()) do
      DoNotOptimise[USize](x)
      x = Fib(25)
      DoNotOptimise.observe()
    end
    error

class iso _BenchmarkAdd is Benchmark
  fun name(): String => "add"

  fun apply(b: BenchmarkRunner) =>
    let n1: USize = 2
    let n2: USize = 2
    for i in Range[USize](0, b.n()) do
      DoNotOptimise[USize](n1 + n2)
    end

class iso _BenchmarkSub is Benchmark
  fun name(): String => "sub"

  fun apply(b: BenchmarkRunner) =>
    let n1: USize = 4
    let n2: USize = 2
    for i in Range[USize](0, b.n()) do
      DoNotOptimise[USize](n1 - n2)
    end

primitive Fib
  fun apply(n: USize): USize =>
    if n < 2 then
      n
    else
      apply(n-1) + apply(n-2)
    end
