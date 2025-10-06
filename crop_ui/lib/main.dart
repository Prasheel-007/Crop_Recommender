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

// This is now our "Manual Analysis" screen
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers for all manual inputs
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _tempController = TextEditingController();
  final _humidityController = TextEditingController();
  final _moistureController = TextEditingController();

  String? _selectedSoilType;
  final List<String> _soilTypes = ['Sandy', 'Loamy', 'Black', 'Red', 'Clayey'];

  String _result = '';
  bool _isLoading = false;

  Future<void> _getRecommendation() async {
    if (_selectedSoilType == null) {
      setState(() { _result = 'Please select a soil type.'; });
      return;
    }

    // TODO: Remember to replace this with your deployed Render URL later
    const String apiUrl = 'https://crop-recommender-api-my11.onrender.com/predict';

    setState(() { _isLoading = true; _result = 'Getting recommendation...'; });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Temparature': double.tryParse(_tempController.text) ?? 0.0,
          'Humidity': double.tryParse(_humidityController.text) ?? 0.0,
          'Moisture': double.tryParse(_moistureController.text) ?? 0.0,
          'Soil Type': _selectedSoilType,
          'Nitrogen': double.tryParse(_nController.text) ?? 0.0,
          'Potassium': double.tryParse(_kController.text) ?? 0.0,
          'Phosphorous': double.tryParse(_pController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() { _result = 'Recommended Crop: ${data['recommended_crop']}'; });
      } else {
        setState(() { _result = 'Error: Could not get a recommendation.'; });
      }
    } catch (e) {
      setState(() { _result = 'Error: Could not connect to the server.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedSoilType,
              hint: const Text('Select Soil Type'),
              items: _soilTypes.map((String soil) {
                return DropdownMenuItem<String>(value: soil, child: Text(soil));
              }).toList(),
              onChanged: (newValue) { setState(() { _selectedSoilType = newValue; }); },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _buildTextField(_nController, 'Nitrogen (N)', 'Unit: kg/ha', 'e.g., 0 - 140'),
            _buildTextField(_pController, 'Phosphorous (P)', 'Unit: kg/ha', 'e.g., 5 - 145'),
            _buildTextField(_kController, 'Potassium (K)', 'Unit: kg/ha', 'e.g., 5 - 205'),
            _buildTextField(_tempController, 'Temperature', 'Unit: °C', 'e.g., 10 - 40'),
            _buildTextField(_humidityController, 'Humidity', 'Unit: %', 'e.g., 20 - 95'),
            _buildTextField(_moistureController, 'Soil Moisture', 'Unit: %', 'e.g., 20 - 70'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _getRecommendation,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Get Recommendation'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String helper, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper, // This text appears below the input field
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}