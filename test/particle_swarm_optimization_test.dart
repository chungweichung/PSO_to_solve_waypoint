import 'package:navigation/navigation.dart';
import 'package:particle_swarm_optimization/particle_swarm_optimization.dart';
import 'package:particle_swarm_optimization/src/adaptive_inertia_pso.dart';
import 'package:particle_swarm_optimization/src/parameter_adhere_pso.dart';
import 'package:particle_swarm_optimization/src/route.dart';
import 'package:test/scaffolding.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

void exportToCSV(List<double> data, String filename) {
  String csv = const ListToCsvConverter().convert([data]);
  File(filename).writeAsStringSync(csv);
}

void exportHistoryToCSV(List<List<Route>> data, String filename) {
  var history = Excel.createExcel();
  Sheet sheetObject = history['sheet1'];
  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      for (int k = 0; k < data[i][j].waypoints.length; k++) {
        sheetObject.updateCell(
            CellIndex.indexByColumnRow(
                columnIndex: 2 * (data[i][j].waypoints.length * j + k),
                rowIndex: i),
            DoubleCellValue(degrees(data[i][j].waypoints[k].lat)));
        sheetObject.updateCell(
            CellIndex.indexByColumnRow(
                columnIndex: 2 * (data[i][j].waypoints.length * j + k) + 1,
                rowIndex: i),
            DoubleCellValue(degrees(data[i][j].waypoints[k].long)));
      }
    }
  }
  File(filename).writeAsBytesSync(history.encode() ?? []);
}

void exportTableToCSV(List<List<double>> data, String filename) {
  var history = Excel.createExcel();
  Sheet sheetObject = history['sheet1'];
  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      sheetObject.updateCell(
          CellIndex.indexByColumnRow(
              columnIndex: i, //iteration
              rowIndex: j),
          DoubleCellValue(data[i][j]));
    }
  }
  File(filename).writeAsBytesSync(history.encode() ?? []);
}

void recommendedIterationAndParticleNum() {
  Position start_hsieh = Position(radians(34), radians(-120.66666666667));
  Position end_hsieh = Position(radians(20.1666666666667), radians(122));
  Position start_tseng = Position(radians(35), radians(-121));
  Position end_tseng = Position(radians(46.2), radians(144));
  double wMax = 0.9;
  double wMin = 0.2;
  double c1 = 0.5;
  double c2 = 0.5;
  Route route;
  double distance;
  double averageDistance = 0;
  List<List<double>> iteraAndParticleTable1 = [];
  List<double> temp = [];
  for (int itera = 800; itera <= 1100; itera += 25) {
    for (int particleNum = 800; particleNum <= 1100; particleNum += 25) {
      for (int i = 0; i < 1; i++) {
        // ignore: unused_local_variable
        ParticleSwarmOptimization PSO = ParticleSwarmOptimization(
            start: start_hsieh,
            end: end_hsieh,
            wayPointNum: 4,
            iterationNum: itera,
            particleNum: particleNum,
            wMax: wMax,
            wMin: wMin,
            c1: c1,
            c2: c2,
            isEllipticLat: false,
            isEllipticMeridianal: false);
        (route, distance) = PSO.optimize();
        averageDistance += distance;
      }
      temp.add(degrees(averageDistance) * 60 / 1);
      averageDistance = 0;
    }
    iteraAndParticleTable1.add(List.from(temp));
    temp.clear();
  }
  exportTableToCSV(iteraAndParticleTable1, 'iteraAndParticleTable3.xlsx');
}

void main() {
  recommendedIterationAndParticleNum();
  /*Position start_hsieh = Position(radians(34), radians(-120.66666666667));
  Position end_hsieh = Position(radians(20.1666666666667), radians(122));
  Position start_tseng = Position(radians(35), radians(-121));
  Position end_tseng = Position(radians(46.2), radians(144));
  int wayPointNum = 5;
  double wMax = 0.9;
  double wMin = 0.2;
  double c1 = 0.5;
  double c2 = 0.5;
  int particleNum = 5;
  int iterationNum = 1000;

  Route route;
  double distance;

  List<double> hsiehDistanceAPN = [];
  List<double> tsengDistanceAPN = [];
  List<double> hsiehDistanceSphere = [];
  List<double> tsengDistanceSphere = [];
  List<double> hsiehDistanceSpheroid = [];
  List<double> tsengDistanceSpheroid = [];

  //for (int i = 1; i <= 6; i++) {
  ParticleSwarmOptimization pso = ParticleSwarmOptimization(
      start: start_hsieh,
      end: end_hsieh,
      wayPointNum: 2,
      iterationNum: iterationNum,
      particleNum: particleNum,
      wMax: wMax,
      wMin: wMin,
      c1: c1,
      c2: c2,
      isEllipticLat: false,
      isEllipticMeridianal: true);
  (route, distance) = pso.optimize();
  hsiehDistanceAPN.add(degrees(distance) * 60);
//}
  exportToCSV(hsiehDistanceAPN, 'hsiehAPN.csv');
  exportHistoryToCSV(pso.history, 'history.xlsx');
  for (int i = 1; i <= 6; i++) {
    (route, distance) = ParticleSwarmOptimization(
            start: start_tseng,
            end: end_tseng,
            wayPointNum: i,
            iterationNum: iterationNum,
            particleNum: particleNum,
            wMax: wMax,
            wMin: wMin,
            c1: c1,
            c2: c2,
            isEllipticLat: false,
            isEllipticMeridianal: true)
        .optimize();
    tsengDistanceAPN.add(degrees(distance) * 60);
  }
  exportToCSV(tsengDistanceAPN,
      'tsengAPN.csv'); /*
//////
  for (int i = 1; i <= 6; i++) {
    (route, distance) = ParticleSwarmOptimization(
            start: start_hsieh,
            end: end_hsieh,
            wayPointNum: i,
            iterationNum: iterationNum,
            particleNum: particleNum,
            wMax: wMax,
            wMin: wMin,
            c1: c1,
            c2: c2,
            isEllipticLat:false,
            isEllipticMeridianal: false)
        .optimize();
    hsiehDistanceSphere.add(degrees(distance) * 60);
  }
  exportToCSV(hsiehDistanceSphere, 'hsiehSphere.csv');*/
  for (int i = 1; i <= 6; i++) {
    (route, distance) = ParticleSwarmOptimization(
            start: start_tseng,
            end: end_tseng,
            wayPointNum: i,
            iterationNum: iterationNum,
            particleNum: particleNum,
            wMax: wMax,
            wMin: wMin,
            c1: c1,
            c2: c2,
            isEllipticLat: false,
            isEllipticMeridianal: false)
        .optimize();
    tsengDistanceSphere.add(degrees(distance) * 60);
  }
  exportToCSV(tsengDistanceSphere, 'tsengSphere.csv');
  ////
  /*for (int i = 1; i <= 6; i++) {
    (route, distance) = ParticleSwarmOptimization(
            start: start_hsieh,
            end: end_hsieh,
            wayPointNum: i,
            iterationNum: iterationNum,
            particleNum: particleNum,
            wMax: wMax,
            wMin: wMin,
            c1: c1,
            c2: c2,
            isEllipticLat:true,
            isEllipticMeridianal: true)
        .optimize();
    hsiehDistanceSpheroid.add(degrees(distance) * 60);
  }
  exportToCSV(hsiehDistanceSpheroid, 'hsiehSpheroid.csv');*/
  for (int i = 1; i <= 6; i++) {
    (route, distance) = ParticleSwarmOptimization(
            start: start_tseng,
            end: end_tseng,
            wayPointNum: i,
            iterationNum: iterationNum,
            particleNum: particleNum,
            wMax: wMax,
            wMin: wMin,
            c1: c1,
            c2: c2,
            isEllipticLat: true,
            isEllipticMeridianal: true)
        .optimize();
    tsengDistanceSpheroid.add(degrees(distance) * 60);
  }
  exportToCSV(tsengDistanceSpheroid, 'tsengSpheroid.csv');*/
}
  /*Route routeStandardVersion;
  double distanceStardardVersion;
  Route routeRuleVersion;
  double distanceRuleVersion;
  int ruleVersionWin = 0, equal = 0, standardVersionWin = 0;
  //for (int i = 0; i < 500; i++) {
  ParticleSwarmOptimization PSO = ParticleSwarmOptimization(
      start: start,
      end: end,
      wayPointNum: 3,
      iterationNum: 500,
      particleNum: 50,
      wMax: 1.2,
      wMin: 0.2);
  (routeStandardVersion, distanceStardardVersion) = PSO.optimize();
  print(routeStandardVersion.toString());
  print(degrees(distanceStardardVersion) * 60);
  exportToCSV(PSO.globalBestHistory, 'StandardVersion.csv');
  /*ExtremumDisturbedPSO tPSO = ExtremumDisturbedPSO(start: start, end: end, wayPointNum: 3,iterationNum: 5000,particleNum:50 );
  (route, distance) = tPSO.optimize();
  print(route.toString());
  print(degrees(distance)*60);*/
  ParameterAdherePSO pPSO = ParameterAdherePSO(
      start: start,
      end: end,
      wayPointNum: 3,
      iterationNum: 500,
      particleNum: 50,
      wMax: 1.2,
      wMin: 0.2);
  (routeRuleVersion, distanceRuleVersion) = pPSO.optimize();
  /*if (distanceRuleVersion < distanceStardardVersion) {
      ruleVersionWin++;
    } else if (distanceRuleVersion == distanceStardardVersion) {
      equal++;
    } else {
      standardVersionWin++;
    }*/
  print(routeRuleVersion.toString());
  print(degrees(distanceRuleVersion) * 60);
  exportToCSV(pPSO.globalBestHistory, 'RuleVersion.csv');
  print('*********************');


AdaptiveInertiaPSO aiwfPSO = AdaptiveInertiaPSO(
      start: start,
      end: end,
      wayPointNum: 3,
      iterationNum: 500,
      particleNum: 50,
      wMax: 1.2,
      wMin: 0.2);
  (routeStandardVersion, distanceStardardVersion) = aiwfPSO.optimize();
  print(routeStandardVersion.toString());
  print(degrees(distanceStardardVersion) * 60);
  exportToCSV(aiwfPSO.globalBestHistory, 'aiwfVersion.csv');
  /*print(ruleVersionWin);
  print(equal);
  print(standardVersionWin);*/
}*/
