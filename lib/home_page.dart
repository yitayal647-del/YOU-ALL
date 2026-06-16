import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_auth_service.dart';
import 'verification_page.dart';

class HomePage extends StatefulWidget {
  final User? user;
  final String? token;

  const HomePage({
    super.key,
    this.user,
    this.token,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _amountController = TextEditingController();
  final _authBackend = MockAuthBackend();
  
  double _totalRevenue = 0.0;
  double _creatorsShare = 0.0;
  double _platformShare = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateSplit() {
    final double? enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount != null && enteredAmount > 0) {
      setState(() {
        _totalRevenue = enteredAmount;
        _creatorsShare = enteredAmount * 0.70;
        _platformShare = enteredAmount * 0.30;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('እባክህ ትክክለኛ ቁጥር አስገብ።'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    if (widget.user != null) {
      await _authBackend.logout(widget.user!.phoneNumber);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UserVerificationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YAll Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
              Card(
                color: Colors.blue.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'User Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.user != null) ...[
                        Text(
                          'Phone: ${widget.user!.phoneNumber}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: ${widget.user!.id}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Account verification card
              const Card(
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 40),
                      SizedBox(width: 15),
                      Text(
                        'መለያዎ በስኬት ተረጋግጧል!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'የገቢ ክፍፍል ማስያ (70/30 Split)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ጠቅላላ ገቢ ያስገቡ (በብር)',
                  border: OutlineInputBorder(),
                  hintText: '1000',
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _calculateSplit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 45),
                ),
                child: const Text('አስላ'),
              ),
              const SizedBox(height: 30),
              if (_totalRevenue > 0) ...[
                Text(
                  'ጠቅላላ ገቢ: $_totalRevenue ብር',
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(),
                Text(
                  'የአዘጋጆች ድርሻ (70%): $_creatorsShare ብር',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'የ YAll ፕላትፎርም ድርሻ (30%): $_platformShare ብር',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
