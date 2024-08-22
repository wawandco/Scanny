import * as ImagePicker from 'expo-image-picker';
import { useEffect } from 'react';

import { Button, StyleSheet, Text, View } from 'react-native';

import * as Scanny from 'scanny';

export default function App() {
  useEffect(() => {
    requestCameraPermission()
  });

  const requestCameraPermission = async () => {
    await ImagePicker.requestCameraPermissionsAsync()
  }

  function onPress() {
    Scanny.openCamera()
  }

  return (
    <View style={styles.container}>
      <Text>{"Hello"}</Text>
      <Button
        title="Press me."
        onPress={onPress}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
