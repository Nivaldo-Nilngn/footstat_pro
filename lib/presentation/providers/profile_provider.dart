import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null) {
    _init();
  }

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _init() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _db.ref('users/${user.uid}/profile').get();
        if (snapshot.exists && snapshot.value != null) {
          final map = Map<String, dynamic>.from(snapshot.value as Map);
          state = UserProfile.fromJson(map);
        } else {
          // Create default profile
          final defaultProfile = UserProfile(
            id: user.uid,
            name: user.email?.split('@')[0] ?? 'Player',
            avatarUrl: 'https://i.pravatar.cc/150?u=${user.uid}',
            level: 1,
            currentXp: 0,
            maxXpForLevel: 1000,
            isVerified: false,
            badgeType: 'none',
            achievements: [],
            tag: '#${user.uid.substring(0, 6).toUpperCase()}',
          );
          await _db.ref('users/${user.uid}/profile').set(defaultProfile.toJson());
          state = defaultProfile;
        }
      } catch (e) {
        state = UserProfile(
          id: user.uid,
          name: user.email?.split('@')[0] ?? 'Player Offline',
          avatarUrl: 'https://i.pravatar.cc/150?u=${user.uid}',
          level: 1,
          currentXp: 0,
          maxXpForLevel: 1000,
          isVerified: false,
          badgeType: 'offline',
          achievements: [],
          tag: '#${user.uid.substring(0, 6).toUpperCase()}',
        );
      }
    } else {
      state = UserProfile(
        id: 'guest',
        name: 'Guest Player',
        avatarUrl: 'https://i.pravatar.cc/150',
        level: 1,
        currentXp: 0,
        maxXpForLevel: 1000,
        isVerified: false,
        badgeType: 'none',
        achievements: [],
        tag: '#GUEST',
      );
    }
  }

  Future<void> addXp(int xp) async {
    if (state == null || state!.id == 'guest') return;
    
    int newXp = state!.currentXp + xp;
    int newLevel = state!.level;
    int newMaxXp = state!.maxXpForLevel;
    
    if (newXp >= newMaxXp) {
      newLevel++;
      newXp = newXp - newMaxXp;
      newMaxXp += 500;
    }
    
    final updatedProfile = state!.copyWith(
      currentXp: newXp,
      level: newLevel,
      maxXpForLevel: newMaxXp,
    );
    
    state = updatedProfile;
    try {
      await _db.ref('users/${state!.id}/profile').set(updatedProfile.toJson());
    } catch (_) {
      // Ignorar erro se offline
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});
