import 'dart:math';

import 'package:navigation/navigation.dart';
import 'package:particle_swarm_optimization/particle_swarm_optimization.dart';
import 'package:particle_swarm_optimization/src/route.dart';
import 'package:vector_math/vector_math.dart';

class ParameterAdherePSO extends ParticleSwarmOptimization {
  List<double> globalBestHistory = [];
  ParameterAdherePSO({
    required super.start,
    required super.end,
    required super.wayPointNum,
    super.iterationNum,
    super.particleNum,
    super.c1,
    super.c2,
    super.wMax,
    super.wMin,
    super.tolerance,
    super.isEllipticMeridianal,
    super.isEllipticLat,
  });
  @override
  void _updateVelocityAndPosition(int currentIteration) {
    double w = (wMax - wMin) * pow(currentIteration / iterationNum, 2) +
        (wMin - wMax) * (2 * currentIteration / iterationNum) +
        wMax; //w2
    r1 = Random().nextDouble();
    r2 = Random().nextDouble();
    double parameterRule = (24 * (1 - pow(w, 2)) / (7 - 5 * w));
    c1 = parameterRule*(1-(currentIteration / iterationNum));
    c2 = parameterRule*((currentIteration / iterationNum));
    for (int i = 0; i < particleNum; i++) {
      v[i] = v[i] * w +
          (personalBest[i] - particles[i]) * c1 * r1 +
          (globalBest - particles[i]) * c2 * r2;
      particles[i] = particles[i] + v[i];
      limit(i);
    }
  }
  @override
  (Route, double) optimize() {
    double lastGlobalBestDistance = double.infinity;
    double currentTolerance = double.infinity;
    int currentIteration = 0;
    init();

    while (currentIteration < iterationNum) {
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
