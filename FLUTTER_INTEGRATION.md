# Flutter Integration Documentation

## Laravel Backend Setup Complete

Your Laravel backend is now configured to work with Flutter frontend applications with a comprehensive role-based system. Here's what has been set up:

### 🔧 Backend Configuration

1. **Laravel Sanctum** - API authentication
2. **CORS Support** - Cross-origin requests enabled
3. **API Routes** - `/api/*` endpoints configured
4. **Structured API Responses** - Consistent JSON response format
5. **Role-Based Access Control** - Multi-role system with hierarchy
6. **Dashboard Routing** - Role-specific dashboard endpoints

### � Role System

The system supports 7 different user roles with hierarchical permissions:

1. **Member** (Default) - Basic church member access
2. **Group Leader** - Manages small groups and activities
3. **Deacon** - Assists with church services and coordination
4. **Church Elder** - Provides spiritual guidance and ministry oversight
5. **Pastor** - Pastoral care and congregation management
6. **Chair** - Church leadership and administrative oversight
7. **Admin** - Full system administration and user management

### �📡 Available API Endpoints

#### Public Endpoints
- `GET /api/health` - Health check
- `GET /api/config` - App configuration
- `GET /api/time` - Server time
- `GET /api/test` - Test endpoint
- `POST /api/register` - User registration (creates member role by default)
- `POST /api/login` - User login

#### Protected Endpoints (Require Bearer Token)
- `GET /api/user` - Get user profile
- `PUT /api/user` - Update user profile
- `POST /api/logout` - User logout
- `GET /api/profile` - Get detailed user profile
- `PUT /api/profile` - Update detailed profile

#### Role-Based Dashboard Endpoints

**Admin Dashboard** (Admin only)
- `GET /api/admin/dashboard` - Admin dashboard data
- `GET /api/admin/users` - Manage all users
- `PUT /api/admin/users/{user}/role` - Assign roles to users

**Chair Dashboard** (Chair only)
- `GET /api/chair/dashboard` - Chair dashboard data
- `GET /api/chair/leadership` - Leadership overview

**Pastor Dashboard** (Pastor only)
- `GET /api/pastor/dashboard` - Pastor dashboard data
- `GET /api/pastor/congregation` - View congregation members

**Elder Dashboard** (Church Elder only)
- `GET /api/elder/dashboard` - Elder dashboard data

**Deacon Dashboard** (Deacon only)
- `GET /api/deacon/dashboard` - Deacon dashboard data

**Group Leader Dashboard** (Group Leader only)
- `GET /api/leader/dashboard` - Group leader dashboard data
- `GET /api/leader/members` - Group members management

**Member Dashboard** (All roles can access)
- `GET /api/member/dashboard` - Member dashboard data
- `GET /api/member/group` - Group information

### 🔑 Authentication Flow

1. **Register/Login** - Get access token and role information
2. **Include Token** - Add `Authorization: Bearer {token}` header
3. **Check Role** - Use role for dashboard routing and feature access
4. **Make Requests** - Use token for protected endpoints

### 🎯 Dashboard Routing Logic

After successful login, redirect users based on their role:

```dart
String getDashboardRoute(String role) {
  switch (role) {
    case 'admin':
      return '/admin/dashboard';
    case 'chair':
      return '/chair/dashboard';
    case 'pastor':
      return '/pastor/dashboard';
    case 'church_elder':
      return '/elder/dashboard';
    case 'deacon':
      return '/deacon/dashboard';
    case 'group_leader':
      return '/leader/dashboard';
    case 'member':
    default:
      return '/member/dashboard';
  }
}
```

### 📱 Flutter Integration Steps

#### 1. Add HTTP Dependencies
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.0
```

#### 2. Create API Service Class
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://your-server-ip:8000/api';
  
  // Register user (creates member role by default)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return jsonDecode(response.body);
  }
  
  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }
  
  // Get user profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
  
  // Get dashboard data based on role
  static Future<Map<String, dynamic>> getDashboard(String token, String role) async {
    String endpoint;
    switch (role) {
      case 'admin':
        endpoint = '$baseUrl/admin/dashboard';
        break;
      case 'chair':
        endpoint = '$baseUrl/chair/dashboard';
        break;
      case 'pastor':
        endpoint = '$baseUrl/pastor/dashboard';
        break;
      case 'church_elder':
        endpoint = '$baseUrl/elder/dashboard';
        break;
      case 'deacon':
        endpoint = '$baseUrl/deacon/dashboard';
        break;
      case 'group_leader':
        endpoint = '$baseUrl/leader/dashboard';
        break;
      case 'member':
      default:
        endpoint = '$baseUrl/member/dashboard';
        break;
    }
    
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
  
  // Admin: Get all users (Admin only)
  static Future<Map<String, dynamic>> getAllUsers(String token, {
    String? role,
    String? search,
    int page = 1,
  }) async {
    var queryParams = <String, dynamic>{'page': page.toString()};
    if (role != null) queryParams['role'] = role;
    if (search != null) queryParams['search'] = search;
    
    final uri = Uri.parse('$baseUrl/admin/users').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
  
  // Admin: Assign role to user (Admin only)
  static Future<Map<String, dynamic>> assignRole(String token, int userId, String role) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/role'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'role': role}),
    );
    return jsonDecode(response.body);
  }
}
```

#### 3. Example Flutter Usage
```dart
// Register (creates member by default)
final result = await ApiService.register(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  passwordConfirmation: 'password123',
);

if (result['success']) {
  final token = result['data']['access_token'];
  final user = result['data']['user'];
  final dashboardRoute = result['data']['dashboard_route'];
  
  // Save token and user info to SharedPreferences
  await saveUserSession(token, user, dashboardRoute);
  
  // Navigate to appropriate dashboard
  Navigator.pushReplacementNamed(context, dashboardRoute);
}

// Login with role-based redirect
final loginResult = await ApiService.login(
  email: 'admin@pcea.com',
  password: 'admin123',
);

if (loginResult['success']) {
  final token = loginResult['data']['access_token'];
  final user = loginResult['data']['user'];
  final role = user['role'];
  final dashboardRoute = loginResult['data']['dashboard_route'];
  
  // Save session
  await saveUserSession(token, user, dashboardRoute);
  
  // Navigate based on role
  switch (role) {
    case 'admin':
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
      break;
    case 'chair':
      Navigator.pushReplacementNamed(context, '/chair/dashboard');
      break;
    case 'pastor':
      Navigator.pushReplacementNamed(context, '/pastor/dashboard');
      break;
    // ... other roles
    default:
      Navigator.pushReplacementNamed(context, '/member/dashboard');
  }
}

// Get dashboard data
final dashboardData = await ApiService.getDashboard(token, userRole);
if (dashboardData['success']) {
  final data = dashboardData['data'];
  final userInfo = data['user'];
  final stats = data['stats'];
  final permissions = data['permissions'];
  
  // Use data to populate dashboard
}

// Admin functionality: Assign role
if (userRole == 'admin') {
  final result = await ApiService.assignRole(token, userId, 'group_leader');
  if (result['success']) {
    // Role assigned successfully
    showSuccess('Role assigned successfully');
  }
}
```

### 🌐 Server Configuration

**Base URL**: `http://localhost:8000/api` (Development)
**Production URL**: Update to your production server URL

### 🔒 Security Features

- **Token-based Authentication** - Secure API access
- **Role-Based Access Control (RBAC)** - Hierarchical permission system
- **Middleware Protection** - Route-level role verification
- **CORS Protection** - Controlled cross-origin requests
- **Input Validation** - Server-side validation
- **Rate Limiting** - API request throttling

### 🧪 Test Users

For development and testing, the following test users are available:

| Role | Email | Password | Dashboard Route |
|------|--------|----------|----------------|
| Admin | admin@pcea.com | admin123 | /admin/dashboard |
| Chair | chair@pcea.com | chair123 | /chair/dashboard |
| Pastor | pastor@pcea.com | pastor123 | /pastor/dashboard |
| Elder | elder@pcea.com | elder123 | /elder/dashboard |
| Deacon | deacon@pcea.com | deacon123 | /deacon/dashboard |
| Leader | leader@pcea.com | leader123 | /leader/dashboard |
| Member | member@pcea.com | member123 | /member/dashboard |

### 🚀 Next Steps

1. **Create Flutter App** - Set up your Flutter project
2. **Configure Base URL** - Update API base URL for your environment
3. **Implement Authentication** - Add login/register screens
4. **Add API Calls** - Integrate backend endpoints
5. **Handle Responses** - Implement error handling and success states

### 📝 API Response Format

All API responses follow this consistent format:

```json
{
  "success": true/false,
  "message": "Description of the result",
  "data": {
    // Response data (when success = true)
  },
  "errors": {
    // Validation errors (when success = false)
  }
}
```

#### Login/Register Response Format
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "member",
      "role_display": "Member",
      "created_at": "2025-09-10T07:00:00.000000Z"
    },
    "access_token": "1|abc123...",
    "token_type": "Bearer",
    "dashboard_route": "/member/dashboard"
  }
}
```

#### Dashboard Data Response Format
```json
{
  "success": true,
  "message": "Dashboard data retrieved successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin",
      "role_display": "Admin"
    },
    "stats": {
      "total_users": 150,
      "members": 120,
      "group_leaders": 15
    },
    "permissions": {
      "can_manage_users": true,
      "can_assign_roles": true,
      "can_view_all_data": true
    }
  }
}
```

### 🛠 Development Tips

1. **Use HTTP Interceptors** - For automatic token handling and role-based routing
2. **Implement Retry Logic** - For network failures
3. **Cache User Role** - Store role locally for quick dashboard routing
4. **Handle Loading States** - Show progress indicators during dashboard transitions
5. **Error Handling** - Implement proper error messages and fallback routes
6. **Role-Based UI** - Show/hide features based on user permissions
7. **Session Management** - Handle role changes and re-authentication
8. **Offline Support** - Cache dashboard data for offline viewing

### 🔄 Role Management Workflow

#### For Admins:
1. Login with admin credentials
2. Access admin dashboard at `/admin/dashboard`
3. View all users via `/admin/users` endpoint
4. Assign roles using `/admin/users/{id}/role` endpoint
5. Monitor user statistics and system health

#### For Regular Users:
1. Register (assigned 'member' role by default)
2. Login and get redirected to role-specific dashboard
3. Access features based on role permissions
4. Request role changes through proper channels (admin assignment)

### 🎯 Flutter Implementation Checklist

- [ ] Implement role-based navigation
- [ ] Create dashboard screens for each role
- [ ] Add permission-based UI elements
- [ ] Implement user management (for admin/chair roles)
- [ ] Add role request/assignment flows
- [ ] Create fallback routes for unauthorized access
- [ ] Implement session management with role caching
- [ ] Add role-specific feature toggles

Your Laravel backend with comprehensive role-based system is now ready to support your Flutter application! 🎉

### 📊 Role Hierarchy & Permissions

```
Admin (Level 7)
├── Full system access
├── User management
├── Role assignment
└── System configuration

Chair (Level 6)
├── Church leadership oversight
├── User management (limited)
├── Leadership reports
└── Strategic planning

Pastor (Level 5)
├── Congregation management
├── Pastoral care
├── Event scheduling
└── Spiritual oversight

Church Elder (Level 4)
├── Ministry oversight
├── Member counseling
├── Spiritual guidance
└── Support pastoral duties

Deacon (Level 3)
├── Service coordination
├── Administrative support
├── Member assistance
└── Event management

Group Leader (Level 2)
├── Small group management
├── Member engagement
├── Activity coordination
└── Attendance tracking

Member (Level 1)
├── Basic access
├── Profile management
├── Event participation
└── Group membership
```
