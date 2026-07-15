import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import gleamy/bench

pub fn table(results: bench.BenchResults) -> String {
  let bench.BenchResults(_options, sets) = results

  let grouped =
    sets
    |> list.group(fn(set) { set.input })
    |> dict.to_list

  let input_tables =
    list.map(grouped, fn(pair) {
      let #(input_label, input_sets) = pair
      let slowest_ips = slowest_mean_ips(input_sets)
      let header =
        pad_right("Function", 18)
        <> pad_left("IPS", 14)
        <> pad_left("Min", 12)
        <> pad_left("Mean", 12)
        <> pad_left("P99", 12)
        <> pad_left("Speedup", 10)

      let rows =
        input_sets
        |> list.map(fn(set) {
          let ips = calc_ips(set)
          let min = calc_min(set)
          let mean = calc_mean(set)
          let p99 = calc_p(set, 99)
          let speedup = calc_speedup(set, slowest_ips)

          pad_right(set.function, 18)
          <> pad_left(ips, 14)
          <> pad_left(min, 12)
          <> pad_left(mean, 12)
          <> pad_left(p99, 12)
          <> pad_left(speedup, 10)
        })
        |> string.join("\n")

      "Input: " <> input_label <> "\n" <> header <> "\n" <> rows
    })
    |> string.join("\n\n")

  let summary = build_summary(grouped)

  input_tables <> "\n\n" <> summary
}

fn slowest_mean_ips(sets: List(bench.Set)) -> Float {
  case sets {
    [] -> 0.0
    [first, ..rest] -> {
      let first_mean = calc_mean_float(first)
      list.fold(rest, first_mean, fn(acc, set) {
        let m = calc_mean_float(set)
        float.min(acc, m)
      })
    }
  }
}

fn calc_speedup(set: bench.Set, slowest_ips: Float) -> String {
  let mean = calc_mean_float(set)
  case mean >. 0.0 && slowest_ips >. 0.0 {
    True -> {
      let ratio = mean /. slowest_ips
      let rounded = int.to_float(float.round(ratio *. 10.0)) /. 10.0
      float.to_string(rounded) <> "x"
    }
    False -> "—"
  }
}

fn calc_mean_float(set: bench.Set) -> Float {
  case set.reps {
    [] -> 0.0
    reps -> {
      let total = list.fold(reps, 0.0, fn(acc, t) { acc +. t })
      let count = int.to_float(list.length(reps))
      total /. count
    }
  }
}

fn calc_ips(set: bench.Set) -> String {
  case set.reps {
    [] -> "0.0"
    reps -> {
      let total_ms = list.fold(reps, 0.0, fn(acc, t) { acc +. t })
      let count = int.to_float(list.length(reps))
      let mean_ms = total_ms /. count
      case mean_ms >. 0.0 {
        True -> {
          let ips = 1000.0 /. mean_ms
          let rounded = int.to_float(float.round(ips *. 10_000.0)) /. 10_000.0
          float.to_string(rounded)
        }
        False -> "0.0"
      }
    }
  }
}

fn calc_min(set: bench.Set) -> String {
  case set.reps {
    [] -> "0.0"
    reps -> {
      let min_ms =
        list.fold(reps, 999_999_999.0, fn(acc, t) { float.min(acc, t) })
      let rounded = int.to_float(float.round(min_ms *. 10_000.0)) /. 10_000.0
      float.to_string(rounded)
    }
  }
}

fn calc_mean(set: bench.Set) -> String {
  case set.reps {
    [] -> "0.0"
    reps -> {
      let total = list.fold(reps, 0.0, fn(acc, t) { acc +. t })
      let count = int.to_float(list.length(reps))
      let mean = total /. count
      let rounded = int.to_float(float.round(mean *. 10_000.0)) /. 10_000.0
      float.to_string(rounded)
    }
  }
}

fn calc_p(set: bench.Set, percentile: Int) -> String {
  case set.reps {
    [] -> "0.0"
    reps -> {
      let sorted = list.sort(reps, float.compare)
      let idx =
        int.to_float(list.length(sorted)) *. int.to_float(percentile) /. 100.0
        |> float.round

      case list.drop(sorted, idx) {
        [val, ..] -> {
          let rounded = int.to_float(float.round(val *. 10_000.0)) /. 10_000.0
          float.to_string(rounded)
        }
        [] -> "0.0"
      }
    }
  }
}

fn build_summary(grouped: List(#(String, List(bench.Set)))) -> String {
  let function_labels = case grouped {
    [first, ..] -> list.map(first.1, fn(set) { set.function })
    [] -> []
  }

  let col_width = 14

  let header =
    pad_right("Input", 20)
    <> list.map(function_labels, fn(label) { pad_left(label, col_width) })
    |> string.join("")

  let rows =
    list.map(grouped, fn(pair) {
      let #(input_label, sets) = pair
      let slowest_ips = slowest_mean_ips(sets)

      let speedups =
        list.map(sets, fn(set) {
          let mean = calc_mean_float(set)
          case mean >. 0.0 && slowest_ips >. 0.0 {
            True -> {
              let ratio = mean /. slowest_ips
              let rounded = int.to_float(float.round(ratio *. 10.0)) /. 10.0
              pad_left(float.to_string(rounded) <> "x", col_width)
            }
            False -> pad_left("—", col_width)
          }
        })
        |> string.join("")

      pad_right(input_label, 20) <> speedups
    })
    |> string.join("\n")

  "--- Speedup Summary (relative to slowest) ---\n" <> header <> "\n" <> rows
}

fn pad_right(s: String, width: Int) -> String {
  let len = string.length(s)
  case len >= width {
    True -> s
    False -> s <> string.repeat(" ", width - len)
  }
}

fn pad_left(s: String, width: Int) -> String {
  let len = string.length(s)
  case len >= width {
    True -> s
    False -> string.repeat(" ", width - len) <> s
  }
}
