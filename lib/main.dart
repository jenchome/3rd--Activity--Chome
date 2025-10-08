import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Black background, beige accents, white text
    final primary = Color(0xFFF5F0E1); // beige
    final black = Colors.black;
    final white = Colors.white;
    return MaterialApp(
      title: 'LegalDocs Preparation & Tracking',
      theme: ThemeData(
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, secondary: white),
        appBarTheme: AppBarTheme(
          backgroundColor: black,
          foregroundColor: primary,
          iconTheme: IconThemeData(color: primary),
          titleTextStyle: TextStyle(
            color: primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        scaffoldBackgroundColor: black,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: black),
        ),
        iconTheme: IconThemeData(color: primary),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          backgroundColor: primary,
          selectedIconTheme: IconThemeData(color: Colors.black),
          unselectedIconTheme: IconThemeData(color: Colors.black54),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // 0 = Home

  // Login controllers
  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _rememberMe = false;

  // Register controllers
  final GlobalKey<FormState> _regKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;
  String _selectedRole = 'User';
  final List<String> _roles = ['Admin', 'User'];
  bool _acceptedTermsDocs = false;

  // Documentation & Tracking state
  String _docType = 'Affidavit';
  final List<String> _docTypes = ['Affidavit', 'Contract', 'Deed'];
  final TextEditingController _docDescriptionController = TextEditingController();
  bool _includeNotary = false;
  bool _expedited = false;
  DateTime? _docDate;
  TimeOfDay? _docTime;
  final List<Map<String, dynamic>> _tracking = [];

  @override
  void dispose() {
    _usernameController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _confirmPasswordController.dispose();
    _docDescriptionController.dispose();
    super.dispose();
  }

  void _onTap(int i) => setState(() => _selectedIndex = i);
  void _goHome() => setState(() => _selectedIndex = 0);

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.black)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submitLogin() {
    if (_loginKey.currentState?.validate() ?? false) {
      final user = _usernameController.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signed in as $user${_rememberMe ? ' (remembered)' : ''}')));
    }
  }

  void _submitRegister() {
    // registration does not require terms here (moved to Docs & Track)
    if (_regKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered $name as $_selectedRole')));
    }
  }

  Widget _card({required Widget child}) => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );

  Widget _loginPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _card(
            child: Form(
              key: _loginKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Welcome back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Sign in to access your legal documents', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Username'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter username' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter email';
                      if (!v.contains('@')) return 'Email must contain @';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _loginPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false)),
                      const SizedBox(width: 4),
                      const Text('Remember Me'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(onPressed: _submitLogin, icon: const Icon(Icons.login), label: const Text('Sign in')),
                ],
              ),
            ),
          ),
          TextButton(onPressed: () => _onTap(1), child: const Text("Don't have an account? Register")),
        ],
      ),
    );
  }

  Widget _registerPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _card(
            child: Form(
              key: _regKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Create account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.badge), labelText: 'Full name'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _regEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter email';
                      if (!v.contains('@')) return 'Email must contain @';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _regPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'Confirm password'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm password';
                      if (v != _regPasswordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.cake), labelText: 'Birthdate', hintText: _birthDate == null ? 'Select birthdate' : DateFormat.yMMMd().format(_birthDate!)),
                        validator: (v) => _birthDate == null ? 'Please pick your birthdate' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => _selectedRole = v ?? 'User'),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.work), labelText: 'Role'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _submitRegister, icon: const Icon(Icons.app_registration), label: const Text('Create account')),
                ],
              ),
            ),
          ),
          TextButton(onPressed: () => _onTap(0), child: const Text('Already have an account? Sign in')),
        ],
      ),
    );
  }

  Future<void> _pickDocDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _docDate ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.black)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _docDate = picked);
  }

  Future<void> _pickDocTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _docTime ?? now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.black)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _docTime = picked);
  }

  void _submitDocument() {
    if ((_docDescriptionController.text.trim()).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    // Calculate cost
    int cost = 0;
    if (_includeNotary) cost += 50;
    if (_expedited) cost += 80;

    final scheduled = _docDate != null
        ? DateTime(
            _docDate!.year,
            _docDate!.month,
            _docDate!.day,
            _docTime?.hour ?? 0,
            _docTime?.minute ?? 0,
          )
        : null;

    final entry = {
      'type': _docType,
      'description': _docDescriptionController.text.trim(),
      'notary': _includeNotary,
      'expedited': _expedited,
      'scheduled': scheduled,
      'cost': cost,
      'created': DateTime.now(),
    };

    setState(() {
      _tracking.add(entry);
      // Clear form
      _docDescriptionController.clear();
      _includeNotary = false;
      _expedited = false;
      _docDate = null;
      _docTime = null;
    _docType = _docTypes.first;
    _selectedIndex = 4; // switch to tracking tab to show the result
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document submitted')),
    );
  }

  Widget _documentationPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Prepare Document', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _docType,
                items: _docTypes
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _docType = v ?? _docTypes.first),
                decoration: InputDecoration(labelText: 'Document Type'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _docDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text('Include Notary (₱50)'),
                      value: _includeNotary,
                      onChanged: (v) => setState(() => _includeNotary = v),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text('Expedited (₱80)'),
                      value: _expedited,
                      onChanged: (v) => setState(() => _expedited = v),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDocDate,
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                      child: Text(_docDate == null
                          ? 'Pick Date'
                          : DateFormat.yMMMd().format(_docDate!), style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDocTime,
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                      child: Text(_docTime == null
                          ? 'Pick Time'
                          : _docTime!.format(context), style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _acceptedTermsDocs,
                onChanged: (v) => setState(() => _acceptedTermsDocs = v ?? false),
                title: const Text('I accept the Terms & Conditions'),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitDocument,
                child: Text('Submit Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackingPage() {
    if (_tracking.isEmpty) {
      return Center(child: Text('No submissions yet'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _tracking.length,
      itemBuilder: (context, i) {
        final e = _tracking[i];
        final scheduled = e['scheduled'] as DateTime?;
        return Card(
          child: ListTile(
            title: Text('${e['type']} - ${e['description']}'),
            subtitle: Text(
                'Notary: ${e['notary'] ? 'Yes' : 'No'} • Expedited: ${e['expedited'] ? 'Yes' : 'No'}\nScheduled: ${scheduled != null ? DateFormat.yMMMd().add_jm().format(scheduled) : '—'}'),
            trailing: Text('₱${e['cost']}'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  final pages = [_homePage(), _loginPage(), _registerPage(), _documentationPage(), _trackingPage()];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.gavel, color: Theme.of(context).primaryColor, size: 32),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('LegalDocs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).primaryColor, letterSpacing: 1.2)),
            Text('Preparation & Tracking', style: TextStyle(fontSize: 16, color: Color.fromRGBO(245,240,225,0.85), letterSpacing: 1)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _goHome, icon: Icon(Icons.home, color: Theme.of(context).primaryColor)),
        ],
        elevation: 8,
        backgroundColor: Colors.black,
      ),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: pages)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Register'),
          BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: 'Documentation'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
        ],
      ),
    );
  }

  Widget _homePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, color: Theme.of(context).primaryColor, size: 64),
            SizedBox(height: 24),
            Text('LegalDocs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Theme.of(context).primaryColor, letterSpacing: 1.2)),
            Text('Preparation & Tracking', style: TextStyle(fontSize: 20, color: Color.fromRGBO(245,240,225,0.85), letterSpacing: 1)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              icon: Icon(Icons.login),
              label: Text('Login', style: TextStyle(fontSize: 18)),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              icon: Icon(Icons.person_add),
              label: Text('Register', style: TextStyle(fontSize: 18)),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              icon: Icon(Icons.document_scanner),
              label: Text('Documentation', style: TextStyle(fontSize: 18)),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              icon: Icon(Icons.track_changes),
              label: Text('Tracking', style: TextStyle(fontSize: 18)),
              onPressed: () => setState(() => _selectedIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
  
}
