class Constans {
  static const isAlreadyRegistered = "auth/is-already-registered";
  static const loginWithGoogle = "auth/login-with-google";
  static const loginWithApple = "auth/login-with-apple";
  static const sendOtpEmail = "auth/send-otp-email";
  static const verifyOtpEmail = "auth/verify-email-otp-and-login";
  static const otpVerify = "auth/verify-text-message-and-login";
  static const updateContentFeedback = "mobile-feedback/add-or-update-feedback";
  static const updateJournal = "journal/add-or-update-journals";
  static const sendOtp = "auth/sendTextMessage";
  static const getProfile = "users/get-user-details?userId=";
  static const getSimilarPrompt = "prompt/get-similar-names?word=";
  static const getContentList = "web-page/contents-mobile?userId=";
  static const getJournalList = "journal/journals?userId=";
  static const logContent = "mood/log-content-interaction";
  static const logEmi = "feedback/log-content-response";
  static const rewardDetails = "users/reward-details";
  static const postMetric = "data/sync";
  static const contentList =
      "mood/generations?moodId=d4e441e4-b399-4a9a-8df0-eef6541199d5&userId=";
  static const updateProfile = "users/updateUser";
  static const refreshToken = "auth/isAlreadyLoggedIn";
  static const favourite = "game/game-favourite";
  static const createCollection = "mobile-favourites/add-or-update-collections";
  static const favouritesUpdate = "mobile-favourites/add-or-update-favourite";
  static const overallFeedback =
      "mobile-feedback/save-overall-feedback-results";
  static const getFavorites = "mobile-favourites/favourites?userId=";
  static const getCollection = "mobile-favourites/collections?userId=";
  static const updateAssessment = "survey/save-survey-results";
  static const updateFeedbackSurvey = "feedback/save-feedback-results";
  static const getAssessmentList = "feedback/feedback-questions?feedbackId=";

  static const DATE_FORMAT_1 = "yyyy-MM-dd'T'HH:mm:ssZ";
  static const getAllClinics = "clinic/get-all-clinic";
}
