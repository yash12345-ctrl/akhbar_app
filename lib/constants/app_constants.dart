
class AppConstants {
  // @NOTE(muktar): If you're running the server locally and using the Android emulator,
  // then your server endpoint should be 10.0.2.2:8000 instead of localhost:8000 as
  // AVD uses 10.0.2.2 as an alias to your host loopback interface (i.e) localhost
  // the Local IP address would not work either.
  static const String baseUrl = "https://akhbarmashriq.com";

  static const String apiArticleUrl = "$baseUrl/api/articles";
  static const String apiPollUrl = "$baseUrl/api/polls";
  static const String apiPollVoteUrl = "$baseUrl/api/polls";
  static const String apiDigitalAdUrl = "$baseUrl/api/advertisements";
  static const String apiUserLoginUrl = "$baseUrl/api/auth/login";
  static const String apiUserOTPLoginUrl = "$baseUrl/api/auth/otp-login";
  static const String apiUserLogoutUrl = "$baseUrl/api/auth/logout";
  static const String apiUserRegisterUrl = "$baseUrl/api/auth/register";
  static const String apiUserForgotPasswordSendOtpUrl = "$baseUrl/api/auth/forgot-password/send-otp";
  static const String apiUserForgotPasswordVerifyOtpUrl = "$baseUrl/api/auth/forgot-password/verify-otp";
  static const String apiUserForgotPasswordResetUrl = "$baseUrl/api/auth/forgot-password/reset";
  static const String apiUserAccountDeleteUrl = "$baseUrl/api/my-profile/delete";
  static const String apiEPaperUrl = "$baseUrl/api/enews";

  static const String apiEPaperEditionUrl = "$baseUrl/api/editions";
  static const String apiCategoryUrl = "$baseUrl/api/categories";
  static const String apiProfileImageUploadUrl = "$baseUrl/api/users";
  static const String apiArticleTTSUrl = "$baseUrl/api/articles/ARTICLE_ID/text-to-speech?device=phone";

  static const String fontName = "BarlowCondensed";

  static const String savedAuthKey = "saved_auth";

  static const String defaultImage = "$baseUrl/assets/img/default-image.jpg";
  static const String logoUrduImage = "assets/img/logo-rounded-ur.png";
  static const String logoEnglishImage = "assets/img/logo-rounded-en.png";

  static const String ARTICLE_PUBLISH_FCM_TOPIC = "latest_article";

  static const String methodChannel = "akhbarmashriq";
  static const String enableScreenCaptureMethod = "enableScreenCapture";
  static const String disableScreenCaptureMethod = "disableScreenCapture";
}