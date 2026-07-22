# Toast Notification System

This Flutter app now includes a comprehensive toast notification system with beautiful design, rounded corners, and backdrop filter effects.

## Features

- **Four Toast Types**: Success (green), Error (red), Warning (orange), and Info (blue)
- **Beautiful Design**: Rounded corners, backdrop filters, and smooth animations
- **Auto-dismiss**: Toasts automatically disappear after a configurable duration
- **Manual Dismiss**: Users can tap the close button to dismiss toasts early
- **Theme Aware**: Automatically adapts to light/dark themes
- **Consistent Styling**: Uses the app's design language and FuturaPT font

## Usage

### Basic Toast Notifications

```dart
import 'package:readrift/widgets/custom_toast.dart';

// Success toast (green)
ToastService.showSuccess(context, "Operation completed successfully!");

// Error toast (red)
ToastService.showError(context, "Something went wrong. Please try again.");

// Warning toast (orange)
ToastService.showWarning(context, "Please check your input and try again.");

// Info toast (blue)
ToastService.showInfo(context, "Here's some helpful information.");
```

### Custom Duration

```dart
// Show toast for 5 seconds instead of default
ToastService.showSuccess(
  context, 
  "Custom duration message",
  duration: Duration(seconds: 5),
);
```

### Toast Types

- **Success**: Use for successful operations (green)
- **Error**: Use for errors and failures (red)
- **Warning**: Use for warnings and validation issues (orange)
- **Info**: Use for general information and navigation feedback (blue)

## Implementation Details

### CustomToast Widget

The `CustomToast` widget provides:
- Backdrop filter blur effects
- Rounded corners (20px radius)
- Dynamic colors based on toast type and theme
- Smooth animations and shadows
- Close button for manual dismissal

### ToastService

The `ToastService` provides static methods for easy toast creation:
- `showToast()` - Generic toast with custom type
- `showSuccess()` - Success toast (green)
- `showError()` - Error toast (red)
- `showWarning()` - Warning toast (orange)
- `showInfo()` - Info toast (blue)

## Where Toast Notifications Are Used

### Authentication
- Login success/error messages
- Signup success/error messages
- Password reset confirmations
- Profile photo updates

### User Actions
- Book downloads and library additions
- Bookmark management
- Notification preferences
- Account settings changes

### Navigation
- Screen navigation feedback
- Search operations
- Error handling for network requests

### System Feedback
- Feature availability notices
- Coming soon notifications
- Success confirmations

## Styling

The toast system automatically adapts to the app's theme:
- **Light Theme**: Lighter background colors with darker text
- **Dark Theme**: Darker background colors with lighter text
- **Consistent**: Uses the app's color palette and typography

## Best Practices

1. **Use Appropriate Types**: Match the toast type to the message content
2. **Keep Messages Short**: Toast messages should be concise and clear
3. **Don't Overuse**: Reserve toasts for important feedback, not every action
4. **Consistent Language**: Use similar wording patterns across the app
5. **Accessibility**: Ensure messages are clear and helpful for all users

## Example Implementation

```dart
// In a login function
try {
  await authService.signIn(email: email, password: password);
  ToastService.showSuccess(context, "Login successful!");
  context.go('/home');
} catch (e) {
  ToastService.showError(context, "Login failed. Please check your credentials.");
}
```

This toast notification system provides a modern, user-friendly way to communicate with users throughout the app while maintaining the beautiful design aesthetic.
