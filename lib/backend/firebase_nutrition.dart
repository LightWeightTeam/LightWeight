import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


//Berechne die Grundkalorien

Future<void> berechneUndSpeichereGrundKalorien(
    String geschlecht,
    int alter,
    double gewicht,
    double groesse,
  ) async {
    try {
      String serverUrl = 'http://192.168.8.166:3000/nutrition/calculateCalories';

      Map<String, dynamic> data = {
        'geschlecht': geschlecht,
        'alter': alter,
        'gewicht': gewicht,
        'groesse': groesse,
      };

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        double grundKalorien = result['grundKalorien'];
        bool success = result['success'];

        if (success) {
          await saveGrundKalorienToLocal(grundKalorien);
          sendGrundKalorienToAPI();
          print('Grundkalorien berechnet und gespeichert: $grundKalorien');
          // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
        } else {
          print('Fehler bei der Kalorienberechnung');
        }
      } else {
        print('Fehler beim Berechnen der Grundkalorien - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Fehler beim Senden der Daten an den Server: $e');
    }
  }

//Speichere die Grundkalorien

Future<void> saveGrundKalorienToLocal(double grundKalorien) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('grundKalorien', grundKalorien);
  }

//sende die Grundkalorien und UID zur API
Future<void> sendGrundKalorienToAPI() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');
  double? grundKalorien = prefs.getDouble('grundKalorien');

  if (uid != null && grundKalorien != null) {
    String serverUrl = 'http://192.168.8.166:3000/nutrition/saveBasicCalories';

    Map<String, dynamic> data = {
      'uid': uid,
      'basic_calories': grundKalorien,
    };

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Grundkalorien erfolgreich an die API übergeben und in Firestore gespeichert');
        // Hier können Sie weitere Aktionen ausführen
      } else {
        print('Fehler beim Übergeben der Grundkalorien an die API - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Fehler beim Senden der Daten an den Server: $e');
    }
  } else {
    print('UID oder Grundkalorien sind nicht vorhanden');
  }
}


Future<List<Map<String, dynamic>>> searchFoodItems(String query, int pageNumber) async {
  final url = Uri.parse('http://192.168.8.166:3000/nutrition/searchFoodItems?query=$query&pageNumber=$pageNumber');

  try {
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> foodList = data['foods']['food'];

      List<Map<String, dynamic>> foodItems = [];

      for (var item in foodList) {
        foodItems.add({
          'food_name': item['food_name'][0],
          'food_description': item['food_description'][0],
        });
      }

      return foodItems;
    } else {
      throw Exception('Fehler beim Suchen von Lebensmitteln: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Suchen von Lebensmitteln: $e');
  }
}


Future<void> loadFoodPage(
  String query,
  List<Map<String, dynamic>> searchResults,
  bool loadingMore,
  int pageNumber,
  TextEditingController searchController,
  Function(bool) setLoadingMore,
  Function(List<Map<String, dynamic>>) setSearchResults,
  Function(int) setPageNumber,
) async {
  try {
    if (!loadingMore) {
      pageNumber = 1;
      searchResults.clear();
    }

    List<Map<String, dynamic>> foods = await searchFoodItems(query, pageNumber);

    if (foods.isNotEmpty) {
      searchResults.addAll(foods);
      pageNumber++;
    }

    setLoadingMore(false); // Set loading more to false after the results are fetched
    setSearchResults(searchResults);
    setPageNumber(pageNumber);
  } catch (error) {
    print('Fehler bei der Suche nach Lebensmitteln: $error');
  }
}


Future<Map<String, dynamic>> splitNutritionData(String nutritionData) async {
  List<String> values = nutritionData.split('-');

  int calories = 0;
  double fat = 0.0;
  double carbs = 0.0;
  double protein = 0.0;
  int amountValue = 0;
  String amountUnit = '';

  // Extrahiere die Menge und Einheit
  RegExp amountRegex = RegExp(r'(\d+)\s*([a-zA-Z]+)');
  String amountSection = values[0].trim();
  Match? amountMatch = amountRegex.firstMatch(amountSection);

  if (amountMatch != null) {
    amountValue = int.tryParse(amountMatch.group(1)!) ?? 0;
    amountUnit = amountMatch.group(2)!;
  }

  // Extrahiere Nährwertinformationen
  for (int i = 1; i < values.length; i++) {
    List<String> nutrientInfo = values[i].split('|');

    for (String info in nutrientInfo) {
      List<String> parts = info.split(':');
      String nutrientName = parts[0].trim();
      String nutrientValue = parts[1].trim().replaceAll(RegExp(r'[a-zA-Z]'), '');

      if (nutrientName.contains('Calories')) {
        calories = int.tryParse(nutrientValue) ?? 0;
      } else if (nutrientName.contains('Fat')) {
        fat = double.tryParse(nutrientValue) ?? 0.0;
      } else if (nutrientName.contains('Carbs')) {
        carbs = double.tryParse(nutrientValue) ?? 0.0;
      } else if (nutrientName.contains('Protein')) {
        protein = double.tryParse(nutrientValue) ?? 0.0;
      }
    }
  }

  return {
    'calories': calories,
    'fat': fat,
    'carbs': carbs,
    'protein': protein,
    'amount': {
      'value': amountValue,
      'unit': amountUnit,
    },
  };
}







Future<void> saveNutritionDataToFirebase({
  required int calories,
  required double fat,
  required double carbs,
  required double protein,
  required String foodName,
  required String amount,
  required String selectedDate, // Hinzugefügte Zeile: selectedDate-Parameter
  required String mealType
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');

  // Setze leere oder null Daten auf 0, bevor du sie sendest
  calories ??= 0;
  fat ??= 0.0;
  carbs ??= 0.0;
  protein ??= 0.0;

  if (uid != null) {
    String serverUrl = 'http://192.168.8.166:3000/nutrition/saveNutritionData'; // Node.js Server-URL anpassen

    Map<String, dynamic> data = {
      'uid': uid,
      'calories': calories,
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
      'foodName': foodName,
      'amount': amount,
      'selectedDate': selectedDate.toString(), // Hinzugefügte Zeile: selectedDate wird als String übergeben
      'mealType': mealType,
    };

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Nährwertdaten erfolgreich an die API übergeben und in Firestore gespeichert');
        // Hier können Sie weitere Aktionen ausführen
      } else {
        print('Fehler beim Übergeben der Nährwertdaten an die API - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Fehler beim Senden der Nährwertdaten an den Server: $e');
    }
  } else {
    print('UID ist nicht vorhanden');
  }
}



Future<Map<String, dynamic>> adjustNutritionData(double newAmount, Map<String, dynamic> originalNutritionData) async {
  
 
  int adjustedCalories = ((originalNutritionData['calories'] / originalNutritionData['amount']['value'])* newAmount).round();
  double adjustedFat = (originalNutritionData['fat'] / originalNutritionData['amount']['value'])* newAmount;
  adjustedFat = double.parse(adjustedFat.toStringAsFixed(2));
  double adjustedCarbs = (originalNutritionData['carbs'] / originalNutritionData['amount']['value'])* newAmount;
  adjustedCarbs = double.parse(adjustedCarbs.toStringAsFixed(2));
  double adjustedProtein = (originalNutritionData['protein'] / originalNutritionData['amount']['value'])* newAmount;
  adjustedProtein = double.parse(adjustedProtein.toStringAsFixed(2));

  int adjustedAmountValue = newAmount.toInt();
  String adjustedAmountUnit = originalNutritionData['amount']['unit'];

  return {
    'calories': adjustedCalories,
    'fat': adjustedFat,
    'carbs': adjustedCarbs,
    'protein': adjustedProtein,
    'amount': {
      'value': adjustedAmountValue,
      'unit': adjustedAmountUnit,
    },
  };
}



Future<List<Map<String, dynamic>>> getMealData(String selectedDate, String mealType) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userUid');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('http://192.168.8.166:3000/nutrition/getMeal?uid=$uid&selectedDate=$selectedDate&mealType=$mealType');

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      List<Map<String, dynamic>> mealDataArray = [];

      for (var meal in data) {
        mealDataArray.add({
          'amount': meal['amount'] ?? '',
          'calories': meal['calories'] ?? 0,
          'carbs': meal['carbs'] ?? 0,
          'fat': meal['fat'] ?? 0,
          'foodName': meal['foodName'] ?? '',
          'mealId': meal['mealId'] ?? '',
          'protein': meal['protein'] ?? 0,
        });
      }

      return mealDataArray;
    } else {
      throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: $e');
  }
}



Future<Map<String, dynamic>?> getMealTypeSum(String selectedDate, String mealType) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('http://192.168.8.166:3000/nutrition/getMealTypeSum?uid=$uid&selectedDate=$selectedDate&mealType=$mealType');

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> mealSumData = {
        'caloriesSum': data['caloriesSum'] ?? 0,
        'carbsSum': data['carbsSum'] ?? 0,
        'fatSum': data['fatSum'] ?? 0,
        'proteinSum': data['proteinSum'] ?? 0,
      };

      return mealSumData;
    } else {
      throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: $e');
  }
}

Future<Map<String, dynamic>?> getMealSum(String selectedDate) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('http://192.168.8.166:3000/nutrition/getMealSum?uid=$uid&selectedDate=$selectedDate');

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> mealTotalSumData = {
        'totalCalories': data['totalCalories'] ?? 0,
        'totalCarbs': data['totalCarbs'] ?? 0,
        'totalFat': data['totalFat'] ?? 0,
        'totalProtein': data['totalProtein'] ?? 0,
      };

      return mealTotalSumData;
    } else {
      throw Exception('Fehler beim Abrufen der totalen Summe: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen der totalen Summe: $e');
  }
}



Future<void> deleteMeal(String selectedDate, String mealType, String mealId) async {
  try {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }
  
  final url = Uri.parse('http://192.168.8.166:3000/nutrition/deleteMeal?uid=$uid&selectedDate=$selectedDate&mealType=$mealType&mealId=$mealId');


  
  
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      print('Erfolgreich gelöscht');
    } else {
      print('Fehler: ${response.statusCode}');
    }
  } catch (error) {
    print('Fehler beim Senden der Anfrage: $error');
  }
}
