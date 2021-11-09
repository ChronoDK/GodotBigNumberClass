# GodotBigNumberClass

Use very BIG numbers in Godot Engine games.

It supports very big numbers, with hundreds of digits so very useful in an idle game. Also it can format the number to a short string in AA-notation like 2.00M for two million, or for bigger numbers something like 4.56AA, 7.89ZZ or even bigger.

## Setup

The easiest way to use this class is to preload it in a file that is set as [AutoLoad](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html) in your project, as Big.gd cannot be used as AutoLoad itself as of Godot 3.3.4.

e.g. In a file named Global.gd, autoloaded in your project:

```GDScript
extends Node

const Big = preload("res://path/to/Big.gd")

# ...
```

## Creating an instance

Multiple constructors can be used to instanciate a Big number:

```GDScript
var my_big_number_a = Big.new(100)  # From an integer
var my_big_number_b = Big.new(2, 6) # Using a mantissa and exponent; here means 2000000
var my_big_number_c = Big.new(my_big_number_b) # As a copy of another big number; see why below
```

All operations executed on a Big number modify that instance. As such, you will probably often find yourself creating temporary copies of other Big numbers to run those operations while leaving the original value untouched.

```GDScript
var unit_cost: Big = Big.new(2, 6)

func cost(count:Big) -> Big:
    var _total = Big.new(count)
    return _total.multiply(unit_cost)
```

## Mathematical operations

The normal operands used for integer and floating-point operations (e.g. `+`, `-`, `*`, `/`, `%`) cannot be used on a Big number.

Instead, you can use the provided functions:

```GDScript
my_big_number.plus(value)       # 'value' can be numeric or another Big number
my_big_number.minus(value)
my_big_number.divide(value)
my_big_number.power(int_value)  # Only accepts an 'int' value
my_big_number.squareRoot()
my_big_number.module(value)
my_big_number.roundDown()
my_big_number.log10(int_value)
```

All functions modify the current object, and also return it to chain operations if needed.

```GDScript
var my_big_number = Big.new(100)
print(my_big_number.plus(10).divide(10).toString())  # Will print "11"
```

## Comparisons

Again, the normal operands cannot be used here (e.g. `>`, `>=`, `==`, `<`, `<=`).

Instead, you can use the provided functions:

```GDScript
my_big_number.isLargerThan(value)  # 'value' can be numeric or another Big number
my_big_number.isLargerThanOrEqualTo(value)
my_big_number.isEqualTo(value)
my_big_number.isLessThanOrEqualTo(value)
my_big_number.isLessThan(value)
```

## Static functions

The following static functions are available:

```GDScript
var small_number = Big.min(big_value, value)  # 'big_value' must be a Big number,
                                              # 'value' can be numeric or another Big number
var large_number = Big.max(big_value, value)
var positive_number = Big.abs(big_value)
```

## Formatting as a string

(TODO)

This converts the Big number to an AA-notation string:

myBigNumber.toAA()

You can also convert it to large name notation like billion, trillion or even octovigintillion like this:

myBigNumber.toLargeName()
