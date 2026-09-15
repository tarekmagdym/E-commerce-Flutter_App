/// Centralized user-facing strings for ShopEasy.
class AppStrings {
  AppStrings._();

  // Splash / Welcome Screen
  static const String appName = 'ShopEasy';
  static const String splashTaglineLine1 = 'Great products';
  static const String splashTaglineLine2 = 'Better life';
  static const String getStarted = 'Get Started';

  // Login Screen
  static const String welcomeBack = 'Welcome back!';
  static const String loginSubtitle = 'Login to your account';
  static const String emailOrPhoneHint = 'Email or Phone';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String rememberMe = 'Remember me';
  static const String forgotPassword = 'Forgot password?';
  static const String login = 'Login';
  static const String or = 'or';
  static const String createNewAccount = 'Create new account';
  static const String continueWith = 'Or continue with';
  static const String google = 'Google';
  static const String microsoft = 'Microsoft';
  static const String googleLoginSuccessTitle = 'Logged in with Google Successfully';
  static const String microsoftLoginSuccessTitle = 'Logged in with Microsoft Successfully';
  static const String socialLoginSuccessSubtitle = 'You are now signed in to your account';

  // Forgot Password Flow
  static const String forgotPasswordTitle = 'Forgot Password?';
  static const String forgotPasswordSubtitle =
      'Enter your email and we\'ll send you a verification code';
  static const String sendCode = 'Send Code';
  static const String backToLogin = 'Back to Login';

  static const String verifyCodeTitle = 'Verify Code';
  static const String verifyCodeSubtitlePrefix = 'Enter the 6-digit code sent to';
  static const String codeHint = '6-digit code';
  static const String verifyCode = 'Verify Code';
  static const String resendCode = 'Resend code';

  static const String newPasswordTitle = 'Create New Password';
  static const String newPasswordSubtitle =
      'Your new password must be different from previous passwords';
  static const String newPasswordHint = 'New Password';
  static const String confirmPasswordHint = 'Confirm Password';
  static const String resetPasswordBtn = 'Reset Password';

  static const String resetSuccessTitle = 'Password Reset!';
  static const String resetSuccessSubtitle =
      'Your password has been changed successfully';
  static const String backToLoginBtn = 'Back to Login';

  // Create Account Flow
  static const String createAccountTitle = 'Create Account';
  static const String createAccountSubtitle = 'Sign up to get started';
  static const String fullNameHint = 'Full Name';
  static const String agreeToTerms = 'I agree to the Terms of Service and Privacy Policy';
  static const String createAccountBtn = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String loginNow = 'Login';
  static const String accountCreatedTitle = 'Account Created Successfully';
  static const String accountCreatedSubtitle = 'You can now log in to your account';

  // Home Screen
  static const String homeGreeting = 'Hello, Ahmed 👋';
  static const String homeSubtitle = 'Shop your favorite products';
  static const String searchHint = 'Search for products...';
  static const String newCollectionTitle = 'New Collection';
  static const String newCollectionSubtitle = 'Up to 50% Off';
  static const String shopNow = 'Shop Now';
  static const String bestSellers = 'Best Sellers';
  static const String seeAll = 'See All';

  // Categories Screen
  static const String categoriesTitle = 'Categories';
  static const String categoriesSearchHint = 'Search in this category...';
  static const String noProductsTitle = 'No products found';
  static const String noProductsSubtitle =
      'Try a different category or search term';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String tryAgain = 'Try Again';
  static const String productsCountSuffix = 'items';
  static const String allProductsTitle = 'All Products';

  // Product Details Screen
  static const String reviewsSuffix = 'reviews';
  static const String descriptionLabel = 'Description';
  static const String quantityLabel = 'Quantity';
  static const String addToCart = 'Add to Cart';
  static const String noDescriptionAvailable =
      'No description available for this product yet.';

  // Cart Screen
  static const String cartTitle = 'Shopping Cart';
  static const String totalLabel = 'Total';
  static const String checkout = 'Checkout';
  static const String emptyCartTitle = 'Your cart is empty';
  static const String emptyCartSubtitle = 'Looks like you haven\'t added anything yet';
  static const String browseProducts = 'Browse Products';
  static const String cartItemsCountSuffix = 'items';
  static const String addedToCart = 'Added to cart';

  // Checkout Screen
  static const String checkoutTitle = 'Checkout';
  static const String shippingAddress = 'Shipping Address';
  static const String changeLabel = 'Change';
  static const String paymentMethod = 'Payment Method';
  static const String cashOnDelivery = 'Cash on Delivery';
  static const String orderSummary = 'Order Summary';
  static const String subtotalLabel = 'Subtotal';
  static const String shippingFeeLabel = 'Shipping Fee';
  static const String placeOrder = 'Place Order';
  static const String orderPlacedTitle = 'Order Placed!';
  static const String orderPlacedMessage =
      'Your order has been placed successfully. You can track it from My Orders.';
  static const String viewOrders = 'View Orders';
  static const String continueShopping = 'Continue Shopping';

  // Addresses Screen
  static const String addressesTitle = 'Addresses';
  static const String addAddress = 'Add Address';
  static const String noAddressesTitle = 'No addresses yet';
  static const String noAddressesSubtitle = 'Add an address to check out faster next time';
  static const String removeAddress = 'Remove address';

  // Admin Dashboard
  static const String adminDashboardTitle = 'Dashboard';
  static const String adminProfileTitle = 'Admin Profile';
  static const String adminOrdersTitle = 'Orders';
  static const String totalProductsLabel = 'Total Products';
  static const String totalOrdersLabel = 'Total Orders';
  static const String totalUsersLabel = 'Total Users';
  static const String totalRevenueLabel = 'Total Revenue';
  static const String salesOverviewTitle = 'Sales Overview';
  static const String rangeWeekLabel = 'Week';
  static const String rangeMonthLabel = 'Month';
  static const String rangeYearLabel = 'Year';
  static const String recentOrdersTitle = 'Recent Orders';
  static const String viewAllLabel = 'View All';

  // Admin Categories
  static const String addCategoryTitle = 'Add Category';
  static const String editCategoryTitle = 'Edit Category';
  static const String categoryNameHint = 'Category name';
  static const String chooseIconLabel = 'Choose an icon';
  static const String noCategoriesTitle = 'No categories yet';
  static const String noCategoriesSubtitle = 'Add a category to start organizing products';
  static const String deleteCategoryTitle = 'Delete category?';
  static const String deleteCategoryMessagePrefix = 'This will remove';
  static const String editLabel = 'Edit';
  static const String deleteLabel = 'Delete';

  // Admin Products
  static const String productsTitle = 'Products';
  static const String addProductTitle = 'Add Product';
  static const String editProductTitle = 'Edit Product';
  static const String productNameHint = 'Product name';
  static const String priceHint = 'Price';
  static const String stockHint = 'Stock quantity';
  static const String descriptionHint = 'Product description';
  static const String categoryLabel = 'Category';
  static const String inStockLabel = 'in stock';
  static const String outOfStockLabel = 'Out of stock';
  static const String deleteProductTitle = 'Delete product?';
  static const String deleteProductMessagePrefix = 'This will remove';

  // Admin Orders
  static const String allFilterLabel = 'All';
  static const String updateStatusLabel = 'Update Status';
  static const String statusUpdatedMessage = 'Order status updated';

  // Admin Users
  static const String usersTitle = 'Users';
  static const String ordersLabel = 'Orders';
  static const String blockedLabel = 'Blocked';
  static const String blockUser = 'Block User';
  static const String unblockUser = 'Unblock User';
  static const String deleteUserTitle = 'Delete user?';
  static const String deleteUserMessagePrefix = 'This will remove';
  static const String noUsersTitle = 'No users yet';
  static const String noUsersSubtitle = 'Registered customers will appear here';
  // Admin Profile
  static const String administratorLabel = 'Administrator';
  static const String orderStatusLabel = 'Order Status';
  static const String itemsLabel = 'Items';

  // Profile Screen
  static const String profileTitle = 'Profile';
  static const String memberSincePrefix = 'Member since';
  static const String myOrders = 'My Orders';
  static const String paymentMethods = 'Payment Methods';
  static const String wishlist = 'Wishlist';
  static const String settingsLabel = 'Settings';
  static const String logout = 'Logout';
  static const String logoutConfirmTitle = 'Log out?';
  static const String logoutConfirmMessage =
      'You will need to sign in again to access your account.';
  static const String cancel = 'Cancel';
  static const String account = 'Account';
  static const String preferences = 'Preferences';
  static const String ordersCountLabel = 'Orders';
  static const String wishlistCountLabel = 'Wishlist';

  // Edit Profile Screen
  static const String editProfileTitle = 'Edit Profile';
  static const String saveChanges = 'Save Changes';
  static const String profileUpdatedMessage = 'Profile updated successfully';
  static const String phoneHint = 'Phone Number';

  // Orders Screen
  static const String ordersTitle = 'My Orders';
  static const String noOrdersTitle = 'No orders yet';
  static const String noOrdersSubtitle = 'Your order history will show up here';
  static const String orderIdPrefix = 'Order';

  // Payment Methods Screen
  static const String paymentMethodsTitle = 'Payment Methods';
  static const String addPaymentMethod = 'Add Payment Method';
  static const String defaultLabel = 'Default';
  static const String expiresLabel = 'Expires';
  static const String setAsDefault = 'Set as default';
  static const String removeCard = 'Remove card';
  static const String noPaymentMethodsTitle = 'No payment methods yet';
  static const String noPaymentMethodsSubtitle =
      'Add a card to check out faster next time';

  // Wishlist Screen
  static const String wishlistTitle = 'Wishlist';
  static const String emptyWishlistTitle = 'Your wishlist is empty';
  static const String emptyWishlistSubtitle =
      'Tap the heart icon on any product to save it here';
  static const String removedFromWishlist = 'Removed from wishlist';
  static const String undo = 'Undo';

  // Settings Screen
  static const String settingsTitle = 'Settings';
  static const String pushNotifications = 'Push Notifications';
  static const String pushNotificationsSubtitle =
      'Get notified about orders and offers';
  static const String orderUpdates = 'Order Updates';
  static const String orderUpdatesSubtitle = 'Email me about my order status';
  static const String darkMode = 'Dark Mode';
  static const String darkModeSubtitle = 'Switch to a darker color theme';
  static const String languageLabel = 'Language';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String appVersionLabel = 'App Version';
}