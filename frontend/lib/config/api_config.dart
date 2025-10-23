class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';

  // Autenticação
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';

  // Dashboard
  static const String dashboard = '$baseUrl/dashboard';

  // Vacas
  static const String vacas = '$baseUrl/vacas';
  static String vacaByQrCode(String qrCode) => '$vacas/qr-code/$qrCode';
  static String vacaByBrinco(String brinco) => '$vacas/brinco/$brinco';
  static String searchVacas(String nome) => '$vacas/search?nome=$nome';
  static String vacaEstatisticas(int vacaId) => '$vacas/$vacaId/estatisticas';

  // Ações das vacas
  static String registrarOrdenha(int vacaId) => '$vacas/$vacaId/ordenha';
  static String registrarCio(int vacaId) => '$vacas/$vacaId/cio';
  static String registrarInseminacao(int vacaId) =>
      '$vacas/$vacaId/inseminacao';
  static String registrarPrenhez(int vacaId) => '$vacas/$vacaId/prenhez';
  static String registrarParto(int vacaId) => '$vacas/$vacaId/parto';
  static String registrarPeso(int vacaId) => '$vacas/$vacaId/peso';
}
