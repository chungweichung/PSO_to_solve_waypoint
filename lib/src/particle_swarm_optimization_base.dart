import 'dart:math';
import 'package:navigation/navigation.dart';
import 'package:particle_swarm_optimization/src/route.dart';
import 'package:vector_math/vector_math.dart';

class ParticleSwarmOptimization {
  Position start, end;
  double wMax, wMin, c1, c2;
  double tolerance;
  int iterationNum, particleNum, wayPointNum;
  double r1 = Random().nextDouble(), r2 = Random().nextDouble();
  bool isEllipticMeridianal, isEllipticLat;

  late Route globalBest;
  List<Route> v = [];
  List<Route> personalBest = [], particles = [];
  double globalBestDistance = double.infinity;
  List<double> personalBestDistance = [];
  List<double> globalBestHistory = [];
  List<List<Route>> history = [];
  ParticleSwarmOptimization(
      {required this.start,
      required this.end,
      required this.wayPointNum,
      this.iterationNum = 100,
      this.particleNum = 100,
      this.c1 = 0.5,
      this.c2 = 0.5,
      this.wMax = 0.9,
      this.wMin = 0.2,
      this.tolerance = 0.0000001,
      this.isEllipticMeridianal = false,
      this.isEllipticLat = false});

  double totalDistance(Route route) {
    double distance = start.mercatorDistanceTo(route.waypoints[0],
        isEllipticLat: isEllipticLat,
        isEllipticMeridianal: isEllipticMeridianal);
    distance += route.mercatorDistanceTo(
        isEllipticLat: isEllipticLat,
        isEllipticMeridianal: isEllipticMeridianal);
    distance += route.waypoints.last.mercatorDistanceTo(end,
        isEllipticLat: isEllipticLat,
        isEllipticMeridianal: isEllipticMeridianal);

    return distance;
  }

  Route _sortByLong(Route route) {
    for (int i = 0; i < route.waypoints.length; i++) {
      bool swapped = false;
      for (int j = 0; j < route.waypoints.length - i - 1; j++) {
        if (route.waypoints[j].dLong(start) >
            route.waypoints[j + 1].dLong(start)) {
          swapped = true;
          Position temp = route.waypoints[j];
          route.waypoints[j] = route.waypoints[j + 1].clone();
          route.waypoints[j + 1] = temp.clone();
        }
      }
      if (swapped == false) {
        break;
      }
    }
    return route;
  } //need unit test

  /*Position _randomPosition({Position? beging, Position? finish}) {
    if (beging == null || finish == null) {
      return Position(-pi / 2 + Random().nextDouble() * pi,
          -pi + Random().nextDouble() * 2 * pi);
    } else {
      double dLon = difLong(startLong: beging.long, endLong: finish.long);
      double randomLong = addDLon(beging.long, dLon);
      double randomLat =
          beging.lat + Random().nextDouble() * (finish.lat - beging.lat);
      return Position(randomLat, randomLong);
    }
  }*/

  void init() {
    for (int i = 0; i < particleNum; i++) {
      Route randomRoute = Route.random(wayPointNum, start: start, end: end);
      randomRoute = _sortByLong(randomRoute);
      particles.add(randomRoute.clone());
      personalBest.add(randomRoute.clone());
      personalBestDistance.add(totalDistance(randomRoute));
      if (personalBestDistance[i] < globalBestDistance) {
        globalBest = personalBest[i].clone();
        globalBestDistance = personalBestDistance[i];
      }
      randomRoute.clear();
      v.add(Route.zero(wayPointNum));
    }
  }

  void _updateVelocityAndPosition(int currentIteration) {
    double w = (wMax - wMin) * pow(currentIteration / iterationNum, 2) +
        (wMin - wMax) * (2 * currentIteration / iterationNum) +
        wMax; //w2
    r1 = Random().nextDouble();
    r2 = Random().nextDouble();
    for (int i = 0; i < particleNum; i++) {
      v[i] = v[i] * w +
          (personalBest[i] - particles[i]) * c1 * r1 +
          (globalBest - particles[i]) * c2 * r2;
      particles[i] = particles[i] + v[i];
      limit(i);
    }
  }

  void limit(int particleIndex) {
    double dLon = start.dLong(end);
    bool isNeedSort = false;
    for (int i = 0; i < wayPointNum; i++) {
      //need limit long in route
      if (start.dLong(particles[particleIndex].waypoints[i]).abs() >
              dLon.abs() ||
          particles[particleIndex].waypoints[i].long < -pi ||
          particles[particleIndex].waypoints[i].long > pi) {
        particles[particleIndex].waypoints[i] = Position.random(start, end);
        isNeedSort = true;
      }
    }
    if (isNeedSort) {
      particles[particleIndex] = _sortByLong(particles[particleIndex]);
    }
  }

  (Route, double) optimize() {
    double lastGlobalBestDistance = double.infinity;
    double currentTolerance = double.infinity;
    int currentIteration = 0;
    init();

    while (currentIteration <= iterationNum) {
      for (int i = 0; i < particleNum; i++) {
        if (totalDistance(particles[i]) <= personalBestDistance[i]) {
          personalBest[i] = particles[i].clone();
          personalBestDistance[i] = totalDistance(particles[i]);
          if (personalBestDistance[i] < globalBestDistance) {
            globalBest = personalBest[i].clone();
            globalBestDistance = personalBestDistance[i];
          }
        }
      }
      history.add(personalBest.map((e) => e.clone()).toList());
      _updateVelocityAndPosition(currentIteration);
      currentTolerance = lastGlobalBestDistance - globalBestDistance;
      lastGlobalBestDistance = globalBestDistance;
      globalBestHistory.add(globalBestDistance);
      currentIteration++;
      //print(degrees(globalBestDistance) * 60);
    }
    return (globalBest, globalBestDistance);
  }
}
