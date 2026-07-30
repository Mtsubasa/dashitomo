import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummonState {
  const SummonState({required this.name});

  final String name;

  bool get canWelcome => name.trim().isNotEmpty;

  SummonState copyWith({String? name}) {
    return SummonState(name: name ?? this.name);
  }
}

class SummonViewModel extends Notifier<SummonState> {
  @override
  SummonState build() {
    return const SummonState(name: 'かつお菜太郎');
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}

final summonViewModelProvider = NotifierProvider<SummonViewModel, SummonState>(
  SummonViewModel.new,
);
