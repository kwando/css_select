import css_select
import css_select/selector.{
  Any, AttributeEqual, AttributeExists, AttributeIncludes, AttributePrefix,
  AttributeSuffix, Class, ElementSelector, Id, Psuedo, Tag,
}
import gleeunit/should

pub fn parse_simple_selector_test() {
  css_select.parse_simple_selector("div.foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Tag("div"), [Class("foo"), Class("bar"), Id("myId")]),
  )

  css_select.parse_simple_selector(".foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Any, [Class("foo"), Class("bar"), Id("myId")]),
  )

  css_select.parse_simple_selector(".foo-bar")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Class("foo-bar")]))
}

pub fn parse_attribute_exists_test() {
  css_select.parse_simple_selector("[href]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeExists("href")]))
}

pub fn parse_attribute_equals_test() {
  css_select.parse_simple_selector("[foo=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeEqual("foo", "bar")]))
  css_select.parse_simple_selector("[href=\"https://www.example.com\"]")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Any, [AttributeEqual("href", "https://www.example.com")]),
  )
}

pub fn parse_attribute_prefix_test() {
  css_select.parse_simple_selector("[foo^=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributePrefix("foo", "bar")]))
}

pub fn parse_attribute_suffix_test() {
  css_select.parse_simple_selector("[foo$=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeSuffix("foo", "bar")]))
}

pub fn parse_attribute_includes_test() {
  css_select.parse_simple_selector("[foo*=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeIncludes("foo", "bar")]))
}

pub fn parse_attribute_psuedo_class_test() {
  css_select.parse_simple_selector(":checked")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Psuedo("checked")]))

  css_select.parse_simple_selector(":disabled")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Psuedo("disabled")]))

  css_select.parse_simple_selector(":hello")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Psuedo("hello")]))
}
