import { StyleSheet, Text, View } from 'react-native';

import * as Scanny from 'scanny';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{Scanny.hello()}</Text>
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
