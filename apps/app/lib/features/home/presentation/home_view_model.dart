import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ホーム画面に表示するペットの状態。
class HomeState {
  const HomeState({
    required this.petName,
    required this.level,
    required this.expRatio,
  });

  final String petName;

  final int level;

  /// 次のレベルまでの経験値の割合（0.0〜1.0）。
  final double expRatio;

  HomeState copyWith({String? petName, int? level, double? expRatio}) {
    return HomeState(
      petName: petName ?? this.petName,
      level: level ?? this.level,
      expRatio: expRatio ?? this.expRatio,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState(petName: 'かつ男', level: 12, expRatio: 1);
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
