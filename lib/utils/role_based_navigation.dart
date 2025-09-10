import 'package:flutter/material.dart';
import '../dashboards/admin_dashboard.dart';
import '../dashboards/chair_dashboard.dart';
import '../dashboards/pastor_dashboard.dart';
import '../dashboards/elder_dashboard.dart';
import '../dashboards/deacon_dashboard.dart';
import '../dashboards/group_leader_dashboard.dart';
import '../dashboards/member_dashboard.dart';

/// Role-based navigation utility class
class RoleBasedNavigation {
  /// Get the appropriate dashboard route based on user role
  static String getDashboardRoute(String role) {
    switch (role.toLowerCase()) {
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

  /// Get the appropriate dashboard widget based on user role
  static Widget getDashboardWidget(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const AdminDashboard();
      case 'chair':
        return const ChairDashboard();
      case 'pastor':
        return const PastorDashboard();
      case 'church_elder':
        return const ElderDashboard();
      case 'deacon':
        return const DeaconDashboard();
      case 'group_leader':
        return const GroupLeaderDashboard();
      case 'member':
      default:
        return const MemberDashboard();
    }
  }

  /// Navigate to the appropriate dashboard based on user role
  static void navigateToDashboard(BuildContext context, String role) {
    final route = getDashboardRoute(role);
    Navigator.pushReplacementNamed(context, route);
  }

  /// Navigate to the appropriate dashboard and remove all previous routes
  static void navigateToDashboardAndClearStack(BuildContext context, String role) {
    final route = getDashboardRoute(role);
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  /// Check if a role has access to admin features
  static bool hasAdminAccess(String role) {
    return ['admin', 'chair'].contains(role.toLowerCase());
  }

  /// Check if a role has leadership access
  static bool hasLeadershipAccess(String role) {
    return ['admin', 'chair', 'pastor', 'church_elder'].contains(role.toLowerCase());
  }

  /// Check if a role has management access
  static bool hasManagementAccess(String role) {
    return ['admin', 'chair', 'pastor', 'church_elder', 'deacon', 'group_leader'].contains(role.toLowerCase());
  }

  /// Get role hierarchy level (higher number = higher authority)
  static int getRoleLevel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 7;
      case 'chair':
        return 6;
      case 'pastor':
        return 5;
      case 'church_elder':
        return 4;
      case 'deacon':
        return 3;
      case 'group_leader':
        return 2;
      case 'member':
      default:
        return 1;
    }
  }

  /// Get role display name
  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'chair':
        return 'Chairman';
      case 'pastor':
        return 'Pastor';
      case 'church_elder':
        return 'Church Elder';
      case 'deacon':
        return 'Deacon';
      case 'group_leader':
        return 'Group Leader';
      case 'member':
      default:
        return 'Member';
    }
  }

  /// Get all available roles (useful for admin role management)
  static List<Map<String, dynamic>> getAllRoles() {
    return [
      {'value': 'member', 'display': 'Member', 'level': 1},
      {'value': 'group_leader', 'display': 'Group Leader', 'level': 2},
      {'value': 'deacon', 'display': 'Deacon', 'level': 3},
      {'value': 'church_elder', 'display': 'Church Elder', 'level': 4},
      {'value': 'pastor', 'display': 'Pastor', 'level': 5},
      {'value': 'chair', 'display': 'Chairman', 'level': 6},
      {'value': 'admin', 'display': 'Administrator', 'level': 7},
    ];
  }

  /// Check if user can manage another user based on role hierarchy
  static bool canManageUser(String managerRole, String targetRole) {
    return getRoleLevel(managerRole) > getRoleLevel(targetRole);
  }
}
