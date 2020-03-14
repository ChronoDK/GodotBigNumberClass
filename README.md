# GodotBigNumberClass
Use very BIG numbers in Godot Engine games.

With my solution you can create a number like this:

var myBigNumber = Big.new(2,6) #2 million

Or like this:

var myBigNumber2 = Big.new(2000000)

And then do math on it like this:

myBigNumber.plus(myBigNumber2)

It supports very big numbers, with hundreds of digits so very useful in an idle game. Also it can format the number to a short string in AA-notation like 2.00M for two million, or for bigger numbers something like 4.56AA, 7.89ZZ or even bigger.

myBigNumber.toAA()

Simply put the Big.gd file in your project and you are good to go.
