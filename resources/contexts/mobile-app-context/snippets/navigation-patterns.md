# Navigation Patterns

## React Native Navigation Setup

### Stack Navigator with Tab Navigator

```typescript
// navigation/AppNavigator.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useAuth } from '@/hooks/useAuth';
import Icon from 'react-native-vector-icons/MaterialIcons';

// Type definitions
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  PatientDetail: { patientId: string };
  Settings: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Patients: undefined;
  Appointments: undefined;
  Profile: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

// Tab Navigator Component
function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string;

          switch (route.name) {
            case 'Home':
              iconName = 'home';
              break;
            case 'Patients':
              iconName = 'people';
              break;
            case 'Appointments':
              iconName = 'calendar-today';
              break;
            case 'Profile':
              iconName = 'person';
              break;
            default:
              iconName = 'circle';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: 'gray',
        headerShown: false,
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Patients" component={PatientsScreen} />
      <Tab.Screen name="Appointments" component={AppointmentsScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

// Main App Navigator
export function AppNavigator() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {!isAuthenticated ? (
          <Stack.Screen name="Auth" component={AuthNavigator} />
        ) : (
          <>
            <Stack.Screen name="Main" component={MainTabs} />
            <Stack.Screen
              name="PatientDetail"
              component={PatientDetailScreen}
              options={{
                headerShown: true,
                headerTitle: 'Patient Details',
                presentation: 'modal'
              }}
            />
            <Stack.Screen
              name="Settings"
              component={SettingsScreen}
              options={{
                headerShown: true,
                headerTitle: 'Settings'
              }}
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Navigation Hooks

```typescript
// hooks/useNavigation.ts
import { useNavigation as useRNNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/AppNavigator';

export function useNavigation() {
  return useRNNavigation<NativeStackNavigationProp<RootStackParamList>>();
}

// Usage in components
import { useNavigation } from '@/hooks/useNavigation';

function PatientCard({ patient }: { patient: Patient }) {
  const navigation = useNavigation();

  const handlePress = () => {
    navigation.navigate('PatientDetail', { patientId: patient.id });
  };

  return (
    <TouchableOpacity onPress={handlePress}>
      {/* Patient card content */}
    </TouchableOpacity>
  );
}
```

## Flutter Navigation Setup

### Navigator 2.0 with GoRouter

```dart
// lib/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final router = GoRouter(
    refreshListenable: authService,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/patients',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PatientsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return PatientDetailScreen(patientId: patientId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// Bottom Navigation Bar
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/patients')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/patients');
        break;
      case 2:
        GoRouter.of(context).go('/appointments');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
```
