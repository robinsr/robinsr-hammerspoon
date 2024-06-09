`hs.canvas.attributes` - Canvas Element Attribute
=================================================


## `type`

Specifies the type of canvas element the table represents. This attribute has no
default and must be specified for each element in the canvas array. Valid type
strings are:
 
### `arc`

An arc inscribed on a circle, defined by `radius`, `center`, `startAngle`, and
`endAngle`.

### `canvas`

An independent canvas object, displayed as an element within the specified
frame. Defined by `canvas` and `frame`.

### `circle`

A circle, defined by `radius` and `center`.

### `ellipticalArc`

An arc inscribed on an oval, defined by `frame`, `startAngle`, and `endAngle`.

### `image`

An image as defined by one of the `hs.image` constructors.

### `oval`

An oval, defined by `frame`

### `points`

A list of points defined in `coordinates`.

### `rectangle`

A rectangle, optionally with rounded corners, defined by `frame`.

### `resetClip`

A special type -- indicates that the current clipping shape should be reset to
the canvas default (the full canvas area).  See `Clipping Example`.  All other
attributes, except `action` are ignored.

### `segments`

A list of line segments or bezier curves with control points, defined in
`coordinates`.

### `text`

A string or `hs.styledtext` object, defined by `text` and `frame`.


***


## Attribues


The following is a list of all valid attributes.  Not all attributes apply to
every type, but you can set them for any type.


### `action`

A string specifying the action to take for the element in the array. The following actions are recognized:

* `clip` - append the shape to the current clipping region for the
  canvas. Ignored for `canvas`, `image`, and `text` types.
* `build` - do not render the element -- its shape is preserved and the
  next element in the canvas array is appended to it.  This can be used to
  create complex shapes or clipping regions. The stroke and fill settings for a
  complex object created in this manner will be those of the final object of
  the group. Ignored for `canvas`, `image`, and `text` types.
* `fill` - fill the canvas element, if it is a shape, or display it
  normally if it is a `canvas`, `image` or `text`.  Ignored for `resetClip`.
* `skip` - ignore this element or its effects.  Can be used to
  temporarily "remove" an object from the canvas.
* `stroke` - stroke (outline) the canvas element, if it is a shape, or
  display it normally if it is a `canvas`, `image` or `text`.  Ignored for
  `resetClip`.
* `strokeAndFill` - stroke and fill the canvas element, if it is a shape, or
  display it normally if it is a `canvas`, `image` or `text`.  Ignored for
  `resetClip`.

Default `strokeAndFill`


### `absolutePosition`

If false, numeric location and size attributes (`frame`, `center`, `radius`, and
`coordinates`) will be automatically adjusted when the canvas is resized with
[hs.canvas:size](#size) or [hs.canvas:frame](#frame) so that the element remains
in the same relative position in the canvas.

Default `true`. 


### `absoluteSize`

If false, numeric location and size attributes(`frame`, `center`, `radius`, and
`coordinates`) will be automatically adjusted when the canvas is resized with
[hs.canvas:size](#size) or [hs.canvas:frame](#frame) so that the element
maintains the same relative size in the canvas.

Default `true`


### `antialias`

Indicates whether or not antialiasing should be enabled for the element.

Default `true`


### `arcRadii`

Used by the `arc` and `ellipticalArc` types to specify whether or not line
segments from the element's center to the start and end angles should be
included in the element's visible portion.  This affects whether the object's
stroke is a pie-shape or an arc with a chord from the start angle to the end
angle.

Default `true`


### `arcClockwise`

Used by the `arc` and `ellipticalArc` types to specify whether
the arc should be drawn from the start angle to the end angle in a clockwise
(true) direction or in a counter-clockwise (false) direction.

Default `true`


### `canvas`

A separate canvas object which is to be displayed as an element
in this canvas.  The object must not currently belong to a visible window.
Assign nil to this property to release a previously assigned object for use
elsewhere as an element or on its own.

Defaults to `nil`


### `canvasAlpha`

Specifies the alpha value to apply to the independent canvas element.

Default `1.0`


### `compositeRule`

A string specifying how this element should be combined with earlier elements of
the canvas.  See [hs.canvas.compositeTypes](#compositeTypes) for a list of
valid strings and their descriptions.

default `"sourceOver"`


### `center`

Used by the `circle` and `arc` types to specify the center of the canvas
element.  The `x` and `y` fields can be specified as numbers or as a string.
When specified as a string, the value is treated as a percentage of the canvas
size.  See the section on [percentages](#percentages) for more information.

Default `{ x = "50%", y = "50%" }`


### `clipToPath`

Specifies whether the clipping regions should be temporarily
limited to the element's shape while rendering this element or not.  This can
be used to produce crisper edges, as seen with `hs.drawing` but reduces stroke
width granularity for widths less than 1.0 and causes occasional "missing"
lines with the `segments` element type. Ignored for the `canvas`, `image`,
`point`, and `text` types.

Default `false`


### `closed`

Used by the `segments` type to specify whether or not the
shape defined by the lines and curves defined should be closed (true) or open
(false).  When an object is closed, an implicit line is stroked from the final
point back to the initial point of the coordinates listed.

Default `false`


### `coordinates`

An array containing coordinates used by the `segments` and `points` types to
define the lines and curves or points that make up the canvas element.  The
following keys are recognized and may be specified as numbers or strings
(see the section on [percentages](#percentages)).


* `x`   - required for `segments` and `points`, specifying the x coordinate of a
  point.
* `y`   - required for `segments` and `points`, specifying the y coordinate of a
  point.
* `c1x` - optional for `segments`, specifying the x coordinate of the first
  control point used to draw a bezier curve between this point and the previous
  point.  Ignored for `points` and if present in the first coordinate in the
  `coordinates` array.
* `c1y` - optional for `segments`, specifying the y coordinate of the first
  control point used to draw a bezier curve between this point and the previous
  point.  Ignored for `points` and if present in the first coordinate in the
  `coordinates` array.
* `c2x` - optional for `segments`, specifying the x coordinate of the second
  control point used to draw a bezier curve between this point and the previous
  point.  Ignored for `points` and if present in the first coordinate in the
  `coordinates` array.
* `c2y` - optional for `segments`, specifying the y coordinate of the second
  control point used to draw a bezier curve between this point and the previous
  point.  Ignored for `points` and if present in the first coordinate in the
  `coordinates` array.


### `endAngle`

Used by the `arc` and `ellipticalArc` to specify the ending angle position for
the inscribed arc.

Default `360.0`


### `fillColor`

Specifies the color used to fill the canvas element when the `action` is set to
`fill` or `strokeAndFill` and `fillGradient` is equal to `none`.  Ignored for
the `canvas`, `image`, `points`, and `text` types.

Default `{ red = 1.0 }`


### `fillGradient`

A string specifying whether a fill gradient should be used instead of the fill
color when the action is `fill` or `strokeAndFill`.  Maybe "none", "linear",
or "radial".

Default `none`


### `fillGradientAngle`

Specifies the direction of a linear gradient when `fillGradient` is linear.

Default `0.0`


### `fillGradientCenter`

Specifies the relative center point within the elements bounds of a radial
gradient when `fillGradient` is `radial`.  The `x` and `y` fields must both be
between -1.0 and 1.0 inclusive.

Default `{ x = 0.0, y = 0.0 }`


### `fillGradientColors`

Specifies the colors to use for the gradient when `fillGradient` is not `none`.
You must specify at least two colors, each of which must be convertible into
the RGB color space (i.e. they cannot be an image being used as a color
pattern).  The gradient will blend from the first to the next, and so on until
the last color.  If more than two colors are specified, the "color stops" will
be placed at evenly spaced intervals within the element.

Default `{ { white = 0.0 }, { white = 1.0 } }`.


### `flatness`

A number which specifies the accuracy (or smoothness) with which
curves are rendered. It is also the maximum error tolerance (measured in
pixels) for rendering curves, where smaller numbers give smoother curves at the
expense of more computation.

Default `0.6`


### `flattenPath`

Specifies whether curved line segments should be converted into
straight line approximations. The granularity of the approximations is
controlled by the path's current flatness value.

Default `false`


### `frame`

Used by the `rectangle`, `oval`, `ellipticalArc`, `text`, `canvas` and `image`
types to specify the element's position and size.  When the key value for `x`,
`y`, `h`, or `w` are specified as a string, the value is treated as a
percentage of the canvas size.  See the section on 
[percentages](#percentages) for more information.

Default `{ x = "0%", y = "0%", h = "100%", w = "100%" }`


### `id`

An optional string or number which is included in mouse callbacks to identify
the element which was the target of the mouse event.  If this is not specified
for an element, it's index position is used instead.


### `image`

Used by the `image` type to specify an `hs.image` object to display as an image.

Defaults to a blank image.


### `imageAlpha`

A number between 0.0 and 1.0 specifying the alpha value to
be applied to the image specified by `image`.  Note that if an image is a
template image, then this attribute will internally default to `0.5` unless
explicitly set for the element.

Defaults to `1.0`


### `imageAlignment`

A string specifying the alignment of the image within the canvas element's
frame.  Valid values for this attribute are `center`, `bottom`, `topLeft`,
`bottomLeft`, `bottomRight`, `left`, `right`, `top`, and `topRight`.

Default `"center"`


### `imageAnimationFrame`

An integer specifying the image frame to display when the image is
from an animated GIF.  This attribute is ignored for other image types.  May be
specified as a negative integer indicating that the image frame should be
calculated from the last frame and calculated backwards (i.e. specifying `-1`
selects the last frame for the GIF.)

Default `0`


### `imageAnimates`

A boolean specifying whether or not an animated GIF should be
animated or if only a single frame should be shown.  Ignored for other image
types.

Default `false`


### `imageScaling`

A string specifying how the image should be scaled within the canvas element's
frame.  Valid values for this attribute are:


* `scaleToFit`          - shrink the image, preserving the aspect ratio, to fit
  the drawing frame only if the image is larger than the drawing frame.
* `shrinkToFit`         - shrink or expand the image to fully fill the drawing
  frame.  This does not preserve the aspect ratio.
* `none`                - perform no scaling or resizing of the image.
* `scaleProportionally` - shrink or expand the image to fully fill the drawing
  frame, preserving the aspect ration.

Default `"scaleProportionally"`


### `miterLimit`

The limit at which miter joins are converted to bevel join when
`strokeJoinStyle` is `miter`.

The miter limit helps you avoid spikes at the junction of two line segments.
When the ratio of the miter length—the diagonal length of the miter join—to the
line thickness exceeds the miter limit, the joint is converted to a bevel
join. 

Ignored for the `canvas`, `text`, and `image` types.

Default `10.0`


### `padding`

When an element specifies position information by percentage
(i.e. as a string), the actual frame used for calculating position values is
inset from the canvas frame on all sides by this amount. If you are using
shadows with your elements, the shadow position is not included in the
element's size and position specification; this attribute can be used to
provide extra space for the shadow to be fully rendered within the canvas.

Default `0.0`


### `radius`

Used by the `arc` and `circle` types to specify the radius of the
circle for the element. May be specified as a string or a number.  When
specified as a string, the value is treated as a percentage of the canvas size.

See the section on [percentages](#percentages) for more information.

Default `"50%"`


### `reversePath`

Specifies drawing direction for the canvas element.

By default, canvas elements are drawn from the point nearest the origin(top left
corner) in a clockwise direction.  Setting this to true causes the element to
be drawn in a counter-clockwise direction. This will mostly affect fill and
stroke dash patterns, but can also be used with clipping regions to create
cut-outs.  Ignored for `canvas`, `image`, and `text` types.

Default `false`


### `roundedRectRadii`

Default `{ xRadius = 0.0, yRadius = 0.0 }`.


### `shadow`

Specifies the shadow blurring, color, and offset to be added to an element which
has `withShadow` set to true.

Default `{ blurRadius = 5.0, color = { alpha = 1/3 }, offset = { h = -5.0, w =
5.0 } }`


### `startAngle`

Used by the `arc` and `ellipticalArc` to specify the starting angle position for
the inscribed arc.

Default `0.0`


### `strokeCapStyle`

A string which specifies the shape of the endpoints of an open
path when stroked.  Primarily noticeable for lines rendered with the `segments`
type.  Valid values for this attribute are "butt", "round", and "square".

Default `"butt"`


### `strokeColor`

Specifies the stroke (outline) color for a canvas element when the action is set
to `stroke` or `strokeAndFill`.  Ignored for the `canvas`, `text`, and `image`
types.

Default `{ white = 0 }`


### `strokeDashPattern`

Specifies an array of numbers specifying a dash pattern for stroked lines when
an element's `action` attribute is set to `stroke` or `strokeAndFill`.

The numbers in the array alternate with the first element specifying a dash
length in points, the second specifying a gap length in points, the third a
dash length, etc.  The array repeats to fully stroke the element.

Ignored for the `canvas`, `image`, and `text` types.

Default `{}`


### `strokeDashPhase`

Specifies an offset, in points, where the dash pattern specified
by `strokeDashPattern` should start. Ignored for the `canvas`, `image`, and
`text` types.

Default `0.0`


### `strokeJoinStyle`

A string which specifies the shape of the joints between
connected segments of a stroked path.  Valid values for this attribute
are "miter", "round", and "bevel".  Ignored for element types of `canvas`,
`image`, and `text`.

Default `"miter"`


### `strokeWidth`

Specifies the width of stroked lines when an element's action is
set to `stroke` or `strokeAndFill`.  Ignored for the `canvas`, `image`, and
`text` element types.

Default `1.0`


### `text`

Specifies the text to display for a `text` element.  This may be
specified as a string, or as an `hs.styledtext` object.

Default `""`


### `textAlignment`

Default `natural`. A string specifying the alignment of the text within a canvas
element of type `text`.  This field is ignored if the text is specified as an
`hs.styledtext` object.  Valid values for this attributes are:


* `left`      - the text is visually left aligned.
* `right`     - the text is visually right aligned.
* `center`    - the text is visually center aligned.
* `justified` - the text is justified
* `natural`   - the natural alignment of the text’s script


### `textColor`

Specifies the color to use when displaying the
`text` element type, if the text is specified as a string.  This field is
ignored if the text is specified as an `hs.styledtext` object.

Default `{ white = 1.0 }`


### `textFont`

A string specifying the name of the font to use when displaying the `text`
element type, if the text is specified as a string.  This field is ignored if
the text is specified as an `hs.styledtext` object.

Defaults to the default system font.


### `textLineBreak`

A string specifying how to wrap text which exceeds the
canvas element's frame for an element of type `text`.  This field is ignored if
the text is specified as an `hs.styledtext` object.  Valid values for this
attribute are:


* `wordWrap`       - wrap at word boundaries, unless the word itself doesn’t fit
  on a single line
* `charWrap`       - wrap before the first character that doesn’t fit
* `clip`           - do not draw past the edge of the drawing object frame
* `truncateHead`   - the line is displayed so that the end fits in the frame and
  the missing text at the beginning of the line is indicated by an ellipsis
* `truncateTail`   - the line is displayed so that the beginning fits in the
  frame and the missing text at the end of the line is indicated by an
  ellipsis
* `truncateMiddle` - the line is displayed so that the beginning and end fit in
  the frame and the missing text in the middle is indicated by an ellipsis

Default `wordWrap`. 


### `textSize`

Specifies the font size to use when displaying the `text`
element type, if the text is specified as a string.  This field is ignored if
the text is specified as an `hs.styledtext` object.

Default `27.0`


### `trackMouseByBounds`

If true, mouse events are based on the element's bounds
(smallest rectangle which completely contains the element); otherwise, mouse
events are based on the visible portion of the canvas element.

Default `false`

### `trackMouseEnterExit`

Generates a callback when the mouse enters or exits the canvas
element.  For `canvas` and `text` types, the `frame` of the element defines the
boundaries of the tracking area.

Default `false`

### `trackMouseDown`

Generates a callback when mouse button is clicked down while
the cursor is within the canvas element.  For `canvas` and `text` types, the
`frame` of the element defines the boundaries of the tracking area.

Default `false`

### `trackMouseUp`

Generates a callback when mouse button is released while the
cursor is within the canvas element.  For `canvas` and `text` types, the
`frame` of the element defines the boundaries of the tracking area.

Default `false`

### `trackMouseMove`

Generates a callback when the mouse cursor moves within the
canvas element.  For `canvas` and `text` types, the `frame` of the element
defines the boundaries of the tracking area.

Default `false`

### `transformation`


Specifies a matrix transformation to apply to the element before displaying it.

Transformations may include rotation, translation, scaling, skewing, etc.

Default 

```lua
{ 
  m11 = 1.0,
  m12 = 0.0,
  m21 = 0.0,
  m22 = 1.0,
  tX = 0.0,
  tY = 0.0
}
```


### `windingRule`

A string specifying the winding rule in effect for the
canvas element. May be "nonZero" or "evenOdd".  The winding rule determines
which portions of an element to fill. This setting will only have a visible
effect on compound elements (built with the `build` action) or elements of type
`segments` when the object is made from lines which cross.

Default `"nonZero"`


### `withShadow`

Specifies whether a shadow effect should be applied to the
canvas element.  Ignored for the `text` type.

Default `false`