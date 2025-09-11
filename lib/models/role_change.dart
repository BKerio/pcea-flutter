import 'user.dart';

/// Role Change model representing a role history entry
class RoleChange {
  final int id;
  final String fromRole;
  final String fromRoleDisplay;
  final String toRole;
  final String toRoleDisplay;
  final User changedBy;
  final String? reason;
  final Map<String, dynamic>? metadata;
  final DateTime changedAt;
  final String changedAtHuman;
  final bool wasPromotion;
  final int hierarchyChange;

  RoleChange({
    required this.id,
    required this.fromRole,
    required this.fromRoleDisplay,
    required this.toRole,
    required this.toRoleDisplay,
    required this.changedBy,
    this.reason,
    this.metadata,
    required this.changedAt,
    required this.changedAtHuman,
    required this.wasPromotion,
    required this.hierarchyChange,
  });

  /// Create RoleChange from JSON response
  factory RoleChange.fromJson(Map<String, dynamic> json) {
    return RoleChange(
      id: json['id'] as int,
      fromRole: json['from_role'] as String,
      fromRoleDisplay: json['from_role_display'] as String,
      toRole: json['to_role'] as String,
      toRoleDisplay: json['to_role_display'] as String,
      changedBy: User.fromJson(json['changed_by']),
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      changedAt: DateTime.parse(json['changed_at']),
      changedAtHuman: json['changed_at_human'] as String,
      wasPromotion: json['was_promotion'] as bool,
      hierarchyChange: json['hierarchy_change'] as int,
    );
  }

  /// Convert RoleChange to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_role': fromRole,
      'from_role_display': fromRoleDisplay,
      'to_role': toRole,
      'to_role_display': toRoleDisplay,
      'changed_by': changedBy.toJson(),
      'reason': reason,
      'metadata': metadata,
      'changed_at': changedAt.toIso8601String(),
      'changed_at_human': changedAtHuman,
      'was_promotion': wasPromotion,
      'hierarchy_change': hierarchyChange,
    };
  }

  @override
  String toString() {
    return 'RoleChange{id: $id, from: $fromRoleDisplay, to: $toRoleDisplay, changedAt: $changedAtHuman}';
  }
}

/// Role Change Statistics model
class RoleChangeStatistics {
  final int totalChanges;
  final int promotions;
  final int demotions;
  final int lateralMoves;
  final DateTime? firstRoleAssignment;
  final DateTime? lastRoleChange;

  RoleChangeStatistics({
    required this.totalChanges,
    required this.promotions,
    required this.demotions,
    required this.lateralMoves,
    this.firstRoleAssignment,
    this.lastRoleChange,
  });

  /// Create RoleChangeStatistics from JSON response
  factory RoleChangeStatistics.fromJson(Map<String, dynamic> json) {
    return RoleChangeStatistics(
      totalChanges: json['total_changes'] as int,
      promotions: json['promotions'] as int,
      demotions: json['demotions'] as int,
      lateralMoves: json['lateral_moves'] as int,
      firstRoleAssignment: json['first_role_assignment'] != null 
          ? DateTime.parse(json['first_role_assignment']) 
          : null,
      lastRoleChange: json['last_role_change'] != null 
          ? DateTime.parse(json['last_role_change']) 
          : null,
    );
  }

  /// Convert RoleChangeStatistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_changes': totalChanges,
      'promotions': promotions,
      'demotions': demotions,
      'lateral_moves': lateralMoves,
      'first_role_assignment': firstRoleAssignment?.toIso8601String(),
      'last_role_change': lastRoleChange?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RoleChangeStatistics{total: $totalChanges, promotions: $promotions, demotions: $demotions}';
  }
}

/// Pagination information for role history
class RoleHistoryPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  RoleHistoryPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  /// Create RoleHistoryPagination from JSON response
  factory RoleHistoryPagination.fromJson(Map<String, dynamic> json) {
    return RoleHistoryPagination(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      hasMorePages: json['has_more_pages'] as bool,
    );
  }

  /// Convert RoleHistoryPagination to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'has_more_pages': hasMorePages,
    };
  }
}

/// Role History Response model
class RoleHistoryResponse {
  final User user;
  final List<RoleChange> history;
  final RoleHistoryPagination pagination;
  final RoleChangeStatistics statistics;

  RoleHistoryResponse({
    required this.user,
    required this.history,
    required this.pagination,
    required this.statistics,
  });

  /// Create RoleHistoryResponse from JSON response
  factory RoleHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RoleHistoryResponse(
      user: User.fromJson(json['user']),
      history: (json['history'] as List)
          .map((item) => RoleChange.fromJson(item))
          .toList(),
      pagination: RoleHistoryPagination.fromJson(json['pagination']),
      statistics: RoleChangeStatistics.fromJson(json['statistics']),
    );
  }

  /// Convert RoleHistoryResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'history': history.map((change) => change.toJson()).toList(),
      'pagination': pagination.toJson(),
      'statistics': statistics.toJson(),
    };
  }
}
