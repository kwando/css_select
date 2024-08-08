import css_select/selector.{
  type Selector, Any, AttributeEqual, AttributeExists, AttributeIncludes,
  AttributePrefix, AttributeSuffix, Class, ElementSelector, Id, Psuedo, Tag,
}
import gleam/bool
import gleam/list
import gleam/result
import gleam/string

pub type Element =
  #(String, List(#(String, String)))

// Check if a selector matches a given element.
pub fn match(element: Element, selector: Selector) {
  let #(t, attrs) = element

  case selector {
    ElementSelector(Any, attr_selectors) ->
      list.all(attr_selectors, match_attribute(attrs, _))

    ElementSelector(Tag(tag), attr_selectors) ->
      tag == t && match(element, ElementSelector(Any, attr_selectors))
  }
}

fn class_list(attributes: List(#(String, String))) {
  use class_str <- with_attribute(attributes, "class", [])

  class_str
  |> string.split(" ")
  |> list.map(string.trim)
  |> list.filter(non_empty_string)
}

fn non_empty_string(str) {
  str
  |> string.is_empty
  |> bool.negate
}

fn with_attribute(
  attributes,
  attribute,
  default: r,
  callback: fn(String) -> r,
) -> r {
  attributes
  |> list.key_find(attribute)
  |> result.map(callback)
  |> result.unwrap(default)
}

fn match_attribute(attributes, selector: selector.AttributeSelector) -> Bool {
  case selector {
    Id(id) -> match_attribute(attributes, AttributeEqual("id", id))
    Psuedo(psuedo) -> match_attribute(attributes, AttributeExists(psuedo))

    Class(class) ->
      class_list(attributes)
      |> list.any(fn(c) { c == class })

    AttributeExists(attribute) -> {
      use _attr_value <- with_attribute(attributes, attribute, False)
      True
    }

    AttributeEqual(attribute, value) -> {
      use attr_value <- with_attribute(attributes, attribute, False)
      attr_value == value
    }

    AttributePrefix(attribute, prefix) -> {
      use attr_value <- with_attribute(attributes, attribute, False)
      string.starts_with(attr_value, prefix)
    }

    AttributeSuffix(attribute, suffix) -> {
      use attr_value <- with_attribute(attributes, attribute, False)
      string.ends_with(attr_value, suffix)
    }

    AttributeIncludes(attribute, value) -> {
      use attr_value <- with_attribute(attributes, attribute, False)
      string.contains(attr_value, value)
    }
  }
}
