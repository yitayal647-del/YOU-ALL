import 'dart:async';
import 'dart:math';
import '../models/user_model.dart';

class MockAuthBackend {
  static final MockAuthBackend _instance = MockAuthBackend._internal();

  factory MockAuthBackend() {
    return _instance;
  }

  MockAuthBackend._internal();

  // In-memory storage for users
  final Map<String, Map<String, dynamic>> _users = {};
  
  // OTP storage: phoneNumber -> {otp: code, expiresAt: timestamp}
  final Map<String, Map<String, dynamic>> _otpStorage = {};
  
  // Session storage: phoneNumber -> {token: token, createdAt: timestamp}
  final Map<String, String> _sessions = {};

  // Generate a random OTP
  String _generateOTP() {
    return (Random().nextInt(9000) + 1000).toString();
  }

  // Generate a mock JWT token
  String _generateToken(String phoneNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$phoneNumber.$timestamp';
  }

  /// Send OTP to phone number
  Future<AuthResponse> sendOTP(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate phone number format
    if (phoneNumber.isEmpty) {
      return AuthResponse(
        success: false,
        message: 'የስልክ ቁጥር ባዶ ነው። እባክህ ስልክ ቁጥር አስገብ።',
      );
    }

    if (!phoneNumber.startsWith('+251')) {
      return AuthResponse(
        success: false,
        message: 'ልክ ያልሆነ ስልክ ቁጥር ቅርጸት። +251 ስልክ ቁጥር ጀምር።',
      );
    }

    try {
      final otp = _generateOTP();
      
      // Store OTP with 5-minute expiration
      _otpStorage[phoneNumber] = {
        'otp': otp,
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)),
        'attempts': 0,
      };

      // Debug: Print OTP for testing
      print('📱 Mock OTP for $phoneNumber: $otp');

      return AuthResponse(
        success: true,
        message: 'የማረጋገጫ ኮድ (OTP) በስኬት ተልኳል! ሙከራ ኮድ: $otp',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'OTP ላክ ወቅት ስህተት ተከስተ: ${e.toString()}',
      );
    }
  }

  /// Verify OTP and create/login user
  Future<AuthResponse> verifyOTP(String phoneNumber, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Check if OTP exists
    if (!_otpStorage.containsKey(phoneNumber)) {
      return AuthResponse(
        success: false,
        message: 'OTP አልተልካም። እባክህ መጀመሪያ "ኮድ ላክ" ብታጫን ሞክር።',
      );
    }

    final otpData = _otpStorage[phoneNumber]!;
    
    // Check if OTP expired
    if (DateTime.now().isAfter(otpData['expiresAt'] as DateTime)) {
      _otpStorage.remove(phoneNumber);
      return AuthResponse(
        success: false,
        message: 'OTP ጊዜው ያለፈ ነው። እባክህ ድጋሚ ኮድ ላክ ሞክር።',
      );
    }

    // Check OTP attempts (max 3)
    if ((otpData['attempts'] as int) >= 3) {
      _otpStorage.remove(phoneNumber);
      return AuthResponse(
        success: false,
        message: 'ብዙ ተሳሳተ ሞከራዎች። እባክህ ድጋሚ ኮድ ላክ ሞክር።',
      );
    }

    // Verify OTP code
    if (otpData['otp'] != otp) {
      otpData['attempts'] = (otpData['attempts'] as int) + 1;
      return AuthResponse(
        success: false,
        message: 'የተሳሳተ ኮድ ነው! ${3 - (otpData['attempts'] as int)} ሞከራ ይቀረዋል።',
      );
    }

    try {
      // OTP verified successfully
      _otpStorage.remove(phoneNumber);

      // Create new user or get existing user
      User user;
      if (_users.containsKey(phoneNumber)) {
        // Existing user - just mark as verified
        _users[phoneNumber]!['isVerified'] = true;
        user = User(
          id: _users[phoneNumber]!['id'] as String,
          phoneNumber: phoneNumber,
          createdAt: _users[phoneNumber]!['createdAt'] as String,
          isVerified: true,
        );
      } else {
        // New user - create account
        final newUser = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          phoneNumber: phoneNumber,
          createdAt: DateTime.now().toIso8601String(),
          isVerified: true,
        );
        _users[phoneNumber] = newUser.toJson();
        user = newUser;
      }

      // Generate session token
      final token = _generateToken(phoneNumber);
      _sessions[phoneNumber] = token;

      return AuthResponse(
        success: true,
        message: 'ተሳክቶ ገባህ! 🎉',
        user: user,
        token: token,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'ምዝግብ ወቅት ስህተት ተከስተ: ${e.toString()}',
      );
    }
  }

  /// Get current user session
  User? getCurrentUser(String? token) {
    if (token == null) return null;

    for (var entry in _sessions.entries) {
      if (entry.value == token) {
        final phoneNumber = entry.key;
        if (_users.containsKey(phoneNumber)) {
          return User.fromJson(_users[phoneNumber]!);
        }
      }
    }
    return null;
  }

  /// Logout user
  Future<bool> logout(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sessions.remove(phoneNumber);
    return true;
  }

  /// Get all users (for debugging)
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalUsers': _users.length,
      'users': _users.keys.toList(),
      'activeSessions': _sessions.length,
      'pendingOTPs': _otpStorage.length,
    };
  }

  /// Clear all data (for testing)
  void clearAllData() {
    _users.clear();
    _otpStorage.clear();
    _sessions.clear();
  }
}
