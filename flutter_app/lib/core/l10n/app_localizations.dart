import 'package:flutter/material.dart';

/// Simple localization support (TR/EN)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('tr'),
    Locale('en'),
  ];

  bool get isTurkish => locale.languageCode == 'tr';

  String get languageCode => locale.languageCode;

  // Common
  String get appName => isTurkish ? 'Fal & Astro' : 'Fortune & Astro';
  String get loading => isTurkish ? 'Yükleniyor...' : 'Loading...';
  String get error => isTurkish ? 'Hata' : 'Error';
  String get retry => isTurkish ? 'Tekrar Dene' : 'Retry';
  String get cancel => isTurkish ? 'İptal' : 'Cancel';
  String get save => isTurkish ? 'Kaydet' : 'Save';
  String get delete => isTurkish ? 'Sil' : 'Delete';
  String get confirm => isTurkish ? 'Onayla' : 'Confirm';
  String get done => isTurkish ? 'Tamam' : 'Done';
  String get next => isTurkish ? 'İleri' : 'Next';
  String get back => isTurkish ? 'Geri' : 'Back';
  String get skip => isTurkish ? 'Atla' : 'Skip';

  // Auth
  String get signIn => isTurkish ? 'Giriş Yap' : 'Sign In';
  String get signUp => isTurkish ? 'Kayıt Ol' : 'Sign Up';
  String get signOut => isTurkish ? 'Çıkış Yap' : 'Sign Out';
  String get signInWithApple => isTurkish ? 'Apple ile Giriş' : 'Sign in with Apple';
  String get signInWithEmail => isTurkish ? 'E-posta ile Giriş' : 'Sign in with Email';
  String get email => isTurkish ? 'E-posta' : 'Email';
  String get password => isTurkish ? 'Şifre' : 'Password';
  String get forgotPassword => isTurkish ? 'Şifremi Unuttum' : 'Forgot Password';

  // Onboarding
  String get onboardingTitle => isTurkish ? 'Doğum Bilgileriniz' : 'Your Birth Info';
  String get onboardingSubtitle => isTurkish
      ? 'Kişisel astroloji yorumlarınız için doğum bilgilerinizi girin'
      : 'Enter your birth info for personalized astrology readings';
  String get birthDate => isTurkish ? 'Doğum Tarihi' : 'Birth Date';
  String get birthTime => isTurkish ? 'Doğum Saati' : 'Birth Time';
  String get birthTimeOptional =>
      isTurkish ? 'Doğum Saati (Opsiyonel)' : 'Birth Time (Optional)';
  String get birthCity => isTurkish ? 'Doğum Şehri' : 'Birth City';
  String get birthCountry => isTurkish ? 'Doğum Ülkesi' : 'Birth Country';
  String get unknownTime => isTurkish ? 'Saati bilmiyorum' : 'I don\'t know the time';

  // Home
  String get home => isTurkish ? 'Ana Sayfa' : 'Home';
  String get fortune => isTurkish ? 'Fal' : 'Fortune';
  String get astro => isTurkish ? 'Astro' : 'Astro';
  String get history => isTurkish ? 'Geçmiş' : 'History';
  String get profile => isTurkish ? 'Profil' : 'Profile';
  String get readFortune => isTurkish ? 'Fal Baktır' : 'Read Fortune';
  String get dailyAstro => isTurkish ? 'Bugünkü Astro' : 'Daily Astro';

  // Fortune
  String get uploadCupImage => isTurkish ? 'Fincan Fotoğrafı' : 'Cup Photo';
  String get uploadSaucerImage =>
      isTurkish ? 'Tabak Fotoğrafı (Opsiyonel)' : 'Saucer Photo (Optional)';
  String get selectIntent => isTurkish ? 'Niyet Seç' : 'Select Intent';
  String get intentLove => isTurkish ? 'Aşk' : 'Love';
  String get intentMoney => isTurkish ? 'Para' : 'Money';
  String get intentCareer => isTurkish ? 'Kariyer' : 'Career';
  String get intentGeneral => isTurkish ? 'Genel' : 'General';
  String get readingFortune => isTurkish ? 'Falınız yorumlanıyor...' : 'Reading your fortune...';
  String get fortuneResult => isTurkish ? 'Fal Sonucu' : 'Fortune Result';
  String get symbols => isTurkish ? 'Semboller' : 'Symbols';
  String get timelines => isTurkish ? 'Zaman Çizelgesi' : 'Timelines';
  String get near => isTurkish ? '7 Gün' : '7 Days';
  String get mid => isTurkish ? '1 Ay' : '1 Month';
  String get far => isTurkish ? '3 Ay' : '3 Months';

  // Feedback
  String get didItComeTrue => isTurkish ? 'Tuttu mu?' : 'Did it come true?';
  String get feedbackPrompt => isTurkish
      ? 'Bu fal tuttu mu? Geri bildiriminiz bizim için önemli.'
      : 'Did this reading come true? Your feedback is important to us.';
  String get yes => isTurkish ? 'Evet' : 'Yes';
  String get no => isTurkish ? 'Hayır' : 'No';
  String get addNote => isTurkish ? 'Not Ekle (Opsiyonel)' : 'Add Note (Optional)';
  String get thankYou => isTurkish ? 'Teşekkürler!' : 'Thank you!';

  // Astro Reports
  String get natalReport => isTurkish ? 'Doğum Haritası' : 'Birth Chart';
  String get weeklyReport => isTurkish ? 'Haftalık Yorum' : 'Weekly Reading';
  String get monthlyReport => isTurkish ? 'Aylık Yorum' : 'Monthly Reading';
  String get yearlyReport => isTurkish ? 'Yıllık Yorum' : 'Yearly Reading';
  String get loveReport => isTurkish ? 'Aşk Yorumu' : 'Love Reading';
  String get careerReport => isTurkish ? 'Kariyer Yorumu' : 'Career Reading';
  String get personality => isTurkish ? 'Kişilik' : 'Personality';

  // Settings
  String get settings => isTurkish ? 'Ayarlar' : 'Settings';
  String get language => isTurkish ? 'Dil' : 'Language';
  String get theme => isTurkish ? 'Tema' : 'Theme';
  String get darkMode => isTurkish ? 'Karanlık Mod' : 'Dark Mode';
  String get notifications => isTurkish ? 'Bildirimler' : 'Notifications';
  String get deleteAccount => isTurkish ? 'Hesabı Sil' : 'Delete Account';
  String get privacy => isTurkish ? 'Gizlilik Politikası' : 'Privacy Policy';
  String get terms => isTurkish ? 'Kullanım Koşulları' : 'Terms of Service';

  // Premium
  String get premium => isTurkish ? 'Premium' : 'Premium';
  String get goPremium => isTurkish ? 'Premium\'a Geç' : 'Go Premium';
  String get dailyLimitReached =>
      isTurkish ? 'Günlük limit aşıldı' : 'Daily limit reached';
  String get upgradeToPremium =>
      isTurkish ? 'Sınırsız fal için Premium\'a geçin' : 'Upgrade to Premium for unlimited readings';

  // Disclaimer
  String get disclaimer => isTurkish
      ? 'Bu uygulama eğlence amaçlıdır. Sunulan yorumlar profesyonel tavsiye yerine geçmez.'
      : 'This app is for entertainment purposes. The readings provided do not replace professional advice.';
  String get dataConsent => isTurkish
      ? 'Doğum bilgileriniz ve fal fotoğraflarınız güvenli şekilde saklanır ve sadece size özel yorumlar oluşturmak için kullanılır.'
      : 'Your birth information and fortune photos are stored securely and used only to create personalized readings for you.';

  // Errors
  String get networkError =>
      isTurkish ? 'İnternet bağlantısı bulunamadı' : 'No internet connection';
  String get serverError => isTurkish ? 'Sunucu hatası' : 'Server error';
  String get unknownError => isTurkish ? 'Bir hata oluştu' : 'An error occurred';
  String get profileNotFound => isTurkish
      ? 'Profil bulunamadı. Lütfen doğum bilgilerinizi girin.'
      : 'Profile not found. Please enter your birth information.';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
