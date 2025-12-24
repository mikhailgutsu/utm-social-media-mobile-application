import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated } from 'react-native';

interface BackgroundProps {
  children?: React.ReactNode;
}

export const Background: React.FC<BackgroundProps> = ({ children }) => {
  const animatedValue = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(animatedValue, {
          toValue: 1,
          duration: 4000,
          useNativeDriver: false,
        }),
        Animated.timing(animatedValue, {
          toValue: 0,
          duration: 4000,
          useNativeDriver: false,
        }),
      ]),
    ).start();
  }, [animatedValue]);

  const backgroundColor = animatedValue.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: ['#ffffff', '#e3f2fd', '#ffffff'],
  });

  return (
    <View style={styles.container}>
      <Animated.View
        style={[
          styles.animatedBackground,
          {
            backgroundColor,
          },
        ]}
      />
      <View style={styles.content}>{children}</View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    position: 'relative',
  },
  animatedBackground: {
    ...StyleSheet.absoluteFillObject,
  },
  content: {
    flex: 1,
  },
});
