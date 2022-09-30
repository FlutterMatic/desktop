class ThemeState {
  final bool darkTheme;
  final bool systemTheme;

  const ThemeState({
    this.darkTheme = true,
    this.systemTheme = false,
  });

  factory ThemeState.initial() => const ThemeState();

  ThemeState copyWith({
    bool? darkTheme,
    bool? systemTheme,
  }) {
    return ThemeState(
      darkTheme: darkTheme ?? this.darkTheme,
      systemTheme: systemTheme ?? this.systemTheme,
    );
  }
}
