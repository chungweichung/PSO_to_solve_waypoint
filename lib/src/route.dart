import 'package:navigation/navigation.dart';

class Route {
  List<Position> waypoints;
  Route(this.waypoints);

  Route.clone(Route other)
      : waypoints = other.waypoints.map((p) => p.clone()).toList();
  Route clone() {
    return Route.clone(this);
  }

  Route.zero(int wayPointNum)
      : waypoints = List.generate(wayPointNum, (i) => Position(0, 0));
  Route.random(int wayPointNum, {Position? start, Position? end})
      : waypoints =
            List.generate(wayPointNum, (i) => Position.random(start, end));

  Route operator *(num factor) {
    return Route(waypoints.map((p) => p * factor).toList());
  }

  Route operator +(Route other) {
    List<Position> newWaypoints = [];
    int maxLength = waypoints.length > other.waypoints.length
        ? waypoints.length
        : other.waypoints.length;
    for (int i = 0; i < maxLength; i++) {
      Position pos1 = i < waypoints.length ? waypoints[i] : Position(0, 0);
      Position pos2 =
          i < other.waypoints.length ? other.waypoints[i] : Position(0, 0);
      newWaypoints.add(pos1 + pos2);
    }
    return Route(newWaypoints);
  }

  Route operator -(Route other) {
    List<Position> newWaypoints = [];
    int maxLength = waypoints.length > other.waypoints.length
        ? waypoints.length
        : other.waypoints.length;
    for (int i = 0; i < maxLength; i++) {
      Position pos1 = i < waypoints.length ? waypoints[i] : Position(0, 0);
      Position pos2 =
          i < other.waypoints.length ? other.waypoints[i] : Position(0, 0);
      newWaypoints.add(pos1 - pos2);
    }
    return Route(newWaypoints);
  }

  double greatCircleDistanceTo() {
    Map sail;
    double totalDistance = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      sail = GreatCircle(start: waypoints[i]).to(waypoints[i + 1]);
      totalDistance += sail['distance'];
    }

    return totalDistance;
  }

  double mercatorDistanceTo(
      {bool isEllipticMeridianal = true, bool isEllipticLat = false}) {
    Map sail;
    double totalDistance = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      sail = MercatorSailing(start: waypoints[i]).to(waypoints[i + 1],
          isEllipticLat: isEllipticLat,
          isEllipticMeridianal: isEllipticMeridianal);
      totalDistance += sail['distance'];
    }

    return totalDistance;
  }

  void add(Position position) => waypoints.add(position);
  void clear() => waypoints.clear();
  @override
  String toString() => 'Route(waypoints: $waypoints)';
}
