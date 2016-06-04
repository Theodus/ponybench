trait BenchmarkList
  """
  Source of benchmarks for a PonyBench object.
  """
  fun tag benchmarks(bench: PonyBench)
  """
  Add all the benchmarks to the given bench object.
  Typically the implementation of this function will be of the form:
  ```pony
  fun benchmarks(bench: PonyBench) =>
    bench(_BenchClass1)
    bench(_BenchClass2)
    bench(_BenchClass3)
  ```
  """

trait Benchmark
  """
  Each benchmark class must provide this trait.
  """
  fun name(): String
  """
  Report the benchmark name, which is used when printing benchmark results.
  """
  fun apply(b: BenchmarkRunner) ?
  """
  Run the benchmark. Raising an error is interpreted as a failure.
  """
