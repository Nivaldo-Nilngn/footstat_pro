import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/storage_repository.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

class PlayersNotifier extends StateNotifier<List<String>> {
  final StorageRepository _repository;

  PlayersNotifier(this._repository) : super([]) {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    state = await _repository.loadGlobalPlayers();
  }

  Future<bool> addPlayer(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (state.contains(trimmed)) return false;

    state = [...state, trimmed];
    await _repository.saveGlobalPlayers(state);
    return true;
  }

  Future<bool> renamePlayer(int index, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || index < 0 || index >= state.length) return false;
    if (state.contains(trimmed) && state[index] != trimmed) return false;

    final oldName = state[index];
    final updatedList = List<String>.from(state);
    updatedList[index] = trimmed;
    state = updatedList;

    await _repository.saveGlobalPlayers(state);
    return true;
  }

  Future<void> removePlayer(int index) async {
    if (index < 0 || index >= state.length) return;
    final updatedList = List<String>.from(state)..removeAt(index);
    state = updatedList;
    await _repository.saveGlobalPlayers(state);
  }
}

final playersProvider = StateNotifierProvider<PlayersNotifier, List<String>>((ref) {
  final repo = ref.watch(storageRepositoryProvider);
  return PlayersNotifier(repo);
});
