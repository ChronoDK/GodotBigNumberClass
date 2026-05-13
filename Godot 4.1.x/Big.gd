class_name Big
extends RefCounted
## Big number class for use in idle / incremental games and other games that needs very large numbers
##
## Can format large numbers using a variety of notation methods:[br]
## AA notation like AA, AB, AC etc.[br]
## Metric symbol notation k, m, G, T etc.[br]
## Metric name notation kilo, mega, giga, tera etc.[br]
## Long names like octo-vigin-tillion or millia-nongen-quin-vigin-tillion (based on work by Landon Curt Noll)[br]
## Scientic notation like 13e37 or 42e42[br]
## Long strings like 4200000000 or 13370000000000000000000000000000[br][br]
## Please note that this class has limited precision and does not fully support negative exponents[br]

## Big Number Mantissa
var mantissa: float
## Big Number Exponent
var exponent: int

## Metric Symbol Suffixes
const suffixes_metric_symbol: Dictionary[int, String] = {
    0: "", 
    1: "k", 
    2: "M", 
    3: "G", 
    4: "T", 
    5: "P", 
    6: "E", 
    7: "Z", 
    8: "Y", 
    9: "R", 
    10: "Q",
}
## Metric Name Suffixes
const suffixes_metric_name: Dictionary[int, String] = {
    0: "", 
    1: "kilo", 
    2: "mega", 
    3: "giga", 
    4: "tera", 
    5: "peta", 
    6: "exa", 
    7: "zetta", 
    8: "yotta", 
    9: "ronna", 
    10: "quetta", 
}

## AA suffixes keps in dictionary to prevent generating each of them again and again
static var suffixes_aa: Dictionary[int, String] = {
    0: "", 
    1: "k", 
    2: "m", 
    3: "b", 
    4: "t", 
    5: "aa", 
    6: "ab", 
    7: "ac", 
    8: "ad", 
    9: "ae", 
    10: "af", 
    11: "ag", 
    12: "ah", 
    13: "ai", 
    14: "aj", 
    15: "ak", 
    16: "al", 
    17: "am", 
    18: "an", 
    19: "ao", 
    20: "ap", 
    21: "aq", 
    22: "ar", 
    23: "as", 
    24: "at", 
    25: "au", 
    26: "av", 
    27: "aw", 
    28: "ax", 
    29: "ay", 
    30: "az", 
    31: "ba", 
    32: "bb", 
    33: "bc", 
    34: "bd", 
    35: "be", 
    36: "bf", 
    37: "bg", 
    38: "bh", 
    39: "bi", 
    40: "bj", 
    41: "bk", 
    42: "bl", 
    43: "bm", 
    44: "bn", 
    45: "bo", 
    46: "bp", 
    47: "bq", 
    48: "br", 
    49: "bs", 
    50: "bt", 
    51: "bu", 
    52: "bv", 
    53: "bw", 
    54: "bx", 
    55: "by", 
    56: "bz", 
    57: "ca"
}

## AA Alphabet
const alphabet_aa: Array[String] = [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
]

## Latin Ones Prefixes
const latin_ones: Array[String] = [
    "", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem"
]
## Latin Tens Prefixes
const latin_tens: Array[String] = [
    "", "dec", "vigin", "trigin", "quadragin", "quinquagin", "sexagin", "septuagin", "octogin", "nonagin"
]
## Latin Hundreds Prefixes
const latin_hundreds: Array[String] = [
    "", "cen", "duocen", "trecen", "quadringen", "quingen", "sescen", "septingen", "octingen", "nongen"
]
## Latin Special Prefixes
const latin_special: Array[String] = [
    "", "mi", "bi", "tri", "quadri", "quin", "sex", "sept", "oct", "non"
]

## Various options to control the string presentation of Big Numbers
static var options = {
    "dynamic_decimals": false, 
    "dynamic_numbers": 4, 
    "small_decimals": 2, 
    "thousand_decimals": 2, 
    "big_decimals": 2, 
    "scientific_decimals": 2, 
    "logarithmic_decimals": 2, 
    "maximum_trailing_zeroes": 3,
    "thousand_separator": ",", 
    "decimal_separator": ".", 
    "suffix_separator": "", 
    "reading_separator": "", 
    "thousand_name": "thousand"
}

## Maximum Big Number Mantissa
const MANTISSA_MAX: float = 1209600.0
## Big Number Mantissa floating-point precision
const MANTISSA_PRECISION: float = 0.0000001

## int (signed 64-bit) minimum value
const INT_MIN: int = -9223372036854775808
## int (signed 64-bit) maximum value
const INT_MAX: int = 9223372036854775807

const POW10:Array[float] = [1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0, 10000000.0, 100000000.0, 1000000000.0, 10000000000.0, 100000000000.0, 1000000000000.0, 10000000000000.0, 100000000000000.0, 1000000000000000.0]

func _init(m: Variant = 1.0, e: int = 0) -> void:
    if m is Big:
        mantissa = m.mantissa
        exponent = m.exponent
    elif typeof(m) == TYPE_STRING:
        var scientific: PackedStringArray = m.split("e")
        mantissa = float(scientific[0])
        exponent = int(scientific[1]) if scientific.size() > 1 else 0
    else:
        if typeof(m) != TYPE_INT and typeof(m) != TYPE_FLOAT:
            printerr("Big Error: Unknown data type passed as a mantissa!")
        mantissa = m
        exponent = e
    Big._sizeCheck(mantissa)
    Big.normalize(self)

## Verifies (or converts) an argument into a Big number
static func _typeCheck(n) -> Big:
    if n is Big:
        return n
    var result:Big = Big.new(n)
    return result

## Warns if Big number's mantissa exceeds max
static func _sizeCheck(m: float) -> void:
    if m > MANTISSA_MAX:
        printerr("Big Error: Mantissa \"" + str(m) + "\" exceeds MANTISSA_MAX. Use exponent or scientific notation")


## [url=https://en.wikipedia.org/wiki/Normalized_number]Normalize[/url] a Big number
static func normalize(big: Big) -> void:
    var m:float = big.mantissa
    if m == 0.0:
        big.exponent = 0
        return

    var e:int = big.exponent

    var sign_ := 1.0
    if m < 0.0:
        sign_ = -1.0
        m = -m

    var shift:int = int(floor(log10(m)))
    if shift < 0 and -shift < POW10.size():
        m *= POW10[-shift]
    else:
        m *= pow(10.0, -shift)
    
    e += shift

    m = snapped(m, MANTISSA_PRECISION)

    big.mantissa = m * sign_
    big.exponent = e


## Returns the absolute value of a number in Big format
static func absolute(x) -> Big:
    var result:Big = Big.new(x)
    result.mantissa = abs(result.mantissa)
    return result


## Adds two numbers and returns the Big number result [br][br]
static func add(x, y) -> Big:
    x = Big._typeCheck(x)
    y = Big._typeCheck(y)

    # Ensure x has the larger exponent (dominant number)
    if y.exponent > x.exponent:
        var temp:Big = x
        x = y
        y = temp

    var result: Big = Big.new(x)
    var exp_diff:int = y.exponent - x.exponent

    # If y is too small to affect x (float precision limit), skip it
    if exp_diff < -15:
        return result
    elif exp_diff >= -15: # Fast paths for common small differences
        result.mantissa = x.mantissa + y.mantissa / POW10[-exp_diff]
    else:
        result.mantissa = x.mantissa + y.mantissa * pow(10.0, exp_diff)

    Big.normalize(result)
    return result


## Subtracts two numbers and returns the Big number result
static func subtract(x, y) -> Big:
    return add(x, Big.new(y).negate())


## Multiplies two numbers and returns the Big number result
static func times(x, y) -> Big:
    x = Big._typeCheck(x)
    y = Big._typeCheck(y)
    var result:Big = Big.new()
    
    var new_exponent: int = y.exponent + x.exponent
    var new_mantissa: float = y.mantissa * x.mantissa
    while new_mantissa >= 10.0:
        new_mantissa /= 10.0
        new_exponent += 1
    result.mantissa = new_mantissa
    result.exponent = new_exponent
    Big.normalize(result)
    return result


## Divides two numbers and returns the Big number result
static func division(x, y) -> Big:
    x = Big._typeCheck(x)
    y = Big._typeCheck(y)
    var result:Big = Big.new(x)
    
    if y.mantissa > -MANTISSA_PRECISION and y.mantissa < MANTISSA_PRECISION:
        printerr("Big Error: Divide by zero or less than " + str(MANTISSA_PRECISION))
        return x
    var new_exponent = x.exponent - y.exponent
    var new_mantissa = x.mantissa / y.mantissa
    while new_mantissa > 0.0 and new_mantissa < 1.0:
        new_mantissa *= 10.0
        new_exponent -= 1
    result.mantissa = new_mantissa
    result.exponent = new_exponent
    Big.normalize(result)
    return result


## Raises a Big number to the nth power and returns the Big number result
static func powers(x: Big, y) -> Big:
    var result:Big = Big.new(x)
    if typeof(y) == TYPE_INT:
        if y <= 0:
            if y < 0:
                printerr("Big Error: Negative exponents are not supported!")
            result.mantissa = 1.0
            result.exponent = 0
            return result
        
        var y_mantissa: float = 1.0
        var y_exponent: int = 0
        
        while y > 1:
            Big.normalize(result)
            if y % 2 == 0:
                result.exponent *= 2
                result.mantissa **= 2
                y = y / 2
            else:
                y_mantissa = result.mantissa * y_mantissa
                y_exponent = result.exponent + y_exponent
                result.exponent *= 2
                result.mantissa **= 2
                y = (y - 1) / 2
        
        result.exponent = y_exponent + result.exponent
        result.mantissa = y_mantissa * result.mantissa
        Big.normalize(result)
        return result
    elif typeof(y) == TYPE_FLOAT:
        if result.mantissa == 0:
            return result
        
        # fast track
        var temp: float = result.exponent * y
        var newMantissa = result.mantissa ** y
        if (round(y) == y
                and temp <= INT_MAX
                and temp >= INT_MIN
                and is_finite(temp)
        ):
            if is_finite(newMantissa):
                result.mantissa = newMantissa
                result.exponent = int(temp)
                Big.normalize(result)
                return result
        
        # a bit slower, still supports floats
        var newExponent: int = int(temp)
        var residue: float = temp - newExponent
        newMantissa = 10 ** (y * Big.log10(result.mantissa) + residue)
        if newMantissa != INF and newMantissa != -INF:
            result.mantissa = newMantissa
            result.exponent = newExponent
            Big.normalize(result)
            return result
        
        if round(y) != y:
            printerr("Big Error: Power function does not support large floats, use integers!")
        
        return powers(x, int(y))
    elif y is Big:
        if y.isEqualTo(0):
            return Big.new(1)
        if y.isLessThan(0):
            printerr("Big Error: Negative exponents are not supported!")
            return Big.new(0)

        var exponent_decremented:Big = y.minus(1)
        while exponent_decremented.isGreaterThan(0):  # warning - this might be slow!
            result.multiplyEquals(x)
            exponent_decremented.minusEquals(1)

        return result
    else:
        printerr("Big Error: Unknown/unsupported data type passed as an exponent in power function!")
        return x


## Square Roots a given Big number and returns the Big number result
static func root(x: Big) -> Big:
    var result:Big = Big.new(x)
    
    if result.exponent % 2 == 0:
        result.mantissa = sqrt(result.mantissa)
        @warning_ignore("integer_division")
        result.exponent = result.exponent / 2
    else:
        result.mantissa = sqrt(result.mantissa * 10)
        @warning_ignore("integer_division")
        result.exponent = (result.exponent - 1) / 2
    Big.normalize(result)
    return result


## Modulos a number and returns the Big number result
static func modulo(x, y) -> Big:
    x = Big._typeCheck(x)
    y = Big._typeCheck(y)

    var div := Big.division(x, y)
    div = Big.roundDown(div)

    var result := Big.subtract(x, Big.times(div, y))

    # Fix floating-point drift
    if result.isGreaterThanOrEqualTo(y):
        result = Big.subtract(result, y)
    if result.mantissa < 0:
        result = Big.add(result, y)

    Big.normalize(result)
    return result


## Rounds down a Big number
static func roundDown(x: Big) -> Big:
    var result:Big = Big.new(x)

    if result.exponent < 0:
        return Big.new(0)

    if result.exponent == 0:
        result.mantissa = floor(result.mantissa)
    else:
        var scaled:float = result.mantissa * pow(10.0, min(result.exponent, 15))
        scaled = floor(scaled)
        result.mantissa = scaled / pow(10.0, min(result.exponent, 15))

    Big.normalize(result)
    return result


## Equivalent of [code]min(Big, Big)[/code]
static func minValue(m, n) -> Big:
    m = Big._typeCheck(m)
    if m.isLessThan(n):
        return m
    else:
        return n


## Equivalent of [code]max(Big, Big)[/code]
static func maxValue(m, n) -> Big:
    m = Big._typeCheck(m)
    if m.isGreaterThan(n):
        return m
    else:
        return n


## Equivalent of [code]Big + n[/code]
func plus(n) -> Big:
    return Big.add(self, n)


## Equivalent of [code]Big += n[/code]
func plusEquals(n) -> Big:
    var new_value = Big.add(self, n)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Equivalent of [code]Big - n[/code]
func minus(n) -> Big:
    return Big.subtract(self, n)


## Equivalent of [code]Big -= n[/code]
func minusEquals(n) -> Big:
    var new_value: Big = Big.subtract(self, n)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Equivalent of [code]Big * n[/code]
func multiply(n) -> Big:
    return Big.times(self, n)


## Equivalent of [code]Big *= n[/code]
func multiplyEquals(n) -> Big:
    var new_value: Big = Big.times(self, n)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Equivalent of [code]Big / n[/code]
func divide(n) -> Big:
    return Big.division(self, n)


## Equivalent of [code]Big /= n[/code]
func divideEquals(n) -> Big:
    var new_value: Big = Big.division(self, n)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Equivalent of [code]Big % n[/code]
func mod(n) -> Big:
    return Big.modulo(self, n)


## Equivalent of [code]Big %= n[/code]
func modEquals(n) -> Big:
    var new_value:Big = Big.modulo(self, n)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Equivalent of [code]Big ** n[/code]
func power(n) -> Big:
    return Big.powers(self, n)


## Equivalent of [code]Big **= n[/code]
func powerEquals(n) -> Big:
    var new_value: Big = Big.powers(self, n)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Equivalent of [code]sqrt(Big)[/code]
func squareRoot() -> Big:
    return Big.root(self)


## Equivalent of [code]Big = sqrt(Big)[/code]
func squared() -> Big:
    var new_value:Big = Big.root(self)
    mantissa = new_value.mantissa
    exponent = new_value.exponent
    return self


## Negate the value
func negate() -> Big:
    return Big.new(-mantissa, exponent)


## sort function for use with [code]Array.sort_custom(Big.sort_increasing)[/code]
static func sort_increasing(a:Big, b:Big):
    if a.isLessThan(b):
        return true
    else:
        return false


## sort function for use with [code]Array.sort_custom(Big.sort_decreasing)[/code]
static func sort_decreasing(a:Big, b:Big):
    if a.isLessThan(b):
        return false
    else:
        return true


## Equivalent of [code]Big == n[/code]
func isEqualTo(n) -> bool:
    n = Big._typeCheck(n)
    Big.normalize(n)
    return n.exponent == exponent and is_equal_approx(n.mantissa, mantissa)


## Equivalent of [code]Big > n[/code]
func isGreaterThan(n) -> bool:
    return !isLessThanOrEqualTo(n)


## Equivalent of [code]Big >== n[/code]
func isGreaterThanOrEqualTo(n) -> bool:
    return !isLessThan(n)


## Equivalent of [code]Big < n[/code]
func isLessThan(n) -> bool:
    n = Big._typeCheck(n)
    Big.normalize(n)
    if (mantissa == 0
            and (n.mantissa > MANTISSA_PRECISION or mantissa < MANTISSA_PRECISION)
            and n.mantissa == 0
    ):
        return false
    if exponent < n.exponent:
        if exponent == n.exponent - 1 and mantissa > 10*n.mantissa:	
            return false #9*10^3 > 0.1*10^4
        return true
    elif exponent == n.exponent:
        if mantissa < n.mantissa:
            return true
        return false
    else:
        if exponent == n.exponent + 1 and mantissa * 10 < n.mantissa:
            return true
        return false


## Equivalent of [code]Big <= n[/code]
func isLessThanOrEqualTo(n) -> bool:
    n = Big._typeCheck(n)
    Big.normalize(n)
    if isLessThan(n):
        return true
    if n.exponent == exponent and is_equal_approx(n.mantissa, mantissa):
        return true
    return false


static func log10(x) -> float:
    return log(x) * 0.4342944819032518


func absLog10() -> float:
    return exponent + Big.log10(abs(mantissa))


func ln() -> float:
    return 2.302585092994045 * logN(10)


func logN(base) -> float:
    return (2.302585092994046 / log(base)) * (exponent + Big.log10(mantissa))


func pow10(value: int) -> void:
    mantissa = 10 ** (value % 1)
    exponent = int(value)


## Sets the Thousand name option
static func setThousandName(name: String) -> void:
    options.thousand_name = name


## Sets the Thousand Separator option
static func setThousandSeparator(separator: String) -> void:
    options.thousand_separator = separator


## Sets the Decimal Separator option
static func setDecimalSeparator(separator: String) -> void:
    options.decimal_separator = separator


## Sets the Suffix Separator option
static func setSuffixSeparator(separator: String) -> void:
    options.suffix_separator = separator


## Sets the Reading Separator option
static func setReadingSeparator(separator: String) -> void:
    options.reading_separator = separator


## Sets the Dynamic Decimals option
static func setDynamicDecimals(d: bool) -> void:
    options.dynamic_decimals = d


## Sets the Dynamic numbers digits option
static func setDynamicNumbers(d: int) -> void:
    options.dynamic_numbers = d


## Sets the maximum trailing zeroes option
static func setMaximumTrailingZeroes(d: int) -> void:
    options.maximum_trailing_zeroes = d


## Sets the small decimal digits option
static func setSmallDecimals(d: int) -> void:
    options.small_decimals = d


## Sets the thousand decimal digits option
static func setThousandDecimals(d: int) -> void:
    options.thousand_decimals = d


## Sets the big decimal digits option
static func setBigDecimals(d: int) -> void:
    options.big_decimals = d


## Sets the scientific notation decimal digits option
static func setScientificDecimals(d: int) -> void:
    options.scientific_decimals = d


## Sets the logarithmic notation decimal digits option
static func setLogarithmicDecimals(d: int) -> void:
    options.logarithmic_decimals = d


## Converts the Big Number into a string
func toString() -> String:
    var mantissa_decimals:int = 0
    var mantissa_string:String = str(mantissa)
    if mantissa_string.find(".") >= 0:
        mantissa_decimals = mantissa_string.split(".")[1].length()
    if mantissa_decimals > exponent:
        if exponent < 248:
            return str(mantissa * 10 ** exponent)
        else:
            return toPlainScientific()
    else:
        mantissa_string = mantissa_string.replace(".", "")
        for _i in range(exponent-mantissa_decimals):
            mantissa_string += "0"
        return mantissa_string


## Converts the Big Number into a string (in plain Scientific format)
func toPlainScientific() -> String:
    return str(mantissa) + "e" + str(exponent)


## Converts the Big Number into a string (in Scientific format)
func toScientific(no_decimals_on_small_values = false, force_decimals = false) -> String:
    if exponent < 3:
        var decimal_increments: float = 1 / (10 ** options.scientific_decimals / 10)
        var value:String = str(snappedf(mantissa * 10 ** exponent, decimal_increments))
        var split:PackedStringArray = value.split(".")
        if no_decimals_on_small_values:
            return split[0]
        if split.size() > 1:
            for i in range(options.logarithmic_decimals):
                if split[1].length() < options.scientific_decimals:
                    split[1] += "0"
            return split[0] + options.decimal_separator + split[1].substr(0,min(options.scientific_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.scientific_decimals))
        else:
            return value
    else:
        var split:PackedStringArray = str(mantissa).split(".")
        if split.size() == 1:
            split.append("")
        if force_decimals:
            for i in range(options.scientific_decimals):
                if split[1].length() < options.scientific_decimals:
                    split[1] += "0"
        return split[0] + options.decimal_separator + split[1].substr(0,min(options.scientific_decimals, options.dynamic_numbers-1 - str(exponent).length() if options.dynamic_decimals else options.scientific_decimals)) + "e" + str(exponent)


## Converts the Big Number into a string (in Logarithmic format)
func toLogarithmic(no_decimals_on_small_values = false) -> String:
    var decimal_increments: float = 1 / (10 ** options.logarithmic_decimals / 10)
    if exponent < 3:
        var value:String = str(snappedf(mantissa * 10 ** exponent, decimal_increments))
        var split:PackedStringArray = value.split(".")
        if no_decimals_on_small_values:
            return split[0]
        if split.size() > 1:
            for i in range(options.logarithmic_decimals):
                if split[1].length() < options.logarithmic_decimals:
                    split[1] += "0"
            return split[0] + options.decimal_separator + split[1].substr(0,min(options.logarithmic_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.logarithmic_decimals))
        else:
            return value
    var dec:String = str(snappedf(abs(log(mantissa) / log(10) * 10), decimal_increments))
    dec = dec.replace(".", "")
    for i in range(options.logarithmic_decimals):
        if dec.length() < options.logarithmic_decimals:
            dec += "0"
    var formated_exponent:String = formatExponent(exponent)
    dec = dec.substr(0, min(options.logarithmic_decimals, options.dynamic_numbers - formated_exponent.length() if options.dynamic_decimals else options.logarithmic_decimals))
    return "e" + formated_exponent + options.decimal_separator + dec


## Formats an exponent for string format
func formatExponent(value) -> String:
    if value < 1000:
        return str(value)
    var string:String = str(value)
    var string_mod:int = string.length() % 3
    var output:String = ""
    for i in range(0, string.length()):
        if i != 0 and i % 3 == string_mod:
            output += options.thousand_separator
        output += string[i]
    return output


## Converts the Big Number into a float
func toFloat() -> float:
    return snappedf(float(str(mantissa) + "e" + str(exponent)),MANTISSA_PRECISION)


func toFloat2() -> float:
    if exponent < POW10.size() and exponent >= 0:
        return mantissa * POW10[exponent]
    return mantissa * pow(10.0, exponent)


func toFloat3() -> float:
    return float(str(mantissa) + "e" + str(exponent))


func toPrefix(no_decimals_on_small_values = false, use_thousand_symbol=true, force_decimals=true, scientic_prefix=false) -> String:
    var number:float = mantissa
    if not scientic_prefix:
        var hundreds = 1
        for _i in range(exponent % 3):
            hundreds *= 10
        number *= hundreds

    var split:PackedStringArray = str(number).split(".")
    if split.size() == 1:
        split.append("")
    if force_decimals:
        var max_decimals = max(max(options.small_decimals, options.thousand_decimals), options.big_decimals)
        for i in range(max_decimals):
            if split[1].length() < max_decimals:
                split[1] += "0"
    
    if no_decimals_on_small_values and exponent < 3:
        return split[0]
    elif exponent < 3:
        if options.small_decimals == 0 or split[1] == "":
            return split[0]
        else:
            return split[0] + options.decimal_separator + split[1].substr(0,min(options.small_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.small_decimals))
    elif exponent < 6:
        if options.thousand_decimals == 0 or (split[1] == "" and use_thousand_symbol):
            return split[0]
        else:
            if use_thousand_symbol: # when the prefix is supposed to be using with a K for thousand
                for i in range(options.maximum_trailing_zeroes):
                    if split[1].length() < options.maximum_trailing_zeroes:
                        split[1] += "0"
                return split[0] + options.decimal_separator + split[1].substr(0,min(options.thousand_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else 3))
            else:
                for i in range(options.maximum_trailing_zeroes):
                    if split[1].length() < options.maximum_trailing_zeroes:
                        split[1] += "0"
                return split[0] + options.thousand_separator + split[1].substr(0,3)
    else:
        if options.big_decimals == 0 or split[1] == "":
            return split[0]
        else:
            return split[0] + options.decimal_separator + split[1].substr(0,min(options.big_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.big_decimals))


func _latinPower(european_system) -> int:
    if european_system:
        @warning_ignore("integer_division")
        return int(exponent / 3) / 2
    @warning_ignore("integer_division")
    return int(exponent / 3) - 1


func _latinPrefix(european_system) -> String:
    var ones:int = _latinPower(european_system) % 10
    var tens:int = int(_latinPower(european_system) / floor(10)) % 10
    @warning_ignore("integer_division")
    var hundreds:int = int(_latinPower(european_system) / 100) % 10
    @warning_ignore("integer_division")
    var millias:int = int(_latinPower(european_system) / 1000) % 10

    var prefix:String = ""
    if _latinPower(european_system) < 10:
        prefix = latin_special[ones] + options.reading_separator + latin_tens[tens] + options.reading_separator + latin_hundreds[hundreds]
    else:
        prefix = latin_hundreds[hundreds] + options.reading_separator + latin_ones[ones] + options.reading_separator + latin_tens[tens]

    for _i in range(millias):
        prefix = "millia" + options.reading_separator + prefix

    return prefix.lstrip(options.reading_separator).rstrip(options.reading_separator)


func _tillionOrIllion(european_system) -> String:
    if exponent < 6:
        return ""
    var powerKilo:int = _latinPower(european_system) % 1000
    if powerKilo < 5 and powerKilo > 0 and _latinPower(european_system) < 1000:
        return ""
    if (
            powerKilo >= 7 and powerKilo <= 10
            or int(powerKilo / floor(10)) % 10 == 1
    ):
        return "i"
    return "ti"


func _llionOrLliard(european_system) -> String:
    if exponent < 6:
        return ""
    if int(exponent/floor(3)) % 2 == 1 and european_system:
        return "lliard"
    return "llion"


func getLongName(european_system = false, prefix="") -> String:
    if exponent < 6:
        return ""
    else:
        return prefix + _latinPrefix(european_system) + options.reading_separator + _tillionOrIllion(european_system) + _llionOrLliard(european_system)


## Converts the Big Number into a string (in American Long Name format)
func toAmericanName(no_decimals_on_small_values = false) -> String:
    return toLongName(no_decimals_on_small_values, false)


## Converts the Big Number into a string (in European Long Name format)
func toEuropeanName(no_decimals_on_small_values = false) -> String:
    return toLongName(no_decimals_on_small_values, true)


## Converts the Big Number into a string (in Latin Long Name format)
func toLongName(no_decimals_on_small_values = false, european_system = false) -> String:
    if exponent < 6:
        if exponent > 2:
            return toPrefix(no_decimals_on_small_values) + options.suffix_separator + options.thousand_name
        else:
            return toPrefix(no_decimals_on_small_values)

    var suffix = _latinPrefix(european_system) + options.reading_separator + _tillionOrIllion(european_system) + _llionOrLliard(european_system)

    return toPrefix(no_decimals_on_small_values) + options.suffix_separator + suffix


## Converts the Big Number into a string (in Metric Symbols format)
func toMetricSymbol(no_decimals_on_small_values = false) -> String:
    @warning_ignore("integer_division")
    var target:int = int(exponent / 3)

    if not suffixes_metric_symbol.has(target):
        return toScientific()
    else:
        return toPrefix(no_decimals_on_small_values) + options.suffix_separator + suffixes_metric_symbol[target]


## Converts the Big Number into a string (in Metric Name format)
func toMetricName(no_decimals_on_small_values = false) -> String:
    @warning_ignore("integer_division")
    var target:int = int(exponent / 3)

    if not suffixes_metric_name.has(target):
        return toScientific()
    else:
        return toPrefix(no_decimals_on_small_values) + options.suffix_separator + suffixes_metric_name[target]


## Converts the Big Number into a string (in AA format)
func toAA(no_decimals_on_small_values = false, use_thousand_symbol = true, force_decimals=false) -> String:
    @warning_ignore("integer_division")
    var target:int = int(exponent / 3)
    var suffix:String = suffixes_aa.get(target, "")
    if suffix == "":
        var offset:int = target + 22
        var base:int = alphabet_aa.size()
        while offset > 0:
            offset -= 1
            var digit:int = offset % base
            suffix = alphabet_aa[digit] + suffix
            offset /= base
        suffixes_aa[target] = suffix
    else:
        suffix = suffixes_aa[target]

    var prefix:String = toPrefix(no_decimals_on_small_values, use_thousand_symbol, force_decimals)

    if target == 0 or (not use_thousand_symbol and target == 1):
        return prefix

    return prefix + options.suffix_separator + suffix


## Check function
static func check(label:String, actual:Big, expected:Big) -> void:
    if actual.isEqualTo(expected):
        print("[PASS] ", label, " -> ", actual.toPlainScientific())
    else:
        print("[FAIL] ", label)
        print("   Expected: ", expected.toPlainScientific())
        print("   Got:      ", actual.toPlainScientific())


## Check serialization function
static func check_serialization(label:String, value:Big) -> void:
    var serialized:String = value.toPlainScientific()
    var deserialized:Big = Big.new(serialized)

    if deserialized.isEqualTo(value):
        print("[PASS] ", label, " -> ", serialized)
    else:
        print("[FAIL] ", label)
        print("   Serialized:   ", serialized)
        print("   Deserialized: ", deserialized.toPlainScientific())
        print("   Original:     ", value.toPlainScientific())


static func tests() -> void:
    print("=== Big Number Tests ===")

    # --- Basic addition ---
    check("1 + 1",
        Big.add(1, 1),
        Big.new(2)
    )

    # --- Different exponents ---
    check("1e3 + 1e2",
        Big.add(Big.new(1, 3), Big.new(1, 2)),
        Big.new(1.1, 3)
    )

    # --- Large exponent difference (should ignore small) ---
    check("1e10 + 1",
        Big.add(Big.new(1, 10), Big.new(1)),
        Big.new(1, 10)
    )

    # --- Negative numbers ---
    check("5 - 3",
        Big.subtract(5, 3),
        Big.new(2)
    )

    check("3 - 5",
        Big.subtract(3, 5),
        Big.new(-2)
    )

    # --- Multiplication ---
    check("2 * 3",
        Big.times(2, 3),
        Big.new(6)
    )

    check("1e3 * 1e3",
        Big.times(Big.new(1, 3), Big.new(1, 3)),
        Big.new(1, 6)
    )

    # --- Division ---
    check("6 / 3",
        Big.division(6, 3),
        Big.new(2)
    )

    check("1e6 / 1e3",
        Big.division(Big.new(1, 6), Big.new(1, 3)),
        Big.new(1, 3)
    )

    # --- Power ---
    check("2^3",
        Big.powers(Big.new(2), 3),
        Big.new(8)
    )

    check("10^6",
        Big.powers(Big.new(10), 6),
        Big.new(1, 6)
    )

    # --- Root ---
    check("sqrt(1e6)",
        Big.root(Big.new(1, 6)),
        Big.new(1, 3)
    )

    # --- Modulo ---
    check("11 % 3",
        Big.modulo(11, 3),
        Big.new(2)
    )

    check("1e5 % 3",
        Big.modulo(Big.new(1, 5), 3),
        Big.new(1)
    )

    # --- Round down ---
    check("roundDown(1.9)",
        Big.roundDown(Big.new(1.9)),
        Big.new(1)
    )

    # --- Comparisons ---
    var a:Big = Big.new(1, 5)
    var b:Big = Big.new(9, 4)

    if a.isGreaterThan(b):
        print("[PASS] comparison (1e5 > 9e4)")
    else:
        print("[FAIL] comparison (1e5 > 9e4)")

    # --- Normalization ---
    var n:Big = Big.new(1000)
    if n.exponent == 3 and is_equal_approx(n.mantissa, 1.0):
        print("[PASS] normalization (1000 -> 1e3)")
    else:
        print("[FAIL] normalization (1000 -> 1e3): ", n.toPlainScientific())

    # --- Basic serialization ---
    check_serialization("serialize 0", Big.new(0))
    check_serialization("serialize 1", Big.new(1))
    check_serialization("serialize -1", Big.new(-1))

    # --- Small numbers ---
    check_serialization("serialize 123", Big.new(123))
    check_serialization("serialize 999.99", Big.new(999.99))

    # --- Large numbers ---
    check_serialization("serialize 1e6", Big.new(1, 6))
    check_serialization("serialize 1.23e12", Big.new(1.23, 12))
    check_serialization("serialize 9.99e100", Big.new(9.99, 100))

    # --- Very large exponent (forces scientific format) ---
    check_serialization("serialize huge exponent", Big.new(1.2345, 300))

    # --- Edge cases around normalization ---
    check_serialization("serialize 10 (should normalize to 1e1)", Big.new(10))
    check_serialization("serialize 0.1 (should normalize)", Big.new(0.1))

    # --- Negative values ---
    check_serialization("serialize -1e6", Big.new(-1, 6))
    check_serialization("serialize -3.21e9", Big.new(-3.21, 9))

    # --- Precision-sensitive values ---
    check_serialization("serialize 1.0000001", Big.new(1.0000001))
    check_serialization("serialize 9.9999999e5", Big.new(9.9999999, 5))

    # --- Arithmetic + serialization ---
    var c:Big = Big.add(Big.new(1, 10), Big.new(5, 5))
    check_serialization("serialize after add", c)

    var d:Big = Big.times(Big.new(3.3, 4), Big.new(2.2, 3))
    check_serialization("serialize after multiply", d)

    var e:Big = Big.division(Big.new(1, 10), Big.new(3))
    check_serialization("serialize after division", e)

    print("=== Tests Complete ===")
