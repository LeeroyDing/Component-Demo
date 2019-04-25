/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#pragma once

#include <cstdlib>
#include <functional>
#include <new>
#include <type_traits>
#include <utility>

namespace CK {

template <typename>
struct PointerToMemberTraits;

template <typename R, typename T>
struct PointerToMemberTraits<R(T::*)> {
  using Self = T;
  using MemberType = R;
};

template <typename F>
using Self = typename PointerToMemberTraits<F>::Self;

template <typename F>
using MemberType = typename PointerToMemberTraits<F>::MemberType;

struct None {
  auto operator==(const None&) const -> bool {
    return true;
  }
};

/**
 Singleton empty value for all optionals.
 */
constexpr None none;

/**
 `Optional` class allows you to add an "empty state" value to any type `T`, similar to `nil` value for pointers.
 Instead of using an otherwise perfectly ordinary value to signify the absence of the value, like `NSNotFound` or
 `std::string::npos` or `-1`, `Optional` allows you to model this concept explicitly, without using any special values.
 `Optional` also makes sure that you don't forget to check for both cases and don't try to use the wrapped value when
 it's not there.

 Typical problems that are solved by using `Optional` include:

 - Inability to delay initialisation of types without the default constructor.

 - Having to resort to reference types / heap allocation to use `nil` as a sentinel.

 - Having to maintain a separate boolean flag that signifies the presence of a value.

 If you have function that takes an optional but you can't really do anything useful when this optional is empty,
 you should consider having an version that works with non-optional values instead. This simplifies code considerably:

     Optional<int> x = ...

     // Valid, but...
     auto f(Optional<int> i) -> Optional<string> {
       if (t == none) { return none; }
       ...
     }
     auto s = f(x);

     // ...better!
     auto f(int i) -> string { ... }
     auto s = x.map(f);

 In general, you should strive to have functions that take and return non-optional values and use these functions as
 arguments to map and have optionals usage confined to a limited number of call sites.
 */
template <typename T>
class Optional final {
public:
  using ValueType = T;

  // Constructs an empty Optional
  Optional() noexcept {}
  Optional(const None&) noexcept {}

  // Constructs an Optional that contains a value
  Optional(const T& value) noexcept {
    construct(value);
  }
  Optional(T&& value) noexcept {
    construct(std::move(value));
  }

  Optional(const Optional& other) {
    if (other.hasValue()) {
      construct(other.forceUnwrap());
    }
  }

  Optional(Optional&& other) {
    if (other.hasValue()) {
      construct(std::move(other.forceUnwrap()));
      other.clear();
    }
  }

  auto operator=(None) noexcept -> Optional& {
    clear();
    return *this;
  }

  template <typename Arg>
  auto operator=(Arg&& arg) -> Optional& {
    assign(std::forward<Arg>(arg));
    return *this;
  }

  auto operator=(const Optional& other) -> Optional {
    assign(other);
    return *this;
  }

  auto operator=(Optional&& other) -> Optional {
    assign(std::move(other));
    return *this;
  }

  auto hasValue() const noexcept -> bool {
    return _storage.hasValue;
  }

  /**
   The foundational operation which allows you to get the access to the wrapped value. You should consider using other
   operations such as `map`, `valueOr` or `apply` first since they handle the most common use cases in a more concise
   manner.

   You pass the two callable objects to the match() function, where the first one will be called with the wrapped value
   if it's there and the second one will be called if the optional is empty:

       Optional<T> x = ...
       x.match(
       [](const T &t){
         // Always have a valid T here
         useT(t);
       },
       [](){
         // No T, handle it
       }
       );

   You can notice that there are certain similarities to switch statement. However, unlike switch, match() is an
   *expression*, so your handlers can return a value (both must return the same type).

   Note: "callable objects" here include but are not limited to lambdas. These can also be Objective C blocks,
   function pointers, function-like objects (that override operator ()).

   @param vm  function-like object that will be invoked if the Optional contains the value.
   @param nm  function-like object that will be invoked if the Optional is empty.

   @return The return value of invoking vm with the wrapped value if the Optional is not empty, or the return value
   of invoking nm otherwise.
   */
  template <typename ValueMatcher, typename NoneMatcher>
  auto match(ValueMatcher&& vm, NoneMatcher&& nm) const
  -> decltype(vm(std::declval<T>())) {
    if (hasValue()) {
      return vm(forceUnwrap());
    }
    return nm();
  }

  /**
   Same as `match` but for cases when you want to perform a side-effect instead of returning a value, e.g.:

       auto v = std::vector<int> {};

       x.apply([&](const int &x){
         v.push_back(x);
       });

   @param vm  function-like object that will be invoked if the Optional contains the value.

   Note: you are not allowed to return anything from value handler in apply.
   */
  template <typename ValueMatcher>
  auto apply(ValueMatcher&& vm) const -> void {
    match(std::forward<ValueMatcher>(vm), []() {});
  }

  /**
   Transforms a value wrapped inside the Optional, e.g.:

       auto area(rect: CGRect) -> CGFloat;
       Optional<CGRect> r = ...
       Optional<CGFloat> a = r.map(area);

   @param f function-like object that will be invoked if the Optional contains the value.

   @return A new Optional that wraps the result of calling `f` with the wrapped value if the Optional was not empty, or
   an empty Optional otherwise.
   */
  template <typename F>
  auto map(F&& f) const -> Optional<decltype(f(std::declval<T>()))> {
    using U = decltype(f(std::declval<T>()));
    return match(
                 [&](const T& value) { return Optional<U>{f(value)}; },
                 []() { return none; });
  }

  /**
   Transforms a value wrapped inside the Optional, e.g.:

   Optional<CGRect> r = ...
   Optional<CGFloat> w = r.map(&CGRect::width);

   @param f pointer-to-member function that will be invoked if the Optional contains the value.

   @return A new Optional that wraps the result of calling `f` with the wrapped value if the Optional was not empty, an
   empty Optional otherwise.
   */
  template <typename F>
  auto map(F&& f) const -> Optional<MemberType<F>> {
    return match(
                 [&](const T& value) { return Optional<MemberType<F>>{value.*f}; },
                 []() { return none; });
  }

  /**
   Transforms a value wrapped inside the Optional using a function that itself returns an Optional, "flattening" the
   final result, e.g.:

       // Not all strings can be converted to integers
       auto toInt(const std::string& s) -> Optional<int>;
       Optional<std::string> s = ...
       Optional<int> = s.flatMap(toInt); // Not Optional<Optional<int>>!

   @param f function-like object that will be invoked if the Optional contains the value.

   @return The result of calling `f` with the wrapped value if the Optional was not empty, or an empty Optional otherwise.
   */
  template <typename F>
  auto flatMap(F&& f) const
  -> Optional<typename decltype(f(std::declval<T>()))::ValueType> {
    return match(
                 [&](const T& value) { return f(value); }, []() { return none; });
  }

  /**
   Transforms a value wrapped inside the Optional using a function that itself returns an Optional, "flattening" the
   final result, e.g.:

   struct HasOptional {
     Optional<int> x;
   };
   Optional<HasOptional> a = HasOptional { 123 };
   Optional<int> x = a.flatMap(&HasOptional::x); // Not Optional<Optional<int>>!

   @param f pointer-to-member function that will be invoked if the Optional contains the value.

   @return The result of calling `f` with the wrapped value if the Optional was not empty, or an empty Optional otherwise.
   */
  template <typename F>
  auto flatMap(F&& f) const -> Optional<typename MemberType<F>::ValueType> {
    return match(
                 [&](const T& value) { return Optional<typename MemberType<F>::ValueType>{value.*f}; },
                 []() { return none; });
  }

  /**
   Substitutes a default value in case the optional is empty.

   @param dflt  default non-optional value to substitute.

   @return The value wrapped in the Optional if it is not empty, or the default value otherwise.
   */
  auto valueOr(const T& dflt) const& -> T {
    return match([](const T& value) { return value; }, [&]() { return dflt; });
  }

  auto valueOr(T&& dflt) const& -> T {
    return match(
                 [](const T& value) { return value; },
                 [&]() { return std::forward<T>(dflt); });
  }

  auto valueOr(const T& dflt) && -> T {
    return match(
                 [](const T& value) { return std::move(value); },
                 [&]() { return dflt; });
  }

  auto valueOr(T&& dflt) && -> T {
    return match(
                 [](const T& value) { return std::move(value); },
                 [&]() { return std::forward<T>(dflt); });
  }

  /**
   Substitutes a default value in case the optional is empty. The callable argument is only invoked when the optional is
   empty. Use this variant of `valueOr` when the computation of the default value is expensive or has side effects.

   @param defaultProvider  a function-like object that takes no arguments and returns a default non-optional value to
                           substitute.

   @return The value wrapped in the Optional if it is not empty, or the default value otherwise.
   */
  template <typename F, typename = std::enable_if_t<std::is_convertible<F, std::function<T()>>::value>>
  auto valueOr(F&& defaultProvider) const& -> T {
    return match([](const T& value) { return value; }, [&]() { return defaultProvider(); });
  }

  template <typename F, typename = std::enable_if_t<std::is_convertible<F, std::function<T()>>::value>>
  auto valueOr(F&& defaultProvider) && -> T {
    return match([](const T& value) { return std::move(value); }, [&]() { return defaultProvider(); });
  }

  /**
   ** Advanced API, Tread with Caution **

   You can use a more concise syntax for getting access to the wrapped value using unsafeValuePtrOrNull:

       Optional<T> x = ...

       if (auto t = a.unsafeValuePtrOrNull()) {
         // Always have a pointer to valid T here
       } else {
         // No T, handle it
       }

   The constness of `x` here will be propagated to `t` (i.e. if `x` were `const Optional<T>`, `t` would be `const T *`;
   in the example the type of `t` is just `T *`).

   @note `unsafeValuePtrOrNull()` doesn't work for rvalues (because the Optional will be destroyed at the end of
   expression and you'll be left with a dangling pointer), so the following won't compile:

       if (auto t = getOptional().unsafeValuePtrOrNull()) { ... }

   @note `unsafeValuePtrOrNull()` returns a nullable unmanaged pointer to the Optional's storage. The usual safety
   rules about such pointers apply.
   */
  auto unsafeValuePtrOrNull() const& -> const ValueType* {
    return _storage.hasValue ? &_storage.value : nullptr;
  }

  auto unsafeValuePtrOrNull() & -> ValueType* {
    return _storage.hasValue ? &_storage.value : nullptr;
  }

  auto unsafeValuePtrOrNull() && -> ValueType* = delete;

private:
  template <typename U>
  friend auto operator==(
                         const Optional<U>& lhs,
                         const Optional<U>& rhs) noexcept -> bool;

  template <typename... Args>
  void construct(Args&&... args) {
    const void* ptr = &_storage.value;
    new (const_cast<void*>(ptr)) T(std::forward<Args>(args)...);
    _storage.hasValue = true;
  }

  void assign(const Optional& other) {
    other.match(
                [this](const T& value) { assign(value); }, [this]() { clear(); });
  }

  void assign(Optional&& other) {
    if (this == &other) {
      return;
    }
    other.match(
                [&](const T& value) {
                  assign(std::move(value));
                  other.clear();
                },
                [this]() { clear(); });
  }

  void assign(const T& newValue) {
    if (hasValue()) {
      _storage.value = newValue;
    } else {
      construct(newValue);
    }
  }

  void assign(T&& newValue) {
    if (hasValue()) {
      _storage.value = std::move(newValue);
    } else {
      construct(std::move(newValue));
    }
  }

  const T& forceUnwrap() const& {
    requireValue();
    return _storage.value;
  }

  T& forceUnwrap() & {
    requireValue();
    return _storage.value;
  }

  T&& forceUnwrap() && {
    requireValue();
    return std::move(_storage.value);
  }

  void requireValue() const {
    if (!_storage.hasValue) {
      abort();
    }
  }

  void clear() noexcept {
    _storage.clear();
  }

  struct StorageTriviallyDestructible {
    union {
      char emptyState;
      T value;
    };
    bool hasValue;

    StorageTriviallyDestructible() : hasValue{false} {}

    void clear() {
      hasValue = false;
    }
  };

  struct StorageNonTriviallyDestructible {
    union {
      char emptyState;
      T value;
    };
    bool hasValue;

    StorageNonTriviallyDestructible() : hasValue{false} {}
    ~StorageNonTriviallyDestructible() {
      clear();
    }

    void clear() {
      if (!hasValue) {
        return;
      }
      hasValue = false;
      value.~T();
    }
  };

  using Storage = typename std::conditional<
  std::is_trivially_destructible<T>::value,
  StorageTriviallyDestructible,
  StorageNonTriviallyDestructible>::type;

  Storage _storage;
};

/**
 You can compare Optionals of the same type:

 - Empty optionals are equal to each other
 - An empty optional is never equal to the one that has a value
 - If both optionals have values, the values are checked for equality.
 */
template <typename U>
auto operator==(const Optional<U>& lhs, const Optional<U>& rhs) noexcept
-> bool {
  if (lhs.hasValue() != rhs.hasValue()) {
    return false;
  }
  if (lhs.hasValue()) {
    return lhs.forceUnwrap() == rhs.forceUnwrap();
  }
  return true;
}

template <typename T>
auto operator!=(const Optional<T>& lhs, const Optional<T>& rhs) noexcept
-> bool {
  return !(lhs == rhs);
}

/**
 You can compare optionals to values of the corresponding type directly:

     Optional<int> x = ...
     x == 2

 This return true iff x has a value and it is equal to 2.
 */

template <typename T>
auto operator==(const Optional<T>& lhs, const T& rhs) noexcept -> bool {
  return lhs.map([&](const T& value) { return value == rhs; }).valueOr(false);
}

template <typename T>
auto operator!=(const Optional<T>& lhs, const T& rhs) noexcept -> bool {
  return !(lhs == rhs);
}

template <typename T>
auto operator==(const T& lhs, const Optional<T>& rhs) noexcept -> bool {
  return rhs.map([&](const T& value) { return value == lhs; }).valueOr(false);
}

template <typename T>
auto operator!=(const T& lhs, const Optional<T>& rhs) noexcept -> bool {
  return !(lhs == rhs);
}

/**
 You can also compare optionals with `none` which is equivalent to calling `hasValue`.
 */

template <typename T>
auto operator==(const Optional<T>& lhs, None) noexcept -> bool {
  return !lhs.hasValue();
}

template <typename T>
auto operator!=(const Optional<T>& lhs, None) noexcept -> bool {
  return lhs.hasValue();
}

template <typename T>
auto operator==(None, const Optional<T>& rhs) noexcept -> bool {
  return !rhs.hasValue();
}

template <typename T>
auto operator!=(None, const Optional<T>& rhs) noexcept -> bool {
  return rhs.hasValue();
}

} // namespace CK
