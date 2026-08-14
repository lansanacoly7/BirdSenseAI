import 'package:flutter/material.dart';

enum ValidationStatus {
  aiOnly,         // 🟡 IA uniquement
  community,      // 🔵 Communauté confirmée
  expert,         // 🟢 Expert confirmé
  needsReview,    // ⚠️ À vérifier
}

extension ValidationStatusX on ValidationStatus {
  String get label {
    switch (this) {
      case ValidationStatus.aiOnly:
        return 'IA uniquement';
      case ValidationStatus.community:
        return 'Communauté confirmée';
      case ValidationStatus.expert:
        return 'Expert confirmé';
      case ValidationStatus.needsReview:
        return 'À vérifier';
    }
  }

  Color get color {
    switch (this) {
      case ValidationStatus.aiOnly:
        return const Color(0xFFE67E22);
      case ValidationStatus.community:
        return const Color(0xFF2980B9);
      case ValidationStatus.expert:
        return const Color(0xFF27AE60);
      case ValidationStatus.needsReview:
        return const Color(0xFFC0392B);
    }
  }

  IconData get icon {
    switch (this) {
      case ValidationStatus.aiOnly:
        return Icons.smart_toy_outlined;
      case ValidationStatus.community:
        return Icons.groups_rounded;
      case ValidationStatus.expert:
        return Icons.verified_rounded;
      case ValidationStatus.needsReview:
        return Icons.help_outline_rounded;
    }
  }
}

class CommunityObservation {
  final String id;
  final String userName;
  final String userAvatar;
  final String userLevel;
  final String timeAgo;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final bool isLocationBlurred;
  final String speciesNameFr;
  final String speciesNameScientific;
  final int count;
  final int confidenceScore;
  final String imageUrl;
  final ValidationStatus validationStatus;
  int likesCount;
  bool isLiked;
  int commentsCount;
  final bool isSensitive;
  final String aiReasoning;

  CommunityObservation({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.userLevel,
    required this.timeAgo,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    this.isLocationBlurred = false,
    required this.speciesNameFr,
    required this.speciesNameScientific,
    required this.count,
    required this.confidenceScore,
    required this.imageUrl,
    required this.validationStatus,
    this.likesCount = 0,
    this.isLiked = false,
    this.commentsCount = 0,
    this.isSensitive = false,
    required this.aiReasoning,
  });
}

class ValidationSuggestion {
  final String id;
  final String userName;
  final String userAvatar;
  final String userLevel;
  final String proposedSpeciesFr;
  final int confidence;
  final String comment;
  final String timeAgo;

  ValidationSuggestion({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.userLevel,
    required this.proposedSpeciesFr,
    required this.confidence,
    required this.comment,
    required this.timeAgo,
  });
}

class CommentModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final String timeAgo;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timeAgo,
  });
}

class UserProfileModel {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String levelTitle;
  final int levelNumber;
  final int totalObservations;
  final int totalSpecies;
  final int totalValidations;
  final List<String> badges;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.levelTitle,
    required this.levelNumber,
    required this.totalObservations,
    required this.totalSpecies,
    required this.totalValidations,
    required this.badges,
  });
}

class CollectionItem {
  final String id;
  final String speciesFr;
  final String speciesScientific;
  final String imageUrl;
  final bool isUnlocked;
  final String? firstObservedDate;
  final String iucnCategory;

  CollectionItem({
    required this.id,
    required this.speciesFr,
    required this.speciesScientific,
    required this.imageUrl,
    required this.isUnlocked,
    this.firstObservedDate,
    required this.iucnCategory,
  });
}
