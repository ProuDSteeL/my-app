abstract class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const shelves = '/shelves';
  static const downloads = '/downloads';
  static const profile = '/profile';
  static const bookDetail = '/book/:bookId';
  static const reader = '/book/:bookId/read';
  static const audioPlayer = '/book/:bookId/listen';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const resetPassword = '/auth/reset-password';
  static const subscription = '/subscription';
  static const admin = '/admin';
  static const adminBookEditor = '/admin/book/:bookId';
}
