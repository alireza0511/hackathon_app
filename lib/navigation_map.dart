import 'navigation_models.dart';

class NavigationMap {
  static const Map<String, NavigationRoute> _routes = {
    'zelle_payment': NavigationRoute(
      intent: 'zelle_payment',
      primaryDeepLink: 'app://zelle',
      fallbackUrl: 'https://bank.example.com/zelle',
      displayName: 'Open Zelle',
      analyticsName: 'zelle_cta_tap',
      description: 'Send money with Zelle',
    ),
    'transfer_funds': NavigationRoute(
      intent: 'transfer_funds',
      primaryDeepLink: 'app://transfer?type=internal',
      fallbackUrl: 'https://bank.example.com/transfer?type=internal',
      displayName: 'Transfer Funds',
      analyticsName: 'transfer_cta_tap',
      description: 'Transfer between your accounts',
    ),
    'wire_transfer': NavigationRoute(
      intent: 'wire_transfer',
      primaryDeepLink: 'app://transfer?type=wire',
      fallbackUrl: 'https://bank.example.com/transfer?type=wire',
      displayName: 'Wire Transfer',
      analyticsName: 'wire_transfer_cta_tap',
      description: 'Send a wire transfer',
    ),
    'check_deposit': NavigationRoute(
      intent: 'check_deposit',
      primaryDeepLink: 'app://deposit',
      fallbackUrl: 'https://bank.example.com/deposit',
      displayName: 'Deposit Check',
      analyticsName: 'deposit_cta_tap',
      description: 'Deposit a check using your camera',
    ),
    'loan_access': NavigationRoute(
      intent: 'loan_access',
      primaryDeepLink: 'app://loans',
      fallbackUrl: 'https://bank.example.com/loans',
      displayName: 'View Loans',
      analyticsName: 'loans_cta_tap',
      description: 'Manage your loans and applications',
    ),
    'account_balance': NavigationRoute(
      intent: 'account_balance',
      primaryDeepLink: 'app://accounts',
      fallbackUrl: 'https://bank.example.com/accounts',
      displayName: 'View Accounts',
      analyticsName: 'accounts_cta_tap',
      description: 'Check your account balances',
    ),
    'bill_payment': NavigationRoute(
      intent: 'bill_payment',
      primaryDeepLink: 'app://billpay',
      fallbackUrl: 'https://bank.example.com/billpay',
      displayName: 'Pay Bills',
      analyticsName: 'billpay_cta_tap',
      description: 'Pay your bills online',
    ),
    'card_management': NavigationRoute(
      intent: 'card_management',
      primaryDeepLink: 'app://cards',
      fallbackUrl: 'https://bank.example.com/cards',
      displayName: 'Manage Cards',
      analyticsName: 'cards_cta_tap',
      description: 'Manage your debit and credit cards',
    ),
    'alerts_settings': NavigationRoute(
      intent: 'alerts_settings',
      primaryDeepLink: 'app://alerts',
      fallbackUrl: 'https://bank.example.com/alerts',
      displayName: 'Alert Settings',
      analyticsName: 'alerts_cta_tap',
      description: 'Configure account alerts',
    ),
    'profile_management': NavigationRoute(
      intent: 'profile_management',
      primaryDeepLink: 'app://profile',
      fallbackUrl: 'https://bank.example.com/profile',
      displayName: 'Edit Profile',
      analyticsName: 'profile_cta_tap',
      description: 'Update your personal information',
    ),
    'transaction_history': NavigationRoute(
      intent: 'transaction_history',
      primaryDeepLink: 'app://transactions',
      fallbackUrl: 'https://bank.example.com/transactions',
      displayName: 'View Transactions',
      analyticsName: 'transactions_cta_tap',
      description: 'View your transaction history',
    ),
    'customer_support': NavigationRoute(
      intent: 'customer_support',
      primaryDeepLink: 'app://support',
      fallbackUrl: 'https://bank.example.com/support',
      displayName: 'Get Support',
      analyticsName: 'support_cta_tap',
      description: 'Contact customer support',
    ),
  };

  static const List<IntentPattern> _patterns = [
    // Zelle patterns
    IntentPattern(
      intent: 'zelle_payment',
      keywords: ['zelle', 'quickpay', 'person-to-person', 'p2p'],
      phrases: ['send money', 'send cash', 'pay someone', 'money to friend', 'split bill'],
      baseConfidence: 0.9,
    ),
    
    // Transfer patterns
    IntentPattern(
      intent: 'transfer_funds',
      keywords: ['transfer', 'move money', 'internal transfer'],
      phrases: ['between accounts', 'move funds', 'transfer money', 'from checking to savings'],
      baseConfidence: 0.8,
    ),
    
    IntentPattern(
      intent: 'wire_transfer',
      keywords: ['wire', 'international', 'overseas'],
      phrases: ['wire transfer', 'send overseas', 'international transfer', 'wire money'],
      baseConfidence: 0.9,
    ),
    
    // Deposit patterns
    IntentPattern(
      intent: 'check_deposit',
      keywords: ['deposit', 'check', 'mobile deposit'],
      phrases: ['deposit check', 'add money', 'upload check', 'photograph check'],
      baseConfidence: 0.9,
    ),
    
    // Loan patterns
    IntentPattern(
      intent: 'loan_access',
      keywords: ['loan', 'mortgage', 'credit', 'borrow', 'financing'],
      phrases: ['apply for loan', 'loan application', 'get a loan', 'mortgage info'],
      baseConfidence: 0.8,
    ),
    
    // Balance patterns
    IntentPattern(
      intent: 'account_balance',
      keywords: ['balance', 'account', 'how much'],
      phrases: ['check balance', 'account balance', 'how much money', 'current balance'],
      baseConfidence: 0.9,
    ),
    
    // Bill payment patterns
    IntentPattern(
      intent: 'bill_payment',
      keywords: ['bill', 'payment', 'pay', 'utility'],
      phrases: ['pay bills', 'bill payment', 'pay utility', 'schedule payment'],
      baseConfidence: 0.8,
    ),
    
    // Card patterns
    IntentPattern(
      intent: 'card_management',
      keywords: ['card', 'debit', 'credit', 'freeze', 'lock', 'activate'],
      phrases: ['manage card', 'card settings', 'freeze card', 'activate card', 'card limit'],
      baseConfidence: 0.8,
    ),
    
    // Alerts patterns
    IntentPattern(
      intent: 'alerts_settings',
      keywords: ['alert', 'notification', 'notify', 'reminder'],
      phrases: ['set alert', 'notification settings', 'alert preferences', 'low balance alert'],
      baseConfidence: 0.7,
    ),
    
    // Profile patterns
    IntentPattern(
      intent: 'profile_management',
      keywords: ['profile', 'personal', 'information', 'update', 'change'],
      phrases: ['update profile', 'personal info', 'change address', 'contact info'],
      baseConfidence: 0.7,
    ),
    
    // Transaction patterns
    IntentPattern(
      intent: 'transaction_history',
      keywords: ['transaction', 'history', 'statement', 'activity'],
      phrases: ['transaction history', 'account activity', 'view transactions', 'recent activity'],
      baseConfidence: 0.8,
    ),
    
    // Support patterns
    IntentPattern(
      intent: 'customer_support',
      keywords: ['help', 'support', 'customer service', 'problem', 'issue'],
      phrases: ['need help', 'customer support', 'contact support', 'have a problem'],
      baseConfidence: 0.7,
    ),
  ];

  static NavigationRoute? getRoute(String intent) {
    return _routes[intent];
  }

  static List<NavigationRoute> getAllRoutes() {
    return _routes.values.toList();
  }

  static List<IntentPattern> getPatterns() {
    return _patterns;
  }

  static Map<String, NavigationRoute> get routes => _routes;
  static List<IntentPattern> get patterns => _patterns;

  // Quick reply suggestions for ambiguous cases
  static const Map<String, List<QuickReply>> _ambiguityResolvers = {
    'money_transfer': [
      QuickReply(text: 'Send to someone (Zelle)', intent: 'zelle_payment'),
      QuickReply(text: 'Between my accounts', intent: 'transfer_funds'),
      QuickReply(text: 'International wire', intent: 'wire_transfer'),
    ],
    'account_info': [
      QuickReply(text: 'Check balance', intent: 'account_balance'),
      QuickReply(text: 'View transactions', intent: 'transaction_history'),
      QuickReply(text: 'Account settings', intent: 'profile_management'),
    ],
    'card_help': [
      QuickReply(text: 'Manage cards', intent: 'card_management'),
      QuickReply(text: 'Report issue', intent: 'customer_support'),
      QuickReply(text: 'Set alerts', intent: 'alerts_settings'),
    ],
  };

  static List<QuickReply>? getAmbiguityResolver(String key) {
    return _ambiguityResolvers[key];
  }
}