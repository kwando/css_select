import css_select
import css_select/simple_matcher
import gleam/io
import gleeunit/should

pub fn selector_test() {
  {
    use run <- should("match tag")
    run(div([]), "div")
  }

  {
    use run <- should_not("match when tag is different")
    run(div([]), "p")
  }

  {
    use run <- should("match tag and class")
    run(div([#("class", "foo")]), "div.foo")
  }

  {
    use run <- should_not("not match class when tag doesnt match")
    run(div([#("class", "foo")]), "p.foo")
  }

  {
    use run <- should("match class")
    run(div([#("class", "foo")]), ".foo")
  }

  {
    use run <- should("match id")
    run(div([#("id", "foo")]), "#foo")
  }

  {
    use run <- should_not("match wrong id")
    run(div([#("id", "foo")]), "#bar")
  }

  {
    use run <- should("match id and tag")
    run(div([#("id", "foo")]), "div#foo")
  }

  {
    use run <- should_not("match id and tag when tag is not maching")
    run(div([#("id", "foo")]), "p#foo")
  }
}

pub fn psuedo_class_test() {
  {
    use run <- should("match psuedo class")
    run(#("input", [#("readonly", "")]), ":readonly")
  }

  {
    use run <- should_not("match psuedo class that does not exist")
    run(#("input", []), ":readonly")
  }
}

pub fn attribute_selector_test() {
  // exists
  {
    use run <- should("match if attribute exists")
    run(#("div", [#("foo", "bar")]), "[foo]")
  }

  {
    use run <- should_not("match if attribute does not exists")
    run(div([#("foo", "bar")]), "[buz]")
  }

  // equal
  {
    use run <- should("match if attribute is equal")
    run(div([#("foo", "bar")]), "[foo=\"bar\"]")
  }

  {
    use run <- should_not("match if attribute is not equal")
    run(div([#("foo", "bar")]), "[foo=\"baz\"]")
  }

  // prefix
  {
    use run <- should("match if attribute match prefix")
    run(div([#("data-test", "foobar")]), "[data-test^=\"foo\"]")
  }

  {
    use run <- should_not("match if attribute match does not match prefix")
    run(div([#("data-test", "foobar")]), "[data-test^=\"bar\"]")
  }
}

// --------------------- [ UTILS ] -----------------------
fn should(description: String, run) {
  use element, selector <- run
  check(description, element, selector, True)
}

fn should_not(description: String, run) {
  use element, selector <- run
  check(description, element, selector, False)
}

fn css(input) {
  css_select.parse_simple_selector(input)
  |> should.be_ok
}

fn check(description, element, selector, expected) {
  io.println(">> " <> description <> " selector: " <> selector)

  simple_matcher.match(element, css(selector))
  |> should.equal(expected)

  io.println(" ✅")
}

fn div(attributes) {
  #("div", attributes)
}
