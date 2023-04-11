class Constraints
{
  Constraints({double? width, double? minWidth, double? maxWidth, double? height, double? minHeight, double? maxHeight})
  {
    this.width    = width;
    this.minWidth = minWidth;
    this.maxWidth = maxWidth;

    this.height    = width;
    this.minHeight = minHeight;
    this.maxHeight = maxHeight;
  }

  // width
  double? _width;
  set width(double? v) => _width = v;
  double? get width
  {
    if (_width == null) return null;
    if (_width == double.infinity || _width == double.negativeInfinity) return null;
    if (_width! < 0) return null;
    return _width;
  } 
  
  double? _minWidth;
  set minWidth(double? v) => _minWidth = v;
  double? get minWidth
  {
    if (_minWidth == null) return null;
    if (_minWidth == double.infinity || _minWidth == double.negativeInfinity) return null;
    if (_minWidth! < 0) return null;
    return _minWidth;
  }

  double? _maxWidth;
  set maxWidth(double? v) => _maxWidth = v;
  double? get maxWidth
  {
    if (_maxWidth == null) return null;
    if (_maxWidth == double.infinity || _maxWidth == double.negativeInfinity) return null;
    if (_maxWidth! < 0) return null;
    return _maxWidth;
  }

  // height
  double? _height;
  set height(double? v) => _height = v;
  double? get height
  {
    if (_height == null) return null;
    if (_height == double.infinity || _height == double.negativeInfinity) return null;
    if (_height! < 0) return null;
    return _height;
  }

  double? _minHeight;
  set minHeight(double? v) => _minHeight = v;
  double? get minHeight
  {
    if (_minHeight == null) return null;
    if (_minHeight == double.infinity || _minHeight == double.negativeInfinity) return null;
    if (_minHeight! < 0) return null;
    return _minHeight;
  }

  double? _maxHeight;
  set maxHeight(double? v) => _maxHeight = v;
  double? get maxHeight
  {
    if (_maxHeight == null) return null;
    if (_maxHeight == double.infinity || _maxHeight == double.negativeInfinity) return null;
    if (_maxHeight! < 0) return null;
    return _maxHeight;
  }

  bool get isNotEmpty => hasVerticalConstraints || hasHorizontalConstraints;
  bool get isEmpty => !isNotEmpty;

  bool get hasVerticalContractionConstraints
  {
    var h = height ?? minHeight ?? double.negativeInfinity;
    return h > double.negativeInfinity;
  }

  bool get hasVerticalExpansionConstraints
  {
    var h = height ?? maxHeight ?? double.infinity;
    return h < double.infinity;
  }

  bool get hasVerticalConstraints => hasVerticalExpansionConstraints || hasVerticalContractionConstraints;

  bool get hasHorizontalContractionConstraints
  {
    var w = width ?? minWidth ?? double.negativeInfinity;
    return w > double.negativeInfinity;
  }

  bool get hasHorizontalExpansionConstraints
  {
    var w = width ?? maxWidth ?? double.infinity;
    return w < double.infinity;
  }

  bool get hasHorizontalConstraints => hasHorizontalExpansionConstraints || hasHorizontalContractionConstraints;
}