import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { Provider as PaperProvider } from 'react-native-paper';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';

import HomeScreen from './src/screens/HomeScreen';
import BooksScreen from './src/screens/BooksScreen';
import AddBookScreen from './src/screens/AddBookScreen';
import BookDetailScreen from './src/screens/BookDetailScreen';
import SummaryScreen from './src/screens/SummaryScreen';
import { theme } from './src/styles/theme';
import { initializeApp } from './src/utils/initApp';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

function BooksStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen 
        name="BooksList" 
        component={BooksScreen} 
        options={{ title: 'Meine Bücher' }}
      />
      <Stack.Screen 
        name="AddBook" 
        component={AddBookScreen} 
        options={{ title: 'Buch hinzufügen' }}
      />
      <Stack.Screen 
        name="BookDetail" 
        component={BookDetailScreen} 
        options={{ title: 'Buchdetails' }}
      />
      <Stack.Screen 
        name="Summary" 
        component={SummaryScreen} 
        options={{ title: 'Zusammenfassung' }}
      />
    </Stack.Navigator>
  );
}

export default function App() {
  useEffect(() => {
    initializeApp();
  }, []);

  return (
    <PaperProvider theme={theme}>
      <NavigationContainer>
        <StatusBar style="auto" />
        <Tab.Navigator
          screenOptions={({ route }) => ({
            tabBarIcon: ({ focused, color, size }) => {
              let iconName: keyof typeof Ionicons.glyphMap;

              if (route.name === 'Home') {
                iconName = focused ? 'home' : 'home-outline';
              } else if (route.name === 'Books') {
                iconName = focused ? 'library' : 'library-outline';
              }

              return <Ionicons name={iconName} size={size} color={color} />;
            },
            tabBarActiveTintColor: theme.colors.primary,
            tabBarInactiveTintColor: 'gray',
          })}
        >
          <Tab.Screen 
            name="Home" 
            component={HomeScreen} 
            options={{ title: 'Start' }}
          />
          <Tab.Screen 
            name="Books" 
            component={BooksStack} 
            options={{ headerShown: false, title: 'Bücher' }}
          />
        </Tab.Navigator>
      </NavigationContainer>
    </PaperProvider>
  );
}
