class SubscriptionContacts {
  // Впиши свои контакты. Пустую строку кнопка не показывает
  static const telegramUsername = 'ismoilflutter'; // без @
  static const phone = '+992987519495'; // например '+992XXXXXXXXX'

  // Цены и бейдж скидки. Пустая строка: показывается просто срок (1 месяц / 1 год)
  static const monthlyPrice = '49 TJS';
  static const yearlyPrice = '499 TJS';
  static const yearlyBadge = 'Экономия 15%';

  // Должны совпадать с TierRules.cs на backend
  static const freeLimit = 3;
  static const proLimit = 10;

  static const paymentNote =
      'Оплата переводом. Тариф включается сразу после подтверждения оплаты.';
}
