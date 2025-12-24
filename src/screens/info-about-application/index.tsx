import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Background } from '../../components/atoms/background';
import { InfoAboutApplicationProps } from '../../navigation/types';

export const InfoAboutApplication: React.FC<InfoAboutApplicationProps> = () => {
  const insets = useSafeAreaInsets();

  return (
    <Background>
      <View
        style={[
          styles.container,
          {
            paddingTop: insets.top,
            paddingBottom: insets.bottom,
            paddingLeft: insets.left,
            paddingRight: insets.right,
          },
        ]}
      >
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.header}>
            <Text style={styles.title}>UTM Social Media</Text>
            <Text style={styles.subtitle}>Mobile Application</Text>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>About Us</Text>
            <Text style={styles.sectionText}>
              Welcome to UTM Social Media - Your premier destination for
              connecting with the community and sharing your experiences.
            </Text>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Features</Text>
            <Text style={styles.featureItem}>• Connect with friends</Text>
            <Text style={styles.featureItem}>• Share your moments</Text>
            <Text style={styles.featureItem}>• Discover new content</Text>
            <Text style={styles.featureItem}>• Real-time notifications</Text>
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Version 0.0.1</Text>
          </View>
        </ScrollView>
      </View>
    </Background>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingVertical: 32,
  },
  header: {
    marginBottom: 32,
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#1967D2',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    fontWeight: '400',
    color: '#666666',
  },
  section: {
    marginBottom: 28,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#1967D2',
    marginBottom: 12,
  },
  sectionText: {
    fontSize: 14,
    fontWeight: '400',
    color: '#333333',
    lineHeight: 22,
  },
  featureItem: {
    fontSize: 14,
    fontWeight: '400',
    color: '#333333',
    marginBottom: 8,
    lineHeight: 20,
  },
  footer: {
    marginTop: 'auto',
    paddingTop: 24,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    fontWeight: '400',
    color: '#999999',
  },
});
