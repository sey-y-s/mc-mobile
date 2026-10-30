class AppRoutes {
  const AppRoutes._();
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verify = '/verify';
  static const home = '/home';

  /// Lisible sans compte (depuis l'inscription) comme avec un compte (depuis « Plus »).
  static const terms = '/conditions';

  static const publicRoutes = {
    login,
    register,
    forgotPassword,
    resetPassword,
    verify,
  };
}
