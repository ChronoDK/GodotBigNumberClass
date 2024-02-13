# GodotBigNumberClass

Use very BIG numbers in Godot Engine games.

It supports very big numbers with hundreds of digits, useful in an idle game. It can also format the number to a short string in AA-notation like 2.00M for two million, or for bigger numbers something like 4.56AA, 7.89ZZ or even bigger.

## Setup

For `4.1.x` and later, just drop the file in your project folder.

For `3.x`, the easiest way to use this class is to preload it in a script that is set as [AutoLoad](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html) in your project, as Big.gd cannot be used as AutoLoad itself as of Godot 3.3.4.

e.g. In a file named Global.gd, autoloaded in your project:

```GDScript
extends Node

const Big = preload("res://path/to/Big.gd")

# ...
```

## Creating an instance

Multiple constructors can be used to instantiate a `Big` number:

```GDScript
var big_int = Big.new(100)  # From an integer
var big_exp = Big.new(2, 6) # Using a mantissa and exponent;
                            # here means 2,000,000
var big_cpy = Big.new(big_exp)  # As a copy of another big number;
                                # See why below
```

Some operations executed on a `Big` number modify that instance. As such, you will probably find yourself creating temporary copies of other `Big` numbers to run those operations while leaving the original value untouched.

```GDScript
var unit_cost: Big = Big.new(2, 6)

func cost(count: Big) -> Big:
    var _total = Big.new(count)
    return _total.timesEquals(unit_cost)
```

## Mathematical operations

The normal operands used for integer and floating-point operations (e.g. `+`, `-`, `*`, `/`, `%`) cannot be used on a `Big` number.

Instead, you can use the provided functions for a `Big` number:

```GDScript
# 'value' can be numeric or another Big number
my_big_number.plus(value)       # my_big_number + value
my_big_number.minus(value)      # my_big_number - value
my_big_number.times(value)      # my_big_number * value
my_big_number.dividedBy(value)  # my_big_number / value
my_big_number.mod(value)        # my_big_number % value
my_big_number.toThePowerOf(value) # Only accepts float or int; my_big_number ** value
```

Or for calculating `Big` numbers together:

```GDScript
Big.add(big_a, big_b)       # big_a + big_b
Big.subtract(big_a, big_b)  # big_a - big_b
Big.multiply(big_a, big_b)  # big_a * big_b
Big.divide(big_a, big_b)    # big_a / big_b
Big.modulo(big_a, big_b)    # big_a % big_b
```

Operations can be chained:

```GDScript
var my_big_number = Big.new(100)
print(my_big_number.plus(10).dividedBy(10).toString())  # Will print "11"
```

## Modifying

Some functions can modify the current object as well. It's as simple as writing "Equals" after the operation names

```GDScript
# 'value' can be numeric or another Big number
my_big_number.plusEquals(value)         # my_big_number += value
my_big_number.minusEquals(value)        # my_big_number -= value
my_big_number.timesEquals(value)        # my_big_number *= value
my_big_number.dividedByEquals(value)    # my_big_number /= value
my_big_number.modEquals(value)          # my_big_number %= value
my_big_number.toThePowerOfEquals(value) # Only accepts float or int; my_big_number **= value

Big.round_down(my_big_number)           # Rounds down the mantissa
```

## Comparisons

The normal operands still cannot be used here (e.g. `>`, `>=`, `==`, `<`, `<=`).

Instead, you can use the provided functions:

```GDScript
# 'value' can be numeric or another Big number

my_big_number.isGreaterThan(value)
my_big_number.isGreaterThanOrEqualTo(value)
my_big_number.isEqualTo(value)
my_big_number.isLessThanOrEqualTo(value)
my_big_number.isLessThan(value)
```

## Static functions

The following static functions are available:

```GDScript
# 'big_value' must be a Big number;
# 'value' can be numeric or another Big number

var smallest = Big.minValue(big_value, value)
var largest = Big.maxValue(big_value, value)
var positive = Big.absolute(big_value)
```

## Formatting as a string

An important aspect with big numbers is being able to display them in a way that is readable and makes sense for the player. The following functions can be used to do so:

```GDScript
var big = Big.new(12345, 12)
print(big.toAA())               # 12.34aa
print(big.toAmericanName())     # 12.34quadrillion
print(big.toEuropeanName())     # 12.34billiard
print(big.toLongName())         # 12.34quadrillion
print(big.toMetricName())       # 12.34peta
print(big.toMetricSymbol())     # 12.34P
print(big.toPrefix())           # 12.34
print(big.toScientific())       # 1.2345e16
print(big.toShortScientific())  # 1.2e16
print(big.toString())           # 12345000000000000
```

Some of the functions have arguments with default values, not displayed in the snippet above.

You can tweak the way the strings are formatted by calling the following static functions:

```GDScript
Big.setThousandName("string_value")       # Defaults to "thousand"
Big.setThousandSeparator("string_value")  # Defaults to ".", you should set this with your localization settings
Big.setDecimalSeparator("string_value")   # Defaults to ",", you should set this with your localization settings
Big.setSuffixSeparator("string_value")   # Defaults to an empty string
Big.setReadingSeparator("string_value")   # Defaults to an empty string

Big.setDynamicNumbers(int_value)  # Defaults to 4, makes it such that values will only have four digits when dynamic_decimals is true, ie. 1,234 or 12,34
Big.setDynamicDecimals(bool_value)  # Defaults to true

Big.setSmallDecimals(int_value)     # Defaults to 2
Big.setThousandDecimals(int_value)  # Defaults to 2
Big.setBigDecimals(int_value)       # Defaults to 2
```

For example:

```GDScript
var big = Big.new(12345, 12)
print(big.toAA())  # With default settings: 12,34aa

Big.setSuffixSeparator(" ")
Big.setDecimalSeparator(".")
Big.setDynamicDecimals(false)
Big.setSmallDecimals(1)
print(big.toAA())  # With modified settings: 12.3 aa
```
