class ThemeState {
  final bool isDarkTheme;
  final bool isSystemTheme;

  const ThemeState({
    this.isDarkTheme = true,
    this.isSystemTheme = false,
  });

  factory ThemeState.initial() => const ThemeState();

  ThemeState copyWith({
    bool? isDarkTheme,
    bool? isSystemTheme,
  }) {
    return ThemeState(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      isSystemTheme: isSystemTheme ?? this.isSystemTheme,
    );
  }
}
