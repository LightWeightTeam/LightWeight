import 'package:flutter/material.dart';
import '../backend/firebase_nutrition.dart';


class PreviousAddsScreen extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;

  const PreviousAddsScreen({
    Key? key,
    required this.selectedDate,
    required this.mealType,
  }) : super(key: key);

  @override
  _PreviousAddsScreenState createState() => _PreviousAddsScreenState();
}

class _PreviousAddsScreenState extends State<PreviousAddsScreen> {
  late Future<List<Map<String, dynamic>>> _mealDataFuture;
  late Future<Map<String, dynamic>?> _mealTypeSumFuture;
  late Future<Map<String, dynamic>?> _mealTypeTotalSumFuture; // New future for total meal sum

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String formattedDate =
        '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';

    // Load Meal Data
    _mealDataFuture = getMealData(formattedDate, widget.mealType);

    // Load Meal Type Sums
    _mealTypeSumFuture = getMealTypeSum(formattedDate, widget.mealType);

    _mealTypeTotalSumFuture = getMealSum(formattedDate); // Load total meal sum
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _mealTypeSumFuture,
          builder: (context, sumSnapshot) {
            if (sumSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (sumSnapshot.hasError) {
              return Center(child: Text('Error loading meal sum'));
            } else {
              final Map<String, dynamic>? mealTypeSumData = sumSnapshot.data;

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _mealDataFuture,
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (dataSnapshot.hasError) {
                    return Center(child: Text('Error loading meal data'));
                  } else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
                    return Center(child: Text('No meals found'));
                  } else {
                    return ListView.builder(
                      itemCount: dataSnapshot.data!.length + 2, // +2 for sum and meal rows
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _mealTypeTotalSumFuture,
                            builder: (context, totalSumSnapshot) {
                              if (totalSumSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (totalSumSnapshot.hasError) {
                                return Center(child: Text('Error loading total meal sum'));
                              } else {
                                final Map<String, dynamic>? totalSumData = totalSumSnapshot.data;
                                return _buildTotalSumRow(totalSumData); // Total Meal Sum Row
                              }
                            },
                          );
                        } else if (index == 1) {
                          return _buildSumRow(mealTypeSumData); // Meal Type Sum Row
                        } else {
                          final mealData = dataSnapshot.data![index - 2];
                          return _buildMealRow(mealData); // Meal Rows
                        }
                      },
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

Widget _buildMealRow(Map<String, dynamic> mealData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Food Name: ${mealData['foodName']}'),
      Text('Amount: ${mealData['amount']}'),
      Text('Calories: ${mealData['calories']}'),
      Text('Carbs: ${mealData['carbs']}'),
      Text('Fat: ${mealData['fat']}'),
      Text('MealId: ${mealData['mealId']}'),
      Text('Protein: ${mealData['protein']}'),
      Row(
        children: [
        ElevatedButton(
        onPressed: () {
          final String selectedDate = '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
          final String mealType = widget.mealType;
          final String mealId = mealData['mealId'];
          
          deleteMeal(selectedDate, mealType, mealId);
        },
        child: Text('Löschen'),
      ),
      ElevatedButton(
        onPressed: () {
        },
        child: Text('Bearbeiten'),
      ),
    ],
  ),
      
      const Divider(), // Trennlinie zwischen den Datensätzen
    ],
  );
}

  Widget _buildSumRow(Map<String, dynamic>? mealTypeSumData) {
    if (mealTypeSumData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories Sum: ${mealTypeSumData['caloriesSum']}'),
          Text('Carbs Sum: ${mealTypeSumData['carbsSum']}'),
          Text('Fat Sum: ${mealTypeSumData['fatSum']}'),
          Text('Protein Sum: ${mealTypeSumData['proteinSum']}'),
          Divider(), // Trennlinie zwischen Summe und Mahlzeiten
        ],
      );
    } else {
      return Center(child: Text('Mahlzeitensumme nicht gefunden'));
    }
  }

    Widget _buildTotalSumRow(Map<String, dynamic>? mealTypeTotalSumData) {
    if (mealTypeTotalSumData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Calories: ${mealTypeTotalSumData['totalCalories']}'),
          Text('Total Carbs: ${mealTypeTotalSumData['totalCarbs']}'),
          Text('Total Fat: ${mealTypeTotalSumData['totalFat']}'),
          Text('Total Protein: ${mealTypeTotalSumData['totalProtein']}'),
          Divider(), // Trennlinie zwischen Summe und Mahlzeiten
        ],
      );
    } else {
      return Center(child: Text('Total Mahlzeitensumme nicht gefunden'));
    }
  }
}
