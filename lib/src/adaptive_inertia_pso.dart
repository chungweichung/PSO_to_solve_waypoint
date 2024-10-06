import 'dart:math';

import 'package:particle_swarm_optimization/particle_swarm_optimization.dart';
import 'package:particle_swarm_optimization/src/route.dart';
import 'package:vector_math/vector_math.dart';

class AdaptiveInertiaPSO extends ParticleSwarmOptimization {
  late List<double> w;
  AdaptiveInertiaPSO({
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
  }) {
    w = List.filled(particleNum, 0);
  }

  @override
  void _updateVelocityAndPosition(int currentIteration) {
    r1 = Random().nextDouble();
    r2 = Random().nextDouble();
    for (int i = 0; i < particleNum; i++) {
      v[i] = v[i] * w[i] +
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
    double tempPersonalBestValue;
    double totlalValueAtIter=0;
    double averageValueAtIter;

    init();

    while (currentIteration < iterationNum) {
      totlalValueAtIter = 0;
      double minAtIteration = double.infinity;
      for (int i = 0; i < particleNum; i++) {
        tempPersonalBestValue = totalDistance(particles[i]);
        totlalValueAtIter += tempPersonalBestValue;
        averageValueAtIter = totlalValueAtIter / (i + 1);
        if (tempPersonalBestValue <= personalBestDistance[i]) {
          personalBest[i] = particles[i].clone();
          personalBestDistance[i] = totalDistance(particles[i]);
          if (personalBestDistance[i] < globalBestDistance) {
            globalBest = personalBest[i].clone();
            globalBestDistance = personalBestDistance[i];
          }
        }
        if (tempPersonalBestValue < minAtIteration) {
          minAtIteration = tempPersonalBestValue;
        }
        if (tempPersonalBestValue < averageValueAtIter) {
          w[i] = wMin +
              (wMax - wMin) *
                  (tempPersonalBestValue - minAtIteration) /
                  (averageValueAtIter - minAtIteration);
        } else {
          w[i] = wMax;
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
