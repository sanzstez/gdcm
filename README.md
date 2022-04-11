# GDCM

A ruby wrapper for [GDCM tools](http://gdcm.sourceforge.net/)

## Information

Inspired by MiniMagick ruby gem, this realization was created based on same DSL structure (but for GDCM tools).

## Requirements

GDCM command-line tool has to be installed. You can
check if you have it installed by running

```sh
$ gdcminfo --version
gdcminfo: gdcm 3.0.10
```

## Installation

Add the gem to your Gemfile:

```rb
gem "gdcm"
```

## Usage

Let's first see a basic example.

```rb
require "gdcm"

package = GDCM::Package.open("original.dcm")

package.convert do |convert|
  convert.raw
  convert.verbose
end

package.path
package.write "output.dcm"
```

`GDCM::Package.open` makes a copy of the package, and further methods modify
that copy (the original stays untouched). The writing part is necessary because
the copy is just temporary, it gets garbage collected when we lose reference
to the package.


On the other hand, if we want the original package to actually *get* modified,
we can use `GDCM::Package.new`.

```rb
package = GDCM::Package.new("original.dcm")
package.path

package.convert do |convert|
  convert.raw
  convert.verbose
end
# Not calling #write, because it's not a copy
```

### Attributes


To get the all information about the package, GDCM gives you a handy method
which returns the output from `gdcminfo` in hash format:

```rb
package.info.data #=>
#{"MediaStorage"=>"1.2.840.10008.5.1.4.1.1.77.1.5.1",                             
# "TransferSyntax"=>"1.2.840.10008.1.2.4.70",                                     
# "NumberOfDimensions"=>"2",                                                      
# "Dimensions"=>"(4000,4000,1)",                                                  
# "SamplesPerPixel"=>"3",                                                         
# "BitsAllocated"=>"8",                                                           
# "BitsStored"=>"8",                                                              
# "HighBit"=>"7",                                                                 
# "PixelRepresentation"=>"0",                                                     
# "ScalarType found"=>"UINT8",                                                    
# "PhotometricInterpretation"=>"RGB",                                             
# "PlanarConfiguration"=>"0",                                                     
# "Origin"=>"(0,0,0)",                                                            
# "Spacing"=>"(1,1,1)",
# "DirectionCosines"=>"(1,0,0,0,1,0)",
# "Rescale Intercept/Slope"=>"(0,1)",
# "Orientation Label"=>"AXIAL"}
```


### Configuration

```rb
GDCM.configure do |config|
  config.timeout = 5
end
```

### Package validation

By default, GDCM validates package each time it's opening them. It
validates them by running `gdcminfo` on them, and see if GDCM tools finds
them valid. This adds slight overhead to the whole processing. Sometimes it's
safe to assume that all input and output packages are valid by default and turn
off validation:

```rb
GDCM.configure do |config|
  config.validate_on_create = false
end
```

You can test whether an package is valid:

```rb
package.valid?
package.validate! # raises GDCM::Invalid if package is invalid
```

### Logging

You can choose to log GDCM commands and their execution times:

```rb
GDCM.logger.level = Logger::DEBUG
```
```
D, [2022-04-11T12:07:39.240238 #59063] DEBUG -- : [0.11s] gdcminfo /var/folders/4d/k113_9r544nfj8k0bfxtjx0m0000gn/T/gdcm20220411-59063-8yvk5s.dcm
```

In Rails you'll probably want to set `GDCM.logger = Rails.logger`.

### Metal

If you want to be close to the metal, you can use GDCM's command-line
tools directly.

```rb
GDCM::Tool::Convert.new do |convert|
  convert.raw
  convert.verbose
  convert << "input.dcm"
  convert << "output.dcm"
end #=> `gdcmconv --raw --verbose input.dcm output.dcm`

# OR

convert = GDCM::Tool::Convert.new
convert.raw
convert.verbose
convert << "input.dcm"
convert << "output.dcm"
convert.call #=> `gdcmconv --raw --verbose input.dcm output.dcm`
```

## Troubleshooting

### Errors being raised when they shouldn't


If you're using the tool directly, you can pass `whiny: false` value to the
constructor:

```rb
GDCM::Tool::Identify.new(whiny: false) do |b|
  b.help
end
```
