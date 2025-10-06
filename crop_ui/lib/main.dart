import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const CropApp());
}

class CropApp extends StatelessWidget {
  const CropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Recommender',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});
  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardPage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers for our new input fields
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _moistureController = TextEditingController();

  // State for the dropdown
  String? _selectedSoilType;
  final List<String> _soilTypes = ['Sandy', 'Loamy', 'Black', 'Red', 'Clayey'];

  String _result = '';
  bool _isLoading = false;

  Future<void> _getRecommendation() async {
    if (_selectedSoilType == null) {
      setState(() {
        _result = 'Please select a soil type.';
      });
      return;
    }

    // TODO: Replace with your deployed Render URL
    const String apiUrl = 'YOUR_RENDER_URL_HERE/predict';

    // We will get Temperature and Humidity from a weather API later. For now, we use defaults.
    const double defaultTemp = 28.0;
    const double defaultHumidity = 80.0;

    setState(() {
      _isLoading = true;
      _result = 'Getting recommendation...';
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          // New JSON body matching our enhanced backend
          'Temparature': defaultTemp,
          'Humidity': defaultHumidity,
          'Moisture': double.tryParse(_moistureController.text) ?? 0.0,
          'Soil Type': _selectedSoilType,
          'Nitrogen': double.tryParse(_nController.text) ?? 0.0,
          'Potassium': double.tryParse(_kController.text) ?? 0.0,
          'Phosphorous': double.tryParse(_pController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _result = 'Recommended Crop: ${data['recommended_crop']}';
        });
      } else {
        setState(() {
          _result = 'Error: Could not get a recommendation.';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: Could not connect to the server.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Recommendation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // New Dropdown for Soil Type
            DropdownButtonFormField<String>(
              value: _selectedSoilType,
              hint: const Text('Select Soil Type'),
              items: _soilTypes.map((String soil) {
                return DropdownMenuItem<String>(value: soil, child: Text(soil));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedSoilType = newValue;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _buildTextField(_nController, 'Nitrogen (N)', 'e.g., 0-140 kg/ha'),
            _buildTextField(_pController, 'Phosphorus (P)', 'e.g., 5-145 kg/ha'),
            _buildTextField(_kController, 'Potassium (K)', 'e.g., 5-205 kg/ha'),
            _buildTextField(_moistureController, 'Soil Moisture', 'e.g., 20-70 %'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _getRecommendation,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Get Recommendation'),
            ),
            const SizedBox(height: 24),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Updated helper widget with hint text
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}