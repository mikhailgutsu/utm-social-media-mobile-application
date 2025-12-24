import { NativeStackScreenProps } from '@react-navigation/native-stack';

export type RootStackParamList = {
  SplashScreen: undefined;
  InfoAboutApplication: undefined;
};

export type SplashScreenProps = NativeStackScreenProps<
  RootStackParamList,
  'SplashScreen'
>;

export type InfoAboutApplicationProps = NativeStackScreenProps<
  RootStackParamList,
  'InfoAboutApplication'
>;
