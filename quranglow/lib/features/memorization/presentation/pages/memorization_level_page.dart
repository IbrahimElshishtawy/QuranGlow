import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/features/memorization/application/memorization_controller.dart';
import 'package:quranglow/features/memorization/domain/memorization_models.dart';

class MemorizationLevelPage extends ConsumerStatefulWidget {
  const MemorizationLevelPage({
    super.key,
    required this.levelId,
    this.reviewMode = false,
  });

  final String levelId;
  final bool reviewMode;

  @override
  ConsumerState<MemorizationLevelPage> createState() =>
      _MemorizationLevelPageState();
}

class _MemorizationLevelPageState extends ConsumerState<MemorizationLevelPage> {
  Future<_LoadedMemorizationLevel>? _loadedFuture;
  int _currentAyahIndex = 0;
  int _mistakes = 0;
  int? _sessionHearts;
  DateTime _startedAt = DateTime.now();
  bool _finishing = false;
  MemorizationSessionResult? _result;

  final _expertController = TextEditingController();
  String? _expertAyahKey;
  String? _hardAyahKey;
  List<_WordToken> _wordBank = const [];
  List<_WordToken> _selectedWords = const [];

  @override
  void dispose() {
    _expertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(memorizationControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: asyncState.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'تعذر فتح المستوى: $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        data: (state) {
          final level = _findLevel(state.levels);
          if (level == null) {
            return const Scaffold(
              body: Center(child: Text('هذا المستوى غير موجود')),
            );
          }

          _sessionHearts ??= state.profile.hearts;
          _loadedFuture ??= _loadLevel(level);

          return FutureBuilder<_LoadedMemorizationLevel>(
            future: _loadedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _LevelLoadError(
                  error: snapshot.error,
                  onRetry: () {
                    setState(() {
                      _loadedFuture = _loadLevel(level);
                    });
                  },
                );
              }

              final loaded = snapshot.data!;
              return _buildLevelScaffold(context, loaded);
            },
          );
        },
      ),
    );
  }

  MemorizationLevel? _findLevel(List<MemorizationLevel> levels) {
    for (final level in levels) {
      if (level.levelId == widget.levelId) return level;
    }
    return null;
  }

  Future<_LoadedMemorizationLevel> _loadLevel(MemorizationLevel level) async {
    final service = ref.read(quranServiceProvider);
    final surah = await service.getSurahText('quran-uthmani', level.surahId);
    final ayat = surah.ayat
        .where(
          (aya) =>
              aya.numberInSurah >= level.ayahStart &&
              aya.numberInSurah <= level.ayahEnd,
        )
        .toList(growable: false);

    if (ayat.isEmpty) {
      throw StateError('لا توجد آيات لهذا المستوى داخل مصدر البيانات الحالي');
    }

    return _LoadedMemorizationLevel(
      level: level,
      ayat: ayat,
      allSurahAyat: surah.ayat,
      difficulty: _effectiveDifficulty(level),
    );
  }

  MemorizationDifficulty _effectiveDifficulty(MemorizationLevel level) {
    final base = widget.reviewMode || level.isCompleted
        ? level.difficulty.next
        : level.difficulty;
    if (level.isBossReview &&
        base.index < MemorizationDifficulty.medium.index) {
      return MemorizationDifficulty.medium;
    }
    return base;
  }

  Widget _buildLevelScaffold(
    BuildContext context,
    _LoadedMemorizationLevel loaded,
  ) {
    final hearts = _sessionHearts ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loaded.level.isBossReview ? 'تثبيت شامل' : loaded.level.surahName,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: _result != null
            ? _ResultView(
                result: _result!,
                hearts: hearts,
                onBack: () => Navigator.pop(context),
                onRetry: hearts > 0 ? () => _restartLevel() : null,
              )
            : hearts <= 0
            ? _NoHeartsView(onBack: () => Navigator.pop(context))
            : Column(
                children: [
                  _LevelHeader(
                    loaded: loaded,
                    ayahIndex: _currentAyahIndex,
                    mistakes: _mistakes,
                    hearts: hearts,
                    reviewMode: widget.reviewMode || loaded.level.isCompleted,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: SingleChildScrollView(
                        key: ValueKey(
                          '${loaded.currentAya(_currentAyahIndex).numberInSurah}-${loaded.difficulty.name}',
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: _buildExercise(loaded),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildExercise(_LoadedMemorizationLevel loaded) {
    final aya = loaded.currentAya(_currentAyahIndex);

    switch (loaded.difficulty) {
      case MemorizationDifficulty.beginner:
        return _BeginnerExercise(
          aya: aya,
          choices: _ayahChoices(loaded, aya),
          onAnswer: (choice) => _handleAnswer(choice == aya.text, loaded),
        );
      case MemorizationDifficulty.medium:
        final medium = _mediumQuestion(loaded, aya);
        return _MediumExercise(
          aya: aya,
          maskedText: medium.maskedText,
          choices: medium.choices,
          onAnswer: (choice) => _handleAnswer(choice == medium.answer, loaded),
        );
      case MemorizationDifficulty.hard:
        _ensureHardWords(aya);
        return _HardExercise(
          aya: aya,
          bank: _wordBank,
          selected: _selectedWords,
          onPick: (token) {
            setState(() {
              _wordBank = _wordBank
                  .where((item) => item.id != token.id)
                  .toList();
              _selectedWords = [..._selectedWords, token];
            });
          },
          onRemove: (token) {
            setState(() {
              _selectedWords = _selectedWords
                  .where((item) => item.id != token.id)
                  .toList();
              _wordBank = [..._wordBank, token];
            });
          },
          onCheck: () {
            final expected = _targetWords(aya, maxWords: 9);
            final answer = _selectedWords
                .map((token) => token.text)
                .toList(growable: false);
            _handleAnswer(_sameWords(expected, answer), loaded);
          },
        );
      case MemorizationDifficulty.expert:
        _ensureExpertInput(aya);
        return _ExpertExercise(
          aya: aya,
          controller: _expertController,
          targetPreview: _targetPhrase(aya, maxWords: 8),
          onCheck: () {
            final typed = _normalizeArabic(_expertController.text);
            final target = _normalizeArabic(_targetPhrase(aya, maxWords: 8));
            final fullAyah = _normalizeArabic(aya.text);
            _handleAnswer(typed == target || typed == fullAyah, loaded);
          },
        );
    }
  }

  Future<void> _handleAnswer(
    bool isCorrect,
    _LoadedMemorizationLevel loaded,
  ) async {
    if (_finishing || _result != null) return;

    if (isCorrect) {
      if (_currentAyahIndex + 1 >= loaded.ayat.length) {
        await _finish(loaded, failedByHearts: false);
        return;
      }
      setState(() {
        _currentAyahIndex += 1;
        _clearExerciseState();
      });
      return;
    }

    await _registerMistake(loaded);
  }

  Future<void> _registerMistake(_LoadedMemorizationLevel loaded) async {
    final hearts = await ref
        .read(memorizationControllerProvider.notifier)
        .loseHeart();
    if (!mounted) return;

    setState(() {
      _mistakes += 1;
      _sessionHearts = hearts;
    });

    final failed = hearts <= 0 || _mistakes > 3;
    if (failed) {
      await _finish(loaded, failedByHearts: hearts <= 0);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'إجابة غير صحيحة. القلوب المتبقية: ${_toArabicDigits(hearts)}',
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _finish(
    _LoadedMemorizationLevel loaded, {
    required bool failedByHearts,
  }) async {
    if (_finishing) return;
    _finishing = true;

    final elapsed = DateTime.now().difference(_startedAt);
    final result = await ref
        .read(memorizationControllerProvider.notifier)
        .finishLevel(
          levelId: loaded.level.levelId,
          mistakes: _mistakes,
          elapsed: elapsed,
          reviewMode: widget.reviewMode || loaded.level.isCompleted,
          failedByHearts: failedByHearts,
        );

    if (!mounted) return;
    setState(() {
      _result = result;
      _finishing = false;
    });
  }

  void _restartLevel() {
    setState(() {
      _currentAyahIndex = 0;
      _mistakes = 0;
      _result = null;
      _finishing = false;
      _startedAt = DateTime.now();
      _clearExerciseState();
    });
  }

  void _clearExerciseState() {
    _hardAyahKey = null;
    _wordBank = const [];
    _selectedWords = const [];
    _expertAyahKey = null;
    _expertController.clear();
  }

  List<String> _ayahChoices(_LoadedMemorizationLevel loaded, Aya aya) {
    final choices = <String>{aya.text};
    for (final other in [...loaded.ayat, ...loaded.allSurahAyat]) {
      if (choices.length >= 4) break;
      if (other.text.trim().isNotEmpty &&
          other.numberInSurah != aya.numberInSurah) {
        choices.add(other.text);
      }
    }
    final out = choices.toList(growable: false);
    out.shuffle(math.Random(aya.numberInSurah + loaded.level.sequence));
    return out;
  }

  _MediumQuestion _mediumQuestion(_LoadedMemorizationLevel loaded, Aya aya) {
    final words = _words(aya.text);
    if (words.isEmpty) {
      return _MediumQuestion(
        maskedText: aya.text,
        answer: aya.text,
        choices: [aya.text],
      );
    }

    final answerIndex = words.length <= 3
        ? words.length - 1
        : words.length ~/ 2;
    final answer = words[answerIndex];
    final maskedWords = [...words]..[answerIndex] = 'ـــــــ';
    final options = <String>{answer};

    for (final item in loaded.allSurahAyat) {
      for (final word in _words(item.text)) {
        if (options.length >= 4) break;
        if (_normalizeArabic(word) != _normalizeArabic(answer) &&
            word.length > 2) {
          options.add(word);
        }
      }
      if (options.length >= 4) break;
    }

    final choices = options.toList(growable: false)
      ..shuffle(math.Random(aya.numberInSurah * 7 + loaded.level.sequence));

    return _MediumQuestion(
      maskedText: maskedWords.join(' '),
      answer: answer,
      choices: choices,
    );
  }

  void _ensureHardWords(Aya aya) {
    final key = '${aya.surah}:${aya.numberInSurah}';
    if (_hardAyahKey == key) return;

    final tokens = _targetWords(aya, maxWords: 9)
        .asMap()
        .entries
        .map((entry) => _WordToken(entry.key, entry.value))
        .toList(growable: false);
    final shuffled = [...tokens]..shuffle(math.Random(aya.numberInSurah * 31));

    _hardAyahKey = key;
    _wordBank = shuffled;
    _selectedWords = const [];
  }

  void _ensureExpertInput(Aya aya) {
    final key = '${aya.surah}:${aya.numberInSurah}';
    if (_expertAyahKey == key) return;
    _expertAyahKey = key;
    _expertController.clear();
  }

  List<String> _targetWords(Aya aya, {required int maxWords}) {
    final words = _words(aya.text);
    return words.take(math.min(maxWords, words.length)).toList(growable: false);
  }

  String _targetPhrase(Aya aya, {required int maxWords}) {
    return _targetWords(aya, maxWords: maxWords).join(' ');
  }

  bool _sameWords(List<String> expected, List<String> answer) {
    if (expected.length != answer.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (_normalizeArabic(expected[i]) != _normalizeArabic(answer[i])) {
        return false;
      }
    }
    return true;
  }
}

class _LoadedMemorizationLevel {
  const _LoadedMemorizationLevel({
    required this.level,
    required this.ayat,
    required this.allSurahAyat,
    required this.difficulty,
  });

  final MemorizationLevel level;
  final List<Aya> ayat;
  final List<Aya> allSurahAyat;
  final MemorizationDifficulty difficulty;

  Aya currentAya(int index) => ayat[index.clamp(0, ayat.length - 1).toInt()];
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.loaded,
    required this.ayahIndex,
    required this.mistakes,
    required this.hearts,
    required this.reviewMode,
  });

  final _LoadedMemorizationLevel loaded;
  final int ayahIndex;
  final int mistakes;
  final int hearts;
  final bool reviewMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (ayahIndex + 1) / loaded.ayat.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.62)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _HeaderPill(
                  icon: Icons.favorite_rounded,
                  text: _toArabicDigits(hearts),
                  color: const Color(0xFFE9445A),
                ),
                const SizedBox(width: 8),
                _HeaderPill(
                  icon: Icons.close_rounded,
                  text: _toArabicDigits(mistakes),
                  color: const Color(0xFFDC6E25),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    reviewMode ? 'مراجعة أصعب' : loaded.difficulty.modeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${loaded.level.surahName}  •  آيات ${_toArabicDigits(loaded.level.ayahStart)}-${_toArabicDigits(loaded.level.ayahEnd)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'آية ${_toArabicDigits(ayahIndex + 1)} من ${_toArabicDigits(loaded.ayat.length)}',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeginnerExercise extends StatelessWidget {
  const _BeginnerExercise({
    required this.aya,
    required this.choices,
    required this.onAnswer,
  });

  final Aya aya;
  final List<String> choices;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return _ExerciseCard(
      icon: Icons.touch_app_rounded,
      title: 'اختر نص الآية الصحيح',
      subtitle: 'الآية ${_toArabicDigits(aya.numberInSurah)}',
      child: Column(
        children: choices
            .map(
              (choice) =>
                  _AnswerTile(text: choice, onTap: () => onAnswer(choice)),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _MediumExercise extends StatelessWidget {
  const _MediumExercise({
    required this.aya,
    required this.maskedText,
    required this.choices,
    required this.onAnswer,
  });

  final Aya aya;
  final String maskedText;
  final List<String> choices;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _ExerciseCard(
      icon: Icons.extension_rounded,
      title: 'أكمل الكلمة الناقصة',
      subtitle: 'الآية ${_toArabicDigits(aya.numberInSurah)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              maskedText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                height: 1.9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: choices
                .map(
                  (choice) => FilledButton.tonal(
                    onPressed: () => onAnswer(choice),
                    child: Text(
                      choice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _HardExercise extends StatelessWidget {
  const _HardExercise({
    required this.aya,
    required this.bank,
    required this.selected,
    required this.onPick,
    required this.onRemove,
    required this.onCheck,
  });

  final Aya aya;
  final List<_WordToken> bank;
  final List<_WordToken> selected;
  final ValueChanged<_WordToken> onPick;
  final ValueChanged<_WordToken> onRemove;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _ExerciseCard(
      icon: Icons.reorder_rounded,
      title: 'رتب بداية الآية',
      subtitle: 'الآية ${_toArabicDigits(aya.numberInSurah)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            ),
            child: selected.isEmpty
                ? Center(
                    child: Text(
                      'اختر الكلمات بالترتيب الصحيح',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected
                        .map(
                          (token) => InputChip(
                            label: Text(token.text),
                            onDeleted: () => onRemove(token),
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bank
                .map(
                  (token) => ActionChip(
                    label: Text(token.text),
                    onPressed: () => onPick(token),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: selected.isEmpty ? null : onCheck,
            icon: const Icon(Icons.check_rounded),
            label: const Text('تحقق'),
          ),
        ],
      ),
    );
  }
}

class _ExpertExercise extends StatelessWidget {
  const _ExpertExercise({
    required this.aya,
    required this.controller,
    required this.targetPreview,
    required this.onCheck,
  });

  final Aya aya;
  final TextEditingController controller;
  final String targetPreview;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _ExerciseCard(
      icon: Icons.edit_note_rounded,
      title: 'اكتب من الذاكرة',
      subtitle:
          'اكتب بداية الآية ${_toArabicDigits(aya.numberInSurah)} بدون مساعدات',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 7,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب هنا...',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
            ),
            style: const TextStyle(fontSize: 20, height: 1.7),
          ),
          const SizedBox(height: 10),
          Text(
            'المطلوب: ${_toArabicDigits(_words(targetPreview).length)} كلمات من بداية الآية.',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCheck,
            icon: const Icon(Icons.check_rounded),
            label: const Text('تحقق'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.70),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              height: 1.7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.hearts,
    required this.onBack,
    required this.onRetry,
  });

  final MemorizationSessionResult result;
  final int hearts;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final success = result.success;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.09),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                success
                    ? Icons.emoji_events_rounded
                    : Icons.heart_broken_rounded,
                size: 58,
                color: success
                    ? const Color(0xFFFFB332)
                    : const Color(0xFFE9445A),
              ),
              const SizedBox(height: 12),
              Text(
                success ? 'أحسنت، انتهى المستوى' : 'انتهت المحاولة',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                success
                    ? 'حصلت على ${_toArabicDigits(result.xpEarned)} XP وقوة حفظ ${_toArabicDigits(result.memoryStrength)}٪.'
                    : 'أعد المحاولة بعد مراجعة الآيات. قوة الحفظ الآن ${_toArabicDigits(result.memoryStrength)}٪.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < result.stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFFFB332),
                    size: 34,
                  );
                }),
              ),
              const SizedBox(height: 18),
              _ResultMetric(
                icon: Icons.close_rounded,
                label: 'الأخطاء',
                value: _toArabicDigits(result.mistakes),
              ),
              _ResultMetric(
                icon: Icons.psychology_rounded,
                label: 'الصعوبة القادمة',
                value: result.difficulty.label,
              ),
              _ResultMetric(
                icon: Icons.favorite_rounded,
                label: 'القلوب المتبقية',
                value: _toArabicDigits(hearts),
              ),
              if (result.unlockedNext)
                const _ResultBanner(
                  icon: Icons.lock_open_rounded,
                  text: 'تم فتح المستوى التالي',
                ),
              if (success && result.stars == 1)
                const _ResultBanner(
                  icon: Icons.replay_rounded,
                  text:
                      'نجمة واحدة لا تفتح المستوى التالي. أعده لتحصل على نجمتين.',
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.map_rounded),
                label: const Text('العودة للخريطة'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المستوى'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoHeartsView extends StatelessWidget {
  const _NoHeartsView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 54,
              color: Color(0xFFE9445A),
            ),
            const SizedBox(height: 12),
            const Text(
              'لا توجد قلوب كافية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'القلوب محفوظة محليًا وتعود في يوم جديد. راجع من الخريطة لاحقًا.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onBack,
              child: const Text('العودة للخريطة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelLoadError extends StatelessWidget {
  const _LevelLoadError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 44),
              const SizedBox(height: 12),
              const Text(
                'تعذر تحميل آيات المستوى',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediumQuestion {
  const _MediumQuestion({
    required this.maskedText,
    required this.answer,
    required this.choices,
  });

  final String maskedText;
  final String answer;
  final List<String> choices;
}

class _WordToken {
  const _WordToken(this.id, this.text);

  final int id;
  final String text;
}

List<String> _words(String text) {
  return text
      .replaceAll('\u06DD', ' ')
      .split(RegExp(r'\s+'))
      .map((word) => word.trim())
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}

String _normalizeArabic(String input) {
  var text = input.trim();
  const diacritics = r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]';
  text = text.replaceAll(RegExp(diacritics), '');
  text = text.replaceAll('\u0640', '');
  text = text.replaceAll(RegExp(r'[^\u0600-\u06FF0-9\s]'), '');
  text = text.replaceAll(RegExp('[\u0623\u0625\u0622\u0671]'), '\u0627');
  text = text.replaceAll('\u0649', '\u064A');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

String _toArabicDigits(num value) {
  const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final text = value.toString();
  final out = StringBuffer();
  for (final char in text.split('')) {
    final digit = int.tryParse(char);
    out.write(digit == null ? char : east[digit]);
  }
  return out.toString();
}
