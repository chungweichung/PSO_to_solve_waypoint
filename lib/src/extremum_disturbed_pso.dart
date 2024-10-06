import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:navigation/navigation.dart';
import 'package:particle_swarm_optimization/particle_swarm_optimization.dart';
import 'package:particle_swarm_optimization/src/route.dart';

class ExtremumDisturbedPSO extends ParticleSwarmOptimization {
  late List<int> currentPersonalStalled;
  int currentGlobalStalled = 0;
  double r4 = 1;
  late List<double>r3;
  int maxPersonalStalled, maxGlobalStalled;
  ExtremumDisturbedPSO({
    this.maxGlobalStalled = 3,
    this.maxPersonalStalled = 3,
    required Position start,
    required Position end,
    required int wayPointNum,
    int iterationNum = 100,
    int particleNum = 100,
    double c1 = 0.5,
    double c2 = 0.5,
    double wMax = 0.9,
    double wMin = 0.2,
    double tolerance = 0.0000001,
    bool isEllipticMeridianal = false,
    bool isEllipticLat = false,
  }) : super(
          start: start,
          end: end,
          wayPointNum: wayPointNum,
          iterationNum: iterationNum,
          particleNum: particleNum,
          c1: c1,
          c2: c2,
          wMax: wMax,
          wMin: wMin,
          tolerance: tolerance,
          isEllipticMeridianal: isEllipticMeridianal,
          isEllipticLat: isEllipticLat,
        ) {
    
      currentPersonalStalled = List.filled(particleNum, 0);
      r3 = List.filled(particleNum, 1);
  }

  @override
  void _updateVelocityAndPosition(int currentIteration) {
    double w = (wMax - wMin) * pow(currentIteration / iterationNum, 2) +
        (wMin - wMax) * (2 * currentIteration / iterationNum) +
        wMax; //w2
    r1 = Random().nextDouble();
    r2 = Random().nextDouble();
    //r3 = currentPersonalStalled <= maxPersonalStalled ? 1 : Random().nextDouble();
    r4 = currentGlobalStalled <= maxGlobalStalled ? 1 : 0.5+Random().nextDouble();
    for (int i = 0; i < particleNum; i++) {
      v[i] = v[i] * w +
          (personalBest[i]*r3[i] - particles[i]) * c1 * r1 +
          (globalBest * r4 - particles[i]) * c2 * r2;
      particles[i] = particles[i] + v[i];
      limit(i);
    }
  }

  @override
  (Route, double) optimize() {
    // TODO: implement optimize
    double lastGlobalBestDistance = double.infinity;
    double currentTolerance = double.infinity;
    int currentIteration = 0;
    init();

    while (currentIteration < iterationNum) {
      bool globalImproved = false;
      for (int i = 0; i < particleNum; i++) {
        if (totalDistance(particles[i]) < personalBestDistance[i]) {
          personalBest[i] = particles[i].clone();
          personalBestDistance[i] = totalDistance(particles[i]);
          if (personalBestDistance[i] < globalBestDistance) {
            globalBest = personalBest[i].clone();
            globalBestDistance = personalBestDistance[i];
            globalImproved = true;
            currentGlobalStalled = 0;
          }
          currentPersonalStalled[i] = 0;
        } else {
          currentPersonalStalled[i]++;
          r3[i]=currentPersonalStalled[i] <= maxPersonalStalled? 1 : 0.5+Random().nextDouble();
        }
      }

      if (!globalImproved) {
        currentGlobalStalled++;
      }
      _updateVelocityAndPosition(currentIteration);
      currentTolerance = lastGlobalBestDistance - globalBestDistance;
      lastGlobalBestDistance = globalBestDistance;
      currentIteration++;
      //print(degrees(globalBestDistance) * 60);
    }
    return (globalBest, globalBestDistance);
  }
}
