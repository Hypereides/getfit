class Location {
  double? _latitude;
  double? _longitude;

  void setCoordinates(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  (double latitude, double longitude) getCoordinates() {
    assert(
      _latitude != null && _longitude != null,
      'setCoordinates() must be called before getCoordinates()',
    );
    return (_latitude!, _longitude!);
  }
}