# 📱 SaSu Family Wealth Dashboard - Flutter Mobile App

## Overview
**SaSu** is a beautiful, calm, and motivating mobile app for family financial planning.

### Philosophy
- **Not an expense tracker** ❌
- **A Family Wealth & Future Readiness Dashboard** ✅
- Focus on confidence, safety, and future preparedness
- Premium, soft UI with calm colors (green/blue tones)

---

## 🎯 User Roles

### Admin (Father)
- Full CRUD access to all data
- Add, edit, delete assets, insurance, liabilities
- View all family financial information

### Family (Wife, Daughter)
- Read-only access
- View all financial data
- Calm, motivating dashboard experience

---

## 🏠 Main Features

### 1. Dashboard (Home Screen)
The heart of the app - shows:
- **Welcome message** - Personalized greeting
- **Net Worth** - Total assets minus liabilities
- **Wealth Health Score** (0-100) - Overall financial health indicator
- **Future Readiness** - Status of long-term preparedness
- **Quick Stats** - Insurance coverage and monthly burden
- **Motivational Message** - Encouraging family message

### 2. Assets Screen
Shows all family assets:
- Land
- House
- Vehicles
- Savings & Fixed Deposits
- EPF & Retirement Funds
- Shares & Investments
- Gold & Other assets

**Total Asset Value** displayed prominently at top

### 3. Insurance Screen
Displays protection and security:
- Life Insurance
- Medical Insurance
- Education Plans
- Vehicle Insurance
- Home Insurance

**Total Protection Coverage** shown with shield icon

### 4. Liabilities Screen
Calm presentation of financial obligations:
- Home Loans
- Vehicle Loans
- Personal Loans
- Education Loans
- Credit Cards

**Reassuring message**: "All liabilities are under control"

---

## 🎨 Design Principles

### Colors
- **Soft Green** (`#4CAF50`) - Primary, assets
- **Light Blue** (`#2196F3`) - Insurance, trust
- **Gold** (`#FFC107`) - Wealth, value
- **Soft Orange** (`#FF9800`) - Liabilities (calm, not harsh)
- **Cream Background** (`#FAFAFA`) - Easy on eyes

### Typography
- **Font**: Poppins (Google Fonts)
- **Large numbers** for key metrics
- **Plenty of white space**
- **Rounded cards** (20px radius)
- **Soft shadows**

### Emotional Design
Every screen should make users feel:
- ✅ Safe
- ✅ Prepared
- ✅ Proud
- ✅ Calm

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Navigate to mobile app directory**
```bash
cd sasu-mobile
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Update API endpoint**
Edit `lib/core/constants/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8080/api';
```

For Android Emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api';
```

For Physical Device, use your computer's IP:
```dart
static const String baseUrl = 'http://192.168.1.XXX:8080/api';
```

4. **Run the app**
```bash
flutter run
```

---

## 👥 Default Login Credentials

| User | Username | Password | Role |
|------|----------|----------|------|
| Father (You) | `admin` | `admin123` | ADMIN |
| Wife | `wife` | `wife123` | FAMILY |
| Daughter | `daughter` | `daughter123` | FAMILY |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_context.dart       # App vision & philosophy
│   │   └── api_config.dart        # API endpoints
│   ├── theme/
│   │   └── app_theme.dart         # Colors, fonts, styles
│   └── widgets/
│       └── info_card.dart         # Reusable card widget
│
├── data/
│   ├── models/
│   │   ├── user.dart              # User model
│   │   ├── asset.dart             # Asset model
│   │   ├── insurance.dart         # Insurance model
│   │   ├── liability.dart         # Liability model
│   │   └── dashboard_summary.dart # Dashboard data
│   └── services/
│       └── api_service.dart       # HTTP API calls
│
├── features/
│   ├── auth/
│   │   └── login_screen.dart      # Login page
│   ├── dashboard/
│   │   └── dashboard_screen.dart  # Main home screen
│   ├── assets/
│   │   └── assets_screen.dart     # Assets list
│   ├── insurance/
│   │   └── insurance_screen.dart  # Insurance list
│   └── liabilities/
│       └── liabilities_screen.dart # Liabilities list
│
└── main.dart                       # App entry point
```

---

## 🔐 Security
- JWT-based authentication
- Token stored securely in SharedPreferences
- Auto-logout on token expiry
- Role-based UI (Admin sees edit buttons, Family doesn't)

---

## 📊 Key Widgets

### InfoCard
Reusable card for displaying financial data:
```dart
InfoCard(
  title: 'Net Worth',
  value: 'Rs. 45.3Cr',
  subtitle: 'All assets minus liabilities',
  icon: Icons.account_balance_wallet,
  gradient: AppTheme.greenGradient,
)
```

### Wealth Score Display
Circular progress indicator showing financial health (0-100)

### Motivational Messages
Dynamic messages based on score:
- 80+: "Your family is financially strong! ❤️"
- 60+: "Great work! Foundation is solid. 👍"
- 40+: "Building a stable future! 💪"
- <40: "Every step matters! 🌱"

---

## 🛠️ Technology Stack
- **Flutter** 3.x
- **Dart** 3.x
- **Packages**:
  - `google_fonts` - Beautiful typography
  - `fl_chart` - Charts (future feature)
  - `provider` - State management
  - `http` - API communication
  - `shared_preferences` - Local storage
  - `intl` - Number formatting

---

## 🎯 Screens Explained

### Login Screen
- Clean, minimal design
- Shows demo credentials for easy testing
- Gradient background
- Error handling with friendly messages

### Dashboard Screen
- **Welcome section** - Personalized greeting
- **Net Worth card** - Prominent display with gradient
- **Wealth Score** - Circular progress (0-100)
- **Quick stats** - Insurance & monthly burden
- **Motivational card** - Encouraging message
- **Navigation cards** - Access to detail screens

### Assets Screen
- **Header** - Total assets with gradient
- **List** - Each asset with icon, name, value
- **Admin controls** - Edit/delete options
- **Floating action button** - Add new asset (admin only)

### Insurance Screen
- **Header** - Total coverage with shield icon
- **List** - Policies with details
- **Maturity info** - Future benefits highlighted
- **Protection theme** - Blue gradient

### Liabilities Screen
- **Reassurance message** - "All under control"
- **Progress bars** - Show how much paid
- **Calm colors** - No harsh red
- **Monthly burden** - Clearly displayed

---

## 📱 Mobile-Specific Features
- **Pull to refresh** - All screens
- **Smooth scrolling** - Optimized lists
- **Touch-friendly** - Large tap targets
- **Responsive** - Works on all screen sizes
- **Offline grace** - Shows last loaded data

---

## 🔜 Future Enhancements (Optional)
- [ ] Future Projections screen (age-based milestones)
- [ ] Charts & graphs (asset distribution, growth)
- [ ] Notifications (insurance renewal reminders)
- [ ] Biometric login (fingerprint/face)
- [ ] Export reports (PDF)
- [ ] Multi-language support

---

## 🐛 Troubleshooting

### Cannot connect to backend
- Check if backend is running: `http://localhost:8080`
- Verify API base URL in `api_config.dart`
- For emulator: Use `10.0.2.2` instead of `localhost`
- For device: Use computer's local IP address

### Login fails
- Ensure backend database has users
- Check backend console for errors
- Verify credentials: `admin/admin123`

### White screen on startup
- Run `flutter clean`
- Run `flutter pub get`
- Restart the app

---

## 💡 Tips for Customization

### Change Currency
Edit in respective screens or create a constant:
```dart
// In api_service.dart or a constants file
static const String currencySymbol = 'Rs. '; // Change to $ or £
```

### Change Theme Colors
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryGreen = Color(0xFF4CAF50); // Your color
```

### Modify Motivational Messages
Edit `DashboardService.java` in backend or customize in Flutter.

---

## 🤝 Support
For issues:
1. Check backend is running
2. Verify API configuration
3. Check Flutter doctor: `flutter doctor`
4. See console logs for errors

---

## 📝 Notes
- This is a **read-mostly** app (not for daily data entry)
- Designed for **family viewing** (wife & daughter)
- **Admin** (you) updates data occasionally
- Focus is on **summary, confidence, clarity**

---

**Built with ❤️ for your family's financial future**

"A calm mind plans better. A confident family thrives together."

