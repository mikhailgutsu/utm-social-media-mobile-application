import React from 'react';
import { View, StyleSheet } from 'react-native';

interface BackgroundProps {
  children?: React.ReactNode;
}

export const Background: React.FC<BackgroundProps> = ({ children }) => {
  return (
    <View style={styles.container}>
      <View style={styles.content}>{children}</View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(225, 238, 255, 1)',
  },
  content: {
    flex: 1,
  },
});
