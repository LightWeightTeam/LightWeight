import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import des intl-Pakets
import '../backend/firebase_nutrition.dart';
import 'food_detail_screen.dart';
import 'previous_adds.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lebensmittelsuche'),
        ),
        body: FoodSearchScreen(),
      ),
    );
  }
}

class FoodSearchScreen extends StatefulWidget {
  @override
  _FoodSearchScreenState createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  DateTime selectedDate = DateTime.now();
  String mealType = 'Frühstück'; // Variable für die Auswahl des Mahlzeitentyps

  void _updateDate(int daysToAdd) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: daysToAdd));
    });
  }

  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _loadingMore = false;
  int _pageNumber = 1;

  void _loadFoodPage(String query, {bool loadMore = false}) {
    loadFoodPage(
      query,
      _searchResults,
      _loadingMore,
      _pageNumber,
      _searchController,
      (bool loading) {
        setState(() {
          _loadingMore = loading;
        });
      },
      (List<Map<String, dynamic>> results) {
        setState(() {
          _searchResults = results;
        });
      },
      (int number) {
        setState(() {
          _pageNumber = number;
        });
      },
    );
  }

  void _showFoodDetailPage(Map<String, dynamic> foodData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodDetails: foodData,
          selectedDate: selectedDate, // Übergabe von selectedDate
          mealType: mealType,
        ),
      ),
    );
  }

    void _showPreviousAdds(Map<String, dynamic> foodData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreviousAddsScreen(
          selectedDate: selectedDate,
          mealType: mealType,
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Lebensmittelsuche'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _updateDate(-1),
              ),
              Text(
                '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                style: TextStyle(fontSize: 18.0),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => _updateDate(1),
              ),
            ],
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: mealType,
            onChanged: (String? newValue) {
              setState(() {
                mealType = newValue!; // Aktualisieren des Mahlzeitentyps
              });
            },
            items: <String>['Frühstück', 'Mittag', 'Abendessen'] // Auswahlmöglichkeiten
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextButton(
            onPressed: () {
              _showPreviousAdds({'food_name': 'Dummy Food', 'food_description': 'Dummy Description'});
            },
            child: Text('Vorherige Hinzufügungen anzeigen'),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Lebensmittel suchen',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  String query = _searchController.text.trim();
                  _loadFoodPage(query);
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length + (_loadingMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == _searchResults.length) {
                  if (_loadingMore) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SizedBox.shrink();
                  }
                } else {
                  return ListTile(
                    title: Text(_searchResults[index]['food_name']),
                    subtitle: Text(_searchResults[index]['food_description']),
                    onTap: () {
                      _showFoodDetailPage(_searchResults[index]);
                    },
                  );
                }
              },
            ),
          ),
          if (_searchResults.isNotEmpty && !_loadingMore)
            ElevatedButton(
              child: Text('Weitere Ergebnisse anzeigen'),
              onPressed: () {
                setState(() {
                  _loadingMore = true;
                });
                String query = _searchController.text.trim();
                _loadFoodPage(query, loadMore: true);
              },
            ),
        ],
      ),
    ),
  );
}
}